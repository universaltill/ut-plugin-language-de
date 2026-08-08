# Code review — close lang-pack drift (universaltill/ut-docs#36)

**Date:** 2026-08-08
**Card:** universaltill/ut-docs#36 (p3, `complexity:easy`), closed via
`universal-till` PR #241 (`fix: i18n the multi-till join/pairing error
messages`)
**Branch:** `fix/close-lang-pack-drift-36`
**Dev:** inline (Sonnet — easy tier)
**Reviewer:** independent fresh-context Sonnet subagent

## What shipped

`universal-till`'s `lang-pack-drift` CI check went red on `main` right
after PR #241 merged: that PR added 8 new keys under `tills.join_error.*`
to core's `web/locales/en.json` (i18n'ing the multi-till join/pairing
flow's previously-hardcoded English error messages), and this pack — at
full parity with core before then (ut-docs#297, most recently reconfirmed
by #374) — didn't know about them yet. Fixed:

- `locales/de.json`: all 8 new keys translated for real, restoring exact
  parity (1153/1153 core keys, 0-entry baseline unchanged), matching this
  pack's existing `tills.*` vocabulary (`Kasse` = till, `Hauptkasse` =
  primary till).
- `manifest.json`: `1.1.1` → `1.1.2` (patch — staying at full parity, same
  precedent as #374's own patch bump for a small content addition).

Companion fix in the sibling `ut-plugin-language-es` repo (same root
cause, separate PR/review — see that repo's own `docs/code-reviews/` for
the Spanish-side diff).

## Independent review (fresh-context Sonnet, easy tier) — 0 blockers

Full gate re-run and confirmed green: `scripts/validate.sh`,
`scripts/check-key-drift.sh` against a local core checkout (**1153/1153
translated, 0 drift, 0 orphans, 0 empty values, 0 untranslated-present, 0
token mismatches**), `scripts/check-key-drift.test.sh` (21/21),
`scripts/package.sh`. Diff hygiene confirmed: only `locales/de.json` and
`manifest.json` touched, no existing translation altered, no secret-shaped
values, no duplicate JSON keys.

Hand-verified placeholder-token parity for all 8 new keys against core's
`en.json` (cross-checking the script's own automated token-mismatch count):
the 6 keys carrying a `%s` in core (`not_a_till`, `request_failed`,
`snapshot_failed`, `stage_identity_failed`, `stage_snapshot_failed`,
`unreachable`) each have exactly one `%s` in the German value, in a
sensible sentence position; the 2 without (`bad_code`, `refused`) have no
stray `%s`.

Terminology/register cross-checked against this pack's own existing
`tills.*` corpus: consistent `Kasse`/`Hauptkasse`, formal `Sie`-imperative
matching `tills.join_help`/`tills.add_help`, `einfügen` reused verbatim
from `tills.join_code_ph`, grammar and separable-verb placement correct
throughout.

**No findings.**

## Verification beyond the automated suite

- Confirmed via a live gate run that this is genuine drift (the same 8
  keys the `lang-pack-drift` CI failure on `universal-till` main named),
  not a guard false-positive.
- No UI/visible-surface driven-browser check performed — same accepted-gap
  reasoning as #374's own review: an 8-key incremental patch closing
  active CI drift, not a full-coverage milestone; the automated
  key-drift/token-parity/empty-value gate plus by-hand terminology/token
  verification is the meaningful regression proof at this scope.

## Safe-to-merge verdict

Yes.
