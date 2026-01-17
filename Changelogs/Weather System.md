Weather System - Changelog
# Version 2.0.0 (January 16, 2026) - UNRELEASED
---------------------------
[NEW]
- Added auto-update self-registration for Mod Settings.
- Added comprehensive searchable keywords covering all features.
- Modernized all menus to use PokemonOption_Scene pattern with Mod Settings color themes.
- Added helper classes: StoneSliderOption, SpacerOption, ModSettingsSpacing.

[CHANGED]
- Migrated to Mod Settings menu creation style.
- Converted all debug logging to ModsDebug log file.
- Updated registration to use Mod Settings registration.
- Modernized main menu and settings submenus to use PokemonOption_Scene with EnumOption, ButtonOption, and StoneSliderOption.
- Converted Change Weather menu to scene-based button selection.
- Converted Weather Types menu to scene-based toggle switches.
- Converted Sound Volume menus to scene-based sliders with live preview.
- Converted Weather Intensity menu to scene-based sliders with live preview.
- Converted Transition Graphics menu to scene-based toggles with test buttons.
- Retained legacy Window_CommandPokemonEx pattern for complex dynamic menus (map exclusions, season cycling).
