# Code review: record `settings.shop_type.service_layout_note` as known-untranslated (ut-docs#2005)

**Date:** 2026-09-10
**Branch:** `fix/2005-shop-type-service-layout-note-drift`
**Implementer:** Sonnet (inline, cloud lane `lane:cloud-54`)
**Reviewer:** Sonnet (fresh-context subagent, independent of the implementation — `complexity:easy` review tier)

## What changed

`scripts/check-key-drift.sh` started failing on `main` (first surfaced by
ut-docs#1948's shellcheck-fix PR, universaltill/ut-plugin-language-de#232's
own CI run): a recent `universal-till` core change added
`settings.shop_type.service_layout_note` (help text for the Service-trade
/ Salon-menu-layout setting) with no matching `ut-plugin-language-de`
follow-up — the "core merge implies a pack follow-up that exists on no
board" gap `ut-docs`'s own `scrum-master` SKILL.md names explicitly.

Fixed by recording the gap as known-untranslated debt:
`scripts/check-key-drift.sh --update-baseline --allow-growth`, which
appended exactly one line
(`settings.shop_type.service_layout_note`) to
`i18n-baseline/de.untranslated.txt`. `--allow-growth` was required because
the baseline had reached exact 0-entry parity as of the 2026-08 translation
pass (ut-docs#297) — this is the first regression from that state, tracked
honestly rather than silently.

**No translation was hand-typed.** This repo's translation pipeline uses a
self-hosted NAS model, unreachable from this cloud sandbox (same
constraint hit by universal-till#970/ut-docs#1775); a hand-invented
translation was previously flagged as a rule violation in a sibling PR's
review. `ut-plugin-language-es` was checked independently and does **not**
have this drift — `de`-specific.

## Verified beyond automated tests

- `bash scripts/check-key-drift.sh`: 0 drift, the new key correctly
  counted as the 1 known-untranslated entry
  (`2258/2259 core keys translated, 1 known-untranslated`).
- `bash scripts/check-key-drift.test.sh`: all cases pass, unchanged
  (`scripts/check-key-drift.sh` itself untouched — confirmed via
  `git diff main -- scripts/check-key-drift.sh`, empty).
- `bash scripts/check-version-bump.sh` (against `main`): "no shipped file
  changed" — cross-checked directly against `scripts/package.sh`'s own
  `entries=(manifest.json locales README.md)`, which does not include
  `i18n-baseline`, confirming this file is genuinely not shipped per this
  repo's own `CLAUDE.md`.
- `bash scripts/validate.sh`: clean (`v1.1.44`).
- Confirmed the key exists in `universal-till/web/locales/en.json` and is
  genuinely absent from `locales/de.json`.
- Confirmed the baseline category is correct: this is ordinary
  translatable help-text prose (not a brand term or deliberately-English
  string), so `de.untranslated.txt` (temporary gap) is right, not
  `de.same-as-en.txt` (deliberate allowlist).
- Commit author/committer: `Farshid Mirza
  <4035824+farshidmirza@users.noreply.github.com>`.

## Independent review findings

None blocking. **Verdict: SAFE TO MERGE.**
