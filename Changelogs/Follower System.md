Follower System - Changelog
# Version 2.1.0 (January 18, 2026)
---------------------------
[NEW]
- Added Overworld Menu 2.0 integration with dedicated Follower submenu.
- Added Left Control key support to quickly toggle follower on/off.
- System now remembers last follower selection for quick toggle with Left Ctrl key.
- Added "Follower System" submenu in Mod Settings (Major Systems category).
- Added toggle setting to enable/disable Left Control key functionality.
- Added animated sprite preview windows when selecting Pokemon to follow.
- Added automatic party member cycling - if a Pokemon can't follow, system tries next party member automatically.
- Added detection for triple fusions and missing sprites with appropriate error messages.

[CHANGED]
- Follower management now exclusively through Overworld Menu and Left Ctrl key.
- Sprite variation changes now properly refresh follower display with put away/bring out sequence.

[REMOVED]
- Removed all Follower functionality from Party Screen menu.

[DEPENDENCIES]
- Added dependency: Overworld Menu v2.0.0

# Version 2.0.0 (January 11, 2026)
---------------------------
[NEW]
- Added Auto-Update Self-Registration with Mod Settings.

[CHANGED]
- Updated debug logging to use FollowerSystem prefix.

[FIXED]
- Fixed issue of Party View and Weather box showing on sprite variation selected message by removing message. Selected variation will now have +'s beside the name.

# Version 1.3.0
---------------------------
[FEATURES]
- Initial version with follower Pokemon system.
- Custom sprite support for fusions.
- Sprite variation selection.
- Party screen integration.
