#!/usr/bin/env bash
# Tests for scripts/check-version-bump.sh (ut-docs#1940).
#
# The cases every plugin repo shares live in
# scripts/check-version-bump.cases.sh, byte-identical in every ut-plugin-*
# repo (canonical copy: ut-docs scripts/templates/check-version-bump.cases.sh,
# ut-docs#5143) -- never edit it here. This file keeps only what is this
# repo's own: the fixture layout (vb_fixture) and the entries mirror against
# this repo's package.sh.
#
# Each case builds a throwaway git repo (real commits, so BASE_SHA/HEAD_SHA
# and `git diff`/`git show` behave exactly as against a real PR), runs the
# real script against a BASE_SHA..HEAD_SHA pair, and asserts both the exit
# code and that the failure output names the reason.
set -euo pipefail
cd "$(dirname "$0")/.."

PACKAGE_SH="$(pwd)/scripts/package.sh"

# Asset-only: package.sh bundles tracked files, so SHIPPED_PATTERNS lists the
# bundled paths themselves.
# shellcheck disable=SC2034 # read by the sourced cases file
VB_VARIANT=assets
# shellcheck disable=SC2034
VB_SHIPPED_FILE=locales/de.json

# vb_fixture: this repo's minimal layout, written into $case_dir.
vb_fixture() {
    mkdir -p "${case_dir}/locales"
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
}

# shellcheck source=scripts/check-version-bump.cases.sh
. scripts/check-version-bump.cases.sh

vb_run_shared_cases

# --- per-repo case: SHIPPED_PATTERNS mirrors package.sh's own bundle entries -----
# package.sh's `entries=(...)` line is the actual source of truth for what
# ships; this parses the ACTUAL array contents out of that line (not a
# hardcoded restatement of what we expect it to say) and asserts every name
# it lists is also covered by SHIPPED_PATTERNS in the real script, so a real
# change to package.sh's bundle (e.g. adding a CHANGELOG.md entry) is
# caught here instead of silently drifting undetected.
entries_line=$(grep -m1 '^entries=' "$PACKAGE_SH") || entries_line=""
if [ -z "$entries_line" ]; then
    echo "FAIL [entries mirror]: could not find package.sh's entries=(...) line"
    FAILS=$((FAILS + 1))
else
    array_body="${entries_line#entries=(}"
    array_body="${array_body%)}"
    read -r -a bundle_entries <<<"$array_body"
    patterns=$(grep -oE "'[^']*'" "$REAL_SCRIPT" | tr -d "'")
    mismatch=0
    for entry in "${bundle_entries[@]}"; do
        if ! grep -qxF "$entry" <<<"$patterns" && ! grep -qxF "${entry}/*" <<<"$patterns"; then
            echo "FAIL [entries mirror]: package.sh bundles '$entry' but SHIPPED_PATTERNS in check-version-bump.sh has no matching entry"
            mismatch=1
        fi
    done
    # LICENSE ships conditionally ([ -f LICENSE ] && entries+=(LICENSE)),
    # so it never appears on package.sh's own entries=(...) line -- checked
    # separately here rather than assumed.
    if ! grep -qxF "LICENSE" <<<"$patterns"; then
        echo "FAIL [entries mirror]: package.sh conditionally bundles LICENSE (when present) but SHIPPED_PATTERNS has no LICENSE entry"
        mismatch=1
    fi
    if [ "$mismatch" -eq 0 ]; then
        echo "ok   [entries mirror] (package.sh: ${bundle_entries[*]} + conditional LICENSE)"
    else
        FAILS=$((FAILS + 1))
    fi
fi

vb_finish
