# Stone's Kuray Shop Documentation
**Script Version:** 1.1.0  
**Author:** Stonewall
---

## Table of Contents
1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Configuration](#configuration)
4. [Shop Item Order](#shop-item-order)
5. [Item Pricing](#item-pricing)
6. [Streamer's Dream Integration](#streamers-dream-integration)
7. [Kuray Eggs Integration](#kuray-eggs-integration)
8. [Header Customization](#header-customization)
9. [Advanced Features](#advanced-features)
10. [Troubleshooting](#troubleshooting)

---

## Overview

**Stone's Kuray Shop** is a custom shop mod for Pokemon Infinite Fusion that provides a specialized shopping experience with:

- **Customizable Item Lists**: Control exactly which items appear in your shop and in what order
- **Category Headers**: Organize items into visual categories with customizable colors
- **Custom Pricing**: Set buy/sell prices independently for each item
- **Streamer's Dream Integration**: Automatic pricing adjustments based on the Streamer's Dream setting
- **Kuray Eggs Support**: Dynamic pricing for Kuray Eggs based on game settings
- **Debug Logging**: Comprehensive error tracking for troubleshooting
- **Auto-Update Support**: Automatic version checking and update notifications

The shop is designed to give players access to specific items with custom pricing while maintaining compatibility with game features like Streamer's Dream mode.

---

## Quick Start

### Installation

1. Download `03_StonesKurayShop.rb`
2. Place it in your `Mods` folder
3. Launch the game - the mod will auto-register

### Basic Usage

The shop will be available in-game wherever Kuray Shops are located. Items will appear in the order you configure, organized by category headers.

### Default Configuration

Out of the box, the shop includes:
- Power Items (Weight, Bracer, Belt, Lens, Band, Anklet)
- Battle Items (Flame Orb, Toxic Orb, Life Orb, Eviolite)
- PP Items (Ether, Max Ether, Elixir, Max Elixir, PP Up, PP Max)
- Select TMs (various coverage moves)
- Kuray Eggs (items 2000-2030)
- Items affected by Streamer's Dream setting

---

## Configuration

All configuration is done by editing constants at the top of the file.

### File Structure

```ruby
module KurayShopMod
  ITEMS = [...]     # What appears in the shop and in what order
  PRICES = {...}    # Custom pricing for each item
end
```

---

## Shop Item Order

The `ITEMS` array controls what appears in your shop and the display order.

### Basic Format

```ruby
ITEMS = [
  "CATEGORY NAME",
  item_id_1, item_id_2, item_id_3,
  "ANOTHER CATEGORY",
  item_id_4, item_id_5
]
```

### Category Headers

String entries create **visual category headers** in the shop:

```ruby
ITEMS = [
  "ITEMS",              # Creates red header labeled "ITEMS"
  68, 121, 122,         # Items appear under this category
  "MEDICINE",           # Creates new header labeled "MEDICINE"
  245, 246, 247         # Items appear under this category
]
```

**Important Notes:**
- Category headers are purely visual - they don't restrict item types
- You can name categories anything you want
- Empty categories (headers with no items after them) won't display
- Items must still be priced in the `PRICES` hash to appear

### Item IDs

Common item IDs:
- **3**: Max Repel
- **68**: Eviolite
- **100**: Life Orb
- **115**: Flame Orb
- **116**: Toxic Orb
- **121-126**: Power Items (Weight, Bracer, Belt, Lens, Band, Anklet)
- **235**: Rage Candy Bar
- **245-250**: PP Items (Ether, Max Ether, Elixir, Max Elixir, PP Up, PP Max)
- **263**: Rare Candy
- **264**: Master Ball
- **303-657**: TMs
- **568**: Mist Stone
- **569**: Devolution Spray
- **570**: Transgender Stone
- **623**: Rocket Ball
- **2000-2030**: Kuray Eggs

### Example Configuration

```ruby
ITEMS = [
  "TRAINING ITEMS",
  121, 122, 123, 124, 125, 126,  # All Power Items
  "HELD ITEMS",
  68, 100, 115, 116,              # Eviolite, Life Orb, Flame Orb, Toxic Orb
  "KURAY EGGS",
  2000, 2001, 2002                # First three eggs
]
```

---

## Item Pricing

The `PRICES` hash sets custom buy and sell prices for items.

### Price Format

```ruby
PRICES = {
  item_id => [buy_price, sell_price],
  68 => [4000, 2000],  # Eviolite costs 4000, sells for 2000
  121 => [3000, 1500]   # Power Weight costs 3000, sells for 1500
}
```

### Important Rules

1. **Items must be in both ITEMS and PRICES**
   - ITEMS array: Controls if item appears
   - PRICES hash: Controls pricing
   - Missing from PRICES = won't appear even if in ITEMS

2. **Sell price is typically half buy price**
   ```ruby
   68 => [4000, 2000],  # Buy 4000, sell 2000 (50%)
   ```

3. **Zero sell price for non-sellable items**
   ```ruby
   263 => [10000, 0],   # Rare Candy - can't sell back
   ```

### Commented Items

Items commented out in PRICES won't appear in the base shop (but may appear via Streamer's Dream):

```ruby
PRICES = {
  # 263 => [10000, 0],  # Rare Candy - commented out
  68 => [4000, 2000]     # Eviolite - active
}
```

### Example Pricing

```ruby
PRICES = {
  # Power Items - Training focused
  121 => [3000, 1500],   # Power Weight
  122 => [3000, 1500],   # Power Bracer
  123 => [3000, 1500],   # Power Belt
  
  # Battle Items - Competitive pricing
  100 => [6000, 3000],   # Life Orb
  115 => [6000, 3000],   # Flame Orb
  116 => [6000, 3000],   # Toxic Orb
  
  # PP Items - Convenience pricing
  245 => [1200, 600],    # Ether
  249 => [9100, 4550],   # PP Up
  250 => [29120, 14560]  # PP Max
}
```

---

## Streamer's Dream Integration

The mod automatically adjusts pricing for specific items based on the **Streamer's Dream** setting.

### How It Works

When Streamer's Dream is enabled:
- Select items become **free** (price = -1)
- This overrides normal pricing from the PRICES hash
- Items still need to be in the ITEMS array to appear

When Streamer's Dream is disabled:
- Items use special pricing defined in `apply_streamer_dream_and_eggs`
- Different from base PRICES hash

### Affected Items

Items with Streamer's Dream pricing:
- **3**: Max Repel
- **235**: Rage Candy Bar
- **263**: Rare Candy
- **264**: Master Ball
- **568**: Mist Stone
- **569**: Devolution Spray
- **570**: Transgender Stone

### Pricing Behavior

```ruby
# Streamer's Dream OFF:
mart_prices[263] = [10000, 0]      # Rare Candy costs 10,000

# Streamer's Dream ON:
mart_prices[263] = [-1, 0]         # Rare Candy is FREE
```

### Customizing Streamer's Dream Items

Edit the `apply_streamer_dream_and_eggs` method:

```ruby
def self.apply_streamer_dream_and_eggs(mart_prices)
  if $PokemonSystem.kuraystreamerdream == 0
    # Prices when Streamer's Dream is OFF
    mart_prices[263] = [10000, 0] if ITEMS.include?(263)  # Rare Candy
    mart_prices[570] = [6900, 3450] if ITEMS.include?(570) # Transgender Stone
  else
    # Prices when Streamer's Dream is ON (free)
    mart_prices[263] = [-1, 0] if ITEMS.include?(263)      # Free Rare Candy
    mart_prices[570] = [-1, 0] if ITEMS.include?(570)      # Free Transgender Stone
  end
end
```

**Important**: Items MUST be in the ITEMS array to appear, even with Streamer's Dream pricing.

---

## Kuray Eggs Integration

The mod automatically handles **Kuray Eggs** (items 2000-2032) with dynamic pricing.

### How It Works

1. Kuray Eggs use pricing from the global `$KURAYEGGS_BASEPRICE` array
2. Buy price = base price from array
3. Sell price = 50% of base price
4. With Streamer's Dream enabled, all eggs become free

### Configuration

Add eggs to your ITEMS array:

```ruby
ITEMS = [
  "KURAY EGGS",
  2000, 2001, 2002, 2003  # First 4 eggs
]
```

No need to add to PRICES hash - pricing is automatic.

### Egg Pricing Examples

```ruby
# Assuming $KURAYEGGS_BASEPRICE[0] = 5000
# Item 2000 (first egg):
#   Buy price: 5000
#   Sell price: 2500

# With Streamer's Dream ON:
#   Buy price: FREE (-1)
#   Sell price: 0
```

### Full Egg Range

To include all Kuray Eggs:

```ruby
ITEMS = [
  "KURAY EGGS",
  2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009,
  2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
  2020, 2021, 2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030
]
```

---

## Header Customization

Category headers display in a customizable color at the top of each section.

### Changing Header Color

Edit the `drawItem` method in the `Window_PokemonMart` class:

```ruby
def drawItem(index, count, rect)
  item = @stock[index]
  if item.is_a?(Hash) && item[:header]
    # CUSTOMIZE THESE COLOR VALUES
    base = Color.new(255, 50, 50)   # Red (RGB: 255, 50, 50)
    shadow = Color.new(0, 0, 0)     # Black shadow
    # ... rest of method
  end
end
```

### RGB Color Values

Common colors:
```ruby
Color.new(255, 0, 0)      # Bright Red
Color.new(0, 255, 0)      # Bright Green
Color.new(0, 0, 255)      # Bright Blue
Color.new(255, 215, 0)    # Gold
Color.new(255, 165, 0)    # Orange
Color.new(128, 0, 128)    # Purple
Color.new(255, 255, 255)  # White
Color.new(128, 128, 128)  # Gray
```

### Example: Gold Headers

```ruby
base = Color.new(255, 215, 0)   # Gold
shadow = Color.new(50, 50, 50)  # Dark gray shadow
```

---

## Advanced Features

### Dynamic Configuration

You can modify shop contents at runtime using the `configure` method:

```ruby
KurayShopMod.configure(
  items: ["CUSTOM", 68, 100],
  prices: {68 => [5000, 2500], 100 => [8000, 4000]}
)
```

This allows other mods or scripts to customize the shop dynamically.

### Price Lookup

Get the price for any item programmatically:

```ruby
buy_price = KurayShopMod.get_price_for_item(68, selling: false)  # Get buy price
sell_price = KurayShopMod.get_price_for_item(68, selling: true)  # Get sell price
```

### Debug Logging

The mod logs all major operations to `ModsDebug.txt`:

- Shop initialization
- Price application success/failures
- Display stock building
- Error details with stack traces

All logs use the prefix `StonesKurayShop:` for easy filtering.

### Auto-Update Support

The mod includes auto-update registration:
- Automatically checks for new versions from GitHub
- Displays update notifications in Mod Settings menu
- Can view changelog from within the game
- Download URLs configured in registration block

---

## Troubleshooting

### Items Not Appearing in Shop

**Problem**: Added item to ITEMS array but it doesn't show up

**Solutions**:
1. Make sure item is also in PRICES hash
   ```ruby
   ITEMS = [68]            # Not enough
   PRICES = {68 => [4000, 2000]}  # Also need this
   ```

2. Check if category is empty (headers with no items don't display)

3. Verify item ID is correct

### Wrong Prices Displaying

**Problem**: Item shows different price than configured

**Possible Causes**:
1. Streamer's Dream is active (overrides normal pricing)
2. Item is a Kuray Egg (uses $KURAYEGGS_BASEPRICE)
3. Price defined in `apply_streamer_dream_and_eggs` overrides PRICES hash

**Check**:
- Review `apply_streamer_dream_and_eggs` method for item
- Check Streamer's Dream setting in game options

### Category Headers Not Showing

**Problem**: Category string in ITEMS but no header appears

**Solution**: Headers only display if items follow them:
```ruby
# Won't show header:
ITEMS = ["CATEGORY", "ANOTHER CATEGORY", 68]

# Will show both headers:
ITEMS = ["CATEGORY", 68, "ANOTHER CATEGORY", 100]
```

### Debug Log Issues

**Problem**: Not seeing log entries in ModsDebug.txt

**Solutions**:
1. Check file location: `[Game Save Folder]\ModsDebug.txt`
2. Verify Mod Settings framework is installed (v3.0.0+)
3. Look for prefix `StonesKurayShop:` in the log file

### Color Not Changing

**Problem**: Changed RGB values but header still shows red

**Solution**: 
1. Make sure you edited the correct section (inside `drawItem` method)
2. Verify syntax: `Color.new(R, G, B)` with valid RGB values (0-255)
3. Save file and reload game

### Price Returns Nil

**Problem**: `get_price_for_item` returns nil

**Causes**:
- Item not in PRICES hash
- Using wrong item ID

**Solution**: Add to PRICES hash or verify item ID is correct

---

**Need More Help?**

- Check `ModsDebug.txt` for detailed error messages with prefix `StonesKurayShop:`
- Review the changelog for recent changes
- Verify you're using the latest version (1.1.0)
- Ensure Mod Settings framework is installed and up to date
