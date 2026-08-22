# Code review — close lang-pack drift (tables.node.aria key)

**Date:** 2026-08-22
**Card:** universaltill/ut-docs#891 (p3, `complexity:easy`)
**Trigger:** `universal-till`'s `lang-pack-drift` check is red on `main` —
the tables floor-plan keyboard-reposition work (`universal-till` PR #435,
on top of #814/#820) added `tables.node.aria` to `web/locales/en.json`
and neither language pack had it yet (pre-existing gap, not caused by any
change in this cycle).
**Branch:** `fix/891-tables-node-aria-key`
**Dev:** inline (Sonnet, autonomous SDLC pipeline)
**Reviewer:** independent subagent, fresh-context Sonnet (easy-tier —
mechanical i18n key-sync fix, a clean-context instance that never saw the
dev reasoning)

## What shipped

Added the single missing key, translated, to `locales/de.json`, restoring
**exact parity** (1585/1585 core keys, 0-entry untranslated baseline
unchanged):

- `tables.node.aria` → "%s — mit den Pfeiltasten bewegen (Umschalttaste
  für größere Schritte gedrückt halten)"

Placed in the same position as core's `en.json` (right after
`tables.edit.hint`, before `tables.status.open_minutes`). No manifest
version bump — nothing in `ci.yml`/`validate.sh` gates a locale-only patch
on one, consistent with this directory's own recent precedent.

Companion fix in the sibling `ut-plugin-language-es` repo (same trigger,
separate PR/review — see that repo's own `docs/code-reviews/`).

## Verification

- `scripts/validate.sh` — green: JSON valid, every value a non-empty
  string, `ok com.universaltill.language-de v1.1.10 (de)`.
- `scripts/check-key-drift.sh` against `universal-till`'s real `main`
  `web/locales/en.json` — **1585/1585 translated, 0 known-untranslated,
  55 known-same-as-English, 0 drift, 0 orphans, 0 empty values,
  0 untranslated-present, 0 token mismatches**.
- `%s` placeholder preserved verbatim, count/order matches source (single
  token, confirmed both mechanically by the drift script and by direct
  inspection).
- `i18n-baseline/de.untranslated.txt` / `de.same-as-en.txt` — confirmed
  `tables.node.aria` was in neither file before this change, so no
  baseline pruning was required (this pack sits at exact key parity
  already).
- Terminology/style cross-checked against the pack's existing corpus:
  terse, subject-less imperative phrasing matches the sibling
  `tables.plan_aria` key's style; no other `tables.*` key needed touching.
- No UI/driven-browser check performed for this pass — accepted gap at
  this scale (single-key content-only patch), consistent with this
  directory's own precedent (see `2026-08-20-close-lang-pack-drift-862-user-elevation-keys.md`).

## Independent review (fresh-context Sonnet) — 0 blockers, 0 nits

Re-ran `validate.sh` and `check-key-drift.sh` independently rather than
trusting the dev report; confirmed the German grammar, placeholder
preservation, and encoding (no mojibake) by direct byte-level inspection;
confirmed the diff touches only `locales/de.json`, no secrets, no client
names, no stray files.

## Safe-to-merge verdict

Yes.
