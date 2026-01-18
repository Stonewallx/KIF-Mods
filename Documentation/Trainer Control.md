# Trainer Control Documentation
**Script Version:** 2.0.0  
**Author:** Stonewall  
---

## Table of Contents
1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Level Scaling System](#level-scaling-system)
4. [Extra Pokemon System](#extra-pokemon-system)
5. [Trainer Adaptation System](#trainer-adaptation-system)
6. [Battle Records](#battle-records)
7. [Progression Rewards](#progression-rewards)
8. [Configuration](#configuration)
9. [Advanced Features](#advanced-features)
10. [Troubleshooting](#troubleshooting)

---

## Overview

**Trainer Control** is a comprehensive trainer battle enhancement mod for Pokemon Infinite Fusion that transforms trainer battles with dynamic difficulty scaling, adaptive AI, and progression systems.

### Core Features

**Level Scaling:**
- Automatically adjust trainer Pokemon levels to match your team
- Customizable level offsets from -10 to +20
- Eliminates over/under-leveling for consistent challenge

**Extra Pokemon:**
- Add 1-5 additional Pokemon to trainer teams
- Four generation modes: Off, Type Pool, Random, Random Fusion
- Intelligent type-matching for gym trainers
- Optional no-duplicate enforcement

**Trainer Adaptation:**
- Trainers remember your battle history and adapt their teams
- Add counter-type fusion Pokemon as you beat them repeatedly (1 per 4 wins)
- Progressive difficulty increase with player wins
- Optional Alpha Pokemon integration (3% chance)
- Gym leaders excluded from counter Pokemon adaptation

**Battle Records:**
- Track individual win/loss records against every trainer
- Display records at battle start
- Persistent across save sessions

**Progression Rewards:**
- Earn items + ₽30,000 after every 10 consecutive wins
- Randomized reward pool with competitive items

### Integration

- **Mod Settings**: Full submenu with modern UI
- **Auto-Update**: Automatic version checking and updates
- **Debug Logging**: Comprehensive error tracking with "TrainerControl:" prefix
- **Save Compatibility**: All data persists across sessions

---

## Quick Start

### Installation

1. Download `04_Trainer Control.rb`
2. Place in your `Mods` folder
3. Requires **Mod Settings 3.1.3+**
4. Launch game - mod auto-registers

### First Time Setup

1. Open **Mod Settings** from the options menu
2. Select **Trainer Control** submenu
3. Configure your preferred settings:
   - **Level Scaling**: Turn On if you want level matching
   - **Level Difference**: Set to 0 for exact match, positive for harder, negative for easier
   - **Extra Mode**: Choose how extra Pokemon are added
   - **Extra Pokemon Count**: Set how many extras (1-5)

---

## Level Scaling System

### How It Works

Level Scaling automatically adjusts all trainer Pokemon levels based on your team:

1. Finds your highest-level Pokemon
2. Adds the configured offset
3. Scales all trainer Pokemon to that level (minimum level 1)

### Configuration

**Level Scaling** (`On`/`Off`):
- Enables/disables the entire system
- Default: `Off`

**Level Difference** (`-10` to `+20`):
- **0**: Trainers match your highest Pokemon exactly
- **Positive** (e.g., +5): Trainers are 5 levels higher than your highest
- **Negative** (e.g., -3): Trainers are 3 levels lower than your highest

### Examples

**Your Team:**
- Charizard Level 45 (highest)
- Blastoise Level 42
- Venusaur Level 40

**Trainer Original Levels:**
- Pidgeot Level 28
- Fearow Level 30

**With Level Difference = 0:**
- Pidgeot → Level 45
- Fearow → Level 45

**With Level Difference = +5:**
- Pidgeot → Level 50
- Fearow → Level 50

**With Level Difference = -5:**
- Pidgeot → Level 40
- Fearow → Level 40

### Important Notes

- Only affects Pokemon **below** the target level (won't decrease levels)
- Applies to **all trainers** (route trainers, gym leaders, bosses)
- Works with rematch system
- Stats are automatically recalculated after level changes

---

## Extra Pokemon System

### Generation Modes

**Off (Mode 0):**
- No extra Pokemon added
- Vanilla trainer teams

**Type Pool (Mode 1):**
- Adds Pokemon matching trainer/gym type
- Uses intelligent species pools per trainer class
- Best for themed battles

**Random (Mode 2):**
- Adds completely random Pokemon
- Excludes legendaries
- Maximum variety

**Random Fusion (Mode 3):**
- Generates random fusion species
- Excludes legendary components
- Unique every time

### Configuration

**Extra Mode** (`Off`/`Trainer Pool`/`Random`/`Random Fusion`):
- Selects generation method
- Default: `Off`

**Extra Pokemon Count** (`1` to `5`):
- How many extra Pokemon to add
- Maximum party size is 6
- Default: `1`

**No-Dupe Extras** (`Yes`/`No`):
- If Yes: Prevents extra Pokemon from duplicating species already in party
- If No: Allows duplicates
- Default: `No`

**Extra Held Items** (`Off`/`50%`/`100%`):
- Chance for extra Pokemon to hold competitive items
- Items include: berries, choice items, orbs, etc.
- Default: `Off`

**Gym Leaders Full Party** (`Yes`/`No`):
- Forces all gym leaders to have exactly 6 Pokemon
- Adds extras until party reaches 6
- Works with Extra Pokemon Count setting
- Default: `No`

### Type Pool Details

Each trainer class has curated species pools:

**Bug Trainers:**
- Caterpie, Weedle, Metapod, Kakuna, Butterfree, Beedrill, Paras, Venonat, Scyther, Pinsir

**Bird Trainers:**
- Pidgey, Pidgeotto, Pidgeot, Spearow, Fearow, Doduo, Dodrio, Farfetch'd

**Fighting Trainers:**
- Mankey, Primeape, Machop, Machoke, Machamp, Hitmonlee, Hitmonchan, Poliwrath

**Gym Type Matching:**
- Automatically detects gym type
- Adds Pokemon with matching types
- Applies to all gym trainers, not just leaders

### Examples

**Route Trainer (Bug Catcher) - Type Pool Mode:**
- Original: Caterpie, Weedle
- Extra Count: 2
- Result: Adds 2 random bug-types (e.g., Kakuna, Metapod)

**Gym Leader (Fire Type) - Type Pool + Full Party:**
- Original: Growlithe (30), Vulpix (32), Arcanine (35)
- Extra Count: 2, Full Party: Yes
- Result: Adds 3 fire-types to reach 6 total

**Route Trainer - Random Fusion Mode:**
- Original: Pidgey (12)
- Extra Count: 1
- Result: Adds 1 random fusion (e.g., Charizard/Blastoise fusion)

---

## Trainer Adaptation System

### How It Works

Trainers **remember** battles against you and adapt their teams:

1. **Record Battle Result**: Win/loss tracked per trainer
2. **Your Wins Trigger Counter Pokemon**: As you beat them repeatedly, they add counters
3. **Counter Pokemon Added**: Fusion Pokemon with type advantage against your team
4. **Progressive Scaling**: More player wins = more counters (1 counter per 4 wins)
5. **Move/Item/Nature Adaptation**: After winning, trainers also adapt their strategies

### Counter Pokemon Logic

**Type Advantage Calculation:**
- Analyzes your most-used Pokemon types from battle records
- Selects fusion Pokemon with types that counter your common types
- Adds moves that are super-effective against your team

**Counter Addition Rules:**
- **Formula**: `Counters = Player Wins ÷ 4` (integer division)
- 4 player wins: Trainer gets 1 counter Pokemon
- 8 player wins: Trainer gets 2 counter Pokemon
- 12 player wins: Trainer gets 3 counter Pokemon
- 16 player wins: Trainer gets 4 counter Pokemon
- Continues adding 1 counter per 4 wins (max 6 party size)
- **Important**: Not limited by Extra Pokemon Count setting
- **Gym Leaders Excluded**: Gym leaders do NOT receive counter Pokemon

**Alpha Integration:**
- Counter Pokemon have 3% chance to be Alpha (if AlphaHordes/Raids mod installed)
- Alpha Pokemon have boosted stats and special aura

### Configuration

**Team Adaptation** (`Yes`/`No`):
- Enables/disables entire adaptation system
- Default: `Yes`

**Battle Record Display** (`Yes`/`No`):
- Shows battle record message at battle start
- Default: `Yes`

### Example Scenario

**Your Team:**
- Charizard (Fire/Flying)
- Blastoise (Water)
- Venusaur (Grass/Poison)

**Trainer Original Team:**
- Pidgey (Level 15)
- Rattata (Level 16)

**Battle 1, 2, 3:** You win (Record: 3W - 0L)
- No counter Pokemon yet (need 4 wins)
- Trainer adapts moves/items/natures each rematch

**Battle 4:** You win (Record: 4W - 0L)

**Next Rematch:**
- Counter Pokemon threshold reached! (4 ÷ 4 = 1)
- Trainer adds 1 counter fusion
- Detects your Fire/Water/Grass types
- Adds Rock/Electric fusion (e.g., Geodude/Graveler fusion)
- New Team: Pidgey, Rattata, Geodude/Graveler fusion

**Battle 5, 6, 7:** You win (Record: 7W - 0L)
- Still 1 counter (7 ÷ 4 = 1)

**Battle 8:** You win (Record: 8W - 0L)

**Next Rematch:**
- Second counter Pokemon added! (8 ÷ 4 = 2)
- Adds another type-advantage fusion
- New Team: Pidgey, Rattata, Counter 1, Counter 2

### Important Notes

- Counters are **permanent** once added (persist across saves)
- **Gym Leaders do NOT get counter Pokemon** (excluded from adaptation)
- Different trainers track separately
- Works with both named trainers and generic trainers
- Counter Pokemon follow same level scaling rules
- Alpha chance only applies if AlphaHordes/Raids mod present
- Counter Pokemon are **fusion Pokemon**, not regular species
- Counter additions are NOT limited by Extra Pokemon Count setting

---

## Battle Records

### Tracking System

Every trainer battle is recorded:
- **Wins**: Battles where you won (player perspective)
- **Losses**: Battles where you lost or fled (player perspective)
- **Format**: "Battle Record: XW - YL" where X = your wins, Y = your losses

### Display

**At Battle Start:**
```
Battle Record: 3W - 1L
```

Shows before battle begins (if Battle Record Display = Yes)

### Configuration

**Battle Record Display** (`Yes`/`No`):
- Shows/hides record message
- Records are always tracked, only display is toggled
- Default: `Yes`

### Storage

- Records stored in `$PokemonGlobal.trainer_memory`
- Persists across save sessions
- Never resets (cumulative)

---

## Progression Rewards

### How It Works

Earn rewards for **consecutive trainer victories**:

1. Win trainer battles (any trainer counts)
2. Every **10 consecutive wins**: Receive reward
3. **Lose once**: Win streak resets to 0

### Reward Structure

**Item Reward:**
- Random item from reward pool
- Quantity varies by item (1-10 depending on item)
- Common items: More frequent
- Rare items: Less frequent (Master Ball, Ability Capsule)

**Money Reward:**
- Flat **₽30,000** bonus
- Awarded alongside item reward

### Reward Pool

**Consumables:**
- Rare Candy (2-4)
- PP Up (1-3), PP Max (1-2)
- Elixir (1-3), Max Elixir (1-2)
- Ether (1-3), Max Ether (1-2)
- Super Potion (2-7), Hyper Potion (2-3)
- Full Heal (2-4)

**Competitive Items:**
- Choice Band, Choice Scarf, Choice Specs
- Life Orb, Focus Sash, Leftovers
- Assault Vest, Weakness Policy
- Ability Capsule

**Poke Balls:**
- Fusion Ball (3-10)
- Ultra Ball (3-10)

**Valuables:**
- Nugget (2-4)
- Big Nugget (1-3)
- Heart Scale (3-5)

**Rare:**
- Master Ball (1) - Low probability

### Configuration

**Trainer Rewards** (`Yes`/`No`):
- Enables/disables reward system
- Default: `Yes`

**Reward Frequency:**
- Hardcoded to 10 wins (editable in Config::WINS_FOR_REWARD)

### Examples

**Win Streak:**
```
Wins: 9 → Battle → Win → 10 wins reached!
Message: "You've proven yourself worthy!"
Message: "As a token of respect, take 3 Rare Candies!"
Message: "You also receive ₽30,000!"
New Streak: 0 (resets after reward)
```

**Loss Breaks Streak:**
```
Wins: 7 → Battle → Lose → Streak Reset
Wins: 0 (start over)
```

---

## Configuration

### In-Game Settings

All settings accessible via **Mod Settings → Trainer Control** submenu:

**Level Scaling System:**
- Level Scaling: On/Off
- Level Difference: -10 to +20 (slider)

**Extra Pokemon System:**
- Extra Mode: Off/Trainer Pool/Random/Random Fusion
- Extra Pokemon Count: 1-5 (slider)
- No-Dupe Extras: Yes/No
- Extra Held Items: Off/50%/100%
- Gym Leaders Full Party: Yes/No

**Adaptation & Records:**
- Battle Record Display: Yes/No
- Team Adaptation: Yes/No

**Rewards & Debug:**
- Trainer Rewards: Yes/No
- Debug Messages: Off/On

### File Configuration

Advanced users can edit `TrainerControl::Config` module:

**Location:** Lines 11-77 in `04_Trainer Control.rb`

**Key Constants:**
```ruby
LEVEL_SCALING_DEFAULT = false          # Default on/off
DEFAULT_LEVEL_OFFSET = 0               # Default offset
EXTRA_POKEMON_DEFAULT_MODE = 0         # Default mode (0-3)
EXTRA_POKEMON_DEFAULT_COUNT = 1        # Default count
MAX_PARTY_SIZE = 6                     # Max Pokemon per trainer
GYM_LEADER_FULL_PARTY_DEFAULT = false  # Gym leaders full party default
TEAM_ADAPTATION_DEFAULT = true         # Adaptation default
BATTLE_RECORD_DISPLAY_DEFAULT = true   # Record display default
PROGRESSION_REWARDS_DEFAULT = true     # Rewards default
WINS_FOR_REWARD = 10                   # Wins needed for reward
ALPHA_COUNTER_POKEMON_CHANCE = 3       # Alpha counter chance (%)
DEBUG_MESSAGES_DEFAULT = false         # Debug messages default
PROGRESSION_MONEY_REWARD = 30000       # Money per reward
```

**Reward Pool:**
- Edit `PROGRESSION_REWARD_POOL` array (lines 48-76)
- Format: `:ITEMSYMBOL` or `[:ITEMSYMBOL, qty]` or `[:ITEMSYMBOL, min, max]`

---

## Advanced Features

### Type Caching System

**Purpose:** Optimizes Pokemon lookup by type

**How It Works:**
- Builds cache of all Pokemon by type on first use
- Separate caches for regular Pokemon and fusions
- Reused for all subsequent lookups

**Benefits:**
- Fast type-pool selection
- Efficient gym type matching
- Reduced lag during trainer battles

**Debug Logging:**
- "TrainerControl: Type cache initialized"
- "TrainerControl: Fusion cache initialized"

### Fusion Generation

**Random Fusion Mode:**
- Generates fusions by combining two random species
- Formula: `fusion_id = (body_id * NB_POKEMON) + head_id`
- Validates type matching for gym trainers
- Excludes legendary components

**Type-Matched Fusions:**
- For gym trainers, only adds fusions with matching type
- Checks both head and body species
- Falls back to regular type pool if fusion pool empty

### Memory Persistence

**Stored Data:**
```ruby
$PokemonGlobal.trainer_memory = {
  "COOLTRAINER_Jake" => {
    wins: 3,
    losses: 1,
    counters_added: 1,
    last_battle_won: true
  }
}
```

**Trainer Identification:**
- Format: "TRAINERTYPE_Name"
- Example: "BUGCATCHER_Sammy", "LEADER_Brock"

**Save File Integration:**
- Automatically serialized with save data
- No manual save needed
- Works with all save slots

### Error Handling

**Level Adjustment:**
- Catches level assignment failures
- Falls back to EXP-based leveling
- Logs errors to ModsDebug.txt

**Cache Operations:**
- Handles missing Pokemon data gracefully
- Logs initialization errors
- Continues operation even if cache fails

**Counter Addition:**
- Validates party size before adding
- Handles fusion generation failures
- Logs each counter addition

### Debug Mode

**Enable:** Set Debug Messages to `On`

**Shows In-Game Messages:**
- Level scaling details (target level, adjusted count)
- Type cache initialization
- Counter Pokemon addition
- Battle record updates
- Reward grants

**Log File:** `[SaveFolder]\ModsDebug.txt`
- All operations logged with "TrainerControl:" prefix
- Includes error messages with stack traces

---

## Troubleshooting

### Level Scaling Not Working

**Problem:** Trainer levels not changing

**Solutions:**
1. Verify Level Scaling is set to `On`
2. Check your highest Pokemon level (must be > 0)
3. Trainer Pokemon already at/above target level won't scale down
4. Check ModsDebug.txt for "TrainerControl: Adjusted X Pokemon levels" messages

### Extra Pokemon Not Appearing

**Problem:** Trainers don't have extra Pokemon

**Solutions:**
1. Verify Extra Mode is not set to `Off`
2. Check Extra Pokemon Count is > 0
3. Trainer already at max party size (6) - can't add more
4. For Gym Leaders Full Party: Must be enabled separately

### Counters Not Being Added

**Problem:** Trainers don't adapt with counter Pokemon

**Solutions:**
1. Verify Team Adaptation is set to `Yes`
2. You must **win** against the trainer 4+ times (not lose)
3. Counter addition formula: `Wins ÷ 4` (e.g., 4 wins = 1 counter, 8 wins = 2 counters)
4. Gym Leaders are EXCLUDED - they never get counter Pokemon
5. Check ModsDebug.txt for "TrainerMemory: Added counter fusion" messages
6. Trainer party must have room (max 6 Pokemon)
7. Counter Pokemon are independent of Extra Pokemon Count setting

### Rewards Not Granted

**Problem:** No reward after 10 wins

**Solutions:**
1. Verify Trainer Rewards is set to `Yes`
2. Must be exactly 10 **consecutive** wins
3. Any loss resets streak to 0
4. Wild Pokemon battles don't count
5. Check for "You've proven yourself worthy!" message

### Battle Records Not Showing

**Problem:** No record message at battle start

**Solutions:**
1. Verify Battle Record Display is set to `Yes`
2. Records are always tracked, only display is toggled
3. First battle against trainer won't show record (no history yet)

### Menu Not Appearing

**Problem:** Trainer Control option missing in Mod Settings

**Solutions:**
1. Verify Mod Settings 3.1.3+ is installed
2. Check file is in Mods folder and named `04_Trainer Control.rb`
3. Restart game after adding mod
4. Check errorlog.txt for script errors

### Duplicate Species in Party

**Problem:** Extra Pokemon are duplicating species

**Solutions:**
1. Enable No-Dupe Extras setting
2. If Type Pool mode: Limited species in pool may cause duplicates
3. Try Random or Random Fusion mode for more variety

### Debug Messages Too Frequent

**Problem:** Too many debug popup messages

**Solutions:**
1. Set Debug Messages to `Off`
2. Debug logs still written to ModsDebug.txt
3. Use log file for troubleshooting instead

### Alpha Counter Pokemon Not Appearing

**Problem:** Counter Pokemon never Alpha

**Solutions:**
1. Requires AlphaHordes or Raids mod to be installed
2. Only 3% chance - very rare
3. Check if AlphaHordes/Raids mod is active

### Cache Initialization Errors

**Problem:** Errors in ModsDebug.txt about cache initialization

**Solutions:**
1. Usually non-fatal - mod continues working
2. May indicate corrupted Pokemon data
3. Try restarting game
4. Check if other mods are conflicting with Pokemon data

---

**Need More Help?**

- Check `ModsDebug.txt` for detailed error messages with prefix `TrainerControl:`
- Review the changelog for recent changes
- Verify you're using version 2.0.0
- Ensure Mod Settings 3.1.3+ is installed
- Check compatibility with other trainer-modifying mods
