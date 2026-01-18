#========================================
# Weather System - Seasons Module
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
#========================================

module WeatherSystem
  # Seasonal configuration
  SEASONS_ENABLED_DEFAULT = true
  SEASON_DURATION_DAYS = 7  # Each season lasts 7 in-game days
  
  SEASONS = [:Spring, :Summer, :Fall, :Winter]
  
  #=============================================================================
  # Seasonal Weather Patterns
  # Each season has different weather probabilities for each weather type
  # Higher weights = more likely to occur
  #=============================================================================
  SEASONAL_PATTERNS = {
    # Spring: Rainy season with occasional storms
    :Spring => {
      :None => {
        :None => 40,
        :Rain => 25,
        :HeavyRain => 10,
        :Storm => 5,
        :Fog => 15,
        :Sunny => 5
      },
      :Rain => {
        :Rain => 35,
        :HeavyRain => 20,
        :Storm => 15,
        :None => 20,
        :Fog => 10
      },
      :HeavyRain => {
        :HeavyRain => 30,
        :Storm => 25,
        :Rain => 25,
        :Fog => 10,
        :None => 10
      },
      :Storm => {
        :Storm => 20,
        :HeavyRain => 30,
        :Rain => 30,
        :Fog => 15,
        :None => 5
      },
      :Snow => {
        :Rain => 40,
        :None => 30,
        :Fog => 20,
        :HeavyRain => 10
      },
      :Blizzard => {
        :Storm => 40,
        :HeavyRain => 30,
        :Rain => 20,
        :Fog => 10
      },
      :Sandstorm => {
        :None => 40,
        :Sandstorm => 30,
        :Fog => 20,
        :Sunny => 10
      },
      :Sunny => {
        :Sunny => 35,
        :None => 35,
        :Fog => 15,
        :Rain => 10,
        :HeavyRain => 5
      },
      :Fog => {
        :Fog => 35,
        :None => 25,
        :Rain => 25,
        :HeavyRain => 10,
        :Storm => 5
      }
    },
    
    # Summer: Hot and dry with occasional storms
    :Summer => {
      :None => {
        :None => 35,
        :Sunny => 30,
        :Storm => 10,
        :Rain => 15,
        :Sandstorm => 5,
        :Fog => 5
      },
      :Rain => {
        :Rain => 30,
        :Storm => 20,
        :HeavyRain => 15,
        :None => 20,
        :Sunny => 15
      },
      :HeavyRain => {
        :HeavyRain => 25,
        :Storm => 30,
        :Rain => 25,
        :None => 15,
        :Sunny => 5
      },
      :Storm => {
        :Storm => 25,
        :HeavyRain => 30,
        :Rain => 20,
        :None => 15,
        :Sunny => 10
      },
      :Snow => {
        :None => 40,
        :Rain => 30,
        :Sunny => 20,
        :Storm => 10
      },
      :Blizzard => {
        :Storm => 40,
        :HeavyRain => 30,
        :Rain => 20,
        :None => 10
      },
      :Sandstorm => {
        :Sandstorm => 40,
        :None => 25,
        :Sunny => 20,
        :Fog => 10,
        :Storm => 5
      },
      :Sunny => {
        :Sunny => 50,
        :None => 30,
        :Sandstorm => 10,
        :Fog => 5,
        :Rain => 5
      },
      :Fog => {
        :Fog => 30,
        :None => 30,
        :Sunny => 20,
        :Rain => 15,
        :Storm => 5
      }
    },
    
    # Fall: Transition season with varied weather
    :Fall => {
      :None => {
        :None => 40,
        :Fog => 20,
        :Rain => 15,
        :Sunny => 10,
        :Storm => 5,
        :Snow => 5,
        :Sandstorm => 5
      },
      :Rain => {
        :Rain => 35,
        :None => 25,
        :Fog => 15,
        :Storm => 10,
        :HeavyRain => 10,
        :Snow => 5
      },
      :HeavyRain => {
        :HeavyRain => 30,
        :Rain => 25,
        :Storm => 20,
        :Fog => 15,
        :None => 10
      },
      :Storm => {
        :Storm => 25,
        :HeavyRain => 25,
        :Rain => 25,
        :Fog => 15,
        :None => 10
      },
      :Snow => {
        :Snow => 35,
        :None => 25,
        :Fog => 20,
        :Rain => 10,
        :Blizzard => 5,
        :Sunny => 5
      },
      :Blizzard => {
        :Blizzard => 30,
        :Snow => 30,
        :Storm => 20,
        :Fog => 15,
        :None => 5
      },
      :Sandstorm => {
        :Sandstorm => 35,
        :None => 30,
        :Fog => 20,
        :Sunny => 10,
        :Storm => 5
      },
      :Sunny => {
        :Sunny => 35,
        :None => 35,
        :Fog => 15,
        :Sandstorm => 10,
        :Rain => 5
      },
      :Fog => {
        :Fog => 40,
        :None => 30,
        :Rain => 15,
        :Snow => 10,
        :Storm => 5
      }
    },
    
    # Winter: Cold and snowy
    :Winter => {
      :None => {
        :None => 30,
        :Snow => 25,
        :Fog => 20,
        :Blizzard => 10,
        :Sunny => 10,
        :Rain => 5
      },
      :Rain => {
        :Snow => 30,
        :Rain => 25,
        :None => 20,
        :Fog => 15,
        :Storm => 5,
        :Blizzard => 5
      },
      :HeavyRain => {
        :Blizzard => 30,
        :Snow => 25,
        :Storm => 20,
        :Fog => 15,
        :None => 10
      },
      :Storm => {
        :Blizzard => 35,
        :Storm => 25,
        :Snow => 20,
        :Fog => 15,
        :None => 5
      },
      :Snow => {
        :Snow => 40,
        :Blizzard => 20,
        :None => 20,
        :Fog => 15,
        :Sunny => 5
      },
      :Blizzard => {
        :Blizzard => 35,
        :Snow => 30,
        :Fog => 20,
        :None => 10,
        :Storm => 5
      },
      :Sandstorm => {
        :Blizzard => 30,
        :Snow => 25,
        :None => 20,
        :Fog => 15,
        :Sunny => 10
      },
      :Sunny => {
        :Sunny => 30,
        :None => 30,
        :Snow => 20,
        :Fog => 15,
        :Blizzard => 5
      },
      :Fog => {
        :Fog => 40,
        :None => 25,
        :Snow => 20,
        :Blizzard => 10,
        :Sunny => 5
      }
    }
  }
  
  #=============================================================================
  # Seasonal Methods
  #=============================================================================
  
  # Check if seasonal patterns are enabled
  def seasons_enabled?
    return ModSettingsMenu.get(:weather_system_seasons_enabled) == 1 rescue SEASONS_ENABLED_DEFAULT
  end
  
  # Get current season based on in-game time (5 in-game days per season cycle)
  def current_season
    # Check if manual season override is set (stored as integer index)
    manual_season_index = ModSettingsMenu.get(:weather_system_manual_season)
    if manual_season_index.is_a?(Integer) && manual_season_index >= 0 && manual_season_index < SEASONS.length
      return SEASONS[manual_season_index]
    end
    
    # Calculate season from UnrealTime overworld clock
    current_time = pbGetTimeNow
    initial_time = defined?(UnrealTime) && UnrealTime.respond_to?(:initial_date) ? UnrealTime.initial_date : Time.local(2000, 1, 1, 4, 0)
    elapsed_seconds = (current_time - initial_time).to_i
    total_days = elapsed_seconds / 86400  # 86400 seconds per day
    
    # Determine season based on days elapsed
    season_index = (total_days / SEASON_DURATION_DAYS) % SEASONS.length
    return SEASONS[season_index]
  end
  
  # Manually set the season (pass season symbol or nil to clear)
  def set_manual_season(season)
    if season.nil?
      ModSettingsMenu.set(:weather_system_manual_season, nil)
    elsif SEASONS.include?(season)
      # Store as integer index instead of symbol for better compatibility
      season_index = SEASONS.index(season)
      ModSettingsMenu.set(:weather_system_manual_season, season_index)
    end
  end
  
  # Check if using manual season override
  def using_manual_season?
    manual_season_index = ModSettingsMenu.get(:weather_system_manual_season)
    return manual_season_index.is_a?(Integer) && manual_season_index >= 0 && manual_season_index < SEASONS.length
  end
  
  # Get next weather based on seasonal patterns
  def next_weather_from_seasonal_pattern
    return nil if !seasons_enabled?
    
    current = $game_screen.weather_type rescue :None
    season = current_season
    
    # Get seasonal pattern for current season
    season_patterns = SEASONAL_PATTERNS[season]
    return nil if !season_patterns
    
    # Get transitions for current weather
    transitions = season_patterns[current]
    return nil if !transitions
    
    # Filter transitions to only include enabled weather types and not excluded for current map
    enabled_transitions = {}
    transitions.each do |weather, weight|
      next if !weather_enabled?(weather)
      next if map_excluded_for_weather?(weather)
      enabled_transitions[weather] = weight
    end
    
    # If no enabled transitions, return nil to fall back to random
    return nil if enabled_transitions.empty?
    
    # Weighted random selection
    total_weight = enabled_transitions.values.sum
    roll = rand(total_weight)
    
    cumulative = 0
    enabled_transitions.each do |weather, weight|
      cumulative += weight
      return weather if roll < cumulative
    end
    
    # Fallback (should never reach here)
    return enabled_transitions.keys.first
  end
  
  # Get time until next season as a hash with days and hours
  def time_until_next_season
    return nil if using_manual_season?  # No time tracking for manual seasons
    
    # Calculate remaining time using UnrealTime overworld clock
    current_time = pbGetTimeNow
    initial_time = defined?(UnrealTime) && UnrealTime.respond_to?(:initial_date) ? UnrealTime.initial_date : Time.local(2000, 1, 1, 4, 0)
    elapsed_seconds = (current_time - initial_time).to_i
    total_days = elapsed_seconds / 86400.0
    days_into_season = total_days % SEASON_DURATION_DAYS
    seconds_remaining = (SEASON_DURATION_DAYS - days_into_season) * 86400
    
    days = (seconds_remaining / 86400).floor
    hours = ((seconds_remaining % 86400) / 3600).floor
    
    return { days: days, hours: hours }
  end
  
  module_function :seasons_enabled?, :current_season,
                  :set_manual_season, :using_manual_season?,
                  :next_weather_from_seasonal_pattern,
                  :time_until_next_season
