# Code review — close lang-pack drift (user-management elevation keys)

**Date:** 2026-08-20
**Card:** universaltill/ut-docs#862 (p3, `complexity:easy`)
**Trigger:** `universal-till`'s `lang-pack-drift` check is red on `main` — a
recent user-management/elevation feature (`ut-docs#794`/`#795`) added 6 new
keys to `web/locales/en.json` and neither language pack had them yet
(pre-existing, not caused by any change in this cycle).
**Branch:** `fix/862-user-elevation-keys`
**Dev:** inline (Sonnet, autonomous SDLC pipeline)
**Reviewer:** independent subagent, fresh-context Sonnet (easy-tier —
mechanical i18n key-sync fix, a clean-context instance that never saw the
dev reasoning)

## What shipped

Added the 6 missing keys, translated, to `locales/de.json`, restoring
**exact parity** (1536/1536 core keys, 0-entry baseline unchanged):

- `elevation.summary.user_create` → "Benutzer %s mit der Rolle %s anlegen."
- `elevation.summary.user_pin_set` → "Eine neue PIN für %s festlegen."
- `elevation.summary.user_activate` → "%s aktivieren."
- `elevation.summary.user_deactivate` → "%s deaktivieren."
- `elevation.summary.user_role_change` → "Die Rolle von %s von %s auf %s
  ändern."
- `users.saved` → "Gespeichert."

`manifest.json`: `1.1.9` → `1.1.10` (patch).

Companion fix in the sibling `ut-plugin-language-es` repo (same trigger,
separate PR/review — that pack is partial-coverage, so its fix adds the
same 6 keys to its untranslated baseline instead of translating them; see
that repo's own `docs/code-reviews/`).

## Verification

- `scripts/validate.sh` — green (JSON valid, every value a non-empty
  string), `v1.1.10 (de)`.
- `scripts/check-key-drift.sh` against `universal-till`'s real `main`
  `web/locales/en.json` (local checkout at `4df0626`, matching
  `origin/main`) — **1536/1536 translated, 0 drift, 0 orphans, 0 empty
  values, 0 untranslated-present, 0 token mismatches**.
- `scripts/check-key-drift.test.sh` — all tests passed, unaffected by this
  change (fixture-driven).
- `scripts/package.sh` — dry-run packages cleanly; `dist/` output removed
  before commit (gitignored, not part of the diff).
- Placeholder token count/order checked against the English source for
  every key (also confirmed mechanically by the drift script's own
  token-parity check, 0 mismatches):
  - `user_create`: 2×`%s` (user, role), order preserved.
  - `user_pin_set` / `user_activate` / `user_deactivate`: 1×`%s`.
  - `user_role_change`: 3×`%s` (user, old role, new role), order preserved.
  - `users.saved`: 0 tokens.
- Terminology cross-checked against the pack's existing corpus: `anlegen`
  matches `users.new.submit: "Benutzer anlegen"`; `aktivieren`/
  `deaktivieren` match `users.activate`/`users.deactivate`; the
  imperative-object-first, infinitive-final sentence style matches every
  other `elevation.summary.*` entry (e.g. `archive_export`,
  `eod_settings_enabled`); `"Gespeichert."` (with trailing period) matches
  the source's punctuation and the existing `issuereport.saved` pattern.
- No UI/driven-browser check performed for this pass — accepted gap at this
  scale (a 6-key content-only patch), consistent with this directory's own
  precedent (see `2026-08-16-close-lang-pack-drift-journal-crosstill.md`)
  for why the automated key-drift/token-parity/empty-value gate is the
  meaningful regression proof for a change of this shape.

## Independent review (fresh-context Sonnet) — 0 blockers, 0 nits

Re-ran all four verification commands (both repos) independently rather
than trusting the dev report; confirmed the German grammar, placeholder
order/count, and terminology consistency by direct inspection; confirmed
the diff touches only `locales/de.json` + `manifest.json`, no secrets, no
client names, no stray files.

## Safe-to-merge verdict

Yes.
