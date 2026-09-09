#!/usr/bin/env bash
# Tests for scripts/check-version-bump.sh (ut-docs#1940).
#
# Each case builds a throwaway git repo (real commits, so BASE_SHA/HEAD_SHA
# and `git diff`/`git show` all behave exactly as they do against a real
# PR) with just enough of this repo's layout for the script under test to
# operate on, then runs the real script against a BASE_SHA..HEAD_SHA pair
# and asserts both the exit code and that the failure output actually names
# the changed shipped file(s) and the version -- a script that exits
# non-zero for the wrong reason must not be mistaken for a passing test of
# the real check.
set -euo pipefail
cd "$(dirname "$0")/.."

REAL_SCRIPT="$(pwd)/scripts/check-version-bump.sh"
PACKAGE_SH="$(pwd)/scripts/package.sh"
FAILS=0

work_dir=""
cleanup() {
    [ -n "$work_dir" ] && rm -rf "$work_dir"
}
trap cleanup EXIT

# fresh_repo
# Builds a throwaway git repo ($case_dir) with an initial commit carrying a
# minimal but complete layout (manifest.json v1.0.0, locales/de.json,
# README.md, LICENSE, a workflow file, a docs file). Sets $base_sha to that
# commit. The script under test is copied in (not symlinked -- it does
# `cd "$(dirname "$0")/.."`, which resolves relative to ITS OWN path, so it
# must run from inside the fixture).
fresh_repo() {
    [ -n "$work_dir" ] && rm -rf "$work_dir"
    work_dir="$(mktemp -d)"
    case_dir="${work_dir}/repo"
    mkdir -p "${case_dir}/scripts" "${case_dir}/locales" "${case_dir}/.github/workflows" "${case_dir}/docs/code-reviews"
    cp "$REAL_SCRIPT" "${case_dir}/scripts/check-version-bump.sh"
    chmod +x "${case_dir}/scripts/check-version-bump.sh"

    cat >"${case_dir}/manifest.json" <<'JSON'
{
  "id": "com.universaltill.language-de",
  "name": "German (Deutsch)",
  "version": "1.0.0",
  "locales": ["de"]
}
JSON
    echo '{"a.one": "Eins"}' >"${case_dir}/locales/de.json"
    echo "# German pack" >"${case_dir}/README.md"
    echo "MIT" >"${case_dir}/LICENSE"
    echo "name: CI" >"${case_dir}/.github/workflows/ci.yml"

    (
        cd "$case_dir"
        git init -q
        git config user.email test@example.com
        git config user.name Test
        git add -A
        git commit -q -m "initial"
    )
    base_sha=$(cd "$case_dir" && git rev-parse HEAD)
}

# commit_change - stages whatever the caller already edited in $case_dir
# and commits it, setting $head_sha.
commit_change() {
    (cd "$case_dir" && git add -A && git commit -q -m "change")
    head_sha=$(cd "$case_dir" && git rev-parse HEAD)
}

run_check() {
    (cd "$case_dir" && BASE_SHA="$base_sha" HEAD_SHA="$head_sha" bash scripts/check-version-bump.sh)
}

assert_pass() {
    local name="$1"
    local out rc
    set +e
    out="$(run_check 2>&1)"
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

# --- case 1: locale changed, version NOT bumped -> FAIL, names the file ---
fresh_repo
echo '{"a.one": "Eins", "a.two": "Zwei"}' >"${case_dir}/locales/de.json"
commit_change
assert_fail_containing "locale changed, no bump" \
    "locales/de.json" "manifest.json" "1.0.0" "FAIL"

# --- case 2: locale changed, version bumped -> PASS -----------------------
fresh_repo
echo '{"a.one": "Eins", "a.two": "Zwei"}' >"${case_dir}/locales/de.json"
python3 -c "
import json
m = json.load(open('${case_dir}/manifest.json'))
m['version'] = '1.0.1'
json.dump(m, open('${case_dir}/manifest.json', 'w'))
"
commit_change
assert_pass "locale changed, version bumped"

# --- case 3: README changed, version NOT bumped -> FAIL --------------------
fresh_repo
echo "# German pack, updated" >"${case_dir}/README.md"
commit_change
assert_fail_containing "README changed, no bump" "README.md" "FAIL"

# --- case 4: only manifest.json touched (version bump itself) -> PASS -----
# The bump is itself a shipped-file change, and the version differs -- must
# not require a SECOND shipped file to also have changed.
fresh_repo
python3 -c "
import json
m = json.load(open('${case_dir}/manifest.json'))
m['version'] = '1.0.1'
json.dump(m, open('${case_dir}/manifest.json', 'w'))
"
commit_change
assert_pass "manifest-only version bump"

# --- case 5: docs-only change -> PASS, no bump required --------------------
fresh_repo
echo "# review" >"${case_dir}/docs/code-reviews/2026-09-09-example.md"
commit_change
assert_pass "docs-only change, no bump required"

# --- case 6: workflow-only change -> PASS, no bump required ----------------
fresh_repo
echo "name: CI (updated)" >"${case_dir}/.github/workflows/ci.yml"
commit_change
assert_pass "workflow-only change, no bump required"

# --- case 7: manifest.json changed but NOT the version (e.g. permissions)
# still counts as a shipped-file change, still requires the version to move.
fresh_repo
python3 -c "
import json
m = json.load(open('${case_dir}/manifest.json'))
m['locales'] = ['de']
m['description'] = 'updated blurb'
json.dump(m, open('${case_dir}/manifest.json', 'w'))
"
commit_change
assert_fail_containing "manifest changed without version bump" "manifest.json" "FAIL"

# --- case 8: SHIPPED_PATTERNS mirrors package.sh's own bundle entries -----
# package.sh's `entries=(...)` line is the actual source of truth for what
# ships; this asserts every base name it lists is also covered by
# SHIPPED_PATTERNS in the real script, so the two can't silently drift.
entries_line=$(grep -m1 '^entries=' "$PACKAGE_SH") || entries_line=""
if [ -z "$entries_line" ]; then
    echo "FAIL [entries mirror]: could not find package.sh's entries=(...) line"
    FAILS=$((FAILS + 1))
else
    patterns=$(grep -oE "'[^']*'" "$REAL_SCRIPT" | tr -d "'")
    mismatch=0
    for entry in manifest.json locales README.md; do
        if ! grep -qxF "$entry" <<<"$patterns" && ! grep -qxF "${entry}/*" <<<"$patterns"; then
            echo "FAIL [entries mirror]: package.sh bundles '$entry' but SHIPPED_PATTERNS in check-version-bump.sh has no matching entry"
            mismatch=1
        fi
    done
    if [ "$mismatch" -eq 0 ]; then
        echo "ok   [entries mirror] (package.sh: $entries_line)"
    else
        FAILS=$((FAILS + 1))
    fi
fi

if [ "$FAILS" -ne 0 ]; then
    echo ""
    echo "$FAILS case(s) failed."
    exit 1
fi
echo ""
echo "All check-version-bump.sh cases passed."
