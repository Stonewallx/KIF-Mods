#========================================
# Economy Mod
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 1.8.2
# Author: Stonewall
#========================================

# ============================================================================
# SALE SECTION
# ============================================================================
module EconomyMod
  module Sale
    # Configuration
    SALE_CHANCE_PERCENT = 75          # chance a sale occurs when entering a mart
    SALE_MIN_PERCENT    = 5          # minimum sale percent
    SALE_MAX_PERCENT    = 60          # maximum sale percent
    GLOBAL_VS_SINGLE_PERCENT = 3     # chance that the sale is global vs single item
    MULTI_ITEM_PERCENT = 50            # chance that the sale is on 2 items instead of 1
    ANNOUNCE_SALE = true              # show a message announcing the sale
    SALE_DURATION_HOURS = 5           # how long (in-game hours) the sale lasts
    SINGLE_ACTIVE_SALE = true

    def self.validate_sale_data!
      begin
        return unless $game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data
        data = $game_system.mart_sale_data
        st = data[:start_time]
        if st.nil?
          clear_sale
          return
        end
        elapsed = current_time_seconds - st
        if elapsed < 0 || elapsed >= sale_duration_seconds
          clear_sale
        end
      rescue => e
        ModSettingsMenu.debug_log("EconomyMod: Error validating sale data: #{e.class} - #{e.message}") if defined?(ModSettingsMenu)
      end
    end

    def self.start_sale(default_percent = nil, overrides = nil)
      $game_temp.mart_sale_percent ||= {}
      $game_temp.mart_sale_default = default_percent if default_percent
      if overrides
        overrides.each do |k, v|
          begin
            id = (k.is_a?(Symbol) || k.is_a?(String)) ? GameData::Item.get(k).id : k
          rescue => e
            ModSettingsMenu.debug_log("EconomyMod: Error converting item key #{k}: #{e.class}") if defined?(ModSettingsMenu)
            id = k
          end
          $game_temp.mart_sale_percent[id] = v
        end
      end
      ModSettingsMenu.debug_log("EconomyMod: Sale started - Default: #{default_percent}%, Overrides: #{overrides ? overrides.size : 0}") if defined?(ModSettingsMenu)
    end

    def self.clear_sale
        $game_temp.mart_sale_percent = nil
        $game_temp.mart_sale_default = nil
        $game_temp.mart_sale_active = false if $game_temp.respond_to?(:mart_sale_active=)
        if $game_system.respond_to?(:mart_sale_data=)
          $game_system.mart_sale_data = nil
        end
        $game_temp.mart_sale_announced = false if $game_temp.respond_to?(:mart_sale_announced=)
        ModSettingsMenu.debug_log("EconomyMod: Sale cleared") if defined?(ModSettingsMenu)
    end

    def self.clear_transient_sale
      $game_temp.mart_sale_percent = nil
      $game_temp.mart_sale_default = nil
      $game_temp.mart_sale_active = false if $game_temp.respond_to?(:mart_sale_active=)
      $game_temp.mart_sale_announced = false if $game_temp.respond_to?(:mart_sale_announced=)
    end

    def self.current_time_seconds
      if defined?(pbGetTimeNow)
        begin
          t = pbGetTimeNow
          return t.to_i if t
        rescue => e
          ModSettingsMenu.debug_log("EconomyMod: Error getting time from pbGetTimeNow: #{e.class}") if defined?(ModSettingsMenu)
        end
      end
      gs = $game_system
      if gs && gs.respond_to?(:play_time) && gs.play_time
        return gs.play_time.to_i
      end
      if gs && gs.respond_to?(:playtime) && gs.playtime
        return gs.playtime.to_i
      end
      if defined?(Graphics) && Graphics.respond_to?(:frame_count) && Graphics.respond_to?(:frame_rate)
        begin
          return (Graphics.frame_count / Graphics.frame_rate.to_f).to_i
        rescue => e
          ModSettingsMenu.debug_log("EconomyMod: Error calculating time from Graphics: #{e.class}") if defined?(ModSettingsMenu)
        end
      end
      return 0
    end

    def self.sale_duration_seconds
      SALE_DURATION_HOURS * 60 * 60
    end

    def self.sale_percent_for_item(item_id)
      validate_sale_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return nil
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return nil
      end
      if defined?(ModSettingsMenu) && ModSettingsMenu.get(:economymod_sales) == 0
        return nil
      end
      if $game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data
        data = $game_system.mart_sale_data
        if data[:start_time] && (current_time_seconds - data[:start_time] >= sale_duration_seconds)
          clear_sale
          return nil
        end
        per = data[:per_item] || {}
        return per[item_id] if per[item_id]
        return data[:default]
      end
      if $game_temp && $game_temp.respond_to?(:mart_sale_percent) && $game_temp.mart_sale_percent
        return $game_temp.mart_sale_percent[item_id]
      end
      if $game_temp && $game_temp.respond_to?(:mart_sale_default) && $game_temp.mart_sale_default
        return $game_temp.mart_sale_default
      end
      return nil
    end

    def self.maybe_start_sale_for_stock(stock)
      validate_sale_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return
      end
      if defined?(ModSettingsMenu) && ModSettingsMenu.get(:economymod_sales) == 0
        return
      end
      if SINGLE_ACTIVE_SALE
        if $game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data
          data = $game_system.mart_sale_data
          if data[:start_time]
            elapsed = current_time_seconds - data[:start_time]
            if elapsed >= 0 && elapsed < sale_duration_seconds
              return data
            else
              clear_sale
            end
          end
        end
      end
      if $game_temp.respond_to?(:mart_sale_active) && $game_temp.mart_sale_active
        return
      end
      return unless rand(100) < SALE_CHANCE_PERCENT

      ids = []
      stock.each do |it|
        begin
          id = GameData::Item.get(it).id
        rescue => e
          ModSettingsMenu.debug_log("EconomyMod: Error getting item ID for #{it}: #{e.class}") if defined?(ModSettingsMenu)
          id = it
        end
        ids << id if id
      end
      ids.uniq!
      return if ids.empty?

      per_item = {}
      if rand(100) < GLOBAL_VS_SINGLE_PERCENT
        percent = rand(SALE_MIN_PERCENT..SALE_MAX_PERCENT)
        ids.each { |iid| per_item[iid] = percent }
        origin = nil
        if $game_map.respond_to?(:map_id)
          origin = { map_id: $game_map.map_id }
          if $game_player && $game_player.respond_to?(:x) && $game_player.respond_to?(:y)
            origin[:x] = $game_player.x
            origin[:y] = $game_player.y
          end
        end
        sale_data = { start_time: current_time_seconds, type: :global, default: percent, per_item: per_item, origin: origin }
      else
        num_items = (rand(100) < MULTI_ITEM_PERCENT && ids.length >= 2) ? 2 : 1
        chosen = ids.sample(num_items)
        
        chosen.each do |item|
          percent = rand(SALE_MIN_PERCENT..SALE_MAX_PERCENT)
          per_item[item] = percent
        end
        
        origin = nil
        if $game_map.respond_to?(:map_id)
          origin = { map_id: $game_map.map_id }
          if $game_player && $game_player.respond_to?(:x) && $game_player.respond_to?(:y)
            origin[:x] = $game_player.x
            origin[:y] = $game_player.y
          end
        end
        
        sale_type = num_items == 2 ? :multi : :single
        sale_data = { 
          start_time: current_time_seconds, 
          type: sale_type, 
          default: nil, 
          per_item: per_item, 
          origin: origin, 
          single_item: (num_items == 1 ? chosen.first : nil),
          multi_items: (num_items == 2 ? chosen : nil)
        }
      end
      if $game_system.respond_to?(:mart_sale_data=)
        $game_system.mart_sale_data = sale_data
      end
      $game_temp.mart_sale_percent ||= {}
      $game_temp.mart_sale_start_time = sale_data[:start_time] if $game_temp.respond_to?(:mart_sale_start_time=)
      $game_temp.mart_sale_default = sale_data[:default]
      sale_data[:per_item].each { |k, v| $game_temp.mart_sale_percent[k] = v }
      $game_temp.mart_sale_active = true if $game_temp.respond_to?(:mart_sale_active=)
      return sale_data
    end

    def self.sale_header_for_stock(stock)
      validate_sale_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return nil
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return nil
      end
      if defined?(ModSettingsMenu) && ModSettingsMenu.get(:economymod_sales) == 0
        return nil
      end
      if $game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data
        data = $game_system.mart_sale_data
        per = data[:per_item] || {}
        if data[:type] == :global
          pct = data[:default] || per.values.first
          return sprintf("Sale: %d%% off!", pct) if pct && pct > 0
        elsif data[:type] == :single
          item_id = data[:single_item] || per.keys.first
          pct = per[item_id]
          name = begin; GameData::Item.get(item_id).name; rescue; item_id.to_s; end
          return sprintf("Sale: %s %d%% off!", name, pct) if pct && pct > 0
        elsif data[:type] == :multi
          items = data[:multi_items] || per.keys
          if items.length >= 2
            names = items.first(2).map { |iid| begin; GameData::Item.get(iid).name; rescue; iid.to_s; end }
            return sprintf("Sale: %s on sale!", names.join(' & '))
          end
        end
      end
      if $game_temp && $game_temp.respond_to?(:mart_sale_percent) && $game_temp.mart_sale_percent && $game_temp.mart_sale_percent.any?
        keys = $game_temp.mart_sale_percent.keys
        if keys.length == 1
          item_id = keys.first
          pct = $game_temp.mart_sale_percent[item_id]
          name = begin; GameData::Item.get(item_id).name; rescue; item_id.to_s; end
          return sprintf("Sale: %s %d%% off!", name, pct) if pct && pct > 0
        else
          names = keys.first(2).map do |k|
            begin; GameData::Item.get(k).name; rescue; k.to_s; end
          end
          pct = $game_temp.mart_sale_default
          if pct.nil?
            pct = $game_temp.mart_sale_percent[keys.first]
          end
          return sprintf("Sale: %s %d%% off!", names.join('/'), pct) if pct && pct > 0
        end
      end
      if $game_temp && $game_temp.respond_to?(:mart_sale_default) && $game_temp.mart_sale_default
        pct = $game_temp.mart_sale_default
        return sprintf("Sale: %d%% off!", pct) if pct && pct > 0
      end
      return nil
    end

    def self.sale_details_for_stock(stock)
      validate_sale_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return nil
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return nil
      end
      if defined?(ModSettingsMenu) && ModSettingsMenu.get(:economymod_sales) == 0
        return nil
      end
      lines = []
      if $game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data
        data = $game_system.mart_sale_data
        if data[:type] == :global
          pct = data[:default] || (data[:per_item] && data[:per_item].values.first)
          lines << _INTL("Sales: Everything in this shop is {1}% off!", pct)
          sample = stock.first(6).map do |iid|
            begin; GameData::Item.get(iid).name; rescue; iid.to_s; end
          end
          lines << _INTL("Examples: {1}", sample.join(', ')) if sample && sample.any?
        elsif data[:type] == :single
          per = data[:per_item] || {}
          item_id = data[:single_item] || per.keys.first
          pct = per[item_id]
          name = begin; GameData::Item.get(item_id).name; rescue; item_id.to_s; end
          lines << _INTL("Sales: {1} is {2}% off!", name, pct)
        elsif data[:type] == :multi
          per = data[:per_item] || {}
          items = data[:multi_items] || per.keys
          items.each do |item_id|
            pct = per[item_id]
            name = begin; GameData::Item.get(item_id).name; rescue; item_id.to_s; end
            lines << _INTL("{1} is {2}% off!", name, pct) if pct
          end
        end
        begin
          start_time = data[:start_time]
          if start_time
            rem = sale_duration_seconds - (current_time_seconds - start_time)
            if rem > 0
              hrs = rem / 3600
              mins = (rem % 3600) / 60
              if hrs > 0
                lines << _INTL("Time left: {1}h {2}m", hrs, mins)
              else
                lines << _INTL("Time left: {1}m", mins)
              end
            end
          end
        rescue
        end
        return lines.join("\n")
      end
      if $game_temp && $game_temp.respond_to?(:mart_sale_percent) && $game_temp.mart_sale_percent && $game_temp.mart_sale_percent.any?
        per = $game_temp.mart_sale_percent
        if per.keys.length == 1
          k = per.keys.first
          name = begin; GameData::Item.get(k).name; rescue; k.to_s; end
          pct = per[k]
          lines << _INTL("Sales: {1} is {2}% off!", name, pct)
        else
          pct = $game_temp.mart_sale_default
          if pct
            names = per.keys.first(4).map { |k| (begin; GameData::Item.get(k).name; rescue; k.to_s; end) }
            lines << _INTL("Sales: {1} are {2}% off!", names.join(', '), pct)
          else
            per.each do |k, v|
              name = begin; GameData::Item.get(k).name; rescue; k.to_s; end
              lines << _INTL("{1}: {2}% off", name, v)
            end
          end
        end
        begin
          start_time = ($game_temp.respond_to?(:mart_sale_start_time) ? $game_temp.mart_sale_start_time : nil)
          if start_time
            rem = sale_duration_seconds - (current_time_seconds - start_time)
            if rem > 0
              hrs = rem / 3600
              mins = (rem % 3600) / 60
              if hrs > 0
                lines << _INTL("Time left: {1}h {2}m", hrs, mins)
              else
                lines << _INTL("Time left: {1}m", mins)
              end
            end
          end
        rescue
        end
        return lines.join("\n")
      end
      if $game_temp && $game_temp.respond_to?(:mart_sale_default) && $game_temp.mart_sale_default
        lines << _INTL("Sales: Everything is {1}% off!", $game_temp.mart_sale_default)
        begin
          start_time = ($game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data) ? $game_system.mart_sale_data[:start_time] : ($game_temp.respond_to?(:mart_sale_start_time) ? $game_temp.mart_sale_start_time : nil)
          if start_time
            rem = sale_duration_seconds - (current_time_seconds - start_time)
            if rem > 0
              hrs = rem / 3600
              mins = (rem % 3600) / 60
              if hrs > 0
                lines << _INTL("Time left: {1}h {2}m", hrs, mins)
              else
                lines << _INTL("Time left: {1}m", mins)
              end
            end
          end
        rescue
        end
        return lines.join("\n")
      end
      return nil
    end
  end
