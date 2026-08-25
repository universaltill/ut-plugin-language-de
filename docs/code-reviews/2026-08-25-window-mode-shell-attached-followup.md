# i18n follow-up: settings.display.window_mode_shell_attached (ut-docs#1086)

**Date:** 2026-08-25
**Card:** ut-docs#1086 (follow-up from ut-docs#1040)
**Complexity:** easy
**Author (dev):** scrum-master pipeline cycle, inline (Sonnet)
**Reviewer:** independent fresh-context Sonnet subagent

## What shipped

`web/locales/en.json`'s `settings.display.window_mode_shell_attached` key
was extended (universal-till#536) with a sentence explaining desktop-
overlay behavior on a Raspberry Pi with a desktop OS. Updated this pack's
German translation of the same key to carry the new sentence, matching
the file's existing "Vollbild"/"Kiosk" terminology and quote conventions.

## What the independent review found

PASS. Translation verified faithful to the English meaning, consistent
terminology, JSON valid, `scripts/validate.sh` and
`scripts/check-key-drift.sh` both clean (1703/1703 core keys translated,
0 drift/orphans/empty values). One minor German style note raised (a more
colloquial phrasing was possible) — not a defect, not changed.

## What was verified beyond automated tests

- `python3 -c "import json; json.load(open('locales/de.json'))"` — valid.
- `bash scripts/validate.sh` — `ok com.universaltill.language-de v1.1.17 (de)`.
- `bash scripts/check-key-drift.sh` — 0 drift, 0 orphans, 0 empty values,
  0 untranslated-present.
