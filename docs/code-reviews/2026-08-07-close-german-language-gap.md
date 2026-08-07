# Code review — close the German language-pack gap (ut-docs#297)

**Date:** 2026-08-07
**Card:** universaltill/ut-docs#297 (p2, `complexity:hard`)
**Branch:** `fix/297-close-german-language-gap`
**Dev:** subagent, Fable (hard-tier build model)
**Reviewer:** independent subagent, Opus (hard-tier review model — deliberately
not Fable, so translation-quality issues aren't checked by the same model that
wrote them)

## What shipped

`ut-plugin-language-de/locales/de.json` went from 170 of core's 1128 keys
translated to full parity — every core key now has a real German value.
`i18n-baseline/de.untranslated.txt` (the ut-docs#292 drift guard's ratchet)
regenerated from 918 entries to 0. Alongside the translation itself:

- `scripts/check-key-drift.sh` gained a placeholder-token-parity check
  (`%s`/`%d`/`{{name}}`/`{0}` must appear in the same order in `de.json` as
  in core) — TDD, 3 new cases confirmed red against the pre-change script.
- Once the baseline reached 0, `--update-baseline` now refuses to reopen it
  (regenerate a non-empty baseline) without an explicit `--allow-growth`
  flag, so 100% coverage can't regress via a routine re-run out of habit.
  TDD, 4 new cases.
- `manifest.json` 1.0.2 → 1.1.0.
- `README.md` rewritten to describe current coverage and both guard
  mechanisms (was still describing "a growing subset").

## What the independent review found

The build itself (translation content, token handling, guard-check logic,
test coverage, gate compliance) was verified sound — see "Verified beyond
automated tests" below for the specifics the reviewer independently
re-ran. Four BLOCKER-class issues and a set of SHOULD-FIX items were found
and fixed in a second commit (`1141fdc`), scoped to the fix, not a re-review
of the whole diff (this pipeline's standing rule: a second round is earned
by a blocker, and stays scoped to it):

**1. BLOCKER — `Storno` used for what is actually a goods return, with three
different German terms for the same concept in the same flow.** In German
POS/fiscal practice (DSFinV-K/KassenSichV), a *Storno* voids a booking; a
goods return is a *Retoure*/*Rückgabe*, and the money movement is an
*Erstattung*. `refund.help`'s own English ("Stock is returned to the shop…
the refund receipt references this sale") is unambiguously a Retoure, not a
Storno — an auditor reading a Z-report line labelled `Stornos` would book it
under the wrong category. Ten keys used `Storno` for this (`refund.title`,
`refund.col.refund_qty`, `refund.original_ref`, `refund.returns_ref`,
`reports.refunds`, `reports.tax_summary_hint`, `receipt.return_for`,
`refund.help`, `designer.receipt.show_barcode`, `help.feat.sell.s3`,
`settings.invoice.help`), while `refund.submit`/`refund.method`/
`refund.col.remaining` on the *same screen* already correctly used
`Erstattung`, and `inventory.return_title`/`process_return` already
correctly used `Retoure`. Standardized: **Retoure** = the goods-return
action/screen, **Erstattung** = the money movement, **Storno** reserved for
an actual void (grepped after the fix: zero remaining uses of the word in
`de.json`).

**2. BLOCKER — `help.feat.plugins.what` misstated the plugin trust model.**
German word order/passive collapsed "is signed and verified before it runs"
into a reading of "the till signs the plugin before running it" — factually
wrong and contradicting ADR-0006 / `internal/plugins/manifest_verifier.go`
(the publisher signs at build time; the till only verifies). Reworded to
keep the two facts distinct and correctly ordered: *"Jedes Plugin ist
signiert und wird vor der Ausführung verifiziert."*

**3. BLOCKER — the guard was never actually tightened once parity was
reached**, despite the acceptance criterion asking for it explicitly. The
existing ratchet mechanism happened to enforce exact parity as a side effect
of the baseline being empty, but nothing stopped a plain `--update-baseline`
re-run from silently regenerating a non-empty baseline and quietly
reopening debt — and the script's own header comment still argued *against*
demanding parity, using now-false numbers (917/1087). Fixed: `--update-
baseline` on an empty baseline now requires `--allow-growth` to proceed;
header rewritten to state current parity and explain the new gate.

**4. BLOCKER — two overstated/incorrect claims in the first commit
message.** "The two highest length-ratio flags… tender.scan.add 3.33x,
nav.settings 1.62x" was wrong (`nav.settings` was not top-2 of the ~19 keys
at or above that ratio — several tied with `tender.scan.add` at 3.33x
alone). "tender.scan.qty is an aria-label/title, not visible text" was also
wrong — it's additionally a visible `<th>` in `invoice.html` (practical risk
is low at 5 characters, but the stated justification was factually
incorrect). Both corrected in the second commit's message rather than left
standing as a false record.

**SHOULD-FIX, applied alongside the blockers** (full list in `1141fdc`'s
commit message): `settings.invoice.help`'s "Stornos berechneter Verkäufe" →
"Erstattungen fakturierter Verkäufe" (folds into finding 1 plus a wording
fix — *berechnet* reads as "calculated", not "invoiced"); `settings.enrol.
benefits` "Tipp" (hint) → "Fingertipp" (a tap); `settings.backup.help`
"Maschine" (machinery) → "Gerät" (device); `plugins.store.state.retryable`
"erneut versuchen möglich" (telegraphic) → "kann wiederholt werden";
`invoice.bill_to` shortened "Rechnungsempfänger" (19 chars) → "Rechnung an"
(11 chars) to reduce the byte budget it eats on a 42-byte-clipped ESC/POS
receipt header line; `tender.reference_placeholder`'s non-standard "Aut.-
Code" → "Auth-Code"; `tills.revoke` "Entziehen" → "Zugang entziehen"; three
minority `Filiale`/`Filialleiter` instances (including one inconsistent with
its own sibling key on the same page) standardized to the dominant
`Geschäft`/`Manager` pair used everywhere else (31/14 occurrences).

**Deferred, not silently dropped:** a handful of NIT-level findings —
`TOKEN_RE`'s gap on printf width/precision verbs (`%.2f`, `%-10s`) is latent,
since no current core key uses them; a few more length-flagged strings
(`sync.chip_queued`, `reports.seasonal_lunar_badge`, `plugins.status.
failed`) weren't individually re-verified in a live browser beyond the two
already driven (see below). The underlying byte-vs-rune `clip()` bug in
`universal-till/internal/print/escpos.go` that motivated shortening
`invoice.bill_to` is a separate, pre-existing defect outside this pack's
scope — filed as universaltill/ut-docs#371.

## Verified beyond automated tests

- **Driven visual check**, `universal-till` built and run locally
  (`UT_AUTH=off`, seeded demo data), real German terms substituted into the
  live DOM per the established ut-docs#300/#301 pattern (German ships as a
  plugin overlay, not a core locale — `?lang=de` against a till without the
  plugin proves nothing; substituting text into the live DOM after a real
  page load is the only check that means anything here). Sale screen at
  1024×600 kiosk and 1280×800: "Neuer Verkauf", "Hinzufügen", "Zahlen" all
  render with no clipping/overflow — the barcode-row button is flex-sized
  and grows to fit (measured: `clientWidth === scrollWidth` before and
  after, 74px → 133px, no truncation). `/menu`'s Settings tile →
  "Einstellungen" matches every sibling tile's icon-over-label layout
  exactly (confirmed after an initial DOM-substitution bug in the driving
  script — not the product — briefly collapsed the icon+label into one text
  node; re-driven correctly against the real `.menu-label` span). Console
  errors: none in either pass.
- **The two highest actual length-ratio candidates were checked and are
  false alarms**, not just asserted clean: `tender.scan.add` → "Hinzufügen"
  (3.33x) and `nav.settings` → "Einstellungen" (1.62x) both render with zero
  visual defect once actually rendered — the heuristic character-count scan
  overstated the real risk because these controls aren't fixed-width.
- **`tender.scan.qty`** is a `title`/`aria-label` on the sale-screen barcode
  row (`index.html:99`) — no visible text there — but the review correctly
  found it's also a visible `<th>` in `invoice.html:31`; not independently
  re-driven in this fix round, low risk at 5 characters ("Menge").
- **Not checked:** dark/curated themes, RTL. This change is locale-content
  only — no CSS or markup touched — so the risk class that motivated
  ut-docs#300/#301's theme/RTL checks (a shared stylesheet rule regressing
  unrelated surfaces) doesn't apply the same way here; noted rather than
  silently assumed covered.
- **TDD, re-verified independently** by the reviewer: the token-parity
  check's 3 new test cases were confirmed to fail against
  `git show main:scripts/check-key-drift.sh` (the pre-change script exits 0
  on a fixture with a dropped `%d`) before passing against the new one. The
  `--allow-growth` gate's 4 new test cases were added in the fix round and
  independently re-run clean by the orchestrator (21/21 total).
- **Existing translations preserved unchanged**: the reviewer diffed
  `main:locales/de.json` against the branch programmatically — 0 values
  changed, 0 keys removed, 958 added in the first commit; the second
  commit's 22 further value edits are exactly the reviewed findings above,
  confirmed by re-grepping for the flagged terms afterward (zero remaining
  `Storno`/`Filiale`/`Filialleiter` instances).
- Full gate, re-run after the fix commit: `scripts/validate.sh` (`ok
  com.universaltill.language-de v1.1.0`), `scripts/check-key-drift.test.sh`
  (21/21), `check-key-drift.sh` against a local core checkout (`ok --
  1128/1128 core keys translated, 0 known-untranslated, 44 known-same-as-
  English, 0 drift, 0 orphans, 0 empty values, 0 untranslated-present, 0
  token mismatches`), `scripts/package.sh` (artifact builds).

## Follow-up filed

- universaltill/ut-docs#371 — `internal/print/escpos.go`'s receipt-header
  `clip()` byte-slices instead of rune-slicing, so a multi-byte UTF-8
  character (e.g. German `ä`/`ü`/`ß`) sitting near the 42-byte clip boundary
  can split mid-character. Found during this card's scope but is a core
  print-module defect, not a translation issue — out of scope here.
