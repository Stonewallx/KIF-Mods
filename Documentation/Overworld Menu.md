# Overworld Menu Documentation
**Script Version:** 2.0.0  
**Author:** Stonewall  

---

## Table of Contents
1. [Overview](#overview)
2. [Features](#features)
3. [Installation](#installation)
4. [Registration Guide](#registration-guide)
5. [Configuration](#configuration)
6. [Technical Details](#technical-details)

---

## Overview
The Overworld Menu provides a customizable, expandable pause menu overlay accessible at any time during gameplay. It features a party overview display, weather information box, and a flexible registration system for mods to add their own menu options. The menu uses multi-page navigation and priority-based sorting to organize entries.

---

## Features

### Core Features
- **Configurable Trigger Button**: Choose from several different button/combo options to open the menu
- **Multi-Page Navigation**: Press R button to switch between Page 1 and Page 2
- **Party Overview Display**: 2x3 grid showing party Pokemon with:
  - Pokemon sprites (eggs shown as EGG indicator)
  - HP bars with color coding (green/yellow/red)
  - Level display
  - Status condition icons
  - Shiny stars for shiny Pokemon
  - Held item icons
- **Weather Information Box**: Real-time weather display (requires Weather System mod)
- **Season Information**: Shows current season and day progress (requires Seasons mod)
- **Priority-Based Sorting**: Control menu item ordering with priority values
- **Flexible Registration API**: Easy-to-use system for mods to add menu options

### Built-in Menu Items
- **Time**: Quick access to time changing (Morning/Afternoon/Evening/Night)
- **Mod Settings**: Opens the Mod Settings menu for all mod configuration

---

## Installation

1. Download `01a_Overworld_Menu.rar` from the releases

2. Extract the rar file to your game''s root directory
   - The rar contains the full folder structure
   - Files will automatically place in correct locations

3. Launch game - Overworld Menu will auto-register with Mod Settings

---

## Registration Guide

### Basic Registration

To add your mod to the Overworld Menu, use the `OverworldMenu.register` method:

```ruby
OverworldMenu.register(:unique_key, {
  label: "Menu Label",
  handler: proc { |screen|
    # Your menu action code here
    pbMessage("Hello from my mod!")
    nil  # Return nil to stay in menu, or :exit_menu to close
  },
  priority: 50,                    # Optional: Lower = appears first
  condition: proc { true },        # Optional: When this item is visible
  exit_on_select: false            # Optional: Close menu after selection
})
```

### Complete Example - Simple Message

```ruby
OverworldMenu.register(:hello_world, {
  label: "Say Hello",
  handler: proc { |screen|
    # Hide party sprites while showing message
    screen.instance_variable_get(:@scene).hide_party_sprites
    
    pbMessage("Hello from the Overworld Menu!")
    
    # Show party sprites again
    screen.instance_variable_get(:@scene).show_party_sprites
    
    nil  # Stay in menu
  },
  priority: 30
})
```

### Complete Example - Open Submenu with Fade Transition

```ruby
OverworldMenu.register(:my_mod_settings, {
  label: "My Mod Settings",
  handler: proc { |screen|
    # Close the Overworld Menu scene first
    scene = screen.instance_variable_get(:@scene)
    scene.pbEndScene if scene
    $game_temp.in_menu = false
    
    # Now open your settings menu with fade transition
    pbFadeOutIn {
      my_scene = MyModSettingsScene.new
      screen_obj = PokemonOptionScreen.new(my_scene)
      screen_obj.pbStartScreen
    }
    
    :exit_menu  # Close menu after opening submenu
  },
  priority: 25,
  exit_on_select: true
})
```

### Complete Example - Conditional Visibility

```ruby
OverworldMenu.register(:special_feature, {
  label: "Special Feature",
  handler: proc { |screen|
    scene = screen.instance_variable_get(:@scene)
    scene.hide_party_sprites
    
    # Your special feature code
    pbMessage("Special feature activated!")
    
    scene.show_party_sprites
    nil
  },
  priority: 40,
  condition: proc {
    # Only show after first gym badge
    $Trainer.badge_count >= 1
  }
})
```

### Complete Example - Exit Menu Immediately

```ruby
OverworldMenu.register(:quick_heal, {
  label: "Quick Heal Party",
  handler: proc { |screen|
    # Heal all Pokemon
    $Trainer.party.each { |pkmn| pkmn.heal }
    
    pbMessage("Party fully healed!")
    
    :exit_menu  # Close menu after healing
  },
  priority: 15,
  exit_on_select: true
})
```

### Registration Parameters

#### Required Parameters

**`:label`** (String)  
The display name shown in the menu  
*Example:* `"My Cool Feature"`

**`:handler`** (Proc)  
The code that runs when the menu item is selected. Receives the screen object as a parameter.  
*Return values:*
- `nil` - Stay in menu after executing
- `:exit_menu` - Close menu after executing

#### Optional Parameters

**`:priority`** (Integer, default: 99)  
Controls the order items appear in the menu. Lower numbers appear first.  
*Example:* `priority: 25`

**`:condition`** (Proc, default: `proc { true }`)  
A proc that determines if this menu item is visible. Return `true` to show, `false` to hide.  
*Example:* `condition: proc { $Trainer.badge_count >= 3 }`

**`:exit_on_select`** (Boolean, default: false)  
If true, the menu will close after this item is selected, regardless of handler return value.  
*Example:* `exit_on_select: true`

### Best Practices

1. **Handle Scene Properly**: When opening submenus, always close the Overworld Menu scene first
   ```ruby
   scene = screen.instance_variable_get(:@scene)
   scene.pbEndScene if scene
   $game_temp.in_menu = false
   ```

2. **Hide Party Sprites for Messages**: Use `hide_party_sprites` and `show_party_sprites` when showing messages
   ```ruby
   scene.hide_party_sprites
   pbMessage("Your message")
   scene.show_party_sprites
   ```

3. **Return Correct Values**: Return `nil` to stay in menu, `:exit_menu` to close
   ```ruby
   nil           # Menu stays open
   :exit_menu    # Menu closes
   ```

## Configuration

### User Settings

Access configuration through **Mod Settings → Overworld Menu**:

**Enabled**  
Toggle the entire Overworld Menu system on/off

**Open Button**  
Select which button or button combination opens the menu:
- Single buttons: Z, Q, W, D, A, S
- Button combos: Q+W, Q+Z, W+Z, Q+A, W+A, Q+S, W+S, D+Z, A+Z, S+Z

**Party View**  
Show/hide party Pokemon sprites in the menu

**Weather Box**  
Show/hide weather information box (requires Weather System)

**Page Assignments**  
Configure which page (1 or 2) each registered menu item appears on

### In-Menu Controls

- **Arrow Keys**: Navigate menu items
- **R Button**: Switch between Page 1 and Page 2
- **Configured Button / Back**: Close menu

---

## Technical Details

### Module Structure

**`OverworldMenuConfig`**  
Priority configuration for menu items

**`OverworldMenu`**  
Registration system and registry management

**`OverworldMenuSettings`**  
Settings storage and button configuration

**`OverworldMenuScene`**  
Scene class handling visual display

**`OverworldMenuHandler`**  
Handler class managing menu logic and page switching

### Events & Hooks

**`Events.onMapUpdate`**  
Checks for configured button press to open menu

### Storage Keys

Menu settings use ModSettings storage:
- `:overworld_menu_enabled` - Menu system enabled
- `:overworld_menu_button` - Configured trigger button
- `:overworld_menu_party_view` - Party view display toggle
- `:overworld_menu_weather_box` - Weather box display toggle
- `:overworld_menu_page2_{key}` - Page assignment for each registered item

### Registration Validation

The system validates registrations:
- **Key must be Symbol**: Ensures consistent key format
- **Label must be String**: Ensures display text is valid
- **Handler must be Proc**: Ensures executable code
- **Duplicate prevention**: Warns if key already registered
