#========================================
# Trainer Control Mod
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
#========================================

# ============================================================================
# CONFIGURATION
# ============================================================================
module TrainerControl
  module Config
    # Level Scaling Settings
    LEVEL_SCALING_DEFAULT = false          # Enable level scaling by default
    # Positive values = trainers ABOVE your level (e.g., +5 = trainers 5 levels higher)
    # Negative values = trainers BELOW your level (e.g., -2 = trainers 2 levels lower)
    # Zero = trainers match your highest Pokemon's level
    DEFAULT_LEVEL_OFFSET = 0              # Default offset for level scaling
    
    # Extra Pokemon Settings
    EXTRA_POKEMON_DEFAULT_MODE = 0        # 0=Off, 1=Type Pool, 2=Random, 3=Fusion
    EXTRA_POKEMON_DEFAULT_COUNT = 1       # Default number of extra Pokemon to add (1-3)
    MAX_PARTY_SIZE = 6                    # Maximum Pokemon in a trainer's party
    GYM_LEADER_FULL_PARTY_DEFAULT = false # Force gym leaders to always have 6 Pokemon
    
    # Trainer Adaptation Settings
    TEAM_ADAPTATION_DEFAULT = true        # Enable team adaptation by default
    BATTLE_RECORD_DISPLAY_DEFAULT = true  # Show Battle Record message at battle start
    PROGRESSION_REWARDS_DEFAULT = true    # Enable progression rewards by default
    WINS_FOR_REWARD = 10                  # Number of wins needed for reward
    
    # Alpha Pokemon Settings (requires AlphaHordes or Raids mod)
    ALPHA_COUNTER_POKEMON_CHANCE = 3     # Percent chance for counter Pokemon to be Alpha (0-100)
    
    # Debug Settings
    DEBUG_MESSAGES = false                # When true, writes detailed debug messages to ModsDebug.txt in save folder
    
    # Reward pool for progression (items given after WINS_FOR_REWARD victories)
    # Each entry may be:
    #   :ITEMSYMBOL                       -> gives 1 of ITEMSYMBOL
    #   [:ITEMSYMBOL, qty]                -> gives 'qty' copies
    #   [:ITEMSYMBOL, minQty, maxQty]     -> gives random quantity in range
    # Example customisation:
    #   [:RARECANDY,2,5]   # 2 to 5 Rare Candies
    #   [:RARECANDY,3]     # Exactly 3 Rare Candies
    # You can include duplicates to weight probability (e.g., repeat an entry)
    PROGRESSION_REWARD_POOL = [
      [:RARECANDY,2,4],
      [:PPUP,1,3],
      [:PPMAX,1,2],
      [:ELIXIR,1,3],
      [:MAXELIXIR,1,2],
      [:ETHER,1,3],
      [:MAXETHER,1,2],
      [:SUPERPOTION,2,7],
      [:SUPERPOTION,2,7],
      [:ABILITYCAPSULE,1],
      :LEFTOVERS,
      :CHOICEBAND, :CHOICESCARF, :CHOICESPECS,
      [:LIFEORB,1],
      [:FOCUSSASH,1],
      [:BIGNUGGET,1,3],
      [:NUGGET,2,4],
      [:NUGGET,2,4],
      [:HYPERPOTION,2,3],
      [:FULLHEAL,2,4],
      [:FUSIONBALL,3,10],
      [:FUSIONBALL,3,10],
      [:ULTRABALL,3,10],
      [:ULTRABALL,3,10],
      :ASSAULTVEST, :WEAKNESSPOLICY,
      [:HEARTSCALE,3,5],
      :MASTERBALL
    ]
    PROGRESSION_MONEY_REWARD = 30000     # Flat money bonus granted with item reward
  end
end

if $DEBUG
  puts "Trainer Control Mod (Extra Pokemon + Level Scaling + Memory System) loaded successfully!"
end

# ============================================================================
# DEBUG HELPER
# ============================================================================
module TrainerControlDebug
  def self.messages_enabled?
    return TrainerControl::Config::DEBUG_MESSAGES
  end
  
  def self.log(msg)
    return unless messages_enabled?
    ModSettingsMenu.debug_log("TrainerControl: #{msg}") if defined?(ModSettingsMenu)
  end
end

# ============================================================================
# LEVEL SCALING SECTION
# ============================================================================
module TrainerLevelScaling
  def self.level_scaling_enabled?
    if defined?(ModSettingsMenu)
      setting = ModSettingsMenu.get(:level_scaling_enabled)
      return setting.nil? ? TrainerControl::Config::LEVEL_SCALING_DEFAULT : setting
    end
    return TrainerControl::Config::LEVEL_SCALING_DEFAULT
  end

  def self.get_level_offset
    if defined?(ModSettingsMenu)
      offset = ModSettingsMenu.get(:trainer_level_offset)
      return offset.nil? ? TrainerControl::Config::DEFAULT_LEVEL_OFFSET : offset
    end
    return TrainerControl::Config::DEFAULT_LEVEL_OFFSET
  end
  
  def self.get_player_highest_level
    return 0 if !$Trainer || !$Trainer.party
    max_level = 0
    $Trainer.party.each do |pkmn|
      next if !pkmn || pkmn.egg?
      max_level = pkmn.level if pkmn.level > max_level
    end
    return max_level
  end
  
  def self.adjust_trainer_levels(trainer)
    begin
      return if !level_scaling_enabled?

      if trainer.is_a?(Array)
        trainer.each { |t| adjust_trainer_levels(t) }
        return
      end

      return if !trainer || !trainer.party || trainer.party.empty?

      player_highest = get_player_highest_level
      return if player_highest == 0

      level_offset = get_level_offset
      trainer_name = trainer.name rescue "Unknown"
      target_level = player_highest + level_offset
      target_level = 1 if target_level < 1

      adjusted_count = 0
      lowest_before = 999
      highest_before = 0

      target_level = player_highest + level_offset
      target_level = 1 if target_level < 1

      trainer.party.each do |pkmn|
        next if !pkmn
        current_level = pkmn.level
        lowest_before = [lowest_before, current_level].min
        highest_before = [highest_before, current_level].max
        next if current_level >= target_level

        new_level = target_level
        new_level = GameData::GrowthRate.max_level if new_level > GameData::GrowthRate.max_level

        begin
          pkmn.level = new_level
        rescue
          # Fallback to EXP assignment if direct level fails
          growth_rate = pkmn.growth_rate
          pkmn.exp = growth_rate.minimum_exp_for_level(new_level)
        end

        pkmn.calc_stats
        adjusted_count += 1
      end

      TrainerControlDebug.log("Level Scaling: #{trainer_name} -> target=#{target_level} | before min=#{lowest_before}, max=#{highest_before} | adjusted=#{adjusted_count}")
      
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("TrainerControl: Adjusted #{adjusted_count} Pokemon levels for #{trainer_name}")
      end
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("TrainerControl: Error adjusting trainer levels: #{e.class} - #{e.message}")
      end
    end
  end
end

module TrainerRematchLevels
  def self.apply_rematch_level_override
    if !Kernel.respond_to?(:getRematchLevel_original)
      Kernel.module_eval do
        if defined?(getRematchLevel)
          alias getRematchLevel_original getRematchLevel
        end
        
        def getRematchLevel(originalLevel, nbRematch)
          expRate = getLevelRate(originalLevel) rescue 3
          levelIncr = 0
          for i in 0..nbRematch
            if i % expRate == 0
              levelIncr += 1
            end
          end
          newLevel = originalLevel + levelIncr
          
          return newLevel < 100 ? newLevel : 100
        end
      end
    end
  end
end

TrainerRematchLevels.apply_rematch_level_override

if defined?(PokemonGlobalMetadata)
  class PokemonGlobalMetadata
    alias rematch_mod_trainer_battlers trainer_battlers if method_defined?(:trainer_battlers)
    def trainer_battlers
      return {}
    end
  end
end

