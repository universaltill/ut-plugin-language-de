# Code review: voucher issue/redeem cashier UI strings (ut-docs#1832)

- **Card:** universaltill/ut-docs#1832 — `universal-till` PR #937 (branch
  `fix/1832-voucher-ui`) adds 19 new keys to core's `web/locales/en.json`
  for the new "Sell a voucher" / redeem-a-voucher cashier UI, landing this
  pack's translation *before* #937 merges to `main` (to avoid the
  `lang-pack-drift` push-to-`main` gate going red the moment it lands, per
  this pipeline's "the lane that merges the core change owns the implied
  pack follow-up" rule).
- **Repo:** `ut-plugin-language-de`
- **Reviewer:** same session, immediately after writing the translations —
  ran the repo's own guards live against a local checkout of core's
  `fix/1832-voucher-ui` branch (which already carries the 19 new keys)
  rather than the published `main` (which doesn't have them yet).

## What shipped

19 new keys in `locales/de.json`, inserted next to their nearest existing
sibling (alphabetical/semantic grouping this file already follows in each
region — `receipt.*`, `tender.issue_voucher.*`, `tender.status.voucher_*`,
`tender.voucher_*`, `pos.toast.voucher_*`):

```
receipt.vouchers.issued              -> Ausgestellte Gutscheine
tender.issue_voucher.add             -> Gutschein hinzufügen
tender.issue_voucher.amount          -> Gutscheinbetrag
tender.issue_voucher.auto_code       -> Code wird beim Abschluss erzeugt
tender.issue_voucher.code            -> Code
tender.issue_voucher.code_placeholder-> Leer = wird beim Abschluss erzeugt
tender.issue_voucher.hint            -> Der Gutscheinwert wird dem Betrag des Kunden hinzugefügt.
tender.issue_voucher.holder_label    -> Für (optional)
tender.issue_voucher.no_pending      -> Noch keine Gutscheine zum Verkauf.
tender.issue_voucher.title           -> Gutschein verkaufen
tender.status.voucher_added          -> %s-Gutschein zu diesem Verkauf hinzugefügt.
tender.status.voucher_balance        -> Gutschein-Guthaben: %s.
tender.status.voucher_check_unavailable -> Gutschein-Guthaben konnte gerade nicht geprüft werden — die Zahlung kann trotzdem hinzugefügt werden.
tender.status.voucher_id_required    -> Gutscheincode eingeben.
tender.status.voucher_removed        -> Offenen Gutschein entfernt.
tender.voucher_check                 -> Guthaben prüfen
tender.voucher_id                    -> Gutscheincode
tender.voucher_id_placeholder        -> Code auf der Karte
pos.toast.voucher_code_exists        -> Dieser Gutscheincode wird bereits verwendet — prüfen Sie den Code auf der Karte und versuchen Sie es erneut
```

Terminology/register matches this file's own established conventions for
the same feature area: "Gutschein" for voucher (already used throughout
`pos.toast.voucher_*`/`sync.quarantine_reason.*_voucher_*`/
`tender.pay_voucher`), imperative/infinitive style for buttons and status
lines (matches `tender.add_payment` "Zahlung hinzufügen",
`tender.status.removed` "Zahlung entfernt.", `tender.status.added`
"%s-Zahlung über %s hinzugefügt."), formal **Sie**-imperative for the one
longer toast (matches `pos.toast.voucher_overtender`'s existing "geben Sie
stattdessen..." pattern).

`tender.issue_voucher.code` is deliberately `"Code"`, byte-identical to
core's English string — same accepted German loanword already allowlisted
twice in this file for the identical reason (`designer.code`,
`promotions.col.code`, both plain "Code" labels). Added
`tender.issue_voucher.code` to `i18n-baseline/de.same-as-en.txt` in
alphabetical order (between `taxcodes.col.name` and
`tender.scan.barcode`) in the same change — leaving it un-allowlisted
would have failed `check-key-drift.sh`'s untranslated-but-present check.

No other new key is identical to English, and none needed a
`de.untranslated.txt` baseline entry (all 19 translated immediately, not
deferred debt).

`manifest.json` version left unchanged (`v1.1.31`) — release/tag is a
separate, later action, per this directory's own established precedent
(see `2026-09-08-close-lang-pack-drift-1723-...md`).

## Verified, live, not just read

- `bash scripts/validate.sh` — `ok com.universaltill.language-de v1.1.31 (de)`, exit 0.
- `UT_CORE_EN_JSON=<local universal-till checkout, branch
  fix/1832-voucher-ui> bash scripts/check-key-drift.sh` — after adding the
  allowlist entry: 0 new drift, 0 empty values, 0 untranslated-present, 0
  token mismatches on any of the 19 new keys. The only remaining findings
  are 6 **pre-existing, unrelated** orphan keys
  (`elevation.summary.allow_negative_inventory_{off,on}`,
  `import.status.stock_not_tracked`,
  `settings.stock_tracking.{hint,label,title}`) — not touched by this
  change, not caused by it (this local core checkout's `en.json` doesn't
  currently carry those keys; `main` has moved independently since, likely
  from a concurrent lane's own stock-tracking card). Left alone, out of
  scope for this PR — a separate lang-pack-drift follow-up if it's still
  live once `main` settles.
- `bash scripts/check-key-drift.test.sh` — all 21 fixture cases pass.
- Placeholder-token parity checked explicitly by the guard itself for
  every key sharing a `%s` (e.g. `tender.status.voucher_added`,
  `tender.status.voucher_balance`) — no dropped/reordered token.
- No real client/shop name, no secret-shaped literal.
- Git identity on the commit: `Farshid Mirza
  <4035824+farshidmirza@users.noreply.github.com>`.

## Update: CI red on the first push — unrelated concurrent drift, fixed here

The first CI run (against the live `main`, not this local checkout)
failed `key-drift` with 19 **different** missing keys — not these 19
voucher keys (expected: they're not in `main` yet, this PR predates
#937's merge) but 19 unrelated keys two other concurrent lanes' PRs had
just landed on `main` while this PR was in flight: `elevation.summary.
{keep,remove}_demo_item`, `orders.view.{title,refund_link}`, `pos.toast.
receipt_{not_completed,order_cancelled,read_error}`, and 12
`settings.data.demo_*` keys (ut-docs#1818 scan-to-collect routing,
ut-docs#1840 remove-sample-data). The earlier "6 orphan keys" noted
above as pre-existing/unrelated turned out to be the *same* underlying
churn — `main` caught back up to what this pack already had translated
by the time this fix landed, so those 6 are gone from the diff below;
0 orphans now, not 6.

Rather than leave the whole repo red (blocking every pack PR, not just
this one) or silently baseline them as debt, translated all 19 into
German — same terminology already established in this file
(`Beispielartikel` for sample item, `Bestellung`/`Beleg` for
order/receipt, `Retoure` for refund, formal **Sie** imperative matching
`settings.data.demo_confirm`'s existing style) — per this pipeline's own
precedent for exactly this situation
(`2026-09-08-close-lang-pack-drift-1723-...`'s sibling case, and more
directly `72b1e22`'s own commit message: "the rule is that the lane
merging a core change owns the implied pack follow-up... leaving the
repo red to make the point would only spread the block").

Re-verified against the now-current core checkout (branch
`fix/1832-voucher-ui`, merged up to `main`'s `ed8ca82a`):
**2120/2120 core keys translated, 0 drift, 0 orphans, 0 empty values, 0
untranslated-present, 0 token mismatches.** `scripts/validate.sh` and
`scripts/check-key-drift.test.sh` both green again.

## Verdict

**Safe to merge.** Fully guard-verified against the exact core branch
these keys are landing alongside, at full parity. Should land before (or
together with) `universal-till` PR #937 merging to `main`, so
`lang-pack-drift` doesn't go red on push.
