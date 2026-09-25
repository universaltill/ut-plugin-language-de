# Review — running-out chip plural keys (ut-docs#2648)

Core (universal-till#1356) splits `inventory.running_out` ("item(s)…") into
`inventory.running_out_one` / `inventory.running_out_other`. This pack makes the same split:

- `_one` "Artikel geht voraussichtlich innerhalb einer Woche aus", `_other` "Artikel gehen voraussichtlich innerhalb einer Woche aus"
- `manifest.json` version bumped (shipped file changed).

Verified: `scripts/validate.sh` ok; `UT_CORE_EN_JSON=<universal-till branch en.json> scripts/check-key-drift.sh`
→ 0 drift, 0 orphans. The independent Opus 5.5 reviewer of the core change also read these values and found them correct.
Merge order: after core #1356 (this pack's drift check reads core `main`).

Verdict: safe to merge once core has merged.
