# Review — de: drop the dead `tile_sheet.delete_item*` keys (ut-docs#2710)

Date: 2026-11-04. Branch `chore/2710-dead-locale-keys` (uncommitted at review
time, forked from `origin/main`). Author model: Sonnet 5.5 Dev agent.
Reviewer: Opus 5.5, a different model per `reviewer/SKILL.md`. Source of
truth: `universal-till` `web/locales/en.json` on the companion branch of the
same name.

## What shipped
- `locales/de.json`: −3 keys, the ones universal-till #2698 left without a
  consumer — `elevation.summary.buttons_delete_item`
  ("„%s“ aus dem Katalog löschen. …"), `tile_sheet.delete_item`
  ("Artikel löschen"), `tile_sheet.delete_item_confirm`. 3843 keys remain.
- `manifest.json`: 1.1.291 → 1.1.292 (patch).
- Nothing else: no `i18n-baseline/` change is needed (neither
  `de.untranslated.txt` nor `de.same-as-en.txt` listed these keys — checked,
  so no stale entry is created), no README/LICENSE/`package.sh` change.

Pre-flight: shipped-file change → `manifest.json` version bumped (1.1.292,
one patch above tag v1.1.291). `i18n-baseline/`: n/a (keys not listed).
Core side: `web/locales/{en,ar,fa,tr}.json` +
`scripts/ci/i18n-baseline/key-meta-baseline.txt` on the universal-till branch
of the same name, reviewed in `docs/code-reviews/2026-11-04-dead-locale-keys-2710.md`
there. Help (`web/help/de/`): n/a — the keys had no consumer, so no German
help page describes them; the card's separate help-translation items are
deferred there (finding 2 of the core record). Review record: this file.

## Verification (run)
- `scripts/validate.sh`: ok, com.universaltill.language-de v1.1.292 (de).
- `scripts/check-no-gitlinks.sh`: ok. `scripts/check-key-drift.test.sh`: pass.
- `UT_CORE_EN_JSON=<edited core en.json> scripts/check-key-drift.sh`:
  3843/3843 core keys translated, 0 drift, 0 orphans, 0 empty values, 0
  untranslated-present, 0 token/ICU mismatches (118 known-same-as-English).
- `scripts/check-version-bump.sh` against a `git stash create` snapshot
  (it diffs `origin/main..HEAD`, so it reports "no shipped file changed"
  while uncommitted): "version bumped 1.1.291 -> 1.1.292, covering
  locales/de.json, manifest.json". Re-run after committing.
- `locales/de.json` parses; no duplicate keys.
- Order check, both directions: this pack against core `main` (keys still
  there) fails with **3 missing keys / new drift**; core's edited `en.json`
  against pack `main` fails with **3 orphan keys**. See the verdict.

## Findings
| # | Severity | Where | Finding | Action |
|---|----------|-------|---------|--------|
| 1 | Non-blocking (merge order) | — | ut-docs#2710 asks for "packs first or together". For a removal that cannot be green: this PR's CI runs `check-key-drift.sh` against core `main`'s `en.json`, which still has the three keys, so the PR fails until core merges. | **Accepted as an order constraint:** merge the universal-till PR first, then this one in the same cycle. Core `main`'s `lang-pack-drift` is red on orphan keys in that window (expected); re-dispatch it once de, es and pt have landed. |
| 2 | Nit (info) | `locales/de.json` | The removed German wording ("Artikel löschen" / "aus dem Katalog löschen") was a real translation, not a stub — dropping it loses nothing, since the till's delete-from-grid flow now renders `elevation.summary.buttons_remove` ("Schnellwahltaste %s vom Verkaufsbildschirm entfernen."), which this pack already translates. | Accepted; verified the replacement key exists and is translated here. |
| 3 | Nit (info) | — | No released till build (every `v0.34.*`/`v0.35.*` tag checked in core) consumes these keys, so shipping v1.1.292 to an older till cannot blank a string. | No action. |

No blocking findings.

## Verdict
Safe to merge, **after** the universal-till PR of the same branch name and in
the same cycle (finding 1).
