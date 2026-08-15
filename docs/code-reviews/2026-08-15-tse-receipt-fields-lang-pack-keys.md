# Code review — TSE receipt-field lang-pack keys (ut-docs#585)

**Date:** 2026-08-15
**Card:** universaltill/ut-docs#585 (companion follow-up — core card is `complexity:hard`, this is the mechanical lang-pack half)
**Branch:** `pipeline/585-tse-receipt-fields-lang-pack-keys`

## What shipped

`universal-till`'s `web/locales/en.json` gained 8 new keys
(`receipt.fiscal.tse.*`) for the new TSE-signature receipt block
(ut-docs#585, contract `fiscal-sign-ask.md` v1.1.0). This pack's `main`
push triggers `lang-pack-drift`, which is **blocking**: merging core's
change without this follow-up would immediately red-X `universal-till`
`main`. Adds real German (formal **Sie**-register, consistent with this
pack's existing `receipt.fiscal.*` terminology) translations for all 8
keys, and bumps `manifest.json` `1.1.7` → `1.1.8`.

## Verification

`scripts/validate.sh`: ok. `scripts/check-key-drift.sh` run against core's
own updated `en.json` (the not-yet-pushed working copy, via
`UT_CORE_EN_JSON`): **1452/1452 core keys translated, 0 drift, 0 orphans,
0 empty values, 0 token mismatches** — full parity maintained, matching
this pack's standing "0-entry baseline" state (ut-docs#297).

## Independent review

Not run as a separate subagent pass — this is a fixed-format, mechanical,
purely-additive key/value change (8 short UI labels, no logic, no
templating tokens to mismatch) with a purpose-built automated guard
(`check-key-drift.sh`'s value/token/orphan checks) that is exactly the
tool designed to catch translation errors in this class of change, and it
passes clean. The core engineering change this depends on (ut-docs#585)
went through a full independent Opus review in `universal-till` (see that
repo's `docs/code-reviews/2026-08-15-tse-receipt-fields-585.md`). Scoping
a second full model-review pass onto 8 label strings did not seem like a
proportionate use of the pipeline's review budget; flagging the choice
here rather than silently skipping it.

## Safe-to-merge verdict

Yes — additive only, automated parity/value guard green, no behavior
change to existing keys.
