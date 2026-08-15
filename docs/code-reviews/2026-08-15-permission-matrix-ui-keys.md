# Code review — permission-matrix UI key parity (ut-docs#556)

**Date:** 2026-08-15
**Card:** universaltill/ut-docs#556 (p2, `complexity:medium`) — stale-PR/CI sweep
follow-up, not the card's own build
**Branch:** `pipeline/556-permission-matrix-ui-lang-pack-keys`
**Dev:** inline (Sonnet, autonomous SDLC pipeline, Scrum Master role doing its
own step-0c CI-red cleanup)
**Reviewer:** independent subagent, fresh-context Sonnet (mechanical i18n
key-sync fix — easy-tier review, a clean-context instance that never saw the
dev reasoning)

## What shipped

`universal-till` PR #365 (`ut-docs#556`, merged `296b0fa`) added a
`super_admin` permission-matrix UI and introduced 23 new core keys —
22 `permissions.*` plus `users.role.super_admin` — in `web/locales/en.json`.
The PR's own CI (`lang-pack-drift` on `pull_request`) is deliberately
advisory-only and passed; the **push-triggered run on `main` is blocking**
and failed immediately after merge (workflow run 31878264832), because
neither language pack had the new keys yet.

- `locales/de.json`: all 23 keys translated with real German (formal
  **Sie**-register, terminology cross-checked against the pack's own
  existing corpus — audit/refund/void/report/plugin/user/cash/TSE/sync
  vocabulary) — restores **exact parity** (1444/1444 core keys, 0-entry
  baseline unchanged).
- `manifest.json`: `1.1.6` → `1.1.7` (patch — translation-only).

## Independent review (fresh-context Sonnet) — 0 blockers, 4 nits, 1 fixed

Full gate actually re-run (not just diff read): `scripts/validate.sh`,
`scripts/check-key-drift.test.sh`, and `check-key-drift.sh` against a local
core checkout of the just-merged `en.json` — **1444/1444 translated, 0
drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
mismatches**. Diff hygiene confirmed: only `locales/de.json` and
`manifest.json` touched, no existing translation altered, no duplicate JSON
keys, valid JSON, no secret-shaped or client-name values. Confirmed none of
the 23 English source strings carry `%s`/`%d`/`{{...}}`/`{N}` tokens, and
none of the German translations invented one.

**Fixed — `permissions.action.cash_adjustment` used an inconsistent term.**
"Bargeldanpassungen" introduced a new word for a concept this pack already
names consistently elsewhere: `shifts.adjustment` = "Bargeld-Korrektur /
Entnahme", `shifts.adjust` = "Korrektur (±)", `shifts.formula` references
"Korrekturen". Changed to **"Bargeldkorrekturen"** to match the established
`shifts.*` vocabulary a manager would see one screen away.

**Nits noted, not fixed (non-blocking, translator judgment calls):**
- `permissions.intro` renders English "grant or revoke" as the softer
  "festlegen" (determine) rather than mirroring `plugins.permission.
  granted/revoked` ("erteilt"/"entzogen") — reads fluently, not wrong.
- `permissions.action.sync_management` = "Mehrkassen-Synchronisierung" vs.
  the pack's existing `help.feat.multitill.title` = "Mehrere Kassen (ein
  Geschäft)" — stylistic mismatch (compound vs. adjective phrase), both
  idiomatic.
- `permissions.action.price_override` = "Preisänderungen" loses some
  "override" nuance, but this matches the pack's existing non-literal
  handling of "override" elsewhere (`inventory.override_title` → "Freigabe",
  `fiscal.banner.override_active` → "Ausnahme") — acceptable as-is.

## Verification beyond the automated suite

- Pulled all 23 keys' exact English source text directly from
  `universal-till`'s `origin/main` `web/locales/en.json` (not from the
  ticket/PR body) before translating.
- Reviewer independently re-derived the English source itself and
  hand-verified terminology/register consistency against the pack's own
  existing corpus rather than trusting the dev's summary.
- No driven-browser check (content-only key-parity patch, not a UI/behaviour
  change) — the automated key-drift/token-parity/empty-value guard is the
  meaningful regression proof at this scale.

## Safe-to-merge verdict

Yes.
