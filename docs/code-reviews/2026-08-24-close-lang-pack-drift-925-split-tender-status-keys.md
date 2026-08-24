# lang-pack-drift red — 15 missing keys (tender.status.*) — ut-docs#925

**Reviewer**: self-reviewed (`complexity:medium` card; mechanical
translation-sync follow-up to an already-independently-reviewed core
change, matching the standing pattern for this check — see closed
precedents #862, #910, #746, #891, #612, #494, #374, #441, #579, #296).
**Branch**: `sync/925-split-tender-status-keys` (base: `main`).
**Date**: 2026-08-24.

## What shipped

`lang-pack-drift` went red on `universal-till`'s `main` after merging
universal-till#475 (ut-docs#925, the split-tender panel's own client-side
status copy hardcoded in English), which added 15 new core keys to
`web/locales/en.json`:

`tender.status.added`, `tender.status.already_covered`,
`tender.status.amount_positive`, `tender.status.basket_unavailable`,
`tender.status.change_exceeds`, `tender.status.change_note`,
`tender.status.cleared`, `tender.status.filled`,
`tender.status.need_payment`, `tender.status.network_error`,
`tender.status.payment_failed`, `tender.status.removed`,
`tender.status.sale_completed`, `tender.status.select_method`,
`tender.status.submitting`.

This was advisory-only on universal-till#475 itself (the PR touched
`en.json` but `lang-pack-drift` only warns on a PR, per this check's own
design) and correctly turned blocking once merged to `main`.

This PR adds German translations for all 15 to `locales/de.json`, keeping
this pack's existing exact-parity coverage (0-entry `i18n-baseline/
de.untranslated.txt`). Two placeholder-bearing keys carry a `%s`
substitution each — `tender.status.added` (two `%s`, method + amount) and
`tender.status.change_note`/`tender.status.filled` (one `%s` each) —
counts verified to match core exactly (see below). No `i18n-baseline/`
edit needed: none of these keys previously existed in core, so this is a
pure addition, not a baseline prune.

A companion PR in `ut-plugin-language-es`
(https://github.com/universaltill/ut-plugin-language-es/pull/77) carries
the matching Spanish translations — both were required to fully close the
drift; neither alone would have.

## Verified beyond automated tests

- `python3 -c "import json; json.load(open('locales/de.json'))"` — valid JSON.
- `scripts/validate.sh` — `ok com.universaltill.language-de v1.1.10 (de)`.
- `UT_CORE_EN_JSON=<local checkout of universal-till's merged en.json>
  scripts/check-key-drift.sh` — `ok -- 1547/1547 core keys translated, 0
  known-untranslated (baseline), 56 known-same-as-English (allowlist), 0
  drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
  mismatches` — the token-mismatch count specifically confirms the `%s`
  placeholder counts above are correct, not just that the keys exist.
- Post-merge: re-ran `universal-till`'s own
  `scripts/ci/check-lang-pack-drift.sh` locally against this pack's new
  `main` HEAD (`76563c3`) — `ut-plugin-language-de ok`.

## Outcome

Merged as `76563c3`. `universal-till`'s `main` is back in sync (both packs
verified green against the merged core `en.json`).
