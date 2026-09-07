# Code review: translate catalog.error.item_replica_use_primary

- **Card:** universaltill/ut-docs#1689 — `universal-till` PR #854 gates
  item/variant/barcode catalog mutations behind `requirePrimary` and adds
  the new key `catalog.error.item_replica_use_primary` to core's
  `web/locales/en.json`, ahead of it landing on `main` (to avoid the
  `lang-pack-drift` push-to-`main` gate going red the moment it merges).
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** independent fresh-context Sonnet subagent (small,
  mechanical single-key translation follow-up — reviewed at Sonnet per
  the 2026-09-05 Bluetooth-keys/#1585-replica-keys precedent in this same
  directory) — did not see the implementation reasoning, read the diff
  cold, ran the repo's own guards live.

## What shipped

`locales/de.json` gets one new key, inserted immediately after the
existing sibling `catalog.error.replica_use_primary`:

```
"catalog.error.item_replica_use_primary": "Diese Kasse folgt einer Hauptkasse — verwalten Sie den Katalog auf der Hauptkasse."
```

Matches the sibling key's exact register (formal **Sie**, identical lead
clause) and uses "Katalog" — the term already used consistently
elsewhere in this file (`nav.catalog`, `import.title`) and matching
core's own `nav.catalog` = "Catalog".

Neither the value nor any prefix of it is byte-identical to core's
English string, so no `i18n-baseline/de.same-as-en.txt` allowlist entry
is needed.

## Review findings

None (no must-fix) for this key. The reviewer independently confirmed:
- JSON valid, key present exactly once, correctly placed.
- Translation register/terminology matches sibling keys and this file's
  own established usage.
- Not present in either baseline file (no stale entry to prune).
- `manifest.json` version unchanged (`v1.1.28`) — release/tag is a
  separate, later action, per this directory's own established
  precedent (see the 2026-09-05 #1585-replica-keys record).

**Incidental finding, NOT caused by this commit (out of scope, new
Backlog card filed separately):** `locales/de.json` already carries two
pre-existing duplicate key pairs —
`kitchenstations.error.replica_use_primary` (lines 731/733) and
`tables.error.replica_use_primary` (lines 1745/1747) — confirmed by diff
inspection to predate this change (this commit is a single `+1` line).

## Verified, live, not just read

- `bash scripts/validate.sh` — `ok com.universaltill.language-de v1.1.28 (de)`, exit 0.
- `UT_CORE_EN_JSON=<local universal-till checkout> bash scripts/check-key-drift.sh`
  — exit 1, but the reported gap is exclusively the 3 pre-existing
  `sync.quarantine_reason.*` keys tracked separately as ut-docs#1695;
  the new key does **not** appear in the missing-keys output.
- No real client/shop name, no secret-shaped literal.
- Git identity on the commit: `Farshid Mirza
  <4035824+farshidmirza@users.noreply.github.com>`.

## Verdict

**Safe to merge.** Small, mechanical, fully guard-verified. Should land
before (or together with) `universal-till` PR #854 merging to `main`, so
`lang-pack-drift` doesn't go red on push.
