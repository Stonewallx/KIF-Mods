#========================================
# Weather System
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
#========================================

#===============================================================================
# This mod adds dynamic weather changes to outdoor maps with two modes:
# - Real Weather: Follows natural transition patterns (sunny → rain → storm)
# - Random Weather: Randomly selects from enabled weather types
# Weather changes periodically based on configured intervals.
# Fully customizable through the Mod Settings menu.
#===============================================================================

module WeatherSystem
  # Configuration defaults
  ENABLED_DEFAULT = true
  TIME_INTERVAL = 3  # Hours between weather changes (CONFIGURE THIS)
  BATTLE_WEATHER_SYNC_DEFAULT = false  # Sync overworld weather to battles
  REAL_WEATHER_DEFAULT = true  # Use realistic weather patterns by default
  INDOOR_DETECTION_DEFAULT = true  # Automatically disable weather indoors/caves
  WEATHER_INTENSITY_DEFAULT = 100  # Default intensity percentage (0-100%)
  WEATHER_VOLUME_DEFAULT = 30  # Default sound volume percentage (0-100%)
  THUNDER_VOLUME_DEFAULT = 150  # Default thunder sound volume percentage (0-100%)
  
  # Transition Graphics Configuration
  TRANSITIONS_ENABLED_DEFAULT = true  # Enable transition graphics by default
  TRANSITION_FADE_IN_FRAMES = 60      # Frames to fade in (1.0 sec at 60 FPS)
  TRANSITION_HOLD_FRAMES = 150         # Frames to hold at full opacity (2.5 sec)
  TRANSITION_FADE_OUT_FRAMES = 30     # Frames to fade out (0.5 sec)
  
  # Available transition types
  TIME_TRANSITIONS = [:Morning, :Afternoon, :Evening, :Night]
  SEASON_TRANSITIONS = [:Spring, :Summer, :Autumn, :Winter]
  
  # Available weather types for random selection
  WEATHER_TYPES = [
    :None,
    :Rain,
    :Storm,
    :Snow,
    :Blizzard,
    :Sandstorm,
    :HeavyRain,
    :Sunny,
    :Fog
  ]
  
  # Default enabled weather types (excluding extreme weather)
  DEFAULT_ENABLED_WEATHER = [
    :None,
    :Rain,
    :Storm,
    :HeavyRain,
    :Snow,
    :Sunny
  ]
  
  # Weather transition patterns - realistic weather chains
  # Each weather type has weighted probabilities for what comes next
  WEATHER_PATTERNS = {
    :None => {
      :None => 45,      # Stay clear
      :Sunny => 25,     # Get sunny
      :Rain => 15,      # Start raining
      :Fog => 5,       # Morning fog
      :Snow => 5,       # Start snowing
      :Sandstorm => 5   # Dust storm
    },
    :Sunny => {
      :Sunny => 50,     # Stay sunny
      :None => 30,      # Clouds roll in
      :Sandstorm => 10, # Heat causes dust
      :Rain => 10       # Sudden shower
    },
    :Rain => {
      :Rain => 35,      # Keep raining
      :Storm => 25,     # Intensify to storm
      :HeavyRain => 15, # Heavy downpour
      :None => 15,      # Clear up
      :Snow => 10        # Misty after rain
    },
    :Storm => {
      :Storm => 30,     # Continue storming
      :Rain => 40,      # Calm to rain
      :HeavyRain => 20, # Heavy rain
      :None => 10       # Sudden clear
    },
    :HeavyRain => {
      :HeavyRain => 15, # Continue heavy
      :Rain => 40,      # Lighten up
      :Storm => 20,     # Become storm
      :None => 25       # Clear suddenly
    },
    :Snow => {
      :Snow => 40,      # Keep snowing
      :Blizzard => 10,  # Intensify
      :None => 35,      # Stop snowing
      :Fog => 15        # Snowy fog
    },
    :Blizzard => {
      :Blizzard => 30,  # Continue blizzard
      :Snow => 50,      # Calm to snow
      :None => 20       # Clear suddenly
    },
    :Sandstorm => {
      :Sandstorm => 35, # Continue sandstorm
      :None => 40,      # Settle down
      :Sunny => 25      # Clear and hot
    },
    :Fog => {
      :Fog => 30,       # Stay foggy
      :None => 35,      # Lift
      :Rain => 20,      # Turn to rain
      :Sunny => 15      # Burn off
    }
  }
  
  class << self
    # Select the next weather type based on weighted probabilities in WEATHER_PATTERNS
    def next_weather_from_pattern(current_weather)
      pattern = WEATHER_PATTERNS[current_weather] || WEATHER_PATTERNS[:None]
      total = pattern.values.sum
      roll = rand(total)
      cumulative = 0
      pattern.each do |weather, weight|
        cumulative += weight
        return weather if roll < cumulative
      end
      return :None
    end
    # Check if enough time has passed to change the weather
    def should_change_weather?
      last_change_time = $PokemonGlobal.weather_system_last_change_time
      current_time = pbGetTimeNow
      
      # Reset if value is wrong type
      if !last_change_time.is_a?(Time)
        $PokemonGlobal.weather_system_last_change_time = current_time
        return false
      end
      
      interval_seconds = time_interval * 3600  # Convert hours to seconds
      elapsed = (current_time - last_change_time).to_i  # Ensure integer seconds
      
      # If elapsed time is unreasonable (negative or > 30 days), reset and don't change
      if elapsed < 0 || elapsed > (30 * 24 * 3600)
        $PokemonGlobal.weather_system_last_change_time = current_time
        return false
      end
      
      return elapsed >= interval_seconds
    end
    # Initialize the weather change counter if not already set
    def init_counter
      current_time = pbGetTimeNow
      last_time = $PokemonGlobal.weather_system_last_change_time
      
      # Force reset if nil, wrong type, or unreasonably far in past/future
      if last_time.nil? || !last_time.is_a?(Time)
        $PokemonGlobal.weather_system_last_change_time = current_time
      else
        # Check if time difference is unreasonable (more than 30 days)
        diff = (current_time - last_time).abs
        if diff > (30 * 24 * 3600)
          $PokemonGlobal.weather_system_last_change_time = current_time
        end
      end
    end

    # Reset the weather change counter to the current time
    def reset_counter
      current_time = pbGetTimeNow
      $PokemonGlobal.weather_system_last_change_time = current_time
    end
    
    # Get time until next weather change
    def time_until_change
      last_change_time = $PokemonGlobal.weather_system_last_change_time
      current_time = pbGetTimeNow
      
      # Reset if value is wrong type or nil
      if !last_change_time.is_a?(Time)
        $PokemonGlobal.weather_system_last_change_time = current_time
        return "Initialized"
      end
      
      interval_seconds = time_interval * 3600  # Convert hours to seconds
      elapsed = (current_time - last_change_time).to_i  # Ensure integer seconds
      
      # If elapsed time is unreasonable (negative or > 30 days), reset
      if elapsed < 0 || elapsed > (30 * 24 * 3600)
        $PokemonGlobal.weather_system_last_change_time = current_time
        return "Reset (invalid)"
      end
      
      remaining_seconds = interval_seconds - elapsed
      
      if remaining_seconds <= 0
        return "Ready to change"
      else
        hours = (remaining_seconds / 3600).floor
        minutes = ((remaining_seconds % 3600) / 60).floor
        return "#{hours}h #{minutes}m"
      end
    end
    
    # Get the enabled state
    def enabled?
      return ModSettingsMenu.get(:weather_system_enabled) == 1 rescue false
    end
    
    # Check if real weather patterns are enabled
    def real_weather_enabled?
      return ModSettingsMenu.get(:weather_system_real_weather) == 1 rescue REAL_WEATHER_DEFAULT
    end
    
    # Indoor detection is always enabled
    def indoor_detection_enabled?
      return true
    end
    
    # Get time interval in hours
    def time_interval
      return TIME_INTERVAL
    end
    
    # Check if battle weather sync is enabled
    def battle_weather_sync?
      return ModSettingsMenu.get(:weather_system_battle_sync) == 1 rescue BATTLE_WEATHER_SYNC_DEFAULT
    end
    alias battle_sync_enabled? battle_weather_sync?
    
    # Get weather intensity percentage for specific weather type (0-100)
    def weather_intensity_for(weather_type)
      key = "weather_system_intensity_#{weather_type.to_s.downcase}".to_sym
      return ModSettingsMenu.get(key) || WEATHER_INTENSITY_DEFAULT rescue WEATHER_INTENSITY_DEFAULT
    end
    
    # Get weather sound volume percentage for specific weather type (0-100)
    def weather_volume_for(weather_type)
      key = "weather_system_volume_#{weather_type.to_s.downcase}".to_sym
      return ModSettingsMenu.get(key) || WEATHER_VOLUME_DEFAULT rescue WEATHER_VOLUME_DEFAULT
    end
    
    # Get thunder sound volume percentage (0-100)
    def thunder_volume
      return ModSettingsMenu.get(:weather_system_thunder_volume) || THUNDER_VOLUME_DEFAULT rescue THUNDER_VOLUME_DEFAULT
    end
    
    # Check if specific weather type is enabled
    def weather_enabled?(weather_type)
      key = "weather_system_#{weather_type.to_s.downcase}".to_sym
      return ModSettingsMenu.get(key) == 1 rescue DEFAULT_ENABLED_WEATHER.include?(weather_type)
    end
    
    # Get exclusion list for a specific weather type
    def get_exclusion_list(weather_type)
      key = "weather_system_exclude_#{weather_type.to_s.downcase}".to_sym
      list = ModSettingsMenu.get(key)
      return list.is_a?(Array) ? list : []
    end
    
    # Set exclusion list for a specific weather type
    def set_exclusion_list(weather_type, list)
      key = "weather_system_exclude_#{weather_type.to_s.downcase}".to_sym
      ModSettingsMenu.set(key, list)
    end
    
    # Add map to exclusion list for specific weather
    def add_map_to_exclusion(weather_type, map_id)
      list = get_exclusion_list(weather_type)
      list << map_id unless list.include?(map_id)
      set_exclusion_list(weather_type, list)
    end
    
    # Remove map from exclusion list for specific weather
    def remove_map_from_exclusion(weather_type, map_id)
      list = get_exclusion_list(weather_type)
      list.delete(map_id)
      set_exclusion_list(weather_type, list)
    end
    
    # Check if current map is excluded for a specific weather type
    def map_excluded_for_weather?(weather_type, map_id = nil)
      map_id ||= $game_map.map_id
      list = get_exclusion_list(weather_type)
      return list.include?(map_id)
    end
    
    # Get list of currently enabled weather types (filtered by exclusions)
    def enabled_weather_types(map_id = nil)
      map_id ||= $game_map.map_id if $game_map
      types = []
      
      WEATHER_TYPES.each do |weather|
        next if !weather_enabled?(weather)
        next if map_excluded_for_weather?(weather, map_id)
        types << weather
      end
      
      return types
    end
    
    # Get time interval in hours
    def time_interval
      return TIME_INTERVAL
    end
    
    # Select a random weather type from enabled types (fallback)
    def random_weather
      types = enabled_weather_types
      return types[rand(types.length)]
    end
    
    # Check if current map allows random weather
    def map_allows_random_weather?
      return false if !$game_map
      
      map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
      return false if !map_metadata
      
      # Check if map has forced weather (don't override special weather)
      return false if map_metadata.weather
      
      # Check indoor/cave detection if enabled
      if indoor_detection_enabled?
        # Exclude indoor maps (buildings, caves, indoor areas)
        return false if !map_metadata.outdoor_map
      end
      
      return true
    end
    
    # Apply weather change (uses patterns if Real Weather enabled, otherwise random)
    def apply_weather_change(force: false)
      return if !enabled? && !force
      return if !map_allows_random_weather?
      
      current_weather = $game_screen.weather_type rescue :None
      
      # Choose next weather based on Real Weather toggle and Seasons
      if real_weather_enabled?
        # Try seasonal patterns first if enabled
        if WeatherSystem.seasons_enabled?
          new_weather = WeatherSystem.next_weather_from_seasonal_pattern
        end
        # Fall back to regular patterns if no seasonal pattern found
        new_weather ||= next_weather_from_pattern(current_weather)
      else
        new_weather = random_weather
      end
      
      # Don't change to same weather
      return if new_weather == current_weather && !force
      
      # Apply weather with intensity based on type
      power = get_weather_power(new_weather)
      duration = 20  # Smooth transition (1 second at 20 FPS)
      
      $game_screen.weather(new_weather, power, duration)
      
      # Play weather sound
      play_weather_sound(new_weather)
      
      # Store the current weather so it persists across maps
      $PokemonGlobal.weather_system_current_weather = new_weather
      
      # Reset counter for next change
      reset_counter
    end
    
    # Reapply the stored weather (used when changing maps)
    def reapply_weather
      return if !enabled?
      return if !map_allows_random_weather?
      
      stored_weather = $PokemonGlobal.weather_system_current_weather
      return if !stored_weather
      
      # Only restart weather animation if weather type is different
      current_screen_weather = $game_screen.weather_type rescue :None
      weather_changed = (current_screen_weather != stored_weather)
      
      if weather_changed
        # Apply the stored weather (this will restart the animation)
        power = get_weather_power(stored_weather)
        duration = 20
        $game_screen.weather(stored_weather, power, duration)
      end
      
      # Play weather sound without fade (immediate playback)
      play_weather_sound(stored_weather, fade: false)
    end
    
    # Play appropriate background sound for weather
    def play_weather_sound(weather_type, fade: true)
      # Fade out current BGS over 2 seconds if fading is enabled
      if fade
        Audio.bgs_fade(2000) rescue nil  # 2000 milliseconds = 2 seconds
      end
      
      # Get volume from separate volume setting
      volume = weather_volume_for(weather_type)
      pitch = 100
      
      # Determine the sound file to play
      sound_file = case weather_type
      when :Rain
        "Audio/BGS/Rain"
      when :Storm
        "Audio/BGS/Storm"
      when :HeavyRain
        "Audio/BGS/HeavyRain"
      when :Snow, :Blizzard
        "Audio/BGS/Ice"
      when :Sandstorm
        "Audio/BGS/Sandstorm"
      when :Fog
        "Audio/BGS/Fog"
      else
        nil
      end
      
      # Play new sound after fade delay
      if sound_file
        # Schedule the new sound to play after fade completes
        Thread.new do
          sleep(2.1) if fade  # Wait slightly longer than fade time
          Audio.bgs_play(sound_file, volume, pitch) rescue nil
        end
      end
    end
    
    # Get appropriate power level for weather type with custom intensity applied
    def get_weather_power(weather_type)
      base_power = case weather_type
      when :None
        0
      when :Storm, :Blizzard, :HeavyRain
        9  # Maximum intensity
      when :Sandstorm, :Fog
        7  # High intensity
      when :Rain, :Snow
        5  # Medium intensity
      when :Sunny
        0  # Sunny doesn't use particles
      end
      
      # Apply custom intensity percentage
      intensity_percent = weather_intensity_for(weather_type) / 100.0
      adjusted_power = (base_power * intensity_percent).round
      return adjusted_power.clamp(0, 9)
    end
    
    #===========================================================================
    # Transition Graphics System
    #===========================================================================
    
    # Check if transitions are enabled globally
    def transitions_enabled?
      return ModSettingsMenu.get(:weather_system_transitions_enabled) == 1 rescue TRANSITIONS_ENABLED_DEFAULT
    end
    
    # Check if specific time transition is enabled
    def time_transition_enabled?(time_period)
      key = "weather_system_transition_#{time_period.to_s.downcase}".to_sym
      return ModSettingsMenu.get(key) == 1 rescue true
    end
    
    # Check if specific season transition is enabled
    def season_transition_enabled?(season)
      key = "weather_system_transition_#{season.to_s.downcase}".to_sym
      return ModSettingsMenu.get(key) == 1 rescue true
    end
    
    # Get current time period (matches encounter system exactly)
    def current_time_period
      time = pbGetTimeNow
      hour = time.hour
      
      # Match the exact time periods used by PBDayNight for encounters
      if hour >= 5 && hour < 10
        return :Morning
      elsif hour >= 14 && hour < 17
        return :Afternoon
      elsif hour >= 17 && hour < 20
        return :Evening
      else  # hour >= 20 or hour < 5
        return :Night
      end
    end
    
    # Show transition graphic (non-blocking)
    def show_transition(type, name)
      return if !transitions_enabled?
      return if !$scene.is_a?(Scene_Map)
      
      # Don't show transitions if menus are open
      return if $game_temp && $game_temp.in_menu
      
      # Don't show transitions during message windows
      return if $game_temp && $game_temp.message_window_showing
      
      # Don't show transitions if there's an active message window visible
      if $scene.respond_to?(:spriteset) && $scene.spriteset
        return if $scene.spriteset.respond_to?(:message_window) && 
                  $scene.spriteset.message_window && 
                  $scene.spriteset.message_window.visible
      end
      
      # Check if this specific transition is enabled
      if TIME_TRANSITIONS.include?(name)
        return if !time_transition_enabled?(name)
      elsif SEASON_TRANSITIONS.include?(name)
        return if !season_transition_enabled?(name)
      end
      
      # Path to transition graphic
      path = "Graphics/12_Weather System/Transitions/#{name}"
      return if !pbResolveBitmap(path)
      
      # Clean up any existing transition
      dispose_transition_sprite
      
      # Create new transition sprite data
      $PokemonGlobal.weather_system_transition_sprite = {
        sprite: nil,
        path: path,
        phase: :fade_in,
        frame: 0,
        total_frames: 0,  # Total frames elapsed for timeout
        opacity: 0,
        max_total_frames: TRANSITION_FADE_IN_FRAMES + TRANSITION_HOLD_FRAMES + TRANSITION_FADE_OUT_FRAMES + 60  # Add 60 frame buffer
      }
    end
    
    # Update transition sprite (called each frame)
    def update_transition_sprite
      return if !$PokemonGlobal.weather_system_transition_sprite
      return if !$scene.is_a?(Scene_Map)
      
      data = $PokemonGlobal.weather_system_transition_sprite
      
      # Safety check: dispose if we're not in the map scene anymore
      if !$scene.is_a?(Scene_Map)
        dispose_transition_sprite
        return
      end
      
      # Safety check: timeout after maximum frames to prevent stuck transitions
      data[:total_frames] ||= 0
      data[:total_frames] += 1
      max_frames = data[:max_total_frames] || 300  # Default 5 seconds at 60 FPS
      if data[:total_frames] > max_frames
        dispose_transition_sprite
        return
      end
      
      # Wrap in error handler to prevent crashes from breaking input
      begin
        # Create sprite if not yet created
        if !data[:sprite]
          data[:sprite] = Sprite.new
          data[:sprite].bitmap = AnimatedBitmap.new(data[:path]).bitmap
          data[:sprite].z = 99999  # Above everything
          data[:sprite].opacity = 0
        end
        
        sprite = data[:sprite]
        data[:frame] += 1
        
        case data[:phase]
        when :fade_in
          data[:opacity] += (255.0 / TRANSITION_FADE_IN_FRAMES)
          sprite.opacity = data[:opacity].clamp(0, 255)
          if data[:frame] >= TRANSITION_FADE_IN_FRAMES
            data[:phase] = :hold
            data[:frame] = 0
            sprite.opacity = 255
          end
        when :hold
          if data[:frame] >= TRANSITION_HOLD_FRAMES
            data[:phase] = :fade_out
            data[:frame] = 0
          end
        when :fade_out
          data[:opacity] -= (255.0 / TRANSITION_FADE_OUT_FRAMES)
          sprite.opacity = data[:opacity].clamp(0, 255)
          if data[:frame] >= TRANSITION_FADE_OUT_FRAMES
            dispose_transition_sprite
          end
        end
      rescue => e
        # If any error occurs, immediately dispose to prevent stuck state
        dispose_transition_sprite
        ModSettingsMenu.debug_log("WeatherSystem: Transition error: #{e.message}") if defined?(ModSettingsMenu) && $INTERNAL
      end
    end
    
    # Clean up transition sprite
    def dispose_transition_sprite
      return if !$PokemonGlobal
      if $PokemonGlobal.weather_system_transition_sprite
        begin
          data = $PokemonGlobal.weather_system_transition_sprite
          if data[:sprite]
            data[:sprite].bitmap.dispose if data[:sprite].bitmap rescue nil
            data[:sprite].dispose rescue nil
          end
        rescue => e
          ModSettingsMenu.debug_log("WeatherSystem: Dispose error: #{e.message}") if defined?(ModSettingsMenu) && $INTERNAL
        ensure
          # Always clear the global state, even if disposal failed
          $PokemonGlobal.weather_system_transition_sprite = nil
        end
      end
    end
    
    # Check if a transition is currently playing
    def transition_active?
      return false if !$PokemonGlobal
      return $PokemonGlobal.weather_system_transition_sprite != nil
    end
    
    # Trigger time transition if time period changed
    def check_time_transition
      # Don't check transitions if not in overworld
      return if !$scene.is_a?(Scene_Map)
      
      # Don't check if menus are open
      return if $game_temp && $game_temp.in_menu
      
      current = current_time_period
      last = $PokemonGlobal.weather_system_last_time_period
      
      if last && last != current
        show_transition(:time, current)
      end
      
      $PokemonGlobal.weather_system_last_time_period = current
    end
    
    # Trigger season transition if season changed
    def check_season_transition
      return if !seasons_enabled?
      
      # Don't check transitions if not in overworld
      return if !$scene.is_a?(Scene_Map)
      
      # Don't check if menus are open
      return if $game_temp && $game_temp.in_menu
      
      current = current_season
      last = $PokemonGlobal.weather_system_last_season_displayed
      
      if last && last != current
        # Map season names to graphic names
        graphic_name = case current
        when :Fall then :Autumn
        else current
        end
        show_transition(:season, graphic_name)
      end
      
      $PokemonGlobal.weather_system_last_season_displayed = current
    end
  end
