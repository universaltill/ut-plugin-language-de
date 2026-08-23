# lang-pack-drift red — 109 orphan help.feat./help.guide./help.features. keys — ut-docs#352

**Reviewer**: independent Sonnet subagent, fresh context (`complexity:easy`
— Sonnet built it, a fresh-context Sonnet instance reviewed it, per the
scrum-master skill's model routing exception for easy cards). One round.
**Branch**: `fix/352-drop-dead-help-keys` (base: `main`).
**Date**: 2026-08-23.

## What shipped

`lang-pack-drift` went red on `universal-till` `main` after merging
universal-till#459 (ut-docs#352), which removed 109 now-dead
`help.feat.*`/`help.features.*`/`help.guide.*` keys from
`web/locales/en.json` (kept `help.guide.title`/`help.guide.intro`, which
are still live). Core dropping keys this pack still carries turns them
into orphans — a key present in `locales/de.json` that core no longer has
at all, which `check-key-drift.sh` fails unconditionally, no baseline
exception.

`locales/de.json` had real German translations for all 109 dropped keys
(this is the inverse of the usual drift precedent, where core *adds* keys
a pack hasn't caught up on — here core *removed* keys the pack still had).
This PR removes the same 109 keys from `locales/de.json`, mirroring core
exactly, and prunes the one now-stale `i18n-baseline/de.same-as-en.txt`
entry (`help.feat.backups.title` — a key in the allowlist that no longer
exists at all is stale by definition, same failure mode as a translated
baseline entry).

A companion PR in `ut-plugin-language-es` carries the equivalent fix
(`i18n-baseline/es.untranslated.txt` prune only — `locales/es.json` never
had these keys, so there's nothing to remove there, just 109 stale
untranslated-baseline entries) — both are required before ut-docs#352 is
fully closed out; neither PR alone clears `lang-pack-drift` on
`universal-till`'s `main`, since the check evaluates both packs.

## Verified beyond automated tests

- `python3 -m json.tool locales/de.json` — valid JSON.
- `scripts/validate.sh` — `ok com.universaltill.language-de v1.1.10 (de)`.
- `scripts/check-key-drift.sh` — `ok -- 1510/1510 core keys translated, 0
  known-untranslated (baseline), 56 known-same-as-English (allowlist), 0
  drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
  mismatches`.
- `git diff main -- locales/de.json` — exactly 109 lines removed, nothing
  else touched; `help.guide.title`/`help.guide.intro` (still live in core)
  left untouched.
- `git diff main -- i18n-baseline/de.same-as-en.txt` — exactly 1 line
  removed (`help.feat.backups.title`), regenerated via
  `scripts/check-key-drift.sh --update-allowlist`, not hand-edited.
- No real client/shop name, no secret-shaped literal, anywhere in the
  diff.

## Independent review

Fresh-context Sonnet subagent, briefed with the diff scope, this repo's
`CLAUDE.md` (guard-script contract), and universal-till PR #459's actual
diff (the set of keys core removed). Told explicitly to run the guard
scripts itself rather than trust the PR's own claims, and to confirm
nothing beyond the 109 dead keys (plus the 1 stale allowlist entry) was
touched.

Findings:
- Re-ran `scripts/validate.sh` and `scripts/check-key-drift.sh`
  independently — clean.
- Confirmed the removed-key set in `locales/de.json` is byte-identical to
  the set core removed in universal-till#459 (same 109 key names, diffed
  against the PR).
- Confirmed `help.guide.title`/`help.guide.intro` — the two keys core
  deliberately kept — are present and unchanged in `locales/de.json`.
- Confirmed the `i18n-baseline/de.same-as-en.txt` prune is exactly the one
  entry the guard script itself flagged as stale, regenerated via the
  documented `--update-allowlist` command rather than a hand edit.
- Confirmed `i18n-baseline/de.untranslated.txt` is untouched — correct,
  since none of the 109 removed keys were listed there as known debt
  (they were all actually translated).

**None blocking. No non-blocking findings either.**

## Safe-to-merge verdict

**Yes.** Small, self-contained, mechanical diff; independently
re-verified guard-script results; mirrors core's removal exactly with no
collateral changes.