end

# ============================================================================
# MARKUP SECTION
# Increases prices similar to Sales but never stacks: if an item is on sale,
# markup will NOT apply. Markups are also skipped in Kuray Shop.
# ============================================================================
module EconomyMod
  module Markup
    CHANCE_PERCENT = 50            # chance a markup occurs when entering a mart
    MIN_PERCENT    = 5             # minimum markup percent
    MAX_PERCENT    = 60            # maximum markup percent
    GLOBAL_VS_SINGLE_PERCENT = 0   # chance that the markup is global vs single item
    MULTI_ITEM_PERCENT = 50        # chance that the markup is on 2 items instead of 1
    DURATION_HOURS = 5             # how long (in-game hours) the markup lasts
    SINGLE_ACTIVE_MARKUP = true

    def self.validate_markup_data!
      begin
        return unless $game_system && $game_system.respond_to?(:mart_markup_data) && $game_system.mart_markup_data
        data = $game_system.mart_markup_data
        st = data[:start_time]
        if st.nil?
          clear_markup
          return
        end
        elapsed = current_time_seconds - st
        if elapsed < 0 || elapsed >= duration_seconds
          clear_markup
        end
      rescue => e
        ModSettingsMenu.debug_log("EconomyMod: Error validating markup data: #{e.class} - #{e.message}") if defined?(ModSettingsMenu)
      end
    end

    def self.current_time_seconds
      if defined?(EconomyMod::Sale) && EconomyMod::Sale.respond_to?(:current_time_seconds)
        return EconomyMod::Sale.current_time_seconds
      end
      if defined?(pbGetTimeNow)
        begin
          t = pbGetTimeNow
          return t.to_i if t
        rescue
        end
      end
      gs = $game_system
      if gs && gs.respond_to?(:play_time) && gs.play_time
        return gs.play_time.to_i
      end
      if gs && gs.respond_to?(:playtime) && gs.playtime
        return gs.playtime.to_i
      end
      if defined?(Graphics) && Graphics.respond_to?(:frame_count) && Graphics.respond_to?(:frame_rate)
        begin
          return (Graphics.frame_count / Graphics.frame_rate.to_f).to_i
        rescue
        end
      end
      return 0
    end

    def self.duration_seconds
      DURATION_HOURS * 60 * 60
    end

    def self.clear_markup
      $game_temp.mart_markup_percent = nil if $game_temp.respond_to?(:mart_markup_percent=)
      $game_temp.mart_markup_default = nil if $game_temp.respond_to?(:mart_markup_default=)
      $game_temp.mart_markup_active = false if $game_temp.respond_to?(:mart_markup_active=)
      if $game_system.respond_to?(:mart_markup_data=)
        $game_system.mart_markup_data = nil
      end
      ModSettingsMenu.debug_log("EconomyMod: Markup cleared") if defined?(ModSettingsMenu)
    end

    def self.clear_transient_markup
      $game_temp.mart_markup_percent = nil if $game_temp.respond_to?(:mart_markup_percent=)
      $game_temp.mart_markup_default = nil if $game_temp.respond_to?(:mart_markup_default=)
      $game_temp.mart_markup_active = false if $game_temp.respond_to?(:mart_markup_active=)
    end

    def self.percent_for_item(item_id)
      validate_markup_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return nil
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return nil
      end
      if defined?(ModSettingsMenu)
        begin
          return nil if ModSettingsMenu.get(:economymod_markups) == 0
        rescue => e
          ModSettingsMenu.debug_log("EconomyMod: Error checking markup setting: #{e.class}") if defined?(ModSettingsMenu)
        end
      end
      begin
        s = EconomyMod::Sale.sale_percent_for_item(item_id)
        return nil if s && s > 0
      rescue
      end
      if $game_system && $game_system.respond_to?(:mart_markup_data) && $game_system.mart_markup_data
        data = $game_system.mart_markup_data
        if data[:start_time] && (current_time_seconds - data[:start_time] >= duration_seconds)
          clear_markup
          return nil
        end
        per = data[:per_item] || {}
        return per[item_id] if per[item_id]
        return data[:default]
      end
      if $game_temp && $game_temp.respond_to?(:mart_markup_percent) && $game_temp.mart_markup_percent
        return $game_temp.mart_markup_percent[item_id]
      end
      if $game_temp && $game_temp.respond_to?(:mart_markup_default) && $game_temp.mart_markup_default
        return $game_temp.mart_markup_default
      end
      return nil
    end

    def self.maybe_start_markup_for_stock(stock)
      validate_markup_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return
      end
      if SINGLE_ACTIVE_MARKUP
        if $game_system && $game_system.respond_to?(:mart_markup_data) && $game_system.mart_markup_data
          data = $game_system.mart_markup_data
          if data[:start_time]
            elapsed = current_time_seconds - data[:start_time]
            if elapsed >= 0 && elapsed < duration_seconds
              return data
            else
              clear_markup
            end
          end
        end
      end
      if $game_temp.respond_to?(:mart_markup_active) && $game_temp.mart_markup_active
        return
      end
      return unless rand(100) < CHANCE_PERCENT

      ids = []
      stock.each do |it|
        begin
          id = GameData::Item.get(it).id
        rescue
          id = it
        end
        ids << id if id
      end
      ids.uniq!
      return if ids.empty?

      per_item = {}
      if rand(100) < GLOBAL_VS_SINGLE_PERCENT
        percent = rand(MIN_PERCENT..MAX_PERCENT)
        ids.each { |iid| per_item[iid] = percent }
        origin = nil
        if $game_map.respond_to?(:map_id)
          origin = { map_id: $game_map.map_id }
          if $game_player && $game_player.respond_to?(:x) && $game_player.respond_to?(:y)
            origin[:x] = $game_player.x
            origin[:y] = $game_player.y
          end
        end
        markup_data = { start_time: current_time_seconds, type: :global, default: percent, per_item: per_item, origin: origin }
      else
        num_items = (rand(100) < MULTI_ITEM_PERCENT && ids.length >= 2) ? 2 : 1
        chosen = ids.sample(num_items)
        chosen.each do |item|
          percent = rand(MIN_PERCENT..MAX_PERCENT)
          per_item[item] = percent
        end
        origin = nil
        if $game_map.respond_to?(:map_id)
          origin = { map_id: $game_map.map_id }
          if $game_player && $game_player.respond_to?(:x) && $game_player.respond_to?(:y)
            origin[:x] = $game_player.x
            origin[:y] = $game_player.y
          end
        end
        markup_type = (num_items == 2) ? :multi : :single
        markup_data = {
          start_time: current_time_seconds,
          type: markup_type,
          default: nil,
          per_item: per_item,
          origin: origin,
          single_item: (num_items == 1 ? chosen.first : nil),
          multi_items: (num_items == 2 ? chosen : nil)
        }
      end
      if $game_system.respond_to?(:mart_markup_data=)
        $game_system.mart_markup_data = markup_data
      end
      $game_temp.mart_markup_percent ||= {}
      $game_temp.mart_markup_default = markup_data[:default] if $game_temp.respond_to?(:mart_markup_default=)
      markup_data[:per_item].each { |k, v| $game_temp.mart_markup_percent[k] = v }
      $game_temp.mart_markup_active = true if $game_temp.respond_to?(:mart_markup_active=)
      return markup_data
    end
  end
end
# ============================================================================
# END OF MARKUP SECTION
# ============================================================================
module EconomyMod
  module Markup
    def self.markup_header_for_stock(stock)
      validate_markup_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return nil
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return nil
      end
      if defined?(ModSettingsMenu) && ModSettingsMenu.get(:economymod_markups) == 0
        return nil
      end
      begin
        data = ($game_system && $game_system.respond_to?(:mart_markup_data)) ? $game_system.mart_markup_data : nil
        return nil unless data
        per = data[:per_item] || {}
        if data[:type] == :global
          pct = data[:default] || per.values.first
          return sprintf("Markup: +%d%% on all items", pct) if pct && pct > 0
        elsif data[:type] == :single
          item_id = data[:single_item] || per.keys.first
          pct = per[item_id]
          name = begin; GameData::Item.get(item_id).name; rescue; item_id.to_s; end
          return sprintf("Markup: %s +%d%%", name, pct) if pct && pct > 0
        elsif data[:type] == :multi
          items = data[:multi_items] || per.keys
          if items && items.length >= 2
            names = items.first(2).map { |iid| begin; GameData::Item.get(iid).name; rescue; iid.to_s; end }
            return sprintf("Markup: %s are marked up", names.join(' & '))
          end
        end
      rescue
      end
      return nil
    end

    def self.markup_details_for_stock(stock)
      validate_markup_data!
      if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
        return nil
      end
      if $game_temp && $game_temp.respond_to?(:in_outfit_menu) && $game_temp.in_outfit_menu
        return nil
      end
      if defined?(ModSettingsMenu) && ModSettingsMenu.get(:economymod_markups) == 0
        return nil
      end
      lines = []
      begin
        data = ($game_system && $game_system.respond_to?(:mart_markup_data)) ? $game_system.mart_markup_data : nil
        return nil unless data
        if data[:type] == :global
          pct = data[:default] || (data[:per_item] && data[:per_item].values.first)
          lines << _INTL("Markups: Everything in this shop costs +{1}% more.", pct)
          sample = stock.first(6).map do |iid|
            begin; GameData::Item.get(iid).name; rescue; iid.to_s; end
          end
          lines << _INTL("Examples: {1}", sample.join(', ')) if sample && sample.any?
        elsif data[:type] == :single
          per = data[:per_item] || {}
          item_id = data[:single_item] || per.keys.first
          pct = per[item_id]
          name = begin; GameData::Item.get(item_id).name; rescue; item_id.to_s; end
          lines << _INTL("Markups: {1} costs +{2}% more.", name, pct)
        elsif data[:type] == :multi
          per = data[:per_item] || {}
          items = data[:multi_items] || per.keys
          items.each do |item_id|
            pct = per[item_id]
            name = begin; GameData::Item.get(item_id).name; rescue; item_id.to_s; end
            lines << _INTL("{1} costs +{2}% more.", name, pct) if pct
          end
        end
        begin
          start_time = data[:start_time]
          if start_time
            rem = EconomyMod::Markup.duration_seconds - (EconomyMod::Markup.current_time_seconds - start_time)
            if rem > 0
              hrs = rem / 3600
              mins = (rem % 3600) / 60
              if hrs > 0
                lines << _INTL("Time left: {1}h {2}m", hrs, mins)
              else
                lines << _INTL("Time left: {1}m", mins)
              end
            end
          end
        rescue
        end
      rescue
      end
      return lines.any? ? lines.join("\n") : nil
    end
  end
