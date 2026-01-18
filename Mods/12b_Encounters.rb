#========================================
# Weather System - Encounters Module
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
#========================================

# ENCOUNTER TYPE PRIORITY ORDER (Most Specific → Least Specific)
# The game checks for encounters in this order and uses the FIRST match it finds:
#
# PRIORITY 1: Base + Specific Time + Weather + Season
#   Example: :LandMorningRainSpring
#   When: Morning time (6-10 AM), Rainy weather, Spring season
#
# PRIORITY 2: Base + Specific Time + Weather
#   Example: :LandMorningRain
#   When: Morning time (6-10 AM), Rainy weather (any season)
#
# PRIORITY 3: Base + Weather + Season
#   Example: :LandRainSpring
#   When: Rainy weather, Spring season (any time of day)
#
# PRIORITY 4: Base + Specific Time + Season
#   Example: :LandMorningSpring
#   When: Morning time (6-10 AM), Spring season (any weather)
#
# PRIORITY 5: Base + Weather
#   Example: :LandRain
#   When: Rainy weather (any time, any season)
#
# PRIORITY 6: Base + Season
#   Example: :LandSpring
#   When: Spring season (any time of day, any weather)
#
# PRIORITY 7: Base + Specific Time
#   Example: :LandMorning
#   When: Morning time (6-10 AM) (any weather, any season)
#
# PRIORITY 8-11: Day/Night variants (same as 1-4 but with Day/Night instead)
#   Example: :LandDayRainSpring → :LandDayRain → :LandDaySpring → :LandDay
#
# PRIORITY 12: Base Type Only
#   Example: :Land
#   Fallback when no specific conditions match
#
# TIME PERIODS:
# - Morning: 6 AM - 10 AM
# - Afternoon: 10 AM - 6 PM  
# - Evening: 6 PM - 10 PM
# - Day: 6 AM - 6 PM (general daytime)
# - Night: 6 PM - 6 AM (general nighttime)
#
# SEASONS: Spring, Summer, Fall, Winter (1 month each in UnrealTime)
# WEATHER: None, Rain, HeavyRain, Storm, Snow, Blizzard, Sandstorm, Sunny, Fog
#
#===============================================================================

