#========================================
# Stone's Kuray Shop
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 1.1.0
#========================================

module KurayShopMod
  #-----------------------------------------------------------------------
  # SHOP ITEM ORDER
  # Add Item IDs here for them to appear in the Kuray Shop in the order listed.
  # I only added categories for organization, feel free to add, remove, rename or rearrange the categories.
  #-----------------------------------------------------------------------
  ITEMS = [
    "ITEMS",
    3, 568, 569, 570, 68, 121, 122, 123, 124, 125, 126, 115, 116, 100, 194,
    "MEDICINE",
    235, 263, 245, 246, 247, 248, 249, 250,
    "POKEBALLS",
    264, 623,
    "TMs & HMs",
    303, 314, 329, 335, 343, 345, 346, 356,
    358, 367, 371, 618, 619, 646, 647, 648,
    649, 650, 651, 652, 653, 654, 655, 656,
    657,
    "BERRIES",
    "BATTLE ITEMS",
    "KEY ITEMS",
    "KURAY EGGS",
    2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
    2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021,
    2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030
  ]

  #-----------------------------------------------------------------------
  # ITEM PRICES
  # Set prices below for items in the shop. Must have Item IDs listed in the ITEMS array above to appear in the shop.
  # Format is: ItemID => [BuyPrice, SellPrice]
  # Comments added so you know which item corresponds to which ID.
  #-----------------------------------------------------------------------
  PRICES = {
    #--------- ITEMS ---------
    # 3 => [700, 350], # Max Repel
    # 570 => [6900, 3450], # Transgender Stone
    # 568 => [999999, 24000], # Mist Stone
    # 569 => [8200, 4100], # Devolution Spray
    68 => [4000, 2000], # Eviolite
    # 604 => [9100, 4550], # Secret Capsule
    121 => [3000, 1500], # Power Weight
    122 => [3000, 1500], # Power Bracer
    123 => [3000, 1500], # Power Belt
    124 => [3000, 1500], # Power Lens
    125 => [3000, 1500], # Power Band
    126 => [3000, 1500], # Power Anklet
    114 => [6000, 3000], # Focus Sash
    115 => [6000, 3000], # Flame Orb
    116 => [6000, 3000], # Toxic Orb
    100 => [6000, 3000], # Life Orb
    194 => [10000, 1000], # Deep Sea Scale
    #--------- MEDICINE ---------
    # 235 => [10000, 0], # Rage Candy Bar
    # 263 => [10000, 0], # Rare Candy
    245 => [1200, 600], # Ether
    246 => [3600, 1800], # Ether Max
    247 => [4000, 2000], # Elixir
    248 => [12000, 6000], # Elixir Max
    249 => [9100, 4550], # PPUP
    250 => [29120, 14560], # PPMAX
    #--------- POKEBALLS ---------
    # 264 => [960000, 0], # Master Ball
    623 => [1500, 750], # Rocket Ball
    #--------- TMs & HMs ---------
    303 => [10000, 5000], # Light Screen
    314 => [10000, 5000], # Return
    329 => [10000, 5000], # Facade
    335 => [10000, 5000], # Round
    343 => [10000, 5000], # Fling
    345 => [10000, 5000], # Sky Drop
    346 => [10000, 5000], # Incinerate
    356 => [10000, 5000], # Rock Polish
    358 => [10000, 5000], # Stone Edge
    367 => [10000, 5000], # Rock Throw
    618 => [30000, 15000], # Spore
    619 => [30000, 15000], # Toxic Spikes
    646 => [30000, 15000], # Brutal Swing
    647 => [30000, 15000], # Aurora Veil
    648 => [30000, 15000], # Dazzling Gleam
    649 => [30000, 15000], # Focus Punch
    650 => [30000, 15000], # Infestation
    651 => [30000, 15000], # Leech Life
    652 => [30000, 15000], # Power Up Punch
    653 => [30000, 15000], # Shock Wave
    654 => [30000, 15000], # Smart Strike
    655 => [30000, 15000], # Steel Wing
    656 => [30000, 15000], # Stomping Tantrum
    657 => [30000, 15000], # Throat Chop
    # 659 => [30000, 15000], # Scald
    #--------- BERRIES ---------
    #--------- BATTLE ITEMS ---------
    #--------- KEY ITEMS ---------
    # 599 => [1, 1] # Magic Boots
  }

  #-----------------------------------------------------------------------
  # STREAMER'S DREAM ITEM PRICING
  # For the Streamer's Dream feature, set prices for specific items when the feature is off and on.
  #-----------------------------------------------------------------------
  def self.apply_streamer_dream_and_eggs(mart_prices)
    begin
      return unless mart_prices
      if defined?($PokemonSystem) && $PokemonSystem.respond_to?(:kuraystreamerdream)
        if $PokemonSystem.kuraystreamerdream == 0
          # Prices if Streamer's dream is inactive
          # Code[ItemID] = [BuyPrice, SellPrice] if ITEMS.include?(ItemID)
          mart_prices[235] = [10000, 0] if ITEMS.include?(235) # Rage Candy Bar
          mart_prices[263] = [10000, 0] if ITEMS.include?(263) # Rare Candy
          mart_prices[570] = [6900, 3450] if ITEMS.include?(570) # Transgender  Stone
          mart_prices[264] = [960000, 0] if ITEMS.include?(264) # Master Ball
          mart_prices[568] = [999999, 24000] if ITEMS.include?(568) # Mist Stone
          mart_prices[569] = [8200, 4100] if ITEMS.include?(569) # Devolution Spray
          mart_prices[3] = [700, 350] if ITEMS.include?(3) # Max Repel
        else
          # Prices if Streamer's dream is active
          # Code[ItemID] = [-1, 0] if ITEMS.include?(ItemID)
          mart_prices[235] = [-1, 0] if ITEMS.include?(235) # Rage Candy Bar
          mart_prices[263] = [-1, 0] if ITEMS.include?(263) # Rare Candy
          mart_prices[570] = [-1, 0] if ITEMS.include?(570) # Transgender  Stone
          mart_prices[264] = [-1, 0] if ITEMS.include?(264) # Master Ball
          mart_prices[568] = [-1, 0] if ITEMS.include?(568) # Mist Stone
          mart_prices[569] = [-1, 0] if ITEMS.include?(569) # Devolution Spray
          mart_prices[3] = [-1, 0] if ITEMS.include?(3) # Max Repel
        end
      end


      for i in 2000..2032
        next unless ITEMS.include?(i)
        if defined?($PokemonSystem) && $PokemonSystem.respond_to?(:kuraystreamerdream) && $PokemonSystem.kuraystreamerdream != 0
          mart_prices[i] = [-1, 0]
        else
          if defined?($KURAYEGGS_BASEPRICE) && $KURAYEGGS_BASEPRICE[i - 2000]
            base = $KURAYEGGS_BASEPRICE[i - 2000]
            sell = (base / 2.0).round
            mart_prices[i] = [base, sell]
          end
        end
      end
      
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("StonesKurayShop: Applied Streamer's Dream and Kuray Eggs pricing")
      end
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("StonesKurayShop: Error applying pricing: #{e.class} - #{e.message}")
      end
      return nil
    end
  end

  def self.configure(items:, prices: {})
    remove_const(:ITEMS) if const_defined?(:ITEMS)
    remove_const(:PRICES) if const_defined?(:PRICES)
    const_set(:ITEMS, items)
    const_set(:PRICES, prices)
  end

  def self.get_price_for_item(item_id, selling: false)
    begin
      return nil unless PRICES.key?(item_id)
      price_data = PRICES[item_id]
      return selling ? price_data[1] : price_data[0]
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("StonesKurayShop: Error getting price for item #{item_id}: #{e.class} - #{e.message}")
      end
      return nil
    end
  end

  def self.build_display_stock(items)
    begin
      return [] if !items
      display = []
      i = 0
      while i < items.length
        e = items[i]
        if e.is_a?(Array)
          hdr = e[0].to_s.gsub(/^\-+|\-+$/, "").strip
          nested = e[1..-1] || []
          has_items = nested.any? { |it| !(it.is_a?(String) || it.is_a?(Symbol) || it.is_a?(Array)) }
          if has_items
            display << { header: hdr }
            nested.each { |it| display << it }
          end
          i += 1
        elsif e.is_a?(String) || e.is_a?(Symbol)
          hdr = e.to_s.gsub(/^\-+|\-+$/, "").strip
          j = i + 1
          found = false
          while j < items.length
            ne = items[j]
            break if ne.is_a?(String) || ne.is_a?(Symbol) || ne.is_a?(Array)
            found = true if ne
            j += 1
          end
          if found
            display << { header: hdr }
          end
          i += 1
        else
          display << e
          i += 1
        end
      end
      
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("StonesKurayShop: Built display stock with #{display.length} items")
      end
      return display
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("StonesKurayShop: Error building display stock: #{e.class} - #{e.message}")
      end
      return []
    end
  end
