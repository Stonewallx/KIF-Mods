Trainer Control - Changelog

# Version 2.0.0 (January 10, 2026)
---------------------------
[NEW]
- Added Auto-Update support via ModRegistry self-registration
- Added improved error handling.
- Added documentation to the discord for the mod.

[CHANGED]
- Improved menu for better look and more consistent behavior.
- Updated all debug logs to use consistent "TrainerControl:" prefix
- Updated version format to handle new registration.
- Migrated all sliders to StoneSliderOption for improved rendering and negative value support
- Changed debug messages from in-game popups to ModsDebug.txt logging

[REMOVED]
- Removed "Debug Messages" toggle from menu

---

# Version 1.3.0
---------------------------
[NEW]
- Initial public release with level scaling system
- Extra Pokemon addition system (Type Pool, Random, Random Fusion modes)
- Trainer adaptation system with counter-Pokemon learning
- Battle record tracking and display
- Progression rewards system (items + money after consecutive wins)
- Gym leader full party enforcement option
- Held items chance configuration for extra Pokemon
- No-duplicate extras option
- Debug messages toggle
- Trainer rematch level override system
- Alpha Pokemon integration for counter-Pokemon

[FEATURES]
- Level Scaling: Match trainer levels to your highest Pokemon with customizable offset (-10 to +20)
- Extra Pokemon: Add 1-5 additional Pokemon to trainer teams using various generation modes
- Team Adaptation: Trainers remember losses and add counter-type Pokemon on rematches
- Battle Records: Track win/loss records against individual trainers
- Progression Rewards: Earn items and money after every 10 consecutive wins
- Type Pools: Intelligent type-based Pokemon selection for extra additions
- Fusion Support: Generate random fusions as extra Pokemon
- Memory System: Persistent trainer data across save sessions