end

# Hook into RPG::Weather to disable visual flashes and add random thunder sounds
module RPG
  class Weather
    attr_accessor :thunder_timer
    
    alias owsfx_update update unless method_defined?(:owsfx_update)
    def update
      owsfx_update
      
      # Handle Storm weather: disable flashes and add random thunder
      if @type == :Storm && !@fading
        # Set flash timer to infinity to prevent visual flashes
        @time_until_flash = 999999 if @time_until_flash && @time_until_flash < 999999
        
        # Initialize thunder timer (frames at ~60 FPS)
        @thunder_timer ||= rand(240..480)  # Random interval between 4-8 seconds
        
        # Countdown and play random thunder
        @thunder_timer -= 1
        if @thunder_timer <= 0
          # Play thunder sound with custom volume
          sfx = ["OWThunder1", "OWThunder2"].sample
          volume = WeatherSystem.thunder_volume
          pbSEPlay(sfx, volume) rescue nil
          # Reset timer for next thunder
          @thunder_timer = rand(240..480)
        end
      else
        # Reset thunder timer when not in storm
        @thunder_timer = nil
      end
    end
  end
end

# Block interactions during transitions (but allow movement)
module Input
  class << self
    alias weather_transition_trigger? trigger? unless method_defined?(:weather_transition_trigger?)
    
    def trigger?(button)
      # Block interaction buttons during transitions
      if WeatherSystem.transition_active?
        # Safety check: if not in Scene_Map, force cleanup the stuck transition
        if !$scene.is_a?(Scene_Map)
          WeatherSystem.dispose_transition_sprite
        else
          blocked_buttons = [USE, ACTION, SPECIAL, AUX1, AUX2]
          return false if blocked_buttons.include?(button)
        end
      end
      
      return weather_transition_trigger?(button)
    end
  end
