#!/usr/bin/env bash
#
# Requires a manifest.json version bump on any PR that touches a shipped
# file (ut-docs#1940).
#
# WHY THIS EXISTS: scripts/package.sh bundles manifest.json, locales/ and
# README.md (plus LICENSE when present) into the marketplace release
# artifact. None of this repo's other checks (key-drift, validate, authors)
# look at the version field, so a PR that edits locales/*.json but forgets
# to bump manifest.json's version lands on main, passes every check, and
# then SILENTLY NEVER SHIPS: auto-tag-release.yml reads the unchanged
# version, sees v<version> already tagged/released, and correctly does
# nothing. main and the marketplace diverge with no failing signal
# anywhere. This has already needed hand repair at least three times
# (v1.1.32, v1.1.33->34, and the duplicated-keys fix for ut-docs#1863) plus
# twice more on 2026-09-09 alone, in two different lanes.
#
# WHAT COUNTS AS "SHIPPED": deliberately keyed off the same set
# scripts/package.sh actually bundles, not "any file" -- a docs/code-reviews/
# record or a workflow-only edit must never force a version bump. Keep this
# list mirrored to package.sh's own `entries=(...)` line; nothing enforces
# that automatically, so a change to package.sh's bundle needs a matching
# edit here (and check-version-bump.test.sh's "entries mirror" case exists
# to catch drift between the two by re-reading package.sh's own source).
set -euo pipefail
cd "$(dirname "$0")/.."

SHIPPED_PATTERNS=(
    'manifest.json'
    'locales/*'
    'README.md'
    'LICENSE'
)

# BASE_SHA/HEAD_SHA follow the same convention as
# .github/workflows/commit-attribution.yml: passed in by the workflow from
# the pull_request event (github.event.pull_request.base.sha / head.sha).
# For a local/manual run, fall back to comparing against origin/main.
BASE_SHA="${BASE_SHA:-}"
HEAD_SHA="${HEAD_SHA:-}"
if [ -z "$BASE_SHA" ]; then
    BASE_SHA=$(git merge-base HEAD origin/main 2>/dev/null || true)
fi
if [ -z "$HEAD_SHA" ]; then
    HEAD_SHA=$(git rev-parse HEAD)
fi
if [ -z "$BASE_SHA" ]; then
    echo "ERROR: could not determine BASE_SHA (set BASE_SHA explicitly, or ensure origin/main is fetched)"
    exit 1
fi

changed_files=$(git diff --name-only "$BASE_SHA" "$HEAD_SHA" -- .)

shipped_changed=()
while IFS= read -r f; do
    [ -n "$f" ] || continue
    for pat in "${SHIPPED_PATTERNS[@]}"; do
        # shellcheck disable=SC2053 -- intentional unquoted glob match
        if [[ "$f" == $pat ]]; then
            shipped_changed+=("$f")
            break
        fi
    done
done <<<"$changed_files"

if [ "${#shipped_changed[@]}" -eq 0 ]; then
    echo "ok: no shipped file changed (${BASE_SHA:0:9}..${HEAD_SHA:0:9}) -- no version bump required"
    exit 0
fi

read_version() {
    # $1 = git ref. Fails closed (non-empty error) if manifest.json is
    # missing or doesn't parse at that ref, rather than silently treating
    # it as "no version".
    git show "$1:manifest.json" 2>/dev/null | python3 -c '
import json, sys
try:
    print(json.load(sys.stdin)["version"])
except Exception as e:
    print(f"ERROR:{e}", file=sys.stderr)
    sys.exit(1)
'
}

base_version=$(read_version "$BASE_SHA") || {
    echo "ERROR: could not read manifest.json version at base ${BASE_SHA:0:9}"
    exit 1
}
head_version=$(read_version "$HEAD_SHA") || {
    echo "ERROR: could not read manifest.json version at head ${HEAD_SHA:0:9}"
    exit 1
}

if [ "$base_version" = "$head_version" ]; then
    # Suggest a patch bump as a starting point -- the author picks
    # minor/major if the change actually warrants it.
    IFS='.' read -r major minor patch <<<"$head_version"
    suggested="${major}.${minor}.$((patch + 1))"
    {
        echo "FAIL: shipped file(s) changed but manifest.json's version is still ${head_version}."
        echo ""
        echo "Changed shipped file(s):"
        printf '  - %s\n' "${shipped_changed[@]}"
        echo ""
        echo "Why this fails the build: scripts/package.sh bundles these files into"
        echo "the release artifact, and auto-tag-release.yml only cuts a release when"
        echo "manifest.json's version differs from the last tag. Without a bump, this"
        echo "change lands on main and then SILENTLY NEVER SHIPS -- the marketplace"
        echo "keeps serving the old ${head_version} artifact with no failing signal"
        echo "anywhere (ut-docs#1940)."
        echo ""
        echo "Fix: bump manifest.json's \"version\" in this PR -- e.g. to \"${suggested}\""
        echo "(a plain patch bump; use minor/major instead if this change warrants it)."
    } >&2
    exit 1
fi

echo "ok: manifest.json version bumped ${base_version} -> ${head_version}, covering:"
printf '  - %s\n' "${shipped_changed[@]}"
