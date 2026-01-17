Overworld Menu - Changelog
# Version 2.0.0 (January 13, 2026) - UNRELEASED
---------------------------
[NEW]
- Added registration system for external mods to add submenus.
- Added priority system for menu ordering.
- Added auto-update Mod Settings registration.
- Added proper category (Interface) and searchable keywords for Mod Settings.
- Added OverworldMenuSettingsScene using modern PokemonOption_Scene pattern.
- Added page assignment options for all registered submenus in settings.
- Added Mod Settings submenu button to Overworld Menu at priority 100.
- Added comprehensive debug logging with "OverworldMenu:" prefix.
- Added automatic party view and weather box hiding when dialog boxes appear.
- Added error wrapping for all handler executions with detailed logging.

[CHANGED]
- Complete framework rewrite for standalone modular architecture.
- Framework now contains only Time submenu as built-in.
- Migrated OVM Settings from in-menu to dedicated Mod Settings menu.
- Settings now accessible via dedicated Mod Settings menu with proper transitions.
- All debug logs write to ModsDebug.

[REMOVED]
- Removed DexNav Repeat functionality (moved to 11_DexNav.rb standalone mod).
- Removed all DexNav-specific integrations from framework.
- Removed mod-specific features.

# Version 1.0.0
---------------------------
[FEATURES]
- Initial Overworld Menu framework with party display and weather box.
- Built-in Time changer and OVM settings menu.
- DexNav integration and DexNav Repeat functionality.
