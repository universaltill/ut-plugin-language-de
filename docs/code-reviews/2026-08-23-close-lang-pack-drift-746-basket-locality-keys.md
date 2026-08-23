# Code review — close lang-pack drift (demo_in_basket basket-locality keys)

**Date:** 2026-08-23
**Card:** universaltill/ut-docs#746 (p3, `complexity:medium`)
**Trigger:** companion fix, same cycle as `universal-till`'s
`fix/live-basket-guard-746` — that PR splits core's single
`settings.data.demo_in_basket` key into `settings.data.demo_in_basket_cashier`
and `settings.data.demo_in_basket_kiosk`. Landed here in the same cycle
(not as a follow-up) specifically to avoid the push-to-main-blocking
`lang-pack-drift` workflow going red the moment core's PR merges.
**Branch:** `fix/746-demo-in-basket-locality-keys`
**Dev:** inline (Sonnet, autonomous SDLC pipeline)
**Reviewer:** independent subagent, fresh-context Sonnet (easy-tier —
mechanical i18n key-sync fix, same class as the `#891` precedent)

## What shipped

`locales/de.json`: replaced `settings.data.demo_in_basket` with two keys,
in the same position, translated:

- `settings.data.demo_in_basket_cashier` → "Beispieldaten befinden sich im
  aktuellen Warenkorb — leeren Sie zuerst den Warenkorb." (unchanged text
  from the retired key)
- `settings.data.demo_in_basket_kiosk` → "Beispieldaten befinden sich im
  Warenkorb des Selbstbedienungs-Kiosks — leeren Sie zuerst den
  Kiosk-Warenkorb." ("Selbstbedienungs-Kiosk" matches this pack's existing
  precedent term, `elevation.summary.kiosk_idle_reset`/`settings.display.mode_self_order`)

## Verification

- `scripts/validate.sh` — green: `ok com.universaltill.language-de v1.1.10 (de)`.
- `scripts/check-key-drift.sh` run against core's post-merge `en.json`
  (the `fix/live-basket-guard-746` working tree, which already has both
  new keys and neither old one) — **1614/1614 core keys translated, 0
  known-untranslated, 57 known-same-as-English, 0 drift, 0 orphans, 0
  empty values, 0 untranslated-present, 0 token mismatches**. Exact
  parity maintained.
- No placeholder tokens in either string — nothing to preserve/mismatch.
- `i18n-baseline/de.untranslated.txt`/`de.same-as-en.txt` — confirmed
  neither the old nor the new keys were ever listed in either file (the
  old key was already a real, non-baseline translation), so no baseline
  pruning was needed.

## Independent review (fresh-context Sonnet) — 0 blockers, 0 nits

Re-ran `validate.sh` and `check-key-drift.sh` independently; confirmed
German grammar and the "Selbstbedienungs-Kiosk" term against the pack's
own existing corpus rather than taking it on trust; confirmed no mojibake
by direct inspection; confirmed the diff touches only `locales/de.json`,
no secrets, no stray files, no client names.

## Safe-to-merge verdict

Yes.
