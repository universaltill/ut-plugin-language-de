# Code review: receipt-policy keys (ut-docs#1907 pack follow-up)

- **Card:** universaltill/ut-docs#1907 — `universal-till` PR #980 (merged)
  added 8 keys to core's `web/locales/en.json` for the new three-way
  receipt-policy setting (ADR-0089) and removed the now-orphaned
  `settings.printer.auto`, landing `lang-pack-drift` red on `main`
  (blocking, per this repo's own `CLAUDE.md`) as a tracked follow-up —
  this pipeline's own standing rule is that the lane that merges the core
  change owns the pack follow-up in the same cycle.
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** fresh-context Sonnet subagent, given both this repo's and
  `ut-plugin-language-es`'s diffs together.

## What shipped

8 new keys in `locales/de.json`:

```
receipt.ask.none                              -> Kein Beleg
receipt.ask.paper                             -> Beleg drucken
receipt.ask.title                             -> Möchten Sie einen Beleg?
settings.printer.receipt_policy.always        -> Immer drucken
settings.printer.receipt_policy.ask           -> Kunden fragen
settings.printer.receipt_policy.locked_de     -> Für Geschäfte in Deutschland vorerst
                                                  auf „Immer drucken" festgelegt: Die
                                                  Kasse druckt für jeden Verkauf einen
                                                  Beleg, während die Belegregeln für
                                                  deutsche Geschäfte noch bestätigt werden.
settings.printer.receipt_policy.never         -> Nie automatisch drucken
settings.printer.receipt_policy.title         -> Beleg nach jedem Verkauf
```

Plus removal of the orphaned `settings.printer.auto` key (core no longer
has it) and a patch version bump (`1.1.37` → `1.1.38`).

Register matches this file's existing conventions: formal **Sie**
throughout (matches the neighboring `settings.printer.help`/`system_hint`
tone), infinitive/imperative style for option labels. `locked_de` is a
neutral factual statement about current behaviour, not a
compliance-outcome claim (ADR-0040) — matches this pack's existing
`compliance-claim`-sensitive wording elsewhere.

**Note:** this follow-up covers only the 8 receipt-policy keys this
lane's own merge introduced. `lang-pack-drift` on `main` remains red for
22 unrelated `categories.*` keys from a different, still-in-flight card
(`lane:cloud-54`, ut-docs#1898) — not this follow-up's to fix, per the
lane-ownership rule (each lane owns only the pack follow-up for its own
merge).

## Verified

- `scripts/validate.sh` — `ok com.universaltill.language-de v1.1.38 (de)`.
- `scripts/check-key-drift.sh` — the 8 receipt-policy keys and the
  `settings.printer.auto` orphan no longer appear in the drift/orphan
  output; only the pre-existing, unrelated 22 `categories.*` keys remain
  (confirmed not introduced by this change).
- `scripts/check-key-drift.test.sh` — all self-tests pass.

No correctness, translation-quality, or guard-compliance issues found.
