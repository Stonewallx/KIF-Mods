Mod Settings - Changelog
# Version 3.2.4 (January 11, 2026)
---------------------------
[NEW]
- Added ZIP file extraction support for auto-update system using 7z.exe.
-- Graphics and mod files can now be distributed as ZIP archives for easier packaging.
- All ZIP extractions are now security validated before processing.
- ZIP files extract to base game directory automatically.
- Added zip extract information to the documentation.
- Added simple restart notification system: Shows "Mods updated! Restart Needed" in Mod List when updates complete and a restart has not been made.

[SECURITY]
- Allowed file types: .rb, .png, .gif, .jpg, .jpeg, .bmp, .wav, .ogg, .mp3, .mid, .txt, .md, .json, .yml, .rxdata, .rvdata, .rvdata2.
- Allowed extraction zones: Graphics/, Audio/, Mods/, Fonts/. 
- Files outside allowed zones or with unsafe extensions are automatically rejected and removed.

[FIXED]
- Fixed Auto-Update not properly proccing the update all message and not cleaning up the scene properly. - Not sure when I broke it tbh, my bad!
- Fixed dependency display showing empty dashes when mod requirements are missing.
- Dependency version requirements now show both required and installed versions when version mismatch occurs.

# Version 3.1.4 (January 10, 2026)
---------------------------
[NEW]
- Added StoneSliderOption class for improved slider support with negative value ranges
- Added automatic slider rendering with fixed 108px bar width and 10px right offset
- Added percentage-based tick positioning for accurate slider value visualization
- Added "Restart Game" button at bottom of Mod List for convenient restart after updates
- Added auto-restart functionality after auto-update completes: (disabled til all my mods guarantee work with it though)
  * If "Auto-Update Confirm" is ON: Asks "Restart now?" after successful updates
  * If "Auto-Update Confirm" is OFF: Auto-restarts immediately after showing success message

[CHANGED]
- Category headers now display collapse/expand indicators (+/-) on both sides for improved symmetry.
- Improved 3-option dropdown spacing: 50% tighter spacing with 65px left shift for better visual alignment
- Base game SliderOption now uses dynamic width (capped at 108px) for better compatibility

# Version 3.1.3 (January 9, 2026)
---------------------------
[CHANGED]
- Changed Auto-update system to now use self-registration blocks so that mod authors can put them in their mods without needing me. Also updated the documentation to reflect this. Version checks will still happen on mods that use ```# Script Version: X.Y.Z``` in headers of the mod files so that users can still show what version they have for troubleshooting, they will just not check for updates. 
- Updated all debug logging to include a prefix.

[FIXED]
- Fixed transition issue for menu/submenus.

# Version 3.1.2 (January 8, 2026)
---------------------------
[NEW]
- Added descriptions to several options that were missing them.

[CHANGED]
- Replaced use_blue_colors flag with use_color_theme flag so it's more appropriate for the behavior now. Updated documentation to reflect this change.

[FIXED]
- Fixed issue of submenu's not using the pbFadeOutIn blocks, which resulted in see through backgrounds and overlapping texts. 

# Version 3.1.1 (January 8, 2026)
---------------------------
[FIXED]
- Fixed issue where the Uncategorized category wasn't showing.

# Version 3.1.0 (January 8, 2026)
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

# Version 3.0.0 (January 8, 2026)
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