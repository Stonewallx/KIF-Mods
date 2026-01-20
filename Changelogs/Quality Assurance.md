Quality Assurance - Changelog
# Version 2.0.2 (January 19, 2026) - UNRELEASED
---------------------------
[FIXED]
- Fixed Super Candy Mode overlapping with Super Candy Level option by adding spacer

# Version 2.0.1 (January 18, 2026)
---------------------------
[FIXED]
- Fixed auto-update links. 

# Version 2.0.0 (January 17, 2026)
---------------------------
[NEW]
- Added auto-update registration with Mod Settings
- Added Overworld Menu registration at priority 40
- Added comprehensive debug logging with "QualityAssurance:" prefix throughout all operations
- Added Disobedience toggle: Disable obedience checks so Pokemon always obey commands regardless of level/badges (Credit to AnUnsocialPigeon)
- Added Upgraded PP toggle: Automatically maximizes PP upgrades for all party Pokemon moves to max level (ppup = 5)
- Added Infinite PP toggle: Continuously restores all party Pokemon moves to full PP

[CHANGED]
- Updated Mod Settings category to "Quality of Life" and includes searchable keywords
- Updated registration to use new streamlined API format
- Migrated to Mod Settings menu creation style

[FIXED]
- Fixed Super Candy Level NumberOption displaying value +1 higher than actual stored value

# Version 1.5 (Previous)
---------------------------
[FEATURES]
- **Auto Hook Fishing**: Automatically hooks fish without player input
- **Infinite Safari Steps**: Sets Safari Zone steps to 999999
- **Rematch Money**: Enables prize money from trainer rematches
- **No Move Auto-Teach**: Prevents automatic move learning on level-up
- **Move Teach Prompt**: Prompts before teaching TM/HM/Tutor moves
- **Infinite Repel**: Makes repel effect permanent when enabled
- **Infinite Money**: Keeps money at 999999 at all times
- **No Auto-Evolve**: Prompts before evolution instead of auto-evolving
- **Quick Rare Candy**: Speeds up Rare Candy usage animations
- **Instant Hatch**: Eggs hatch immediately upon receiving
- **Relearn Moves**: Access move relearner functionality
- **Egg Moves**: Enable/disable egg move learning
- **Level Locking**: Lock Pokemon levels to prevent over-leveling
- **Level Lock Manager**: Manage level locks per Pokemon
- **Super Candy**: Advanced leveling tool with multiple modes:
  - Level Cap mode: Levels to current level cap
  - Highest Level mode: Levels to highest party Pokemon level
  - Set Level mode: Levels to specific configured level (1-100)
- **Nature Selector**: Change Pokemon natures
- **Reset Money**: Reset money to 3000 and disable Infinite Money