# ============================================================================
# EXTRA POKEMON SECTION
# ============================================================================
module TrainerExtraPokemon
  # Cache for type-filtered Pokemon to improve performance
  @type_cache = {}
  @cache_initialized = false
  @type_cache_built = {}
  # Cache for fusion species grouped by type to speed fusion selection
  @fusion_type_cache = {}
  @fusion_cache_initialized = false

  # Returns the current gym's type id (numeric PBTypes id) if in a gym context,
  # otherwise nil. Prefer direct game variables to ensure availability for all
  # gym trainers, not just leaders. Falls back to getLeaderType if present.
  def self.current_gym_type_id
    begin
      if defined?(VAR_CURRENT_GYM_TYPE) && defined?(VAR_GYM_TYPES_ARRAY) && $game_variables
        idx = $game_variables[VAR_CURRENT_GYM_TYPE] rescue -1
        if idx && idx >= 0
          arr = $game_variables[VAR_GYM_TYPES_ARRAY] rescue nil
          if arr && arr[idx]
            type_id = arr[idx]
            if !type_id.is_a?(Integer)
              begin
                type_id = PBTypes.const_get(type_id.to_s.upcase)
              rescue
              end
            end
            return type_id if type_id.is_a?(Integer)
          end
        end
      end
    rescue
    end
    return (defined?(getLeaderType) ? getLeaderType() : nil)
  end

  def self.held_items_chance
    if defined?(ModSettingsMenu)
      val = ModSettingsMenu.get(:trainer_extra_held_items)
      return [0, 50, 100].include?(val) ? val : 0
    end
    return 0
  end

  def self.no_dupes?
    if defined?(ModSettingsMenu)
      val = ModSettingsMenu.get(:trainer_no_dupes_extras)
      return !!val
    end
    return false
  end

  def self.species_id_number_for(species)
    sd = GameData::Species.try_get(species)
    return sd ? sd.id_number : nil
  end

  def self.party_contains_species?(trainer, species)
    sid = species_id_number_for(species)
    return false if !sid
    return false if !trainer || !trainer.party
    trainer.party.each do |pk|
      next if !pk
      begin
        psid = GameData::Species.get(pk.species).id_number
        return true if psid == sid
      rescue
      end
    end
    return false
  end

  def self.get_random_held_item
    candidate_symbols = [
      :ORANBERRY, :SITRUSBERRY, :LUMBERRY, :CHESTOBERRY, :PECHABERRY,
      :RAWSTBERRY, :CHERIBERRY, :PERSIMBERRY, :FIGYBERRY, :WIKIBERRY,
      :MAGOBERRY, :AGUAVBERRY, :IAPAPABERRY,
      :LEFTOVERS, :BLACKBELT, :CHARCOAL, :MYSTICWATER, :MIRACLESEED,
      :MAGNET, :NEVERMELTICE, :TWISTEDSPOON, :SOFTSAND, :SILVERPOWDER,
      :HARDSTONE, :POISONBARB, :DRAGONFANG, :SHELLBELL
    ]
    10.times do
      sym = candidate_symbols.sample
      item_data = GameData::Item.try_get(sym)
      return item_data.id if item_data
    end
    return nil
  end
  
  def self.initialize_type_cache
    begin
      return if @cache_initialized
      return if !defined?(PBTypes)
      @type_cache = {}
      @type_cache_built = {}
      PBTypes.constants.each do |type_const|
        next if type_const == :QMARKS
        type_id = PBTypes.const_get(type_const) rescue nil
        next if !type_id.is_a?(Integer)
        @type_cache[type_id] = { regular: [], non_legendary: [] }
      @type_cache_built[type_id] = false
    end
    @cache_initialized = true
      
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("TrainerControl: Type cache initialized")
      end
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("TrainerControl: Error initializing type cache: #{e.class} - #{e.message}")
      end
    end
  end

  def self.build_type_pool(type_id)
    initialize_type_cache if !@cache_initialized
    return if !defined?(NB_POKEMON)
    return if !@type_cache.key?(type_id)
    return if @type_cache_built[type_id]
    (1..NB_POKEMON).each do |species_id|
      species_data = GameData::Species.try_get(species_id)
      next if !species_data
      t1 = species_data.type1
      t2 = species_data.type2
      if t1.is_a?(Symbol); t1 = (PBTypes.const_get(t1.to_s.upcase) rescue t1); end
      if t2.is_a?(Symbol); t2 = (PBTypes.const_get(t2.to_s.upcase) rescue t2); end
      is_leg = is_legendary?(species_id)
      if t1 == type_id
        @type_cache[type_id][:regular] << species_id
        @type_cache[type_id][:non_legendary] << species_id if !is_leg
      end
      if t2 == type_id && t2 != t1
        @type_cache[type_id][:regular] << species_id
        @type_cache[type_id][:non_legendary] << species_id if !is_leg
      end
    end
    @type_cache_built[type_id] = true
  end
  
  def self.get_cached_species_of_type(type_id)
    initialize_type_cache if !@cache_initialized
    return nil if !@type_cache[type_id]
    build_type_pool(type_id) if !@type_cache_built[type_id]
    
    pool = @type_cache[type_id][:non_legendary]
    return nil if pool.empty?
    
    return pool.sample
  end

  def self.initialize_fusion_cache
    begin
      return if @fusion_cache_initialized
      return if !defined?(PBTypes)
      # Initialize empty arrays per type; populate on-demand per type later
      @fusion_type_cache = {}
      PBTypes.constants.each do |type_const|
        next if type_const == :QMARKS
        type_id = PBTypes.const_get(type_const) rescue nil
        next if !type_id.is_a?(Integer)
      @fusion_type_cache[type_id] = []
    end
    @fusion_cache_initialized = true
      
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("TrainerControl: Fusion cache initialized")
      end
    rescue => e
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:debug_log)
        ModSettingsMenu.debug_log("TrainerControl: Error initializing fusion cache: #{e.class} - #{e.message}")
      end
    end
  end

  def self.populate_fusion_cache_for(type_id, min_entries = 24, max_tries = 800)
    initialize_fusion_cache if !@fusion_cache_initialized
    return if !defined?(NB_POKEMON)
    pool = @fusion_type_cache[type_id]
    return if !pool
    tries = 0
    while pool.length < min_entries && tries < max_tries
      head_id = rand(1..NB_POKEMON)
      body_id = rand(1..NB_POKEMON)
      fusion_id = (body_id * NB_POKEMON) + head_id
      species_data = GameData::Species.try_get(fusion_id)
      if species_data && !is_legendary?(fusion_id)
        t1 = species_data.type1
        t1 = PBTypes.const_get(t1.to_s.upcase) rescue t1 if t1.is_a?(Symbol)
        t2 = species_data.type2
        t2 = PBTypes.const_get(t2.to_s.upcase) rescue t2 if t2.is_a?(Symbol)
        if t1 == type_id || t2 == type_id
          pool << fusion_id
        end
      end
      tries += 1
    end
  end

  def self.get_cached_fusion_of_type(type_id)
    initialize_fusion_cache if !@fusion_cache_initialized
    pool = @fusion_type_cache[type_id]
    if pool && pool.empty?
      populate_fusion_cache_for(type_id)
    end
    return nil if !pool || pool.empty?
    return pool.sample
  end
  

      def self.get_random_species_of_type(type_id)
        return nil if !defined?(NB_POKEMON)
        attempts = 0
        max_attempts = 50
        while attempts < max_attempts
          candidate = get_random_pokemon
          if species_matches_type?(candidate, type_id) && !is_legendary?(candidate)
            return candidate
          end
          attempts += 1
        end
        return nil
      end
  def self.get_random_fusion_of_type(type_id)
    cached = get_cached_fusion_of_type(type_id)
    return cached if cached
    return nil if !defined?(NB_POKEMON)
    max_tries = 50
    tries = 0
    while tries < max_tries
      head_id = rand(1..NB_POKEMON)
      body_id = rand(1..NB_POKEMON)
      fusion_id = (body_id * NB_POKEMON) + head_id
      species_data = GameData::Species.try_get(fusion_id)
      if species_data && !is_legendary?(fusion_id)
        t1 = species_data.type1
        t1 = PBTypes.const_get(t1.to_s.upcase) rescue t1 if t1.is_a?(Symbol)
        t2 = species_data.type2
        t2 = PBTypes.const_get(t2.to_s.upcase) rescue t2 if t2.is_a?(Symbol)
        return fusion_id if t1 == type_id || t2 == type_id
      end
      tries += 1
    end
    return nil
  end
  
  # Helper: does given species (regular or fusion id) have the given numeric type id?
  def self.species_matches_type?(species_id, type_id)
    species_data = GameData::Species.try_get(species_id)
    return false if !species_data
    t1 = species_data.type1
    t2 = species_data.type2
    # Normalize symbols to numeric if possible
    if t1.is_a?(Symbol)
      begin; t1 = PBTypes.const_get(t1.to_s.upcase); rescue; end
    end
    if t2.is_a?(Symbol)
      begin; t2 = PBTypes.const_get(t2.to_s.upcase); rescue; end
    end
    return (t1 == type_id || t2 == type_id)
  end
  
  # Check if species is legendary
  def self.is_legendary?(species_id)
    return false if !defined?(LEGENDARIES_LIST)
    species_data = GameData::Species.try_get(species_id)
    return false if !species_data
    species_symbol = species_data.id
    return true if LEGENDARIES_LIST.include?(species_symbol)
    begin
      if defined?(NB_POKEMON)
        numeric_id = species_data.id_number
        if numeric_id && numeric_id > NB_POKEMON
          head_id = numeric_id % NB_POKEMON
          head_id = NB_POKEMON if head_id == 0
          body_id = (numeric_id - head_id) / NB_POKEMON
          head_sym = GameData::Species.get(head_id).id rescue nil
          body_sym = GameData::Species.get(body_id).id rescue nil
          return true if head_sym && LEGENDARIES_LIST.include?(head_sym)
          return true if body_sym && LEGENDARIES_LIST.include?(body_sym)
        end
      end
    rescue
    end
    return false
  end
  
  # Pokemon pools for different trainer types
  TRAINER_POOLS = {
    # Bug trainers
    :BUGCATCHER => [:CATERPIE, :WEEDLE, :KAKUNA, :METAPOD, :BUTTERFREE, :BEEDRILL, :PARAS, :VENONAT, :SCYTHER, :PINSIR],
    :BUGMANIAC => [:SCYTHER, :PINSIR, :HERACROSS, :YANMA, :FORRETRESS, :ARIADOS, :VENOMOTH],
    # Bird trainers
    :BIRDKEEPER => [:PIDGEY, :PIDGEOTTO, :PIDGEOT, :SPEAROW, :FEAROW, :DODUO, :DODRIO, :FARFETCHD],
    # Fighting trainers
    :BLACKBELT => [:MANKEY, :PRIMEAPE, :MACHOP, :MACHOKE, :MACHAMP, :HITMONLEE, :HITMONCHAN, :POLIWRATH],
    :KARATEKA => [:MANKEY, :PRIMEAPE, :MACHOP, :MACHOKE, :HITMONLEE, :HITMONCHAN],
    # Poison trainers
    :POKEMANIAC => [:NIDORANM, :NIDORANF, :NIDORINO, :NIDORINA, :GRIMER, :MUK, :KOFFING, :WEEZING],
    # Psychic trainers
    :PSYCHIC => [:ABRA, :KADABRA, :ALAKAZAM, :DROWZEE, :HYPNO, :EXEGGCUTE, :EXEGGUTOR, :MR_MIME, :JYNX],
    :CHANNELER => [:GASTLY, :HAUNTER, :GENGAR, :MISDREAVUS],
    # Water trainers
    :SWIMMER => [:TENTACOOL, :TENTACRUEL, :GOLDEEN, :SEAKING, :STARYU, :STARMIE, :MAGIKARP, :GYARADOS],
    :SWIMMERF => [:TENTACOOL, :TENTACRUEL, :GOLDEEN, :SEAKING, :STARYU, :STARMIE, :HORSEA, :SEADRA],
    :FISHERMAN => [:MAGIKARP, :GYARADOS, :GOLDEEN, :SEAKING, :POLIWAG, :POLIWHIRL, :TENTACOOL, :KRABBY, :KINGLER],
    # Rock/Ground trainers
    :HIKER => [:GEODUDE, :GRAVELER, :GOLEM, :ONIX, :RHYHORN, :RHYDON, :CUBONE, :MAROWAK],
    :COOLTRAINER => [:SANDSHREW, :SANDSLASH, :DIGLETT, :DUGTRIO],
    # Electric trainers
    :ENGINEER => [:MAGNEMITE, :MAGNETON, :VOLTORB, :ELECTRODE, :PIKACHU, :RAICHU],
    :GUITARIST => [:VOLTORB, :ELECTRODE, :MAGNEMITE, :MAGNETON, :ELECTABUZZ],
    # Fire trainers
    :BURGLAR => [:GROWLITHE, :VULPIX, :PONYTA, :MAGMAR, :FLAREON],
    # Grass trainers
    :PICNICKER => [:ODDISH, :GLOOM, :BELLSPROUT, :WEEPINBELL, :EXEGGCUTE, :TANGELA],
    :BEAUTY => [:ODDISH, :GLOOM, :VILEPLUME, :BELLSPROUT, :WEEPINBELL, :VICTREEBEL],
    # Youngsters/Lasses (common Pokemon)
    :YOUNGSTER => [:RATTATA, :RATICATE, :PIDGEY, :SPEAROW, :EKANS, :SANDSHREW, :NIDORANM, :MANKEY],
    :LASS => [:PIDGEY, :RATTATA, :NIDORANF, :CLEFAIRY, :JIGGLYPUFF, :MEOWTH, :ODDISH, :PIKACHU],
    # Team Rocket
    :TEAMROCKET => [:RATTATA, :RATICATE, :ZUBAT, :GOLBAT, :GRIMER, :MUK, :KOFFING, :WEEZING],
    # Scientists
    :SCIENTIST => [:MAGNEMITE, :MAGNETON, :VOLTORB, :ELECTRODE, :GRIMER, :MUK, :KOFFING, :WEEZING, :PORYGON],
    # Gentleman/Rich trainers
    :GENTLEMAN => [:GROWLITHE, :PONYTA, :PIKACHU, :NIDORANM, :NIDORINO],
    :SUPERNERD => [:MAGNEMITE, :VOLTORB, :KOFFING, :GRIMER, :SLOWPOKE],
    # Gamblers
    :GAMBLER => [:POLIWAG, :HORSEA, :MAGIKARP, :FARFETCHD],
    # Sailors
    :SAILOR => [:MACHOP, :MACHOKE, :POLIWAG, :POLIWHIRL, :TENTACOOL, :SHELLDER],
    # Bikers
    :BIKER => [:KOFFING, :WEEZING, :GRIMER, :MUK, :MAGNEMITE, :VOLTORB],
    # Jugglers
    :JUGGLER => [:DROWZEE, :HYPNO, :KADABRA, :MR_MIME, :VOLTORB, :ELECTRODE],
    # Tamer
    :TAMER => [:SANDSHREW, :ARBOK, :PERSIAN, :PONYTA, :RAPIDASH, :TAUROS],
    # Rocker
    :ROCKER => [:VOLTORB, :ELECTRODE, :MAGNEMITE, :MAGNETON, :ELECTABUZZ],
  }
  
  # Default pool for unknown trainer types
  DEFAULT_POOL = [:RATTATA, :PIDGEY, :SPEAROW, :EKANS, :SANDSHREW, :ZUBAT, :ODDISH, :MEOWTH, :PSYDUCK, :MANKEY, :GEODUDE, :MAGNEMITE, :DODUO, :KRABBY, :VOLTORB, :GOLDEEN]
  
  # Pokemon selection modes
  SELECTION_MODES = {
    0 => "Off",
    1 => "Trainer Pool",
    2 => "Completely Random",
    3 => "Random Fusion"
  }
  
  def self.enabled?
    if defined?(ModSettingsMenu)
      mode = ModSettingsMenu.get(:trainer_extra_pokemon_mode)
      return mode && mode > 0
    end
    return false
  end
  

  def self.selection_mode
    if defined?(ModSettingsMenu)
      mode = ModSettingsMenu.get(:trainer_extra_pokemon_mode)
      return mode || TrainerControl::Config::EXTRA_POKEMON_DEFAULT_MODE
    end
    return TrainerControl::Config::EXTRA_POKEMON_DEFAULT_MODE
  end
  
  def self.pokemon_count
    if defined?(ModSettingsMenu)
      count = ModSettingsMenu.get(:trainer_extra_pokemon_count)
      return count || TrainerControl::Config::EXTRA_POKEMON_DEFAULT_COUNT
    end
    return TrainerControl::Config::EXTRA_POKEMON_DEFAULT_COUNT
  end
  
  def self.gym_leader_full_party?
    if defined?(ModSettingsMenu)
      setting = ModSettingsMenu.get(:gym_leader_full_party)
      return setting.nil? ? TrainerControl::Config::GYM_LEADER_FULL_PARTY_DEFAULT : setting
    end
    return TrainerControl::Config::GYM_LEADER_FULL_PARTY_DEFAULT
  end
  
  def self.is_gym_leader?(trainer)
    return false if !trainer
    trainer_type = trainer.trainer_type
    begin
      tstr = trainer_type.to_s.upcase
    rescue
      tstr = ""
    end
    return false if tstr.empty?

    return (
      tstr.start_with?("LEADER") ||
      tstr.include?("LEADER") ||
      tstr.include?("GYM_LEADER") ||
      tstr.include?("GYMLEADER")
    )
  end
  
  def self.get_average_level(trainer)
    return 5 if !trainer.party || trainer.party.empty?
    total = 0
    count = 0
    trainer.party.each do |pkmn|
      next if !pkmn
      total += pkmn.level
      count += 1
    end
    return count > 0 ? (total / count) : 5
  end
  
  def self.get_lowest_level(trainer)
    return 5 if !trainer.party || trainer.party.empty?
    lowest = 100
    trainer.party.each do |pkmn|
      next if !pkmn
      lowest = pkmn.level if pkmn.level < lowest
    end
    return lowest > 0 ? lowest : 5
  end
  
  def self.get_pokemon_pool(trainer_type)
    pool = TRAINER_POOLS[trainer_type]
    return pool if pool && !pool.empty?
    return DEFAULT_POOL
  end
  
  def self.get_random_pokemon
    # Get random Pokemon from 1 to NB_POKEMON
    if defined?(NB_POKEMON)
      attempts = 0
      while attempts < 30
        random_id = rand(1..NB_POKEMON)
        if !is_legendary?(random_id)
          species_data = GameData::Species.try_get(random_id)
          return species_data.species if species_data
        end
        attempts += 1
      end
    end
    return DEFAULT_POOL.sample
  end
  
  def self.get_random_fusion
    if defined?(NB_POKEMON)
      attempts = 0
      while attempts < 30
        head_id = rand(1..NB_POKEMON)
        body_id = rand(1..NB_POKEMON)
        
        fusion_id = (body_id * NB_POKEMON) + head_id
        
        # Verify the fusion species exists and is not legendary
        if !is_legendary?(fusion_id)
          species_data = GameData::Species.try_get(fusion_id)
          return fusion_id if species_data
        end
        attempts += 1
      end
    end
    return get_random_pokemon
  end
  
  def self.add_extra_pokemon(trainer)
    if trainer.is_a?(Array)
      trainer.each { |t| add_extra_pokemon(t) }
      return
    end
    
    return if !trainer || !trainer.party
    
    # Check if this is a gym leader that should have a full party
    is_gym = is_gym_leader?(trainer)
    force_full_party = is_gym && gym_leader_full_party?
    
    TrainerControlDebug.log("TrainerExtraPokemon: Detected gym leader #{trainer.name}, force_full_party=#{force_full_party}, current party size=#{trainer.party.length}") if is_gym
    
    return if !force_full_party && !enabled?
    
    max_size = TrainerControl::Config::MAX_PARTY_SIZE
    orig_size_var = :@__tc_original_party_size
    added_flag_var = :@__tc_added
    base_size = trainer.instance_variable_get(orig_size_var)
    if base_size.nil?
      base_size = trainer.party.length
      trainer.instance_variable_set(orig_size_var, base_size)
    end

    target_size = if force_full_party
      max_size
    else
      base_size + (pokemon_count || 0)
    end
    target_size = [[target_size, max_size].min, 0].max

    # If current party exceeds target (e.g., previous higher setting), trim extras we added.
    if trainer.party.length > target_size
      to_trim = trainer.party.length - target_size
      # Prefer removing Pokémon previously added by this mod
      idx = trainer.party.length - 1
      while to_trim > 0 && idx >= 0
        pkmn = trainer.party[idx]
        # Never trim counter fusion mons
        is_counter = pkmn && pkmn.instance_variable_get(:@__tc_counter_mon)
        if pkmn && pkmn.instance_variable_get(added_flag_var) && !is_counter
          trainer.party.delete_at(idx)
          to_trim -= 1
        end
        idx -= 1
      end
      # Fallback: if still above target and there are still extras beyond base, pop from end
      while to_trim > 0 && trainer.party.length > base_size
        trainer.party.pop
        to_trim -= 1
      end
    end

    # Number of Pokémon to add now to reach target
    count = target_size - trainer.party.length
    count = 0 if count < 0
    
    TrainerControlDebug.log("TrainerExtraPokemon: Will attempt to add #{count} Pokemon to #{trainer.name}'s party") if is_gym
    
    # Compute base added level once to avoid recalculations
    base_added_level = nil
    if is_gym && force_full_party
      base_added_level = get_lowest_level(trainer) - 2
      base_added_level = 1 if base_added_level < 1
    else
      base_added_level = get_average_level(trainer)
    end

    # Add multiple Pokemon
    count.times do
      # Check if party is already full
      if trainer.party.length >= max_size
        TrainerControlDebug.log("TrainerExtraPokemon: #{trainer.name}'s party is full (#{trainer.party.length}/#{max_size})")
        break
      end
      
      mode = selection_mode
      if force_full_party && (mode.nil? || mode == 0)
        mode = 1  # Prefer Trainer Type Pool for gym leaders
      end
      species = nil
      no_dupes = no_dupes?
      attempts = 0
      begin
        species = nil
        if is_gym
        # Determine gym type (randomized or original) for leaders as well.
        gym_type_id = current_gym_type_id
        force_gym_full = force_full_party
        
        if force_gym_full
          # Always use fusions of the current gym type when forcing full party
          species = gym_type_id ? get_random_fusion_of_type(gym_type_id) : nil
          species = get_random_fusion if species.nil?
        else
          # Gym respects selection mode but must match gym type if known.
          case mode
            when 1 # Trainer Pool filtered by gym type
              if gym_type_id
                # Use cached type-filtered species for better performance
                species = get_cached_species_of_type(gym_type_id)
              else
                pool = get_pokemon_pool(trainer.trainer_type)
                # Filter to exclude legendaries
                pool = pool.select { |sp| !is_legendary?(sp) } if pool
                species = pool && !pool.empty? ? pool.sample : nil
              end
            # Stay unfused for mode 1; fallback to a type-matched non-fusion, then (as a last resort) fusion of type
            species = (gym_type_id ? get_random_species_of_type(gym_type_id) : nil) if species.nil?
            species = (gym_type_id ? get_random_fusion_of_type(gym_type_id) : nil) if species.nil?
          when 2 # Completely Random but enforce type match
            if gym_type_id
              # Use cached type-filtered species for better performance
              species = get_cached_species_of_type(gym_type_id)
            end
            # Stay unfused for mode 2; fallback to a type-matched non-fusion, then fusion of type (keep on-type only)
            species = (gym_type_id ? get_random_species_of_type(gym_type_id) : nil) if species.nil?
            species = (gym_type_id ? get_random_fusion_of_type(gym_type_id) : nil) if species.nil?
          when 3 # Random Fusion with type match
            species = gym_type_id ? get_random_fusion_of_type(gym_type_id) : nil
          else
            # Mode Off: do nothing for gym (no addition)
            next
          end
        end
        else
        # Non-gym trainers follow configured mode directly.
        # If we're inside a gym, align extra Pokémon with the gym's type (randomized or not).
        gym_type_id = current_gym_type_id
        if gym_type_id
          case mode
          when 1 # Trainer Pool, but enforce gym type (unfused)
            species = get_cached_species_of_type(gym_type_id)
            species = get_random_species_of_type(gym_type_id) if species.nil?
            species = get_random_fusion_of_type(gym_type_id) if species.nil?
          when 2 # Completely Random, but enforce gym type (unfused)
            species = get_cached_species_of_type(gym_type_id)
            species = get_random_species_of_type(gym_type_id) if species.nil?
            # Strictly enforce gym type: if no non-fusion found, use a fusion of that type
            species = get_random_fusion_of_type(gym_type_id) if species.nil?
          when 3 # Random Fusion of gym type
            species = get_random_fusion_of_type(gym_type_id)
          else
            return
          end
        else
          # Not in a gym: original behavior
          case mode
          when 1
            pool = get_pokemon_pool(trainer.trainer_type)
            # Filter to exclude legendaries
            pool = pool.select { |sp| !is_legendary?(sp) } if pool
            species = pool && !pool.empty? ? pool.sample : nil
          when 2
            species = get_random_pokemon
          when 3
            species = get_random_fusion
          else
            return
          end
        end
        end
        attempts += 1
      end while no_dupes && !species.nil? && party_contains_species?(trainer, species) && attempts < 30
      
      next if species.nil?

      # Use precomputed level
      level = base_added_level
      
      # Create the new Pokemon
      begin
        new_pokemon = Pokemon.new(species, level, trainer)
        # Assign held item based on setting: Off/50%/100%
        begin
          chance = held_items_chance
          assign = (chance == 100) || (chance == 50 && rand() < 0.5)
          if assign
            held_item = get_random_held_item
            new_pokemon.item = held_item if held_item
          end
        rescue
        end
        # Mark as added by Trainer Control so we can trim safely later if needed
        new_pokemon.instance_variable_set(added_flag_var, true)
        # Mark non-counter extras explicitly (counter mons set elsewhere)
        new_pokemon.instance_variable_set(:@__tc_counter_mon, false)
        
        # Add to party
        trainer.party.push(new_pokemon)
        
        TrainerControlDebug.log("TrainerExtraPokemon: Added #{new_pokemon.name} (Lv.#{level}) to #{trainer.name}'s party")
      rescue => e
        if $DEBUG && TrainerControlDebug.messages_enabled?
          pbMessage("TrainerExtraPokemon Error: #{e.message}")
          pbPrintException(e)
        end
      end
    end
  end