end

if defined?(PokemonMart_Scene)
  class PokemonMart_Scene
    unless method_defined?(:economymod_orig_pbChooseBuyItem)
      alias :economymod_orig_pbChooseBuyItem :pbChooseBuyItem
    end

    def pbChooseBuyItem
      return economymod_orig_pbChooseBuyItem
    end
  end
end

if defined?(PokemonMart_Scene)
  class PokemonMart_Scene
    unless method_defined?(:economymod_orig_update)
      alias :economymod_orig_update :update
    end

    def update
      economymod_orig_update

      begin
        iw = @sprites && @sprites["itemwindow"]
        if iw && iw.visible
          if Input.trigger?(Input::AUX2)
              if defined?(EconomyMod)
                if $game_temp.respond_to?(:mart_sale_details_open) && $game_temp.mart_sale_details_open
                  return
                end
                sale_details = (EconomyMod::Sale.respond_to?(:sale_details_for_stock) ? (EconomyMod::Sale.sale_details_for_stock(@stock) rescue nil) : nil)
                sale_header = (EconomyMod::Sale.respond_to?(:sale_header_for_stock) ? (EconomyMod::Sale.sale_header_for_stock(@stock) rescue nil) : nil)
                markup_details = (EconomyMod::Markup.respond_to?(:markup_details_for_stock) ? (EconomyMod::Markup.markup_details_for_stock(@stock) rescue nil) : nil)
                markup_header = (EconomyMod::Markup.respond_to?(:markup_header_for_stock) ? (EconomyMod::Markup.markup_header_for_stock(@stock) rescue nil) : nil)
                combined_header = [sale_header, markup_header].compact.join("\n")
                combined_details = [sale_details, markup_details].compact.join("\n\n")
                if combined_details.length > 0 || combined_header.length > 0
                  begin
                    $game_temp.mart_sale_details_open = true if $game_temp.respond_to?(:mart_sale_details_open=)
                    pbPlayDecisionSE
                    pbDisplayPaused(combined_details.empty? ? combined_header : combined_details)
                  ensure
                    $game_temp.mart_sale_details_open = false if $game_temp.respond_to?(:mart_sale_details_open=)
                  end
                  10.times do
                    Graphics.update
                    Input.update
                    break unless Input.trigger?(Input::USE) || Input.trigger?(Input::AUX2)
                  end
                  pbRefresh
                else
                  begin
                    $game_temp.mart_sale_details_open = true if $game_temp.respond_to?(:mart_sale_details_open=)
                    pbPlayCancelSE
                    pbDisplayPaused(_INTL("There are no sales or markups right now."))
                  ensure
                    $game_temp.mart_sale_details_open = false if $game_temp.respond_to?(:mart_sale_details_open=)
                  end
                  10.times do
                    Graphics.update
                    Input.update
                    break unless Input.trigger?(Input::USE) || Input.trigger?(Input::AUX2)
                  end
                  pbRefresh
                end
              end
            end
          end
        end
      rescue StandardError
      end
    end
  end

MartSale = EconomyMod::Sale

class PokemonMartAdapter
  unless method_defined?(:martsale_orig_getPrice)
    alias :martsale_orig_getPrice :getPrice
  end
  unless method_defined?(:martsale_orig_getDisplayPrice)
    alias :martsale_orig_getDisplayPrice :getDisplayPrice
  end

  def getBasePriceWithCustom(item, selling = false)
    if defined?(Outfit) && item.is_a?(Outfit)
      return martsale_orig_getPrice(item, selling)
    end
    
    base_price = martsale_orig_getPrice(item, selling)
    
    if base_price > 0
      if !($game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop)
        if defined?(EconomyMod) && EconomyMod::CustomPrices.respond_to?(:get_custom_price)
          custom_price = EconomyMod::CustomPrices.get_custom_price(item, !selling)
          base_price = custom_price if custom_price
        end
      end
    end
    
    return base_price
  end

  def getPrice(item, selling = false)
    if defined?(Outfit) && item.is_a?(Outfit)
      return martsale_orig_getPrice(item, selling)
    end
    
    base_price = getBasePriceWithCustom(item, selling)
    
    return base_price if selling || base_price <= 0
    if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
      return base_price
    end
    sales_enabled = true
    if defined?(ModSettingsMenu)
      begin
        sales_enabled = !(ModSettingsMenu.get(:economymod_sales) == 0)
      rescue
      end
    end
    spercent = nil
    if sales_enabled && defined?(EconomyMod) && EconomyMod::Sale.respond_to?(:sale_percent_for_item)
      spercent = EconomyMod::Sale.sale_percent_for_item(item)
    end
    if sales_enabled && spercent.nil? && $game_temp.respond_to?(:mart_sale_percent) && $game_temp.mart_sale_percent
      spercent = $game_temp.mart_sale_percent[item]
    end
    if sales_enabled && spercent.nil? && $game_temp.respond_to?(:mart_sale_default) && $game_temp.mart_sale_default
      spercent = $game_temp.mart_sale_default
    end
    if sales_enabled && spercent && spercent > 0
      sale_price = (base_price * (100 - spercent) / 100.0).floor
      sale_price = 1 if sale_price < 1
      return sale_price
    end
    mpercent = nil
    if defined?(EconomyMod) && EconomyMod::Markup.respond_to?(:percent_for_item)
      mpercent = EconomyMod::Markup.percent_for_item(item)
    end
    if mpercent && mpercent > 0
      markup_price = (base_price * (100 + mpercent) / 100.0).floor
      markup_price = [markup_price, base_price + 1].max
      return markup_price
    end
    return base_price
  end

  def getDisplayPrice(item, selling = false)
    if defined?(Outfit) && item.is_a?(Outfit)
      return martsale_orig_getDisplayPrice(item, selling)
    end
    
    if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
      base_price = martsale_orig_getPrice(item, false)
      return _INTL("$ {1}", base_price.to_s_formatted)
    end
    price = getPrice(item, selling)
    if !selling
      base_price = martsale_orig_getPrice(item, false)
      spercent = nil
      sales_enabled = true
      if defined?(ModSettingsMenu)
        begin
          sales_enabled = !(ModSettingsMenu.get(:economymod_sales) == 0)
        rescue
        end
      end
      if sales_enabled && defined?(EconomyMod) && EconomyMod::Sale.respond_to?(:sale_percent_for_item)
        spercent = EconomyMod::Sale.sale_percent_for_item(item)
      end
      if sales_enabled && spercent.nil? && $game_temp.respond_to?(:mart_sale_percent) && $game_temp.mart_sale_percent
        spercent = $game_temp.mart_sale_percent[item]
      end
      if sales_enabled && spercent.nil? && $game_temp.respond_to?(:mart_sale_default) && $game_temp.mart_sale_default
        spercent = $game_temp.mart_sale_default
      end
      if sales_enabled && spercent && base_price > 0 && price != base_price
        return _INTL("$ {1}  (was $ {2})", price.to_s_formatted, base_price.to_s_formatted)
      end
    end
    return _INTL("$ {1}", price.to_s_formatted)
  end
end

if defined?(PokemonMart_Scene)
  class PokemonMart_Scene
    unless method_defined?(:martsale_orig_pbStartBuyOrSellScene)
      alias :martsale_orig_pbStartBuyOrSellScene :pbStartBuyOrSellScene
    end

    def pbStartBuyOrSellScene(buying, stock, adapter)
      martsale_orig_pbStartBuyOrSellScene(buying, stock, adapter)

      begin
        base_adapter = (adapter.respond_to?(:getAdapter) ? adapter.getAdapter : adapter)
        is_outfit_menu = defined?(OutfitsMartAdapter) && base_adapter.is_a?(OutfitsMartAdapter)
        $game_temp.in_outfit_menu = is_outfit_menu if $game_temp.respond_to?(:in_outfit_menu=)
        
        EconomyMod::Sale.maybe_start_sale_for_stock(stock)
        EconomyMod::Markup.maybe_start_markup_for_stock(stock) if defined?(EconomyMod::Markup)
        if defined?(EconomyMod) && EconomyMod::Sale.respond_to?(:sale_header_for_stock)
          sale_header = EconomyMod::Sale.sale_header_for_stock(stock) rescue nil
          markup_header = (EconomyMod::Markup.respond_to?(:markup_header_for_stock) ? (EconomyMod::Markup.markup_header_for_stock(stock) rescue nil) : nil)
          combined_header = [sale_header, markup_header].compact.join("\n")
          if combined_header && combined_header.strip.length > 0
            announced = false
            if $game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data && $game_system.mart_sale_data.is_a?(Hash)
              announced = !!$game_system.mart_sale_data[:announced]
            else
              announced = ($game_temp.respond_to?(:mart_sale_announced) && $game_temp.mart_sale_announced)
            end
            unless announced
              sale_details = (EconomyMod::Sale.respond_to?(:sale_details_for_stock) ? EconomyMod::Sale.sale_details_for_stock(stock) : nil) rescue nil
              markup_details = (EconomyMod::Markup.respond_to?(:markup_details_for_stock) ? (EconomyMod::Markup.markup_details_for_stock(stock) rescue nil) : nil)
              details = [sale_details, markup_details].compact.join("\n\n")
              begin
                $game_temp.mart_sale_details_open = true if $game_temp.respond_to?(:mart_sale_details_open=)
                pbDisplayPaused(details.empty? ? combined_header : details)
              ensure
                $game_temp.mart_sale_details_open = false if $game_temp.respond_to?(:mart_sale_details_open=)
              end
              if $game_system && $game_system.respond_to?(:mart_sale_data) && $game_system.mart_sale_data
                $game_system.mart_sale_data[:announced] = true
              else
                $game_temp.mart_sale_announced = true if $game_temp.respond_to?(:mart_sale_announced=)
              end
            end
          end
        end
      rescue StandardError
      end
    end
    
    unless method_defined?(:martsale_orig_pbEndBuyScene)
      alias :martsale_orig_pbEndBuyScene :pbEndBuyScene rescue nil
    end
    def pbEndBuyScene
      begin
        martsale_orig_pbEndBuyScene if respond_to?(:martsale_orig_pbEndBuyScene)
      ensure
        $game_temp.in_outfit_menu = false if $game_temp.respond_to?(:in_outfit_menu=)
        EconomyMod::Sale.clear_transient_sale
        EconomyMod::Markup.clear_transient_markup if defined?(EconomyMod::Markup)
      end
    end

    unless method_defined?(:martsale_orig_pbEndSellScene)
      alias :martsale_orig_pbEndSellScene :pbEndSellScene rescue nil
    end
    def pbEndSellScene
      begin
        martsale_orig_pbEndSellScene if respond_to?(:martsale_orig_pbEndSellScene)
      ensure
        $game_temp.in_outfit_menu = false if $game_temp.respond_to?(:in_outfit_menu=)
        EconomyMod::Sale.clear_transient_sale
        EconomyMod::Markup.clear_transient_markup if defined?(EconomyMod::Markup)
      end
    end
  end
end

class Game_Temp
  unless method_defined?(:mart_sale_percent)
    attr_accessor :mart_sale_percent
  end
  unless method_defined?(:mart_sale_default)
    attr_accessor :mart_sale_default
  end
  unless method_defined?(:mart_sale_active)
    attr_accessor :mart_sale_active
  end
  unless method_defined?(:mart_sale_announced)
    attr_accessor :mart_sale_announced
  end
  unless method_defined?(:mart_sale_pending)
    attr_accessor :mart_sale_pending
  end
  unless method_defined?(:mart_sale_start_time)
    attr_accessor :mart_sale_start_time
  end
  unless method_defined?(:mart_sale_details_open)
    attr_accessor :mart_sale_details_open
  end
  unless method_defined?(:mart_markup_percent)
    attr_accessor :mart_markup_percent
  end
  unless method_defined?(:mart_markup_default)
    attr_accessor :mart_markup_default
  end
  unless method_defined?(:mart_markup_active)
    attr_accessor :mart_markup_active
  end
  unless method_defined?(:nature_change_open)
    attr_accessor :nature_change_open
  end
  unless method_defined?(:in_outfit_menu)
    attr_accessor :in_outfit_menu
  end
end

class Game_System
  unless method_defined?(:mart_sale_data)
    attr_accessor :mart_sale_data
  end
  unless method_defined?(:mart_markup_data)
    attr_accessor :mart_markup_data
  end
end

