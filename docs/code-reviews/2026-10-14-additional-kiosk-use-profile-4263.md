# Review — `settings.display.additional_kiosk_use_profile` (ut-docs#4263)

**Shipped:** one new core key translated into this pack, „Diese Kasse ist eine zusätzliche Kasse. Um sie zum Selbstbestell-Kiosk zu machen, nutzen Sie Einstellungen → Geräteprofil …“ — the refusal an additional till gets when `POST /api/settings/upsert` tries to switch it to the self-order kiosk without the Device profile confirm. Pairs with the universal-till PR for ut-docs#4263. Version bumped to 1.1.226.

**Review:** checked against `reference/translation.md`: no placeholders, nothing dropped; reuses the pack's existing terms (Zusätzliche Kasse / Selbstbestell-Kiosk / Einstellungen / Geräteprofil / Hauptkasse). `scripts/validate.sh` and `scripts/check-key-drift.sh` (`UT_CORE_EN_JSON` = the core branch's en.json) pass.

**Verdict:** safe to merge once the core PR is on `main`.
