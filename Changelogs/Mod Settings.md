Mod Settings - Changelog
Version 3.1.3 (January 9, 2026)
---------------------------
[CHANGED]
- Changed Auto-update system to now use self-registration blocks so that mod authors can put them in their mods without needing me. Also updated the documentation to reflect this. Version checks will still happen on mods that use ```# Script Version: X.Y.Z``` in headers of the mod files so that users can still show what version they have for troubleshooting, they will just not check for updates. 

[FIXED]
- Fixed transition issue for menu/submenus.

Version 3.1.2 (January 8, 2026)
---------------------------
[NEW]
- Added descriptions to several options that were missing them.

[CHANGED]
- Replaced use_blue_colors flag with use_color_theme flag so it's more appropriate for the behavior now. Updated documentation to reflect this change.

[FIXED]
- Fixed issue of submenu's not using the pbFadeOutIn blocks, which resulted in see through backgrounds and overlapping texts. 

Version 3.1.1 (January 8, 2026)
---------------------------
[FIXED]
- Fixed issue where the Uncategorized category wasn't showing.

Version 3.1.0 (January 8, 2026)
---------------------------
[NEW]
- Improved debug logging and will start to have all mods output debug logs to ModsDebug.txt. All mods will also show they loaded in that log file.
- Added support for Dropdown options to support multiple rows once above 3 options with automatic line spacing so there's no overlapping with other rows when using the proper flags.
- Added the Multiplayer Addons category.
[CHANGED]
- Updated the mod to use a simpler APIs for mod registrations so that it's easier for mod authors to register options into the menu.
- Added a comprehensive documentation to the discord to download for mod authors, contains working examples also.
- Changed the name of some of the categories so that they look cleaner and not so long for most.
- Cleaned up spacing and look of options in the Mod Settings Scenes, to make use of this, make sure to use the @modsettings_menu flag for submenu scenes.
- Cleaned up Update/Auto-update screens so that they're better to look at and quicker to see the information.

Version 3.0.0 (January 8, 2026)
---------------------------
[NEW]
- Initial support for the mod into the changelog/update system.
- Implemented a collapsible Category System to sort mods out better. Mods can register into the pre-defined categories made so they are more organized in the settings menu.
- Implemeted a Search/Filter system so you can find the settings you need faster. Press the Left Control button to search.
- Implemented a Preset system allowed you to save/load presets for the mod settings. You can also export/import presets.
- Implemented a Mod Settings Color toggle that will allow you to choose various colors for the settings.
- Implemented a Mod Update system that will allow you to check for mod updates without needing to go on the discord. You will still have to go to discord to download updates. Any that aren't tracked can be supported, just contact me.
- Implemented an Update Mod option for each mod if it's supported. - Select a mod in the Update Check Results screen for this option.
- Implemented a way to view the changelogs for each mod. - Select a mod in the Update Check Results screen for this option.
- Implements an Auto-Update feature that you can opt in to have it check for Mod Updates automatically on game load. 
- Mods have a Rollback feature so you can rollback to a backed up version of the mod you may have if an update isn't any good for you.
- Implemented a dependancy check so mods that require other mods will also download the required mods if confirmed.

[REMOVED]
- Removed Version Check from the mod. (Replaced by Mod Update check system.)