class Window_PokemonMart
  def itemCount
    return @stock.length + 1
  end

  def item
    return (self.index >= @stock.length) ? nil : @stock[self.index]
  end

  def drawItem(index, count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    ypos = rect.y

    
    if index == count-1
      textpos.push([_INTL("CANCEL"), rect.x, ypos - 4, false, self.baseColor, self.shadowColor])
      pbDrawTextPositions(self.contents, textpos)
      return
    end
    item = @stock[index]
    if item.is_a?(Symbol) && @adapter.respond_to?(:getAdapter) && @adapter.getAdapter().is_a?(OutfitsMartAdapter)
      itemname = @adapter.getSpecialItemCaption(item)
      baseColor = @adapter.getSpecialItemBaseColor(item) ? @adapter.getSpecialItemBaseColor(item) : baseColor
      shadowColor = @adapter.getSpecialItemShadowColor(item) ? @adapter.getSpecialItemShadowColor(item) : shadowColor
      textpos.push([itemname, rect.x, ypos - 4, false, baseColor, shadowColor])
      pbDrawTextPositions(self.contents, textpos)
      return
    end
    if defined?(Outfit) && item.is_a?(Outfit)
      itemname = @adapter.getDisplayName(item) rescue ""
      qty = @adapter.getDisplayPrice(item) rescue _INTL("$ {1}", 0.to_s_formatted)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      textpos.push([itemname, rect.x, ypos - 4, false, self.baseColor, self.shadowColor])
      textpos.push([qty, xQty, ypos - 4, false, self.baseColor, self.shadowColor])
      pbDrawTextPositions(self.contents, textpos)
      return
    end
    itemname = @adapter.getDisplayName(item) rescue ""

    baseColorOverride = @adapter.getBaseColorOverride(item) rescue nil
    shadowColorOverride = @adapter.getShadowColorOverride(item) rescue nil

    baseColor = baseColorOverride ? baseColorOverride : self.baseColor
    shadowColor = shadowColorOverride ? shadowColorOverride : self.shadowColor

    if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
      qty = @adapter.getDisplayPrice(item) rescue _INTL("$ {1}", 0.to_s_formatted)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      textpos.push([itemname, rect.x, ypos - 4, false, baseColor, shadowColor])
      textpos.push([qty, xQty, ypos - 4, false, baseColor, shadowColor])
      pbDrawTextPositions(self.contents, textpos)
      return
    end

    base_adapter = (@adapter.respond_to?(:getAdapter) ? @adapter.getAdapter : @adapter)

    base_price = nil
    if @adapter.respond_to?(:getBasePriceWithCustom)
      base_price = @adapter.getBasePriceWithCustom(item, false)
    elsif base_adapter.respond_to?(:getBasePriceWithCustom)
      base_price = base_adapter.getBasePriceWithCustom(item, false)
    elsif base_adapter.respond_to?(:getPrice)
      base_price = base_adapter.getPrice(item, false)
    else
      begin
        base_price = GameData::Item.get(item).price
      rescue
        base_price = nil
      end
    end

    sale_price = nil
    if @adapter.respond_to?(:getPrice)
      sale_price = @adapter.getPrice(item, false)
    elsif @adapter.respond_to?(:getDisplayPrice)
      display = @adapter.getDisplayPrice(item) rescue nil
      if display && display.is_a?(String)
        nums = display.scan(/\d[\d,]*/).first
        sale_price = nums ? nums.gsub(",", "").to_i : nil
      end
    end

    if sale_price.nil? || base_price.nil? || base_price <= 0 || sale_price == base_price
      qty = @adapter.getDisplayPrice(item) rescue _INTL("$ {1}", (sale_price || 0).to_s_formatted)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      textpos.push([itemname, rect.x, ypos - 4, false, baseColor, shadowColor])
      textpos.push([qty, xQty, ypos - 4, false, baseColor, shadowColor])
      pbDrawTextPositions(self.contents, textpos)
      return
    end

    if sale_price < base_price
      sale_text = _INTL("$ {1}", sale_price.to_s_formatted)
      old_text = _INTL("$ {1}", base_price.to_s_formatted)
      sizeOld = self.contents.text_size(old_text).width
      sizeSale = self.contents.text_size(sale_text).width
      xOld = rect.x + rect.width - sizeOld - 2 - 16
      xSale = xOld - sizeSale - 8

      textpos.push([itemname, rect.x, ypos - 4, false, baseColor, shadowColor])
      # Draw sale price in red
      redBase = Color.new(220, 64, 64)
      redShadow = Color.new(120, 24, 24)
      textpos.push([sale_text, xSale, ypos - 4, false, redBase, redShadow])
      textpos.push([old_text, xOld, ypos - 4, false, baseColor, shadowColor])
      pbDrawTextPositions(self.contents, textpos)

      # Draw strikethrough over original price
      text_height = self.contents.text_size(old_text).height
      yline = ypos - 4 + (text_height / 2) + 9
      line_color = Color.new(160, 24, 24)
      self.contents.fill_rect(xOld, yline, sizeOld, 3, line_color)
    else
      # Markup case: show markup price in blue and original price struck through
      markup_text = _INTL("$ {1}", sale_price.to_s_formatted)
      old_text = _INTL("$ {1}", base_price.to_s_formatted)
      sizeOld = self.contents.text_size(old_text).width
      sizeMarkup = self.contents.text_size(markup_text).width
      xOld = rect.x + rect.width - sizeOld - 2 - 16
      xMarkup = xOld - sizeMarkup - 8

      textpos.push([itemname, rect.x, ypos - 4, false, baseColor, shadowColor])
      blueBase = Color.new(64, 96, 220)
      blueShadow = Color.new(24, 36, 120)
      textpos.push([markup_text, xMarkup, ypos - 4, false, blueBase, blueShadow])
      textpos.push([old_text, xOld, ypos - 4, false, baseColor, shadowColor])
      pbDrawTextPositions(self.contents, textpos)

      # Draw strikethrough over original (lower) price
      text_height = self.contents.text_size(old_text).height
      yline = ypos - 4 + (text_height / 2) + 9
      line_color = Color.new(32, 48, 160)
      self.contents.fill_rect(xOld, yline, sizeOld, 3, line_color)
    end
  end
end

# ============================================================================
# END OF SALE SECTION
# ============================================================================

# ============================================================================
# INITIAL MONEY SECTION
# ============================================================================
module EconomyMod
  module InitialMoney
    DEFAULT_STARTING_MONEY = 3000  # Initial money amount, default is 3000
    ENABLED = true                  

    def self.get_starting_money
      if defined?(ModSettingsMenu)
        amount = ModSettingsMenu.get(:economymod_starting_money)
        return amount if amount && amount > 0
      end
      return DEFAULT_STARTING_MONEY
    end

    def self.enabled?
      if defined?(ModSettingsMenu)
        enabled = ModSettingsMenu.get(:economymod_starting_money_enabled)
        return enabled unless enabled.nil?
      end
      return ENABLED
    end
  end
end

# ============================================================================
# BATTLE MONEY SECTION
# ============================================================================
module EconomyMod
  module BattleMoney
    # Money multiplier for battle rewards
    DEFAULT_BATTLE_MONEY_MULTIPLIER = 1.0
    ENABLED = true

    def self.multiplier
      if defined?(ModSettingsMenu)
        m = ModSettingsMenu.get(:economymod_battle_money_multiplier)
        if m
          m = m.to_i
          m = 1 if m < 1
          m = 10 if m > 10
          return m
        end
      end
      return DEFAULT_BATTLE_MONEY_MULTIPLIER.to_i
    end

    def self.enabled?
      if defined?(ModSettingsMenu)
        e = ModSettingsMenu.get(:economymod_battle_money_enabled)
        return e == 1 || e == true
      end
      return ENABLED
    end
  end
end

begin
  if defined?(PokeBattle_Battle) && !PokeBattle_Battle.method_defined?(:economymod_orig_pbGainMoney)
    class PokeBattle_Battle
      alias economymod_orig_pbGainMoney pbGainMoney
      def pbGainMoney
        return economymod_orig_pbGainMoney unless EconomyMod::BattleMoney.enabled?
      end
    end
  end
rescue
end

begin
  if defined?(PokeBattle_Battle) && !PokeBattle_Battle.method_defined?(:economymod_pbGainMoney)
    class PokeBattle_Battle
      alias economymod_original_pbGainMoney pbGainMoney
      def pbGainMoney
        return if $game_switches[SWITCH_IS_REMATCH]
        return if !@internalBattle || !@moneyGain
        if $PokemonSystem.nomoneylost && $PokemonSystem.nomoneylost != 0
          $PokemonSystem.nomoneylost = 0
          return
        end
        battle_mult = (EconomyMod::BattleMoney.enabled? ? EconomyMod::BattleMoney.multiplier : 1.0)
        # Trainer prize money
        if trainerBattle?
          tMoney = 0
          @opponent.each_with_index do |t,i|
            tMoney += pbMaxLevelInTeam(1, i) * t.base_money
          end
          tMoney *= 2 if @field.effects[PBEffects::AmuletCoin]
          tMoney *= 2 if @field.effects[PBEffects::HappyHour]
          tMoney = (tMoney * battle_mult).round if battle_mult && battle_mult > 0
          oldMoney = pbPlayer.money
            pbPlayer.money += tMoney
          moneyGained = pbPlayer.money - oldMoney
          if moneyGained > 0
            pbDisplayPaused(_INTL("You got ${1} for winning!", moneyGained.to_s_formatted))
          end
        end
        # Pay Day pickup
        if @field.effects[PBEffects::PayDay] > 0
          payMoney = @field.effects[PBEffects::PayDay]
          payMoney *= 2 if @field.effects[PBEffects::AmuletCoin]
          payMoney *= 2 if @field.effects[PBEffects::HappyHour]
          payMoney = (payMoney * battle_mult).round if battle_mult && battle_mult > 0
          oldMoney = pbPlayer.money
          pbPlayer.money += payMoney
          moneyGained = pbPlayer.money - oldMoney
          if moneyGained > 0
            pbDisplayPaused(_INTL("You picked up ${1}!", moneyGained.to_s_formatted))
          end
        end
      end
    end
  end
rescue
end

# ============================================================================
# END OF BATTLE MONEY SECTION
# ============================================================================
if defined?(PokemonLoadScreen)
  module EconomyMod_NewGameOverride
    def pbStartNewGame
      super
      if defined?(EconomyMod) && EconomyMod::InitialMoney.enabled?
        starting_money = EconomyMod::InitialMoney.get_starting_money
        if defined?($Trainer) && $Trainer && $Trainer.respond_to?(:money=)
          $Trainer.money = starting_money
        end
      end
    end
  end

  class PokemonLoadScreen
    prepend EconomyMod_NewGameOverride
  end
end

begin
  module Game
    class << self
      unless method_defined?(:economymod_orig_start_new)
        alias economymod_orig_start_new start_new
      end
      def start_new(*args)
        economymod_orig_start_new(*args)
        begin
          if defined?(EconomyMod) && EconomyMod::InitialMoney.enabled?
            starting_money = EconomyMod::InitialMoney.get_starting_money
            if defined?($Trainer) && $Trainer && $Trainer.respond_to?(:money=)
              $Trainer.money = starting_money
            end
          end
        rescue
        end
      end
    end
  end
rescue
end

# ============================================================================
# END OF INITIAL MONEY SECTION
# ============================================================================

# ============================================================================
# POKEVIAL COST SECTION
# ============================================================================
module EconomyMod
  module PokeVialCost
    DEFAULT_COST_PER_USE = 300
    ENABLED = true

    def self.cost_per_use
      if defined?(ModSettingsMenu)
        cost = ModSettingsMenu.get(:economymod_pokevial_cost)
        return cost if cost && cost >= 0
      end
      return DEFAULT_COST_PER_USE
    end

    def self.enabled?
      if defined?(ModSettingsMenu)
        e = ModSettingsMenu.get(:economymod_pokevial_cost_enabled)
        return e == 1 || e == true unless e.nil?
      end
      return ENABLED
    end

    def self.calculate_refill_cost
      return 0 unless enabled?
      begin
        if defined?(PauseMenuPokeVial)
          max_uses = PauseMenuPokeVial.configured_max_uses rescue 0
          return max_uses * cost_per_use
        end
      rescue
      end
      return 0
    end
  end
end

# ============================================================================
# END OF POKEVIAL COST SECTION
# ============================================================================

# ============================================================================
# BONUS GIFTS SECTION
# Random free item after a successful mart purchase
# - Skips Kuray Shop
# - At most 1 gift per purchase
# - Configurable daily limit and chance
# - Configurable pool with quantities
# ============================================================================
module EconomyMod
  module BonusGifts
    ENABLED               = true
    BLOCK_IN_KURAY_SHOP   = true
    CHANCE_PERCENT        = 50        # % Chance per purchase (0-100)
    ROLLS_PER_PURCHASE    = 1         # Independent rolls per purchase (each respects chance)
    DAILY_LIMIT           = 3         # Max gifts per 24 in-game hours
    SHOW_PREFIX_MESSAGE   = true      # Show a short message before granting

    POOL = [
      # [:item_symbol, min_quantity, max_quantity]]
      [:POTION, 1, 1],
      [:SUPERPOTION, 1, 1],
      [:HYPERPOTION, 1, 1],
      [:POKEBALL, 1, 1],
      [:GREATBALL, 1, 1],
      [:ULTRABALL, 1, 1],
      [:REVIVE, 1, 1],
      [:FUSIONBALL, 1, 1],
      [:ANTIDOTE, 1, 1],
      [:AWAKENING, 1, 1],
      [:PARALYZHEAL, 1, 1],
      [:BURNHEAL, 1, 1],
      [:ICEHEAL, 1, 1],
      [:FULLHEAL, 1, 1],
      [:ROCKETMEAL, 1, 1],
      [:ELIXIR, 1, 1],
      [:ETHER, 1, 1],
      [:PPUP, 1, 1],
      [:PIZZA, 1, 1],
      [:MAXREVIVE, 1, 1],
      [:DNAREVERSER, 1, 1],
      [:DNASPLICERS, 1, 1],
      [:RAGECANDYBAR, 1, 1],
      [:RARECANDY, 1, 1]
    ]

    def self.get_setting
      if defined?(ModSettingsMenu)
        begin
          v = ModSettingsMenu.get(:economymod_bonus_gifts_enabled)
          return v.nil? ? nil : v
        rescue
        end
      end
      if $game_system && $game_system.respond_to?(:economymod_bonus_gifts_enabled)
        return $game_system.economymod_bonus_gifts_enabled
      end
      return nil
    end

    def self.set_setting(val)
      if defined?(ModSettingsMenu)
        begin
          ModSettingsMenu.ensure_storage
          st = ModSettingsMenu.storage
          st[:economymod_bonus_gifts_enabled] = (val ? 1 : 0)
          return
        rescue
        end
      end
      if $game_system && $game_system.respond_to?(:economymod_bonus_gifts_enabled=)
        $game_system.economymod_bonus_gifts_enabled = (val ? 1 : 0)
      end
    end

    def self.setting_on?
      v = get_setting
      return (v.nil? ? ENABLED : (v == 1 || v == true))
    end

    def self.toggle_setting!
      set_setting(!setting_on?)
    end

    def self.enabled?
      return setting_on?
    end

    WINDOW_DURATION_HOURS = 24

    def self.current_time_seconds
      if defined?(EconomyMod::Sale) && EconomyMod::Sale.respond_to?(:current_time_seconds)
        begin
          return EconomyMod::Sale.current_time_seconds
        rescue
        end
      end
      if defined?(pbGetTimeNow)
        begin
          return pbGetTimeNow.to_i
        rescue
        end
      end
      gs = $game_system
      if gs && gs.respond_to?(:play_time) && gs.play_time
        return gs.play_time.to_i
      end
      if gs && gs.respond_to?(:playtime) && gs.playtime
        return gs.playtime.to_i
      end
      return Time.now.to_i  
    end

    def self.window_duration_seconds
      WINDOW_DURATION_HOURS * 60 * 60
    end

    def self.ensure_window_initialized
      return unless $game_system
      if !$game_system.respond_to?(:mart_bonusgift_window_start) || !$game_system.respond_to?(:mart_bonusgift_count_for_window)
        return
      end
      start = $game_system.mart_bonusgift_window_start
      now = current_time_seconds
      if start.nil? || (now - start) >= window_duration_seconds
        $game_system.mart_bonusgift_window_start = now
        $game_system.mart_bonusgift_count_for_window = 0
      end
    end

    def self.get_count_for_window
      $game_system ||= nil
      return 0 unless $game_system
      ensure_window_initialized
      return ($game_system.respond_to?(:mart_bonusgift_count_for_window) ? ($game_system.mart_bonusgift_count_for_window || 0) : 0)
    end

    def self.increment_count_for_window
      return unless $game_system
      ensure_window_initialized
      if $game_system.respond_to?(:mart_bonusgift_count_for_window=)
        $game_system.mart_bonusgift_count_for_window ||= 0
        $game_system.mart_bonusgift_count_for_window += 1
      end
    end

    def self.within_daily_limit?
      lim = DAILY_LIMIT
      return true if !lim || lim <= 0
      return get_count_for_window < lim
    end

    def self.roll?(percent)
      p = percent.to_i
      p = 0 if p < 0
      p = 100 if p > 100
      return rand(100) < p
    end

    def self.parse_pool_entry_simple(entry)
      if entry.is_a?(Hash)
        item = entry[:item]
        min  = (entry[:min] || 1).to_i
        max  = (entry[:max] || min).to_i
        return [item, min, max]
      elsif entry.is_a?(Array)
        item = entry[0]
        min  = (entry[1] || 1).to_i
        max  = (entry[2] || min).to_i
        return [item, min, max]
      else
        return [entry, 1, 1]
      end
    end

    def self.pick_from_pool
      return nil if !POOL || POOL.empty?
      chosen = POOL.sample
      item, min, max = parse_pool_entry_simple(chosen)
      return nil unless item
      qty = rand(min..max)
      return [item, qty]
    end

    def self.item_id_for(entry)
      begin
        return GameData::Item.get(entry).id
      rescue
        return entry
      end
    end

    def self.schedule_pending_gift
      $game_temp ||= nil
      return unless $game_temp
      $game_temp.mart_bonusgift_pending ||= []
      rolls = [ROLLS_PER_PURCHASE.to_i, 1].max
      granted_any = false
      rolls.times do
        break unless within_daily_limit?
        next unless roll?(CHANCE_PERCENT)
        pick = pick_from_pool
        next unless pick
        item, qty = pick
        iid = item_id_for(item)
        $game_temp.mart_bonusgift_pending << [iid, qty]
        granted_any = true
        break
      end
      $game_temp.mart_bonusgift_pending_ready = true if granted_any
    end

    def self.grant_pending_gifts(scene)
      $game_temp ||= nil
      return unless $game_temp && $game_temp.mart_bonusgift_pending_ready
      pending = $game_temp.mart_bonusgift_pending || []
      return if pending.empty?
      if SHOW_PREFIX_MESSAGE && scene && scene.respond_to?(:pbDisplayPaused)
        begin
          scene.pbDisplayPaused(_INTL("Thank you for playing this mod, here's a gift!"))
        rescue
        end
      end
      pending.each do |iid, qty|
        begin
          Kernel.pbReceiveItem(iid, qty)
          increment_count_for_window
        rescue
        end
      end
      $game_temp.mart_bonusgift_pending = []
      $game_temp.mart_bonusgift_pending_ready = false
    end

    def self.should_consider?(old_money, new_money)
      return false unless enabled?
      return false unless $game_temp && $game_temp.mart_bonusgift_active
      return false if BLOCK_IN_KURAY_SHOP && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop
      return false if old_money.nil? || new_money.nil?
      return false unless new_money < old_money  
      return within_daily_limit?
    end
  end
end

if defined?(PokemonMartScreen)
  class PokemonMartScreen
    unless method_defined?(:economygift_orig_pbBuyScreen)
      alias :economygift_orig_pbBuyScreen :pbBuyScreen
    end

    def pbBuyScreen
      $game_temp.mart_bonusgift_active = true if $game_temp && $game_temp.respond_to?(:mart_bonusgift_active=)
      begin
        return economygift_orig_pbBuyScreen
      ensure
        if $game_temp
          $game_temp.mart_bonusgift_active = false if $game_temp.respond_to?(:mart_bonusgift_active=)
          $game_temp.mart_bonusgift_pending = [] if $game_temp.respond_to?(:mart_bonusgift_pending=)
          $game_temp.mart_bonusgift_pending_ready = false if $game_temp.respond_to?(:mart_bonusgift_pending_ready=)
        end
      end
    end
  end
end

class PokemonMartAdapter
  unless method_defined?(:economygift_orig_setMoney)
    alias :economygift_orig_setMoney :setMoney
  end

  def setMoney(value)
    old_money = nil
    begin
      old_money = getMoney
    rescue
    end
    rv = economygift_orig_setMoney(value)
    begin
      if EconomyMod::BonusGifts.should_consider?(old_money, value)
        EconomyMod::BonusGifts.schedule_pending_gift
      end
    rescue
    end
    return rv
  end
end

if defined?(PokemonMart_Scene)
  class PokemonMart_Scene
    unless method_defined?(:economygift_orig_pbDisplayPaused)
      alias :economygift_orig_pbDisplayPaused :pbDisplayPaused
    end

    def pbDisplayPaused(msg, &block)
      rv = economygift_orig_pbDisplayPaused(msg, &block)
      begin
        if $game_temp && $game_temp.mart_bonusgift_pending_ready
          if msg && msg.is_a?(String) && msg.include?("Here you are!")
            EconomyMod::BonusGifts.grant_pending_gifts(self)
          end
        end
      rescue
      end
      return rv
    end
  end
end

class Game_Temp
  unless method_defined?(:mart_bonusgift_active)
    attr_accessor :mart_bonusgift_active
  end
  unless method_defined?(:mart_bonusgift_pending)
    attr_accessor :mart_bonusgift_pending
  end
  unless method_defined?(:mart_bonusgift_pending_ready)
    attr_accessor :mart_bonusgift_pending_ready
  end
end

class Game_System
  unless method_defined?(:mart_bonusgift_window_start)
    attr_accessor :mart_bonusgift_window_start
  end
  unless method_defined?(:mart_bonusgift_count_for_window)
    attr_accessor :mart_bonusgift_count_for_window
  end
end

# ============================================================================
# END OF BONUS GIFTS SECTION
# ============================================================================

# ============================================================================
# CUSTOM ITEM PRICES SECTION
# ============================================================================
module EconomyMod
  module CustomPrices
    ENABLED = true
    # Format: ItemID => [BuyPrice, SellPrice]
    # ItemID can be a number or symbol (e.g., :POTION or 17)
    # Set BuyPrice to nil to use default buy price
    # Set SellPrice to nil to use default sell price (usually half of buy price)
    CUSTOM_PRICES = {
      # :DNASPLICERS => [200, 100],
    }

    def self.enabled?
      if defined?(ModSettingsMenu)
        e = ModSettingsMenu.get(:economymod_custom_prices_enabled)
        return e == 1 || e == true unless e.nil?
      end
      return ENABLED
    end

    def self.get_custom_price(item, buying = true)
      return nil unless enabled?
      return nil if $game_temp && $game_temp.respond_to?(:fromkurayshop) && $game_temp.fromkurayshop

      item_id = item
      begin
        item_id = GameData::Item.get(item).id if item.is_a?(Symbol) || item.is_a?(String)
      rescue
      end

      return nil unless CUSTOM_PRICES.key?(item_id)
      
      prices = CUSTOM_PRICES[item_id]
      return nil unless prices.is_a?(Array) && prices.length >= 2

      return buying ? prices[0] : prices[1]
    end
  end
end

# ============================================================================
# END OF CUSTOM ITEM PRICES SECTION
# ============================================================================

# ============================================================================
# CHANGE NATURE SECTION
# Allows changing a Pokémon's nature from PC Mod Actions for a price
# ============================================================================
module EconomyMod
  module NatureChange
    DEFAULT_PRICE = 1000
    ENABLED = true

    # [symbol, raises, lowers]
    NATURES = [
      [:LONELY,  :ATTACK, :DEFENSE],
      [:BRAVE,   :ATTACK, :SPEED],
      [:ADAMANT, :ATTACK, :SPATK],
      [:NAUGHTY, :ATTACK, :SPDEF],
      [:BOLD,    :DEFENSE, :ATTACK],
      [:RELAXED, :DEFENSE, :SPEED],
      [:IMPISH,  :DEFENSE, :SPATK],
      [:LAX,     :DEFENSE, :SPDEF],
      [:MODEST,  :SPATK, :ATTACK],
      [:MILD,    :SPATK, :DEFENSE],
      [:QUIET,   :SPATK, :SPEED],
      [:RASH,    :SPATK, :SPDEF],
      [:CALM,    :SPDEF, :ATTACK],
      [:GENTLE,  :SPDEF, :DEFENSE],
      [:SASSY,   :SPDEF, :SPEED],
      [:CAREFUL, :SPDEF, :SPATK],
      [:TIMID,   :SPEED, :ATTACK],
      [:HASTY,   :SPEED, :DEFENSE],
      [:JOLLY,   :SPEED, :SPATK],
      [:NAIVE,   :SPEED, :SPDEF],
      [:HARDY,   nil, nil],
      [:DOCILE,  nil, nil],
      [:SERIOUS, nil, nil],
      [:BASHFUL, nil, nil],
      [:QUIRKY,  nil, nil]
    ]

    def self.enabled?
      return true
    end

    def self.price
      if defined?(ModSettingsMenu)
        p = ModSettingsMenu.get(:economymod_nature_change_price)
        return p if p && p >= 0
      end
      return DEFAULT_PRICE
    end

    def self.format_nature_line(nat_sym)
      entry = NATURES.find { |n| n[0] == nat_sym }
      raise_sym = entry ? entry[1] : nil
      lower_sym = entry ? entry[2] : nil
      name = nat_sym.to_s.capitalize
      stat_names = {
        :ATTACK => "Attack",
        :DEFENSE => "Defense",
        :SPEED => "Speed",
        :SPATK => "Sp. Atk",
        :SPDEF => "Sp. Def"
      }
      raise_txt = raise_sym ? (stat_names[raise_sym] || raise_sym.to_s.capitalize) : "Neutral"
      lower_txt = lower_sym ? (stat_names[lower_sym] || lower_sym.to_s.capitalize) : "Neutral"
      return sprintf("%s: %s + / %s -", name, raise_txt, lower_txt)
    end

    def self.get_current_nature_symbol(pkmn)
      begin
        return pkmn.nature if pkmn.respond_to?(:nature)
      rescue
      end
      begin
        return pkmn.nature_id if pkmn.respond_to?(:nature_id)
      rescue
      end
      begin
        nid = pkmn.nature_for_stats if pkmn.respond_to?(:nature_for_stats)
        return nid if nid
      rescue
      end
      return nil
    end

    def self.set_nature!(pkmn, nat_sym)
      changed = false
      begin
        if pkmn.respond_to?(:setNature)
          pkmn.setNature(nat_sym)
          changed = true
        end
      rescue
      end
      begin
        unless changed
          if pkmn.respond_to?(:nature=)
            pkmn.nature = nat_sym
            changed = true
          elsif pkmn.respond_to?(:nature_id=)
            pkmn.nature_id = nat_sym
            changed = true
          end
        end
      rescue
      end
      return changed
    end

    def self.choose_and_apply(pkmn, scene)
      return false unless enabled?
      begin
        if $game_temp && $game_temp.respond_to?(:nature_change_open) && $game_temp.nature_change_open
          return false
        end
      rescue
      end
      begin
        $game_temp.nature_change_open = true if $game_temp && $game_temp.respond_to?(:nature_change_open=)
      rescue
      end
      names = NATURES.map { |n| format_nature_line(n[0]) }
      names << _INTL("Cancel")

      cmdwindow = Window_CommandPokemon.new(names)
      cmdwindow.z = 99999
      cmdwindow.visible = true
      cmdwindow.x = Graphics.width - cmdwindow.width
      cmdwindow.y = 0
      choice = -1
      loop do
        if Graphics.respond_to?(:fast_forward_update)
          Graphics.fast_forward_update
        else
          Graphics.update
        end
        Input.update
        cmdwindow.update
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if defined?(pbPlayDecisionSE)
          choice = cmdwindow.index
          break
        elsif Input.trigger?(Input::BACK)
          pbPlayCancelSE if defined?(pbPlayCancelSE)
          choice = names.length - 1
          break
        end
      end
      cmdwindow.dispose
      return false if choice.nil? || choice < 0 || choice >= NATURES.length || choice == names.length - 1

      target_nat = NATURES[choice][0]
      cost = price
      if $Trainer.money < cost
        scene.pbDisplay(_INTL("Not enough money. Need ${1}.", cost.to_s_formatted))
        return false
      end

      confirm = pbConfirmMessage(_INTL("Change {1}'s nature to {2} for ${3}?", pkmn.name, target_nat.to_s.capitalize, cost.to_s_formatted))
      return false unless confirm

      unless set_nature!(pkmn, target_nat)
        scene.pbDisplay(_INTL("Failed to change nature."))
        return false
      end

      $Trainer.money -= cost
      scene.pbDisplay(_INTL("{1}'s nature changed to {2}.", pkmn.name, target_nat.to_s.capitalize))
      return true
    ensure
      begin
        $game_temp.nature_change_open = false if $game_temp && $game_temp.respond_to?(:nature_change_open=)
      rescue
      end
    end
  end
end

if defined?(ModSettingsMenu::PCModActions)
  ModSettingsMenu::PCModActions.register({
    :name => proc { |pkmn|
      next nil unless defined?(EconomyMod::NatureChange)
      next nil unless EconomyMod::NatureChange.enabled?
      cost = EconomyMod::NatureChange.price
      next _INTL("Change Nature (${1})", cost.to_s_formatted)
    },
    :condition => proc { |pkmn|
      next defined?(EconomyMod::NatureChange) && EconomyMod::NatureChange.enabled?
    },
    :effect => proc { |pkmn, selected, heldpoke, scene|
      next EconomyMod::NatureChange.choose_and_apply(pkmn, scene)
    }
  })
end

# ============================================================================
# END OF CHANGE NATURE SECTION
# ============================================================================

# ============================================================================
# RESET EVS SECTION
# Adds a PC Mod Action to reset all EVs on the selected Pokémon for a price
# ============================================================================
module EconomyMod
  module ResetEVs
    DEFAULT_PRICE = 1000
    ENABLED = true

    def self.enabled?
      return ENABLED
    end

    def self.price
      if defined?(ModSettingsMenu)
        p = ModSettingsMenu.get(:economymod_reset_evs_price)
        return p if p && p >= 0
      end
      return DEFAULT_PRICE
    end

    def self.reset_all!(pkmn)
      begin
        GameData::Stat.each_main { |s| pkmn.ev[s.id] = 0 }
        if pkmn.respond_to?(:saved_ev) && pkmn.saved_ev
          GameData::Stat.each_main { |s| pkmn.saved_ev[s.id] = 0 }
        end
        pkmn.calc_stats if pkmn.respond_to?(:calc_stats)
        return true
      rescue
      end
      return false
    end

    def self.apply(pkmn, scene)
      return false unless enabled?
      cost = price
      if $Trainer.money < cost
        scene.pbDisplay(_INTL("Not enough money. Need ${1}.", cost.to_s_formatted))
        return false
      end

      confirm = pbConfirmMessage(_INTL("Reset all EVs for {1} for ${2}?", pkmn.name, cost.to_s_formatted))
      return false unless confirm

      unless reset_all!(pkmn)
        scene.pbDisplay(_INTL("Failed to reset EVs."))
        return false
      end

      $Trainer.money -= cost
      scene.pbDisplay(_INTL("All EVs on {1} were reset to 0.", pkmn.name))
      return true
    end
  end
end

if defined?(ModSettingsMenu::PCModActions)
  ModSettingsMenu::PCModActions.register({
    :name => proc { |pkmn|
      next nil unless defined?(EconomyMod::ResetEVs)
      next nil unless EconomyMod::ResetEVs.enabled?
      cost = EconomyMod::ResetEVs.price
      next _INTL("Reset EVs (${1})", cost.to_s_formatted)
    },
    :condition => proc { |pkmn|
      next defined?(EconomyMod::ResetEVs) && EconomyMod::ResetEVs.enabled?
    },
    :effect => proc { |pkmn, selected, heldpoke, scene|
      next EconomyMod::ResetEVs.apply(pkmn, scene)
    }
  })
end
# ============================================================================
# END OF RESET EVS SECTION
# ============================================================================
# ============================================================================
# INSTA-HATCH SECTION
# Adds a PC Mod Action to instantly hatch eggs for a price, managed by EconomyMod
# ============================================================================
module EconomyMod
  module InstaHatch
    DEFAULT_PRICE = 1000
    ENABLED = true

    def self.enabled?
      return ENABLED
    end

    def self.price
      if defined?(ModSettingsMenu)
        p = ModSettingsMenu.get(:economymod_insta_hatch_price)
        return p if p && p >= 0
      end
      return DEFAULT_PRICE
    end

    def self.apply(pkmn, scene, selected = nil, heldpoke = nil)
      return false unless enabled?
      # Must be an egg
      if !pkmn || !pkmn.respond_to?(:egg?) || !pkmn.egg?
        scene.pbDisplay(_INTL("This Pokémon is not an egg!"))
        return false
      end

      # Ensure egg is in party; if it's in PC, auto-move if there is space
      eggindex = $Trainer.party.index(pkmn) || -1
      if eggindex < 0
        # Try to move from PC to party
        if $Trainer.party_full?
          scene.pbDisplay(_INTL("Your party is full. Free a slot to hatch this egg."))
          return false
        end
        moved_from_pc = false
        # Use provided selection info if available
        begin
          if selected && selected.is_a?(Array) && selected.length >= 2 && defined?($PokemonStorage)
            box = selected[0]
            idx = selected[1]
            stored = nil
            begin
              stored = $PokemonStorage[box, idx]
            rescue
            end
            if stored && (stored.equal?(pkmn) || stored == pkmn)
              # Remove from storage slot
              begin
                $PokemonStorage[box, idx] = nil
                moved_from_pc = true
              rescue
              end
            end
          end
          # Fallback: scan storage to find and clear the matching egg
          if !moved_from_pc && defined?($PokemonStorage)
            begin
              for b in 0...$PokemonStorage.maxBoxes
                boxobj = $PokemonStorage[b]
                next if !boxobj
                for s in 0...boxobj.length
                  begin
                    obj = $PokemonStorage[b, s]
                    if obj && (obj.equal?(pkmn) || obj == pkmn)
                      $PokemonStorage[b, s] = nil
                      moved_from_pc = true
                      break
                    end
                  rescue
                  end
                end
                break if moved_from_pc
              end
            rescue
            end
          end
        rescue
        end
        # Add to party (uses same object instance)
        if !$Trainer.party_full?
          $Trainer.party.push(pkmn)
          eggindex = $Trainer.party.length - 1
        end
        # If we still don't have an index, abort
        if eggindex < 0
          scene.pbDisplay(_INTL("Failed to move the egg to your party."))
          return false
        end
      end

      cost = price
      if $Trainer.money < cost
        scene.pbDisplay(_INTL("Not enough money. Need ${1}.", cost.to_s_formatted))
        return false
      end

      confirm = pbConfirmMessage(_INTL("Instantly hatch this egg for ${1}?", cost.to_s_formatted))
      return false unless confirm

      # Deduct money
      $Trainer.money -= cost

      # Trigger hatch immediately via hatch scene
      pkmn.steps_to_hatch = 0 if pkmn.respond_to?(:steps_to_hatch=)
      begin
        pbHatch(pkmn, eggindex)
      rescue
        # Attempt animation-only as a fallback
        begin
          pbHatchAnimation(pkmn, eggindex)
        rescue
          # Final fallback: inform user (still no step required elsewhere)
          scene.pbDisplay(_INTL("Hatching failed to start. Try again on the overworld."))
        end
      end

      return true
    end
  end
end

if defined?(ModSettingsMenu::PCModActions)
  ModSettingsMenu::PCModActions.register({
    :name => proc { |pkmn|
      next nil unless defined?(EconomyMod::InstaHatch)
      next nil unless EconomyMod::InstaHatch.enabled?
      next nil unless pkmn && pkmn.respond_to?(:egg?) && pkmn.egg?
      cost = EconomyMod::InstaHatch.price
      next _INTL("Insta-Hatch (${1})", cost.to_s_formatted)
    },
    :condition => proc { |pkmn|
      next defined?(EconomyMod::InstaHatch) && EconomyMod::InstaHatch.enabled? && pkmn && pkmn.respond_to?(:egg?) && pkmn.egg?
    },
    :effect => proc { |pkmn, selected, heldpoke, scene|
      next EconomyMod::InstaHatch.apply(pkmn, scene, selected, heldpoke)
    }
  })
end
# ============================================================================
# END OF INSTA-HATCH SECTION
# ============================================================================
# ============================================================================
# FRIENDSHIP BOOST SECTION
# Adds a PC Mod Action to increase a Pokémon's friendship by +50
# ============================================================================
module EconomyMod
  module FriendshipBoost
    DEFAULT_PRICE = 5000
    ENABLED = true
    AMOUNT = 50

    def self.enabled?
      return ENABLED
    end

    def self.price
      if defined?(ModSettingsMenu)
        p = ModSettingsMenu.get(:economymod_friendship_boost_price)
        return p if p && p >= 0
      end
      return DEFAULT_PRICE
    end

    def self.apply(pkmn, scene)
      return false unless enabled?
      if !pkmn
        scene.pbDisplay(_INTL("No Pokémon selected."))
        return false
      end
      if pkmn.respond_to?(:egg?) && pkmn.egg?
        scene.pbDisplay(_INTL("Eggs don't gain friendship."))
        return false
      end

      # Check for max friendship
      max_friendship = 255
      current_friendship = nil
      if pkmn.respond_to?(:happiness)
        current_friendship = pkmn.happiness.to_i
      elsif pkmn.respond_to?(:getFriendship)
        current_friendship = pkmn.getFriendship.to_i
      end
      if current_friendship && current_friendship >= max_friendship
        scene.pbDisplay(_INTL("{1} already has maximum friendship!", pkmn.name))
        return false
      end

      cost = price
      if $Trainer.money < cost
        scene.pbDisplay(_INTL("Not enough money. Need ${1}.", cost.to_s_formatted))
        return false
      end

      confirm = pbConfirmMessage(_INTL("Boost {1}'s friendship by {2} for ${3}?", pkmn.name, AMOUNT, cost.to_s_formatted))
      return false unless confirm

      # Deduct money
      $Trainer.money -= cost

      boosted = false
      begin
        if pkmn.respond_to?(:happiness) && pkmn.respond_to?(:happiness=)
          cur = pkmn.happiness.to_i
          cur = 0 if cur < 0
          newv = cur + AMOUNT
          newv = max_friendship if newv > max_friendship
          pkmn.happiness = newv
          boosted = true
        elsif pkmn.respond_to?(:changeHappiness)
          # Try direct numeric boost if supported
          begin
            pkmn.changeHappiness(AMOUNT)
            boosted = true
          rescue
            # Fallback: apply walking reason repeatedly
            AMOUNT.times { pkmn.changeHappiness("walking") }
            boosted = true
          end
        end
      rescue
      end
      unless boosted
        scene.pbDisplay(_INTL("Couldn't change friendship for this Pokémon."))
        return false
      end
      scene.pbDisplay(_INTL("{1}'s friendship rose!", pkmn.name))
      return true
    end
  end
end

if defined?(ModSettingsMenu::PCModActions)
  ModSettingsMenu::PCModActions.register({
    :name => proc { |pkmn|
      next nil unless defined?(EconomyMod::FriendshipBoost)
      next nil unless EconomyMod::FriendshipBoost.enabled?
      next nil unless pkmn && (!pkmn.respond_to?(:egg?) || !pkmn.egg?)
      cost = EconomyMod::FriendshipBoost.price
      next _INTL("Friendship Boost (${1})", cost.to_s_formatted)
    },
    :condition => proc { |pkmn|
      next defined?(EconomyMod::FriendshipBoost) && EconomyMod::FriendshipBoost.enabled? && pkmn && (!pkmn.respond_to?(:egg?) || !pkmn.egg?)
    },
    :effect => proc { |pkmn, selected, heldpoke, scene|
      next EconomyMod::FriendshipBoost.apply(pkmn, scene)
    }
  })
end
# ============================================================================
# END OF FRIENDSHIP BOOST SECTION
# ============================================================================
# ============================================================================
# PC POKEMON SELLING SECTION
# Allows players to sell Pokemon from the PC for money
# ============================================================================
module EconomyMod
  module PCPokemonSelling
    ENABLED = true
    BASE_VALUE_PER_LEVEL = 100        # Base money per Pokemon level
    SHINY_MULTIPLIER = 10.0            # Multiplier for shiny Pokemon
    LEGENDARY_MULTIPLIER = 3.0        # Multiplier for legendary Pokemon
    FUSION_MULTIPLIER = 1.5           # Multiplier for fusion Pokemon
    EVOLUTION_STAGE_BONUS = 500        # Additional money per evolution stage
    CONFIRMATION_REQUIRED = true      # Require confirmation before selling

    def self.enabled?
      if defined?(ModSettingsMenu)
        e = ModSettingsMenu.get(:economymod_pc_selling_enabled)
        return e == 1 || e == true unless e.nil?
      end
      return ENABLED
    end

    def self.calculate_value(pkmn)
      return 0 unless pkmn
      base = pkmn.level * BASE_VALUE_PER_LEVEL
      multiplier = 1.0
      
      # Shiny bonus
      if pkmn.shiny?
        multiplier *= SHINY_MULTIPLIER
      end
      
      # Legendary bonus
      begin
        species_data = GameData::Species.get(pkmn.species)
        if species_data && species_data.respond_to?(:has_flag?) && species_data.has_flag?("Legendary")
          multiplier *= LEGENDARY_MULTIPLIER
        end
      rescue
      end
      
      # Fusion bonus
      if pkmn.respond_to?(:isFusion?) && pkmn.isFusion?
        multiplier *= FUSION_MULTIPLIER
      elsif pkmn.respond_to?(:fSpecies) && pkmn.fSpecies
        multiplier *= FUSION_MULTIPLIER
      end
      
      # Evolution stage bonus
      begin
        species_data = GameData::Species.get(pkmn.species)
        if species_data && species_data.respond_to?(:get_evolutions)
          evos = species_data.get_evolutions
          if evos && evos.length == 0
            # Fully evolved
            base += EVOLUTION_STAGE_BONUS * 2
          elsif species_data.get_baby_species != pkmn.species
            # Middle evolution
            base += EVOLUTION_STAGE_BONUS
          end
        end
      rescue
      end
      
      return (base * multiplier).to_i
    end

    def self.sell_pokemon(pkmn, storage_index = nil, box = nil)
      return false unless enabled?
      return false unless pkmn
      
      value = calculate_value(pkmn)
      return false if value <= 0
      
      pkmn_name = pkmn.name
      
      if CONFIRMATION_REQUIRED
        msg = _INTL("Sell {1} for ${2}?", pkmn_name, value.to_s_formatted)
        return false unless pbConfirmMessage(msg)
      end
      
      if defined?($Trainer) && $Trainer && $Trainer.respond_to?(:money=)
        $Trainer.money += value
      end
      
      if defined?($Trainer) && $Trainer && $Trainer.respond_to?(:party) && $Trainer.party.include?(pkmn)
        idx = $Trainer.party.index(pkmn)
        if $Trainer.respond_to?(:remove_pokemon_at_index)
          begin
            $Trainer.remove_pokemon_at_index(idx)
          rescue
            $Trainer.party.delete_at(idx)
          end
        else
          $Trainer.party.delete_at(idx)
        end
      elsif storage_index && box && defined?($PokemonStorage)
        begin
          $PokemonStorage[box, storage_index] = nil
        rescue
        end
      end
      
      pbMessage(_INTL("Sold {1} for ${2}!", pkmn_name, value.to_s_formatted))
      return true
    end
  end
end

if defined?(ModSettingsMenu::PCModActions)
  ModSettingsMenu::PCModActions.register({
    :name => proc { |pkmn|
      next nil unless defined?(EconomyMod::PCPokemonSelling)
      next nil unless EconomyMod::PCPokemonSelling.enabled?
      value = EconomyMod::PCPokemonSelling.calculate_value(pkmn)
      next nil if value <= 0
      next _INTL("Sell Pokemon (${1})", value.to_s_formatted)
    },
    :condition => proc { |pkmn, selected = nil, heldpoke = nil|
      next false unless defined?(EconomyMod::PCPokemonSelling)
      next false unless EconomyMod::PCPokemonSelling.enabled?
      next false if heldpoke
      value = EconomyMod::PCPokemonSelling.calculate_value(pkmn)
      next value > 0
    },
    :effect => proc { |pkmn, selected, heldpoke, scene|
      next false unless defined?(EconomyMod::PCPokemonSelling)
      result = EconomyMod::PCPokemonSelling.sell_pokemon(pkmn, selected[1], selected[0])
      next result
    }
  })
end

# ============================================================================
# END OF PC POKEMON SELLING SECTION
# ============================================================================

# ============================================================================
# SETTINGS REGISTRATION
# ============================================================================
#############################
# BST BOOST SECTION
# Adds a PC Mod Action to permanently boost all six base stats (effective final stats)
# of a single Pokémon by +5 each (one-time purchase per Pokémon).

module EconomyMod
  module BSTBoost
    DEFAULT_PRICE = 30000
    ENABLED = true

    def self.boost_amount; 5; end

    def self.enabled?
      return ENABLED
    end

    def self.price
      return DEFAULT_PRICE
    end

    def self.applied?(pkmn)
      return pkmn && pkmn.respond_to?(:bst_boost_applied) && !!pkmn.bst_boost_applied
    end

    def self.apply(pkmn, scene)
      return false unless enabled?
      if !pkmn
        scene.pbDisplay(_INTL("No Pokémon selected."))
        return false
      end
      if pkmn.respond_to?(:egg?) && pkmn.egg?
        scene.pbDisplay(_INTL("Eggs can't receive a BST Boost."))
        return false
      end
      if applied?(pkmn)
        scene.pbDisplay(_INTL("{1} already received a BST Boost.", pkmn.name))
        return false
      end
      cost = price
      if $Trainer.money < cost
        scene.pbDisplay(_INTL("Not enough money. Need ${1}.", cost.to_s_formatted))
        return false
      end
      confirm = pbConfirmMessage(_INTL("Permanently boost {1}'s base stats (+5 all, +10 nature stats) for ${2}? (One-time)", pkmn.name, cost.to_s_formatted))
      return false unless confirm
      $Trainer.money -= cost
      pkmn.bst_boost_applied = true if pkmn.respond_to?(:bst_boost_applied=)
      begin
        pkmn.calc_stats if pkmn.respond_to?(:calc_stats)
      rescue
      end
      scene.pbDisplay(_INTL("{1}'s base stats were boosted!", pkmn.name))
      return true
    end
  end
end

if defined?(Pokemon)
  class Pokemon
    unless method_defined?(:bst_boost_applied)
      attr_accessor :bst_boost_applied
    end
    unless method_defined?(:economymod_bstboost_orig_calc_stats)
      alias economymod_bstboost_orig_calc_stats calc_stats
      def calc_stats(*args)
        # Store HP BEFORE calc_stats to know if Pokemon was fainted
        old_hp = @hp
        old_totalhp = @totalhp
        
        economymod_bstboost_orig_calc_stats(*args)
        
        begin
          if self.respond_to?(:bst_boost_applied) && self.bst_boost_applied
            base_boost = EconomyMod::BSTBoost.boost_amount rescue 5
            nature_boost = base_boost * 2
            
            raised_stat = nil
            lowered_stat = nil
            if self.respond_to?(:nature_for_stats) && self.nature_for_stats
              self.nature_for_stats.stat_changes.each do |change|
                raised_stat = change[0] if change[1] > 0
                lowered_stat = change[0] if change[1] < 0
              end
            end
            
            hp_boost = (raised_stat == :HP || lowered_stat == :HP) ? nature_boost : base_boost
            atk_boost = (raised_stat == :ATTACK || lowered_stat == :ATTACK) ? nature_boost : base_boost
            def_boost = (raised_stat == :DEFENSE || lowered_stat == :DEFENSE) ? nature_boost : base_boost
            spatk_boost = (raised_stat == :SPECIAL_ATTACK || lowered_stat == :SPECIAL_ATTACK) ? nature_boost : base_boost
            spdef_boost = (raised_stat == :SPECIAL_DEFENSE || lowered_stat == :SPECIAL_DEFENSE) ? nature_boost : base_boost
            speed_boost = (raised_stat == :SPEED || lowered_stat == :SPEED) ? nature_boost : base_boost

            if @totalhp && hp_boost > 0
              if old_hp == 0
                @totalhp = @totalhp + hp_boost
                @hp = 0
              else
                hpDiff = @totalhp - @hp
                
                @totalhp = @totalhp + hp_boost
                
                calculated_hp = @totalhp - hpDiff
                @hp = calculated_hp > 0 ? calculated_hp : 0
              end
            end
            
            @attack  = @attack  + atk_boost if @attack
            @defense = @defense + def_boost if @defense
            @spatk   = @spatk   + spatk_boost if @spatk
            @spdef   = @spdef   + spdef_boost if @spdef
            @speed   = @speed   + speed_boost if @speed
          end
        rescue => e
        end
      end
    end
  end
end

if defined?(ModSettingsMenu::PCModActions)
  ModSettingsMenu::PCModActions.register({
    :name => proc { |pkmn|
      next nil unless defined?(EconomyMod::BSTBoost)
      next nil unless EconomyMod::BSTBoost.enabled?
      next nil unless pkmn && (!pkmn.respond_to?(:egg?) || !pkmn.egg?)
      next nil if EconomyMod::BSTBoost.applied?(pkmn)
      cost = EconomyMod::BSTBoost.price
      next _INTL("BST Boost (${1})", cost.to_s_formatted)
    },
    :condition => proc { |pkmn|
      next defined?(EconomyMod::BSTBoost) && EconomyMod::BSTBoost.enabled? && pkmn && (!pkmn.respond_to?(:egg?) || !pkmn.egg?) && !EconomyMod::BSTBoost.applied?(pkmn)
    },
    :effect => proc { |pkmn, selected, heldpoke, scene|
      next EconomyMod::BSTBoost.apply(pkmn, scene)
    }
  })
end

if defined?(PokemonSummary_Scene)
  class PokemonSummary_Scene
    unless method_defined?(:economymod_bstboost_orig_drawPageThree)
      alias economymod_bstboost_orig_drawPageThree drawPageThree
      def drawPageThree
        if @pokemon && @pokemon.respond_to?(:bst_boost_applied) && @pokemon.bst_boost_applied
          original_baseStats = @pokemon.baseStats
          base_boost = EconomyMod::BSTBoost.boost_amount rescue 5
          nature_boost = base_boost * 2
          
          raised_stat = nil
          lowered_stat = nil
          if @pokemon.respond_to?(:nature_for_stats) && @pokemon.nature_for_stats
            @pokemon.nature_for_stats.stat_changes.each do |change|
              raised_stat = change[0] if change[1] > 0
              lowered_stat = change[0] if change[1] < 0
            end
          end
          
          boosted_stats = {}
          original_baseStats.each do |k, v|
            boost = (k == raised_stat || k == lowered_stat) ? nature_boost : base_boost
            boosted_stats[k] = v + boost
          end
          
          begin
            orig_baseStats = nil
            begin
              orig_baseStats = @pokemon.method(:baseStats)
            rescue
              orig_baseStats = nil
            end

            @pokemon.instance_variable_set(:@_temp_boosted_baseStats, boosted_stats)

            @pokemon.define_singleton_method(:baseStats) do
              temp = instance_variable_get(:@_temp_boosted_baseStats)
              return temp if temp
              if orig_baseStats
                orig_baseStats.call
              else
                nil
              end
            end

            economymod_bstboost_orig_drawPageThree
          ensure
            begin
              if @pokemon && @pokemon.singleton_class.method_defined?(:baseStats)
                @pokemon.singleton_class.send(:remove_method, :baseStats)
              end
            rescue
            end
            begin
              @pokemon.instance_variable_set(:@_temp_boosted_baseStats, nil) if @pokemon
            rescue
            end
          end
        else
          economymod_bstboost_orig_drawPageThree
        end
      end
    end
  end
end

# ============================================================================
# END OF SETTINGS REGISTRATION
# ============================================================================

# ============================================================================
# ECONOMY MOD SUBMENU SCENE
# ============================================================================
class EconomyModScene < PokemonOption_Scene
  include ModSettingsSpacing if defined?(ModSettingsSpacing)
  
  # Menu Transition Fix: Skip fade-in to avoid double-fade (outer pbFadeOutIn handles transition)
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # PokeMart Sales Toggle
    options << EnumOption.new(
      _INTL("PokeMart Sales"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_sales) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_sales, value) },
      _INTL("Enable random sales on items in PokeMarts")
    )
    
    # PokeMart Markups Toggle
    options << EnumOption.new(
      _INTL("PokeMart Markups"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_markups) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_markups, value) },
      _INTL("Enable random price markups on items in PokeMarts")
    )
    
    # Initial Money Toggle
    options << EnumOption.new(
      _INTL("Initial Money"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_starting_money_enabled) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_starting_money_enabled, value) },
      _INTL("Give custom starting money when beginning a new game")
    )
    
    # Initial Money Amount
    options << StoneSliderOption.new(
      _INTL("Initial Money Amount"),
      0, 10000, 500,
      proc { ModSettingsMenu.get(:economymod_starting_money) || 3000 },
      proc { |value| ModSettingsMenu.set(:economymod_starting_money, value) },
      _INTL("Amount of money to start with in a new game")
    )
    
    # Battle Money Toggle
    options << EnumOption.new(
      _INTL("Battle Money Multiplier"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_battle_money_enabled) || 0 },
      proc { |value| ModSettingsMenu.set(:economymod_battle_money_enabled, value) },
      _INTL("Multiply money earned from trainer battles")
    )
    
    # Battle Money Multiplier
    options << StoneSliderOption.new(
      _INTL("Battle Money x Amount"),
      1, 10, 1,
      proc { ModSettingsMenu.get(:economymod_battle_money_multiplier) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_battle_money_multiplier, value) },
      _INTL("Multiplier for battle money rewards (1x to 10x)")
    )
    
    # PokeVial Cost Toggle
    options << EnumOption.new(
      _INTL("PokeVial Cost"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_pokevial_cost_enabled) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_pokevial_cost_enabled, value) },
      _INTL("Charge money each time the PokeVial is used")
    )
    
    # PokeVial Cost Amount
    options << StoneSliderOption.new(
      _INTL("PokeVial Cost Per Use"),
      0, 10000, 100,
      proc { ModSettingsMenu.get(:economymod_pokevial_cost) || 500 },
      proc { |value| ModSettingsMenu.set(:economymod_pokevial_cost, value) },
      _INTL("Cost in Pokedollars for each PokeVial use")
    )
    
    # Bonus Gifts Toggle
    options << EnumOption.new(
      _INTL("Bonus Gifts"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_bonus_gifts_enabled) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_bonus_gifts_enabled, value) },
      _INTL("Enable bonus items given at various points when buying from the shop")
    )
    
    # Custom Prices Toggle
    options << EnumOption.new(
      _INTL("Custom Item Prices"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_custom_prices_enabled) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_custom_prices_enabled, value) },
      _INTL("Use custom pricing for certain items")
    )
    
    # PC Pokemon Selling Toggle
    options << EnumOption.new(
      _INTL("PC Pokemon Selling"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:economymod_pc_selling_enabled) || 1 },
      proc { |value| ModSettingsMenu.set(:economymod_pc_selling_enabled, value) },
      _INTL("Allow selling Pokemon directly from the PC for money")
    )
    
    # Nature Change Price
    options << StoneSliderOption.new(
      _INTL("Nature Change Price"),
      0, 10000, 100,
      proc { ModSettingsMenu.get(:economymod_nature_change_price) || 500 },
      proc { |value| ModSettingsMenu.set(:economymod_nature_change_price, value) },
      _INTL("Cost to change a Pokemon's nature at the PC")
    )
    
    # Reset EVs Price
    options << StoneSliderOption.new(
      _INTL("Reset EVs Price"),
      0, 10000, 100,
      proc { ModSettingsMenu.get(:economymod_reset_evs_price) || 1000 },
      proc { |value| ModSettingsMenu.set(:economymod_reset_evs_price, value) },
      _INTL("Cost to reset all EVs for a Pokemon at the PC")
    )
    
    # Insta-Hatch Price
    options << StoneSliderOption.new(
      _INTL("Insta-Hatch Price"),
      0, 10000, 100,
      proc { ModSettingsMenu.get(:economymod_insta_hatch_price) || 1000 },
      proc { |value| ModSettingsMenu.set(:economymod_insta_hatch_price, value) },
      _INTL("Cost to instantly hatch an egg at the PC")
    )
    
    # Friendship Boost Price
    options << StoneSliderOption.new(
      _INTL("Friendship Boost Price"),
      0, 10000, 100,
      proc { ModSettingsMenu.get(:economymod_friendship_boost_price) || 5000 },
      proc { |value| ModSettingsMenu.set(:economymod_friendship_boost_price, value) },
      _INTL("Cost to max out a Pokemon's friendship at the PC")
    )
    
    options = auto_insert_spacers(options) if defined?(ModSettingsSpacing) && respond_to?(:auto_insert_spacers)
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Economy Mod Settings"), 0, 0, Graphics.width, 64, @viewport)
    
    # Apply current color theme and modsettings_menu flag
    if @sprites["option"]
      @sprites["option"].modsettings_menu = true if @sprites["option"].respond_to?(:modsettings_menu=)
      
      if defined?(ModSettingsMenu) && defined?(COLOR_THEMES)
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
    end
    
    # Initialize values
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