module EncounterConfig
  
  #=============================================================================
  # CUSTOM ENCOUNTER TABLES - EDIT POKEMON HERE!
  #=============================================================================
  
  # AVAILABLE ENCOUNTER TYPES:
  # 
  # BASE TYPES:
  #   :Land, :LandDay, :LandNight, :LandMorning, :LandAfternoon, :LandEvening
  #   :Water, :WaterDay, :WaterNight, :WaterMorning, :WaterAfternoon, :WaterEvening
  #   :OldRod, :GoodRod, :SuperRod
  #   :RockSmash, :HeadbuttLow, :HeadbuttHigh, :Cave
  #
  # SEASONAL TYPES (add season to any base type):
  #   :LandSpring, :LandSummer, :LandFall, :LandWinter
  #   :WaterSpring, :WaterSummer, :WaterFall, :WaterWinter
  #   (All time variants work: :LandMorningSpring, :WaterDayWinter, etc.)
  #
  # WEATHER TYPES (add weather to any base type):
  #   :LandRain, :LandHeavyRain, :LandStorm, :LandSnow, :LandBlizzard
  #   :LandSandstorm, :LandSunny, :LandFog
  #   (All time variants work: :LandMorningRain, :WaterNightSnow, etc.)
  #
  # WEATHER + SEASON COMBINATIONS (add both to any base type):
  #   :LandRainSpring, :LandSnowWinter, :WaterSunnySummer, :LandStormFall
  #   (All time variants work: :LandMorningRainSpring, :WaterDaySnowWinter, etc.)
  #
  # Total: 500+ possible encounter type combinations!

  # ENCOUNTER FORMAT:
  # MAP_ID => {
  #   :EncounterType => [
  #     [chance, :SPECIES, min_level, max_level],
  #     [chance, :SPECIES, level],  # single level variant
  #   ]
  # }
  
  CUSTOM_ENCOUNTERS = {
    # EXAMPLE: Route 1 (Map ID 2) - Beginner route with common Pokemon
    # 2 => {
    #   # Default land encounters - these appear anytime on this map
    #   # Format: [encounter_chance, :POKEMON_SPECIES, min_level, max_level]
    #   # Note: All chances should add up to 100
    #   :Land => [
    #     [30, :PIDGEY, 2, 4],      # 30% chance to find Pidgey level 2-4
    #     [30, :RATTATA, 2, 4],     # 30% chance to find Rattata level 2-4
    #     [20, :CATERPIE, 2, 3],    # 20% chance to find Caterpie level 2-3
    #     [15, :WEEDLE, 2, 3],      # 15% chance to find Weedle level 2-3
    #     [5, :PIKACHU, 3, 5]       # 5% chance to find Pikachu level 3-5 (rare!)
    #   ],
    #   
    #   # You can add more encounter types for the same map:
    #   # :LandMorning => [...],  # Different encounters in the morning
    #   # :LandSpring => [...],   # Different encounters in spring
    #   # :Water => [...],        # Encounters when surfing
    # },
  }
  
  #=============================================================================
  # GLOBAL ENCOUNTER TABLES
  # These Pokemon will appear on ALL maps for specific encounter types
  # Global encounters are added to existing encounters (won't replace them)
  #=============================================================================
  
  GLOBAL_ENCOUNTERS = {
    # SEASONAL GLOBAL ENCOUNTERS
    # These Pokemon appear everywhere during specific seasons
    
    # Spring - Grass and Bug types everywhere
    # :LandSpring => [
    #   [5, :BUTTERFREE, 10, 20],
    #   [5, :ODDISH, 10, 15]
    # ],
    
  }
  
  # Global encounter mode
  # :add - Adds global encounters to existing map encounters (recommended)
  # :replace - Replaces map encounters entirely with global ones (not recommended)
  GLOBAL_ENCOUNTER_MODE = :add
  
  #=============================================================================
  # Encounter System Methods
  #=============================================================================
  
  # Apply custom encounters when module loads
  def self.apply_custom_encounters
    # Apply map-specific custom encounters
    if !CUSTOM_ENCOUNTERS.empty?
      CUSTOM_ENCOUNTERS.each do |map_id, encounter_tables|
        encounter_tables.each do |enc_type, pokemon_list|
          setup_map_encounters(map_id, enc_type, pokemon_list)
        end
      end
    end
    
    # Store global encounters for later injection
    apply_global_encounters
  end
  
  # Store global encounter data
  def self.apply_global_encounters
    return if GLOBAL_ENCOUNTERS.empty?
    
    @global_encounter_data = GLOBAL_ENCOUNTERS
  end
  
  # Get global encounters for a specific type
  def self.get_global_encounters(enc_type)
    return nil if !@global_encounter_data
    return @global_encounter_data[enc_type]
  end
  
  # Check if there are global encounters for this type
  def self.has_global_encounters?(enc_type)
    return false if !@global_encounter_data
    return @global_encounter_data.has_key?(enc_type)
  end
  
  # Store encounter data for a map
  def self.setup_map_encounters(map_id, enc_type, pokemon_list)
    @custom_encounter_data ||= {}
    @custom_encounter_data[map_id] ||= {}
    @custom_encounter_data[map_id][enc_type] = pokemon_list
  end
  
  # Get custom encounters for a map and type
  def self.get_custom_encounters(map_id, enc_type)
    return nil if !@custom_encounter_data
    return nil if !@custom_encounter_data[map_id]
    return @custom_encounter_data[map_id][enc_type]
  end
  
  # Check if map has custom encounters
  def self.has_custom_encounters?(map_id)
    return false if !@custom_encounter_data
    return @custom_encounter_data.has_key?(map_id)
  end
  
  # Export single map to PBS format
  def self.export_to_pbs_format(map_id)
    return "" if !has_custom_encounters?(map_id)
    
    output = "[#{sprintf("%03d", map_id)}] # Custom Map\n"
    
    @custom_encounter_data[map_id].each do |enc_type, pokemon_list|
      trigger_chance = case enc_type.to_s
        when /^Land/ then 21
        when /^Water/ then 2
        when /^Cave/ then 5
        when /^RockSmash/ then 50
        else nil
      end
      
      output += "#{enc_type}"
      output += ",#{trigger_chance}" if trigger_chance
      output += "\n"
      
      pokemon_list.each do |data|
        chance, species, min_level, max_level = data
        output += "    #{chance},#{species}"
        output += ",#{min_level}"
        output += ",#{max_level}" if max_level && max_level != min_level
        output += "\n"
      end
    end
    
    return output
  end
  
  # Export all maps to PBS format
  def self.export_all_to_pbs
    if !@custom_encounter_data || @custom_encounter_data.empty?
      ModSettingsMenu.debug_log("No custom encounters defined!")
      return
    end
    
    ModSettingsMenu.debug_log("="*80)
    ModSettingsMenu.debug_log("CUSTOM ENCOUNTERS IN PBS FORMAT")
    ModSettingsMenu.debug_log("Copy this to PBS/encounters.txt")
    ModSettingsMenu.debug_log("="*80)
    
    @custom_encounter_data.keys.sort.each do |map_id|
      ModSettingsMenu.debug_log(export_to_pbs_format(map_id))
      ModSettingsMenu.debug_log("#" + "-"*78)
    end
  end
  
  #=============================================================================
  # Encounter Type Reference
  #=============================================================================
  
  def self.all_encounter_types
    types = []
    
    base_types = [
      :Land, :LandDay, :LandNight, :LandMorning, :LandAfternoon, :LandEvening,
      :Water, :WaterDay, :WaterNight, :WaterMorning, :WaterAfternoon, :WaterEvening,
      :OldRod, :GoodRod, :SuperRod,
      :RockSmash, :HeadbuttLow, :HeadbuttHigh,
      :Cave
    ]
    
    types += base_types
    
    seasons = [:Spring, :Summer, :Fall, :Winter]
    base_types.each do |base|
      next if base == :Cave
      seasons.each do |season|
        types << "#{base}#{season}".to_sym
      end
    end
    
    weather_types = [:Rain, :HeavyRain, :Storm, :Snow, :Blizzard, :Sandstorm, :Sunny, :Fog]
    base_types.each do |base|
      next if base == :Cave
      weather_types.each do |weather|
        types << "#{base}#{weather}".to_sym
      end
    end
    
    base_types.each do |base|
      next if base == :Cave
      weather_types.each do |weather|
        seasons.each do |season|
          types << "#{base}#{weather}#{season}".to_sym
        end
      end
    end
    
    return types.sort
  end
  
  def self.print_all_types
    ModSettingsMenu.debug_log("="*80)
    ModSettingsMenu.debug_log("ALL ENCOUNTER TYPES (#{all_encounter_types.length} total)")
    ModSettingsMenu.debug_log("="*80)
    all_encounter_types.each_slice(3) do |slice|
      ModSettingsMenu.debug_log("  " + slice.map { |t| t.to_s.ljust(35) }.join)
    end
    ModSettingsMenu.debug_log("="*80)
  end
