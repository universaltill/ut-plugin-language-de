# Review: window-mode note now says Windows applies immediately (ut-docs#610)

Date: 2026-10-06 · Lane: lane:local · Reviewed by: Claude Fable 5.1 (as part of the universal-till #610 review, `docs/code-reviews/2026-10-06-windows-fullscreen-autostart-610.md` there)

- `settings.display.window_mode_pending_note` was rewritten to match en.json. The Windows desktop shell now really applies fullscreen/kiosk (universal-till, ut-docs#610), and only macOS still keeps the window normal. The old text was also a vaguer rendering of the English.
- The reviewer checked the wording against en.json: the meaning is the same, the register matches the pack (Sie), and product names are unchanged.
- `manifest.json` version bumped so the release workflow cuts a pack release.
- Verdict: safe to merge.