end

class PokemonMartScreen
  unless method_defined?(:kuray_kurayshop_orig_pbBuyScreen)
    alias_method :kuray_kurayshop_orig_pbBuyScreen, :pbBuyScreen
  end

  def pbBuyScreen
    if $game_temp && $game_temp.fromkurayshop
      begin
        old_mart_prices = $game_temp.mart_prices.nil? ? nil : $game_temp.mart_prices.clone
      rescue StandardError
        old_mart_prices = nil
      end
      begin
        old_stock = @stock.nil? ? nil : @stock.clone
      rescue StandardError
        old_stock = nil
      end

      $game_temp.mart_prices = {} if $game_temp.mart_prices.nil?

      begin
        display_stock = KurayShopMod.build_display_stock(KurayShopMod::ITEMS)

        clean_stock = []
        KurayShopMod::ITEMS.each do |it|
          if it.is_a?(Array)
            it[1..-1].each { |x| clean_stock << x if x.is_a?(Integer) }
          else
            clean_stock << it if it.is_a?(Integer)
          end
        end
        @stock = clean_stock

        clean_stock.each do |item|
          if KurayShopMod::PRICES.key?(item)
            $game_temp.mart_prices[item] = KurayShopMod::PRICES[item]
          end
        end

        KurayShopMod.apply_streamer_dream_and_eggs($game_temp.mart_prices)

        return kuray_kurayshop_orig_pbBuyScreen
      ensure
        $game_temp.mart_prices = old_mart_prices
        @stock = old_stock
      end
    else
      return kuray_kurayshop_orig_pbBuyScreen
    end
  end
