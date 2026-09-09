# Code review: translate catalog.builtin_icon.* keys

**Date:** 2026-09-09
**Card:** ut-docs#1844
**Author:** scrum-master pipeline (cloud cycle, lane:cloud-54), on behalf of Farshid Mirza

## What changed

`universal-till`'s catalog image picker (ut-docs#1844) adds 10 new
`catalog.builtin_icon.*` keys to `web/locales/en.json` (a picker letting an
operator choose one of the 5 bundled category icons for an item, instead of
only an uploaded photo). This is the same-cycle language-pack follow-up
ADR-0010/this repo's own `CLAUDE.md` requires: a core key addition implies
a translation here before `main` goes red under `lang-pack-drift`.

- `locales/de.json`: all 10 keys translated into German.
- `i18n-baseline/de.same-as-en.txt`: added `catalog.builtin_icon.sandwich`.
  German borrows "Sandwich" as a standard loanword — identical spelling to
  English is the correct translation here, not a missed one, so this is the
  documented allowlist escape hatch (`check-key-drift.sh --update-allowlist`),
  not a mistranslation left unfixed.

## Why no re-litigation

This is a mechanical translation pass following an established, guard-
enforced pattern (`scripts/check-key-drift.sh`) — not new design. The
English source strings and key names were fixed by the core PR; this repo's
only job is a faithful, real (non-placeholder) translation for each.

## Verification performed

- `python3 -c "import json; json.load(...)"` — `locales/de.json` valid JSON.
- `scripts/validate.sh` — OK (JSON validity + non-empty string values).
- `scripts/check-key-drift.sh` against `UT_CORE_EN_JSON=<updated en.json
  from the ut-docs#1844 branch>`: before the allowlist update, exactly one
  new-drift finding — `catalog.builtin_icon.sandwich` byte-identical to
  English, correctly caught by the value-sanity check (this is real
  evidence the guard works, not a bug to route around). After
  `--update-allowlist`, re-ran the same check: **zero new drift** from this
  change. The 5 `orders.view.*`/`pos.toast.receipt_*` missing keys and 1
  `catalog.stock_untracked` orphan the check also reports are pre-existing,
  unrelated drift already tracked as ut-docs#1856/#1857 — confirmed by
  diffing the reported set before and after this change (identical).

## Independent review

Self-verified against this repo's own two automated guards
(`validate.sh`, `check-key-drift.sh`) rather than a separate model pass —
proportionate to a 10-key, single-file mechanical translation with
deterministic, guard-enforced correctness criteria (real-value + key-parity
checks), consistent with this pipeline's own process-depth guidance not to
fan out review effort below a couple of files. The substantive design and
code review for the feature itself lives in `universal-till`'s own
`docs/code-reviews/2026-09-09-catalog-image-picker-1844.md`.

## Non-goals confirmed out of scope

- Expanding the built-in icon set beyond the current 5 — split into
  ut-docs#1862, a separate licensing/curation task. This pack will need a
  second, later translation pass once that card lands new icon labels.

## Verdict

**Safe to merge.** No behavior change beyond adding real translations for
keys core already ships in English fallback; nothing here can regress an
already-working key.
