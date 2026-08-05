# ut-plugin-language-de

German language pack for Universal Till (`canonical_type: "language"`,
ADR-0010). Ships `locales/de.json`; the till merges it as an overlay on
install — base strings always win on key conflict, so packs add locales but
cannot hijack core text. The nav language switcher picks up DE automatically.

**Coverage today: a growing subset of core's `web/locales/en.json` keys are
translated.** A key this pack doesn't yet cover falls back to English —
that fallback chain (`de → de → en → en`) is `I18n.T()` in core's
`internal/config/i18n.go`, not something ADR-0010 itself specifies — so
untranslated strings degrade gracefully rather than breaking the till, but
they're still a real gap. `i18n-baseline/de.untranslated.txt` is the
tracked baseline of that gap: every core key `de.json` doesn't yet
translate, one per line. `i18n-baseline/de.same-as-en.txt` is a second,
much shorter list: keys where `de.json`'s value is deliberately identical
to core's English string (proper nouns, brand names, words that are
genuinely the same in German). Neither file ships to customer tills —
`scripts/package.sh` only bundles `manifest.json`, `locales/`, and
`README.md` (see ADR-0010: a language pack ships `locales/<code>.json` and
nothing else; these are developer bookkeeping, not a shipped asset).

Both files are guarded by `scripts/check-key-drift.sh`, which compares
`locales/de.json` against core's base locale (fetched from the public
`universal-till` repo, or a local file via `UT_CORE_EN_JSON` for
offline/CI use) and fails loudly if:
- core has gained an untranslated key that isn't already in the baseline
  (new drift);
- a baseline entry has since been translated, or core dropped the key
  (stale — must be pruned);
- `de.json` has an orphan key core no longer has;
- a `de.json` value is empty or whitespace-only (core's `T()` renders it
  unconditionally, so an empty value is blank UI in production — worse
  than the English fallback a missing key would give you);
- a `de.json` value is byte-identical to core's English value and the key
  is NOT in the same-as-English allowlist (this is the literal
  ut-docs#292 bug: a key present with the verbatim, never-translated
  English string passes a key-set-only check);
- an allowlist entry is no longer identical to core, or its key no longer
  exists (stale — must be pruned).

Neither file can grow *silently* — new entries only land through a
deliberate, reviewed edit (`scripts/check-key-drift.sh --update-baseline` /
`--update-allowlist`, run and then reviewed like any other diff). That is
a different, weaker, and true claim than "only shrinks": the guard's own
documented escape hatch is adding an entry on purpose, which is not a
violation of it.

This is what should have caught ut-docs#292: core added 6 `pfand.*` keys,
this pack was never updated, and a German till silently rendered English
with no CI signal anywhere. CI runs this guard on every push/PR *and* on a
weekly schedule (`.github/workflows/ci.yml`, `key-drift` job), so drift
introduced purely by a core change (no push to this repo at all) still
surfaces — with the caveat that GitHub disables scheduled workflows on
public repos after 60 days of repo inactivity, so the cron is a
best-effort backstop, not a durable guarantee; it also has
`workflow_dispatch` for a manual/pipeline-triggered run. `release.yml`
runs the same guard before a tag can publish, so drift can't ship in a
new pack version either. `scripts/check-key-drift.test.sh` covers the
guard itself.

`scripts/validate.sh` (run by CI and by `package.sh`) additionally asserts
every value in every `locales/*.json` file is a non-empty string — core's
`internal/plugins/syncLocales` unmarshals each file into
`map[string]string` and, on parse error, logs and skips the **entire
file**, so a single non-string value would silently drop all German
translations on every till while CI stayed green if this didn't catch it
first.

Release: bump manifest version, tag `v<version>` → CI validates, checks
key drift, packages, publishes to the marketplace, auto-approves (dev).
