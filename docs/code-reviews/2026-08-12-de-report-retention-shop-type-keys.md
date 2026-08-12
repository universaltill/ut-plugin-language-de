# Code review — report-retention + shop-type/demo-seed key parity (ut-docs#579)

**Date:** 2026-08-12
**Card:** universaltill/ut-docs#579 (p1, `complexity:easy`)
**Branch:** `pipeline/579-de-es-i18n-key-parity`
**Dev:** inline (Sonnet, easy-tier build model)
**Reviewer:** independent subagent, fresh-context Sonnet (easy-tier review — a
clean-context instance that never saw the dev reasoning, per the pipeline's
model-routing rule)

## What shipped

`ut-docs#571` (report retention) and `ut-docs#539` (demo catalogue opt-in)
landed on `universal-till` `main` within minutes of each other and together
introduced 37 new core keys this pack had never picked up — confirmed by the
real post-merge `check-lang-pack-drift.sh` run
(`universal-till@dcb1ef4a`, [workflow run 31591156570](https://github.com/universaltill/universal-till/actions/runs/31591156570)).

- `locales/de.json`: all 37 keys translated with real German (formal
  **Sie**-register, matching the pack's existing style) — restores **exact
  parity** (1290/1290 core keys, 0-entry baseline unchanged).
- `i18n-baseline/de.same-as-en.txt`: gained one entry,
  `settings.retention.export_format_label` — "Format" is a legitimate German
  cognate, not a missed translation; regenerated with
  `scripts/check-key-drift.sh --update-allowlist` and reviewed.
- `manifest.json`: `1.1.4` → `1.1.5` (patch — coverage stays at full parity,
  content-only update).

Companion fix in the sibling `ut-plugin-language-es` repo (same card,
separate PR/review — see that repo's own `docs/code-reviews/`) closes the
Spanish half of the same gap.

## Independent review (fresh-context Sonnet) — 0 blockers, 2 nits, both fixed

Full gate actually re-run (not just diff read), confirmed green:
`scripts/validate.sh`, `scripts/check-key-drift.test.sh` (21/21),
`check-key-drift.sh` against a local core checkout (**1290/1290 translated,
0 drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
mismatches**). Diff hygiene confirmed: only `locales/de.json`,
`i18n-baseline/de.same-as-en.txt`, and `manifest.json` touched; no existing
translation altered; no duplicate JSON keys; every new value is a plain
non-empty string (checked against core's `syncLocales` whole-file-drop
failure mode); no secret-shaped or client-name values. `%d` placeholder
count verified exactly 1, correctly positioned, in each of
`settings.data.demo_kept` / `demo_present` / `demo_removed`.

Terminology cross-checked against the pack's own existing keys for all 37
new strings — Kasse/Berichte/Sie-register all consistent;
`setup.shop_type.choose` = "Geschäftsart wählen …" was flagged by the
reviewer as a good match to the existing `setup.country.choose` = "Land
wählen …" pattern.

**Nit, fixed — `setup.shop_type.title` used an impersonal construction**
("Um welche Art von Geschäft handelt es sich?") where neighboring
setup-title keys (`setup.store.title` = "Wie heißt Ihr Geschäft?",
`setup.country.title` = "Wo ist Ihr Geschäft?") use direct `Sie`/`Ihr
Geschäft` address. Changed to "Welche Art von Geschäft betreiben Sie?" to
match the established pattern. Re-verified: gate re-run clean after the
edit.

**Cross-repo nit noted, not this repo's fix** — the reviewer also flagged
that the ES pack's new `setup.demo_data.hint` referenced a Spanish
"Ajustes → Datos" breadcrumb for two nav labels (`nav.settings`,
`settings.data.title`) that aren't translated in that pack yet. Addressed
in the ES repo's own commit/review record, not here.

## Verification beyond the automated suite

- Confirmed all 37 keys' English source text directly against
  `universal-till/web/locales/en.json` (this session's own local checkout)
  before translating, rather than working from the ticket body alone.
- Reviewer independently re-ran the full gate and hand-verified
  terminology/register consistency against the pack's own existing corpus.
- No driven-browser check for this pass (content-only key-parity patch, not
  a UI/behaviour change) — the automated key-drift/token-parity/empty-value
  guard is the meaningful regression proof at this scale; every new string
  was checked by eye for plausible length against its English source
  (longest strings are help/hint text, not fixed-width control labels).

## Safe-to-merge verdict

Yes.
