# Review: import from another till system (de, ut-docs#4431)

**What:** the 43 keys core adds for the Import page's fourth option, *From another till system* (`import.welcome.system.*`, `import.system.*`): a shop connects an installed importer plugin, checks & previews, then imports products. `import.welcome.intro` is updated from "three ways" to "four ways". Terms follow the German help text (catalog.md): "Kassensystem", "Import-Plugin", "Prüfen & Vorschau", "Verbindungseinstellungen", "Erneut ausführen"; VAT is "MwSt.-Satz", stock "Bestand". The manifest version is bumped so it ships.

**Checked:** the translation is by Opus. `%s`/`%d` placeholders kept; `scripts/validate.sh` passes; `scripts/check-key-drift.sh` passes against the core branch's en.json (`UT_CORE_EN_JSON`): 3440/3440 keys, 0 drift, 0 orphans, 0 token mismatches. `import.system.col.name` ("Name") and `import.system.col.detail` ("Details") are the correct German and were added to `i18n-baseline/de.same-as-en.txt`, as `catalog.col.name` and `catalog.tab.details` already are.

Independent review (Sonnet): approved. One fix applied: `import.system.get_importer` now says "Import-Plugin" like every other string, not the anglicism "Importer"; the core German help quotes the same label and was changed with it.

**Verdict:** safe to merge once the universal-till change for ut-docs#4431 is on `main`.
