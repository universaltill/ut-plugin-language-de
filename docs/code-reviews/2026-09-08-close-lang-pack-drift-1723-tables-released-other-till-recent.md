# Code review: translate tables.error.released_other_till_recent

- **Card:** universaltill/ut-docs#1723 — `universal-till` PR #908 (branch
  `fix/1723-free-table-cross-till-signal`) adds the new key
  `tables.error.released_other_till_recent` to core's
  `web/locales/en.json`, ahead of it landing on `main` (to avoid the
  `lang-pack-drift` push-to-`main` gate going red the moment it merges).
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** independent fresh-context Sonnet subagent (small,
  mechanical single-key translation follow-up — reviewed at Sonnet per
  the same-day #1697-designer-replica-key precedent in this same
  directory) — did not see the implementation reasoning, read the diff
  cold, ran the repo's own guards live.

## What shipped

`locales/de.json` gets one new key, inserted immediately after the
existing sibling `tables.error.release` and before
`tables.error.replica_use_primary` (alphabetical order this file already
follows in this region):

```
"tables.error.released_other_till_recent": "Tisch freigegeben, aber die Markierung gehörte zu einer anderen, kürzlich aktiven Kasse — bestätigen Sie dort, dass keine Bestellung mehr offen ist, bevor Sie den Tisch neu belegen."
```

Formal **Sie** register matches every sibling `tables.error.*` key; uses
"Kasse" for till and "Markierung" for the occupancy claim, both already
established in this file's own `tables.error.replica_use_primary` /
`tables.error.held_order_attached`.

Neither the value nor any prefix of it is byte-identical to core's
English string, so no `i18n-baseline/de.same-as-en.txt` allowlist entry
is needed.

## Review findings

None (no must-fix). The reviewer independently confirmed:
- JSON valid, key present exactly once, correctly placed.
- Translation register/terminology matches sibling keys and this file's
  own established usage; conveys the same meaning as the English source.
- Not present in either baseline file (no stale entry to prune).
- `manifest.json` version unchanged (`v1.1.28`) — release/tag is a
  separate, later action, per this directory's own established
  precedent.

## Verified, live, not just read

- `bash scripts/validate.sh` — `ok com.universaltill.language-de v1.1.28 (de)`, exit 0.
- `UT_CORE_EN_JSON=<local universal-till checkout, branch
  fix/1723-free-table-cross-till-signal> bash scripts/check-key-drift.sh`
  — exit 0: `2063/2063 core keys translated, 0 known-untranslated
  (baseline), 72 known-same-as-English (allowlist), 0 drift, 0 orphans,
  0 empty values, 0 untranslated-present, 0 token mismatches`. The new
  key is translated and accounted for.
- No real client/shop name, no secret-shaped literal.
- Git identity on the commit: `Farshid Mirza
  <4035824+farshidmirza@users.noreply.github.com>`.

## Verdict

**Safe to merge.** Small, mechanical, fully guard-verified. Should land
before (or together with) `universal-till` PR #908 merging to `main`, so
`lang-pack-drift` doesn't go red on push.
