# ut-plugin-language-de — rules

Language pack (ADR-0010): asset-only, runtime none, locales/de.json only.

Keep keys in sync with universal-till `web/locales/en.json`. This is
guarded by two mechanisms, not just JSON validity:

- `scripts/validate.sh` enforces JSON validity AND that every value in
  every `locales/*.json` file is a non-empty string (core's
  `internal/plugins/syncLocales` unmarshals into `map[string]string` and
  drops the WHOLE FILE on any non-string value, silently, so this must
  never regress).
- `scripts/check-key-drift.sh` enforces key parity against core's base
  locale plus real-value sanity: a key that's present but empty, or
  present but byte-identical to core's English string, is treated as
  untranslated (ut-docs#292 was exactly this — `"pfand.action": "Deposit
  refund"`, present and non-empty, passed a key-set-only check). It reads
  two files in `i18n-baseline/` (NOT `locales/` — that ships to
  customers; these are developer bookkeeping and must never be added to
  `scripts/package.sh`'s bundle):
  - `i18n-baseline/de.untranslated.txt` — every core key this pack
    doesn't yet translate, one per line, sorted.
  - `i18n-baseline/de.same-as-en.txt` — keys where `de.json`'s value is
    deliberately identical to core's English string (allowlist).
  Both are enforced the same way: an entry that's gone stale (translated
  since, or the key/identity no longer holds) FAILS CI so it gets pruned.
  **Landing a translation for a key that's in the baseline requires
  pruning that key from `i18n-baseline/de.untranslated.txt` in the same
  change** — leaving it there is a stale entry and the guard will fail.
  Regenerate either file with `scripts/check-key-drift.sh
  --update-baseline` / `--update-allowlist`, then review the diff like
  any other change — neither file may grow silently, only through a
  reviewed edit.

Never publish by hand — tag v<version>.
