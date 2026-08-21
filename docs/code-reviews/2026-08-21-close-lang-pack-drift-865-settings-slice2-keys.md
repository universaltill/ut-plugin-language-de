# Code review — close lang-pack drift (settings slice 2 elevation keys)

**Date:** 2026-08-21
**Card:** universaltill/ut-docs#865 (complexity:medium, `universal-till`'s
own card; this pack-side fix is the same-day follow-up the `lang-pack-drift`
push-blocking check on `main` forced)
**Trigger:** `universal-till`'s `lang-pack-drift` check went red on `main`
immediately after PR universaltill/universal-till#415 merged — that PR added
12 new `elevation.summary.*` keys to `web/locales/en.json` (wiring the
remaining 10 settings-page mutations onto the manager-override-elevation
mechanism) and neither language pack had them yet.
**Branch:** `chore/865-elevation-summary-keys`
**Dev:** inline (Sonnet, autonomous SDLC pipeline)
**Reviewer:** independent subagent, fresh-context Sonnet (easy-tier —
mechanical i18n key-sync fix, a clean-context instance that never saw the
dev reasoning)

## What shipped

Added the 12 missing keys, translated, to `locales/de.json`, restoring
**exact parity** (1562/1562 core keys, 0-entry baseline unchanged — same
full-coverage posture this pack has held since ut-docs#297):

- `elevation.summary.idle_lock` → "Die Zeit für die automatische Sperre bei
  Inaktivität auf %s setzen."
- `elevation.summary.kiosk_idle_reset` → "Das Zeitfenster für den
  Kiosk-Leerlauf-Reset auf %s setzen." (post-review wording, see below)
- `elevation.summary.window_mode` → "Den Fenstermodus auf %s setzen."
- `elevation.summary.launch_on_startup_on` → "Den Start beim Hochfahren
  aktivieren."
- `elevation.summary.launch_on_startup_off` → "Den Start beim Hochfahren
  deaktivieren."
- `elevation.summary.telemetry_on` → "Die Freigabe von
  Plugin-Telemetriedaten aktivieren."
- `elevation.summary.telemetry_off` → "Die Freigabe von
  Plugin-Telemetriedaten deaktivieren."
- `elevation.summary.display_mode` → "Das Geräteprofil dieser Kasse auf %s
  setzen."
- `elevation.summary.dismiss_restore_prompt` → "Den Hinweis zur
  Wiederherstellung von einer anderen Kasse verwerfen, ohne etwas zu
  importieren."
- `elevation.summary.dismiss_pending_base_plugin` → "Das ausstehende
  Basis-Plugin %s verwerfen, ohne es zu installieren."
- `elevation.summary.enrol_claim_code` → "Einen neuen Anspruchscode für das
  Geschäft und einen QR-Link erstellen." (post-review wording, see below)
- `elevation.summary.enrol_now` → "Jetzt versuchen, diese Kasse beim
  Marketplace zu registrieren." (post-review wording, see below)

`manifest.json`: `1.1.10` → `1.1.11` (patch).

Companion fix in the sibling `ut-plugin-language-es` repo (same trigger,
separate PR/review — that pack is partial-coverage, so its fix adds the
same 12 keys to its untranslated baseline instead of translating them; see
that repo's own `docs/code-reviews/`), same split ut-docs#862's own
closure used for the slice-1 keys.

## Independent review (fresh-context Sonnet) — 3 should-fix, 0 blockers

The reviewer independently re-ran every verification command (all green —
see below) and cross-checked the 3 first-draft translations that used
placeholder token counts/positions and imperative infinitive-final style
correctly but had NOT been cross-checked against this file's own existing
terminology for the same concepts:

1. `enrol_claim_code` used "Shop" — every other occurrence of "store" in
   this file is "Geschäft" (`settings.enrol.claim_btn`,
   `settings.enrol.store`, `help.feat.claim.s2`, and 5 more). **Fixed:**
   "für den Shop" → "für das Geschäft".
2. `enrol_now` used "Marktplatz" (translated) — every other of the 13
   marketplace mentions in this file keeps the English loanword
   "Marketplace" verbatim (`settings.enrol.registered`:
   "...beim Universal-Till-Marketplace registriert.", `status.
   register_till`, `plugins.install.error.*`, etc.) — the product's own
   established term, not translated anywhere else in this pack. **Fixed:**
   "im Marktplatz" → "beim Marketplace", matching
   `settings.enrol.registered`'s exact preposition/case pattern.
3. `kiosk_idle_reset` invented a third phrasing
   ("Selbstbedienungs-Kiosk") for a concept this file already names twice:
   `settings.kiosk_idle_reset.title` = "Kiosk-Leerlauf-Reset",
   `settings.kiosk_idle_reset.help` / `settings.display.mode_self_order`
   use "Selbstbestell-Kasse"/"Selbstbestell-Kiosk" for the device itself.
   **Fixed:** reworded to reuse the existing heading term directly —
   "Das Zeitfenster für die Inaktivitäts-Rücksetzung des
   Selbstbedienungs-Kiosk auf %s setzen." → "Das Zeitfenster für den
   Kiosk-Leerlauf-Reset auf %s setzen."

All three were genuinely real (terminology drift within one file, exactly
the class of thing a same-corpus cross-check catches and a first pass
without it misses) and small enough to fix inline rather than earning a
second review round — re-verified with the full local gate below after the
fix, not just re-asserted.

Everything else the reviewer checked came back clean: all 12 values
genuinely German (not copy-pasted English) with `%s` counts/positions
matching the English source exactly (corroborated by the drift script's
own "0 token mismatches"); "aktivieren"/"deaktivieren" reused verbatim from
`elevation.summary.user_activate`/`user_deactivate`; "Kasse", "Fenstermodus"
(`settings.display.window_mode_label`), "Geräteprofil"
(`settings.display.mode`), and "Basis-Plugin" (`setup.base_plugins.*`) all
correctly reused; sentence style consistent with every neighboring
`elevation.summary.*` entry; the pack's `elevation.summary.*` key set is a
byte-for-byte match against core's en.json; no secrets, no client names, no
stray files.

## Verification (re-run after the fix)

- `scripts/validate.sh` — green, `v1.1.11 (de)`.
- `scripts/check-key-drift.sh` against `universal-till`'s real `main`
  `web/locales/en.json` (local checkout at `a7d6536` / PR #415's merge
  commit) — **1562/1562 translated, 0 drift, 0 orphans, 0 empty values, 0
  untranslated-present, 0 token mismatches, 54 same-as-English (unchanged
  allowlist)**.
- `scripts/check-key-drift.test.sh` — all 21 fixture cases passed,
  unaffected by this change.
- `scripts/package.sh` — dry-run packages cleanly; `dist/` output removed
  before commit (gitignored, not part of the diff).
- No UI/driven-browser check performed for this pass — accepted gap at this
  scale (a 12-key content-only patch), same precedent as ut-docs#862's own
  closure (`2026-08-20-close-lang-pack-drift-862-user-elevation-keys.md`)
  and `2026-08-16-close-lang-pack-drift-journal-crosstill.md`.

## Safe-to-merge verdict

Yes, with the 3 should-fix terminology items addressed on this branch.
