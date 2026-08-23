# lang-pack-drift red — 5 missing keys (tracking.*, selforder.confirm.qr_caption) — ut-docs#910

**Reviewer**: independent Sonnet subagent, fresh context (`complexity:easy`
— Sonnet built it, a fresh-context Sonnet instance reviewed it, per the
scrum-master skill's model routing exception for easy cards). One round.
**Branch**: `fix/910-tracking-selforder-qr-keys` (base: `main`).
**Date**: 2026-08-23.

## What shipped

`lang-pack-drift` went red on `universal-till` `main` after merging
universal-till#457 (ut-docs#527, customer order tracking QR), which added
5 new core keys to `web/locales/en.json`:

- `selforder.confirm.qr_caption`
- `tracking.disclosure`
- `tracking.not_found`
- `tracking.title`
- `tracking.updated`

Both `ut-plugin-language-de` and `ut-plugin-language-es` were missing all
5. This is the standard follow-up pattern for this check — see closed
precedents #862, #891, #783, #612, #494, #374, #441, #579, #296.

This PR (`ut-plugin-language-de`) adds German translations for all 5 to
`locales/de.json`, matching the existing formal-`Sie` register used
elsewhere in the file. No `i18n-baseline/` edit needed — none of these
keys were previously listed as known debt in `de.untranslated.txt` (they
didn't exist in core before #457), so this is a pure addition, not a
baseline prune.

A companion PR in `ut-plugin-language-es`
(https://github.com/universaltill/ut-plugin-language-es/pull/70) carries
the matching Spanish translations — both are required before ut-docs#910
is fully done; neither PR alone closes it.

## Verified beyond automated tests

- `python3 -m json.tool locales/de.json` — valid JSON.
- `scripts/validate.sh` — `ok com.universaltill.language-de v1.1.10 (de)`.
- `scripts/check-key-drift.sh` — `ok -- 1619/1619 core keys translated, 0
  known-untranslated (baseline), 57 known-same-as-English (allowlist), 0
  drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
  mismatches`.
- `git diff main -- locales/de.json` — exactly 5 lines added, nothing
  else touched.
- `i18n-baseline/` unchanged (`git diff main -- i18n-baseline/` empty).
- No real client/shop name, no secret-shaped literal, anywhere in the
  diff.

## Independent review

Fresh-context Sonnet subagent, briefed with the diff scope, the repo's
own `CLAUDE.md` (guard-script contract), and the English source strings.
Told explicitly to run the guard scripts itself rather than trust the
PR's own claims, and to check translation quality (natural German, not
machine-literal), em-dash/punctuation convention, and cross-language
contamination (no German text landing in the Spanish pack or vice
versa).

Findings:
- Re-ran `scripts/validate.sh` and `scripts/check-key-drift.sh`
  independently, including once with `UT_CORE_EN_JSON` pointed at the
  local `universal-till` checkout instead of the network-fetched
  `raw.githubusercontent.com` copy — both ways, same clean result.
- Confirmed the diff is exactly 5 added lines, no reordering, no
  unrelated key changes.
- Confirmed translations are genuine, natural German, formal `Sie`
  register, consistent with neighboring strings (e.g.
  `help.feat.sell.s1`'s "Scannen Sie...").
- Confirmed correct em-dash usage matching source style.
- Confirmed `i18n-baseline/` untouched — correct, since these keys had
  no prior baseline entry to prune.

**None blocking. No non-blocking findings either.**

## Safe-to-merge verdict

**Yes.** Small, self-contained, minimal diff; independently re-verified
guard-script results; no drift, no orphans, no cross-language
contamination.