end

#===============================================================================
# PokemonEncounters Integration
#===============================================================================

class PokemonEncounters
  alias custom_enc_setup setup unless method_defined?(:custom_enc_setup)
  
  def setup(map_id)
    custom_enc_setup(map_id)
    
    # Inject map-specific custom encounters
    if EncounterConfig.has_custom_encounters?(map_id)
      inject_custom_encounters(map_id)
    end
    
    # Inject global encounters for all encounter types on this map
    inject_global_encounters
  end
  
  def inject_custom_encounters(map_id)
    custom_data = EncounterConfig.instance_variable_get(:@custom_encounter_data)
    return if !custom_data || !custom_data[map_id]
    
    custom_data[map_id].each do |enc_type, pokemon_list|
      enc_data = []
      pokemon_list.each do |data|
        chance, species, min_level, max_level = data
        max_level = min_level if !max_level
        enc_data.push([chance, species, min_level, max_level])
      end
      
      set_encounters_for_type(enc_type, enc_data)
    end
  end
  
  def inject_global_encounters
    @encounter_tables ||= []
    
    # Check each encounter table on this map
    @encounter_tables.each do |table|
      enc_type = table[0]
      
      # Check if there are global encounters for this type
      global_enc = EncounterConfig.get_global_encounters(enc_type)
      next if !global_enc
      
      # Convert global encounter format to game format
      global_data = []
      global_enc.each do |data|
        chance, species, min_level, max_level = data
        max_level = min_level if !max_level
        global_data.push([chance, species, min_level, max_level])
      end
      
      # Add or replace based on mode
      mode = EncounterConfig::GLOBAL_ENCOUNTER_MODE
      if mode == :add
        # Add global encounters to existing ones
        add_global_to_existing(enc_type, global_data)
      elsif mode == :replace
        # Replace with global encounters only
        set_encounters_for_type(enc_type, global_data)
      end
    end
  end
  
  def add_global_to_existing(enc_type, global_data)
    @encounter_tables ||= []
    
    # Find existing table
    existing = @encounter_tables.find { |table| table[0] == enc_type }
    return if !existing
    
    # Merge global encounters with existing
    existing[1] ||= []
    existing[1].concat(global_data)
    
    # Normalize chances so they still add up correctly
    # Global encounters add extra spawns but maintain relative rarity
  end
  
  def set_encounters_for_type(enc_type, enc_data)
    @encounter_tables ||= []
    @encounter_tables.delete_if { |table| table[0] == enc_type }
    @encounter_tables.push([enc_type, enc_data])
  end
