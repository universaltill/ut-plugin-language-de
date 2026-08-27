# Code review: translate 4 new setup.tax_plugin.* keys

- **Card:** universaltill/ut-docs#1180 (closed by universal-till PR #586;
  this is the implied lang-pack follow-up, per the "own it explicitly"
  rule in the `scrum-master` skill — no separate board card)
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** independent fresh-context general-purpose subagent (same
  session model tier — complexity:easy per the pipeline's model-routing
  rubric)

## What shipped

Core (`universal-till`'s `web/locales/en.json`) gained 4 new keys under
`setup.tax_plugin.*` (PR #586, "prompt to install the country tax plugin
(ADR-0025 D4)", closing ut-docs#1180), which this pack — maintained at
exact key parity, 0-entry baseline — never translated. This was failing
`lang-pack-drift`'s push-to-main check on `universal-till` (confirmed:
`universal-till`'s `main` had a red `lang-pack-drift` run at 23:46:38Z for
exactly this gap, head `5bc98c5`). Added real German translations for all
4 keys, restoring exact parity.

## Review findings

None (no must-fix). Confirmed independently by a fresh-context reviewer,
not just re-reading the diff:

- Diffed core's actual `web/locales/en.json` for the 4 new keys and
  confirmed the 4 keys added here are exactly the 4 new core keys — no
  more, no fewer, no typo'd key names (`setup.tax_plugin.description`,
  `.install_btn`, `.install_pending`, `.title`).
- `de.json` is valid JSON, alphabetical insertion correct (between
  `setup.store.title` and `setup.till_name.default`), no duplicate keys.
- `scripts/validate.sh` and `scripts/check-key-drift.sh` (run against a
  local `universal-till` checkout at `main`'s post-merge head `5bc98c5`,
  via `UT_CORE_EN_JSON`) both pass: 1743/1743 core keys translated, 0
  drift, 0 orphans, 0 empty values, 0 token mismatches.
- Translation quality checked term-by-term against the pack's own
  existing vocabulary, not just checked for plausibility: `TSE` left
  untranslated (matches this pack's own established convention —
  `fiscal.chip_ok`, `fiscalregister.col.tse_*`, `setup.tse.*` all keep
  `TSE` as-is, a domain term with no German expansion in this pack);
  `§12 UStG` kept verbatim (a legal citation, same treatment as
  `fiscalregister.intro`'s `§146a Abs. 4 AO`); "Install" →
  `"Installieren"` matches `plugins.install`/`plugins.store.action.install`
  exactly, not an invented synonym; the `install_pending` phrasing
  ("wird … im Hintergrund installiert … Sie können fortfahren") mirrors
  this pack's own `setup.base_plugins.pending` construction
  ("wird im Hintergrund installiert").
- No format tokens (`%s`/`%d`/…) in any of the 4 strings — nothing to
  drop/reorder, confirmed by the drift script's own token-mismatch check
  (0).
- Wording checked against core's own compliance-claims constraint
  (ADR-0040, `universal-till` CLAUDE.md): the English source describes a
  factual capability ("applies Germany's VAT rates", "signs each sale
  with your configured TSE") rather than a legal-outcome claim
  ("GoBD-compliant" etc.); the German translation preserves that
  distinction — no `revisionssicher`/`GoBD-konform`/certification wording
  introduced.
- Git identity on the commit: `Farshid Mirza
  <4035824+farshidmirza@users.noreply.github.com>`, a real GitHub-linked
  human identity, not an AI-tool default.
- No real client/shop names, no secret-shaped literals.

## Verdict

**Safe to merge.** `manifest.json`'s version is not bumped in this
commit — this pack's own established convention (see the #1133 review
record) bumps/tags at publish time, not in the content commit; noted here
so the next release-tag pass remembers one is owed.
