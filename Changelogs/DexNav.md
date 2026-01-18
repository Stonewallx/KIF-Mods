DexNav System - Changelog
# Version 1.0.0 (January 17, 2026)
---------------------------
[FEATURES]
- Encounter Methods Supported:
  - Grass: Find rustling grass tiles 2-7 tiles away
  - Cave: Dust cloud animations on walkable terrain
  - Surf: Water ripple animations on surfable water tiles
  - Fishing
  
- Search Level System:
  - Progressive bonuses scaling with search level (max tier at level 75+)
  - Search level increments after successful encounters
  - Bonus calculations:
    - Perfect IVs: 0-4 (Lv10: 1 IV, Lv25: 2 IVs, Lv50: 3 IVs, Lv75+: 4 IVs)
    - Hidden Ability: 0-60% (Lv5: 5%, Lv10: 10%, Lv25: 20%, Lv50: 35%, Lv75+: 60%)
    - Egg Moves: 0-4 (Lv10: 1, Lv25: 2, Lv50: 3, Lv75+: 4)
    - Held Items: 5-65% (Base: 5%, Lv10: 10%, Lv25: 20%, Lv50: 40%, Lv75+: 65%)

- Chain System:
  - Increases shiny chance (1 extra roll per 10 chain, max 7 bonus rolls at chain 70+)
  - Chain breaks if different species selected or map changes
  - Chain persists across encounters of same species on same map

- Encounter Detection:
  - Supports time/weather/season variations
  - Proper terrain detection (grass, water, fishing, cave walkable tiles)

- Repel System Integration:
  - Automatically stores and restores player's original Repel count
  - Sets Repel to 99999 steps while DexNav is active
  - Restores original Repel count after encounter completes or is cleared
  - Prevents normal encounters while DexNav search is active

- DexNav Repeat Feature:
  - Quickly repeat last species search.
  - Remembers last species, method.
  - Can be toggled in settings

- Integration:
  - Registered into Overworld Menu (priority 10)
  - DexNav Repeat in Overworld Menu (priority 1, toggleable)
  - Registered into Mod Settings as "DexNav" button in Encounters category
  - "Clear DexNav Encounter" button in settings menu allows canceling active searches
  - Settings include toggles for messages and DexNav Repeat feature