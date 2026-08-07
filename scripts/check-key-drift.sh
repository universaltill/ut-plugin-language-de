#!/usr/bin/env bash
#
# Ratcheting key-parity guard against core's base locale (ut-docs#292).
#
# WHY A RATCHET, NOT A HARDCODED "de.json == en.json": ADR-0010 makes a
# language pack an asset-only overlay -- core's T() falls back de -> en on a
# missing key, so an untranslated key degrades gracefully to English rather
# than breaking the till, which means a temporary gap (core ships a key
# today, this pack translates it next week) is a legitimate, trackable
# state, not automatically a bug. So the check is not a literal file-equality
# assertion; it's "the untranslated set today is EXACTLY the untranslated
# set the baseline file says we already know about, no more, no less" --
# PLUS: every key de.json claims to translate must actually carry a real,
# non-empty, actually-German value (see "value checks" below), because a key
# present in de.json is not by itself evidence of a translation.
#
# EXACT PARITY, ENFORCED (ut-docs#297): as of the 2026-08 translation pass,
# the baseline is 0 entries -- de.json covers every core key. That makes the
# ratchet's existing behavior into a de facto exact-parity check already
# (with an empty baseline, ANY newly-missing key is unconditionally
# "not in the baseline" = new drift = FAIL; see the missing/new_drift logic
# below, unchanged). What's added here so that isn't just an accident of the
# current state: `--update-baseline` (the one command that can reopen debt)
# now REFUSES to grow an empty baseline unless the caller also passes
# `--allow-growth`. Regressing from 100% coverage back into ratchet mode is
# still possible -- core will keep adding keys this pack won't always
# translate same-day -- but it now takes a second, explicitly-named flag,
# not just re-running the normal update command out of habit.
#
# What actually broke in #292: core shipped 6 new pfand.* keys and this
# pack was never updated, so a German till silently rendered English
# ("Deposit refund" instead of "Pfandrückgabe") -- ADR-0010's fallback
# masked the gap instead of surfacing it. Nothing failed anywhere. This
# script is what should have caught that: any NEW gap between core and
# de.json that isn't already accounted for in the baseline is drift, and
# drift fails CI loudly instead of shipping silently.
#
# The baseline (i18n-baseline/de.untranslated.txt) tracks known-accepted
# gaps:
#   - a core key with no de.json translation is fine IFF it's already
#     listed in the baseline (known, accepted debt);
#   - a core key with no de.json translation that is NOT in the baseline
#     is new drift -- FAIL (this is what would have caught #292);
#   - a baseline entry that HAS since been translated is a stale baseline
#     entry -- FAIL (forces pruning, so the baseline can never quietly
#     grow stale and hide a real re-regression later);
#   - a baseline entry core no longer has is also stale -- FAIL, prune it;
#   - a de.json key core doesn't have at all is an orphan -- FAIL always,
#     no baseline exception (a pack has no business inventing base keys).
# This set cannot grow SILENTLY: it can only grow through a deliberate,
# reviewed edit to the baseline file itself, which shows up in the diff.
# That is not the same claim as "only shrinks" -- adding a key on purpose
# is the documented escape hatch, not a violation of the guard.
#
# VALUE CHECKS (the part key-set comparison alone misses): a key can be
# *present* in de.json and still not be a real translation --
#   - empty / whitespace-only value -- FAIL always. Core's T() returns
#     whatever de.json has unconditionally, so an empty value renders
#     blank UI in production, which is worse than the English fallback a
#     missing key would have produced.
#   - value byte-identical to core's English value -- FAIL, UNLESS the key
#     is listed in the same-as-English allowlist
#     (i18n-baseline/de.same-as-en.txt) for strings that are legitimately
#     identical in both languages (brand names, "Online", "GitHub", ...).
#     This is the literal ut-docs#292 bug: "pfand.action": "Deposit
#     refund" is present, non-empty, and would pass a key-set-only check.
#   - the allowlist has the same staleness rule as the baseline: an entry
#     that is no longer byte-identical (translated since, or core's string
#     changed) or whose key no longer exists must FAIL so it gets pruned.
#   - placeholder token mismatch (ut-docs#297): for every key present on
#     both sides, the ORDERED list of format tokens (%s / %d / %g / ...,
#     {{name}}, {0}) extracted from core's value must equal the list
#     extracted from de.json's value. A dropped or invented token renders a
#     broken string in production; a REORDERED pair is just as wrong --
#     positional formatting feeds arguments in call order, so a swapped
#     %s/%d prints the values in the wrong slots even though both sides
#     have the same token count.
#
# A missing/unreachable core source is a HARD failure, never a skip: a
# guard that quietly exits 0 when it can't fetch its own input is the
# exact silent-gap failure mode this script exists to close.
#
# Usage:
#   scripts/check-key-drift.sh                 # run the check (default)
#   scripts/check-key-drift.sh --update-baseline    # rewrite the baseline
#   scripts/check-key-drift.sh --update-baseline --allow-growth  # ...even
#                                                    if that reopens debt on
#                                                    a baseline currently at
#                                                    full parity (ut-docs#297)
#   scripts/check-key-drift.sh --update-allowlist   # rewrite the allowlist
# Both --update-* flags resolve core's base locale exactly like the check
# does (UT_CORE_EN_JSON / UT_CORE_EN_URL / CORE_EN_URL below), so there is
# one single source of truth for "how do I find core's en.json" -- no
# hand-rolled comm/jq pipeline to keep in sync separately.
set -euo pipefail