end

# ============================================================================
# TRAINER MEMORY SECTION
# ============================================================================
module TrainerMemory
  TRAINER_MEMORY_VAR = 999
  
  def self.initialize_data
    if defined?($game_variables) && $game_variables
      $game_variables[TRAINER_MEMORY_VAR] ||= {}
    end
  end
  
  def self.get_memory_data
    initialize_data
    return {} if !defined?($game_variables) || !$game_variables
    
    if !$game_variables[TRAINER_MEMORY_VAR].is_a?(Hash)
      $game_variables[TRAINER_MEMORY_VAR] = {}
    end
    
    return $game_variables[TRAINER_MEMORY_VAR]
  end
  
  def self.enabled?
    return true
  end
  
  def self.battle_record_enabled?
    if defined?(ModSettingsMenu)
      setting = ModSettingsMenu.get(:battle_record_enabled)
      return setting.nil? ? TrainerControl::Config::BATTLE_RECORD_DISPLAY_DEFAULT : setting
    end
    return TrainerControl::Config::BATTLE_RECORD_DISPLAY_DEFAULT
  end
  
  def self.adaptation_enabled?
    if defined?(ModSettingsMenu)
      setting = ModSettingsMenu.get(:trainer_adaptation_enabled)
      return setting.nil? ? TrainerControl::Config::TEAM_ADAPTATION_DEFAULT : setting
    end
    return TrainerControl::Config::TEAM_ADAPTATION_DEFAULT
  end
  
  def self.rewards_enabled?
    if defined?(ModSettingsMenu)
      setting = ModSettingsMenu.get(:trainer_rewards_enabled)
      return setting.nil? ? TrainerControl::Config::PROGRESSION_REWARDS_DEFAULT : setting
    end
    return TrainerControl::Config::PROGRESSION_REWARDS_DEFAULT
  end
  
  def self.get_trainer_id(trainer)
    return nil if !trainer
    trainer = trainer[0] if trainer.is_a?(Array)
    return nil if !trainer

    trainer_type = trainer.trainer_type rescue nil
    trainer_name = trainer.name rescue nil
    return nil if !trainer_type || !trainer_name
    
    return "#{trainer_type}_#{trainer_name}"
  end
  
  def self.is_gym_leader?(trainer)
    return TrainerExtraPokemon.is_gym_leader?(trainer) if defined?(TrainerExtraPokemon)
    return false
  end
  
  # Check if AlphaHordes or Raids Alpha mod is loaded
  def self.alpha_mod_loaded?
    # Check for AlphaHordes mod (13a_AlphaHordes.rb)
    return true if defined?(ALPHA_TYPE_MOVES) && defined?(ALPHA_CONFIG)
    # Check for Raids Alpha mod (003_AlphaRaids.rb)
    return true if defined?(@all_moves) && @all_moves.is_a?(Array)
    return false
  end
  
  # Apply Alpha Pokemon modifications to an existing Pokemon
  def self.make_alpha_pokemon(pokemon)
    return if !pokemon
    return if !alpha_mod_loaded?
    
    begin
      # Change owner to bypass level cap (matching both implementations)
      fake_owner = Pokemon::Owner.new(88888, "ALPHA", 2, 0)
      pokemon.owner = fake_owner
      
      # Increase level by 10 (matching AlphaHordes)
      pokemon.level = (pokemon.level + 10).clamp(1, 100)
      
      # Mark as Alpha boss for icon display (for Boss System)
      pokemon.instance_variable_set(:@isBossAlpha, true)
      
      # Add " A" to name for visual identification
      pokemon.name += " A" unless pokemon.name.end_with?(" A")
      
      # Set IVs (AlphaHordes uses 20 for all, Raids uses 2 perfect random IVs)
      # Using AlphaHordes approach for consistency
      pokemon.iv = {
        :HP => 20,
        :ATTACK => 20,
        :DEFENSE => 20,
        :SPEED => 20,
        :SPECIAL_ATTACK => 20,
        :SPECIAL_DEFENSE => 20
      }
      
      # Learn a random type-matching move
      # Try AlphaHordes approach first (ALPHA_TYPE_MOVES)
      if defined?(ALPHA_TYPE_MOVES)
        type_moves = (ALPHA_TYPE_MOVES[pokemon.type1] || []) + (ALPHA_TYPE_MOVES[pokemon.type2] || [])
        type_moves.select! { |move| GameData::Move.exists?(move) && !pokemon.hasMove?(move) }
        if type_moves.length > 0
          new_move = type_moves.sample
          if pokemon.moves.length == 4
            pokemon.moves[0] = Pokemon::Move.new(new_move)
          else
            pokemon.moves.push(Pokemon::Move.new(new_move))
          end
        end
      # Fallback to Raids approach (@all_moves)
      elsif defined?(@all_moves) && @all_moves.is_a?(Array)
        moves = @all_moves.select { |key, _| key == pokemon.type1 && !pokemon.getMoveList.include?(_) }[0, 3]
        moves += @all_moves.select { |key, _| key == pokemon.type2 && !pokemon.getMoveList.include?(_) }[0, 3]
        moves.shuffle!
        if moves.length > 0
          if pokemon.moves.length == 4
            pokemon.moves[0] = Pokemon::Move.new(moves[0][1])
          else
            pokemon.moves.push(Pokemon::Move.new(moves[0][1]))
          end
        end
      end
      
      # Recalculate stats
      pokemon.calc_stats
      
      TrainerControlDebug.log("TrainerMemory: Applied Alpha modifications to #{pokemon.name}")
    rescue => e
      if $DEBUG && TrainerControlDebug.messages_enabled?
        pbMessage("TrainerMemory Error applying Alpha modifications: #{e.message}")
        pbPrintException(e)
      end
    end
  end
  
  def self.get_record(trainer_id)
    return nil if !trainer_id
    
    memory = get_memory_data
    return nil if !memory.is_a?(Hash)
    
    trainer_id = trainer_id.to_s
    
    memory[trainer_id] ||= {
      wins: 0,
      losses: 0,
      player_types_used: {},
      player_strategies: {
        setup_moves: 0,
        status_moves: 0,
        hazards: 0
      },
      last_battle_date: nil,
      reward_given: false,
      counter_pokemon_added: false
    }
    return memory[trainer_id]
  end
  
  def self.record_battle(trainer, player_won)
    TrainerControlDebug.log("TrainerMemory: record_battle called")
    
    return if !enabled?
    return if !trainer
    return if is_gym_leader?(trainer)
    
    trainer_id = get_trainer_id(trainer)
    TrainerControlDebug.log("TrainerMemory: Trainer ID = #{trainer_id}")
    return if !trainer_id
    
    record = get_record(trainer_id)
    TrainerControlDebug.log("TrainerMemory: Got record, is nil? #{record.nil?}")
    return if !record
    
    if player_won
      record[:wins] += 1
    else
      record[:losses] += 1
    end
    
    record[:last_battle_date] = Time.now.to_i
    
    if $DEBUG && TrainerControlDebug.messages_enabled?
      pbMessage("TrainerMemory: Recorded #{player_won ? 'WIN' : 'LOSS'} vs #{trainer_id}")
      pbMessage("TrainerMemory: New record - Wins: #{record[:wins]}, Losses: #{record[:losses]}")
      memory = get_memory_data
      saved_record = memory[trainer_id.to_s]
      if saved_record
        pbMessage("TrainerMemory: Verified save - Wins: #{saved_record[:wins]}, Losses: #{saved_record[:losses]}")
      else
        pbMessage("TrainerMemory: ERROR - Record not found in memory after save!")
      end
    end
    
    if $Trainer && $Trainer.party
      $Trainer.party.each do |pkmn|
        next if !pkmn || pkmn.egg?
        species_data = GameData::Species.try_get(pkmn.species)
        next if !species_data
        
        type1 = species_data.type1
        type2 = species_data.type2
        record[:player_types_used][type1] ||= 0
        record[:player_types_used][type1] += 1
        if type2 && type2 != type1
          record[:player_types_used][type2] ||= 0
          record[:player_types_used][type2] += 1
        end
      end
    end
    
    TrainerControlDebug.log("TrainerMemory: Recorded battle vs #{trainer_id}. Record: #{record[:wins]}W-#{record[:losses]}L")
  end
  
  def self.record_strategy(trainer_id, strategy_type)
    return if !enabled?
    return if !trainer_id
    
    record = get_record(trainer_id)
    case strategy_type
    when :setup
      record[:player_strategies][:setup_moves] += 1
    when :status
      record[:player_strategies][:status_moves] += 1
    when :hazard
      record[:player_strategies][:hazards] += 1
    end
  end
  
  def self.get_player_common_types(trainer_id, limit = 3)
    record = get_record(trainer_id)
    return [] if record[:player_types_used].empty?
    
    sorted_types = record[:player_types_used].sort_by { |type, count| -count }
    return sorted_types.first(limit).map { |type, count| type }
  end
  
  def self.player_uses_setup?(trainer_id)
    record = get_record(trainer_id)
    return record[:player_strategies][:setup_moves] > 5
  end
  
  def self.player_uses_hazards?(trainer_id)
    record = get_record(trainer_id)
    return record[:player_strategies][:hazards] > 3
  end
  
  def self.get_counter_types(type)
    return [] if !defined?(PBTypes)
    
    if type.is_a?(Integer)
      begin
        type = GameData::Type.get(type).id
      rescue
        return []
      end
    end
    
    # Type effectiveness chart (types that are super effective against the given type)
    counters = {
      NORMAL: [:FIGHTING],
      FIRE: [:WATER, :GROUND, :ROCK],
      WATER: [:ELECTRIC, :GRASS],
      ELECTRIC: [:GROUND],
      GRASS: [:FIRE, :ICE, :POISON, :FLYING, :BUG],
      ICE: [:FIRE, :FIGHTING, :ROCK, :STEEL],
      FIGHTING: [:FLYING, :PSYCHIC, :FAIRY],
      POISON: [:GROUND, :PSYCHIC],
      GROUND: [:WATER, :GRASS, :ICE],
      FLYING: [:ELECTRIC, :ICE, :ROCK],
      PSYCHIC: [:BUG, :GHOST, :DARK],
      BUG: [:FIRE, :FLYING, :ROCK],
      ROCK: [:WATER, :GRASS, :FIGHTING, :GROUND, :STEEL],
      GHOST: [:GHOST, :DARK],
      DRAGON: [:ICE, :DRAGON, :FAIRY],
      DARK: [:FIGHTING, :BUG, :FAIRY],
      STEEL: [:FIRE, :FIGHTING, :GROUND],
      FAIRY: [:POISON, :STEEL]
    }
    
    return counters[type] || []
  end
  
  def self.adapt_team(trainer)
    return if !adaptation_enabled?
    return if !trainer
    return if is_gym_leader?(trainer)
    
    trainer_id = get_trainer_id(trainer)
    return if !trainer_id
    
    record = get_record(trainer_id)
    return if !record
    
    TrainerControlDebug.log("TrainerMemory: Checking adaptation for #{trainer_id} - Player wins: #{record[:wins]}, Trainer wins: #{record[:losses]}")
    
    return if record[:wins] == 0
    return if !trainer.party || trainer.party.empty?
    
    TrainerControlDebug.log("TrainerMemory: ADAPTING team for #{trainer_id} (player has beaten them #{record[:wins]} times)!")
    
    
    common_types = get_player_common_types(trainer_id, 2)
    
    if !common_types.empty? && defined?(GameData::Move)
      trainer.party.each do |pkmn|
        next if !pkmn
        
        counter_moves = get_counter_moves_for_types(common_types, pkmn)
        
        if !counter_moves.empty? && pkmn.moves.length > 0
          move_to_replace = rand(pkmn.moves.length)
          new_move = counter_moves.sample
          
          unless pkmn.moves.any? { |m| m && m.id == new_move }
            pkmn.moves[move_to_replace] = Pokemon::Move.new(new_move)
            
            TrainerControlDebug.log("TrainerMemory: Taught #{pkmn.name} the move #{GameData::Move.get(new_move).name}")
          end
        end
      end
    end
    
    if player_uses_setup?(trainer_id)
      add_status_moves(trainer)
    end
    
    if record[:wins] >= 3
      $trainer_control_natures_optimized ||= {}
      unless $trainer_control_natures_optimized[trainer_id]
        optimize_natures(trainer, record)
        $trainer_control_natures_optimized[trainer_id] = true
      end
    end

    # Adapt items once per battle per trainer
    $trainer_control_items_adapted ||= {}
    unless $trainer_control_items_adapted[trainer_id]
      adapt_items(trainer)
      $trainer_control_items_adapted[trainer_id] = true
    end
  end
  
  def self.get_counter_moves_for_types(types, pokemon)
    return [] if !types || types.empty? || !pokemon
    return [] if !defined?(GameData::Move)
    
    counter_moves = []
    
    types.each do |type|
      counter_types = get_counter_types(type)
      
      counter_types.each do |counter_type|
        # Find moves of the counter type that the Pokemon can learn
        GameData::Move.each do |move_data|
          next if move_data.type != counter_type
          next if move_data.base_damage == 0  # Skip status moves
          next if move_data.base_damage < 50  # Lower threshold for more variety (was 60)
          
          # Check if Pokemon can learn this move (simplified check)
          # In a full implementation, you'd check the Pokemon's learnset
          counter_moves << move_data.id
        end
      end
    end
    pool = counter_moves.uniq
    legal_chance = 70
    require_legal = (rand(100) < legal_chance)
    if require_legal
      pool = pool.select { |mid| move_is_legal?(pokemon, mid) }
      pool = counter_moves.uniq if pool.empty?
    end
    return pool.shuffle.first(20)
  end

  def self.move_is_legal?(pokemon, move_id)
    return false if !pokemon || !move_id
    species_id = pokemon.species rescue nil
    data = GameData::Species.try_get(species_id)
    return false if !data
    begin
      if data.moves && data.moves.any? { |entry| entry && entry[1] == move_id && (pokemon.level >= entry[0]) }
        return true
      end
    rescue; end
    begin
      if data.respond_to?(:tm_moves) && data.tm_moves && data.tm_moves.include?(move_id)
        return true
      end
    rescue; end
    begin
      if data.respond_to?(:tutor_moves) && data.tutor_moves && data.tutor_moves.include?(move_id)
        return true
      end
    rescue; end
    return false
  end
  
  def self.add_status_moves(trainer)
    return if !trainer || !trainer.party
    
    status_moves = [
      :TOXIC, :THUNDERWAVE, :WILLOWISP, :TAUNT, :ENCORE,
      :ROAR, :WHIRLWIND, :HAZE, :CLEARSMOG
    ]
    
    hazard_moves = [
      :STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB
    ]
    
    pkmn = trainer.party[0]
    return if !pkmn
    
    available_moves = player_uses_hazards?(get_trainer_id(trainer)) ? 
                     (status_moves + hazard_moves) : status_moves
    
    available_moves.shuffle.each do |move_id|
      move_data = GameData::Move.try_get(move_id)
      next if !move_data
      
      # Check if Pokemon already knows this move
      next if pkmn.moves.any? { |m| m && m.id == move_id }
      
      # Replace last move slot
      if pkmn.moves.length > 0
        pkmn.moves[-1] = Pokemon::Move.new(move_id)
        
        TrainerControlDebug.log("TrainerMemory: Taught #{pkmn.name} #{move_data.name} to counter setup")
        break
      end
    end
  end

  # Optimize Pokemon natures to complement their roles and player's strategy
  def self.optimize_natures(trainer, record)
    return if !trainer || !trainer.party || !record
    # Heuristic thresholds
    wins_threshold = 3
    return if (record[:wins] || 0) < wins_threshold
    wins = record[:wins] || 0
    # Incremental probability ramp for nature optimization
    nature_chance = case wins
    when 3..4 then 30
    when 5..7 then 50
    when 8..11 then 80
    else 100
    end
    hazards_used = record[:player_strategies][:hazards] > 2 rescue false
    setup_used   = record[:player_strategies][:setup_moves] > 3 rescue false
    status_used  = record[:player_strategies][:status_moves] > 3 rescue false

    # Common move role sets
    setup_moves = [:SWORDSDANCE, :DRAGONDANCE, :NASTYPLOT, :CALMMIND, :BULKUP, :QUIVERDANCE, :SHELLSMASH]
    speed_moves = [:AGILITY, :ROCKPOLISH, :AUTOTOMIZE, :TAILWIND]
    priority_moves = [:QUICKATTACK, :EXTREMESPEED, :AQUAJET, :BULLETPUNCH, :ICESHARD, :SUCKERPUNCH, :SHADOWSNEAK, :VACUUMWAVE, :WATERSHURIKEN, :MACHPUNCH]
    hazard_moves = [:STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB]
    status_control = [:THUNDERWAVE, :WILLOWISP, :TOXIC, :TAUNT, :ENCORE, :ROAR, :WHIRLWIND, :HAZE, :CLEARSMOG]

    trainer.party.each do |pkmn|
      next if !pkmn || pkmn.egg?
      begin
        physical_count = 0
        special_count  = 0
        setup_count    = 0
        priority_count = 0
        hazard_count   = 0
        status_count   = 0
        speed_support  = 0

        pkmn.moves.each do |mv|
          next if !mv || !mv.id
          md = GameData::Move.try_get(mv.id)
          next if !md
          if md.base_damage && md.base_damage > 0
            if md.category == :physical
              physical_count += 1
            elsif md.category == :special
              special_count += 1
            end
          else
            # Non-damaging move
          end
          setup_count    += 1 if setup_moves.include?(md.id)
          priority_count += 1 if priority_moves.include?(md.id)
          hazard_count   += 1 if hazard_moves.include?(md.id)
          status_count   += 1 if status_control.include?(md.id)
          speed_support  += 1 if speed_moves.include?(md.id)
        end

        offensive_bias = (physical_count - special_count)
        role = :mixed
        role = :physical if offensive_bias > 1
        role = :special  if offensive_bias < -1
        defensive_role = (hazard_count + status_count) >= 2
        speed_role = (priority_count + speed_support) > 0 || setup_count > 0

        desired_nature = pkmn.nature

        if defensive_role
          # Defensive orientation
            if role == :physical
              # Boost Defense drop SpAtk (Impish) or SpDef (Adamant?) -> choose Impish
              desired_nature = :IMPISH
            elsif role == :special
              desired_nature = :BOLD  # Boost Defense drop Attack
            else
              # Balanced defense against status/hazards -> Careful (boost SpDef drop SpAtk) or Calm
              desired_nature = (status_used ? :CALM : :CAREFUL)
            end
        else
          # Offensive orientation
          if role == :physical
            desired_nature = speed_role ? :JOLLY : :ADAMANT
          elsif role == :special
            desired_nature = speed_role ? :TIMID : :MODEST
          else
            # Mixed attackers: choose Naive/Rash depending on speed focus
            desired_nature = speed_role ? :NAIVE : :HARDY
          end
        end

        # Late-game refinement: after many wins escalate to more aggressive natures
        if (record[:wins] || 0) >= 8 && !defensive_role
          if role == :physical && desired_nature == :ADAMANT && speed_role
            desired_nature = :JOLLY
          elsif role == :special && desired_nature == :MODEST && speed_role
            desired_nature = :TIMID
          end
        end

        # Probability gate per Pokémon to avoid uniform sudden optimization
        next if rand(100) >= nature_chance
        # Skip if unchanged
        next if desired_nature == pkmn.nature

        # Apply nature
        pkmn.nature = desired_nature
        pkmn.calc_stats rescue nil
        TrainerControlDebug.log("TrainerMemory: Optimized #{pkmn.name}'s nature to #{desired_nature} (role=#{role}, def=#{defensive_role}, speed=#{speed_role})")
      rescue
      end
    end
  end

  # Optimize held items based on player's strategy
  def self.adapt_items(trainer)
    return if !trainer || !trainer.party
    trainer_id = get_trainer_id(trainer)
    return if !trainer_id
    record = get_record(trainer_id)
    return if !record

    setup_used = record[:player_strategies][:setup_moves] > 3 rescue false
    hazards_used = record[:player_strategies][:hazards] > 2 rescue false
    status_used = record[:player_strategies][:status_moves] > 3 rescue false

    # 20% chance to adapt items this battle to keep it subtle
    return if rand(100) >= 20

    # Expanded heuristics:
    # - Offensive pressure: Choice items, Life Orb, Expert Belt, Muscle Band, Wise Glasses
    # - Survival vs burst: Focus Sash, Focus Band
    # - Attrition/sustain: Leftovers, Black Sludge
    # - Anti-status/hazards utility: Heavy-Duty Boots, Lum Berry
    # Plus: healing berries added across pools (Sitrus, Oran, pinch berries)
    offensive_items = [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :LIFEORB, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES]
    defensive_items = [:FOCUSSASH, :FOCUSBAND, :LEFTOVERS, :BLACKSLUDGE]
    utility_items   = [:HEAVYDUTYBOOTS, :LUMBERRY]

    # Healing berries
    berries_mid = [:ORANBERRY, :SITRUSBERRY]
    berries_pinch = [:FIGYBERRY, :IAPAPABERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY]

    # Merge healing berries into each strategic pool
    offensive_pool = offensive_items + berries_pinch + [:SITRUSBERRY]
    defensive_pool = defensive_items + berries_mid + berries_pinch
    hazard_pool    = utility_items + [:LEFTOVERS] + [:SITRUSBERRY] + berries_pinch
    setup_pool     = [:LIFEORB, :FOCUSSASH, :LEFTOVERS] + [:SITRUSBERRY] + berries_pinch
    priority_pool  = [:LIFEORB, :CHOICEBAND, :FOCUSSASH] + [:SITRUSBERRY, :ORANBERRY]

    trainer.party.each do |pkmn|
      next if !pkmn || pkmn.egg?
      # Skip if already has a valuable item
      cur_item = pkmn.item&.id rescue pkmn.item
      if cur_item
        if $DEBUG && TrainerControlDebug.messages_enabled?
          begin
            item_name = GameData::Item.get(cur_item).name
            pbMessage("TrainerMemory: Skipping item adapt for #{pkmn.name}, already holds #{item_name}")
          rescue
            pbMessage("TrainerMemory: Skipping item adapt for #{pkmn.name}, already holds an item")
          end
        end
        next
      end
      chosen = nil
      # Prefer Leftovers if hazards/status prevalent
      if hazards_used || status_used
        # If Poison-type, Black Sludge is equivalent
        if GameData::Item.try_get(:BLACKSLUDGE) && pkmn.types.any? { |t| (t.is_a?(Symbol) ? (PBTypes.const_get(t.to_s.upcase) rescue nil) : t) == (PBTypes.const_get(:POISON) rescue nil) }
          chosen = :BLACKSLUDGE
        end
        chosen = :LEFTOVERS if chosen.nil? && GameData::Item.try_get(:LEFTOVERS)
        # Boots help vs hazards too
        chosen = :HEAVYDUTYBOOTS if chosen.nil? && GameData::Item.try_get(:HEAVYDUTYBOOTS)
        # Add a mid-fight heal as alternative
        chosen = :SITRUSBERRY if chosen.nil? && GameData::Item.try_get(:SITRUSBERRY)
      end
      # If player sets up often, give Choice item to pressure
      if chosen.nil? && setup_used
        ([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES] + [:SITRUSBERRY] + berries_pinch).shuffle.each do |it|
          if GameData::Item.try_get(it)
            chosen = it
            break
          end
        end
      end
      # Fallbacks
      if chosen.nil?
        ([:LIFEORB, :FOCUSSASH, :FOCUSBAND, :LUMBERRY] + berries_mid + berries_pinch).shuffle.each do |it|
          chosen = it if GameData::Item.try_get(it)
          break if chosen
        end
      end
      # Final fallback: type gem only after 5+ wins, 20% chance
      if chosen.nil?
        if (record[:wins] || 0) >= 5 && rand(100) < 20
          # Map types to gem items (Gen 5 gems); use first matching type found
          gem_map = {
            (PBTypes.const_get(:NORMAL)  rescue :NORMAL)  => :NORMALGEM,
            (PBTypes.const_get(:FIRE)    rescue :FIRE)    => :FIREGEM,
            (PBTypes.const_get(:WATER)   rescue :WATER)   => :WATERGEM,
            (PBTypes.const_get(:ELECTRIC)rescue :ELECTRIC)=> :ELECTRICGEM,
            (PBTypes.const_get(:GRASS)   rescue :GRASS)   => :GRASSGEM,
            (PBTypes.const_get(:ICE)     rescue :ICE)     => :ICEGEM,
            (PBTypes.const_get(:FIGHTING)rescue :FIGHTING)=> :FIGHTINGGEM,
            (PBTypes.const_get(:POISON)  rescue :POISON)  => :POISONGEM,
            (PBTypes.const_get(:GROUND)  rescue :GROUND)  => :GROUNDGEM,
            (PBTypes.const_get(:FLYING)  rescue :FLYING)  => :FLYINGGEM,
            (PBTypes.const_get(:PSYCHIC) rescue :PSYCHIC) => :PSYCHICGEM,
            (PBTypes.const_get(:BUG)     rescue :BUG)     => :BUGGEM,
            (PBTypes.const_get(:ROCK)    rescue :ROCK)    => :ROCKGEM,
            (PBTypes.const_get(:GHOST)   rescue :GHOST)   => :GHOSTGEM,
            (PBTypes.const_get(:DRAGON)  rescue :DRAGON)  => :DRAGONGEM,
            (PBTypes.const_get(:DARK)    rescue :DARK)    => :DARKGEM,
            (PBTypes.const_get(:STEEL)   rescue :STEEL)   => :STEELGEM,
            (PBTypes.const_get(:FAIRY)   rescue :FAIRY)   => :FAIRYGEM
          }
          begin
            # Normalize pokemon types to numeric ids for lookup
            p_types = pkmn.types.map { |t| t.is_a?(Symbol) ? (PBTypes.const_get(t.to_s.upcase) rescue t) : t } rescue []
            p_types.each do |tid|
              gem_sym = gem_map[tid]
              if gem_sym && GameData::Item.try_get(gem_sym)
                chosen = gem_sym
                break
              end
            end
          rescue
          end
        end
      end
      next if chosen.nil?
      begin
        pkmn.item = GameData::Item.get(chosen)
        TrainerControlDebug.log("TrainerMemory: Gave #{pkmn.name} #{GameData::Item.get(chosen).name}")
      rescue
      end
    end
  end
  
  # Helper: adapt item for a single newly added counter mon (mirrors adapt_items logic)
  def self.adapt_item_for_pokemon(pkmn, record)
    return if !pkmn || !record
    # 20% chance gate
    roll = rand(100)
    if roll >= 20
      TrainerControlDebug.log("TrainerMemory: Item adapt skip for #{pkmn.name} (roll=#{roll})")
      return
    end
    setup_used   = record[:player_strategies][:setup_moves] > 3 rescue false
    hazards_used = record[:player_strategies][:hazards] > 2 rescue false
    status_used  = record[:player_strategies][:status_moves] > 3 rescue false

    offensive_items = [:CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :LIFEORB, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES]
    defensive_items = [:FOCUSSASH, :FOCUSBAND, :LEFTOVERS, :BLACKSLUDGE]
    utility_items   = [:HEAVYDUTYBOOTS, :LUMBERRY]
    berries_mid   = [:ORANBERRY, :SITRUSBERRY]
    berries_pinch = [:FIGYBERRY, :IAPAPABERRY, :WIKIBERRY, :MAGOBERRY, :AGUAVBERRY]

    cur_item = pkmn.item&.id rescue pkmn.item
    if cur_item
      TrainerControlDebug.log("TrainerMemory: #{pkmn.name} already holds an item (#{GameData::Item.get(cur_item).name rescue cur_item}), skip adapt")
      return
    end

    chosen = nil
    if hazards_used || status_used
      if GameData::Item.try_get(:BLACKSLUDGE) && pkmn.types.any? { |t| (t.is_a?(Symbol) ? (PBTypes.const_get(t.to_s.upcase) rescue nil) : t) == (PBTypes.const_get(:POISON) rescue nil) }
        chosen = :BLACKSLUDGE
      end
      chosen = :LEFTOVERS if chosen.nil? && GameData::Item.try_get(:LEFTOVERS)
      chosen = :HEAVYDUTYBOOTS if chosen.nil? && GameData::Item.try_get(:HEAVYDUTYBOOTS)
      chosen = :SITRUSBERRY if chosen.nil? && GameData::Item.try_get(:SITRUSBERRY)
    end
    if chosen.nil? && setup_used
      ([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF, :EXPERTBELT, :MUSCLEBAND, :WISEGLASSES] + [:SITRUSBERRY] + berries_pinch).shuffle.each do |it|
        if GameData::Item.try_get(it); chosen = it; break; end
      end
    end
    if chosen.nil?
      ([:LIFEORB, :FOCUSSASH, :FOCUSBAND, :LUMBERRY] + berries_mid + berries_pinch).shuffle.each do |it|
        if GameData::Item.try_get(it); chosen = it; break; end
      end
    end
    if chosen.nil?
      if (record[:wins] || 0) >= 5 && rand(100) < 20
        gem_map = {
          (PBTypes.const_get(:NORMAL)  rescue :NORMAL)  => :NORMALGEM,
          (PBTypes.const_get(:FIRE)    rescue :FIRE)    => :FIREGEM,
          (PBTypes.const_get(:WATER)   rescue :WATER)   => :WATERGEM,
          (PBTypes.const_get(:ELECTRIC)rescue :ELECTRIC)=> :ELECTRICGEM,
          (PBTypes.const_get(:GRASS)   rescue :GRASS)   => :GRASSGEM,
          (PBTypes.const_get(:ICE)     rescue :ICE)     => :ICEGEM,
          (PBTypes.const_get(:FIGHTING)rescue :FIGHTING)=> :FIGHTINGGEM,
          (PBTypes.const_get(:POISON)  rescue :POISON)  => :POISONGEM,
          (PBTypes.const_get(:GROUND)  rescue :GROUND)  => :GROUNDGEM,
          (PBTypes.const_get(:FLYING)  rescue :FLYING)  => :FLYINGGEM,
          (PBTypes.const_get(:PSYCHIC) rescue :PSYCHIC) => :PSYCHICGEM,
          (PBTypes.const_get(:BUG)     rescue :BUG)     => :BUGGEM,
          (PBTypes.const_get(:ROCK)    rescue :ROCK)    => :ROCKGEM,
          (PBTypes.const_get(:GHOST)   rescue :GHOST)   => :GHOSTGEM,
          (PBTypes.const_get(:DRAGON)  rescue :DRAGON)  => :DRAGONGEM,
          (PBTypes.const_get(:DARK)    rescue :DARK)    => :DARKGEM,
          (PBTypes.const_get(:STEEL)   rescue :STEEL)   => :STEELGEM,
          (PBTypes.const_get(:FAIRY)   rescue :FAIRY)   => :FAIRYGEM
        }
        begin
          p_types = pkmn.types.map { |t| t.is_a?(Symbol) ? (PBTypes.const_get(t.to_s.upcase) rescue t) : t } rescue []
          p_types.each do |tid|
            gem_sym = gem_map[tid]
            if gem_sym && GameData::Item.try_get(gem_sym)
              chosen = gem_sym
              break
            end
          end
        rescue; end
      end
    end
    return if chosen.nil?
    begin
      pkmn.item = GameData::Item.get(chosen)
      TrainerControlDebug.log("TrainerMemory: Counter mon #{pkmn.name} assigned item #{GameData::Item.get(chosen).name}")
    rescue
      TrainerControlDebug.log("TrainerMemory: Failed to assign item #{chosen} to #{pkmn.name}")
    end
  end

  # Helper: optimize nature for a single newly added counter mon (mirrors optimize_natures logic)
  def self.optimize_nature_for_pokemon(pkmn, record)
    return if !pkmn || !record
    wins = record[:wins] || 0
    return if wins < 3
    nature_chance = case wins
    when 3..4 then 30
    when 5..7 then 50
    when 8..11 then 80
    else 100
    end
    nroll = rand(100)
    if nroll >= nature_chance
      TrainerControlDebug.log("TrainerMemory: Nature adapt skip for #{pkmn.name} (wins=#{wins}, chance=#{nature_chance}%, roll=#{nroll})")
      return
    end
    setup_moves = [:SWORDSDANCE, :DRAGONDANCE, :NASTYPLOT, :CALMMIND, :BULKUP, :QUIVERDANCE, :SHELLSMASH]
    speed_moves = [:AGILITY, :ROCKPOLISH, :AUTOTOMIZE, :TAILWIND]
    priority_moves = [:QUICKATTACK, :EXTREMESPEED, :AQUAJET, :BULLETPUNCH, :ICESHARD, :SUCKERPUNCH, :SHADOWSNEAK, :VACUUMWAVE, :WATERSHURIKEN, :MACHPUNCH]
    hazard_moves = [:STEALTHROCK, :SPIKES, :TOXICSPIKES, :STICKYWEB]
    status_control = [:THUNDERWAVE, :WILLOWISP, :TOXIC, :TAUNT, :ENCORE, :ROAR, :WHIRLWIND, :HAZE, :CLEARSMOG]
    hazards_used = record[:player_strategies][:hazards] > 2 rescue false
    status_used  = record[:player_strategies][:status_moves] > 3 rescue false

    begin
      physical_count = 0; special_count = 0; setup_count = 0; priority_count = 0; hazard_count = 0; status_count = 0; speed_support = 0
      pkmn.moves.each do |mv|
        next if !mv || !mv.id
        md = GameData::Move.try_get(mv.id); next if !md
        if md.base_damage && md.base_damage > 0
          physical_count += 1 if md.category == :physical
          special_count  += 1 if md.category == :special
        end
        setup_count    += 1 if setup_moves.include?(md.id)
        priority_count += 1 if priority_moves.include?(md.id)
        hazard_count   += 1 if hazard_moves.include?(md.id)
        status_count   += 1 if status_control.include?(md.id)
        speed_support  += 1 if speed_moves.include?(md.id)
      end
      offensive_bias = (physical_count - special_count)
      role = :mixed; role = :physical if offensive_bias > 1; role = :special if offensive_bias < -1
      defensive_role = (hazard_count + status_count) >= 2
      speed_role = (priority_count + speed_support) > 0 || setup_count > 0
      desired_nature = pkmn.nature
      if defensive_role
        desired_nature = case role
        when :physical then :IMPISH
        when :special  then :BOLD
        else (status_used ? :CALM : :CAREFUL)
        end
      else
        desired_nature = case role
        when :physical then (speed_role ? :JOLLY : :ADAMANT)
        when :special  then (speed_role ? :TIMID : :MODEST)
        else (speed_role ? :NAIVE : :HARDY)
        end
      end
      if wins >= 8 && !defensive_role
        if role == :physical && desired_nature == :ADAMANT && speed_role; desired_nature = :JOLLY; end
        if role == :special && desired_nature == :MODEST && speed_role; desired_nature = :TIMID; end
      end
      if desired_nature == pkmn.nature
        TrainerControlDebug.log("TrainerMemory: Nature unchanged for #{pkmn.name} (#{desired_nature})")
        return
      end
      pkmn.nature = desired_nature
      pkmn.calc_stats rescue nil
      TrainerControlDebug.log("TrainerMemory: Counter mon #{pkmn.name} nature set to #{desired_nature}")
    rescue; end
  end

  # Add a counter Pokemon to trainer's team based on player patterns
  def self.add_counter_pokemon(trainer, trainer_id)
    if $DEBUG && TrainerControlDebug.messages_enabled?
      pbMessage("TrainerMemory: add_counter_pokemon called for #{trainer_id}")
      pbMessage("TrainerMemory: Trainer party size: #{trainer.party.length}/#{TrainerControl::Config::MAX_PARTY_SIZE}")
    end
    
    if !trainer || !trainer.party
      TrainerControlDebug.log("TrainerMemory: EARLY RETURN - No trainer or party")
      return
    end
    
    if trainer.party.length >= TrainerControl::Config::MAX_PARTY_SIZE
      TrainerControlDebug.log("TrainerMemory: EARLY RETURN - Party already full (#{trainer.party.length}/#{TrainerControl::Config::MAX_PARTY_SIZE})")
      return
    end
    
    # Get player's most used types
    common_types = get_player_common_types(trainer_id, 2)
    TrainerControlDebug.log("TrainerMemory: Player's common types: #{common_types.inspect}")
    
    if common_types.empty?
      TrainerControlDebug.log("TrainerMemory: EARLY RETURN - No common types found")
      return
    end
    
    # Get counter types for player's common types
    counter_types = []
    common_types.each do |type|
      counter_types.concat(get_counter_types(type))
    end
    counter_types.uniq!
    
    if counter_types.empty?
      TrainerControlDebug.log("TrainerMemory: EARLY RETURN - No counter types found")
      return
    end
    
    TrainerControlDebug.log("TrainerMemory: Counter types: #{counter_types.inspect}")
    
    # Select a random counter type
    selected_counter_type = counter_types.sample
    
    TrainerControlDebug.log("TrainerMemory: Selected counter type (before conversion): #{selected_counter_type.inspect}")
    
    # Convert symbol to numeric type ID if needed
    if selected_counter_type.is_a?(Symbol)
      begin
        # Use GameData::Type instead of PBTypes for modern Pokemon Essentials
        type_data = GameData::Type.get(selected_counter_type)
        selected_counter_type = type_data.id
        TrainerControlDebug.log("TrainerMemory: Converted to type ID: #{selected_counter_type}")
      rescue => e
        TrainerControlDebug.log("TrainerMemory: EARLY RETURN - Type conversion failed: #{e.message}")
        return
      end
    end
    
    if $DEBUG && TrainerControlDebug.messages_enabled?
      type_name = GameData::Type.get(selected_counter_type).name rescue selected_counter_type
      pbMessage("TrainerMemory: Adding counter Pokemon of type #{type_name} to #{trainer_id}'s team")
    end
    
    # Determine what kind of Pokemon to add based on trainer's existing team
    species = nil
    attempts = 0
    max_attempts = 30
    
    # Try to find a fusion Pokemon of the counter type
    while attempts < max_attempts && species.nil?
      if defined?(TrainerExtraPokemon)
        # Use fusion of the counter type
        species = TrainerExtraPokemon.get_random_fusion_of_type(selected_counter_type)
        
        # Fallback to cached fusion if primary search fails
        if species.nil?
          species = TrainerExtraPokemon.get_cached_fusion_of_type(selected_counter_type)
        end
        
        # Last resort: any fusion, then regular species
        if species.nil?
          species = TrainerExtraPokemon.get_random_fusion
        end
        if species.nil?
          species = TrainerExtraPokemon.get_cached_species_of_type(selected_counter_type)
        end
      else
        # Fallback: try to create a fusion of the counter type
        if defined?(NB_POKEMON)
          head_id = rand(1..NB_POKEMON)
          body_id = rand(1..NB_POKEMON)
          fusion_id = (body_id * NB_POKEMON) + head_id
          species_data = GameData::Species.try_get(fusion_id)
          if species_data
            t1 = species_data.type1
            t2 = species_data.type2
            # Normalize to numeric
            if t1.is_a?(Symbol)
              begin; t1 = PBTypes.const_get(t1.to_s.upcase); rescue; end
            end
            if t2.is_a?(Symbol)
              begin; t2 = PBTypes.const_get(t2.to_s.upcase); rescue; end
            end
            if t1 == selected_counter_type || t2 == selected_counter_type
              species = fusion_id
            end
          end
        end
      end
      attempts += 1
    end
    
    TrainerControlDebug.log("TrainerMemory: After species search - species: #{species.inspect}, attempts: #{attempts}")
    
    if species.nil?
      TrainerControlDebug.log("TrainerMemory: EARLY RETURN - Could not find species after #{max_attempts} attempts")
      return
    end
    
    if $DEBUG && TrainerControlDebug.messages_enabled?
      species_name = GameData::Species.get(species).name rescue species
      pbMessage("TrainerMemory: Selected species: #{species_name}")
    end
    
    # Calculate level based on trainer's average
    level = if defined?(TrainerExtraPokemon)
      TrainerExtraPokemon.get_average_level(trainer)
    else
      trainer.party.map { |p| p.level }.sum / trainer.party.length rescue 20
    end
    
    TrainerControlDebug.log("TrainerMemory: Creating Pokemon at level #{level}")
    
    # Create the new Pokemon
    begin
      TrainerControlDebug.log("TrainerMemory: About to call Pokemon.new(#{species}, #{level}, trainer)")
      
      new_pokemon = Pokemon.new(species, level, trainer)
      
      # Give it a held item based on settings
      if defined?(TrainerExtraPokemon)
        chance = TrainerExtraPokemon.held_items_chance
        assign = (chance == 100) || (chance == 50 && rand() < 0.5)
        if assign
          held_item = TrainerExtraPokemon.get_random_held_item
          new_pokemon.item = held_item if held_item
        end
      end
      
      # Add moves that counter player's types
      add_counter_moves_to_pokemon(new_pokemon, common_types)
      
      # Mark this Pokemon as added and as a counter fusion (protected from trimming)
      new_pokemon.instance_variable_set(:@__tc_added, true)
      new_pokemon.instance_variable_set(:@__tc_counter_mon, true)
      
      # Chance to make this counter Pokemon an Alpha (if AlphaHordes/Raids mod is loaded)
      if alpha_mod_loaded? && rand(100) < TrainerControl::Config::ALPHA_COUNTER_POKEMON_CHANCE
        TrainerControlDebug.log("TrainerMemory: Rolling for Alpha counter Pokemon (#{TrainerControl::Config::ALPHA_COUNTER_POKEMON_CHANCE}% chance) - SUCCESS!")
        make_alpha_pokemon(new_pokemon)
        
        if $DEBUG && TrainerControlDebug.messages_enabled?
          pbMessage("TrainerMemory: Counter Pokemon became an ALPHA! #{new_pokemon.name} (Lv.#{new_pokemon.level})")
        end
      end

      # Per-Pokémon immediate adaptation (in case global adaptation already ran earlier)
      begin
        record = get_record(trainer_id)
        adapt_item_for_pokemon(new_pokemon, record) if record
        optimize_nature_for_pokemon(new_pokemon, record) if record
      rescue; end
      
      # Add to trainer's party
      trainer.party.push(new_pokemon)
      
      if $DEBUG && TrainerControlDebug.messages_enabled?
        pbMessage("TrainerMemory: Successfully added #{new_pokemon.name} (Lv.#{level}) to counter player's #{common_types.map { |t| GameData::Type.get(t).name rescue t }.join(', ')} types")
        pbMessage("TrainerMemory: Trainer party size is now: #{trainer.party.length}")
        pbMessage("TrainerMemory: Party: #{trainer.party.map { |p| p.name }.join(', ')}")
      end
    rescue => e
      if $DEBUG && TrainerControlDebug.messages_enabled?
        pbMessage("TrainerMemory Error adding counter Pokemon: #{e.message}")
        pbPrintException(e)
      end
    end
  end
  
  # Add counter moves to a Pokemon based on player's common types
  def self.add_counter_moves_to_pokemon(pokemon, player_types)
    return if !pokemon || !player_types || player_types.empty?
    return if !defined?(GameData::Move)
    
    counter_moves = get_counter_moves_for_types(player_types, pokemon)
    return if counter_moves.empty?
    
    # Replace moves with counter moves (prioritize replacing weaker moves)
    moves_to_add = [counter_moves.length, 2].min  # Add up to 2 counter moves
    
    moves_to_add.times do |i|
      break if i >= pokemon.moves.length
      break if i >= counter_moves.length
      
      move_id = counter_moves[i]
      # Don't replace if already knows this move
      unless pokemon.moves.any? { |m| m && m.id == move_id }
        pokemon.moves[i] = Pokemon::Move.new(move_id)
      end
    end
  end
  
  # Check for progression reward
  def self.check_progression_reward(trainer)
    return if !rewards_enabled?
    return if !trainer
    return if is_gym_leader?(trainer)
    
    trainer_id = get_trainer_id(trainer)
    return if !trainer_id
    
    record = get_record(trainer_id)
    return if !record
    
    TrainerControlDebug.log("TrainerMemory: Checking reward eligibility - Wins: #{record[:wins]}/#{TrainerControl::Config::WINS_FOR_REWARD}, Already given: #{record[:reward_given]}")
    
    # Check if eligible for reward
    if record[:wins] >= TrainerControl::Config::WINS_FOR_REWARD && !record[:reward_given]
      TrainerControlDebug.log("TrainerMemory: Player eligible for progression reward!")
      give_progression_reward(trainer_id)
      record[:reward_given] = true
    end
  end
  
  # Give progression reward to player
  def self.give_progression_reward(trainer_id)
    pool = TrainerControl::Config::PROGRESSION_REWARD_POOL
    return if !pool || pool.empty?

    entry = pool.sample
    item_sym = nil
    qty_min = 1
    qty_max = 1

    if entry.is_a?(Array)
      item_sym = entry[0]
      if entry.length == 2
        qty_min = qty_max = (entry[1].is_a?(Integer) ? entry[1] : 1)
      elsif entry.length >= 3
        qty_min = (entry[1].is_a?(Integer) ? entry[1] : 1)
        qty_max = (entry[2].is_a?(Integer) ? entry[2] : qty_min)
        qty_max = qty_min if qty_max < qty_min
      end
    else
      item_sym = entry
    end

    item_data = GameData::Item.try_get(item_sym)
    return if !item_data || !defined?($PokemonBag)

    qty = (qty_min == qty_max) ? qty_min : rand(qty_min..qty_max)
    qty = 1 if qty < 1

    if $PokemonBag.respond_to?(:pbStoreItem)
      qty.times { $PokemonBag.pbStoreItem(item_sym) }
    end

    item_name = item_data.name
    plural = (qty > 1)
    display_name = plural ? _INTL("{1} {2}", qty, item_name + (item_name.end_with?("s") ? "" : "s")) : item_name

    pbMessage("\\me[Item get]You've proven yourself worthy!\\wtnp[10]")
    pbMessage(plural ? _INTL("As a token of respect, take {1}!", display_name) : _INTL("As a token of respect, here's {1}!", display_name))

    # Money reward (single grant alongside item)
    if defined?($Trainer) && $Trainer.respond_to?(:money) && $Trainer.respond_to?(:money=)
      old_money = $Trainer.money
      bonus = TrainerControl::Config::PROGRESSION_MONEY_REWARD
      $Trainer.money = [$Trainer.money + bonus, 999999].min
      gained = $Trainer.money - old_money
      if gained > 0
        pbMessage(_INTL("You also receive \\c[1]₽{1}\\c[0]!", gained))
      end
    end

    TrainerControlDebug.log("TrainerMemory: Gave #{qty}x #{item_name} and ₽#{TrainerControl::Config::PROGRESSION_MONEY_REWARD} for #{TrainerControl::Config::WINS_FOR_REWARD} wins vs #{trainer_id}")
  end