end

class Window_PokemonMart
  unless method_defined?(:kuray_kurayshop_orig_drawItem)
    alias_method :kuray_kurayshop_orig_drawItem, :drawItem
  end

  def item
    return nil if !@stock || self.index >= @stock.length
    it = @stock[self.index]
    return nil if it.is_a?(Hash) && it[:header]
    return it
  end

  def drawItem(index, count, rect)
    item = @stock[index]
    if item.is_a?(Hash) && item[:header]
      rect = drawCursor(index, rect)
      ypos = rect.y
#-----------------------------------------------------------------
# HEADER COLOR (RGB VALUES)
#-----------------------------------------------------------------
      base = Color.new(255, 50, 50) # Red
      shadow = Color.new(0, 0, 0) # Shadow - Black
      textpos = []
      cx = rect.x + (rect.width / 2)
      textpos.push([item[:header], cx, ypos - 4, 2, base, shadow])
      pbDrawTextPositions(self.contents, textpos)
      return
    end
    kuray_kurayshop_orig_drawItem(index, count, rect)
  end

  unless method_defined?(:kuray_kurayshop_orig_index=)
    alias_method :kuray_kurayshop_orig_index=, :index=
  end

  def index=(value)
    return kuray_kurayshop_orig_index=(value) if !@stock || !@stock.is_a?(Array) || @item_max.nil? || @item_max<=0

    old = @index || 0
    target = value
    target = 0 if target < 0
    target = @item_max - 1 if target > @item_max - 1

    entry = @stock[target] rescue nil
    if entry.is_a?(Hash) && entry[:header]
      dir = 0
      dir = 1 if target > old
      dir = -1 if target < old
      dir = 1 if dir == 0
      newidx = target
      found = false
      (@item_max).times do
        newidx = (newidx + dir) % @item_max
        ent = @stock[newidx] rescue nil
        unless ent.is_a?(Hash) && ent[:header]
          found = true
          break
        end
      end
      target = newidx if found
    end

    kuray_kurayshop_orig_index=(target)
  end
end

