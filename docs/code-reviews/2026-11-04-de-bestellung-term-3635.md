# "Bestellung" for open orders, plus line-reduction PIN summary — de pack (ut-docs#3635)

## What was changed
- `locales/de.json`: the /open-orders page and its entry points used
  "Vorgang/Vorgänge" for an open order, while the newer cancel keys
  (`open_orders.cancel.*`, `elevation.summary.cancel_order`), `hold.toast.*`
  and the core help title ("Offene Bestellungen") say "Bestellung". 10 values
  now say "Bestellung": `open_orders.title`, `page.title.open_orders`,
  `tour.parked.title` ("Offene Bestellungen"), `open_orders.col.label`,
  `open_orders.resume_row`, `open_orders.empty`,
  `open_orders.error.load_failed`, `open_orders.hint` ("eine Bestellung …
  tippen Sie sie"), `open_orders.tabs_label`, `hold.modal.title` ("Diese
  Bestellung benennen (optional)").
- Not changed, because they mean "process/operation":
  `auth.exit_to_os.not_confirmed`, `settings.display.exit_to_os_not_confirmed`
  ("Exit-Vorgang"), `common.error.outcome_unknown`, `vouchers.history.col.event`.
- New key `elevation.summary.reduce_line_qty` = "Menge von %s von %s auf %s
  verringern (als %s)." This catches the pack up with core 94f605e21
  (ut-docs#5411), which added the key without a pack follow-up. The
  placeholders are item, current qty, new qty, and reason (rendered through
  `shrinkage.reason.*`, i.e. Storno / Einladung / Verderb).
- `manifest.json` 1.1.290 → 1.1.291 (patch).
- Core help (`web/help/de/`) changes are in universal-till on the same branch name.

## Review
- Reviewer: Claude Opus 5.5 (a different model from the author, a Claude
  Sonnet Dev subagent; the orchestrator added the `reduce_line_qty` key).
  It reviewed the uncommitted diff on `fix/3635-bestellung-term` against
  `origin/main` (f64eb46).
- Checked: gender/article agreement after Vorgang (m) → Bestellung (f)
  ("eine Bestellung … sie", "Diese Bestellung", "keine offenen
  Bestellungen"); formal Sie kept; `open_orders.empty`'s "erscheint er" still
  refers to "einen Verkauf" (correct); `%s` count and order are the same as
  en.json for all 11 keys (scripted); `reduce_line_qty`'s 4 placeholders
  match `web/i18n-meta/en.meta.json` and `pos_api.go:1674` (`cur.Name`, cur
  qty, new qty, `T("shrinkage.reason."+reason)`); no duplicate keys; the
  remaining `Vorg` hits are only the generic-sense keys listed above;
  templates confirm `open_orders.title` is the sale-screen icon/tooltip and
  dialog heading (`index.html:169,520,523`).

### Findings
1. Nit, optional: `locales/de.json:781` `elevation.summary.reduce_line_qty`.
   The sibling summaries open with an article ("Die Rolle von %s von %s auf
   %s ändern.", "Diese Position als %s entfernen."). Suggested: "Die Menge
   von %s von %s auf %s verringern (als %s)." The placeholder order stays the
   same. **Fixed** (applied as suggested).
2. Info: `scripts/check-version-bump.sh` passes vacuously before a commit
   ("no shipped file changed"); re-run it after committing.
3. Info (core side): `web/help/de/tables.md:26,29` in universal-till still
   quotes **Offene Vorgänge**. That is tracked in the universal-till review
   record for this card and does not block this PR.

## Verification
- `scripts/validate.sh`: ok com.universaltill.language-de v1.1.291 (de).
- `scripts/check-no-gitlinks.sh`: ok.
- `scripts/check-key-drift.sh` (core main 93b87c778, and the local core
  en.json): ok, with 3846/3846 core keys translated, 0 drift, 0 token
  mismatches. Before this change it failed on the missing
  `elevation.summary.reduce_line_qty`.

Pre-flight: New `en.json` key: de pack follow-up for
`elevation.summary.reduce_line_qty` updated (this PR; other packs are
outside this card). Manifest version updated (1.1.291). Help: core
`web/help/de/` updated in universal-till (one leftover, see finding 3).
Review record: this file.

### Verdict
Safe to merge. Finding 1 is optional. Merge in the same cycle as the
universal-till help change.
