# Code review — close lang-pack drift (journal cross-till keys)

**Date:** 2026-08-16
**Trigger:** `universal-till` PR #375 (`ut-docs#550`, cross-till end-of-day
order list) merged to `main` and added 7 new `journal.*` keys to
`web/locales/en.json`. The `lang-pack-drift` workflow is blocking on push
to `main` per this ecosystem's standing rule (`universal-till/CLAUDE.md`),
and went red on the merge commit (`952b321`) because neither language pack
had the new keys yet — expected, not a regression in #375 itself.
**Branch:** `fix/770-journal-crosstill-keys`
**Dev:** inline (Scrum Master pipeline cycle, same session that swept the
stale PR and merged #375 — a same-session "don't leave main red" fix, not a
separately-picked backlog card)
**Reviewer:** self-reviewed inline — proportionate to scope (7 keys, no
logic, precedented fix shape identical to several prior
`close-lang-pack-drift-*` records in this same directory)

## What shipped

- `locales/de.json`: added the 7 missing keys, restoring **exact parity**
  (1464/1464 core keys, 0-entry baseline unchanged).
  - `journal.col.till` / `journal.filter.till` → `Kasse`
  - `journal.filter.all_tills` → `Alle Kassen`
  - `journal.filter.day` → `Tag`
  - `journal.replica_no_cross_till` → `Kassenübergreifende Verkäufe sind
    nur auf der Hauptkasse dieses Geschäfts verfügbar.`
  - `journal.till_last_synced` → `Letzter Kontakt von %s: %s`
  - `journal.till_unknown` → `Unbekannte Kasse`
- `manifest.json`: `1.1.8` → `1.1.9` (patch — stays at full parity, not a
  new coverage milestone).

Companion fix in the sibling `ut-plugin-language-es` repo (same trigger,
separate PR/review — see that repo's own `docs/code-reviews/`).

## Verification

- `scripts/validate.sh` — green (JSON valid, every value a non-empty
  string).
- `scripts/check-key-drift.sh` against `universal-till`'s real `main`
  `web/locales/en.json` (extracted via `git show origin/main:...` after
  the #375 merge, not a stale local checkout) — **1464/1464 translated, 0
  drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
  mismatches**.
- `scripts/check-key-drift.test.sh` — 22/22 passed, unaffected by this
  change (fixture-driven, not touching real locale files).
- Terminology cross-checked against the pack's own existing corpus before
  writing the translations, not after: `grep`'d `"Kasse` /
  `"nav.till"` / `shifts.register` etc. across `de.json` and confirmed
  `Kasse`/`Kassen` is the pack's consistent term for "till" (e.g.
  `nav.till: "Kasse"`, `settings.tills.open: "Kassen verwalten..."`) —
  used the same term rather than introducing a synonym. `%s`/`%d` token
  count and order in `journal.till_last_synced` matches core's
  `"Last contact from %s: %s"` exactly (2× `%s`, same order) — confirmed
  by the guard's own token-parity check (0 mismatches) in addition to
  visual inspection.
- No UI/driven-browser check performed for this pass — accepted gap at
  this scale (a 7-key content-only patch), consistent with this
  directory's own precedent (see `2026-08-08-close-lang-pack-drift-374.md`)
  for why the automated key-drift/token-parity/empty-value gate is the
  meaningful regression proof for a change of this shape. Every new
  string checked by eye for plausible length against its English source;
  none flagged as overflow risk (short filter labels/column headers, one
  sentence-length banner string not in a fixed-width control).

## Safe-to-merge verdict

Yes.
