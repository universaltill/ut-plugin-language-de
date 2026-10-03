# Review: open-orders cancel keys (ut-docs#3621)

Date: 2026-10-03 · Lane: lane:cloud-54 · Translated by Opus 5.5 · Reviewed by Fable (independent subagent)

## What shipped
New de translations for open_orders.cancel.error.main_till_unreachable. Version bumped. This follows core universal-till#1692, which adds the main-till-unreachable refusal for Cancel order.

## Findings
- Nit applied: wording aligned to the pack's "wieder erreichbar ist".
- Meaning, register, placeholders and terminology checked against the pack's neighbouring keys (main till, held orders, open orders, New sale); no other issues.

## Verified
`scripts/validate.sh`, `check-key-drift.sh` against core's branch en.json (all core keys translated, 0 drift, 0 orphans, 0 token mismatches), `check-version-bump.sh`: all ok.

## Verdict
Safe to merge once universal-till#1692 is on main. Before that, the new key is an orphan against main.
