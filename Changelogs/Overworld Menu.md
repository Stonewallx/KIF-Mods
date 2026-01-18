Overworld Menu - Changelog
# Version 2.0.0 (January 17, 2026)
---------------------------
[NEW]
- Added registration system for external mods to add submenus.
- Added priority system for menu ordering.
- Added auto-update Mod Settings registration.
- Added proper category (Interface) and searchable keywords for Mod Settings.
- Added page assignment options for all registered submenus in settings.
- Added Mod Settings submenu button to Overworld Menu at priority 100.
- Added comprehensive debug logging with "OverworldMenu:" prefix to ModsDebug log file.
- Added automatic party view and weather box hiding when dialog boxes appear.

[CHANGED]
- Complete framework rewrite for standalone modular architecture.
- Framework now contains only Time submenu as built-in.
- Migrated OVM Settings from in-menu to dedicated Mod Settings menu.
- Settings now accessible via dedicated Mod Settings menu with proper transitions.

[REMOVED]
- Removed DexNav Repeat functionality (moved to 11_DexNav.rb standalone mod).
- Removed all DexNav-specific integrations from framework.
- Removed mod-specific built-in features besides Weather Box.