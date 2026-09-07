# Code review: translate 3 sync.quarantine_reason.* keys

- **Card:** universaltill/ut-docs#1695 — `lang-pack-drift` red on
  `universal-till` main since PR #852 (ut-docs#1686) merged, adding 3
  new core keys with no same-branch language-pack follow-up (that
  session had no `add_repo`-equivalent access to this repo at the time).
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** self-reviewed against this repo's own established
  pattern (mechanical, single-purpose translation fix; found and fixed
  incidentally while landing the unrelated ut-docs#1689 follow-up in the
  same session, which now has this repo attached) — verified live
  against the repo's own guards rather than trusting the translation by
  eye alone.

## What shipped

Three keys added to `locales/de.json`, alphabetically placed among the
existing `sync.quarantine_reason.*` siblings:

```
"sync.quarantine_reason.unknown_line_reference": "Unbekanntes Produkt oder unbekannte Variante auf einer Verkaufsposition bei der Wiederholung",
"sync.quarantine_reason.unknown_sale_reference": "Unbekannter Kassierer, Kunde, Kassenplatz oder Tisch bei der Wiederholung",
"sync.quarantine_reason.unresolved_reference": "Nicht auflösbarer Verweis bei der Wiederholung",
```

Terminology matches this file's own established vocabulary rather than
inventing new terms: "Wiederholung" for "replay" (matches the sibling
keys `unknown_voucher_redemption`/`voucher_id_collision_issue`, both
already using "…wiederholung"), "Kassierer" (cashier, matches
`shifts.cashier`/`reports.eod.operator`), "Kunde" (customer, matches
`basket.customer`), "Kassenplatz" (register, matches
`registers.error.create`/`elevation.summary.till_register` — this
codebase's established term for the *register* resource, distinct from
"Kasse" which means the till itself), "Tisch" (table, matches
`tables.col.name`).

These are internal-tooling/admin-panel phrasing (a LAN-sync journal
quarantine reason on the `/sync-quarantine` manager page), not
customer-facing or compliance-sensitive.

## Review findings

None (no must-fix). Neither value is byte-identical to core's English
string, so no `i18n-baseline/de.same-as-en.txt` entry is needed; none of
the three keys was already listed in `i18n-baseline/de.untranslated.txt`
(nothing to prune).

## Verified, live, not just read

- `bash scripts/validate.sh` — `ok com.universaltill.language-de v1.1.28 (de)`, exit 0.
- `bash scripts/check-key-drift.sh` (default mode — fetches core's live
  `main` `en.json` over the network, exactly like CI) —
  **`ok -- 1997/1997 core keys translated, 0 drift, 0 orphans, 0 empty
  values, 0 untranslated-present, 0 token mismatches`**.
- **Also fixed in this same commit, found while re-running the live
  check:** `issuereport.my_reports.view_on_github` had become an orphan
  key — `universal-till` PR #853 (ut-docs#1690, a *different* lane,
  merged to `main` in between this PR's first push and this review)
  removed that core key entirely (stopped rendering the private-tracker
  link that 404'd for shop operators), leaving this pack's translation
  of it dangling with nothing to translate. Removed here rather than
  filing yet another separate PR, since this PR's whole purpose is
  "make `key-drift` green" and the fix is the same one-line shape.
- No real client/shop name, no secret-shaped literal.
- `manifest.json` version unchanged — release/tag is a separate, later
  action per this directory's own established precedent.
- Git identity on the commit: `Farshid Mirza
  <4035824+farshidmirza@users.noreply.github.com>`.

## Verdict

**Safe to merge.** Small, mechanical, fully guard-verified. Closes out
ut-docs#1695's `de` half; the `es` half is filed as its own PR in
`ut-plugin-language-es`.