end

#===============================================================================
# Helper Functions
#===============================================================================

def print_encounter_types
  EncounterConfig.print_all_types
end

def export_encounters_to_pbs(map_id = nil)
  if map_id
    ModSettingsMenu.debug_log(EncounterConfig.export_to_pbs_format(map_id))
  else
    EncounterConfig.export_all_to_pbs
  end
end

#===============================================================================
# Console Commands (F12 debug console):
#
# print_encounter_types
#   - Shows all 500+ available encounter types
#
# export_encounters_to_pbs
#   - Exports all custom encounters in PBS format
#
# export_encounters_to_pbs(8)
#   - Exports encounters for map 8 only
#
#===============================================================================

# Apply custom encounters
EncounterConfig.apply_custom_encounters

# Load message
ModSettingsMenu.debug_log("="*80)
ModSettingsMenu.debug_log("12b_Encounters.rb loaded successfully!")
custom_map_count = EncounterConfig.instance_variable_get(:@custom_encounter_data)&.keys&.length || 0
global_enc_count = EncounterConfig.instance_variable_get(:@global_encounter_data)&.keys&.length || 0

if custom_map_count > 0
  ModSettingsMenu.debug_log("Custom encounters: #{custom_map_count} map(s)")
end
if global_enc_count > 0
  ModSettingsMenu.debug_log("Global encounters: #{global_enc_count} encounter type(s) - Mode: #{EncounterConfig::GLOBAL_ENCOUNTER_MODE}")
end
if custom_map_count == 0 && global_enc_count == 0
  ModSettingsMenu.debug_log("No custom encounters defined - edit CUSTOM_ENCOUNTERS or GLOBAL_ENCOUNTERS!")
end
ModSettingsMenu.debug_log("="*80)

#===============================================================================
# Helper Functions
#===============================================================================

def print_encounter_types
  EncounterConfig.print_all_types
end

def export_encounters_to_pbs(map_id = nil)
  if map_id
    ModSettingsMenu.debug_log(EncounterConfig.export_to_pbs_format(map_id), "WeatherSystem")
  else
    EncounterConfig.export_all_to_pbs
  end
end