end

#===============================================================================
# Helper Classes for Modern Menu Pattern
#===============================================================================

# StoneSliderOption: Custom slider for Stone's mods (supports negative values)
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

# SpacerOption: For vertical spacing between options
class SpacerOption < Option
  attr_reader :name, :values
  
  def initialize
    super(" ")
    @name = ""
    @values = []
  end
  
  def get
    return 0
  end
  
  def set(value)
  end
  
  def format(value)
    return ""
  end
end

# ModSettingsSpacing: Auto-spacing logic for multi-row dropdowns
module ModSettingsSpacing
  def auto_insert_spacers(options)
    return options unless options.is_a?(Array)
    
    result = []
    items_per_row = 3
    
    options.each do |option|
      result << option
      
      if option.is_a?(EnumOption) && option.values && option.values.length >= 4
        num_values = option.values.length
        num_rows = (num_values + items_per_row - 1) / items_per_row
        spacers_needed = num_rows - 1
        
        spacers_needed.times do
          result << SpacerOption.new
        end
      end
    end
    
    return result
  end
end

#===============================================================================
# Weather System Main Menu Scene
#===============================================================================

class WeatherSystemScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Main toggles
    options << EnumOption.new(_INTL("Weather System"), [_INTL("Off"), _INTL("On")],
      proc { WeatherSystem.enabled? ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:weather_system_enabled, value) },
      _INTL("Enable or disable the weather system"))
    
    options << EnumOption.new(_INTL("Real Weather"), [_INTL("Off"), _INTL("On")],
      proc { WeatherSystem.real_weather_enabled? ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:weather_system_real_weather, value) },
      _INTL("Use realistic weather transition patterns"))
    
    options << EnumOption.new(_INTL("Seasons"), [_INTL("Off"), _INTL("On")],
      proc { WeatherSystem.seasons_enabled? ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:weather_system_seasons_enabled, value) },
      _INTL("Enable seasonal weather patterns"))
    
    options << EnumOption.new(_INTL("Battle Weather Sync"), [_INTL("Off"), _INTL("On")],
      proc { WeatherSystem.battle_sync_enabled? ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:weather_system_battle_sync, value) },
      _INTL("Sync overworld weather to battles"))
    
    options << EnumOption.new(_INTL("Transitions"), [_INTL("Off"), _INTL("On")],
      proc { WeatherSystem.transitions_enabled? ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:weather_system_transitions_enabled, value) },
      _INTL("Show time/season transition graphics"))
    
    # Submenus
    options << ButtonOption.new(_INTL("Change Weather"),
      proc {
        scene = WeatherChangeScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Manually change the current weather"))
    
    options << ButtonOption.new(_INTL("Season Control"),
      proc {
        scene = SeasonControlScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Control the current season"))
    
    options << ButtonOption.new(_INTL("Check Status"),
      proc {
        show_weather_status
      },
      _INTL("View weather system status"))
    
    options << ButtonOption.new(_INTL("Sound Volume"),
      proc {
        scene = WeatherVolumeScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Adjust weather sound volumes"))
    
    options << ButtonOption.new(_INTL("Thunder Volume"),
      proc {
        scene = ThunderVolumeScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Adjust thunder sound volume"))
    
    options << ButtonOption.new(_INTL("Weather Intensity"),
      proc {
        scene = WeatherIntensityScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Adjust weather visual intensity"))
    
    options << ButtonOption.new(_INTL("Enabled Weather Types"),
      proc {
        scene = WeatherTypesScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Toggle which weather types can appear"))
    
    options << ButtonOption.new(_INTL("Transition Graphics"),
      proc {
        scene = TransitionGraphicsScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Configure transition graphics"))
    
    options << ButtonOption.new(_INTL("Map Exclusions"),
      proc {
        scene = MapExclusionsScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
      },
      _INTL("Exclude weather types from specific maps"))
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Weather System"), 0, 0, Graphics.width, 64, @viewport)
    
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

# Simplified entry point
def weather_system_menu
  scene = WeatherSystemScene.new
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

#===============================================================================
# Weather Change Scene
#===============================================================================

class WeatherChangeScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    WeatherSystem::WEATHER_TYPES.each do |weather|
      options << ButtonOption.new(_INTL("{1}", weather.to_s),
        proc {
          power = WeatherSystem.get_weather_power(weather)
          $game_screen.weather(weather, power, 20)
          WeatherSystem.play_weather_sound(weather)
          $PokemonGlobal.weather_system_current_weather = weather
          WeatherSystem.reset_counter
          pbMessage(_INTL("Weather changed to {1}!", weather.to_s))
        },
        _INTL("Change to {1} weather", weather.to_s))
    end
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Change Weather"), 0, 0, Graphics.width, 64, @viewport)
    
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
# Weather Types Toggle Scene
#===============================================================================

class WeatherTypesScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    WeatherSystem::WEATHER_TYPES.each do |weather|
      key = "weather_system_#{weather.to_s.downcase}".to_sym
      options << EnumOption.new(_INTL("{1}", weather.to_s), [_INTL("Off"), _INTL("On")],
        proc { WeatherSystem.weather_enabled?(weather) ? 1 : 0 },
        proc { |value| ModSettingsMenu.set(key, value) },
        _INTL("Enable or disable {1} weather", weather.to_s))
    end
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Enabled Weather Types"), 0, 0, Graphics.width, 64, @viewport)
    
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
# Weather Volume Scene
#===============================================================================

class WeatherVolumeScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    WeatherSystem::WEATHER_TYPES.each do |weather|
      key = "weather_system_volume_#{weather.to_s.downcase}".to_sym
      options << StoneSliderOption.new(_INTL("{1}", weather.to_s), 0, 100, 5,
        proc { WeatherSystem.weather_volume_for(weather) },
        proc { |value|
          ModSettingsMenu.set(key, value)
          # Reapply sound with new volume if this is the current weather
          if $game_screen && $game_screen.weather_type == weather
            WeatherSystem.play_weather_sound(weather)
          end
        },
        _INTL("Sound volume for {1} weather (0-100%)", weather.to_s))
    end
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Weather Sound Volume"), 0, 0, Graphics.width, 64, @viewport)
    
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
# Thunder Volume Scene
#===============================================================================

class ThunderVolumeScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    options << StoneSliderOption.new(_INTL("Thunder Volume"), 0, 150, 5,
      proc { WeatherSystem.thunder_volume },
      proc { |value| ModSettingsMenu.set(:weather_system_thunder_volume, value) },
      _INTL("Volume for thunder sounds (0-150%)"))
    
    options << ButtonOption.new(_INTL("Test Thunder Sound"),
      proc {
        sfx = ["OWThunder1", "OWThunder2"].sample
        volume = WeatherSystem.thunder_volume
        pbSEPlay(sfx, volume) rescue nil
      },
      _INTL("Play a thunder sound effect"))
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Thunder Volume"), 0, 0, Graphics.width, 64, @viewport)
    
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
# Weather Intensity Scene
#===============================================================================

class WeatherIntensityScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Weather types that don't support intensity adjustment (binary on/off)
    no_intensity_types = [:Blizzard, :Sandstorm, :Sunny, :Fog]
    adjustable_weathers = WeatherSystem::WEATHER_TYPES.reject { |w| no_intensity_types.include?(w) }
    
    adjustable_weathers.each do |weather|
      key = "weather_system_intensity_#{weather.to_s.downcase}".to_sym
      options << StoneSliderOption.new(_INTL("{1}", weather.to_s), 0, 150, 5,
        proc { WeatherSystem.weather_intensity_for(weather) },
        proc { |value|
          ModSettingsMenu.set(key, value)
          # Reapply current weather with new intensity if this is the current weather
          if $game_screen && $game_screen.weather_type == weather
            power = WeatherSystem.get_weather_power(weather)
            $game_screen.weather(weather, power, 0)
            WeatherSystem.play_weather_sound(weather)
          end
        },
        _INTL("Visual intensity for {1} weather (0-150%)", weather.to_s))
    end
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Weather Intensity"), 0, 0, Graphics.width, 64, @viewport)
    
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
# Transition Graphics Scene
#===============================================================================

class TransitionGraphicsScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Time of Day Transitions header
    WeatherSystem::TIME_TRANSITIONS.each do |transition|
      key = "weather_system_transition_#{transition.to_s.downcase}".to_sym
      options << EnumOption.new(_INTL("{1}", transition.to_s), [_INTL("Off"), _INTL("On")],
        proc { WeatherSystem.time_transition_enabled?(transition) ? 1 : 0 },
        proc { |value| ModSettingsMenu.set(key, value) },
        _INTL("Show transition graphic for {1}", transition.to_s))
    end
    
    # Season Transitions header
    options << SpacerOption.new
    
    WeatherSystem::SEASON_TRANSITIONS.each do |transition|
      key = "weather_system_transition_#{transition.to_s.downcase}".to_sym
      options << EnumOption.new(_INTL("{1}", transition.to_s), [_INTL("Off"), _INTL("On")],
        proc { WeatherSystem.season_transition_enabled?(transition) ? 1 : 0 },
        proc { |value| ModSettingsMenu.set(key, value) },
        _INTL("Show transition graphic for {1}", transition.to_s))
    end
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Transition Graphics"), 0, 0, Graphics.width, 64, @viewport)
    
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
# Legacy Menu Functions (Complex Dynamic Menus)
#===============================================================================
# These menus retain old Window_CommandPokemonEx pattern due to complex dynamic
# behavior that doesn't fit cleanly into PokemonOption_Scene pattern.

# Status display - uses message windows instead of option scene
def show_weather_status
  WeatherSystem.init_counter
  
  current = $game_screen.weather_type rescue :None
  
  # Page 1: Current Status
  status_text = []
  status_text << _INTL("Current Weather: {1}", current.to_s)
  status_text << _INTL("Mode: {1}", WeatherSystem.real_weather_enabled? ? "Real Weather" : "Random")
  if WeatherSystem.seasons_enabled?
    season = WeatherSystem.current_season
    manual = WeatherSystem.using_manual_season? ? " (Manual)" : ""
    status_text << _INTL("Season: {1}{2}", season, manual)
  end
  pbMessage(status_text.join("\n"))
  
  # Page 2: Timing Info
  timing_text = []
  timing_text << _INTL("Time Until Change: {1}", WeatherSystem.time_until_change)
  timing_text << _INTL("Interval: Every {1} hours", WeatherSystem.time_interval)
  pbMessage(timing_text.join("\n"))
  
  # Page 3: Map Status
  if WeatherSystem.map_allows_random_weather?
    pbMessage(_INTL("Map Status: Ready"))
  else
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    if map_metadata && !map_metadata.outdoor_map && WeatherSystem.indoor_detection_enabled?
      pbMessage(_INTL("Map Status: Indoor/Cave (Blocked)"))
    elsif map_metadata && map_metadata.weather
      pbMessage(_INTL("Map Status: Has Forced Weather"))
    else
      pbMessage(_INTL("Map Status: Not Allowed"))
    end
  end
  
  # Page 4: Enabled Weather Types
  enabled_types = WeatherSystem.enabled_weather_types
  enabled_text = []
  enabled_text << _INTL("Enabled Weather Types: {1}", enabled_types.length)
  enabled_text << ""
  enabled_types.each { |w| enabled_text << "  - #{w}" }
  pbMessage(enabled_text.join("\n"))
end

#===============================================================================
# Season Control Scene
#===============================================================================

class SeasonControlScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    current_season = WeatherSystem.current_season
    using_manual = WeatherSystem.using_manual_season?
    
    # Display current season
    options << EnumOption.new(
      _INTL("Current Season"),
      WeatherSystem::SEASONS.map { |s| _INTL("{1}", s) },
      proc { WeatherSystem::SEASONS.index(WeatherSystem.current_season) || 0 },
      proc { |value|
        selected_season = WeatherSystem::SEASONS[value]
        WeatherSystem.set_manual_season(selected_season)
      },
      _INTL("Select season (automatically enables Manual mode)")
    )
    
    # Show current mode status (display only - use Current Season to change)
    mode_text = using_manual ? "Manual" : "Auto"
    options << EnumOption.new(
      _INTL("Season Mode"),
      [_INTL("Auto"), _INTL("Manual")],
      proc { WeatherSystem.using_manual_season? ? 1 : 0 },
      proc { |value|
        if value == 0  # Auto
          WeatherSystem.set_manual_season(nil)
        end
        # No messages - handled by Current Season dropdown
      },
      _INTL("Current mode (Auto = time-based, Manual = fixed season)")
    )
    
    # Reset to Auto button removed - use Season Mode dropdown instead
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Season Control"), 0, 0, Graphics.width, 64, @viewport)
    
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

def weather_system_season_menu
  scene = SeasonControlScene.new
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

#===============================================================================
# Map Exclusions Scene
#===============================================================================

class MapExclusionsScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    current_map_id = $game_map ? $game_map.map_id : 0
    map_name = pbGetMapNameFromId(current_map_id) rescue "Unknown"
    
    options << ButtonOption.new(_INTL("Add/Edit Current Map (ID: {1})", current_map_id),
      proc {
        scene = AddMapExclusionScene.new(current_map_id)
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
        @sprites["option"].refresh if @sprites["option"]
      },
      _INTL("Exclude weather types for current map: {1}", map_name))
    
    options << ButtonOption.new(_INTL("View/Clear All Exclusions"),
      proc {
        scene = ViewExclusionsScene.new
        screen = PokemonOptionScreen.new(scene)
        pbFadeOutIn { screen.pbStartScreen }
        @sprites["option"].refresh if @sprites["option"]
      },
      _INTL("View and clear excluded maps by weather type"))
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Map Exclusions"), 0, 0, Graphics.width, 64, @viewport)
    
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

def weather_system_exclusions_menu
  scene = MapExclusionsScene.new
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

#===============================================================================
# Add Map Exclusion Scene
#===============================================================================

class AddMapExclusionScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  attr_accessor :map_id
  
  def initialize(map_id)
    @map_id = map_id
    super()
  end
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    WeatherSystem::WEATHER_TYPES.each do |weather|
      options << EnumOption.new(
        _INTL("{1}", weather.to_s),
        [_INTL("Allow"), _INTL("Excluded")],
        proc { WeatherSystem.map_excluded_for_weather?(weather, @map_id) ? 1 : 0 },
        proc { |value|
          if value == 1
            WeatherSystem.add_map_to_exclusion(weather, @map_id)
            # If we just excluded the current weather on the current map, change weather to None
            current_weather = $game_screen.weather_type rescue :None
            if current_weather == weather && @map_id == $game_map.map_id
              $game_screen.weather(:None, 0, 20)
              $PokemonGlobal.weather_system_current_weather = :None
              Audio.bgs_stop rescue nil
            end
          else
            WeatherSystem.remove_map_from_exclusion(weather, @map_id)
          end
        },
        _INTL("Toggle {1} for this map", weather.to_s)
      )
    end
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    map_name = pbGetMapNameFromId(@map_id) rescue "Unknown"
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Map {1}: {2}", @map_id, map_name), 0, 0, Graphics.width, 64, @viewport)
    
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

def weather_system_add_map_exclusion(map_id)
  scene = AddMapExclusionScene.new(map_id)
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

#===============================================================================
# View Exclusions Scene
#===============================================================================

class ViewExclusionsScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    WeatherSystem::WEATHER_TYPES.each do |weather|
      count = WeatherSystem.get_exclusion_list(weather).length
      options << ButtonOption.new(
        _INTL("{1} ({2} maps)", weather.to_s, count),
        proc {
          scene = ClearWeatherExclusionScene.new(weather)
          screen = PokemonOptionScreen.new(scene)
          pbFadeOutIn { screen.pbStartScreen }
          @sprites["option"].refresh if @sprites["option"]
        },
        _INTL("View and clear excluded maps for {1}", weather.to_s)
      )
    end
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("View/Clear Exclusions"), 0, 0, Graphics.width, 64, @viewport)
    
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

def weather_system_view_exclusions_menu
  scene = ViewExclusionsScene.new
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

#===============================================================================
# Clear Exclusion for Weather Scene
#===============================================================================

class ClearWeatherExclusionScene < PokemonOption_Scene
  include ModSettingsSpacing
  
  attr_accessor :weather_type
  
  def initialize(weather_type)
    @weather_type = weather_type
    super()
  end
  
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    list = WeatherSystem.get_exclusion_list(@weather_type)
    
    if list.empty?
      options << SpacerOption.new
      return auto_insert_spacers(options)
    end
    
    list.each do |map_id|
      map_name = pbGetMapNameFromId(map_id) rescue "Unknown"
      options << ButtonOption.new(
        _INTL("Map {1}: {2}", map_id, map_name),
        proc {
          WeatherSystem.remove_map_from_exclusion(@weather_type, map_id)
          pbMessage(_INTL("Removed map {1} from {2} exclusion list.", map_id, @weather_type.to_s))
          @sprites["option"].refresh if @sprites["option"]
        },
        _INTL("Remove this map from exclusion list")
      )
    end
    
    options << SpacerOption.new
    
    options << ButtonOption.new(_INTL("Clear All"),
      proc {
        if pbConfirmMessage(_INTL("Clear all excluded maps for {1}?", @weather_type.to_s))
          WeatherSystem.set_exclusion_list(@weather_type, [])
          pbMessage(_INTL("All exclusions cleared for {1}.", @weather_type.to_s))
          @sprites["option"].refresh if @sprites["option"]
        end
      },
      _INTL("Clear all exclusions for {1}", @weather_type.to_s))
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("{1} Exclusions", @weather_type.to_s), 0, 0, Graphics.width, 64, @viewport)
    
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

def weather_system_clear_exclusion_for_weather(weather_type)
  list = WeatherSystem.get_exclusion_list(weather_type)
  if list.empty?
    pbMessage(_INTL("No excluded maps for {1}.", weather_type.to_s))
    return
  end
  
  scene = ClearWeatherExclusionScene.new(weather_type)
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

# Register submenu with Mod Settings Menu
if defined?(ModSettingsMenu)
  # Initialize default values in storage
  ModSettingsMenu.set(:weather_system_enabled, WeatherSystem::ENABLED_DEFAULT ? 1 : 0) if ModSettingsMenu.get(:weather_system_enabled).nil?
  ModSettingsMenu.set(:weather_system_real_weather, WeatherSystem::REAL_WEATHER_DEFAULT ? 1 : 0) if ModSettingsMenu.get(:weather_system_real_weather).nil?
  ModSettingsMenu.set(:weather_system_battle_sync, WeatherSystem::BATTLE_WEATHER_SYNC_DEFAULT ? 1 : 0) if ModSettingsMenu.get(:weather_system_battle_sync).nil?
  
  # Initialize weather type toggles
  WeatherSystem::WEATHER_TYPES.each do |weather|
    key = "weather_system_#{weather.to_s.downcase}".to_sym
    default = WeatherSystem::DEFAULT_ENABLED_WEATHER.include?(weather) ? 1 : 0
    ModSettingsMenu.set(key, default) if ModSettingsMenu.get(key).nil?
  end
  
  # Initialize weather volume for each type
  WeatherSystem::WEATHER_TYPES.each do |weather|
    key = "weather_system_volume_#{weather.to_s.downcase}".to_sym
    ModSettingsMenu.set(key, WeatherSystem::WEATHER_VOLUME_DEFAULT) if ModSettingsMenu.get(key).nil?
  end
  
  # Initialize thunder volume
  ModSettingsMenu.set(:weather_system_thunder_volume, WeatherSystem::THUNDER_VOLUME_DEFAULT) if ModSettingsMenu.get(:weather_system_thunder_volume).nil?
  
  # Initialize weather intensity for each type
  WeatherSystem::WEATHER_TYPES.each do |weather|
    key = "weather_system_intensity_#{weather.to_s.downcase}".to_sym
    ModSettingsMenu.set(key, WeatherSystem::WEATHER_INTENSITY_DEFAULT) if ModSettingsMenu.get(key).nil?
  end
  
  # Initialize transitions
  ModSettingsMenu.set(:weather_system_transitions_enabled, WeatherSystem::TRANSITIONS_ENABLED_DEFAULT ? 1 : 0) if ModSettingsMenu.get(:weather_system_transitions_enabled).nil?
  
  # Initialize time transitions
  WeatherSystem::TIME_TRANSITIONS.each do |transition|
    key = "weather_system_transition_#{transition.to_s.downcase}".to_sym
    ModSettingsMenu.set(key, 1) if ModSettingsMenu.get(key).nil?  # Default: all enabled
  end
  
  # Initialize season transitions
  WeatherSystem::SEASON_TRANSITIONS.each do |transition|
    key = "weather_system_transition_#{transition.to_s.downcase}".to_sym
    ModSettingsMenu.set(key, 1) if ModSettingsMenu.get(key).nil?  # Default: all enabled
  end
  
  # Register the submenu button using new simplified API
  reg_proc = proc {
    ModSettingsMenu.register(:weather_system_menu, {
      name: "Weather System",
      type: :button,
      description: "Dynamic weather changes with realistic patterns, seasons, transitions, and battle sync",
      on_press: proc {
        pbFadeOutIn {
          weather_system_menu
        }
      },
      category: "Major Systems",
      searchable: [
        "weather", "rain", "snow", "storm", "sunny", "sandstorm",
        "fog", "blizzard", "season", "transition", "battle sync",
        "indoor detection", "intensity", "volume", "real weather"
      ]
    })
  }
  
  reg_proc.call
end

# Event: When stepping in the overworld, check if weather should change
Events.onStepTaken += proc { |_sender|
  next if !WeatherSystem.enabled?
  next if !WeatherSystem.map_allows_random_weather?
  
  WeatherSystem.init_counter
  
  if WeatherSystem.should_change_weather?
    WeatherSystem.apply_weather_change
  end
}

# Event: When changing maps, reapply weather if on outdoor map
Events.onMapChange += proc { |_sender, e|
  next if !WeatherSystem.enabled?
  
  old_map_ID = e[0]
  next if old_map_ID == $game_map.map_id  # Same map, don't reset
  
  # Clean up any active transition sprite when changing maps
  WeatherSystem.dispose_transition_sprite if WeatherSystem.transitions_enabled?
  
  # Just ensure counter is initialized, don't reset it
  # This allows the weather cycle to continue across map changes
  WeatherSystem.init_counter
  
  # Reapply the stored weather if we're on an outdoor map
  if WeatherSystem.map_allows_random_weather?
    WeatherSystem.reapply_weather
  else
    # Stop weather sounds when entering indoor areas
    Audio.bgs_stop rescue nil
  end
}

# Event: After battles end, restore weather sounds
Events.onEndBattle += proc { |_sender, decision, canLose|
  next if !WeatherSystem.enabled?
  next if !WeatherSystem.map_allows_random_weather?
  
  # Restore weather sound after battle
  stored_weather = $PokemonGlobal.weather_system_current_weather
  if stored_weather
    WeatherSystem.play_weather_sound(stored_weather, fade: false)
  end
}

# Event: Update transition sprite each frame
Events.onMapUpdate += proc { |_sender|
  if WeatherSystem.transitions_enabled?
    # Update any active transition sprite
    WeatherSystem.update_transition_sprite
    
    # Check for time and season transitions every frame
    WeatherSystem.check_time_transition
    WeatherSystem.check_season_transition
  end
}

# Hook into pbStartOver to stop weather sounds when returning to title
if defined?(Kernel) && Kernel.method_defined?(:pbStartOver) && !Kernel.method_defined?(:pbStartOver_weather)
  module Kernel
    alias pbStartOver_weather pbStartOver
    def pbStartOver(gameover = false)
      Audio.bgs_stop rescue nil
      pbStartOver_weather(gameover)
    end
  end
end

# Add debug command for testing (optional)
if defined?(DebugMenuCommands)
  DebugMenuCommands.register("weathersystem", {
    "parent"      => "main",
    "name"        => _INTL("Weather System"),
    "description" => _INTL("Test weather system."),
    "always_show" => true,
    "effect"      => proc {
      commands = []
      commands.push(_INTL("Change Weather Now"))
      commands.push(_INTL("Reset Counter"))
      commands.push(_INTL("Toggle System"))
      commands.push(_INTL("Toggle Real Weather"))
      commands.push(_INTL("View Status"))
      
      cmd = pbShowCommands(nil, commands, -1)
      
      case cmd
      when 0  # Change Weather Now
        WeatherSystem.apply_weather_change(force: true)
        pbMessage(_INTL("Weather changed!"))
      when 1  # Reset Counter
        WeatherSystem.reset_counter
        pbMessage(_INTL("Counter reset!"))
      when 2  # Toggle System
        current = WeatherSystem.enabled?
        ModSettingsMenu.set(:weather_system_enabled, current ? 0 : 1)
        pbMessage(_INTL("Weather System {1}!", current ? "Disabled" : "Enabled"))
      when 3  # Toggle Real Weather
        current = WeatherSystem.real_weather_enabled?
        ModSettingsMenu.set(:weather_system_real_weather, current ? 0 : 1)
        pbMessage(_INTL("Real Weather {1}!", current ? "Disabled" : "Enabled"))
      when 4  # View Status
        status = []
        status.push(_INTL("System: {1}", WeatherSystem.enabled? ? "ON" : "OFF"))
        status.push(_INTL("Mode: {1}", WeatherSystem.real_weather_enabled? ? "Real Weather" : "Random"))
        status.push(_INTL("Time Until Change: {1}", WeatherSystem.time_until_change))
        status.push(_INTL("Current Weather: {1}", $game_screen.weather_type))
        status.push(_INTL("Map Allows: {1}", WeatherSystem.map_allows_random_weather? ? "YES" : "NO"))
        status.push(_INTL("Enabled Types: {1}", WeatherSystem.enabled_weather_types.length))
        pbMessage(status.join("\n"))
      end
    }
  })
end  # if defined?(DebugMenuCommands)

# Initialize global variables if needed
class PokemonGlobalMetadata
  attr_accessor :weather_system_last_change_time
  attr_accessor :weather_system_current_weather
  attr_accessor :weather_system_last_time_period
  attr_accessor :weather_system_last_season_displayed
  attr_accessor :weather_system_transition_sprite
end

# Hook into battle start to ensure weather syncs properly
Events.onStartBattle += proc { |_sender|
  next if !WeatherSystem.enabled?
  next if !WeatherSystem.battle_weather_sync?
  
  # The game automatically converts overworld weather categories to battle weather:
  # Overworld → Battle conversions:
  # :Rain, :Storm, :HeavyRain (category :Rain) → Battle :Rain
  # :Snow, :Blizzard (category :Hail) → Battle :Hail
  # :Sandstorm (category :Sandstorm) → Battle :Sandstorm
  # :Sunny (category :Sun) → Battle :Sun
  # :Fog (category :Fog) → No battle weather
  # :None (category :None) → No battle weather
  
  # This happens automatically in pbPrepareBattle, but we can log it for debugging
  if $INTERNAL
    current_weather = $game_screen.weather_type rescue :None
    weather_data = GameData::Weather.try_get(current_weather)
    if weather_data
      ModSettingsMenu.debug_log("WeatherSystem: Overworld: #{current_weather} (#{weather_data.category}) → Battle weather will be set automatically") if defined?(ModSettingsMenu)
    end
  end
}

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Weather System",
    file: "12_Weather System.rb",
    version: "2.0.0",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/12_Weather%20System.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/main/Changelogs/Weather%20System.md",
    graphics: [
      {
        url: "https://github.com/Stonewallx/KIF-Mods/raw/refs/heads/main/Graphics/12_Weather%20System.rar"
      }
    ],
    dependencies: []
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["12_Weather System.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("WeatherSystem: Weather System #{version_str} loaded successfully") if defined?(ModSettingsMenu)
  rescue
    # Silently fail if we can't log
  end
end