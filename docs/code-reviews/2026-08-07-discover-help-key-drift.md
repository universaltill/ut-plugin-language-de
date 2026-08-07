# Code review — restore de.json parity after core added `setup.join.discover_help` (ut-docs#375)

**Date:** 2026-08-07
**Card:** universaltill/ut-docs#375 (p3, `complexity:easy`)
**Branch:** `fix/375-setup-join-discover-help-de`
**Dev:** inline, Sonnet (easy-tier build model)
**Reviewer:** independent fresh-context subagent, Sonnet (easy-tier review
model — a clean-context instance that never saw the dev reasoning, per the
`scrum-master` skill's model routing for `complexity:easy`)

## Context

`universal-till`'s `web/locales/en.json` gained one new key,
`setup.join.discover_help`, as part of ut-docs#289 (LAN-discovery pairing
option on the setup wizard's join screen). This pack's `de.json` had
reached exact parity with core the day before (ut-docs#297, PR#3, merged
2026-08-07), so the one new core key immediately flipped
`check-key-drift.sh` red on `universal-till` main (surfaced as ut-docs#374
during a scrum-master PR sweep, then split out as this narrower card).

## What shipped

One key added to `locales/de.json`:

```
"setup.join.discover_help": "Oder finden Sie die Hauptkasse automatisch: Stellen Sie sicher, dass sie eingeschaltet und mit diesem Netzwerk verbunden ist, drücken Sie „Hauptkasse in diesem Netzwerk finden", wählen Sie sie aus der Liste aus und geben Sie dieser Kasse einen Namen. Beide Bildschirme zeigen dann denselben 6-stelligen Code — die Managerin oder der Manager der Hauptkasse vergleicht sie und bestätigt.",
```

Inserted in alphabetical order ahead of the existing `setup.join.help`.
Reuses this pack's own already-translated button label
(`tills.discovery.find_button` → "Hauptkasse in diesem Netzwerk finden")
verbatim inside the new string, so the help text names the button the
same way the button itself is labelled. No other file touched —
`i18n-baseline/de.untranslated.txt` and `i18n-baseline/de.same-as-en.txt`
correctly untouched, since this key was never listed in either (it went
straight from "doesn't exist in core" to "exists in core, translated same
day").

## What the independent review found

**No blockers.** Full independent re-run (diff scope, `validate.sh`,
`check-key-drift.sh` against a local core checkout, the drift-checker's
own 21-case test suite, a line-by-line completeness check of the German
translation against all six things the English source actually says,
register/tone consistency against neighboring `setup.join.*` keys, a
grammar proofread, and a check for stray placeholder tokens) all came back
clean. Two **non-blocking** style notes, left as-is:

- `"wählen Sie sie aus der Liste aus"` — adjacent "Sie sie" (formal "you"
  + "it") reads slightly clunky to a native ear but is grammatically
  correct and unambiguous.
- The antecedent of `vergleicht sie` ("compares them") is mildly ambiguous
  in the same way the English source's "compares them" is — the
  translation faithfully mirrors an ambiguity already present in core,
  not a new one it introduced.

## Verified beyond automated tests

- **Negative test (not a false-pass):** temporarily emptied the new key's
  value and confirmed both `check-key-drift.sh` and `validate.sh` fail
  loudly (`empty or whitespace-only value`), then restored the real
  translation and confirmed `git diff` returns to exactly the intended
  +1 line — the guard genuinely exercises this key rather than skipping
  it.
- **Core-parity check run against a real local checkout, not the network
  fetch**: `UT_CORE_EN_JSON` pointed at `universal-till/web/locales/en.json`,
  confirmed that checkout was at `origin/main` HEAD (`489faed3`) before
  trusting the result.
- `scripts/check-key-drift.test.sh` (the guard script's own unit suite):
  21/21 passing, unaffected by this content-only change.
- `scripts/validate.sh`: `ok com.universaltill.language-de v1.1.0 (de)`.
- `scripts/check-key-drift.sh`: `ok -- 1129/1129 core keys translated, 0
  known-untranslated (baseline), 44 known-same-as-English (allowlist), 0
  drift, 0 orphans, 0 empty values, 0 untranslated-present, 0 token
  mismatches`.
- No secrets, no real client/shop name, nothing suspicious in the diff.

## Not applicable to this change

This is a content-only i18n string addition to an asset-only plugin
(ADR-0010: runtime `none`) — no code, no markup, no CSS. No driven
browser/visual check was run: the new string surfaces in
`universal-till`'s setup wizard, a UI this plugin repo has no runnable
app to render on its own, and the change carries none of the layout risk
class (shared stylesheet, fixed-width control) that would make a visual
check load-bearing here. Noted rather than silently assumed covered.

## Verdict

Safe to merge as-is.
