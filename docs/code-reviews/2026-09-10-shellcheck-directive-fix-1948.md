# Code review: fix malformed shellcheck directive in `check-version-bump.sh` (ut-docs#1948)

**Date:** 2026-09-10
**Branch:** `fix/1948-shellcheck-directive-parse-error`
**Implementer:** Sonnet (inline, cloud lane `lane:cloud-54`)
**Reviewer:** Opus (fresh-context subagent, independent of the implementation)

## What changed

`scripts/check-version-bump.sh:77-79` carried:

```sh
# shellcheck disable=SC2053 -- intentional unquoted glob match
if [[ "$f" == $pat ]]; then
```

Trailing prose on the same line as a `shellcheck disable=` directive breaks
shellcheck's own parser (`SC1072`/`SC1073` — "Expected '=' after directive
key" / "Couldn't parse this shellcheck directive") instead of successfully
suppressing `SC2053` — the exact failure shape `universal-till/CLAUDE.md`
documents ("a shellcheck directive comment must carry only `key=value`
pairs — trailing prose on the same line fails to parse, SC1072/SC1073").

Fixed to:

```sh
# Intentional unquoted glob match ($pat is a pattern, not a literal).
# shellcheck disable=SC2053
if [[ "$f" == $pat ]]; then
```

This script was copied into this repo as part of the ut-docs#1948
version-bump-guard rollout, inheriting the bug from its origin. The same
bug was found and fixed independently in three sibling repos in the same
rollout (`ut-plugin-theme-midnight`, `ut-plugin-theme-screen-top`,
`ut-plugin-theme-buttons-left` — "F1" in each of their reviews) but was
never ported back to the two repos (`ut-plugin-language-de`/`-es`) it
originated from. This PR is that port.

## Why this matters beyond style

Confirmed by the reviewer: in the broken form, shellcheck's parse **aborts
entirely** at the malformed directive — the rest of the file (160+ lines)
was never analysed at all, not just the one suppressed line. This script
was getting effectively zero shellcheck coverage before this fix.

## Verified beyond automated tests

- `shellcheck scripts/check-version-bump.sh`: reproduces `SC1072`/`SC1073`
  on `main`'s current form; clean (exit 0, no output) after the fix.
- Confirmed the directive is load-bearing, not decorative: removing just
  the `# shellcheck disable=SC2053` line (keeping the explanatory comment)
  makes shellcheck correctly re-surface `SC2053` at the `if` line — so the
  fixed directive is attached to the right statement and genuinely
  suppresses a real finding.
- `bash scripts/check-version-bump.test.sh`: 11/11 cases pass, unchanged.
- `bash scripts/validate.sh`: clean (`v1.1.44`).
- `bash scripts/check-key-drift.sh`: reports a pre-existing, **unrelated**
  drift (`settings.shop_type.service_layout_note`, filed as ut-docs#2005)
  — confirmed present identically on `main` with or without this diff, so
  not caused by or in scope of this change.
- `BASE_SHA=$(git rev-parse main) bash scripts/check-version-bump.sh`
  itself: confirms no shipped file is touched by this diff (`scripts/*` is
  not in `SHIPPED_PATTERNS`), so no `manifest.json` version bump is
  required for this PR.
- Commit author/committer: `Farshid Mirza
  <4035824+farshidmirza@users.noreply.github.com>` — re-verified against
  `.github/workflows/commit-attribution.yml`'s own `BANNED_RE` logic
  locally; passes.

## Independent review findings

None blocking. Two informational notes, both pre-existing and unrelated to
this diff:

- Neither this repo nor `-es` runs `shellcheck` in CI — this fix restores
  real static-analysis coverage for local runs but has no CI-visible
  effect here (unlike `universal-till`, which gates on it).
- `.github/workflows/ci.yml`'s `if: always()` placement (on the self-test
  step rather than the drift step) is asymmetric with `-es`'s equivalent
  and could mask a self-test failure — cosmetic, out of scope for this PR.

**Verdict: SAFE TO MERGE.**
