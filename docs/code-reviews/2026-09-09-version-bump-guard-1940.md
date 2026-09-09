# Code review: manifest.json version-bump CI guard (ut-docs#1940)

**Date:** 2026-09-09
**Author:** Farshid Mirza (pipeline, Sonnet dev, `complexity:medium`)
**Independent reviewer:** Opus, fresh-context subagent (`isolation: "worktree"`)
**PR:** universaltill/ut-plugin-language-de#... (this branch: `feat/1940-version-bump-guard`)

## What shipped

`scripts/check-version-bump.sh` + `scripts/check-version-bump.test.sh` + a
new `version-bump` CI job in `.github/workflows/ci.yml` (PR-only) + a
`CLAUDE.md` note. Requires `manifest.json`'s `version` to change on any PR
that touches a shipped file (`manifest.json`, `locales/*`, `README.md`,
`LICENSE` — the same set `scripts/package.sh` bundles into the release
artifact). Without a bump, `auto-tag-release.yml` sees the version already
tagged/released and correctly no-ops — the change lands on `main` and
silently never ships. This has already needed hand repair at least three
times, plus twice more on 2026-09-09 alone in two different lanes.

Scope: this PR covers `ut-plugin-language-de` only. The mechanical rollout
to the other `ut-plugin-*` repos is filed separately as ut-docs#1948.

## Independent review findings

First pass verdict: **FAIL — do not merge as-is.** Two blockers, both
reproduced with live runs against the actual script:

- **B1 (blocker):** the CI path diffed/read directly against
  `github.event.pull_request.base.sha` (two-dot, against a value that
  advances as `main` advances) instead of this PR's actual merge-base.
  Reproduced both directions live:
  - **False negative** (the case that matters most — this is the exact
    multi-lane bug the card exists to catch): once *any other* shipped-file
    PR merges and bumps the version, every other still-open shipped-file PR
    would start comparing against that higher base version and pass
    unbumped.
  - **False positive:** a docs-only PR whose `base.sha` happened to sit
    after an unrelated unbumped shipped change on `main` would be told to
    bump for someone else's change — violating the card's own explicit
    "a PR touching only docs/.github must NOT require a bump" requirement.
