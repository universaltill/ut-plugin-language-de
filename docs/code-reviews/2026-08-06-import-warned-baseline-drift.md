# 2026-08-06 — `import.warned` baseline drift

Card: [ut-docs#315](https://github.com/universaltill/ut-docs/issues/315)
Branch: `fix/315-import-warned-baseline-drift`

## What shipped

One line added to `i18n-baseline/de.untranslated.txt`: `import.warned`.

## Why

Core added `import.warned` ("Warnings") to `web/locales/en.json` on
2026-08-05 (`universal-till@b83d9d8`, ut-docs#293). This pack's
`scripts/check-key-drift.sh` — added by #292, exercised live for the
first time against this exact drift by the new core-side check from
#299 — correctly flagged it as new, un-baselined drift.

The card offered two options: translate it, or baseline it as accepted
debt. Chose **baseline**: every other `import.*` key (15 of them —
`import.created` through `import.with_issues`) is already accepted debt
in this pack; the whole catalog-import screen currently renders in
English for German tills, deliberately. Translating only `import.warned`
in isolation would produce one German label next to 15 English ones on
the same screen — worse UX than the consistent English fallback ADR-0010
already provides, not an improvement. Baselining the 16th sibling to
match the other 15 is the correct call here, not just the faster one.

## Verification

```
UT_CORE_EN_JSON=<core checkout>/web/locales/en.json scripts/check-key-drift.sh
```
- Before: `1 core key(s) missing from locales/de.json and NOT in the
  baseline (new drift): - import.warned` — reproduces the card exactly.
- After: `ok -- 170/1088 core keys translated, 918 known-untranslated
  (baseline), 12 known-same-as-English (allowlist), 0 drift, 0 orphans,
  0 empty values, 0 untranslated-present`.

`scripts/validate.sh` and `scripts/check-key-drift.test.sh` (14 self-tests)
both pass unchanged.

## Independent review (fresh-context Sonnet, easy card) — no blockers

Re-ran the full verification independently (including `git stash` /
re-check / `git stash pop` to confirm the pre-fix failure reproduces and
the fix restores cleanly), cross-checked the "15 siblings already
baselined" claim directly against core's `en.json`, confirmed the diff
is exactly one line in the correct sorted position with no other file
touched, and confirmed no regeneration side-effects beyond that line.
Agreed baseline-over-translate was the right call for the reason above.
No findings.

## Not done

`import.warned` and its 15 `import.*` siblings remain untranslated — the
whole catalog-import screen renders in English on German tills. Real,
tracked work, not new: [#297] (the remaining ~917-key gap generally) and
[#312] (a shared drift-guard implementation across all language packs)
already cover this; no new card needed.