end

# Add season tracker to global metadata
class PokemonGlobalMetadata
  attr_accessor :weather_system_season_start_time
end

#===============================================================================
# Register Seasonal Encounter Types
# These encounters trigger based on both weather AND season
#===============================================================================

# Helper method to register seasonal variants for a base encounter type
def register_seasonal_encounters(base_type, type_category, trigger_chance = nil)
  # Register base seasonal encounters (no weather)
  WeatherSystem::SEASONS.each do |season|
    params = {
      :id => "#{base_type}#{season}".to_sym,
      :type => type_category
    }
    params[:trigger_chance] = trigger_chance if trigger_chance
    GameData::EncounterType.register(params)
  end
  
  # Register weather + season combinations
  weather_types = [:Rain, :Storm, :Snow, :Blizzard, :Sandstorm, :HeavyRain, :Sunny, :Fog]
  weather_types.each do |weather|
    WeatherSystem::SEASONS.each do |season|
      params = {
        :id => "#{base_type}#{weather}#{season}".to_sym,
        :type => type_category
      }
      params[:trigger_chance] = trigger_chance if trigger_chance
      GameData::EncounterType.register(params)
    end
  end
end

# Register seasonal encounters for all base types
register_seasonal_encounters(:Land, :land, 21)
register_seasonal_encounters(:LandDay, :land, 21)
register_seasonal_encounters(:LandNight, :land, 21)
register_seasonal_encounters(:LandMorning, :land, 21)
register_seasonal_encounters(:LandAfternoon, :land, 21)
register_seasonal_encounters(:LandEvening, :land, 21)
register_seasonal_encounters(:Water, :water, 2)
register_seasonal_encounters(:WaterDay, :water, 2)
register_seasonal_encounters(:WaterNight, :water, 2)
register_seasonal_encounters(:WaterMorning, :water, 2)
register_seasonal_encounters(:WaterAfternoon, :water, 2)
register_seasonal_encounters(:WaterEvening, :water, 2)
register_seasonal_encounters(:OldRod, :fishing)
register_seasonal_encounters(:GoodRod, :fishing)
register_seasonal_encounters(:SuperRod, :fishing)
register_seasonal_encounters(:RockSmash, :none, 50)
register_seasonal_encounters(:HeadbuttLow, :none)
register_seasonal_encounters(:HeadbuttHigh, :none)

