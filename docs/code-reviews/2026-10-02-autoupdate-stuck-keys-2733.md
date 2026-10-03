# Review: auto-update stuck chip keys (ut-docs#2733)

**Date:** 2026-10-02 · **Lane:** lane:cloud-24 · **Reviewer:** Fable (independent subagent, same pass as core's `docs/code-reviews/2026-10-02-autoupdate-stuck-chip-2733.md`)

Two new core keys go into `locales/de.json`: `status.update_auto_blocked` (status chip) and `settings.update.auto_blocked` (Settings → Check now). They are translated from core's en.json (universal-till#1638), and `manifest.json`'s version is bumped.

`scripts/validate.sh` and `scripts/check-key-drift.sh` (`UT_CORE_EN_JSON` = the core branch's en.json): all keys translated, 0 drift, 0 orphans.

Translation checks: register matches the pack; ".deb" untouched; no placeholders; no hardcoded install path (core dropped "/opt/unitill" in review).

Fixed: de: "Installiere … prüfe" (du) → "installieren Sie … Prüfen Sie" (Sie, as the rest of the pack), "für Hilfe tippen" → "für Hilfe antippen".

Verdict: safe to merge once universal-till#1638 is on main.
