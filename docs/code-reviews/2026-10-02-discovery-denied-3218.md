# Review: tills.discovery.denied (ut-docs#3218)

**Change:** one new key in `locales/de.json` (the iOS Local Network refusal
message added by universal-till#1606) and a patch version bump.

**Reviewer:** independent model (not the author), 2026-10-02.

Checked: meaning matches the English source including "instead"
(„stattdessen“); „Lokales Netzwerk“ and „Einstellungen“ match Apple's German
iOS labels; Sie-form like every other `tills.*` key; „Kopplungscode“ is the
pack's existing term (`tills.join_code`, `setup.join.help`); „…“ quotes match
pack convention.

**Findings:** none.

**Checks:** `scripts/validate.sh` passes; `scripts/check-key-drift.sh` shows no
drift for this key against core `main` after universal-till#1606.
