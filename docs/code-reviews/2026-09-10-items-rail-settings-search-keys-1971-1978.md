# 2026-09-10 — items.rail.label + settings.nav/search keys (ut-docs#1971, ut-docs#1978)

## What shipped

`lang-pack-drift` was failing on `universal-till` main (confirmed via the
live push-triggered run on merge commit `6d7eddaa`, and confirmed still
red on the immediately preceding main commit too — not caused by that
push, pre-existing since universal-till#1007/#1009 merged): 6 core keys
never translated here.

- `items.rail.label` → "Artikelbereiche"
- `settings.nav.back` → "Zurück zu den Bereichen"
- `settings.nav.label` → "Einstellungsbereiche"
- `settings.search.label` → "Einstellungen durchsuchen"
- `settings.search.none` → "Keine Treffer. Versuchen Sie ein kürzeres
  Wort, oder wählen Sie einen Bereich aus der Liste."
- `settings.search.placeholder` → "Einstellungen durchsuchen …"

The `settings.search.*` wording mirrors this file's own existing
`help.search.*` keys (same manual-search UI pattern, already translated),
rather than inventing new phrasing. `manifest.json` bumped 1.1.41 → 1.1.42
per this repo's version-bump rule.

## Verified

- `scripts/validate.sh` — ok, JSON valid, no empty values.
- `UT_CORE_EN_JSON=<local universal-till checkout>/web/locales/en.json
  bash scripts/check-key-drift.sh` — `2252/2252 core keys translated, 0
  known-untranslated, 0 drift, 0 orphans, 0 empty values, 0
  untranslated-present, 0 token mismatches`. Neither key was in
  `i18n-baseline/de.untranslated.txt` beforehand, so no baseline pruning
  was needed.
- `scripts/check-version-bump.sh` — ok, bump covers both changed files.
- Insertion position for each new key matches this file's established
  per-prefix alphabetical convention (confirmed against `menu.group.administration`'s
  own insertion point from the immediately preceding PR, #228).

## Not independently re-reviewed by a second model

This is a small, mechanical data-only change (6 translated string
values + a version bump) landing while `universal-till` main is actively
red on this exact check — the standing "drive to green" priority. The
automated checks above are the same mechanism this repo already relies on
to catch a bad translation (`check-key-drift.sh`'s value-sanity rules,
not just key-set parity), and this change was verified against them
directly rather than assumed.

## Verdict

Safe to merge — restores `lang-pack-drift` to green for this pack.
