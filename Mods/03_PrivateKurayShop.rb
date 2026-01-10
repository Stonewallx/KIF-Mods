#========================================
# Private Kuray Shop
# PIF Version: 6.4.5
# KIF Version: 0.20.6
# Script Version: 1.0.0
#========================================

module KurayShopMod
  #-----------------------------------------------------------------------
  # SHOP ORDER - Order of items in Kuray Shop
  #-----------------------------------------------------------------------
  ITEMS = [
    "NUZLOCKE ITEMS",
    263, 235, 3, 522, 581,
    598, # Ability Capsule
    "MEDICINE",
    237, 239, 240, # HP Healing Items
    228, # Status Healing Items
    245, 246, 247, 248, 249, 250, # PP Restoring Items
    "POKEBALLS",
    267, 624, 279,
    "EVOLUTION ITEMS",
    12, 13, 14, 15, 16, 17, 18, 19, 20, 211, 601, 609, 210, 660, 207, 208,
    "ITEMS",
    569, 570, 68, 121, 122, 123, 124, 125, 126, 115, 116, 100, 194,
    "TMs & HMs",
    "BERRIES",
    "BATTLE ITEMS",
    "KEY ITEMS",
    509, 599,
    "KURAY EGGS",
    2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010,
    2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021,
    2022, 2023, 2024, 2025, 2026, 2027, 2028, 2029, 2030
  ]

  #-----------------------------------------------------------------------
  # ITEM PRICES
  # Format is: ItemID => [BuyPrice, SellPrice]
  #-----------------------------------------------------------------------
  PRICES = {
    #--------- ITEMS ---------
    3 => [750, 350], # Max Repel
    570 => [6900, 3450], # Transgender Stone
    569 => [8200, 4100], # Devolution Spray
    68 => [4000, 2000], # Eviolite
    509 => [1, 1], # PokeRadar
    522 => [200, 100], # DNA Splicers
    581 => [200, 100], # DNA Reversers
    12 => [3000, 1500], # Fire Stone
    13 => [3000, 1500], # Thunder Stone
    14 => [3000, 1500], # Water Stone
    15 => [3000, 1500], # Leaf Stone
    16 => [3000, 1500], # Moon Stone
    17 => [3000, 1500], # Sun Stone
    18 => [3000, 1500], # Dusk Stone
    19 => [3000, 1500], # Dawn Stone
    20 => [3000, 1500], # Shiny Stone
    211 => [3000, 1500], # Oval Stone
    601 => [3000, 1500], # Ice Stone
    609 => [3000, 1500], # Magnet Stone
    210 => [3000, 1500], # Prism Scale
    660 => [3000, 1500], # Linking Cord
    207 => [3000, 1500], # Electrizir
    208 => [3000, 1500], # Magmarizir
    598 => [1, 1], # Ability Capsule
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
    235 => [10000, 0], # Rage Candy Bar
    263 => [10000, 0], # Rare Candy
    245 => [1200, 600], # Ether
    246 => [3600, 1800], # Ether Max
    247 => [4000, 2000], # Elixir
    248 => [12000, 6000], # Elixir Max
    249 => [5000, 2500], # PPUP
    250 => [15000, 7500], # PPMAX
    237 => [1000, 500], # Fresh Water
    239 => [1700, 850], # Lemonade
    240 => [2300, 1150], # MooMoo Milk
    228 => [1500, 750], # Full Heal
    #--------- POKEBALLS ---------
    # 264 => [960000, 0], # Master Ball
    # 623 => [1500, 750], # Rocket Ball
    267 => [100, 50], # Poke Ball
    624 => [500, 250], # Fusion Ball
    279 => [600, 300], # Quick Ball
    #--------- TMs & HMs ---------
    # 530 => [1, 1], # HM Teleport  
    # 371 => [10000, 5000], # TM Poison Jab
    # 303 => [10000, 5000], # Light Screen
    # 314 => [10000, 5000], # Return
    # 329 => [10000, 5000], # Facade
    # 335 => [10000, 5000], # Round
    # 343 => [10000, 5000], # Fling
    # 345 => [10000, 5000], # Sky Drop
    # 346 => [10000, 5000], # Incinerate
    # 356 => [10000, 5000], # Rock Polish
    # 358 => [10000, 5000], # Stone Edge
    # 367 => [10000, 5000], # Rock Throw
    # 618 => [30000, 15000], # Spore
    # 619 => [30000, 15000], # Toxic Spikes
    # 646 => [30000, 15000], # Brutal Swing
    # 647 => [30000, 15000], # Aurora Veil
    # 648 => [30000, 15000], # Dazzling Gleam
    # 649 => [30000, 15000], # Focus Punch
    # 650 => [30000, 15000], # Infestation
    # 651 => [30000, 15000], # Leech Life
    # 652 => [30000, 15000], # Power Up Punch
    # 653 => [30000, 15000], # Shock Wave
    # 654 => [30000, 15000], # Smart Strike
    # 655 => [30000, 15000], # Steel Wing
    # 656 => [30000, 15000], # Stomping Tantrum
    # 657 => [30000, 15000], # Throat Chop
    # 659 => [30000, 15000], # Scald
    #--------- BERRIES ---------
    #--------- BATTLE ITEMS ---------
    #--------- KEY ITEMS ---------
    599 => [1, 1] # Magic Boots
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
          mart_prices[3] = [750, 350] if ITEMS.include?(3) # Max Repel
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
        ModSettingsMenu.debug_log("PrivateKurayShop: Applied Streamer's Dream and Kuray Eggs pricing")
      end
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("PrivateKurayShop: Error applying pricing: #{e.class} - #{e.message}")
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
        ModSettingsMenu.debug_log("PrivateKurayShop: Error getting price for item #{item_id}: #{e.class} - #{e.message}")
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
        ModSettingsMenu.debug_log("PrivateKurayShop: Built display stock with #{display.length} items")
      end
      return display
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("PrivateKurayShop: Error building display stock: #{e.class} - #{e.message}")
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
          stock_arr = itemwindow.instance_variable_get(:@stock) rescue nil
          raw2 = stock_arr ? (stock_arr[itemwindow.index] rescue nil) : nil
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
    name: "Private Kuray Shop",
    file: "03_PrivateKurayShop.rb",
    version: "1.0.0",
    download_url: "https://raw.githubusercontent.com/your-repo/KIF-Mods/main/Private%20Mods/03_PrivateKurayShop.rb",
    changelog_url: "https://raw.githubusercontent.com/your-repo/KIF-Mods/main/Changelogs/Private%20Kuray%20Shop.md",
    graphics: [],
    dependencies: [
      { file: "01_Mod_Settings.rb", version: "3.1.3" }
    ]
  )
  
  begin
    version = ModSettingsMenu::ModRegistry.all["03_PrivateKurayShop.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("PrivateKurayShop: Private Kuray Shop #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