#===============================================================================
# Encounter System Integration
# Modify the encounter system to check for seasonal variants
#===============================================================================

class PokemonEncounters
  # Original method aliased
  alias seasonal_find_valid_encounter_type_for_time find_valid_encounter_type_for_time unless method_defined?(:seasonal_find_valid_encounter_type_for_time)
  
  # Enhanced encounter type finder with seasonal support
  def find_valid_encounter_type_for_time(base_type, time = nil)
    time ||= pbGetTimeNow
    ret = nil
    
    # Determine time of day
    time_suffix = ""
    if PBDayNight.isDay?(time)
      if PBDayNight.isMorning?(time)
        time_suffix = "Morning"
      elsif PBDayNight.isAfternoon?(time)
        time_suffix = "Afternoon"
      elsif PBDayNight.isEvening?(time)
        time_suffix = "Evening"
      else
        time_suffix = "Day"
      end
    else
      time_suffix = "Night"
    end
    
    # Get current weather and season
    weather = $game_screen.weather_type rescue :None
    season = WeatherSystem.seasons_enabled? ? WeatherSystem.current_season : nil
    
    # Priority order for encounter type checking:
    # 1. Base + Time + Weather + Season (e.g., LandMorningRainSpring)
    # 2. Base + Time + Weather (e.g., LandMorningRain)
    # 3. Base + Weather + Season (e.g., LandRainSpring)
    # 4. Base + Time + Season (e.g., LandMorningSpring)
    # 5. Base + Weather (e.g., LandRain)
    # 6. Base + Season (e.g., LandSpring)
    # 7. Base + Time (e.g., LandMorning)
    # 8. Base + Day/Night + Weather + Season
    # 9. Base + Day/Night + Weather
    # 10. Base + Day/Night + Season
    # 11. Base + Day/Night
    # 12. Base type
    
    if season && weather != :None
      # Try: Base + specific time + weather + season
      if time_suffix != "Day" && time_suffix != "Night"
        try_type = "#{base_type}#{time_suffix}#{weather}#{season}".to_sym
        return try_type if has_encounter_type?(try_type)
      end
      
      # Try: Base + Day/Night + weather + season
      day_night = PBDayNight.isDay?(time) ? "Day" : "Night"
      try_type = "#{base_type}#{day_night}#{weather}#{season}".to_sym
      return try_type if has_encounter_type?(try_type)
      
      # Try: Base + weather + season
      try_type = "#{base_type}#{weather}#{season}".to_sym
      return try_type if has_encounter_type?(try_type)
    end
    
    if weather != :None
      # Try: Base + specific time + weather
      if time_suffix != "Day" && time_suffix != "Night"
        try_type = "#{base_type}#{time_suffix}#{weather}".to_sym
        return try_type if has_encounter_type?(try_type)
      end
      
      # Try: Base + Day/Night + weather
      day_night = PBDayNight.isDay?(time) ? "Day" : "Night"
      try_type = "#{base_type}#{day_night}#{weather}".to_sym
      return try_type if has_encounter_type?(try_type)
      
      # Try: Base + weather
      try_type = "#{base_type}#{weather}".to_sym
      return try_type if has_encounter_type?(try_type)
    end
    
    if season
      # Try: Base + specific time + season
      if time_suffix != "Day" && time_suffix != "Night"
        try_type = "#{base_type}#{time_suffix}#{season}".to_sym
        return try_type if has_encounter_type?(try_type)
      end
      
      # Try: Base + Day/Night + season
      day_night = PBDayNight.isDay?(time) ? "Day" : "Night"
      try_type = "#{base_type}#{day_night}#{season}".to_sym
      return try_type if has_encounter_type?(try_type)
      
      # Try: Base + season
      try_type = "#{base_type}#{season}".to_sym
      return try_type if has_encounter_type?(try_type)
    end
    
    # Fall back to original method (handles time-based encounters)
    return seasonal_find_valid_encounter_type_for_time(base_type, time)
  end
