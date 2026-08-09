# 2026-08-09 — lang-pack-drift: orphan `plugins.marketplace.install_success` key

**Card:** universaltill/ut-docs#494
**Branch:** `fix/494-lang-pack-drift-orphan-key`

## What shipped

`locales/de.json` carried `"plugins.marketplace.install_success"`, a key
core (`universal-till/web/locales/en.json`) no longer defines — dropped in
`universal-till`#261 ("remove unverified legacy plugin install endpoints"),
which the commit itself notes as intentional ("Dropped the now-orphaned
`plugins.marketplace.install_success` locale key"). `check-key-drift.sh`
fails on any orphan key with no baseline exception (a pack has no business
inventing base keys core doesn't have), which is what took the
`lang-pack-drift` GitHub Actions check red on `universal-till` `main`.

Fix: delete the single orphan key from `locales/de.json`. One line
removed, nothing else touched.

## Independent review

Reviewed by a fresh-context Sonnet subagent (this is a `complexity:easy`
card — see the `scrum-master` skill's model-routing table), given the
exact diff, both repos' `CLAUDE.md`/`check-key-drift.sh` header contracts,
and told to actually run things, not just read the diff.

Verified by the reviewer, independently:
- `locales/de.json` still valid JSON; key count 1184 → 1183, exactly the
  one targeted key removed, nothing else disturbed.
- `UT_CORE_EN_JSON=<core's current en.json> scripts/check-key-drift.sh` →
  exit 0, `1183/1183 core keys translated, 0 drift, 0 orphans, 0 empty
  values, 0 untranslated-present, 0 token mismatches`.
- `scripts/validate.sh` → exit 0.
- `scripts/check-key-drift.test.sh` (21 subtests) → all pass, unmodified.
- Core's PR #261 genuinely dropped this key on purpose (checked
  `git show` on the commit) — not re-litigating that call, only bringing
  the pack back to parity with it, per the issue's own non-goals.
- `check-lang-pack-drift.sh`'s `PACKS` array lists only
  `ut-plugin-language-de` and `ut-plugin-language-es` — no other pack is
  known to core CI, so the acceptance criterion "no other pack has
  silently drifted" holds by construction.
- No secrets, no real client/shop name, no file-write/path-handling
  concern (pure data deletion in an already-tracked file).
- `web/help/` manual: N/A — this repo has no `web/help/` tree; this is
  developer-only i18n bookkeeping, nothing a shop owner sees or does.

**Findings: none.**

## Verdict

Safe to merge. Requires the matching `ut-plugin-language-es` fix
(`fix/494-lang-pack-drift-stale-baseline`) to also land before
`lang-pack-drift` is actually green on `universal-till` `main` — this
repo's half is necessary but not individually sufficient.
