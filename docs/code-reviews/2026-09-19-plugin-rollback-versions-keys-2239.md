# Code review: translate 6 new plugin-rollback-versions keys

- **Card:** universaltill/ut-docs#2239 — wiring up plugin rollback version
  discovery on the core `universal-till` side
  (`universaltill/universal-till#1285`). These are brand-new core keys
  (no prior German translation to fall behind on), so per the standing
  convention core merges first and this pack PR closes the gap in the
  same cycle — `locale-render-audit` on the core PR fails until this
  lands (a new, untranslated key falls back to English, which that audit
  specifically flags: `[plugins] /plugins -> "Versions"`, confirmed live
  in that PR's failed check run).
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** self-reviewed inline (same session as the core change) —
  this is a small, mechanical, same-cycle language-pack follow-up rather
  than a separate board card, not a scope that warrants a second
  subagent review pass on top of the core card's own independent Opus
  review; verified live against the repo's own guards rather than just
  asserted.

## What shipped

Six new keys, all added to `locales/de.json` next to their existing
alphabetical neighbours, matching this file's existing formal **Sie**
register and the exact terminology already used elsewhere in the
`plugins.manage.*` block:

- `plugins.manage.action.rollback_to` → "Auf diese Version zurücksetzen"
- `plugins.manage.action.versions` → "Versionen"
- `plugins.manage.confirm_rollback` → "Zurücksetzen"
- `plugins.manage.currently_installed` → "Aktuell installiert"
- `plugins.manage.no_versions` → "Keine früheren Versionen verfügbar"
- `plugins.manage.versions_title` → "Verfügbare Versionen"

None is identical to its English source, so no
`i18n-baseline/de.same-as-en.txt` allowlist entry is needed.

`manifest.json`'s version bumped `1.1.98` → `1.1.99`, per this repo's own
`CLAUDE.md` ("any PR that touches a shipped file … must bump
`manifest.json`'s version in the same PR").

## Review findings

None (no must-fix).

Verified, live, not just read:

- `bash scripts/validate.sh` — exit 0: `ok com.universaltill.language-de
  v1.1.99 (de)`.
- `UT_CORE_EN_JSON=/home/user/universal-till/web/locales/en.json bash
  scripts/check-key-drift.sh` (pointed at the actual core branch carrying
  these 6 new keys, universal-till#1285's head) — exit 0: **2589/2589
  core keys translated, 0 known-untranslated, 82 known-same-as-English
  (allowlist), 0 drift, 0 orphans, 0 empty values, 0
  untranslated-present, 0 token mismatches.**
- All 6 key names diffed byte-exact against
  `universal-till/web/locales/en.json` on that branch — no typos, no
  extras, no duplicate JSON keys.
- No format/placeholder tokens (`%s`/`%d`/`{{…}}`/`{N}`) in any of the 6
  English source strings, and none invented on the German side.
- No real client/shop name, no secret-shaped literal.
- Git identity on the commit: `Farshid Mirza
  <farsid@taskrunnertech.co.uk>` — this repo was freshly cloned mid-cycle
  and the identity was set locally before the first commit, per the
  `scrum-master` skill's mid-cycle repo-attach rule.

## Verdict

**Safe to merge** — this is the fix for `universal-till#1285`'s
currently-red `locale-render-audit` check (a brand-new-key case, where
core merging first and the pack following in the same cycle is the
expected, correct order per this ecosystem's standing i18n rules, not a
mistake to avoid). `merge_method: "merge"`.
