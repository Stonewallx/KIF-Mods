#========================================
# DexNav
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 1.0.0
# Author: Stonewall
#========================================

#===============================================================================
# DexNav Module - Core System
#===============================================================================

module DexNav
  #-----------------------------------------------------------------------------
  # DexNavOverlay - UI Class for Species Selection
  #-----------------------------------------------------------------------------
  class DexNavOverlay
    attr_reader :selected_index, :selected_type, :confirmed

    ICONS_PER_ROW = 5
    ICON_SIZE = 48
    ICONS_PER_PAGE = 10
    WATER_START_X = 7
    WATER_START_Y = 50
    LAND_START_X = 7
    LAND_START_Y = 230
    ICON_SPACING_X = 64
    ICON_SPACING_Y = 64

    def initialize(water_species, land_species)
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 100000  # Higher than Weather Box (99999)
      @sprites = {}
      @water_species = water_species || []
      @land_species = land_species || []
      @water_page = 0
      @land_page = 0
      @water_total_pages = (@water_species.length.to_f / ICONS_PER_PAGE).ceil
      @land_total_pages = (@land_species.length.to_f / ICONS_PER_PAGE).ceil
      @selected_type = @land_species.empty? ? :water : :land
      @selected_index = 0
      @confirmed = false
      
      # Load background
      bg_path = DexNav.ui_asset("bg")
      if FileTest.exist?(bg_path + ".png")
        @sprites["background"] = Sprite.new(@viewport)
        @sprites["background"].bitmap = Bitmap.new(bg_path)
      end
      
      # Create water icons
      if defined?(PokemonIconSprite) && defined?(Pokemon)
        visible_water = get_visible_species(:water)
        visible_water.each_with_index do |species_data, i|
          begin
            species = species_data.is_a?(Hash) ? species_data[:species] : species_data
            pkmn = Pokemon.new(species, 5)
            icon = PokemonIconSprite.new(pkmn, @viewport)
            row = i / ICONS_PER_ROW
            col = i % ICONS_PER_ROW
            icon.x = WATER_START_X + col * ICON_SPACING_X
            icon.y = WATER_START_Y + row * ICON_SPACING_Y
            @sprites["water_icon#{i}"] = icon
          rescue
          end
        end
      end
      
      # Create land icons
      if defined?(PokemonIconSprite) && defined?(Pokemon)
        visible_land = get_visible_species(:land)
        visible_land.each_with_index do |species_data, i|
          begin
            species = species_data.is_a?(Hash) ? species_data[:species] : species_data
            pkmn = Pokemon.new(species, 5)
            icon = PokemonIconSprite.new(pkmn, @viewport)
            row = i / ICONS_PER_ROW
            col = i % ICONS_PER_ROW
            icon.x = LAND_START_X + col * ICON_SPACING_X
            icon.y = LAND_START_Y + row * ICON_SPACING_Y
            @sprites["land_icon#{i}"] = icon
          rescue
          end
        end
      end
      
      # Create pointer
      pointer_path = DexNav.ui_asset("pointer")
      if FileTest.exist?(pointer_path + ".png")
        @sprites["pointer"] = Sprite.new(@viewport)
        @sprites["pointer"].bitmap = Bitmap.new(pointer_path)
        update_pointer
      end
      
      # Create static overlay (labels and headers)
      @sprites["overlay"] = Sprite.new(@viewport)
      @sprites["overlay"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
      overlay = @sprites["overlay"].bitmap
      pbSetSystemFont(overlay)
      map_name = pbGetMapNameFromId($game_map.map_id)
      pbDrawTextPositions(overlay, [[map_name, 10, 1, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      pbDrawTextPositions(overlay, [[_INTL("DexNav"), Graphics.width/2, 1, 2, Color.new(255,255,255), Color.new(100,100,100)]])
      
      if @water_species.length > 0
        water_label = _INTL("Water")
        water_label += " (#{@water_page + 1}/#{@water_total_pages})" if @water_total_pages > 1
        pbDrawTextPositions(overlay, [[water_label, WATER_START_X+7, WATER_START_Y-16, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      end
      
      if @land_species.length > 0
        land_label = _INTL("Land")
        land_label += " (#{@land_page + 1}/#{@land_total_pages})" if @land_total_pages > 1
        pbDrawTextPositions(overlay, [[land_label, LAND_START_X+7, LAND_START_Y-18, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      end
      
      # Create info overlay (species details)
      @sprites["info_overlay"] = Sprite.new(@viewport)
      @sprites["info_overlay"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
      update_info_display
    end

    def get_visible_species(type)
      if type == :water
        start_idx = @water_page * ICONS_PER_PAGE
        return @water_species[start_idx, ICONS_PER_PAGE] || []
      else
        start_idx = @land_page * ICONS_PER_PAGE
        return @land_species[start_idx, ICONS_PER_PAGE] || []
      end
    end

    def refresh_icons
      # Dispose old icons
      @sprites.keys.each do |key|
        if key.to_s.start_with?("water_icon") || key.to_s.start_with?("land_icon")
          @sprites[key].dispose
          @sprites.delete(key)
        end
      end
      
      # Recreate icons for current page
      if defined?(PokemonIconSprite) && defined?(Pokemon)
        visible_water = get_visible_species(:water)
        visible_water.each_with_index do |species_data, i|
          begin
            species = species_data.is_a?(Hash) ? species_data[:species] : species_data
            pkmn = Pokemon.new(species, 5)
            icon = PokemonIconSprite.new(pkmn, @viewport)
            row = i / ICONS_PER_ROW
            col = i % ICONS_PER_ROW
            icon.x = WATER_START_X + col * ICON_SPACING_X
            icon.y = WATER_START_Y + row * ICON_SPACING_Y
            @sprites["water_icon#{i}"] = icon
          rescue
          end
        end
        
        visible_land = get_visible_species(:land)
        visible_land.each_with_index do |species_data, i|
          begin
            species = species_data.is_a?(Hash) ? species_data[:species] : species_data
            pkmn = Pokemon.new(species, 5)
            icon = PokemonIconSprite.new(pkmn, @viewport)
            row = i / ICONS_PER_ROW
            col = i % ICONS_PER_ROW
            icon.x = LAND_START_X + col * ICON_SPACING_X
            icon.y = LAND_START_Y + row * ICON_SPACING_Y
            @sprites["land_icon#{i}"] = icon
          rescue
          end
        end
      end
      
      # Update static overlay with new page numbers
      overlay = @sprites["overlay"].bitmap
      overlay.clear
      pbSetSystemFont(overlay)
      map_name = pbGetMapNameFromId($game_map.map_id)
      pbDrawTextPositions(overlay, [[map_name, 10, 1, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      pbDrawTextPositions(overlay, [[_INTL("DexNav"), Graphics.width/2, 1, 2, Color.new(255,255,255), Color.new(100,100,100)]])
      
      if @water_species.length > 0
        water_label = _INTL("Water")
        water_label += " (#{@water_page + 1}/#{@water_total_pages})" if @water_total_pages > 1
        pbDrawTextPositions(overlay, [[water_label, WATER_START_X+7, WATER_START_Y-16, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      end
      
      if @land_species.length > 0
        land_label = _INTL("Land")
        land_label += " (#{@land_page + 1}/#{@land_total_pages})" if @land_total_pages > 1
        pbDrawTextPositions(overlay, [[land_label, LAND_START_X+7, LAND_START_Y-18, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      end
      
      update_pointer
      update_info_display
    end

    def update_pointer
      if @sprites["pointer"]
        if @selected_type == :water
          row = @selected_index / ICONS_PER_ROW
          col = @selected_index % ICONS_PER_ROW
          @sprites["pointer"].x = WATER_START_X + col * ICON_SPACING_X - 3
          @sprites["pointer"].y = WATER_START_Y + row * ICON_SPACING_Y + 20
        else
          row = @selected_index / ICONS_PER_ROW
          col = @selected_index % ICONS_PER_ROW
          @sprites["pointer"].x = LAND_START_X + col * ICON_SPACING_X - 3
          @sprites["pointer"].y = LAND_START_Y + row * ICON_SPACING_Y + 20
        end
      end
    end

    def selected_species
      if @selected_type == :water
        visible_water = get_visible_species(:water)
        return visible_water[@selected_index]
      else
        visible_land = get_visible_species(:land)
        return visible_land[@selected_index]
      end
    end

    def update_info_display
      return unless @sprites["info_overlay"]
      overlay = @sprites["info_overlay"].bitmap
      overlay.clear
      species_data = selected_species
      return unless species_data
      
      species = species_data.is_a?(Hash) ? species_data[:species] : species_data
      method = species_data.is_a?(Hash) ? species_data[:method] : (@selected_type == :water ? :surf : :walk)
      
      pbSetSystemFont(overlay)
      base = Color.new(0, 0, 0)
      shadow = Color.new(176, 176, 176)
      info_x = 350
      info_y = 60
      
      # Species name
      name = GameData::Species.get(species).name rescue species.to_s
      pbDrawTextPositions(overlay, [[name, info_x, info_y + 2, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      
      # Types label
      pbDrawTextPositions(overlay, [[_INTL("Types"), info_x, info_y + 27, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      
      # Type icons from spritesheet
      begin
        types = GameData::Species.get(species).types
        typebitmap = AnimatedBitmap.new("Graphics/Pictures/types").bitmap
        types.each_with_index do |type, i|
          type_number = GameData::Type.get(type).id_number
          type_rect = Rect.new(0, type_number * 28, 64, 28)
          overlay.blt(info_x + i*70, info_y + 65, typebitmap, type_rect)
        end
        typebitmap.dispose if typebitmap
      rescue => e
        # Fallback to text if icon loading fails
        types = GameData::Species.get(species).types rescue []
        types.each_with_index do |type, i|
          pbDrawTextPositions(overlay, [[type.to_s, info_x + i*80, info_y + 63, 0, base, shadow]])
        end
      end
      
      # Search level label
      pbDrawTextPositions(overlay, [[_INTL("Level"), info_x, info_y + 88, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      
      # Display the level of the NEXT encounter
      current_search_level = DexNav.get_search_level(species)
      next_encounter_level = current_search_level + 1
      
      # Add chain info if actively chaining this species
      current_map = $game_map.map_id rescue 0
      is_chaining = (DexNav.chain_species == species && DexNav.chain_map == current_map && DexNav.chain > 0)
      level_text = is_chaining ? "#{next_encounter_level} (Chain #{DexNav.chain})" : next_encounter_level.to_s
      pbDrawTextPositions(overlay, [[level_text, info_x, info_y + 115, 0, base, shadow]])
      
      # Method label
      pbDrawTextPositions(overlay, [[_INTL("Method"), info_x, info_y + 147, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      
      # Display method for this species
      method_name = case method
        when :walk then "Walk"
        when :cave then "Cave"
        when :surf then "Surf"
        when :OldRod, :GoodRod, :SuperRod, :fish then "Fishing"
        else "Unknown"
      end
      
      pbDrawTextPositions(overlay, [[method_name, info_x, info_y + 176, 0, base, shadow]])
      
      # Hidden Ability label
      pbDrawTextPositions(overlay, [[_INTL("Hidden Ability"), info_x, info_y + 204, 0, Color.new(255,255,255), Color.new(100,100,100)]])
      
      begin
        species_obj = GameData::Species.get(species)
        has_seen = $Trainer.pokedex.seen?(species) rescue false
        
        if has_seen
          hidden_abilities = []
          
          is_fusion = false
          if defined?(getBasePokemonID) && defined?(NB_POKEMON)
            is_fusion = (species_obj.id_number > NB_POKEMON) rescue false
          end
          
          if is_fusion
            # Get head and body base Pokemon IDs
            body_id = getBasePokemonID(species, true) rescue nil
            head_id = getBasePokemonID(species, false) rescue nil
            
            # Get hidden abilities from both base Pokemon
            if body_id
              body_species = GameData::Species.get(body_id) rescue nil
              if body_species && body_species.hidden_abilities
                hidden_abilities += body_species.hidden_abilities
              end
            end
            if head_id && head_id != body_id
              head_species = GameData::Species.get(head_id) rescue nil
              if head_species && head_species.hidden_abilities
                hidden_abilities += head_species.hidden_abilities
              end
            end
            hidden_abilities.uniq!
          else
            # Regular Pokemon - just get hidden abilities directly
            hidden_abilities = species_obj.hidden_abilities || []
          end
          
          if hidden_abilities.empty?
            pbDrawTextPositions(overlay, [["None", info_x, info_y + 233, 0, base, shadow]])
          else
            hidden_abilities.each_with_index do |ability, i|
              ability_name = GameData::Ability.get(ability).name rescue ability.to_s
              pbDrawTextPositions(overlay, [[ability_name, info_x, info_y + 233 + (i * 20), 0, base, shadow]])
            end
          end
        else
          pbDrawTextPositions(overlay, [["-------", info_x, info_y + 233, 0, base, shadow]])
        end
      rescue
        pbDrawTextPositions(overlay, [["-------", info_x, info_y + 233, 0, base, shadow]])
      end
    end

    def start_ui_loop
      loop do
        Graphics.update
        Input.update
        
        if Input.trigger?(Input::B)
          @confirmed = false
          break
        elsif Input.trigger?(Input::C)
          visible_count = (@selected_type == :water ? get_visible_species(:water).length : get_visible_species(:land).length)
          if @selected_index < visible_count
            @confirmed = true
            break
          end
        elsif Input.trigger?(Input::R)
          # Cycle pages
          if @selected_type == :water && @water_total_pages > 1
            @water_page = (@water_page + 1) % @water_total_pages
            @selected_index = 0
            refresh_icons
          elsif @selected_type == :land && @land_total_pages > 1
            @land_page = (@land_page + 1) % @land_total_pages
            @selected_index = 0
            refresh_icons
          end
        elsif Input.trigger?(Input::LEFT)
          if @selected_index > 0
            @selected_index -= 1
            update_pointer
            update_info_display
          end
        elsif Input.trigger?(Input::RIGHT)
          visible_count = (@selected_type == :water ? get_visible_species(:water).length : get_visible_species(:land).length)
          max_index = visible_count - 1
          if @selected_index < max_index
            @selected_index += 1
            update_pointer
            update_info_display
          end
        elsif Input.trigger?(Input::UP)
          if @selected_index >= ICONS_PER_ROW
            # Move up within the same section
            @selected_index -= ICONS_PER_ROW
            update_pointer
            update_info_display
          elsif @selected_type == :land && @water_species.length > 0
            # At top row of land section, switch to water section
            @selected_type = :water
            visible_water = get_visible_species(:water)
            # Try to go to the same column in water section
            col = @selected_index % ICONS_PER_ROW
            last_row = (visible_water.length - 1) / ICONS_PER_ROW
            @selected_index = [last_row * ICONS_PER_ROW + col, visible_water.length - 1].min
            refresh_icons
          end
        elsif Input.trigger?(Input::DOWN)
          visible_count = (@selected_type == :water ? get_visible_species(:water).length : get_visible_species(:land).length)
          max_index = visible_count - 1
          if @selected_index + ICONS_PER_ROW <= max_index
            # Move down within the same section
            @selected_index += ICONS_PER_ROW
            update_pointer
            update_info_display
          elsif @selected_type == :water && @land_species.length > 0
            # At bottom row of water section, switch to land section
            @selected_type = :land
            visible_land = get_visible_species(:land)
            col = @selected_index % ICONS_PER_ROW
            @selected_index = [col, visible_land.length - 1].min
            refresh_icons
          end
        end
      end
      Input.update
    end

    def dispose
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    end
  end  # End DexNavOverlay class
  
  #-----------------------------------------------------------------------------
  # Path Helpers
  #-----------------------------------------------------------------------------
  def self.ui_asset(file)
    "Graphics/11a_Overworld Menu/UI/DexNav/#{file}"
  end
  
  def self.anim_asset(file)
    "Graphics/11a_Overworld Menu/Animations/#{file}"
  end
  
  #-----------------------------------------------------------------------------
  # Module Variables
  #-----------------------------------------------------------------------------
  @active = false
  @coords = nil
  @species = nil
  @level = nil
  @is_grass = true
  @terrain_type = :land
  @search_levels = {}
  @current_species = nil
  @current_map = nil
  @pending_encounter = nil  # Stores {species:, level:, search_level:, chain:} for applying bonuses
  @chain = 0  # Current chain count
  @chain_species = nil  # Species being chained
  @chain_map = nil  # Map where chain started
  @last_species = nil  # Last selected DexNav species for DN Repeat feature
  @last_method = nil   # Last selected DexNav method for DN Repeat feature
  @last_rod_type = nil # Last selected rod type for DN Repeat feature
  @repel_was_active = 0  # Store the player's original repel count before DexNav
  
  class << self
    attr_accessor :active, :coords, :species, :level, :is_grass, :terrain_type, :search_levels, 
                  :current_species, :current_map, :pending_encounter, :chain, :chain_species, 
                  :chain_map, :last_species, :last_method, :last_rod_type, :repel_was_active
  end
  
  #-----------------------------------------------------------------------------
  # Helper Methods
  #-----------------------------------------------------------------------------
  
  def self.is_starter_line?(species)
    # List of common starter species IDs and their evolutions
    starters = [
      :BULBASAUR, :IVYSAUR, :VENUSAUR,
      :CHARMANDER, :CHARMELEON, :CHARIZARD,
      :SQUIRTLE, :WARTORTLE, :BLASTOISE,
      :CHIKORITA, :BAYLEEF, :MEGANIUM,
      :CYNDAQUIL, :QUILAVA, :TYPHLOSION,
      :TOTODILE, :CROCONAW, :FERALIGATR,
      :TREECKO, :GROVYLE, :SCEPTILE,
      :TORCHIC, :COMBUSKEN, :BLAZIKEN,
      :MUDKIP, :MARSHTOMP, :SWAMPERT,
      :TURTWIG, :GROTLE, :TORTERRA,
      :CHIMCHAR, :MONFERNO, :INFERNAPE,
      :PIPLUP, :PRINPLUP, :EMPOLEON,
      :SNIVY, :SERVINE, :SERPERIOR,
      :TEPIG, :PIGNITE, :EMBOAR,
      :OSHAWOTT, :DEWOTT, :SAMUROTT,
      :CHESPIN, :QUILLADIN, :CHESNAUGHT,
      :FENNEKIN, :BRAIXEN, :DELPHOX,
      :FROAKIE, :FROGADIER, :GRENINJA,
      :ROWLET, :DARTRIX, :DECIDUEYE,
      :LITTEN, :TORRACAT, :INCINEROAR,
      :POPPLIO, :BRIONNE, :PRIMARINA
    ]
    return starters.include?(species)
  end

  def self.get_search_level(species)
    map_id = $game_map.map_id rescue 0
    key = "#{map_id}_#{species}"
    return @search_levels[key] || 0
  end

  def self.increment_search_level(species)
    map_id = $game_map.map_id rescue 0
    key = "#{map_id}_#{species}"
    @search_levels[key] = (@search_levels[key] || 0) + 1
  end

  def self.reset_search_level(species = nil)
    if species
      map_id = $game_map.map_id rescue 0
      key = "#{map_id}_#{species}"
      @search_levels.delete(key)
    else
      @search_levels.clear
    end
  end

  def self.check_and_init_chain(species)
    # Initialize or reset chain if species or map changed
    current_map = $game_map.map_id rescue 0
    if @chain_species != species || @chain_map != current_map
      @chain = 0
      @chain_species = species
      @chain_map = current_map
    end
  end

  def self.reset_chain
    # Reset the chain completely
    @chain = 0
    @chain_species = nil
    @chain_map = nil
  end

  def self.clear_encounter
    # Restore repel to original count
    if $PokemonGlobal && @active
      ModSettingsMenu.debug_log("DexNav: Manually clearing encounter - Restoring repel to #{@repel_was_active}")
      $PokemonGlobal.repel = @repel_was_active
    end
    
    # Clear active DexNav encounter
    @active = false
    @coords = nil
    @species = nil
    @level = nil
    @pending_encounter = nil
    @repel_was_active = 0
  end

  def self.get_min_encounter_level(species, species_data = nil)
    map_id = $game_map.map_id rescue nil
    return 5 unless map_id
    
    min_level = 100
    found = false
    
    if defined?(GameData::Encounter)
      encounter_data = GameData::Encounter.get(map_id, ($PokemonGlobal.respond_to?(:encounter_version) ? $PokemonGlobal.encounter_version : nil))
      if encounter_data && encounter_data.types
        encounter_data.types.each do |type, enc|
          next if !enc || enc.empty?
          enc.each do |entry|
            if entry[1] == species
              level = entry[0]
              min_level = level if level < min_level
              found = true
            end
          end
        end
      end
    end
    
    return found ? min_level : 5
  end
  
  #-----------------------------------------------------------------------------
  # Bonus Calculation Methods
  #-----------------------------------------------------------------------------
  
  # Calculate shiny chance bonus based on chain (not search level)
  # Base: 1/4096, improves with chain
  def self.calculate_shiny_chance(chain)
    return 0 if chain < 10
    # Increase shiny chance gradually: every 10 chain adds +1 to the roll
    bonus_rolls = [(chain / 10).floor, 7].min  # Cap at 7 bonus rolls (chain 70+)
    return bonus_rolls
  end

  # Calculate number of guaranteed perfect IVs
  def self.calculate_perfect_ivs(search_level)
    return 0 if search_level < 10
    return 1 if search_level < 25
    return 2 if search_level < 50
    return 3 if search_level < 75
    return 4  # Max 4 perfect IVs at level 75+
  end

  # Calculate hidden ability chance
  def self.calculate_hidden_ability_chance(search_level)
    return 0 if search_level < 5
    return 5 if search_level < 10
    return 10 if search_level < 25
    return 20 if search_level < 50
    return 35 if search_level < 75
    return 60  # 60% chance at level 75+
  end

  # Calculate number of egg moves to add
  def self.calculate_egg_moves(search_level)
    return 0 if search_level < 10
    return 1 if search_level < 25
    return 2 if search_level < 50
    return 3 if search_level < 75
    return 4  # Max 4 egg moves at level 75+
  end

  # Calculate held item chance
  def self.calculate_held_item_chance(search_level)
    return 5 if search_level < 10   # 5% base
    return 10 if search_level < 25  # 10%
    return 20 if search_level < 50  # 20%
    return 40 if search_level < 75  # 40%
    return 65  # 65% at level 75+
  end
  
  #-----------------------------------------------------------------------------
  # Encounter Detection Methods
  #-----------------------------------------------------------------------------
  
  # Determine which encounter types are currently active based on time/weather/season
  def self.get_active_encounter_types(base_prefix)
    active_types = []
    time = pbGetTimeNow rescue Time.now
    
    # Determine time of day
    time_suffix = ""
    day_fallback = false
    night_fallback = false
    
    if defined?(PBDayNight)
      if PBDayNight.isDay?(time)
        if PBDayNight.isMorning?(time)
          time_suffix = "Morning"
          day_fallback = true
        elsif PBDayNight.isAfternoon?(time)
          time_suffix = "Afternoon"
          day_fallback = true
        elsif PBDayNight.isEvening?(time)
          time_suffix = "Evening"
          night_fallback = true  
        else
          time_suffix = "Day"
        end
      else
        time_suffix = "Night"
      end
    end
    
    # Get current weather (check both systems)
    weather_suffix = ""
    if $game_screen && $game_screen.weather_type
      case $game_screen.weather_type
      when 1, :Rain then weather_suffix = "Rain"
      when 2, :Storm then weather_suffix = "Storm"
      when 3, :Snow then weather_suffix = "Snow"
      when 4, :Blizzard then weather_suffix = "Blizzard"
      when 5, :Sandstorm then weather_suffix = "Sandstorm"
      when 6, :HeavyRain then weather_suffix = "HeavyRain"
      when 7, :Sun, :Sunny then weather_suffix = "Sunny"
      when 8, :Fog then weather_suffix = "Fog"
      end
    end
    
    # Get current season
    season_suffix = ""
    if defined?(WeatherSystem) && WeatherSystem.respond_to?(:seasons_enabled?) && WeatherSystem.seasons_enabled?
      season = WeatherSystem.current_season rescue nil
      if season
        season_suffix = season.to_s.capitalize
      end
    elsif defined?(pbGetSeason)
      case pbGetSeason
      when 0 then season_suffix = "Spring"
      when 1 then season_suffix = "Summer"
      when 2 then season_suffix = "Autumn"
      when 3 then season_suffix = "Winter"
      end
    end
    
    # Build all active encounter type combinations (most specific to least specific)
    # Priority: Time + Weather + Season, then combinations, then base
    if time_suffix != "" && weather_suffix != "" && season_suffix != ""
      active_types << "#{base_prefix}#{time_suffix}#{weather_suffix}#{season_suffix}".to_sym
    end
    if time_suffix != "" && weather_suffix != ""
      active_types << "#{base_prefix}#{time_suffix}#{weather_suffix}".to_sym
    end
    if weather_suffix != "" && season_suffix != ""
      active_types << "#{base_prefix}#{weather_suffix}#{season_suffix}".to_sym
    end
    if time_suffix != "" && season_suffix != ""
      active_types << "#{base_prefix}#{time_suffix}#{season_suffix}".to_sym
    end
    if weather_suffix != ""
      active_types << "#{base_prefix}#{weather_suffix}".to_sym
    end
    if season_suffix != ""
      active_types << "#{base_prefix}#{season_suffix}".to_sym
    end
    if time_suffix != ""
      active_types << "#{base_prefix}#{time_suffix}".to_sym
    end
    # Add Day or Night fallback for specific times
    if day_fallback
      active_types << "#{base_prefix}Day".to_sym
    end
    if night_fallback
      active_types << "#{base_prefix}Night".to_sym
    end
    # Always include base type as fallback
    active_types << base_prefix.to_sym
    
    return active_types.uniq
  end
  
  def self.available_species
    found = []
    land_encounters = $PokemonEncounters.listPossibleEncounters(:land) rescue []
      map_id = $game_map.map_id rescue nil
      
      # Check if we're in a cave environment
      in_cave = false
      begin
        if defined?(GameData::MapMetadata) && map_id
          map_metadata = GameData::MapMetadata.try_get(map_id)
          in_cave = (map_metadata && map_metadata.battle_environment == :Cave)
        end
      rescue
        in_cave = false
      end
      
      # Get currently active encounter types based on time/weather/season
      active_land_types = DexNav.get_active_encounter_types(:Land)
      # In caves, encounters are often stored as :Cave type, but if not found, fall back to :Land
      active_cave_types = [:Cave]
      active_water_types = DexNav.get_active_encounter_types(:Water)
      
      
      fishing_types = [
        :OldRod, :GoodRod, :SuperRod, :Fishing
      ]
      # Exclude Event/Special encounter types that might contain starters or special encounters
      excluded_types = [:Event, :EventChance, :Special, :SpecialChance, :BugContest, :Gift, :Starter, :Tutorial, :Scripted]
      land_species = []
      water_species = []
      
      # Determine which encounter mode to use (Classic, Remix/Modern, or Randomized)
      encounter_mode = GameData::Encounter
      if defined?(SWITCH_RANDOM_WILD) && defined?(SWITCH_RANDOM_WILD_AREA) && $game_switches && $game_switches[SWITCH_RANDOM_WILD] && $game_switches[SWITCH_RANDOM_WILD_AREA]
        if defined?(GameData::EncounterRandom)
          encounter_mode = GameData::EncounterRandom
        end
      elsif defined?(SWITCH_MODERN_MODE) && $game_switches && $game_switches[SWITCH_MODERN_MODE]
        if defined?(GameData::EncounterModern)
          encounter_mode = GameData::EncounterModern
        end
      end
      
      if map_id
        encounter_data = encounter_mode.get(map_id, ($PokemonGlobal.respond_to?(:encounter_version) ? $PokemonGlobal.encounter_version : nil))
        if encounter_data && encounter_data.types
          
          # Track if we found any matching encounters
          land_matches = 0
          water_matches = 0
          
          encounter_data.types.each do |type, enc|
            next if !enc || enc.empty?
            next if excluded_types.include?(type)  # Skip Event/Special encounters
            
            # In cave environments, check :Cave type first
            if active_cave_types.include?(type)
              land_matches += 1
              enc.each do |entry|
                species = entry[1]
                # Skip starter species and their evolutions only on the starter map
                next if map_id == 42 && DexNav.is_starter_line?(species)
                # Skip Mew on the starter map
                next if map_id == 42 && species == :MEW
                # Store as {species: species, method: :cave, type: type}
                land_species << {species: species, method: :cave, type: type} unless land_species.any? { |s| s[:species] == species }
              end
            elsif active_land_types.include?(type)
              land_matches += 1
              enc.each do |entry|
                species = entry[1]
                # Skip starter species and their evolutions only on the starter map
                next if map_id == 42 && DexNav.is_starter_line?(species)
                # Skip Mew on the starter map
                next if map_id == 42 && species == :MEW
                # In cave environments with no :Cave encounters, treat :Land as cave encounters
                method = in_cave ? :cave : :walk
                land_species << {species: species, method: method, type: type} unless land_species.any? { |s| s[:species] == species }
              end
            elsif active_water_types.include?(type)
              water_matches += 1
              enc.each do |entry|
                species = entry[1]
                # Skip starter species and their evolutions only on the starter map
                next if map_id == 42 && DexNav.is_starter_line?(species)
                # Skip Mew on the starter map
                next if map_id == 42 && species == :MEW
                # Store as {species: species, method: :surf, type: type}
                water_species << {species: species, method: :surf, type: type} unless water_species.any? { |s| s[:species] == species }
              end
            elsif fishing_types.include?(type)
              enc.each do |entry|
                species = entry[1]
                # Skip starter species and their evolutions only on the starter map
                next if map_id == 42 && DexNav.is_starter_line?(species)
                # Skip Mew on the starter map
                next if map_id == 42 && species == :MEW
                # Only add if species not already in list (don't duplicate for multiple rod types)
                unless water_species.any? { |s| s[:species] == species }
                  water_species << {species: species, method: :fish, type: type}
                end
              end
            end
          end
          
        end
      end
      # Fallback: If no encounters found, try EncounterConfig::CUSTOM_ENCOUNTERS for this map
      if land_species.empty? && water_species.empty? && defined?(EncounterConfig) && EncounterConfig.const_defined?(:CUSTOM_ENCOUNTERS)
        if map_id && EncounterConfig::CUSTOM_ENCOUNTERS[map_id]
          encs = EncounterConfig::CUSTOM_ENCOUNTERS[map_id]
          active_land_types.each do |type|
            next unless encs[type]
            encs[type].each do |entry|
              species = entry[1]
              existing = land_species.find { |s| s[:species] == species }
              if existing
                existing[:methods] ||= [existing[:method]]
                existing[:methods] << :walk unless existing[:methods].include?(:walk)
              else
                land_species << {species: species, method: :walk, methods: [:walk], type: type}
              end
            end
          end
          active_cave_types.each do |type|
            next unless encs[type]
            encs[type].each do |entry|
              species = entry[1]
              existing = land_species.find { |s| s[:species] == species }
              if existing
                existing[:methods] ||= [existing[:method]]
                existing[:methods] << :cave unless existing[:methods].include?(:cave)
              else
                land_species << {species: species, method: :cave, methods: [:cave], type: type}
              end
            end
          end
          active_water_types.each do |type|
            next unless encs[type]
            encs[type].each do |entry|
              species = entry[1]
              existing = water_species.find { |s| s[:species] == species }
              if existing
                existing[:methods] ||= [existing[:method]]
                existing[:methods] << :surf unless existing[:methods].include?(:surf)
              else
                water_species << {species: species, method: :surf, methods: [:surf], type: type}
              end
            end
          end
          fishing_types.each do |type|
            next unless encs[type]
            encs[type].each do |entry|
              species = entry[1]
              existing = water_species.find { |s| s[:species] == species }
              if existing
                existing[:methods] ||= [existing[:method]]
                # Add fishing type if not already present, but store specific rod type
                existing[:methods] << type unless existing[:methods].any? { |m| [:fish, :OldRod, :GoodRod, :SuperRod].include?(m) }
                existing[:type] = type if type # Store the rod type for this specific entry
              else
                water_species << {species: species, method: :fish, methods: [type], type: type}
              end
            end
          end
        end
      end
      
      [water_species, land_species]
  end
  
  #-----------------------------------------------------------------------------
  # Main DexNav Launcher
  #-----------------------------------------------------------------------------
  
  def self.open
    arr = available_species
    water_species = arr[0]
    land_species = arr[1]
    if (water_species.nil? || water_species.empty?) && (land_species.nil? || land_species.empty?)
      pbMessage(_INTL("No wild Pok�mon found on this map!"))
      return
    end
    # Show DexNav UI overlay with all available Pok�mon
    overlay = DexNavOverlay.new(water_species, land_species)
    overlay.start_ui_loop
    chosen_data = overlay.selected_species if overlay.confirmed
    overlay.dispose
    if !chosen_data
      return false
    end
    # Extract species and method from selection
    chosen_species = chosen_data.is_a?(Hash) ? chosen_data[:species] : chosen_data
    chosen_method = chosen_data.is_a?(Hash) ? chosen_data[:method] : :walk
    chosen_rod_type = chosen_data.is_a?(Hash) ? chosen_data[:type] : nil
    
    # Store for DN Repeat feature
    @last_species = chosen_species
    @last_method = chosen_method
    @last_rod_type = chosen_rod_type
    
    # Reset search level if switching species or map
    current_map = $game_map.map_id rescue 0
    if @current_species != chosen_species || @current_map != current_map
      @current_species = chosen_species
      @current_map = current_map
    end
    
    # Calculate search level (starts at 1, increments after successful encounters)
    search_level = DexNav.get_search_level(chosen_species)
    # Display level is always search_level + 1 (since we show the NEXT encounter's level)
    display_level = search_level + 1
    
    # Encounter level is the display level
    level = display_level
    
    # Clear any pending encounters before setting up a new one
    # This ensures only one DexNav encounter can be active at a time
    DexNav.pending_encounter = nil
    DexNav.active = false
    DexNav.coords = nil
    DexNav.species = nil
    DexNav.level = nil
    
    # Show message based on method
    case chosen_method
    when :walk
      coords = DexNav.find_valid_tile(:land)
      if coords
        # Store current repel count and activate repel to block normal encounters
        DexNav.repel_was_active = $PokemonGlobal.repel if $PokemonGlobal
        $PokemonGlobal.repel = 99999 if $PokemonGlobal
        
        DexNav.active = true
        DexNav.coords = coords
        DexNav.species = chosen_species
        DexNav.level = level
        DexNav.is_grass = true
        DexNav.terrain_type = :land
        DexNav.show_rustle(coords, :land)
        ModSettingsMenu.debug_log("DexNav: Walk encounter activated - Species: #{chosen_species}, Level: #{level}, Search Level: #{search_level}, Repel stored: #{DexNav.repel_was_active}")
        pbMessage(_INTL("A rustle appeared in the grass! Walk to it to encounter {1}.", GameData::Species.get(chosen_species).name)) if ModSettingsMenu.get(:dexnav_messages)
      else
        pbMessage(_INTL("No valid grass tile found nearby!"))
      end
    when :cave
      # Check if there are any grass tiles on the map
      has_grass = false
      (0...$game_map.width).each do |x|
        (0...$game_map.height).each do |y|
          terrain = $game_map.terrain_tag(x, y)
          if terrain.respond_to?(:land_wild_encounters) && terrain.land_wild_encounters
            has_grass = true
            break
          end
        end
        break if has_grass
      end
      
      # If no grass tiles, assume we're in a cave and use cave-type tile finding
      tile_type = has_grass ? :land : :cave
      coords = DexNav.find_valid_tile(tile_type)
      
      if coords
        # Store current repel count and activate repel to block normal encounters
        DexNav.repel_was_active = $PokemonGlobal.repel if $PokemonGlobal
        $PokemonGlobal.repel = 99999 if $PokemonGlobal
        
        DexNav.active = true
        DexNav.coords = coords
        DexNav.species = chosen_species
        DexNav.level = level
        DexNav.is_grass = false
        DexNav.terrain_type = :cave
        DexNav.show_rustle(coords, :cave)
        ModSettingsMenu.debug_log("DexNav: Cave encounter activated - Species: #{chosen_species}, Level: #{level}, Search Level: #{search_level}, Repel stored: #{DexNav.repel_was_active}, Has grass: #{has_grass}")
        pbMessage(_INTL("A dust cloud appeared! Walk to it to encounter {1}.", GameData::Species.get(chosen_species).name)) if ModSettingsMenu.get(:dexnav_messages)
      else
        pbMessage(_INTL("No valid cave tile found nearby!"))
      end
    when :surf
      coords = DexNav.find_valid_tile(:water)
      if coords
        # Store current repel count and activate repel to block normal encounters
        DexNav.repel_was_active = $PokemonGlobal.repel if $PokemonGlobal
        $PokemonGlobal.repel = 99999 if $PokemonGlobal
        
        DexNav.active = true
        DexNav.coords = coords
        DexNav.species = chosen_species
        DexNav.level = level
        DexNav.is_grass = false
        DexNav.terrain_type = :water
        DexNav.show_rustle(coords, :water)
        ModSettingsMenu.debug_log("DexNav: Surf encounter activated - Species: #{chosen_species}, Level: #{level}, Search Level: #{search_level}, Repel stored: #{DexNav.repel_was_active}")
        pbMessage(_INTL("Water ripples appeared! Surf to them to encounter {1}.", GameData::Species.get(chosen_species).name)) if ModSettingsMenu.get(:dexnav_messages)
      else
        pbMessage(_INTL("No valid water tile found nearby!"))
      end
    when :fish
      # Get the rod type from the chosen data
      rod_type = chosen_data[:type] if chosen_data.is_a?(Hash)
      rod_name = case rod_type
        when :OldRod then "Old Rod"
        when :GoodRod then "Good Rod"
        when :SuperRod then "Super Rod"
        else "Fishing Rod"
      end
      
      # Set up pending encounter for fishing
      DexNav.check_and_init_chain(chosen_species)
      search_level = DexNav.get_search_level(chosen_species)
      DexNav.pending_encounter = {species: chosen_species, level: level, search_level: search_level, chain: DexNav.chain, type: rod_type}
      
      pbMessage(_INTL("{1} is ready! Use your {2} to encounter it.", GameData::Species.get(chosen_species).name, rod_name)) if ModSettingsMenu.get(:dexnav_messages)
      
      ModSettingsMenu.debug_log("DexNav: Fishing encounter set up - Species: #{chosen_species}, Level: #{level}, Rod: #{rod_type}, Search Level: #{search_level}")
    end
    return true
  end

  # Find a valid grass tile near the player (3x3 area)
  def self.find_valid_tile(type = :land)
    px = $game_player.x
    py = $game_player.y
    min_dist = 2
    max_dist = 7
    valid = []
    (-max_dist..max_dist).each do |dx|
      (-max_dist..max_dist).each do |dy|
        dist = dx.abs + dy.abs
        next if dist < min_dist || dist > max_dist
        x = px + dx
        y = py + dy
        next if x < 0 || y < 0 || x >= $game_map.width || y >= $game_map.height
        terrain = $game_map.terrain_tag(x, y)
        if type == :land
          if terrain.respond_to?(:land_wild_encounters) && terrain.land_wild_encounters
            valid << [x, y]
          end
        elsif type == :cave
          # For cave type, use walkable terrain
          if $game_map.passable?(x, y, 0, nil)
            valid << [x, y]
          end
        elsif type == :water
          # Check if it's surfable water using can_surf or can_surf_freely
          if terrain.respond_to?(:can_surf) && terrain.can_surf
            valid << [x, y]
          elsif terrain.respond_to?(:can_surf_freely) && terrain.can_surf_freely
            valid << [x, y]
          elsif terrain.id == :Water
            valid << [x, y]
          end
        end
      end
    end
    valid.sample
  end

  # Show rustle animation at the given tile
  def self.show_rustle(coords, terrain_type = :land)
    x, y = coords
    
    # Wait for any open scenes to close
    pbWait(10)
    
    # Select animation based on terrain type
    if terrain_type == :water
      # Water ripple animation for surf encounters
      anim_id = defined?(Settings::WATER_ENCOUNTER_ANIMATION_ID) ? Settings::WATER_ENCOUNTER_ANIMATION_ID : 22
    elsif terrain_type == :cave
      # Cave dust animation
      anim_id = defined?(Settings::DUST_ANIMATION_ID) ? Settings::DUST_ANIMATION_ID : 10
    else
      # Grass/land rustle animation
      anim_id = defined?(Settings::RUSTLE_NORMAL_ANIMATION_ID) ? Settings::RUSTLE_NORMAL_ANIMATION_ID : 8
    end
    
    # Play animation twice for better visibility with longer delay
    if $scene && $scene.respond_to?(:spriteset)
      $scene.spriteset.addUserAnimation(anim_id, x, y, true, 1)
      # Wait 20 frames longer before second animation
      pbWait(20)
      $scene.spriteset.addUserAnimation(anim_id, x, y, true, 1)
    end
  end
end  # End DexNav module

#===============================================================================
# Event Hooks - DexNav Encounter System
#===============================================================================

# Hook: Intercept fishing encounters at generation time using EncounterModifier
if defined?(EncounterModifier)
  EncounterModifier.register(proc { |encounter|
    # Only intercept if there's actually an encounter (not nil)
    if encounter && defined?(DexNav) && DexNav.pending_encounter && [:OldRod, :GoodRod, :SuperRod].include?(DexNav.pending_encounter[:type])
      target_species = DexNav.pending_encounter[:species]
      target_level = DexNav.pending_encounter[:level]
      
      ModSettingsMenu.debug_log("DexNav: EncounterModifier intercepting fishing encounter - Replacing with #{target_species} at level #{target_level}")
      
      # Return the replacement encounter
      [target_species, target_level]
    else
      # No DexNav fishing encounter or no encounter to replace, return original
      encounter
    end
  })
end

# Hook: Check if player reached rustling grass/dust cloud
Events.onStepTaken += proc { |_sender, _e|
  if DexNav.active && DexNav.coords
    px, py = $game_player.x, $game_player.y
    tx, ty = DexNav.coords
    if px == tx && py == ty
      # Message based on encounter type
      message = case DexNav.terrain_type
      when :land
        _INTL("You found the rustling grass!")
      when :cave
        _INTL("You found the dust cloud!")
      when :water
        _INTL("You found the water ripples!")
      else
        _INTL("You found the encounter!")
      end
      pbMessage(message)
      species_before = DexNav.species
      level_before = DexNav.get_search_level(species_before)
      
      # Check if chain should continue or reset
      DexNav.check_and_init_chain(species_before)
      
      # Store pending encounter for bonus application (includes current chain)
      encounter_type = DexNav.is_grass ? :land : :cave
      DexNav.pending_encounter = {species: species_before, level: DexNav.level, search_level: level_before, chain: DexNav.chain, type: encounter_type}
      
      # Trigger the wild battle with DexNav's chosen species
      pbWildBattle(species_before, DexNav.level)
      
      # Restore repel to original count
      if $PokemonGlobal
        ModSettingsMenu.debug_log("DexNav: Restoring repel count to #{DexNav.repel_was_active}")
        $PokemonGlobal.repel = DexNav.repel_was_active
      end
      
      # Clear DexNav state after battle
      DexNav.active = false
      DexNav.coords = nil
      DexNav.species = nil
      DexNav.level = nil
      DexNav.repel_was_active = 0
    end
  end
}

# Override pbGenerateWildPokemon to handle DexNav encounters ONLY
# When DexNav is active, normal wild encounters are disabled
def pbGenerateWildPokemon(species, level, isRoamer = false)
  # Check if we have a pending DexNav encounter
  if defined?(DexNav) && DexNav.pending_encounter
    expected_type = DexNav.pending_encounter[:type]
    
    # Determine current encounter type
    current_type = :land  # Default
    if $PokemonGlobal
      if $PokemonGlobal.surfing
        current_type = :surf
      end
    end
    
    # For fishing, species will already match because EncounterModifier replaced it
    is_fishing_encounter = [:OldRod, :GoodRod, :SuperRod].include?(expected_type)
    species_matches = (species == DexNav.pending_encounter[:species])
    
    ModSettingsMenu.debug_log("DexNav: pbGenerateWildPokemon - Species: #{species}, Level: #{level}, Expected type: #{expected_type}, Current type: #{current_type}")
    ModSettingsMenu.debug_log("DexNav: Pending encounter - Species: #{DexNav.pending_encounter[:species]}, Level: #{DexNav.pending_encounter[:level]}, Type: #{expected_type}")
    ModSettingsMenu.debug_log("DexNav: Is fishing: #{is_fishing_encounter}, Species matches: #{species_matches}")
    
    # Check if encounter types match
    # - :land and :cave are compatible (both walking)
    # - For fishing, species will match because EncounterModifier replaced it
    types_match = if is_fishing_encounter
      species_matches
    else
      (expected_type == current_type) || 
      ([:land, :cave].include?(expected_type) && [:land, :cave].include?(current_type))
    end
    
    ModSettingsMenu.debug_log("DexNav: Types match: #{types_match}")
    
    if types_match
      # This IS the DexNav encounter - generate Pokemon with DexNav bonuses
      ModSettingsMenu.debug_log("DexNav: Generating DexNav Pokemon with bonuses")
      species = DexNav.pending_encounter[:species]
      level = DexNav.pending_encounter[:level]
      search_level = DexNav.pending_encounter[:search_level]
      chain = DexNav.pending_encounter[:chain]
      
      # Generate base Pokemon
      pokemon = Pokemon.new(species, level)
      
      # Apply DexNav bonuses
      
      # 1. Shiny chance bonus (based on chain)
      shiny_rolls = DexNav.calculate_shiny_chance(chain)
      if shiny_rolls > 0 && !pokemon.shiny?
        shiny_rolls.times do
          if rand(4096) == 0
            pokemon.shiny = true
            break
          end
        end
      end
      
      # 2. Perfect IVs
      perfect_iv_count = DexNav.calculate_perfect_ivs(search_level)
      if perfect_iv_count > 0
        stats = [:HP, :ATTACK, :DEFENSE, :SPEED, :SPECIAL_ATTACK, :SPECIAL_DEFENSE].shuffle
        perfect_iv_count.times do |i|
          pokemon.iv[stats[i]] = 31
        end
      end
      
      # 3. Hidden ability chance
      ha_chance = DexNav.calculate_hidden_ability_chance(search_level)
      if ha_chance > 0 && rand(100) < ha_chance
        species_data = GameData::Species.get(pokemon.species)
        if species_data.hidden_abilities && !species_data.hidden_abilities.empty?
          hidden_ability = species_data.hidden_abilities.sample
          pokemon.ability = hidden_ability
        end
      end
      
      # 4. Egg moves
      egg_move_count = DexNav.calculate_egg_moves(search_level)
      if egg_move_count > 0
        species_data = GameData::Species.get(pokemon.species)
        if species_data.egg_moves && !species_data.egg_moves.empty?
          egg_moves = species_data.egg_moves.sample(egg_move_count)
          egg_moves.each do |move|
            if pokemon.moves.length < 4
              pokemon.learn_move(move)
            else
              replace_idx = rand(4)
              pokemon.moves[replace_idx] = Pokemon::Move.new(move)
            end
          end
        end
      end
      
      # 5. Held item chance
      item_chance = DexNav.calculate_held_item_chance(search_level)
      if item_chance > 0 && rand(100) < item_chance && !pokemon.item
        species_data = GameData::Species.get(pokemon.species)
        possible_items = []
        possible_items << species_data.wild_item_common if species_data.wild_item_common
        possible_items << species_data.wild_item_uncommon if species_data.wild_item_uncommon
        possible_items << species_data.wild_item_rare if species_data.wild_item_rare
        if !possible_items.empty?
          item = possible_items.sample
          pokemon.item = item
        end
      end
      
      return pokemon
    else
      # Type mismatch - clear DexNav state
      DexNav.active = false
      DexNav.coords = nil
      DexNav.species = nil
      DexNav.level = nil
      DexNav.pending_encounter = nil
      DexNav.chain = 0
      DexNav.chain_species = nil
      DexNav.chain_map = nil
    end
  end
  
  # Normal encounter - generate standard Pokemon with base game logic
  pokemon = Pokemon.new(species, level)
  
  # Apply base game held item logic
  items = pokemon.wildHoldItems
  first_pkmn = $Trainer.first_pokemon
  chances = [50, 5, 1]
  chances = [60, 20, 5] if first_pkmn && first_pkmn.hasAbility?(:COMPOUNDEYES)
  itemrnd = rand(100)
  if (items[0] == items[1] && items[1] == items[2]) || itemrnd < chances[0]
    pokemon.item = items[0]
  elsif itemrnd < (chances[0] + chances[1])
    pokemon.item = items[1]
  elsif itemrnd < (chances[0] + chances[1] + chances[2])
    pokemon.item = items[2]
  end
  
  # Shiny Charm
  if GameData::Item.exists?(:SHINYCHARM) && $PokemonBag.pbHasItem?(:SHINYCHARM)
    2.times do
      break if pokemon.shiny?
      pokemon.personalID = rand(2**16) | rand(2**16) << 16
    end
  end
  
  # Pokerus
  pokemon.givePokerus if rand(65536) < Settings::POKERUS_CHANCE rescue nil
  
  return pokemon
end

# Hook: Handle battle end - increment search level and chain
Events.onEndBattle += proc { |_sender, decision, canLose|
  # decision: 1 = won, 2 = lost, 3 = fled, 4 = caught, 5 = drew
  if DexNav.pending_encounter
    species = DexNav.pending_encounter[:species]
    search_level = DexNav.pending_encounter[:search_level]
    
    if decision == 1 || decision == 4
      DexNav.increment_search_level(species)
      DexNav.chain += 1
      level_after = DexNav.get_search_level(species)
      ModSettingsMenu.debug_log("DexNav: Search level incremented - Species: #{species}, New Level: #{level_after}, Chain: #{DexNav.chain}")
    else
      ModSettingsMenu.debug_log("DexNav: Chain broken - Previous chain: #{DexNav.chain}")
      DexNav.reset_chain
    end
    
    DexNav.pending_encounter = nil
  end
}

#===============================================================================
# OverworldMenuHandler Extension - DexNav Menu Handler
#===============================================================================

class OverworldMenuHandler
  def show_dexnav_menu(parent_index = 0)
    return unless defined?(DexNav)
    
    @scene.pbEndScene
    $game_temp.in_menu = false
    
    DexNav.open
    
    @scene.pbStartScene
    $game_temp.in_menu = true
  end
  
  def show_dexnav_repeat(parent_index = 0)
    return unless defined?(DexNav)
    return unless DexNav.last_species && DexNav.last_method
    
    # Get current encounter pool
    arr = DexNav.available_species
    return unless arr
    
    water_species = arr[0] || []
    land_species = arr[1] || []
    all_species = water_species + land_species
    
    # Check if last species/method combo is in pool
    matching = all_species.find { |s| 
      s_species = s.is_a?(Hash) ? s[:species] : s
      s_method = s.is_a?(Hash) ? s[:method] : :walk
      s_rod_type = s.is_a?(Hash) ? s[:type] : nil
      
      # Match species and method, and rod type if it was a fishing encounter
      if DexNav.last_method == :fish
        s_species == DexNav.last_species && s_method == :fish && s_rod_type == DexNav.last_rod_type
      else
        s_species == DexNav.last_species && s_method == DexNav.last_method
      end
    }
    
    unless matching
      @scene.hide_party_sprites if @scene.respond_to?(:hide_party_sprites)
      pbMessage(_INTL("Last DexNav Pokémon not available here!"))
      @scene.show_party_sprites if @scene.respond_to?(:show_party_sprites)
      return
    end
    
    # Close the Overworld Menu scene now that we're ready to proceed
    @scene.pbEndScene
    $game_temp.in_menu = false
    
    # Re-trigger the encounter using the matching data
    chosen_species = matching.is_a?(Hash) ? matching[:species] : matching
    chosen_method = matching.is_a?(Hash) ? matching[:method] : :walk
    chosen_rod_type = matching.is_a?(Hash) ? matching[:type] : nil
    
    # Reset search level if switching species or map
    current_map = $game_map.map_id rescue 0
    if DexNav.current_species != chosen_species || DexNav.current_map != current_map
      DexNav.current_species = chosen_species
      DexNav.current_map = current_map
    end
    
    # Calculate search level (starts at 1, increments after successful encounters)
    search_level = DexNav.get_search_level(chosen_species)
    # Display level is always search_level + 1 (since we show the NEXT encounter's level)
    display_level = search_level + 1
    
    # Encounter level is the display level
    level = display_level
    
    # Clear any pending encounters before setting up a new one
    DexNav.pending_encounter = nil
    DexNav.active = false
    DexNav.coords = nil
    DexNav.species = nil
    DexNav.level = nil
    
    # Show message based on method
    case chosen_method
    when :walk
      coords = DexNav.find_valid_tile(:land)
      if coords
        # Store current repel count and activate repel to block normal encounters
        DexNav.repel_was_active = $PokemonGlobal.repel if $PokemonGlobal
        $PokemonGlobal.repel = 99999 if $PokemonGlobal
        
        DexNav.active = true
        DexNav.coords = coords
        DexNav.species = chosen_species
        DexNav.level = level
        DexNav.is_grass = true
        DexNav.terrain_type = :land
        DexNav.show_rustle(coords, :land)
        pbMessage(_INTL("A rustle appeared in the grass! Walk to it to encounter {1}.", GameData::Species.get(chosen_species).name)) if ModSettingsMenu.get(:dexnav_messages)
      else
        pbMessage(_INTL("No valid grass tile found nearby!"))
      end
    when :cave
      # Check if there are any grass tiles on the map
      has_grass = false
      (0...$game_map.width).each do |x|
        (0...$game_map.height).each do |y|
          terrain = $game_map.terrain_tag(x, y)
          if terrain.respond_to?(:land_wild_encounters) && terrain.land_wild_encounters
            has_grass = true
            break
          end
        end
        break if has_grass
      end
      
      # If no grass tiles, assume we're in a cave and use cave-type tile finding
      tile_type = has_grass ? :land : :cave
      coords = DexNav.find_valid_tile(tile_type)
      
      if coords
        # Store current repel count and activate repel to block normal encounters
        DexNav.repel_was_active = $PokemonGlobal.repel if $PokemonGlobal
        $PokemonGlobal.repel = 99999 if $PokemonGlobal
        
        DexNav.active = true
        DexNav.coords = coords
        DexNav.species = chosen_species
        DexNav.level = level
        DexNav.is_grass = false
        DexNav.terrain_type = :cave
        DexNav.show_rustle(coords, :cave)
        pbMessage(_INTL("A dust cloud appeared! Walk to it to encounter {1}.", GameData::Species.get(chosen_species).name)) if ModSettingsMenu.get(:dexnav_messages)
      else
        pbMessage(_INTL("No valid cave tile found nearby!"))
      end
    when :surf
      coords = DexNav.find_valid_tile(:water)
      if coords
        # Store current repel count and activate repel to block normal encounters
        DexNav.repel_was_active = $PokemonGlobal.repel if $PokemonGlobal
        $PokemonGlobal.repel = 99999 if $PokemonGlobal
        
        DexNav.active = true
        DexNav.coords = coords
        DexNav.species = chosen_species
        DexNav.level = level
        DexNav.is_grass = false
        DexNav.terrain_type = :water
        DexNav.show_rustle(coords, :water)
        pbMessage(_INTL("Water ripples appeared! Surf to them to encounter {1}.", GameData::Species.get(chosen_species).name)) if ModSettingsMenu.get(:dexnav_messages)
      else
        pbMessage(_INTL("No valid water tile found nearby!"))
      end
    when :fish
      # Get the rod type from the matching data
      rod_type = chosen_rod_type
      rod_name = case rod_type
        when :OldRod then "Old Rod"
        when :GoodRod then "Good Rod"
        when :SuperRod then "Super Rod"
        else "Fishing Rod"
      end
      pbMessage(_INTL("{1} is ready! Use your {2} to encounter it.", GameData::Species.get(chosen_species).name, rod_name)) if ModSettingsMenu.get(:dexnav_messages)
      # Set pending_encounter for fishing
      DexNav.check_and_init_chain(chosen_species)
      search_level = DexNav.get_search_level(chosen_species)
      DexNav.pending_encounter = {species: chosen_species, level: level, search_level: search_level, chain: DexNav.chain, type: rod_type}
    end
  end
end

#===============================================================================
# DexNav Settings Scene
#===============================================================================
class DexNavSettingsScene < PokemonOption_Scene
  include ModSettingsSpacing  # Enable automatic spacing
  
  # Menu Transition Fix: Skip fade-in to avoid double-fade
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # DexNav Messages Toggle
    options << EnumOption.new(
      _INTL("DexNav Messages"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:dexnav_messages) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:dexnav_messages, value == 1) },
      _INTL("Show informational messages when using DexNav.")
    )
    
    # DexNav Repeat Toggle
    options << EnumOption.new(
      _INTL("DexNav Repeat"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:dexnav_repeat) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:dexnav_repeat, value == 1) },
      _INTL("Enable DexNav Repeat option to quickly re-search last species.")
    )
    
    # Clear DexNav Encounter Button
    options << ButtonOption.new(
      _INTL("Clear DexNav Encounter"),
      proc {
        if defined?(DexNav) && DexNav.active
          DexNav.clear_encounter
          pbMessage(_INTL("DexNav encounter cleared! Normal wild encounters resumed."))
        else
          pbMessage(_INTL("No active DexNav encounter to clear."))
        end
      },
      _INTL("Clear the current DexNav encounter and resume normal wild encounters.")
    )
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("DexNav Settings"), 0, 0, Graphics.width, 64, @viewport)
    
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
      
      @sprites["option"].refresh
    end
  end
end

#===============================================================================
# Mod Settings Registration
#===============================================================================
if defined?(ModSettingsMenu)
  reg_proc = proc {
    # Set defaults for DexNav settings
    ModSettingsMenu.set(:dexnav_messages, true) unless ModSettingsMenu.get(:dexnav_messages) != nil
    ModSettingsMenu.set(:dexnav_repeat, false) unless ModSettingsMenu.get(:dexnav_repeat) != nil
    
    # Register DexNav Settings menu
    ModSettingsMenu.register(:dexnav_settings, {
      name: "DexNav",
      type: :button,
      description: "Configure DexNav display options and behavior",
      on_press: proc {
        pbFadeOutIn {
          scene = DexNavSettingsScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      },
      category: "Encounters",
      searchable: [
        "dexnav", "search", "chain", "shiny", "encounter", "species",
        "wild pokemon", "rustle", "messages", "repeat"
      ]
    })
  }

  reg_proc.call
end

#===============================================================================
# Overworld Menu Registration
#===============================================================================

if defined?(OverworldMenu)
  # DexNav
  OverworldMenu.register(:dexnav, {
    label: "DexNav",
    handler: proc { |screen|
      screen.show_dexnav_menu(0)
    },
    priority: 10,
    condition: proc { defined?(DexNav) },
    exit_on_select: true
  })
  
  # DexNav Repeat (conditional on setting)
  OverworldMenu.register(:dexnav_repeat, {
    label: "DN Repeat",
    handler: proc { |screen|
      screen.show_dexnav_repeat(0)
    },
    priority: 1,
    condition: proc { 
      defined?(DexNav) && 
      (ModSettingsMenu.get(:dexnav_repeat) rescue false)
    },
    exit_on_select: true
  })
end

#===============================================================================
# Auto-Update Self-Registration
#===============================================================================
# Register this mod for auto-updates
#===============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "DexNav System",
    file: "11a_DexNav.rb",
    version: "1.0.0",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/11_DexNav.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Changelogs/DexNav%20System.md",
    graphics: [],
    dependencies: ["01a_Overworld_Menu.rb"]
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["11a_DexNav.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("DexNav: DexNav System #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end