class PokemonMart_Scene
  unless method_defined?(:kuray_kurayshop_orig_pbRefresh)
    alias_method :kuray_kurayshop_orig_pbRefresh, :pbRefresh
  end

  def pbRefresh
    kuray_kurayshop_orig_pbRefresh
    begin
      itemwindow = @sprites["itemwindow"]
        if itemwindow
          stock_arr = itemwindow.instance_variable_get(:@stock) rescue nil
          raw = stock_arr ? (stock_arr[itemwindow.index] rescue nil) : nil
          if raw.is_a?(Hash) && raw[:header]
            @sprites["icon"].item = nil if @sprites["icon"]
            @sprites["itemtextwindow"].text = "" if @sprites["itemtextwindow"]
          end
        end
    rescue StandardError
    end
  end

  unless method_defined?(:kuray_kurayshop_orig_pbChooseBuyItem)
    alias_method :kuray_kurayshop_orig_pbChooseBuyItem, :pbChooseBuyItem
  end

  def pbChooseBuyItem
    itemwindow = @sprites["itemwindow"]
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") {
      pbRefresh
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        if itemwindow.item != olditem
          @sprites["icon"].item = itemwindow.item
          @sprites["itemtextwindow"].text =
             (itemwindow.item && !itemwindow.item.is_a?(Hash)) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
        end
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          return nil
        elsif Input.trigger?(Input::USE)
          raw2 = itemwindow.instance_variable_get(:@stock)[itemwindow.index] rescue nil
          if raw2.is_a?(Hash) && raw2[:header]
            pbPlayCancelSE
            next
          end
          if itemwindow.index < @stock.length
            pbRefresh
            return itemwindow.item
          else
            return nil
          end
        end
      end
    }
  end
end

class PokemonMart_Scene
  unless method_defined?(:kuray_kurayshop_orig_pbStartBuyOrSellScene)
    alias_method :kuray_kurayshop_orig_pbStartBuyOrSellScene, :pbStartBuyOrSellScene
  end

  def pbStartBuyOrSellScene(buying, stock, adapter)
    rv = kuray_kurayshop_orig_pbStartBuyOrSellScene(buying, stock, adapter)
    begin
      if $game_temp && $game_temp.fromkurayshop
        iw = @sprites["itemwindow"] rescue nil
        if iw
          iw.instance_variable_set(:@stock, KurayShopMod.build_display_stock(KurayShopMod::ITEMS))
          iw.index = 0 if iw.respond_to?(:index=)
          iw.refresh if iw.respond_to?(:refresh)
        end
      end
    rescue StandardError
    end
    return rv
  end
end

# Override PokemonMartAdapter to use KurayShop custom prices
if defined?(PokemonMartAdapter)
  class PokemonMartAdapter
    unless method_defined?(:kuray_kurayshop_orig_getPrice)
      alias_method :kuray_kurayshop_orig_getPrice, :getPrice
    end

    def getPrice(item, selling = false)
      # Check if we're in the Kuray Shop
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        # Try to get price from KurayShopMod first
        custom_price = KurayShopMod.get_price_for_item(item, selling: selling)
        if custom_price
          # Apply Streamer's Dream pricing if applicable
          if !selling && defined?($game_temp.mart_prices) && $game_temp.mart_prices && $game_temp.mart_prices[item]
            price_data = $game_temp.mart_prices[item]
            return price_data[0] if price_data[0] == -1  # Free item
            return price_data[0] if price_data[0]
          end
          return custom_price
        end
      end
      
      # Fallback to original pricing
      return kuray_kurayshop_orig_getPrice(item, selling)
    end
  end
end

#===============================================================================
# Auto-Update Self-Registration
#===============================================================================
if defined?(ModSettingsMenu) && defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Stone's Kuray Shop",
    file: "03_StonesKurayShop.rb",
    version: "1.1.0",
    download_url: "https://raw.githubusercontent.com/your-repo/KIF-Mods/main/Public%20Mods/03_StonesKurayShop.rb",
    changelog_url: "https://raw.githubusercontent.com/your-repo/KIF-Mods/main/Changelogs/Stone's%20Kuray%20Shop.md",
    graphics: [],
    dependencies: []
  )
  
  begin
    version = ModSettingsMenu::ModRegistry.all["03_StonesKurayShop.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("StonesKurayShop: Stone's Kuray Shop #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
