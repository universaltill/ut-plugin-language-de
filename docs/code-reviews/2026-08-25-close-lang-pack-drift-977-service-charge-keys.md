# Code review: translate settings.service_charge.{invalid_rate,tr_forbidden}

- **Card:** universaltill/ut-docs#977
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** independent fresh-context general-purpose subagent (same
  session model tier — complexity:easy per the pipeline's model-routing
  rubric)

## What shipped

Core (`universal-till`'s `web/locales/en.json`) gained two keys —
`settings.service_charge.invalid_rate` and
`settings.service_charge.tr_forbidden` — that this pack never translated,
which was failing `lang-pack-drift`'s push-to-main check on `universal-till`
(confirmed pre-existing: identical failure on the commit before this
session's own unrelated PR #508 merged, so not caused by that PR). Added
real German translations for both, restoring exact key parity.

## Review findings

None. Confirmed independently:
- Both `de.json` and `es.json` (the companion fix, reviewed together) are
  valid JSON, no duplicate keys, correct alphabetical insertion point.
- Translation accuracy: formal "Sie"-register German matching neighboring
  strings; the Turkish law name (`Fiyat Etiketi Yönetmeliği`) and calendar
  date preserved correctly.
- `scripts/validate.sh` and `scripts/check-key-drift.sh` (run against a
  local `universal-till` checkout via `UT_CORE_EN_JSON`) both pass: 0
  drift, 0 orphans, 0 empty values, 1623/1623 core keys translated.
- Both target keys confirmed absent from `i18n-baseline/de.untranslated.txt`
  (never listed as accepted debt — no baseline pruning needed).
- Git identity on the commit: a real linked GitHub identity, not an
  AI-tool default.
- No real client/shop names, no secret-shaped literals.

## Verdict

**Safe to merge.**
