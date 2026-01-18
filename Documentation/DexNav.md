# DexNav Documentation
**Script Version:** 1.0.0  
**Author:** Stonewall  

---

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [How to Use](#how-to-use)
5. [Bonus System](#bonus-system)
6. [Settings](#settings)
7. [Tips & Tricks](#tips--tricks)

---

## Overview
DexNav is an advanced wild encounter system that lets you search for specific Pokémon species on any map. Select your target from a visual menu, then encounter it with special bonuses based on your search level and chain count. The more you search for a species, the better your rewards become.

---

## Features

- **Species Selection Menu** - Visual UI showing all wild Pokémon available on current map
- **Search Levels** - Persistent level system that tracks encounters per species per map
- **Chain System** - Consecutive same-species encounters increase bonuses (breaks on loss/flee)
- **Improved Shiny Odds** - Higher shiny chance based on chain length (starts at chain 10+)
- **Perfect IVs** - Guaranteed 31 IVs in 1-4 stats based on search level
- **Hidden Abilities** - 5-60% chance for hidden ability based on search level
- **Egg Moves** - Encounter Pokémon with 1-4 egg moves already learned
- **Held Items** - 5-65% chance of held item based on search level
- **Multiple Encounter Types** - Walk, cave, surf, and fishing support
- **Visual Indicators** - Rustling grass, dust clouds, or water ripples mark encounter location
- **DN Repeat** - Quick option to search for the last selected species again
- **Information Display** - Shows types, hidden abilities, level, method, and chain info
- **Automatic Repel** - Blocks normal encounters while DexNav is active

---

## Installation

1. Download `11_DexNav.rb`

2. Place the `11_DexNav.rb` into your KIF/Mods folder.

3. Launch game - DexNav will auto-register with Mod Settings

---

## How to Use

### Opening DexNav

**From Overworld Menu:**
- Press your configured Overworld Menu button
- Select "DexNav" from the menu

### Selecting a Species

1. **Navigate the Menu**
   - **Arrow Keys** - Move between species icons
   - **Up/Down** - Switch between Water and Land sections
   - **R Button** - Switch pages (if more than 10 species)
   - **Z/X** - Confirm selection
   - **Back** - Cancel and close

2. **Species Information Panel**
   - Shows selected species' types, hidden ability, and encounter method
   - Displays your current search level for that species
   - Shows active chain count if chaining that species

3. **Confirm Selection**
   - Press Z/X on your chosen species
   - DexNav will activate for that species

### Finding the Encounter

**Walking/Cave Encounters:**
- A visual indicator appears on a nearby tile (rustling grass or dust cloud)
- Message displays: "Walk to it to encounter [Species]"
- Navigate to the marked tile
- Battle begins automatically when you reach it

**Surfing Encounters:**
- Water ripples appear on a nearby water tile
- Message displays: "Surf to them to encounter [Species]"
- Surf to the marked tile
- Battle begins when you reach it

**Fishing Encounters:**
- No visual indicator (immediate activation)
- Message displays: "[Species] is ready! Use your [Rod] to encounter it"
- Fish anywhere on the current map
- DexNav encounter triggers on next fishing attempt

### DN Repeat (Quick Search)

If enabled in settings:
- Opens Overworld Menu
- Select "DN Repeat"
- Instantly searches for the last species you selected
- Only works if that species is available on current map

---

## Bonus System

DexNav bonuses scale with two separate systems:

### Search Level Bonuses

Search level increases by 1 after every successful encounter (win or catch) with that species on that map. Never decreases.

**Perfect IVs:**
- Level 10-24: 1 perfect IV
- Level 25-49: 2 perfect IVs
- Level 50-74: 3 perfect IVs
- Level 75+: 4 perfect IVs

**Hidden Ability Chance:**
- Level 5-9: 5%
- Level 10-24: 10%
- Level 25-49: 20%
- Level 50-74: 35%
- Level 75+: 60%

**Egg Moves:**
- Level 10-24: 1 egg move
- Level 25-49: 2 egg moves
- Level 50-74: 3 egg moves
- Level 75+: 4 egg moves

**Held Item Chance:**
- Level 0-9: 5%
- Level 10-24: 10%
- Level 25-49: 20%
- Level 50-74: 40%
- Level 75+: 65%

### Chain Bonuses

Chain increases by 1 after each successful encounter with the same species on the same map. Resets if you flee, lose, switch species, or change maps.

**Shiny Chance Boost:**
- Chain 10-19: +1 bonus roll (each roll = 1/4096 chance)
- Chain 20-29: +2 bonus rolls
- Chain 30-39: +3 bonus rolls
- Chain 40-49: +4 bonus rolls
- Chain 50-59: +5 bonus rolls
- Chain 60-69: +6 bonus rolls
- Chain 70+: +7 bonus rolls (maximum)

**Example:** At chain 50, you get 5 additional shiny rolls on top of the base 1/4096 chance.

---

## Settings

Access via **Mod Settings → DexNav**:

**DexNav Messages**  
Toggle informational messages (rustling grass alerts, ready notifications)  
*Default: On*

**DexNav Repeat**  
Enable/disable the DN Repeat option in Overworld Menu  
*Default: Off*

**Clear DexNav Encounter**  
Button to manually clear active DexNav encounter and restore normal wild encounters  
*Use this if you get stuck with an active search*

---

## Tips & Tricks

**Efficient Chaining:**
- Stay on the same map
- Don't flee or lose battles
- Use strong Pokémon to ensure wins

**Search Level Management:**
- Search levels are tracked per species per map
- Moving to a different map resets progress for that species
- Focus on one area if you want to max out a species' bonuses

**DN Repeat Usage:**
- Great for chaining - quickly restart after each catch
- Enable in settings for fastest access
- Appears at top of Overworld Menu when enabled

**Fishing Strategy:**
- DexNav fishing doesn't require finding a specific tile
- Cast anywhere after activation

**Visual Indicator Range:**
- Walking/Cave: Appears 2-7 tiles away
- Surfing: Appears 2-7 tiles away on water