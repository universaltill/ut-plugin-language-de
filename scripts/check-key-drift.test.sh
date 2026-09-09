#!/usr/bin/env bash
# Tests for scripts/check-key-drift.sh (ut-docs#292).
#
# Each case builds a throwaway fixture (a fake core en.json + a temp copy of
# this repo's layout) and runs the real script against it via
# UT_CORE_EN_JSON (or, for the network-failure case, UT_CORE_EN_URL), then
# asserts BOTH the exit code AND that the failure output actually names the
# right category heading AND the right key -- a script that exits non-zero
# for the wrong reason (e.g. a bash syntax error, or the right exit code but
# a mis-categorised report) must not be mistaken for a passing test of the
# real check.
set -euo pipefail
cd "$(dirname "$0")/.."

REAL_SCRIPT="$(pwd)/scripts/check-key-drift.sh"
FAILS=0

work_dir=""
cleanup() {
    [ -n "$work_dir" ] && rm -rf "$work_dir"
}
trap cleanup EXIT

# fresh_case NAME
# Builds a throwaway "repo" ($case_dir) that is a temp working copy of just
# enough of this repo's layout for the script under test to operate on: its
# own scripts/check-key-drift.sh (copied verbatim -- the script does
# `cd "$(dirname "$0")/.."`, which resolves relative to ITS OWN path, so it
# must be invoked from inside the fixture, not the real repo, or it would
# silently check the real repo's files instead of the fixture's) plus
# locales/ and i18n-baseline/ dirs the caller fills in. $core_json is a fake
# core en.json path. Removes the PREVIOUS case's work_dir first -- each call
# used to leak its own mktemp dir (5 fresh_case calls, 1 cleanup at exit);
# the final trap still catches the very last one.
fresh_case() {
    [ -n "$work_dir" ] && rm -rf "$work_dir"
    work_dir="$(mktemp -d)"
    case_dir="${work_dir}/repo"
    mkdir -p "${case_dir}/locales" "${case_dir}/scripts" "${case_dir}/i18n-baseline"
    cp "$REAL_SCRIPT" "${case_dir}/scripts/check-key-drift.sh"
    chmod +x "${case_dir}/scripts/check-key-drift.sh"
    core_json="${work_dir}/core-en.json"
    # Every case gets an empty allowlist by default; cases that care about
    # the allowlist overwrite it.
    : > "${case_dir}/i18n-baseline/de.same-as-en.txt"
}

run_check() {
    # runs from inside case_dir, exactly like the real script expects
    (cd "$case_dir" && UT_CORE_EN_JSON="$core_json" bash "scripts/check-key-drift.sh")
}

run_check_network() {
    # like run_check, but does NOT set UT_CORE_EN_JSON, so the script must
    # actually hit the network (CORE_EN_URL / UT_CORE_EN_URL) -- used for
    # the unreachable-host case.
    (cd "$case_dir" && UT_CORE_EN_URL="$1" bash "scripts/check-key-drift.sh")
}

assert_pass() {
    local name="$1"
    shift
    local out rc
    set +e
    out="$("$@" 2>&1)"
    rc=$?
    set -e
    if [ "$rc" -ne 0 ]; then
        echo "FAIL [$name]: expected exit 0, got $rc. Output:"
        echo "$out"
        FAILS=$((FAILS + 1))
        return
    fi
    echo "ok   [$name]"
}

# assert_fail_containing NAME NEEDLE [NEEDLE...]
# Asserts non-zero exit AND that the output contains every needle given --
# always both the category heading text (e.g. "NOT in the baseline", "are
# stale", "orphan key(s)") AND the specific key name, so a report that names
# the right key under the WRONG heading (mis-categorised) still fails the
# test.
assert_fail_containing() {
    local name="$1"
    shift
    local out rc
    set +e
    out="$(run_check 2>&1)"
    rc=$?
    set -e
    if [ "$rc" -eq 0 ]; then
        echo "FAIL [$name]: expected non-zero exit, got 0. Output:"
        echo "$out"
        FAILS=$((FAILS + 1))
        return
    fi
    local needle
    for needle in "$@"; do
        if ! grep -qF -- "$needle" <<<"$out"; then
            echo "FAIL [$name]: exited non-zero (good) but output did not mention expected reason ('$needle'). Output:"
            echo "$out"
            FAILS=$((FAILS + 1))
            return
        fi
    done
    echo "ok   [$name] (exit $rc, mentions: $*)"
}

