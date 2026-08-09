# Code review — translate 3 new `plugins.install.error.*` keys (ut-docs#411)

**Date:** 2026-08-09
**Card:** universaltill/ut-docs#411 (p3, `complexity:medium`)
**Branch:** `fix/411-page-plugin-install-error-keys`
**Dev:** inline, Sonnet (session model — see the companion
`ut-plugin-language-es` review doc for why this landed at medium/inline
scope rather than the card's original "42+ keys"/hard estimate: prior
cycles #494/#441 had already closed almost all of that drift before this
cycle ran)
**Reviewer:** independent subagent, Opus (medium-tier review model, fresh
context)

## What shipped

`plugins.install.error.page_conflict`, `plugins.install.error.page_route_conflict`
(added by `universaltill/universal-till#267`) and
`plugins.install.error.version_mismatch` (added by
`universaltill/universal-till#270`) were never propagated to this pack, so
`bash scripts/ci/check-lang-pack-drift.sh` (run from `universal-till`) had
been red on `main` for both language packs.

- `locales/de.json`: 3 new keys translated for real, grouped next to the
  existing `plugins.install.error.payment_conflict` sibling whose German
  phrasing they follow ("kollidiert mit … Wählen Sie … und versuchen Sie
  es erneut."). Coverage: 1183 → 1186/1186 — **this pack is now at full
  parity again.**
- `manifest.json`: `1.1.2` → `1.1.3` (patch — content addition, staying at
  full parity, matching this pack's own documented precedent in
  `2026-08-07-close-german-language-gap.md` §"1.1.0→1.1.1" and
  `2026-08-08-close-lang-pack-drift-36.md`'s "1.1.1→1.1.2", both patch
  bumps for a drift-closing translation change that kept the pack at full
  coverage).
- No baseline/allowlist file touched — these are genuinely new keys, this
  pack carries no untranslated-key debt to begin with
  (`i18n-baseline/de.untranslated.txt` is empty).

Companion fix in the sibling `ut-plugin-language-es` repo (same card,
separate branch/review — see that repo's own
`docs/code-reviews/2026-08-09-page-plugin-install-error-keys.md`) closes
the other half of the CI failure.

## Translations

| key | German | rationale |
|---|---|---|
| `plugins.install.error.page_conflict` | "Der Seitenschlüssel dieses Plugins kollidiert mit einem bereits vorhandenen. Wählen Sie einen anderen Schlüssel und versuchen Sie es erneut." | Mirrors `payment_conflict`'s established pattern; masculine `der Schlüssel` → dative `einem bereits vorhandenen`, accusative `einen anderen Schlüssel`. |
| `plugins.install.error.page_route_conflict` | "Die Seitenroute dieses Plugins kollidiert mit einer bereits vorhandenen. Wählen Sie eine andere Route und versuchen Sie es erneut." | Same pattern; feminine `die Route` → dative `einer bereits vorhandenen`, accusative `eine andere Route` — gender correctly switches from the parallel `page_conflict` string above it. |
| `plugins.install.error.version_mismatch` | "Der Marketplace hat die angeforderte Plugin-Version nicht zurückgegeben. Installation fehlgeschlagen." | Direct translation; "Installation fehlgeschlagen." matches the existing `retryable` key's register. `nicht`'s position fixed in review — see below. |

## Independent review (Opus, fresh context) — 0 blockers, 1 style nit (fixed) + 1 process gap (fixed)

Re-ran the full gate from scratch against this branch:
`scripts/validate.sh` (clean), `scripts/check-key-drift.sh` against a real
local `universal-till` checkout's `web/locales/en.json`
(**1186/1186 translated, 0 baseline, 45 allowlist, 0 drift, 0 orphans, 0
empty values, 0 untranslated-present, 0 token mismatches**),
`scripts/check-key-drift.test.sh` (22/22 — this pack's copy includes
placeholder-token parity tests the `es` pack's copy doesn't yet have,
ut-docs#312's known tracked gap), `scripts/package.sh` — confirmed the
tarball contains exactly `manifest.json`, `locales/de.json`, `README.md`,
`LICENSE`, no `i18n-baseline/`. Confirmed diff hygiene: only
`locales/de.json` (3 new lines, no existing key altered) and
`manifest.json` (version bump) touched; 0 duplicate keys; 0
non-string/empty values.

Hand-verified all 3 new strings: formal *Sie* register maintained
throughout, correct gender/case agreement traced for both `Schlüssel`
(masc.) and `Route` (fem.) — the exact thing usually botched in a
copy-paste pair of parallel strings, confirmed right here — `dieses
Plugins` correctly genitive neuter, `Plugin-Version` correctly hyphenated,
no placeholder tokens in any of the three.

**NIT, fixed — `version_mismatch` negation placement.** Original
("`hat nicht die angeforderte Plugin-Version zurückgegeben`") places
`nicht` before the definite object, which reads as constituent/contrastive
negation ("returned *not* the requested version — but some other one").
The English source is plain sentence negation. Fixed to place `nicht`
after the definite object (`hat die angeforderte Plugin-Version nicht
zurückgegeben`), the standard German word order for negating the whole
clause.

**PROCESS GAP, fixed — this repo had no feature branch and no review
record for this change**, breaking the pack's own unbroken 7-for-7
`docs/code-reviews/` precedent (every prior translation change in this
repo has one) and contradicting an earlier draft of the `es` repo's review
doc, which claimed a companion `de` review already existed. Fixed: moved
the change onto `fix/411-page-plugin-install-error-keys` and wrote this
record before commit.

## Verified beyond the automated suite

- Confirmed both new core keys' English source text directly from
  `universal-till/web/locales/en.json` on `main`.
- Confirmed the pre-existing `payment_conflict` sibling's German phrasing
  was the right style precedent, including checking that the two new
  parallel strings (`page_conflict`/`page_route_conflict`) correctly swap
  gender/case rather than copy-pasting one shape.
- Independent reviewer re-ran every gate from scratch and traced
  version-bump precedent through this repo's own prior review docs (a
  shallow clone here means `git log` alone couldn't confirm it — the
  review docs are the durable record).

## Safe-to-merge verdict

Yes.
