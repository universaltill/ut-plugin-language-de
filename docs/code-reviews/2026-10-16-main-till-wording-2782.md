# Review: Tills card role keys + "main till" wording (de) — ut-docs#2782

Date: 2026-10-16 · lane:cloud-41 · Author: Opus 5.5 · Reviewer: Sonnet (independent, read-only)

## What shipped
Follow-up to universaltill/universal-till#2009 (core), which:
- adds `settings.tills.role_label`, `settings.tills.role_main` and `settings.tills.main_till_addr` (%s);
- relabels `settings.tills.register_label` "Cash register for payouts", with `registers.strand_warning` quoting the new label;
- replaces "primary till" with "main till" in core.

This pack translates the three new keys and the new register label, and makes `strand_warning` quote that label exactly. It also changes the last "Primärkasse" (`elevation.summary.sync_promote`) to "Hauptkasse". The core de help quotes „Kassenplatz für Auszahlungen“, the same label. The manifest version is bumped.

## Findings
- None blocking. "Diese Kasse"/"Hauptkasse" match the pack's existing till terminology. The barcode "Primär" (`catalog.primary`) is intentionally kept.

## Verified
`scripts/validate.sh` OK. `check-key-drift.sh` against core's branch en.json: 3451/3451, 0 drift, 0 orphans, 0 token mismatches. The %s placeholder is kept.

## Verdict
Safe to merge after core #2009 merges (new keys, #1576).