# assert_fail_containing_network NAME URL NEEDLE [NEEDLE...]
assert_fail_containing_network() {
    local name="$1" url="$2"
    shift 2
    local out rc
    set +e
    out="$(run_check_network "$url" 2>&1)"
    rc=$?
    set -e
    if [ "$rc" -eq 0 ]; then
        echo "FAIL [$name]: expected non-zero exit, got 0. Output:"
        echo "$out"
        FAILS=$((FAILS + 1))
        return
    fi
    local needle
    for needle in "$@"; do
        if ! grep -qF -- "$needle" <<<"$out"; then
            echo "FAIL [$name]: exited non-zero (good) but output did not mention expected reason ('$needle'). Output:"
            echo "$out"
            FAILS=$((FAILS + 1))
            return
        fi
    done
    echo "ok   [$name] (exit $rc, mentions: $*)"
}

# --- case 1: clean state -> exit 0 -----------------------------------------
fresh_case "clean"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "a.two": "Two",
  "b.three": "Three"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
# baseline
a.two
b.three
TXT
assert_pass "clean state" run_check

# --- case 2: new core key missing from de.json AND baseline -> fail --------
fresh_case "new-drift"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "pfand.action": "Deposit refund"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
# baseline (deliberately does not list pfand.action)
TXT
assert_fail_containing "new drift (uncataloged missing key)" "NOT in the baseline" "pfand.action"

# --- case 3: baseline entry already translated (stale) -> fail ------------
fresh_case "stale-baseline"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "a.two": "Two"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "a.two": "Zwei"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
a.two
TXT
assert_fail_containing "stale baseline entry (now translated)" "are stale" "a.two"