end  # End of TrainerMemory module

# ============================================================================
# SETTINGS MENU SECTION
# ============================================================================

# Modern Trainer Control Menu Scene
class TrainerControlScene < PokemonOption_Scene
  include ModSettingsSpacing if defined?(ModSettingsSpacing)
  
  # Skip fade-in to avoid double-fade (outer pbFadeOutIn handles transition)
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    # Initialize defaults if not set
    ModSettingsMenu.set(:level_scaling_enabled, TrainerControl::Config::LEVEL_SCALING_DEFAULT) if ModSettingsMenu.get(:level_scaling_enabled).nil?
    ModSettingsMenu.set(:trainer_level_offset, TrainerControl::Config::DEFAULT_LEVEL_OFFSET) if ModSettingsMenu.get(:trainer_level_offset).nil?
    ModSettingsMenu.set(:trainer_extra_pokemon_mode, TrainerControl::Config::EXTRA_POKEMON_DEFAULT_MODE) if ModSettingsMenu.get(:trainer_extra_pokemon_mode).nil?
    ModSettingsMenu.set(:trainer_extra_pokemon_count, TrainerControl::Config::EXTRA_POKEMON_DEFAULT_COUNT) if ModSettingsMenu.get(:trainer_extra_pokemon_count).nil?
    ModSettingsMenu.set(:trainer_no_dupes_extras, false) if ModSettingsMenu.get(:trainer_no_dupes_extras).nil?
    ModSettingsMenu.set(:trainer_extra_held_items, 0) if ModSettingsMenu.get(:trainer_extra_held_items).nil?
    ModSettingsMenu.set(:gym_leader_full_party, TrainerControl::Config::GYM_LEADER_FULL_PARTY_DEFAULT) if ModSettingsMenu.get(:gym_leader_full_party).nil?
    ModSettingsMenu.set(:battle_record_enabled, TrainerControl::Config::BATTLE_RECORD_DISPLAY_DEFAULT) if ModSettingsMenu.get(:battle_record_enabled).nil?
    ModSettingsMenu.set(:trainer_adaptation_enabled, TrainerControl::Config::TEAM_ADAPTATION_DEFAULT) if ModSettingsMenu.get(:trainer_adaptation_enabled).nil?
    ModSettingsMenu.set(:trainer_rewards_enabled, TrainerControl::Config::PROGRESSION_REWARDS_DEFAULT) if ModSettingsMenu.get(:trainer_rewards_enabled).nil?
    
    options = []
    
    # Level Scaling
    options << EnumOption.new(
      _INTL("Level Scaling"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:level_scaling_enabled) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:level_scaling_enabled, value == 1) },
      _INTL("Scale trainer Pokemon levels to match your team.")
    )
    
    # Level Difference
    options << StoneSliderOption.new(
      _INTL("Level Difference"),
      -10,
      20,
      1,
      proc { 
        val = ModSettingsMenu.get(:trainer_level_offset)
        val = TrainerControl::Config::DEFAULT_LEVEL_OFFSET if val.nil?
        [[val, -10].max, 20].min
      },
      proc { |value| 
        ModSettingsMenu.set(:trainer_level_offset, value)
      },
      _INTL("Adjust trainer levels relative to your highest Pokemon.")
    )
    
    # Extra Pokemon Mode
    options << EnumOption.new(
      _INTL("Extra Mode"),
      [_INTL("Off"), _INTL("Trainer Pool"), _INTL("Random"), _INTL("Random Fusion")],
      proc { 
        val = ModSettingsMenu.get(:trainer_extra_pokemon_mode)
        val = TrainerControl::Config::EXTRA_POKEMON_DEFAULT_MODE if val.nil?
        val
      },
      proc { |value| ModSettingsMenu.set(:trainer_extra_pokemon_mode, value) },
      _INTL("Add extra Pokemon to trainer teams.")
    )
    
    # Extra Pokemon Count
    options << StoneSliderOption.new(
      _INTL("Extra Pokemon Count"),
      1,
      5,
      1,
      proc { 
        val = ModSettingsMenu.get(:trainer_extra_pokemon_count)
        val = TrainerControl::Config::EXTRA_POKEMON_DEFAULT_COUNT if val.nil?
        [[val, 1].max, 5].min
      },
      proc { |value| 
        ModSettingsMenu.set(:trainer_extra_pokemon_count, value)
      },
      _INTL("Number of extra Pokemon to add (1-5).")
    )
    
    # No-Dupe Extras
    options << EnumOption.new(
      _INTL("No-Dupe Extras"),
      [_INTL("No"), _INTL("Yes")],
      proc { ModSettingsMenu.get(:trainer_no_dupes_extras) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:trainer_no_dupes_extras, value == 1) },
      _INTL("Prevent extra Pokemon from duplicating species in party.")
    )
    
    # Extra Held Items
    options << EnumOption.new(
      _INTL("Extra Held Items"),
      [_INTL("Off"), _INTL("50%"), _INTL("100%")],
      proc { 
        val = ModSettingsMenu.get(:trainer_extra_held_items)
        val = 0 if val.nil?
        case val
        when 50 then 1
        when 100 then 2
        else 0
        end
      },
      proc { |value| ModSettingsMenu.set(:trainer_extra_held_items, [0, 50, 100][value]) },
      _INTL("Chance for extra Pokemon to hold items.")
    )
    
    # Gym Leaders Full Party
    options << EnumOption.new(
      _INTL("Gym Leaders Full Party"),
      [_INTL("No"), _INTL("Yes")],
      proc { ModSettingsMenu.get(:gym_leader_full_party) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:gym_leader_full_party, value == 1) },
      _INTL("Force gym leaders to always have 6 Pokemon.")
    )
    
    # Battle Record Display
    options << EnumOption.new(
      _INTL("Battle Record Display"),
      [_INTL("No"), _INTL("Yes")],
      proc { ModSettingsMenu.get(:battle_record_enabled) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:battle_record_enabled, value == 1) },
      _INTL("Show your win/loss record against trainers.")
    )
    
    # Team Adaptation
    options << EnumOption.new(
      _INTL("Team Adaptation"),
      [_INTL("No"), _INTL("Yes")],
      proc { ModSettingsMenu.get(:trainer_adaptation_enabled) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:trainer_adaptation_enabled, value == 1) },
      _INTL("Trainers adapt with counter-Pokemon as you beat them repeatedly.")
    )
    
    # Progression Rewards
    options << EnumOption.new(
      _INTL("Trainer Rewards"),
      [_INTL("No"), _INTL("Yes")],
      proc { ModSettingsMenu.get(:trainer_rewards_enabled) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:trainer_rewards_enabled, value == 1) },
      _INTL("Receive rewards for consecutive trainer victories.")
    )
    
    # Auto-insert spacers if ModSettingsSpacing is available
    if defined?(ModSettingsSpacing) && respond_to?(:auto_insert_spacers)
      options = auto_insert_spacers(options)
    end
    
    options
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Trainer Control"), 0, 0, Graphics.width, 64, @viewport)
    
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

