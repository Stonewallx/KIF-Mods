# Mod Settings Menu Documentation
**Script Version:** 3.3.4
**Author:** Stonewall
---

## Table of Contents
1. [Quick Start](#quick-start)
2. [Categories](#categories)
3. [Registration Methods](#registration-methods)
4. [Setting Types](#setting-types)
5. [Working Examples](#working-examples)
6. [Developer Features](#developer-features)
7. [Advanced Features](#advanced-features)
8. [Accessing Values](#accessing-values)
9. [Testing](#testing)
10. [Update & Auto-Update Support](#update--auto-update-support)
11. [Debug Logging](#debug-logging)
12. [Troubleshooting](#troubleshooting)

---

## Quick Start

The Mod Settings Menu provides a centralized system for mods to register their configuration options. Settings automatically persist across game sessions and appear in a unified menu accessible from Options.

### Basic Example
```ruby
ModSettingsMenu.register(:my_feature_enabled, {
  name: "Enable My Feature",
  type: :toggle,
  description: "Turns my awesome feature on or off",
  default: 0,
  category: "Quality of Life"
})
```

### Using the Value
```ruby
if ModSettingsMenu.get(:my_feature_enabled) == 1
  # Feature is enabled
end
```

---

## Categories

Settings are organized into predefined categories for easy navigation. If no category is specified (or left blank), settings automatically default to **"Uncategorized"**.

### Main Categories

**Interface**  
UI customization, menus, text speed, visual settings  
*Examples: Menu themes, text speed toggles, display options*

**Major Systems**  
Large gameplay features and mechanics  
*Examples: Seasons, weather systems, follower Pokemon*

**Quality of Life**  
Convenience features and time-savers  
*Examples: Auto-sorting, item management, shortcuts*

**Battle Mechanics**  
Combat system modifications  
*Examples: Move changes, ability tweaks, damage calculations*

**Economy**  
Money, shops, and rewards  
*Examples: Money multipliers, shop prices, pickup items*

**Difficulty**  
Challenge modes and gameplay modifiers  
*Examples: Nuzlocke settings, boss systems, trainer control*

**Encounters**  
Wild Pokemon spawn settings  
*Examples: Spawn rates, hordes, encounter randomizers*

**Training & Stats**  
Pokemon growth and statistics  
*Examples: EV/IV systems, experience multipliers, stat mods*

### Special Categories

**Uncategorized**  
Default category for settings without an assigned category

**Debug & Developer**  
Testing tools and debug features for mod development

---

## Registration Methods

### NEW: Simplified API (Recommended)

The `register` method handles all setting types with a simple hash:

```ruby
ModSettingsMenu.register(key, {
  name: "Setting Name",
  type: :type_here,
  description: "What it does",
  default: default_value,
  category: "Category Name"
})
```

**Parameters:**
- `key` (Symbol) - Unique identifier for storage
- `name` (String) - Display name in menu
- `type` (Symbol) - Setting type: `:toggle`, `:enum`, `:number`, `:slider`, `:button`
- `description` (String) - Help text shown in menu
- `default` - Default value (varies by type)
- `category` (String) - Category name (optional, defaults to "Uncategorized")

### Traditional API (Still Supported)

Individual registration methods for each type:

```ruby
ModSettingsMenu.register_toggle(key, name, description, default, category)
ModSettingsMenu.register_enum(key, name, values, default_index, description, category)
ModSettingsMenu.register_number(key, name, min, max, default, description, category)
ModSettingsMenu.register_slider(key, name, min, max, interval, default, description, category)
ModSettingsMenu.register_option(option_object, key, category, searchable_items)
```

---

## Setting Types

### 1. Toggle
On/Off switch (0 = Off, 1 = On)

**Parameters:**
- `default`: 0 (Off) or 1 (On)

**Example:**
```ruby
ModSettingsMenu.register(:instant_text, {
  name: "Instant Text",
  type: :toggle,
  description: "Skip text animations",
  default: 0,
  category: "Interface"
})
```

### 2. Enum (Dropdown)
Multiple choice dropdown menu

**Parameters:**
- `values`: Array of choice strings
- `default`: Index of default choice (0-based)

**Example:**
```ruby
ModSettingsMenu.register(:difficulty, {
  name: "Difficulty Level",
  type: :enum,
  values: ["Easy", "Normal", "Hard", "Extreme"],
  default: 1,  # "Normal"
  description: "Game difficulty setting",
  category: "Difficulty"
})
```

### 3. Number
Numeric input with min/max bounds

**Parameters:**
- `min`: Minimum allowed value
- `max`: Maximum allowed value
- `default`: Starting value

**Controls:**
- **Left/Right Arrows**: Increment or decrement by 1

**Example:**
```ruby
ModSettingsMenu.register(:max_party_size, {
  name: "Max Party Size",
  type: :number,
  min: 1,
  max: 12,
  default: 6,
  description: "Maximum Pokemon in party",
  category: "Major Systems"
})
```

### 4. Slider
Numeric slider with fixed intervals

**Parameters:**
- `min`: Minimum value
- `max`: Maximum value
- `interval`: Step size
- `default`: Starting value

**Controls:**
- **Left/Right Arrows**: Adjust by interval amount

**Example:**
```ruby
ModSettingsMenu.register(:encounter_rate, {
  name: "Encounter Rate",
  type: :slider,
  min: 0,
  max: 200,
  interval: 10,
  default: 100,
  description: "Wild encounter rate percentage (100 = normal)",
  category: "Encounters"
})
```

**Note:** The `register_slider` helper automatically uses `StoneSliderOption` which supports negative value ranges and provides consistent rendering across all menus. For direct scene usage, see Advanced Usage section.

### 5. Button
Clickable button that executes code

**Parameters:**
- `on_press`: Proc containing code to run
- `searchable`: Array of keywords (optional)

**Example:**
```ruby
ModSettingsMenu.register(:reset_data, {
  name: "Reset All Data",
  type: :button,
  description: "Resets all mod data to defaults",
  on_press: proc {
    if pbConfirmMessage("Reset all data?")
      # Reset logic here
      pbMessage("Data reset!")
    end
  },
  category: "Debug & Developer",
  searchable: ["reset", "clear", "default"]
})
```

---

## Working Examples

Each example below can be copied independently and will work on its own.

### Toggle Example
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register(:test_toggle, {
    name: "Test Toggle",
    type: :toggle,
    description: "A test toggle switch",
    default: 0,
    category: "Debug & Developer"
  })
end
```

### Enum (Dropdown) Example
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register(:test_enum, {
    name: "Test Dropdown",
    type: :enum,
    values: ["Option A", "Option B", "Option C"],
    default: 0,
    description: "A test dropdown menu",
    category: "Debug & Developer"
  })
end
```

### Number Input Example
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register(:test_number, {
    name: "Test Number",
    type: :number,
    min: 0,
    max: 999,
    default: 50,
    description: "A test number input",
    category: "Debug & Developer"
  })
end
```

### Slider Example
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register(:test_slider, {
    name: "Test Slider",
    type: :slider,
    min: 0,
    max: 100,
    interval: 5,
    default: 50,
    description: "A test slider",
    category: "Debug & Developer"
  })
end
```

### Button Example
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register(:test_button, {
    name: "Test Button",
    type: :button,
    description: "Click to show test message",
    on_press: proc {
      toggle_val = ModSettingsMenu.get(:test_toggle)
      enum_val = ModSettingsMenu.get(:test_enum)
      number_val = ModSettingsMenu.get(:test_number)
      slider_val = ModSettingsMenu.get(:test_slider)
      
      msg = "Test Values:\n"
      msg += "Toggle: #{toggle_val == 1 ? \"On\" : \"Off\"}\n"
      msg += "Enum: #{enum_val}\n"
      msg += "Number: #{number_val}\n"
      msg += "Slider: #{slider_val}"
      
      pbMessage(msg) if defined?(pbMessage)
    },
    category: "Debug & Developer"
  })
end
```

### Traditional API Examples

Each traditional method can also be copied independently.

#### Traditional Toggle
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register_toggle(
    :my_toggle,
    "My Toggle Setting",
    "Description of what this toggle does",
    0,  # Default: 0=Off, 1=On
    "Quality of Life"
  )
end
```

#### Traditional Enum
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register_enum(
    :my_enum,
    "My Dropdown Setting",
    ["Choice 1", "Choice 2", "Choice 3"],
    0,  # Default index (0-based)
    "Description of this dropdown",
    "Difficulty"
  )
end
```

#### Traditional Number
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register_number(
    :my_number,
    "My Number Setting",
    1,    # Minimum value
    100,  # Maximum value
    50,   # Default value
    "Description of this number input",
    "Economy"
  )
end
```

#### Traditional Slider
```ruby
if defined?(ModSettingsMenu)
  ModSettingsMenu.register_slider(
    :my_slider,
    "My Slider Setting",
    0,    # Minimum value
    200,  # Maximum value
    10,   # Interval/step size
    100,  # Default value
    "Description of this slider",
    "Training & Stats"
  )
end
```

#### Traditional Button (Custom Option)
```ruby
if defined?(ModSettingsMenu)
  my_button = ButtonOption.new(
    "My Button",
    proc {
      pbMessage("Button clicked!") if defined?(pbMessage)
    },
    "Description of what this button does"
  )
  
  ModSettingsMenu.register_option(
    my_button,
    :my_button_key,
    "Debug & Developer"
  )
end
```

---

## Developer Features

### Pending Registrations

If your mod loads **before** the Mod Settings system, you can queue registrations to be processed later.

**Simplified API:**
```ruby
# Your mod loads early, before ModSettingsMenu is available
ModSettingsMenu.register_pending(:early_setting, {
  name: "Early Setting",
  type: :toggle,
  description: "Registered before system loaded",
  default: 0,
  category: "Quality of Life"
})
```

**Traditional API:**
```ruby
$MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
$MOD_SETTINGS_PENDING_REGISTRATIONS << proc {
  ModSettingsMenu.register_toggle(
    :my_setting,
    "My Setting",
    "Description",
    0,
    "Quality of Life"
  )
}
```

### On-Change Callbacks

React to setting changes in real-time by registering callbacks.

```ruby
# Register a callback that runs when a setting changes
ModSettingsMenu.register_on_change(:my_setting) do |new_value|
  puts "Setting changed to: #{new_value}"
  # Update game state, reload data, etc.
end

# Example: Update battle system when difficulty changes
ModSettingsMenu.register_on_change(:difficulty_mode) do |difficulty_index|
  case difficulty_index
  when 0 then $game_variables[50] = 0.75  # Easy
  when 1 then $game_variables[50] = 1.0   # Normal
  when 2 then $game_variables[50] = 1.5   # Hard
  end
end
```

### Battle Command Menu

Add custom commands to the battle menu (opened with AUX2/R button during battle).

**Simplified API:**
```ruby
BattleCommandMenu.register(
  name: "Quick Throw",
  on_press: proc { |battle, idxBattler, scene|
    # Your command logic here
    pbMessage("Quick Throw used!")
  },
  description: "Throw a Pokeball without using a turn",
  condition: proc { |battle, idxBattler|
    # Only show if player has Pokeballs
    $PokemonBag.pbQuantity(:POKEBALL) > 0
  },
  priority: 10  # Lower = appears first (default: 100)
)
```

**Traditional API:**
```ruby
BattleCommandMenu.register_command(
  "Quick Throw",
  proc { |battle, idxBattler, scene|
    pbMessage("Quick Throw used!")
  },
  "Throw a Pokeball without using a turn",
  proc { |battle, idxBattler|
    $PokemonBag.pbQuantity(:POKEBALL) > 0
  },
  10  # Priority
)
```

**Parameters:**
- `name` (String) - Display name in battle menu
- `on_press` (Proc) - Code to execute, receives (battle, idxBattler, scene)
- `description` (String) - Help text (optional)
- `condition` (Proc) - Show only if returns true (optional)
- `priority` (Integer) - Sort order, lower = first (default: 100)

### PC Mod Actions

Add custom actions to the PC Pokemon menu (appears when viewing a Pokemon in storage).

**Simplified API:**
```ruby
ModSettingsMenu::PCModActions.register(
  name: "Change Ability",
  on_select: proc { |pokemon, selected, heldpoke, scene|
    # Your action logic here
    abilities = pokemon.getAbilityList
    ability_names = abilities.map { |a| GameData::Ability.get(a[0]).name }
    
    choice = scene.pbShowCommands("Select ability:", ability_names)
    if choice >= 0
      pokemon.ability = abilities[choice][0]
      scene.pbDisplay("Changed ability to #{ability_names[choice]}!")
      return true  # Return true to refresh display
    end
  },
  condition: proc { |pokemon, selected, heldpoke|
    # Only show for Pokemon with multiple abilities
    pokemon.getAbilityList.length > 1
  },
  supports_batch: false  # Can't be used on multiple Pokemon at once
)
```

**Traditional API:**
```ruby
ModSettingsMenu::PCModActions.register_handler({
  name: "Change Ability",
  effect: proc { |pokemon, selected, heldpoke, scene|
    # Action logic
  },
  condition: proc { |pokemon, selected, heldpoke|
    # Availability check
    true
  },
  supports_batch: false
})
```

**Parameters:**
- `name` (String/Proc) - Display name (can be dynamic with Proc)
- `on_select` (Proc) - Code to execute, receives (pokemon, selected, heldpoke, scene)
- `condition` (Proc) - Show only if returns true (optional)
- `supports_batch` (Boolean) - Can be used on multiple Pokemon (default: true)

**Return Value:**
- Return `true` from `on_select` to refresh the PC display
- Return `false` or `nil` to keep display as-is

### Creating Custom Submenus

Create custom settings submenus that match the Mod Settings theme.

**Basic Pattern:**
```ruby
# 1. Create your custom scene class
class MyModSettingsScene < PokemonOption_Scene
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Add your options here
    options << EnumOption.new(
      "My Setting",
      ["Option 1", "Option 2"],
      proc { ModSettingsMenu.get(:my_setting) || 0 },
      proc { |value| ModSettingsMenu.set(:my_setting, value) }
    )
    
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      "My Mod Settings", 0, 0, Graphics.width, 64, @viewport)
    
    # Apply Mod Settings color theme
    if @sprites["option"] && defined?(ModSettingsMenu) && defined?(COLOR_THEMES)
      theme_index = ModSettingsMenu.get(:modsettings_color_theme) || 0
      theme_key = COLOR_THEMES.keys[theme_index]
      if theme_key
        theme = COLOR_THEMES[theme_key]
        if theme[:base] && theme[:shadow]
          @sprites["option"].nameBaseColor = theme[:base]
          @sprites["option"].nameShadowColor = theme[:shadow]
          @sprites["option"].selBaseColor = theme[:base]
          @sprites["option"].selShadowColor = theme[:shadow]
        end
      end
    end
    
    # Initialize values
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
end

# 2. Create a button that opens your scene
ModSettingsMenu.register(:my_mod_submenu, {
  name: "My Mod Settings",
  type: :button,
  description: "Configure my mod options",
  on_press: proc {
    scene = MyModSettingsScene.new
    screen = PokemonOptionScreen.new(scene)
    screen.pbStartScreen
  },
  category: "Quality of Life"
})
```

**Key Points:**
- Inherit from `PokemonOption_Scene`
- Override `pbGetOptions` to define your settings
- Override `pbStartScene` to set title and apply color theme
- **Set `@modsettings_menu` flag** to enable enhanced UI features:
  - Custom spacing for toggles and sliders (more compact, better organized)
  - Automatic multi-row dropdown support with proper spacing
  - Automatic spacer insertion for dropdowns with 4+ options
- Get color theme from `ModSettingsMenu.get(:modsettings_color_theme)`
- Apply to `@sprites["option"]` window's color properties

**Example pbStartScene:**
```ruby
def pbStartScene(inloadscreen = false)
  super
  
  # Set custom title
  @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
    _INTL("My Custom Menu"), 0, 0, Graphics.width, 64, @viewport)
  
  # Enable color theme and enhanced UI features
  if @sprites["option"]
    @sprites["option"].use_color_theme = true if @sprites["option"].respond_to?(:use_color_theme=)
    @sprites["option"].modsettings_menu = true if @sprites["option"].respond_to?(:modsettings_menu=)
  end
  
  # Initialize values...
end
```

---

## Advanced Features

### Enhanced UI with @modsettings_menu Flag

The `@modsettings_menu = true` flag enables several UI enhancements for custom submenus:

**Automatic Multi-Row Dropdown Support:**
- Dropdowns with 4+ options automatically display in multiple rows (3 items per row)
- **Built-in scenes**: Automatic spacing included (ModSettingsScene, ModUpdatesScene, etc.)
- **Custom scenes**: Include `ModSettingsSpacing` module and call `auto_insert_spacers(options)`

```ruby
# For custom scenes: Include the spacing module
class MyCustomSettingsScene < PokemonOption_Scene
  include ModSettingsSpacing  # Add this line for automatic spacing support
  
  def pbGetOptions(inloadscreen = false)
    options = []
    options << EnumOption.new("Multi-Option Setting", 
                             ["A", "B", "C", "D", "E", "F", "G"], ...)
    return auto_insert_spacers(options)  # Add this line for automatic spacing
  end
  
  def pbStartScene(inloadscreen = false)
    super
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      "My Custom Menu", 0, 0, Graphics.width, 64, @viewport)
    
    if @sprites["option"]
      @sprites["option"].modsettings_menu = true  # Enable enhanced UI spacing
    end
  end
end

# The ModSettingsSpacing module provides:
# - auto_insert_spacers(options) method
# - Automatically calculates spacing for 4+ option dropdowns
# - Safe to use - only affects scenes that explicitly include it
```

**Enhanced Spacing:**
- Optimized slider and toggle positioning
- Tighter Off/On toggle spacing for better readability
- Consistent alignment with the Mod Settings visual style

**Usage in Custom Scenes:**
```ruby
class MyModSettingsScene < PokemonOption_Scene
  include ModSettingsSpacing  # Enable automatic dropdown spacing
  
  def pbGetOptions(inloadscreen = false)
    options = []
    # ... add your options ...
    return auto_insert_spacers(options)  # Automatic spacing for multi-row dropdowns
  end
  
  def pbStartScene(inloadscreen = false)
    super
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      "My Custom Menu", 0, 0, Graphics.width, 64, @viewport)
    
    if @sprites["option"]
      @sprites["option"].modsettings_menu = true  # Enhanced slider/toggle spacing
    end
  end
end
```

**What you get:**
- `@modsettings_menu = true`: Enhanced spacing for sliders and toggles
- `include ModSettingsSpacing`: Access to `auto_insert_spacers` method  
- `auto_insert_spacers(options)`: Automatic spacing for 4+ option dropdowns
- Compatible with existing code - no conflicts with original game scenes

### StoneSliderOption for Custom Scenes

For direct scene usage, `StoneSliderOption` provides enhanced slider support with negative value ranges and consistent rendering. The `register_slider` helper uses this automatically.

**Features:**
- Supports negative value ranges (e.g., -10 to 100)
- Fixed 108px bar width with 10px right offset
- Percentage-based tick positioning for accurate visualization
- Works with actual values (not offsets like base SliderOption)

**Class Definition:**
```ruby
class StoneSliderOption < Option
  include PropertyMixin
  attr_reader :name, :optstart, :optend
  
  def initialize(name, optstart, optend, optinterval, getProc, setProc, description = "")
    super(description)
    @name, @optstart, @optend, @optinterval = name, optstart, optend, optinterval
    @getProc, @setProc = getProc, setProc
  end
  
  def next(current)
    current += @optinterval
    current = @optend if current > @optend
    return current
  end
  
  def prev(current)
    current -= @optinterval
    current = @optstart if current < @optstart
    return current
  end
  
  def values
    result = []
    val = @optstart
    while val <= @optend
      result.push(val.to_s)
      val += @optinterval
    end
    return result
  end
end
```

**Usage Example:**
```ruby
def pbGetOptions(inloadscreen = false)
  options = []
  
  # Negative value range slider
  options << StoneSliderOption.new(
    _INTL("Level Offset"),
    -10,          # min (supports negatives)
    20,           # max
    1,            # interval
    proc { ModSettingsMenu.get(:level_offset) || 0 },
    proc { |value| ModSettingsMenu.set(:level_offset, value) },
    _INTL("Adjust levels by this offset")
  )
  
  return options
end
```

**When to Use:**
- ✅ For custom scenes with sliders (direct implementation)
- ✅ When you need negative value ranges
- ❌ For registration API (use `type: :slider` instead - uses StoneSliderOption automatically)

### Search Functionality
Press **Left Control** in the Mod Settings menu to search settings by name or description. Press again to clear search.

### Searchable Buttons
Make button submenus discoverable in search:

```ruby
ModSettingsMenu.register(:economy_settings, {
  name: "Economy Settings",
  type: :button,
  description: "Configure economy options",
  on_press: proc { open_economy_menu },
  category: "Economy",
  searchable: ["money", "shops", "prices", "sales", "cost"]
})
```

---

## Accessing Values

### Get Setting Value
```ruby
value = ModSettingsMenu.get(:setting_key)
```

### Set Setting Value
```ruby
ModSettingsMenu.set(:setting_key, new_value)
```

### Check Toggle State
```ruby
if ModSettingsMenu.get(:my_toggle) == 1
  # Feature enabled
end
```

### Get Enum Selection
```ruby
case ModSettingsMenu.get(:difficulty)
when 0 then handle_easy
when 1 then handle_normal
when 2 then handle_hard
end
```

---

## Testing

### Enable Test Settings
The test examples above automatically appear in **Debug & Developer** category. To test:

1. Copy the test suite code into your mod file
2. Start/restart the game
3. Open Options → Mod Settings
4. Scroll to "Debug & Developer" category
5. Test each setting type
6. Click "Test Button" to see all values

### Verify Persistence
1. Change test settings
2. Save the game
3. Close and reopen the game
4. Load your save
5. Check settings retained their values

### Debug Logging
All mod operations log to `ModsDebug.txt` in the game directory. Check this file if settings aren''t working correctly.

---

## Common Patterns

### Feature Toggle with Implementation
```ruby
# Register the toggle
ModSettingsMenu.register(:double_exp, {
  name: "Double Experience",
  type: :toggle,
  description: "Pokemon gain 2x experience",
  default: 0,
  category: "Training & Stats"
})

# Use in your code
def calculate_exp(base_exp)
  multiplier = ModSettingsMenu.get(:double_exp) == 1 ? 2 : 1
  return base_exp * multiplier
end
```

### Difficulty Multiplier
```ruby
ModSettingsMenu.register(:difficulty_mode, {
  name: "Difficulty",
  type: :enum,
  values: ["Easy (x0.75)", "Normal (x1.0)", "Hard (x1.5)", "Extreme (x2.0)"],
  default: 1,
  description: "Enemy strength multiplier",
  category: "Difficulty"
})

# Get multiplier
DIFFICULTY_MULTIPLIERS = [0.75, 1.0, 1.5, 2.0]
multiplier = DIFFICULTY_MULTIPLIERS[ModSettingsMenu.get(:difficulty_mode)]
```

### Settings Submenu
```ruby
button = ButtonOption.new(
  "My Mod Settings",
  proc {
    pbFadeOutIn {
      scene = MyModSettingsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
  },
  "Configure my mod options"
)

ModSettingsMenu.register_option(button, :my_mod_submenu, "Quality of Life")
```

---

## Update & Auto-Update Support

### Version Format

Use semantic versioning for all mod versions:
**Format:** `X.Y.Z`
- **X** = Major version (breaking changes, incompatible updates, huge updates)
- **Y** = Minor version (new features, backwards compatible)
- **Z** = Patch version (bug fixes, small tweaks)

**Examples:**
- `1.0.0` - Initial release
- `1.1.0` - Added new features
- `1.1.1` - Fixed bugs in 1.1.0
- `2.0.0` - Major rewrite with breaking changes

**Update Detection:**
- Major updates (X different): Red - significant changes
- Minor updates (Y different): Orange - new features  
- Hotfixes (Z different): Yellow - bug fixes
- Up to date: Green - current version
- Not tracked: Mod has version header but no registration, or no version at all

### Version Display Options

The update checker will detect and display your mod in three ways:

**1. Self-Registered Mods (Recommended)**
- Add a registration block to your mod (see below)
- **Appears in:** Update categories (Up to Date, Updates Available, etc.)
- **Features:** Auto-update, dependency checking, changelog access
- **Version from:** Registration block

**2. Version Header Only**
- Add a version header to your mod but no registration
- **Appears in:** "Not Tracked" section with version displayed
- **Features:** Version visibility only, no auto-update
- **Version from:** File header `# Script Version: X.Y.Z`

**3. No Version Information**
- Mod has neither registration nor version header
- **Appears in:** "Not Tracked" section with no version
- **Features:** Shows mod exists but version unknown

### Self-Registration for Auto-Updates

To enable auto-updates for your mod, add a self-registration block at the **end of your mod file**:

**Registration Template (Copy & Paste):**
Replace the placeholder values below with your mod's information:

```ruby
# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
# Register this mod for auto-updates
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Your Mod Name",           # Display name (e.g., "Economy Mod")
    file: "YourModFile.rb",          # Filename (e.g., "02_EconomyMod.rb")
    version: "X.Y.Z",                # Current version (e.g., "1.0.0")
    download_url: "https://raw.githubusercontent.com/YourUsername/YourRepo/main/Path/To/YourModFile.rb",
    version_check_url: nil,          # Only required for .zip downloads - URL to .rb file for version checking
    changelog_url: "https://raw.githubusercontent.com/YourUsername/YourRepo/main/Path/To/Changelog.md", # Top line is used as a title, so just throw your mods name at the top of the changelog file.
    graphics: [],                    # Optional: [{url: "https://...", path: "Graphics/Pictures/file.png"}]
    dependencies: []                 # Optional: [{name: "Other Mod", version: "1.0.0"}]
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["YourModFile.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("YourModPrefix: Your Mod Name #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
```

**How Version Checking Works:**
1. The update checker scans your Mods folder for all .rb files
2. For registered mods, it downloads the remote version from `download_url` (or `version_check_url` if download_url is a .zip)
3. It parses the registration block in the downloaded file to get the online version
4. Compares local version vs online version to determine if an update is available
5. If update available, user can download and install automatically from `download_url`
6. For non-registered mods, it reads the version header (if present) and displays in "Not Tracked"

**Field Descriptions:**
- `name` (required): Display name shown in the update menu
- `file` (required): Exact filename including .rb extension
- `version` (required): Semantic version string (X.Y.Z)
- `download_url` (required): Direct URL to download the .rb file (or .zip) for auto-updates
- `version_check_url` (required for .zip downloads only): URL to the .rb file for version checking when download_url is a .zip
- `changelog_url` (optional): URL to changelog file (markdown or text), Top line is used as a title, so just throw your mods name at the top of the changelog file.
- `graphics` (optional): Array of graphics files with download URL and game path (supports individual files or .zip archives)
- `dependencies` (optional): Array of required mods with minimum versions

**ZIP File Support:**
Both `download_url` and `graphics` entries support ZIP files for easier packaging:

```ruby
# Example 1: Mod distributed as ZIP (requires version_check_url)
download_url: "https://github.com/user/repo/releases/download/v1.0/MyMod.zip"
version_check_url: "https://raw.githubusercontent.com/user/repo/main/MyMod.rb"
# ZIP will extract to base game folder, must contain proper structure (e.g., Mods/MyMod.rb)

# Example 2: Graphics as ZIP
graphics: [
  {
    url: "https://github.com/user/repo/releases/download/v1.0/Graphics.zip",
    path: "Graphics/Characters/"  # Ignored for ZIPs - extracts to base folder
  }
]
# ZIP structure should include full paths (e.g., Graphics/Characters/sprite.png)
```

**ZIP Security:**
- All ZIP files are validated before extraction
- Path traversal attacks (../) are blocked
- Only allowed file types: .rb, .png, .gif, .jpg, .jpeg, .bmp, .wav, .ogg, .mp3, .mid, .txt, .md, .json, .yml, .rxdata, .rvdata, .rvdata2
- Only allowed directories: Graphics/, Audio/, Mods/, Data/, Fonts/
- Files outside allowed zones or with unsafe extensions are automatically rejected
- Uses 7z.exe from BaseDir\REQUIRED_BY_INSTALLER_UPDATER folder

**Priority System:**
If a mod has both a self-registration block and a version header, the **registration takes priority**. The mod will appear in update categories (Up to Date, Updates Available, etc.) using the registration version, and the version header is ignored.

**Example with Graphics and Dependencies:**
```ruby
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Advanced Battle System",
    file: "05_AdvancedBattle.rb",
    version: "2.3.1",
    download_url: "https://raw.githubusercontent.com/user/repo/main/Mods/05_AdvancedBattle.rb",
    changelog_url: "https://raw.githubusercontent.com/user/repo/main/Changelogs/AdvancedBattle.md", 
    graphics: [
      {
        url: "https://raw.githubusercontent.com/user/repo/main/Graphics/UI/battle_hud.png",
        path: "Graphics/Pictures/battle_hud.png"
      }
    ],
    dependencies: [
      {name: "01_Mod_Settings", version: "3.1.0"},
      {name: "04_CoreSystem", version: "1.5.0"}
    ]
  )
end
```

**Setup Steps:**
1. Host your mod on GitHub or similar service with raw file access
2. Add the self-registration block at the end of your mod file
3. **Important:** When you release an update, increment the version number in the registration block
4. Push the updated file to your repository
5. Users' mod settings will detect the version difference and offer to auto-update if they have it on.

### Optional Version Header (For Backward Compatibility)

If you want your mod to display a version in "Not Tracked" without full auto-update support, add this header within the first 40 lines of your file:

```ruby
#========================================
# My Mod Name
# Script Version: 1.0.0
# Author: Your Name
#========================================
```

**Note:** This header is optional. The primary version source is the registration block. Mods with only a header will appear in "Not Tracked" but will still show their version number.


**Notes:**
- The registration happens automatically when your mod loads
- Graphics are automatically downloaded and installed during auto-update
- Dependencies are checked before updating - update blocked if requirements not met
- If you don't include `download_url`, the mod will be tracked for version checking only (no auto-download)
- Keep your registration section organized at the end of the file with all other mod registrations
- **Remember:** Update the version number in your registration block when releasing new versions!

---

## Debug Logging

### Required: Mod Load Message

Every mod should ideally output a load message to confirm it initialized successfully:

```ruby
#========================================
# My Mod Name
# Script Version: 1.0.0
#========================================

# Log that mod has loaded
begin
  mod_debug_path = "ModsDebug.txt"
  File.open(mod_debug_path, "a") do |f|
    f.puts("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] My Mod Name v1.0.0 loaded successfully")
  end
rescue
  # Silently fail if we can't write to debug file
end

# Rest of your mod code...
```

### Debug File Location

Debug logs are written to **`ModsDebug.txt`** in the game's save file location:
- **Windows:** `%APPDATA%/kurayinfinitefusion/ModsDebug.txt`
- **Path in game:** Same directory as save files

### Using Debug Logging

Use `ModSettingsMenu.debug_log()` for detailed logging:

```ruby
begin
  ModSettingsMenu.debug_log("MyMod: Starting complex operation")
  
  # Your code here
  result = do_something()
  
  ModSettingsMenu.debug_log("MyMod: Operation completed successfully, result: #{result}")
rescue => e
  ModSettingsMenu.debug_log("MyMod Error: #{e.class} - #{e.message}")
  ModSettingsMenu.debug_log("Backtrace: #{e.backtrace.first(5).join('\n')}")
  raise  # Re-raise if needed
end
```

**Best Practices:**
- Log initialization/load completion
- Log major operations (file operations, network requests, battle hooks)
- Log errors with class, message, and backtrace
- Use mod name prefix: `"MyMod: message"` for easy filtering
- Wrap file operations in begin/rescue blocks

**What to Log:**
- ✅ Mod loaded successfully
- ✅ Settings registered
- ✅ Major feature initialization
- ✅ Errors and exceptions
- ✅ File operations (read/write/download)

---

## Troubleshooting

### Settings Not Saving
- Ensure you''re using `ModSettingsMenu.set()` to change values
- Settings persist in save files, so create a new save or modify existing ones
- Check that `$PokemonSystem` is available when changing settings

### Settings Not Appearing
- Verify your mod file is loaded (check file naming/load order)
- Check `ModsDebug.txt` for errors
- Ensure category name matches exactly (case-sensitive)

### Duplicate Key Errors
- Each `:key` must be unique across all mods
- Use descriptive prefixes: `:mymod_setting_name`
- Check for conflicts with other mods

### Wrong Category Showing
- Category names are case-sensitive
- Verify spelling matches categories list exactly
- Blank/nil category defaults to "Uncategorized"

---
