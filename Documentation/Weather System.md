# Weather System
**Script Version:** 2.0.0  
**Author:** Stonewall  
**Category:** Major Systems

---

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Weather Patterns](#weather-patterns)
6. [Configuration](#configuration)

---

## Overview
The Weather System adds dynamic, time-based weather changes to outdoor maps with realistic transition patterns and seasonal variations. Weather evolves naturally based on configured intervals, creating an immersive atmosphere that responds to in-game time and seasons.

---

## Features

### Core Weather System
- **Dynamic Weather Changes**: Weather automatically changes every 3 hours (configurable)
- **Two Weather Modes**:
  - **Real Weather**: Uses realistic transition patterns (sunny → rain → storm)
  - **Random Weather**: Randomly selects from enabled weather types
- **Indoor Detection**: Automatically disables weather in buildings, caves, and indoor areas
- **Battle Weather Sync**: Optional synchronization of overworld weather to battle conditions
- **Map Persistence**: Weather persists across map changes and maintains cycle timing

### Weather Types
9 distinct weather types available:
- **None** - Clear skies
- **Sunny** - Bright sunshine
- **Rain** - Light rainfall
- **Storm** - Heavy rain with thunder
- **HeavyRain** - Intense downpour
- **Snow** - Gentle snowfall
- **Blizzard** - Heavy snow and wind
- **Sandstorm** - Dust and sand
- **Fog** - Low visibility

### Seasonal System
- **Automatic Seasons**: Seasons progress naturally based on in-game time
- **Manual Override**: Lock to a specific season for testing or aesthetic preference
- **Season Duration**: 7 in-game days per season (configurable)
- **Seasonal Weather Patterns**: Each season has unique weather probabilities
  - **Spring**: Rainy with fog, occasional storms
  - **Summer**: Hot and sunny, occasional storms
  - **Fall**: Variable weather, transition season
  - **Winter**: Cold with snow and blizzards

### Visual & Audio Features
- **Weather Intensity**: Adjustable particle density (0-150%)
- **Weather Sounds**: Ambient background sounds for each weather type
- **Thunder Effects**: Random thunder sounds during storms (no visual flashes)
- **Volume Controls**: Independent volume for weather sounds (0-100%) and thunder (0-150%)
- **Transition Graphics**: Optional fullscreen graphics when time of day or season changes
  - Morning, Afternoon, Evening, Night transitions
  - Spring, Summer, Autumn, Winter transitions
  - Configurable fade in/hold/fade out timing

### Advanced Configuration
- **Per-Weather Toggles**: Enable/disable individual weather types
- **Map Exclusions**: Exclude specific weather types from specific maps
- **Intensity Customization**: Per-weather visual intensity adjustment
- **Volume Customization**: Per-weather sound volume adjustment
- **Realistic Patterns**: Weighted probability transitions for natural weather flow

---

## Installation

1. Download `12_Weather System.rar`

2. Extract the rar file to your game's root directory
   - The rar contains the full folder structure
   - Files will automatically place in correct locations

3. Launch game - Weather System will auto-register with Mod Settings

---

## Usage

### Main Menu Options
- **Weather System**: Enable/Disable the entire system
- **Real Weather**: Toggle between realistic patterns and random weather
- **Seasons**: Enable/Disable seasonal weather variations
- **Battle Weather Sync**: Sync overworld weather to battles
- **Transitions**: Enable/Disable time/season transition graphics

### Submenus

#### Change Weather
Manually set current weather to any type instantly. Useful for:
- Testing weather effects
- Taking screenshots
- Creating specific atmospheric conditions

#### Season Control
- **Current Season**: View/select season (Spring, Summer, Fall, Winter)
  - Switch to Manual mode first to apply.
- **Season Mode**: Toggle between Auto (time-based) and Manual (fixed)
  - Auto: Seasons progress every 7 in-game days
  - Manual: Season stays fixed until changed

#### Check Status
View comprehensive weather system status:
- Current weather and mode
- Time until next weather change
- Season information (if enabled)
- Map compatibility status
- Enabled weather type count

#### Sound Volume
Adjust ambient sound volume for each weather type (0-100%):
- Changes apply immediately to current weather
- Rain, Storm, HeavyRain, Snow, Blizzard, Sandstorm, Fog

#### Thunder Volume
Adjust thunder sound effect volume (0-150%):
- Only affects Storm weather
- Includes test button to preview volume

#### Weather Intensity
Adjust visual particle density (0-150%):
- Changes apply immediately to current weather
- Affects: None, Rain, Storm, Snow, HeavyRain
- Types with binary effects (Blizzard, Sandstorm, Sunny, Fog) not adjustable

#### Enabled Weather Types
Toggle which weather types can appear during random/pattern changes:
- Disabling a type prevents it from occurring naturally
- Manually set weather always works regardless of enabled state

#### Transition Graphics
Configure time and season transition graphics:
- Enable/disable each time period transition (Morning, Afternoon, Evening, Night)
- Enable/disable each season transition (Spring, Summer, Autumn, Winter)
- Transitions show fullscreen graphic with fade in/hold/fade out animation

#### Map Exclusions
Control weather behavior on specific maps:
- **Add/Edit Current Map**: Set which weather types are allowed/excluded for current map
- **View/Clear All Exclusions**: Browse exclusions by weather type, clear individual maps or all

---

## Weather Patterns

### Real Weather Mode
Uses weighted probability transitions for natural weather flow:

(Example)

**Clear → Sunny (25%) / Rain (15%) / Fog (5%)**  
**Sunny → Sunny (50%) / Clear (30%) / Sandstorm (10%)**  
**Rain → Storm (25%) / HeavyRain (15%) / Clear (15%)**  
**Storm → HeavyRain (40%) / Rain (30%) / Clear (10%)**  
**Snow → Blizzard (10%) / Clear (35%) / Fog (15%)**

### Seasonal Patterns
When seasons are enabled, weather patterns adjust:

**Spring**: Higher rain probability, frequent fog  
**Summer**: More sunny/sandstorm, occasional storms  
**Fall**: Balanced mix, introduction of snow  
**Winter**: Heavy snow/blizzard emphasis, reduced rain

### Battle Weather Sync
When enabled, overworld weather converts to battle weather:
- Rain/Storm/HeavyRain → Battle Rain
- Snow/Blizzard → Battle Hail  
- Sandstorm → Battle Sandstorm
- Sunny → Battle Sun
- Fog/None → No battle weather

---

## Configuration

### Default Settings
- **Weather System**: Enabled
- **Real Weather**: Enabled
- **Seasons**: Enabled (when 12a_Seasons.rb present)
- **Battle Sync**: Disabled
- **Time Interval**: 3 hours
- **Weather Intensity**: 100%
- **Weather Volume**: 30%
- **Thunder Volume**: 150%
- **Transitions**: Enabled
- **Season Duration**: 7 in-game days

### Advanced Customization
Edit constants in `12_Weather System.rb`:
```ruby
TIME_INTERVAL = 3  # Hours between weather changes
SEASON_DURATION_DAYS = 7  # Days per season (in 12a_Seasons.rb)
TRANSITION_FADE_IN_FRAMES = 60
TRANSITION_HOLD_FRAMES = 150
TRANSITION_FADE_OUT_FRAMES = 30
```