# --- case 4: de.json key core no longer has (orphan) -> fail --------------
fresh_case "orphan"
cat > "$core_json" <<'JSON'
{
  "a.one": "One"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "a.ghost": "Geist"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "orphan key" "orphan key(s)" "a.ghost"

# --- case 5: missing/unreadable UT_CORE_EN_JSON path -> fail, no silent pass
fresh_case "unreadable-core"
# deliberately do NOT create $core_json
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "unreadable core en.json" "does not exist"

# --- case 6: unreachable fetch (real network path, bad host) -> fail ------
fresh_case "unreachable-network"
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing_network "unreachable core URL" \
    "https://this-host-does-not-resolve.invalid/en.json" \
    "FAILED to fetch"

# --- case 7: core en.json is invalid JSON -> hard fail, never a skip ------
fresh_case "core-invalid-json"
printf '{ not valid json' > "$core_json"
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "core en.json invalid JSON" "FAILED to parse" "core base locale"

# --- case 8: de.json is invalid JSON -> hard fail, never a skip -----------
fresh_case "de-invalid-json"
cat > "$core_json" <<'JSON'
{
  "a.one": "One"
}
JSON
printf '{ not valid json' > "${case_dir}/locales/de.json"
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "de.json invalid JSON" "FAILED to parse" "de locale"

# --- case 9: baseline file missing -> hard fail, never a skip -------------
fresh_case "baseline-missing"
cat > "$core_json" <<'JSON'
{
  "a.one": "One"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
# deliberately do NOT create the baseline file
assert_fail_containing "baseline file missing" "FAILED to read" "baseline"

# --- case 10: empty / whitespace-only value -> fail (item 1) --------------
fresh_case "empty-value"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "pfand.action": "Deposit refund"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "pfand.action": "   "
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "empty/whitespace value" "empty or whitespace-only value" "pfand.action"

# --- case 11: value present but byte-identical to core's English, not
#              allowlisted -> fail (the literal ut-docs#292 bug: "Deposit
#              refund" verbatim, present, non-empty, so a key-set-only check
#              would have missed it) ---------------------------------------
fresh_case "untranslated-present"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "pfand.action": "Deposit refund"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "pfand.action": "Deposit refund"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "untranslated-but-present (not allowlisted)" "untranslated-but-present" "pfand.action"

# --- case 12: same as case 11, but the key IS allowlisted -> pass ---------
fresh_case "allowlisted-identical"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "app.name": "Universal Till"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "app.name": "Universal Till"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
cat > "${case_dir}/i18n-baseline/de.same-as-en.txt" <<'TXT'
app.name
TXT
assert_pass "allowlisted identical value passes" run_check

# --- case 13: stale allowlist entry (no longer identical, or key gone) ---
fresh_case "stale-allowlist"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "app.name": "Universal Till"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "app.name": "Universal Till GmbH"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
cat > "${case_dir}/i18n-baseline/de.same-as-en.txt" <<'TXT'
app.name
TXT
assert_fail_containing "stale allowlist entry (translated since)" "are stale" "app.name"

# --- case 14: baseline not sorted/deduplicated -> fail (item 9) -----------
fresh_case "baseline-unsorted"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "a.two": "Two",
  "a.three": "Three"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
a.two
a.three
a.two
TXT
assert_fail_containing "unsorted/duplicated baseline" "not sorted/deduplicated"

# --- case 15: placeholder token COUNT differs -> fail (ut-docs#297) -------
# Core carries %s and %d; the "translation" dropped the %d. A format verb
# that vanishes in translation renders a literal broken string (or crashes
# the formatter) on a German till, so this must fail like any other value
# check.
fresh_case "token-count-differs"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "greet.user": "Hello %s, you have %d items"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "greet.user": "Hallo %s, Sie haben Artikel"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "token count differs" "placeholder token" "greet.user" "core=['%s', '%d']" "de=['%s']"

# --- case 16: token ORDER differs (same count) -> fail --------------------
# Both sides have one %s and one %d, but swapped -- positional formatting
# feeds the arguments in call order, so a swapped pair prints the values in
# the wrong slots even though every token is "present".
fresh_case "token-order-differs"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "swap.msg": "%s of %d"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "swap.msg": "%d von %s"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "token order differs" "placeholder token" "swap.msg" "core=['%s', '%d']" "de=['%d', '%s']"

# --- case 17: tokens match (mixed %s / {{name}} / {0} styles) -> pass -----
# The check must compare the ordered token list, not fail on the mere
# presence of tokens -- a faithful translation that keeps every token in
# order is clean, across all three token syntaxes at once.
fresh_case "tokens-match-mixed"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "mix.msg": "Hi %s, see {{name}} at {0}"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "mix.msg": "Hallo %s, siehe {{name}} um {0}"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_pass "matching tokens (mixed styles) pass" run_check

# --- case 18: "%" immediately before a flag-shaped letter in plain prose
# must NOT be mistaken for a printf verb (ut-docs#1865) ---------------------
# Real false positive found against core's own en.json while writing this
# check: "a 10%-off code" parsed under the old permissive flag class as
# flag "-" + verb "o" (octal). Both sides carry the identical "%-off"
# text and zero real verbs -- must pass.
fresh_case "percent-prose-not-a-verb"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "promo.hint": "includes a 10%-off code"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "promo.hint": "enthaelt einen 10%-off Code"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_pass "percent sign in prose is not a verb" run_check

# --- case 19: Go explicit positional verbs may legitimately reorder -------
# German puts the count before the noun differently than English might;
# %[1]d/%[2]s on both sides, just written in a different order, must pass
# because the explicit index -- not writing order -- says which argument
# goes where.
fresh_case "positional-reorder-allowed"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "pos.msg": "%[1]d of %[2]s"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "pos.msg": "%[2]s: %[1]d"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_pass "positional verb reorder is allowed" run_check

# --- case 19b: a positional verb whose SHAPE changed at the same index
# must still fail -- reordering is the only thing the positional
# exception permits, not a free pass on verb identity. Without real
# positional comparison, "%[1]d of %[2]s" extracts zero tokens on both
# sides and would pass vacuously -- this case only passes with real
# positional-verb comparison (ut-docs#1865 review finding 2).
fresh_case "positional-shape-changed"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "pos.msg": "%[1]d of %[2]s"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "pos.msg": "%[1]s of %[2]s"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "positional verb shape changed at the same index" "placeholder token" "pos.msg"

# --- case 20: a PLAIN (non-positional) reorder must still fail ------------
# Same shape as case 16, restated to make explicit that writing-order
# swaps stay rejected even though case 19's EXPLICIT positional reorder is
# allowed -- the two must not be conflated.
fresh_case "plain-reorder-still-fails"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "plain.msg": "%d of %s"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "plain.msg": "%s von %d"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "plain reorder without positional verbs still fails" "placeholder token" "plain.msg"

# --- case 21: mixing positional and implicit verbs in the same string is
# rejected rather than guessed at ------------------------------------------
fresh_case "mixed-positional-and-implicit-rejected"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "mixed.msg": "%[1]d of %s"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "mixed.msg": "%[1]d von %s"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "mixed positional/implicit verbs in one string are rejected" "placeholder token" "mixed.msg"

# --- case 22: a positional printf verb alongside a template token is a
# DIFFERENT dialect pairing, not "mixed positional/implicit printf" --
# must not be rejected just because the template token has no positional
# index of its own. Independent review found the original implementation
# made this combination unsatisfiable by ANY translation, including a
# byte-for-byte copy of core's value (ut-docs#1865 review finding 1).
fresh_case "positional-with-template-token"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "postmpl.msg": "%[1]d of {{name}}"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "postmpl.msg": "{{name}}: %[1]d"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_pass "positional verb alongside a template token" run_check

# --- case 23: "%" directly followed by digits, a verb letter, THEN more
# letters with no boundary (the un-hyphenated sibling of case 18) must
# not be mistaken for a verb with prose glued on (ut-docs#1865 review
# finding 4).
fresh_case "percent-prose-no-hyphen"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "promo.hint2": "including a 10%off code"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "promo.hint2": "enthaelt einen 10%off Code"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_pass "percent sign directly followed by prose letters is not a verb" run_check

# --- case 24: a dropped %% (differing literal-percent count) must fail
# even though the extracted verb-token list is IDENTICAL on both sides
# (ut-docs#1873) -------------------------------------------------------
# "50%% off, %d left" -> "50% off, %d left" drops one of the two `%`
# characters in the literal-percent pair. verb_tokens() discards %% as
# "not a verb" on both sides, so both extract to the identical ['%d'] --
# the pre-existing verb-list comparison alone passes this vacuously. Only
# a separate count-of-%%-occurrences check catches it; left uncaught,
# this is the exact %!d(MISSING)-class corruption case 15's check exists
# to prevent.
fresh_case "percent-literal-count-differs"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "promo.pct": "50%% off, %d left"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins",
  "promo.pct": "50% off, %d left"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
TXT
assert_fail_containing "dropped %% (literal-percent count differs)" "placeholder token" "promo.pct" "differing count of literal %% occurrences"

# run_update_baseline [EXTRA_ARG]
# Like run_check but invokes --update-baseline (optionally + --allow-growth),
# from inside case_dir, matching how the real script expects to be run.
run_update_baseline() {
    (cd "$case_dir" && UT_CORE_EN_JSON="$core_json" bash "scripts/check-key-drift.sh" --update-baseline ${1:-})
}

# assert_fail_containing_growth NAME NEEDLE [NEEDLE...]
# Same contract as assert_fail_containing, but against run_update_baseline
# (no --allow-growth) instead of the default check -- assert_fail_containing
# itself is hardcoded to run_check, so this is its --update-baseline sibling.
assert_fail_containing_growth() {
    local name="$1"
    shift
    local out rc
    set +e
    out="$(run_update_baseline 2>&1)"
    rc=$?
    set -e
    if [ "$rc" -eq 0 ]; then
        echo "FAIL [$name]: expected non-zero exit, got 0. Output:"
        echo "$out"
        FAILS=$((FAILS + 1))
        return
    fi
    local needle
    for needle in "$@"; do
        if ! grep -qF -- "$needle" <<<"$out"; then
            echo "FAIL [$name]: exited non-zero (good) but output did not mention expected reason ('$needle'). Output:"
            echo "$out"
            FAILS=$((FAILS + 1))
            return
        fi
    done
    echo "ok   [$name]"
}

# --- case 18: --update-baseline on a NON-empty baseline needs no flag -----
# Ratchet mode is unaffected by the ut-docs#297 exact-parity guard -- only
# an already-empty (full-parity) baseline is protected.
fresh_case "update-baseline (already non-empty, no flag needed)"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "a.two": "Two",
  "a.three": "Three"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
cat > "${case_dir}/i18n-baseline/de.untranslated.txt" <<'TXT'
a.two
TXT
assert_pass "update-baseline, already non-empty" run_update_baseline

# --- case 19: --update-baseline on an EMPTY (full-parity) baseline, ------
# NO --allow-growth -> refuse (ut-docs#297).
fresh_case "update-baseline (full parity, no --allow-growth)"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "a.two": "Two"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
: > "${case_dir}/i18n-baseline/de.untranslated.txt"
assert_fail_containing_growth "update-baseline refuses to reopen full parity" \
    "currently at full parity" "refusing to reopen it" "1 new untranslated"

# --- case 20: --update-baseline --allow-growth on an empty baseline ------
# -> proceeds, and the baseline file actually gets the new entry.
fresh_case "update-baseline --allow-growth (deliberate reopen)"
cat > "$core_json" <<'JSON'
{
  "a.one": "One",
  "a.two": "Two"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
: > "${case_dir}/i18n-baseline/de.untranslated.txt"
assert_pass "update-baseline --allow-growth proceeds" run_update_baseline "--allow-growth"
if ! grep -qF "a.two" "${case_dir}/i18n-baseline/de.untranslated.txt"; then
    echo "FAIL [update-baseline --allow-growth writes the entry]: a.two missing from baseline after update"
    FAILS=$((FAILS + 1))
else
    echo "ok   [update-baseline --allow-growth writes the entry]"
fi

# --- case 21: --update-baseline on an empty baseline with NOTHING missing -
# -> still full parity, no growth attempted -> succeeds without the flag.
fresh_case "update-baseline (still full parity, nothing to add)"
cat > "$core_json" <<'JSON'
{
  "a.one": "One"
}
JSON
cat > "${case_dir}/locales/de.json" <<'JSON'
{
  "a.one": "Eins"
}
JSON
: > "${case_dir}/i18n-baseline/de.untranslated.txt"
assert_pass "update-baseline, nothing missing, no flag needed" run_update_baseline

echo
if [ "$FAILS" -ne 0 ]; then
    echo "check-key-drift.test.sh: ${FAILS} test(s) FAILED"
    exit 1
fi
echo "check-key-drift.test.sh: all tests passed"