if defined?(ModSettingsMenu)
  reg_proc = proc {
    ModSettingsMenu.register(:trainer_control_submenu, {
      name: "Trainer Control",
      type: :button,
      description: "Control trainer Pokemon behavior (level scaling, extra Pokemon, etc.)",
      on_press: proc {
        pbFadeOutIn {
          scene = TrainerControlScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      },
      category: "Difficulty",
      searchable: [
        "trainer", "level scaling", "extra pokemon", "adaptation", "counter pokemon",
        "battle record", "progression rewards", "gym leaders", "team adaptation",
        "alpha pokemon", "fusion", "held items", "type pool"
      ]
    })
  }

  reg_proc.call
end

# ============================================================================
# EVENT HOOKS SECTION
# ============================================================================
$trainer_control_counter_add_announced = {} if !defined?($trainer_control_counter_add_announced)
$trainer_control_processing_announced = {} if !defined?($trainer_control_processing_announced)
$trainer_control_final_summary_announced = {} if !defined?($trainer_control_final_summary_announced)

Events.onTrainerPartyLoad += proc { |_sender, e|
  begin
    trainer = e.is_a?(Array) ? e[0] : e
    next if !trainer

    trainer_key = "#{trainer.trainer_type rescue 'UNKNOWN'}_#{trainer.name rescue 'UNKNOWN'}"

    if !$trainer_control_processing_announced[trainer_key]
      TrainerControlDebug.log("Trainer Control: Processing trainer #{trainer.name rescue 'Unknown'}")
      $trainer_control_processing_announced[trainer_key] = true
    end

    $trainer_control_processed_this_battle = trainer_key

    $trainer_control_battle_recorded = false

    $trainer_control_current_trainer = {
      type: trainer.trainer_type,
      name: trainer.name,
      trainer_object: trainer
    } rescue nil

    initial_party_size = trainer.party.length rescue 0

    trainer_id = TrainerMemory.get_trainer_id(trainer) rescue nil

    if defined?(TrainerMemory) && TrainerMemory.battle_record_enabled? && trainer_id
      $trainer_control_record_shown ||= {}
      unless $trainer_control_record_shown[trainer_key]
        record = TrainerMemory.get_record(trainer_id) rescue nil
        if record
          wins = record[:wins] || 0
          losses = record[:losses] || 0
          if wins > 0 || losses > 0
            pbMessage("\\se[GUI menu open]Battle Record: #{wins}W - #{losses}L")
          end
        end
        $trainer_control_record_shown[trainer_key] = true
      end
    end

    should_add_counter = false
    if trainer_id && defined?(TrainerMemory) && TrainerMemory.adaptation_enabled?
      record = TrainerMemory.get_record(trainer_id) rescue nil
      if record
        wins = record[:wins]
        desired_counter_count = wins / 4
        existing_in_party = trainer.party.count { |p| p && p.instance_variable_get(:@__tc_counter_mon) } rescue 0
        should_add_counter = desired_counter_count > existing_in_party
      end
    end

    if record && !trainer.instance_variable_get(:@__tc_original_party_size)
      wins = record[:wins]
      desired_counter_count = wins / 4
      reservation = [desired_counter_count, TrainerControl::Config::MAX_PARTY_SIZE].min
      adjusted_size = initial_party_size + reservation
      trainer.instance_variable_set(:@__tc_original_party_size, adjusted_size)
      TrainerControlDebug.log("TrainerMemory: Reserved original party size #{adjusted_size} (initial: #{initial_party_size}, desired counters: #{reservation})")
    end

    if should_add_counter && record
      wins = record[:wins]
      desired_counter_count = wins / 4
      existing_in_party = trainer.party.count { |p| p && p.instance_variable_get(:@__tc_counter_mon) } rescue 0
      pending = desired_counter_count - existing_in_party
      pending = 0 if pending < 0
      TrainerControlDebug.log("TrainerMemory: Counter addition check: wins=#{wins}, desired=#{desired_counter_count}, existing_in_party=#{existing_in_party}, pending=#{pending}")
      if pending > 0
        added_this_instance = 0
        show_counter_debug = !$trainer_control_counter_add_announced[trainer_key] && TrainerControlDebug.messages_enabled?
        while pending > 0 && trainer.party.length < TrainerControl::Config::MAX_PARTY_SIZE
          begin
            TrainerMemory.add_counter_pokemon(trainer, trainer_id)
            existing_in_party += 1
            pending -= 1
            added_this_instance += 1
          rescue => e
            TrainerControlDebug.log("TrainerMemory: Error adding counter fusion - #{e.message}")
            break
          end
        end
        if show_counter_debug && $DEBUG
          pbMessage("TrainerMemory: Added #{added_this_instance} counter fusion(s). Now in party: #{existing_in_party}/#{desired_counter_count}")
          pbMessage("TrainerMemory: Party size AFTER additions: #{trainer.party.length}")
          pbMessage("TrainerMemory: Party contents: #{trainer.party.map { |p| p.name }.join(', ')}")
          $trainer_control_counter_add_announced[trainer_key] = true
        end
      else
        TrainerControlDebug.log("TrainerMemory: No pending counter additions (desired=#{desired_counter_count}, existing_in_party=#{existing_in_party})")
      end
    else
      if $DEBUG && TrainerControlDebug.messages_enabled? && record
        desired = record[:wins] / 4
        existing_in_party = trainer.party.count { |p| p && p.instance_variable_get(:@__tc_counter_mon) } rescue 0
        if desired <= 0 || existing_in_party <= 0
          pbMessage("TrainerMemory: Counter condition not met (wins=#{record[:wins]}, existing_in_party=#{existing_in_party})")
        end
      end
    end

    after_counter_size = trainer.party.length rescue 0

    TrainerExtraPokemon.add_extra_pokemon(trainer)

    after_extras_size = trainer.party.length rescue 0

    if defined?(TrainerMemory)
      $trainer_control_moves_adapted ||= {}
      unless $trainer_control_moves_adapted[trainer_key]
        TrainerMemory.adapt_team(trainer)
        $trainer_control_moves_adapted[trainer_key] = true
      end
    end

    # Scale levels LAST to ensure final party reflects scaling
    if defined?(TrainerLevelScaling)
      TrainerLevelScaling.adjust_trainer_levels(trainer)
    end

    final_party_size = trainer.party.length rescue 0

    if trainer && !$trainer_control_final_summary_announced[trainer_key] && $DEBUG && TrainerControlDebug.messages_enabled?
      pbMessage("Trainer Control: Party sizes - Initial: #{initial_party_size}, After extras: #{after_extras_size}, After counter: #{after_counter_size}, Final: #{final_party_size}")
      pbMessage("Trainer Control: Final party: #{trainer.party.map { |p| "#{p.name} Lv.#{p.level}" }.join(', ')}")
      $trainer_control_final_summary_announced[trainer_key] = true
    end
  rescue => err
    if $DEBUG && TrainerControlDebug.messages_enabled?
      pbMessage("Trainer Pokemon Mod Error: #{err.message}")
      pbPrintException(err)
    end
  end
}

Events.onEndBattle += proc { |_sender, e|
  begin
    if defined?($trainer_control_battle_recorded) && $trainer_control_battle_recorded
      next
    end

    TrainerControlDebug.log("TrainerMemory: Battle end event triggered")

    $trainer_control_battle_recorded = true

    $trainer_control_processed_this_battle = nil if defined?($trainer_control_processed_this_battle)
    $trainer_control_counter_add_announced = {} if defined?($trainer_control_counter_add_announced)
    $trainer_control_processing_announced = {} if defined?($trainer_control_processing_announced)
    $trainer_control_final_summary_announced = {} if defined?($trainer_control_final_summary_announced)
    $trainer_control_levels_scaled = {} if defined?($trainer_control_levels_scaled)
    $trainer_control_moves_adapted = {} if defined?($trainer_control_moves_adapted)
    $trainer_control_record_shown = {} if defined?($trainer_control_record_shown)
    $trainer_control_items_adapted = {} if defined?($trainer_control_items_adapted)
    $trainer_control_natures_optimized = {} if defined?($trainer_control_natures_optimized)

    if !defined?(TrainerMemory)
      TrainerControlDebug.log("TrainerMemory: Module not defined!")
      next
    end

    if !TrainerMemory.enabled?
      TrainerControlDebug.log("TrainerMemory: System disabled in settings")
      next
    end

    decision = e[0] rescue nil

    TrainerControlDebug.log("TrainerMemory: Checking for stored trainer data...")

    if !defined?($trainer_control_current_trainer) || !$trainer_control_current_trainer
      TrainerControlDebug.log("TrainerMemory: No stored trainer data, skipping")
      next
    end

    trainer = $trainer_control_current_trainer[:trainer_object]

    if !trainer
      TrainerControlDebug.log("TrainerMemory: Trainer object not found, skipping")
      next
    end

    player_won = (decision == 1 || decision == 4)

    if $DEBUG && TrainerControlDebug.messages_enabled?
      trainer_name = trainer.name rescue "Unknown"
      pbMessage("TrainerMemory: Battle ended vs #{trainer_name}, Player won: #{player_won}")
    end

    TrainerMemory.record_battle(trainer, player_won)

    if player_won
      begin
        TrainerMemory.check_progression_reward(trainer)
      rescue => reward_err
        TrainerControlDebug.log("TrainerMemory: Reward check error - #{reward_err.message}")
      end
    end

    $trainer_control_current_trainer = nil
  rescue => err
    if $DEBUG && TrainerControlDebug.messages_enabled?
      pbMessage("TrainerMemory Error: #{err.message}")
      pbPrintException(err)
    end
  end
}

#===============================================================================
# Auto-Update Self-Registration
#===============================================================================
if defined?(ModSettingsMenu) && defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Trainer Control",
    file: "04_Trainer Control.rb",
    version: "2.0.0",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/04_Trainer%20Control.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Changelogs/Trainer%20Control.md",
    graphics: [],
    dependencies: [
      { file: "01_Mod_Settings.rb", version: "3.1.4" }
    ]
  )
  
  begin
    version = ModSettingsMenu::ModRegistry.all["04_Trainer Control.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("TrainerControl: Trainer Control #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
