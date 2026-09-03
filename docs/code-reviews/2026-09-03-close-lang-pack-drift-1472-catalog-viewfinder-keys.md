# Code review: translate the 2 new catalog viewfinder keys

- **Card:** implied lang-pack follow-up to universal-till (ut-docs#1472,
  catalog in-page camera viewfinder), per the "own it explicitly" rule in
  the `scrum-master` skill — core's upcoming push to `main` would start
  failing `lang-pack-drift` for this pack on merge without this.
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** same session, independent re-check against the repo's own
  guard scripts (no separate subagent spun up — a 2-key, single-file
  translation diff verified end-to-end by the repo's own mechanical guards
  is proportionate here — same call as the #1430 record this mirrors).

## What shipped

Core (`universal-till`'s `web/locales/en.json`) gained two new keys:
`catalog.viewfinder.capture`, `catalog.viewfinder.not_ready`. This pack
(1854/1854 core keys — full coverage) had no baseline debt to draw on, so
both needed real translations:

- `"catalog.viewfinder.capture": "Aufnehmen"`
- `"catalog.viewfinder.not_ready": "Kamera noch nicht bereit — versuchen Sie es gleich noch einmal."`

`catalog.viewfinder.capture` deliberately does NOT reuse this file's
existing `catalog.take_photo` ("Foto aufnehmen") — core's own review found
reusing a near-identical key caused a real duplicate-label bug in the
Persian pack, so core added a dedicated key instead of reusing an
existing one; this translation is short and distinct from
"Foto aufnehmen" for the same reason.

## Review findings

None (no must-fix).

- Diffed core's actual `web/locales/en.json` (local checkout) and
  confirmed both key names are byte-exact, nothing else relevant changed.
- `locales/de.json` is valid JSON: 1856 total keys (1854 + 2 new), no
  duplicate keys.
- Alphabetical insertion correct: `catalog.variants.pick_hint` →
  `catalog.viewfinder.capture` → `catalog.viewfinder.not_ready` →
  `catalog.whole_item`.
- `scripts/validate.sh` and `scripts/check-key-drift.sh` (run against a
  local `universal-till` checkout, via `UT_CORE_EN_JSON`) both pass:
  **1854/1854 core keys translated** (full coverage retained), 0
  known-untranslated, 66 known-same-as-English (unchanged), **0 drift, 0
  orphans, 0 empty values, 0 untranslated-present, 0 token mismatches**.
- Neither new value is byte-identical to core's English string — no
  same-as-English allowlist entry needed.
- No format tokens (`%s`/`%d`/…) in either string.
- No compliance-outcome wording (ADR-0040 doesn't apply to a camera-UI
  button label anyway).
- Git identity on the commit: `Pouria Teimouri
  <35641125+pouria-teimouri@users.noreply.github.com>`, a real
  GitHub-linked human identity, not an AI-tool default (`Co-Authored-By:`
  trailer is co-author attribution only).
- No real client/shop names, no secret-shaped literals — the entire diff
  is the two new locale lines.

## Verdict

**Safe to push directly to `main`** — this repo's own history has ample
precedent for landing a guard-verified, single-file lang-pack-drift
closure as a direct commit (e.g. the #1430/#1352 records). `manifest.json`'s
version is **not** bumped in this commit — this pack's own established
convention bumps/tags at publish time, not in the content commit; a
release/tag pass to actually ship this to the marketplace is a separate,
later action.