begin
  reg_proc = proc do
    next unless defined?(ModSettingsMenu)
    
    # Initialize default values
    ModSettingsMenu.set(:economymod_sales, 1) if ModSettingsMenu.get(:economymod_sales).nil?
    ModSettingsMenu.set(:economymod_markups, 1) if ModSettingsMenu.get(:economymod_markups).nil?
    ModSettingsMenu.set(:economymod_starting_money_enabled, 1) if ModSettingsMenu.get(:economymod_starting_money_enabled).nil?
    ModSettingsMenu.set(:economymod_starting_money, 3000) if ModSettingsMenu.get(:economymod_starting_money).nil?
    ModSettingsMenu.set(:economymod_battle_money_enabled, 1) if ModSettingsMenu.get(:economymod_battle_money_enabled).nil?
    ModSettingsMenu.set(:economymod_battle_money_multiplier, 1) if ModSettingsMenu.get(:economymod_battle_money_multiplier).nil?
    ModSettingsMenu.set(:economymod_pokevial_cost_enabled, 1) if ModSettingsMenu.get(:economymod_pokevial_cost_enabled).nil?
    ModSettingsMenu.set(:economymod_pokevial_cost, 300) if ModSettingsMenu.get(:economymod_pokevial_cost).nil?
    ModSettingsMenu.set(:economymod_bonus_gifts_enabled, 0) if ModSettingsMenu.get(:economymod_bonus_gifts_enabled).nil?
    ModSettingsMenu.set(:economymod_custom_prices_enabled, 0) if ModSettingsMenu.get(:economymod_custom_prices_enabled).nil?
    ModSettingsMenu.set(:economymod_pc_selling_enabled, 0) if ModSettingsMenu.get(:economymod_pc_selling_enabled).nil?
    ModSettingsMenu.set(:economymod_nature_change_price, 5000) if ModSettingsMenu.get(:economymod_nature_change_price).nil?
    ModSettingsMenu.set(:economymod_reset_evs_price, 1000) if ModSettingsMenu.get(:economymod_reset_evs_price).nil?
    ModSettingsMenu.set(:economymod_insta_hatch_price, 1000) if ModSettingsMenu.get(:economymod_insta_hatch_price).nil?
    ModSettingsMenu.set(:economymod_friendship_boost_price, 500) if ModSettingsMenu.get(:economymod_friendship_boost_price).nil?
    
    # Register Economy Mod button that opens the submenu scene
    ModSettingsMenu.register(:economy_mod, {
      name: "Economy Mod",
      type: :button,
      description: "Configure sales, markups, battle money, and PC mod prices",
      on_press: proc {
        pbFadeOutIn {
          scene = EconomyModScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      },
      category: "Economy",
      searchable: [
        "sales", "markups", "pokemart", "money", "battle money", "starting money",
        "pokevial", "cost", "price", "nature change", "reset evs", "insta-hatch",
        "friendship boost", "bonus gifts", "custom prices", "pc selling", "sell pokemon"
      ]
    })
  end

  if defined?(ModSettingsMenu)
    reg_proc.call
  else
    $MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
    $MOD_SETTINGS_PENDING_REGISTRATIONS << reg_proc
  end
rescue
end
# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
# Register this mod for auto-updates
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: 'Economy Mod',
    file: '02_EconomyMod.rb',
    version: '1.8.2',
    download_url: 'https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/02_EconomyMod.rb',
    changelog_url: 'https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Changelogs/Economy%20Mod.md',
    graphics: [],
    dependencies: [{name: '01_Mod_Settings', version: '3.1.4'}]
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["02_EconomyMod.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("EconomyMod: Economy Mod #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
