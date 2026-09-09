# Code review: order-number scheme keys (ut-docs#1874)

- **Card:** universaltill/ut-docs#1874 — follow-up from `universal-till#943`
  (ut-docs#1817, merged 2026-09-09), which added 7 keys to core's
  `web/locales/en.json` and left `lang-pack-drift` red on `main` for both
  external language packs as a known, tracked follow-up.
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** independent fresh-context Sonnet subagent, given both this
  repo's and `ut-plugin-language-es`'s diffs together (same 7 keys, two
  languages) — checked translation correctness/register, `%s` placeholder
  parity, JSON validity, baseline-file scoping, and version bump.

## What shipped

7 new keys in `locales/de.json`:

```
elevation.summary.order_no_scheme          -> Das Bestellnummern-Schema auf %s setzen.
orders.col.order_no                        -> Bestell-Nr.
settings.order_no.help                     -> Die kurze Nummer, die Kunden angezeigt und auf
                                               Küchenbons gedruckt wird — getrennt von der
                                               Belegnummer, die für Rückerstattungen und
                                               Berichte dauerhaft bleibt.
settings.order_no.scheme                   -> Nummerierung
settings.order_no.scheme_lifetime_no_reset -> Fortlaufend, wird nie zurückgesetzt
settings.order_no.scheme_trading_period_reset -> Nach jedem Kassenschluss zurücksetzen (Standard)
settings.order_no.title                    -> Bestellnummern
```

Matching `i18n-baseline/de.untranslated.txt` pruning (all 7 lines removed —
`check-key-drift.sh` treats a translated-but-still-listed baseline entry as
stale and fails, per this repo's own `CLAUDE.md`), and a patch version bump
(`1.1.36` → `1.1.37`, `auto-tag-release.yml` tags/releases on a
`manifest.json` version with no matching tag yet).

Register matches this file's existing conventions: infinitive-instruction
style for the `elevation.summary.*` line (matches
`elevation.summary.eod_reprint`'s "Den ... erneut drucken."), short
abbreviation for the column header (`orders.col.order_no` "Bestell-Nr.",
mirroring `orders.col.receipt` "Beleg"), and the same em-dash clause
structure `settings.language.help` already uses for a similar two-part
explanatory sentence.

## Verified

- `scripts/validate.sh` — `ok com.universaltill.language-de v1.1.37 (de)`.
- `scripts/check-key-drift.sh` — `ok -- 2169/2169 core keys translated, 0
  known-untranslated (baseline), 72 known-same-as-English (allowlist), 0
  drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
  mismatches`.
- `scripts/check-key-drift.test.sh` — all self-tests pass.

## Review findings

One cosmetic nit, not fixed: `elevation.summary.order_no_scheme` was
inserted after `eod_range_export` rather than after the last `eod_*` key
(alphabetical order within the `elevation.summary.*` block is very slightly
off at that one insertion point). JSON key order has no runtime effect and
nothing else in the diff is affected — left as-is rather than reopening the
diff for a purely cosmetic reorder.

No correctness, translation-quality, or guard-compliance issues found.
