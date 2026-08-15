# Code review — `receipt.fiscal.unsigned_signing` key parity (ut-docs#675)

**Date:** 2026-08-15
**Card:** universaltill/ut-docs#675 (`complexity:hard`) — `lang-pack-drift`
blocked `main` after merge (`universal-till@1f8b955`, [workflow run
31873223163](https://github.com/universaltill/universal-till/actions/runs/31873223163))
because the new `receipt.fiscal.unsigned_signing` key (the `fiscal.sign.ask`
proceed-and-declare receipt outage notice) had no German translation yet.
**Dev/Reviewer:** same pipeline session that shipped #675 — a single-key,
mechanical follow-up fixing CI it just broke, not a separate cycle.

## What shipped

- `locales/de.json`: `receipt.fiscal.unsigned_signing` added, real German
  (formal **Sie**-register, matching the adjacent `receipt.fiscal.
  unsigned_override` line's tone) — restores exact parity, 1421/1421 core
  keys.
- `manifest.json`: `1.1.6` → `1.1.7` (patch — content-only).

## Verification (run directly, not assumed)

`scripts/validate.sh`: `ok`. `UT_CORE_EN_JSON=<local, just-merged en.json>
scripts/check-key-drift.sh`: `1421/1421 core keys translated, 0 known-
untranslated, 53 known-same-as-English, 0 drift, 0 orphans, 0 empty values,
0 untranslated-present, 0 token mismatches`. Diff scope confirmed minimal:
only `locales/de.json` and `manifest.json` touched.

## Verdict

Ready to merge and tag — this is what unblocks `main`'s `lang-pack-drift`
check on `universal-till`.