end

#===============================================================================
# Seasonal Menu Integration
# Add menu option to manage seasons
#===============================================================================

def weather_system_season_menu
  season_index = WeatherSystem::SEASONS.index(WeatherSystem.current_season) || 0
  loop do
    current_season = WeatherSystem::SEASONS[season_index]
    using_manual = WeatherSystem.using_manual_season?
    
    cmds = []
    cmds << _INTL("Current Season: {1}{2}", current_season, using_manual ? " (Manual)" : " (Auto)")
    cmds << _INTL("Set Manual Season")
    cmds << _INTL("Reset to Auto Season")
    cmds << _INTL("Back")
    
    cmdwindow = Window_CommandPokemonEx.new(cmds)
    cmdwindow.z = 99999
    cmdwindow.visible = true
    screen_w = (Graphics.width rescue 480)
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.width = screen_w - 15
    pbPositionNearMsgWindow(cmdwindow, nil, :right)
    cmdwindow.index = 0
    exit_menu = false
    
    begin
      loop do
        Graphics.update; Input.update
        cmdwindow.update
        
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          exit_menu = true
          break
        end
        
        if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
          if cmdwindow.index == 0
            # Cycle through seasons
            dir = Input.trigger?(Input::LEFT) ? -1 : 1
            season_index = (season_index + dir) % WeatherSystem::SEASONS.length
            WeatherSystem.set_manual_season(WeatherSystem::SEASONS[season_index])
            pbPlayCursorSE
            exit_menu = true
            break
          end
        elsif Input.trigger?(Input::USE)
          case cmdwindow.index
          when 0  # Current Season display
            pbPlayCancelSE
          when 1  # Set Manual Season
            # Cycle to next season
            season_index = (season_index + 1) % WeatherSystem::SEASONS.length
            WeatherSystem.set_manual_season(WeatherSystem::SEASONS[season_index])
            pbPlayDecisionSE
            exit_menu = true
            break
          when 2  # Reset to Auto
            WeatherSystem.set_manual_season(nil)
            pbPlayDecisionSE
            exit_menu = true
            break
          when 3  # Back
            pbPlayCancelSE
            exit_menu = true
            break
          end
        end
      end
    ensure
      cmdwindow.dispose if cmdwindow
    end
    
    break if exit_menu
  end
end
