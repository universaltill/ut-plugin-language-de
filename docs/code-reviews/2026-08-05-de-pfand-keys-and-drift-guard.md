# 2026-08-05 — German `pfand.*` keys + ratcheting key-drift guard

Card: [ut-docs#292](https://github.com/universaltill/ut-docs/issues/292)
Branch: `fix/292-de-pfand-keys-and-drift-guard`

## What shipped

1. The 6 `pfand.*` keys in `locales/de.json` (`Pfandrückgabe`, `Betrag`,
   `Abbrechen`, `Auszahlen`, `Manager-PIN`) — 164 → 170 keys.
2. `scripts/check-key-drift.sh` — a ratcheting parity guard against core's
   `web/locales/en.json`, run on PR, on a weekly schedule, on
   `workflow_dispatch`, and in `release.yml`.
3. `scripts/check-key-drift.test.sh` — 14 self-tests.
4. `i18n-baseline/de.untranslated.txt` (917 keys) and
   `i18n-baseline/de.same-as-en.txt` (12 keys) — accepted-debt ledgers.
5. `validate.sh` now rejects a non-string locale value.
6. manifest 1.0.1 → 1.0.2; description corrected; README + CLAUDE.md updated.

## Why the bug happened

ADR-0010 makes a language pack an **overlay**, and core's `I18n.T()`
(`internal/config/i18n.go`) resolves `de → de → en → en`. A key the pack
lacks therefore renders English **silently** — graceful degradation that
doubles as a silent failure. Core shipped 6 new `pfand.*` keys via #288;
nothing obliged this repo to follow, and nothing detected that it hadn't.

## Verification

Driven run, real browser, throwaway till, the pack's real `de.json`
(sha256-verified identical to the working-tree file, not a fixture copy):

| pack seeded | button + dialog |
|---|---|
| pre-fix, from `git show HEAD:locales/de.json` | "Deposit refund" — bug reproduced |
| working tree (170 keys) | "Pfandrückgabe" + Betrag/Manager-PIN/Abbrechen/Auszahlen |

The pre-fix pass is the negative control: the same locator returns English
when the keys are absent, so the assertion is not a tautology.

Guard falsified against real failure modes, exit codes measured directly
(not through a pipe, which reports `tail`'s status and would mask a
print-but-exit-0 bug):

| injected defect | result |
|---|---|
| `pfand.action` deleted | exit 1, names the key |
| `pfand.action` = `"Deposit refund"` | exit 1, `untranslated-but-present` |
| `pfand.action` = `"   "` | exit 1, empty-value |
| `pfand.action` = a JSON object | `validate.sh` exit 1 |
| restored | exit 0 |

`scripts/package.sh` output confirmed to contain only `manifest.json`,
`locales/de.json`, `README.md`, `LICENSE`.

## Independent review (Opus, fresh context) — no blockers, 16 findings

Fixed in this branch:

- **Guard was key-presence-only.** It exited 0 with `"pfand.action":
  "Deposit refund"` in `de.json` — the literal symptom it exists to
  prevent. Re-verified personally before accepting. Now fails on empty
  values and on values byte-identical to core's English, with a 12-key
  allowlist for legitimately-identical strings (`app.name`, `status.online`…).
- **A non-string value passed both scripts** but makes core's
  `syncLocales` log and skip the **entire file** — one bad value would
  drop all 170 translations on every German till while CI stayed green.
  Now rejected in `validate.sh`, which is what `release.yml` runs.
- **The baseline was shipped in the signed bundle** (`package.sh` ships
  all of `locales/`). Moved to `i18n-baseline/`; ADR-0010 defines a
  language pack as shipping `locales/<code>.json`, and developer
  bookkeeping does not belong on a customer till.
- **Self-tests missed the "hard failure, never a skip" branches** —
  mutation testing showed curl-failure, core-parse-failure,
  de.json-parse-failure and baseline-read-failure could all be flipped to
  exit 0 and survive. 5 → 14 cases; assertions now check the failure
  *category*, not just the key name.
- **Overclaims replaced, not repeated.** The card is about an overclaiming
  description; the first draft swapped it for "the baseline can only get
  smaller", which the guard does not enforce (its own escape hatch is to
  add entries), and for a hardcoded "170 of 1087" that goes stale on
  core's next commit. Both reworded to what the code actually guarantees.
- CI split into `validate` + `key-drift` so a network failure cannot mask
  whether packaging was green; self-tests run first and `if: always()`;
  the resolved core commit SHA is printed for reproducibility; the guard
  added to `release.yml` so a tag cannot publish known drift.
- Documented regeneration command was broken and **failed open** (`comm`
  exits 0 with empty output, so `> baseline` would have truncated it to
  nothing). Replaced with `--update-baseline` / `--update-allowlist`.
- `CLAUDE.md` updated — it is what the next agent reads first; README's
  attribution of the fallback chain to ADR-0010 corrected to `I18n.T()`.

Found while fixing, by the new self-tests: a first-draft `EXIT INT TERM`
trap whose falsy test became the script's exit code, turning every
successful offline run into a false failure. Exactly what item 4 was for.

Deferred deliberately, with cards:

- **[#299]** GitHub disables scheduled workflows in public repos after 60
  days idle — so the weekly run, the *only* mechanism catching
  core-originated drift, decays to zero precisely when a quiet pack repo
  needs it. Only `workflow_dispatch` + honest wording shipped here; the
  real fix (move the check into always-active core CI) needs its own design.
- **[#297]** the remaining 917 untranslated keys. **[#296]** the Spanish
  pack, which has the identical 164-key gap.

## Not done

No e2e test was added to `universal-till` for language-pack rendering: it
would need a **copied** `de.json` fixture, which would pass even if this
pack regressed. The drift guard in this repo is the regression gate; the
rendering path is already covered by `faq.spec.ts` (plugin locale overlay)
and `rtl.spec.ts` (locale switching). Stated rather than left implied.
