# Code review — close lang-pack drift (ut-docs#374)

**Date:** 2026-08-08
**Card:** universaltill/ut-docs#374 (p3, `complexity:hard`)
**Branch:** `fix/374-close-lang-pack-drift-de`
**Dev:** subagent, Fable (hard-tier build model)
**Reviewer:** independent subagent, Opus (hard-tier review model — deliberately
not Fable)

## What shipped

`universal-till`'s `lang-pack-drift` CI workflow had been red on `main` for
at least 3+ commits: this pack (previously at full parity with core,
ut-docs#297) had drifted 17 keys behind core's `web/locales/en.json`, plus
one orphan key core had renamed. Fixed:

- `locales/de.json`: 17 new keys translated, restoring **exact parity**
  (1145/1145 core keys, 0-entry baseline unchanged); orphan key
  `selforder.search_ph` removed (core renamed it to `products.search_ph`,
  which is one of the 17 translated keys).
- `manifest.json`: `1.1.0` → `1.1.1` (patch — staying at full parity, not a
  new coverage milestone).

Companion fix in the sibling `ut-plugin-language-es` repo (same card,
separate PR/review — see that repo's own `docs/code-reviews/` for the
Spanish-side diff) closed the other half of the CI failure.

## Independent review (Opus, fresh context) — 0 blockers, 1 NIT, fixed

Full gate re-run and confirmed green: `scripts/validate.sh`,
`scripts/check-key-drift.test.sh` (22/22), `check-key-drift.sh` against a
local core checkout (**1145/1145 translated, 0 drift, 0 orphans, 0 empty
values, 0 untranslated-present, 0 token mismatches**), `scripts/package.sh`.
Diff hygiene confirmed: only `locales/de.json` and `manifest.json` touched,
no existing translation altered, no secret-shaped values, no duplicate
JSON keys.

Terminology cross-checked against the pack's own existing keys for every
one of the 17 new strings (till → `Kasse`, primary → `Hauptkasse`,
`Manager-PIN` byte-identical to existing sibling keys, ellipsis/spacing
conventions matched) — all confirmed consistent. Placeholder tokens: none
of the 17 keys carry a token; guard's automated token-parity check
confirms 0 mismatches across the whole file.

**NIT, fixed — `plugins.install.error.payment_conflict` had a dangling,
gender-mismatched elliptical adjective.** "…steht im Konflikt mit einem
bereits vorhandenen." left the substantivized adjective without a head
noun, and its dative masc./neuter form didn't agree with the feminine
*Beschriftung* half of the preceding "oder" clause. Meaning was still
recoverable (cosmetic, not a blocker) but fixed for correctness: "…kollidiert
mit einem bereits installierten Plugin." Re-verified: gate re-run clean
after the edit, no other value touched.

**Confirmed correct by the reviewer, no changes needed:** grammatical fit
of `tills.the_primary`/`tills.this_till` against their real template usage
(`web/ui/pages/tills.html` — they render as parentheticals after a till
name, so nominative case is correct); `sync.banner_open_primary_unavailable`
correctly distinct in register from its actionable-link sibling
`sync.banner_open_primary`; version bump semver-sane; manifest description
and README both remain accurate post-fix (no doc update owed — the "full
parity"/"baseline currently empty" claims both still hold).

## Verification beyond the automated suite

- Live CI logs from the failing run
  (https://github.com/universaltill/universal-till/actions/runs/31239752673)
  used to derive the exact key list and confirm this is genuine drift, not
  a guard false-positive.
- Reviewer independently re-ran the full gate (not just re-read the diff)
  and hand-verified terminology/grammar against the pack's own existing
  corpus and the real HTML templates the strings render into.
- No UI/visible-surface driven-browser check performed for this pass — a
  real-but-accepted gap: this is a 17-key incremental patch (vs. #297's
  958-key full-coverage milestone, which did do a full driven-DOM check),
  the automated key-drift/token-parity/empty-value gate is the meaningful
  regression proof for content-only changes at this scale, and every new
  string was checked by eye for plausible length against its English
  source (none flagged as overflow risk — the longest, the payment-conflict
  error, is a non-width-constrained error message, not a fixed-width
  control label).

## Safe-to-merge verdict

Yes.