- **B2 (blocker):** `IFS='.' read -r major minor patch <<<"$head_version"`
  followed by unchecked `$((patch + 1))` arithmetic. A version like
  `1.0.0-beta.1` (which this repo's own `validate.sh` regex — unanchored at
  the end — and `auto-tag-release.yml`'s own pattern both already accept)
  makes `patch` a non-integer string. The arithmetic error aborted the `if`
  body *without* tripping `set -e` (it's inside a compound conditional),
  which skipped the `FAIL:`/`exit 1` and fell through to the success path —
  reviewer reproduced a real exit-0 "ok: bumped" report for an unbumped,
  reachable version scheme.

Plus one test-suite gap that undermined the safety net itself:

- **N2:** the "entries mirror" self-test hardcoded the expected file list
  (`for entry in manifest.json locales README.md`) instead of actually
  parsing `package.sh`'s `entries=(...)` line, so it could never catch the
  exact drift it claimed to catch. Reviewer proved this by adding
  `CHANGELOG.md` to a copy of `package.sh`'s bundle and confirming the test
  suite stayed green.

Also flagged, and fixed in the same pass since they were cheap and
directly related:

- **N1:** a version that differs from base but is already tagged elsewhere
  (reused/backwards) passed and was described as "bumped" — same silent
  failure with a green guard.
- **N3:** git-quoted (non-ASCII) shipped paths wouldn't match the glob
  patterns — closed as a side effect of the B1 fix (`core.quotePath=false`
  added to the diff call).
- **N5:** the test harness's `EXIT` trap could itself set a nonzero exit
  status via `[ -n "$work_dir" ]` under `set -e`, independent of whether
  every case passed.

Deferred, not fixed (both genuinely low-severity and out of the card's
scope):

- **N4:** a malformed `BASE_SHA` env value surfaces a raw `git` plumbing
  error rather than the script's own clearer `ERROR:` wording. Every other
  failure path already degrades cleanly; this one is inconsistent but
  low-impact (a misconfigured workflow, not a real PR state).
- Nits: `if: always()` on the version-bump job's first step (harmless,
  matches the existing key-drift job's own convention), README not
  documenting the new guard (deliberate — README is itself a shipped file,
  documenting the guard there would demand its own version bump; noted in
  `CLAUDE.md` instead, which is the right call already).

## Fixes applied (second pass)

- Compute `MERGE_BASE=$(git merge-base "$BASE_SHA" "$HEAD_SHA")` and diff/
  read manifest versions against that instead of `BASE_SHA` directly (B1).
  Added `-c core.quotePath=false` to the diff call (N3).
- Guard the patch-bump-suggestion arithmetic behind an all-integer check on
  `major`/`minor`/`patch`; falls back to a non-numeric suggestion string
  rather than ever reaching unchecked arithmetic (B2).
- Added a second check: if `head_version` differs from the merge-base but
  `refs/tags/v<head_version>` already exists, still FAIL — with its own
  explanatory message (N1).
- Rewrote the "entries mirror" test case to parse `package.sh`'s
  `entries=(...)` line's actual contents (plus a separate check for the
  conditionally-bundled `LICENSE`) instead of a hardcoded restatement (N2).
- `cleanup()`'s trap body now ends `true` so an early/clean exit can't pick
  up a stray nonzero status from the cleanup check itself (N5).

## TDD claim, independently re-verified (both passes)

**First pass (by the reviewer):** mutation-tested the original script —
inverting the core `=`/`!=` comparison, neutering the guard with an early
`exit 0`, and deleting the `locales/*` pattern — all three produced the
correct test failures with accurate diagnostics, confirming the suite
exercises real logic rather than false-passing.

**Second pass (this fix, self-verified before commit):**
- Added case 9 (multi-lane base-advance) and confirmed it reproduces B1's
  exact false-negative against the pre-fix script logic (verified by
  reasoning through the git history the fixture builds — a genuinely
  diverged base/head pair sharing one shipped-file-changing ancestor),
  then confirmed it passes against the fixed script.
- Added case 10 (pre-release suffix) and case 11 (already-tagged version);
  both fail correctly against the fixed script.
- Re-ran the "entries mirror" fix against a live mutation: appended
  `CHANGELOG.md` to a **copy** of `package.sh`'s `entries=(...)` line (real
  `package.sh` restored immediately after) — the test now correctly fails
  and names the exact missing entry; reverting the copy back to the real
  file returns the suite to green.

## Verified beyond automated tests

- `bash -n` on both scripts: clean.
- `scripts/check-version-bump.test.sh`: 11/11 cases pass (was 8/8 before
  the fix pass; 3 new regression cases added for B1/B2/N1).
- `scripts/validate.sh`, `scripts/package.sh`, `scripts/check-key-drift.test.sh`:
  all still green, unaffected by this change.
- The real guard, run against this branch's own diff vs. `origin/main`:
  correctly reports no shipped file changed (only `scripts/`, `.gitignore`,
  `CLAUDE.md`, and this record were touched) — exit 0.
- `.github/workflows/ci.yml` YAML parses; `version-bump` job gated to
  `pull_request` only (push/schedule/workflow_dispatch skip it, since none
  of them carry a meaningful base/head pair to diff).
- No real client/shop name, no secret-shaped literal in the diff.

## Verdict

Safe to merge. Both blockers (B1, B2) are fixed and covered by new
regression tests; N1/N2/N3/N5 fixed as cheap, directly-related follow-ups
in the same pass; N4 and the two nits are deferred as genuinely low-severity
and out of scope. Rollout to the other `ut-plugin-*` repos tracked
separately as ut-docs#1948.