MODE="check"
ALLOW_GROWTH="0"
for arg in "$@"; do
    case "$arg" in
        --update-baseline) MODE="update-baseline" ;;
        --update-allowlist) MODE="update-allowlist" ;;
        --allow-growth) ALLOW_GROWTH="1" ;;
        *)
            echo "check-key-drift: unknown argument: $arg" >&2
            echo "usage: $0 [--update-baseline [--allow-growth]|--update-allowlist]" >&2
            exit 1
        ;;
    esac
done

# Resolve UT_CORE_EN_JSON against the CALLER's cwd before we cd -- a
# relative path here is meant to be relative to wherever the caller ran
# this from, not to the repo root we cd into next.
if [ -n "${UT_CORE_EN_JSON:-}" ]; then
    case "$UT_CORE_EN_JSON" in
        /*) ;; # already absolute
        *) UT_CORE_EN_JSON="$(pwd)/${UT_CORE_EN_JSON}" ;;
    esac
fi

cd "$(dirname "$0")/.."

CORE_EN_URL="${UT_CORE_EN_URL:-https://raw.githubusercontent.com/universaltill/universal-till/main/web/locales/en.json}"
BASELINE="i18n-baseline/de.untranslated.txt"
ALLOWLIST="i18n-baseline/de.same-as-en.txt"
DE_LOCALE="locales/de.json"

CORE_EN_JSON=""
CORE_TMP=""
cleanup() {
    # NB: must not end on a false test -- "[ -n "$x" ] && rm ..." evaluates
    # to the test's (false) status when $x is empty, and that becomes the
    # trap's exit status, which becomes the whole script's exit status,
    # silently turning a real success into a false failure.
    if [ -n "$CORE_TMP" ]; then
        rm -f "$CORE_TMP"
    fi
}
trap cleanup EXIT INT TERM

# Resolve core's base locale JSON to a local file, one way or the other.
# UT_CORE_EN_JSON lets this run offline / in tests without hitting network.
if [ -n "${UT_CORE_EN_JSON:-}" ]; then
    CORE_EN_JSON="${UT_CORE_EN_JSON}"
    if [ ! -f "$CORE_EN_JSON" ]; then
        echo "check-key-drift: UT_CORE_EN_JSON=${CORE_EN_JSON} does not exist" >&2
        exit 1
    fi
else
    CORE_TMP="$(mktemp)"
    CORE_EN_JSON="$CORE_TMP"
    CORE_SHA="unknown"
    if command -v gh >/dev/null 2>&1; then
        CORE_SHA="$(gh api repos/universaltill/universal-till/commits/main --jq .sha 2>/dev/null || echo unknown)"
    fi
    if ! curl -fsSL "$CORE_EN_URL" -o "$CORE_EN_JSON"; then
        echo "check-key-drift: FAILED to fetch core base locale from ${CORE_EN_URL}" >&2
        echo "check-key-drift: cannot verify key parity -- refusing to pass silently." >&2
        echo "check-key-drift: set UT_CORE_EN_JSON=<path> to check against a local checkout instead." >&2
        echo "check-key-drift: resolved core commit: ${CORE_SHA}" >&2
        exit 1
    fi
fi

python3 - "$CORE_EN_JSON" "$DE_LOCALE" "$BASELINE" "$ALLOWLIST" "$MODE" "${CORE_SHA:-unknown}" "$ALLOW_GROWTH" <<'PY'
import json
import re
import sys

core_path, de_path, baseline_path, allowlist_path, mode, core_sha, allow_growth = sys.argv[1:8]
allow_growth = allow_growth == "1"

# Ordered format-token extraction (ut-docs#297): printf-style verbs (%s, %d,
# %g, ...), template tokens ({{name}}), and positional tokens ({0}). The
# {{...}} alternative must come before {N} so "{{0}}" reads as one template
# token, not "{0}" inside braces.
TOKEN_RE = re.compile(r"%[a-zA-Z]|\{\{[^{}]*\}\}|\{\d+\}")

def load_json(path, label):
    try:
        return json.load(open(path))
    except Exception as e:
        print(f"check-key-drift: FAILED to parse {label} {path}: {e}", file=sys.stderr)
        sys.exit(1)

def load_keylist(path, label):
    try:
        lines = open(path).read().splitlines()
    except Exception as e:
        print(f"check-key-drift: FAILED to read {label} {path}: {e}", file=sys.stderr)
        sys.exit(1)
    body = [ln.strip() for ln in lines if ln.strip() and not ln.strip().startswith("#")]
    if body != sorted(set(body)):
        print(
            f"check-key-drift: {path} is not sorted/deduplicated -- it must be "
            "one key per line, sorted, unique. Regenerate it instead of hand-editing.",
            file=sys.stderr,
        )
        sys.exit(1)
    return set(body)

def leading_header(path):
    """The leading run of blank/comment lines in a keylist file -- preserved
    verbatim when the body is regenerated, so --update-* never clobbers the
    file's own documentation."""
    with open(path) as f:
        all_lines = f.read().splitlines(keepends=True)
    hdr = []
    for line in all_lines:
        if line.lstrip().startswith("#") or line.strip() == "":
            hdr.append(line)
        else:
            break
    return hdr

def rewrite_body(path, keys):
    hdr = leading_header(path)
    with open(path, "w") as f:
        f.writelines(hdr)
        for k in keys:
            f.write(k + "\n")

core = load_json(core_path, "core base locale")
de = load_json(de_path, "de locale")

core_keys = set(core.keys())
de_keys = set(de.keys())

if mode == "update-baseline":
    missing = sorted(core_keys - de_keys)
    # ut-docs#297 exact-parity guard: once the baseline has reached 0 (full
    # coverage), regenerating it into a non-empty file is REOPENING debt,
    # not routine bookkeeping -- require the caller to say so explicitly
    # rather than let a routine `--update-baseline` silently regress
    # 100% coverage back into ratchet mode.
    try:
        current_baseline = load_keylist(baseline_path, "baseline")
    except SystemExit:
        current_baseline = None  # unreadable/missing -- not our concern here, let the rewrite proceed
    if current_baseline == set() and missing and not allow_growth:
        print(
            f"check-key-drift: {baseline_path} is currently at full parity (0 entries) -- "
            f"refusing to reopen it with {len(missing)} new untranslated key(s) via a plain "
            "--update-baseline.",
            file=sys.stderr,
        )
        print(
            "check-key-drift: pass --update-baseline --allow-growth if this is a deliberate "
            "decision to accept new untranslated debt (e.g. core just shipped a batch of keys "
            "this pack hasn't caught up on yet) -- translating the new keys instead is preferred.",
            file=sys.stderr,
        )
        sys.exit(1)
    rewrite_body(baseline_path, missing)
    print(f"check-key-drift: wrote {len(missing)} entries to {baseline_path}")
    sys.exit(0)

if mode == "update-allowlist":
    identical_now = sorted(k for k in (core_keys & de_keys) if de[k] == core[k])
    rewrite_body(allowlist_path, identical_now)
    print(f"check-key-drift: wrote {len(identical_now)} entries to {allowlist_path}")
    sys.exit(0)

baseline = load_keylist(baseline_path, "baseline")
allowlist = load_keylist(allowlist_path, "same-as-English allowlist")

missing = core_keys - de_keys       # core has it, de.json doesn't
orphans = de_keys - core_keys       # de.json has it, core doesn't

new_drift = sorted(missing - baseline)          # untranslated, not in baseline
stale_translated = sorted(baseline - missing)    # in baseline, but not actually missing anymore

# Value checks: a key can be present and still not be a real translation.
empty_keys = {k for k in de_keys if de[k].strip() == ""}
empty_values = sorted(empty_keys)

identical_to_en = {k for k in (core_keys & de_keys) if k not in empty_keys and de[k] == core[k]}
untranslated_present = sorted(identical_to_en - allowlist)
stale_allowlist = sorted(k for k in allowlist if k not in identical_to_en)

# Token parity (ut-docs#297): same tokens, same order, on every shared key.
token_mismatches = [
    (k, TOKEN_RE.findall(core[k]), TOKEN_RE.findall(de[k]))
    for k in sorted(core_keys & de_keys)
    if TOKEN_RE.findall(core[k]) != TOKEN_RE.findall(de[k])
]

fail = False

if new_drift:
    fail = True
    print(f"check-key-drift: {len(new_drift)} core key(s) missing from {de_path} and NOT in the baseline (new drift):")
    for k in new_drift:
        print(f"  - {k}")

if stale_translated:
    fail = True
    print(f"check-key-drift: {len(stale_translated)} baseline entr(y/ies) in {baseline_path} are stale (translated, or core dropped them) -- prune them:")
    for k in stale_translated:
        print(f"  - {k}")

if orphans:
    fail = True
    print(f"check-key-drift: {len(orphans)} orphan key(s) in {de_path} that core no longer has:")
    for k in sorted(orphans):
        print(f"  - {k}")

if empty_values:
    fail = True
    print(f"check-key-drift: {len(empty_values)} key(s) in {de_path} have an empty or whitespace-only value:")
    for k in empty_values:
        print(f"  - {k}")

if untranslated_present:
    fail = True
    print(f"check-key-drift: {len(untranslated_present)} key(s) in {de_path} are byte-identical to core's English value and NOT in the allowlist (untranslated-but-present):")
    for k in untranslated_present:
        print(f"  - {k}")

if stale_allowlist:
    fail = True
    print(f"check-key-drift: {len(stale_allowlist)} allowlist entr(y/ies) in {allowlist_path} are stale (no longer identical to core, or key missing) -- prune them:")
    for k in stale_allowlist:
        print(f"  - {k}")

if token_mismatches:
    fail = True
    print(f"check-key-drift: {len(token_mismatches)} key(s) in {de_path} have a placeholder token mismatch against core (dropped, invented, or reordered %s/{{...}}/{{N}} tokens):")
    for k, ct, dt in token_mismatches:
        print(f"  - {k}: core={ct} de={dt}")

print(f"check-key-drift: core commit: {core_sha}")

if fail:
    sys.exit(1)

translated = len(core_keys) - len(missing)
print(f"check-key-drift: ok -- {translated}/{len(core_keys)} core keys translated, "
      f"{len(missing)} known-untranslated (baseline), {len(allowlist)} known-same-as-English (allowlist), "
      f"0 drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token mismatches")
PY
