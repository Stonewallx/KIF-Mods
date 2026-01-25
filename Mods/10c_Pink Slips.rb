#========================================
# Pink Slips
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.1
# Author: Stonewall
#========================================

module PinkSlips  
  # ============================================================================
  # Configuration Constants
  # ============================================================================
  
  # Trainer types that are considered rivals (cannot wager against)
  RIVAL_TYPES = (defined?(Settings::RIVAL_NAMES) ? Settings::RIVAL_NAMES.map { |entry| entry[0] }.compact : []).freeze
  
  # Maximum replacement attempts when generating Pokemon
  MAX_REPLACEMENT_ATTEMPTS = 100
  
  # Number of candidates to generate for replacements
  REPLACEMENT_CANDIDATE_COUNT = 10
  
  # ============================================================================
  # Pokemon Deep Clone Helper
  # ============================================================================
  
  # Generate IVs using IV Boundaries mod settings if available, else random
  def self.generate_prize_ivs
    # Check for IV Boundaries mod global variables (personal IVs for player-owned)
    low_iv = 0
    high_iv = 31
    
    if defined?($low_personal_iv) && defined?($high_personal_iv)
      low_iv = $low_personal_iv || 0
      high_iv = $high_personal_iv || 31
    elsif defined?(IVBoundariesSettings)
      low_iv = IVBoundariesSettings.get(:low_personal_iv) || 0
      high_iv = IVBoundariesSettings.get(:high_personal_iv) || 31
    end
    
    # Ensure bounds are valid
    low_iv = [[low_iv, 0].max, 31].min
    high_iv = [[high_iv, low_iv].max, 31].min
    
    # Generate random IV for each stat within bounds
    ivs = {}
    [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED].each do |stat|
      ivs[stat] = rand(low_iv..high_iv)
    end
    ivs
  end
  
  # Clone a Pokemon for prize - reset EVs to 0, regenerate IVs per boundaries
  def self.deep_clone_pokemon(pokemon)
    return nil unless pokemon
    
    clone = pokemon.clone
    
    # Generate fresh IVs using IV Boundaries settings
    new_ivs = generate_prize_ivs
    
    # Set IVs (handle both Hash and direct accessor styles)
    if clone.respond_to?(:iv=)
      clone.iv = new_ivs
    elsif clone.instance_variable_defined?(:@iv)
      clone.instance_variable_set(:@iv, new_ivs)
    end
    
    # Reset EVs to 0 (fresh Pokemon)
    zero_evs = {}
    [:HP, :ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED].each do |stat|
      zero_evs[stat] = 0
    end
    
    if clone.respond_to?(:ev=)
      clone.ev = zero_evs
    elsif clone.instance_variable_defined?(:@ev)
      clone.instance_variable_set(:@ev, zero_evs)
    end
    
    # Copy moves array
    if pokemon.respond_to?(:moves) && pokemon.moves
      clone.instance_variable_set(:@moves, pokemon.moves.map { |m| m.clone rescue m })
    end
    
    # Recalculate stats to reflect new IVs and zeroed EVs
    clone.calc_stats if clone.respond_to?(:calc_stats)
    
    clone
  end
  
  # ============================================================================
  # Module State
  # ============================================================================
  
  @state = {
    active: false,
    collecting: false,
    wager_index: nil,
    wager_mon: nil,
    foe_trainers: [],
    foe_parties: {},
    trainer_key: nil
  }
  
  # Recursion guard for pbTrainerBattleCore
  @in_trainer_battle = false
  
  class << self
    attr_accessor :state, :in_trainer_battle
    
    # ==========================================================================
    # Settings & Configuration
    # ==========================================================================
    
    def enabled?
      return true unless defined?(ModSettingsMenu)
      setting = ModSettingsMenu.get(:pink_slips_enabled)
      return true if setting.nil?
      setting == 1 || setting == true
    end
    
    def infinite_wagers?
      return false unless defined?(ModSettingsMenu)
      setting = ModSettingsMenu.get(:pink_slips_infinite_wagers)
      return false if setting.nil?
      setting == 1 || setting == true
    end
    
    # ==========================================================================
    # State Management
    # ==========================================================================
    
    def reset!
      @state[:active] = false
      @state[:collecting] = false
      @state[:wager_index] = nil
      @state[:wager_mon] = nil
      @state[:foe_trainers] = []
      @state[:foe_parties] = {}
      @state[:trainer_key] = nil
      ModSettingsMenu.debug_log("PinkSlips: State reset") if defined?(ModSettingsMenu)
    end
    
    def cleanup
      reset!
    end
    
    # ==========================================================================
    # Wager History (Persistent Storage)
    # ==========================================================================
    
    def wager_history
      return {} unless defined?($PokemonGlobal) && $PokemonGlobal
      unless $PokemonGlobal.instance_variable_defined?(:@pink_slips_wagers)
        $PokemonGlobal.instance_variable_set(:@pink_slips_wagers, {})
      end
      $PokemonGlobal.instance_variable_get(:@pink_slips_wagers)
    end
    
    def already_wagered?(key)
      wager_history.key?(key)
    end
    
    # ==========================================================================
    # Trainer Identification
    # ==========================================================================
    
    def trainer_key(trainer)
      return nil unless trainer
      
      type = trainer.trainer_type rescue nil
      name = trainer.name rescue nil
      return nil unless type && name
      
      map_id = 0
      if defined?($game_map) && $game_map
        map_id = $game_map.map_id rescue 0
      end
      
      "#{map_id}_#{type}_#{name}".upcase
    end
    
    # ==========================================================================
    # Eligibility Checks
    # ==========================================================================
    
    def eligible_battle?(trainers)
      return false unless trainers.is_a?(Array)
      return false if trainers.length != 1
      return false if gym_battle?
      return false if trainers.any? { |t| disallowed_trainer?(t) }
      true
    end
    
    def gym_battle?
      return false unless defined?(VAR_CURRENT_GYM_TYPE) && defined?($game_variables)
      gym_var = $game_variables[VAR_CURRENT_GYM_TYPE] rescue -1
      gym_var != -1
    end
    
    def disallowed_trainer?(trainer)
      return true unless trainer
      return true if rival_trainer?(trainer)
      
      type_name = trainer.trainer_type.to_s.upcase
      return true if type_name.include?("LEADER")
      return true if type_name.include?("ELITE")
      return true if type_name.include?("CHAMPION")
      return true if type_name.include?("RIVAL")
      
      false
    end
    
    def rival_trainer?(trainer)
      # Check for first rival battle switch
      if defined?(SWITCH_FIRST_RIVAL_BATTLE) && defined?($game_switches)
        if $game_switches && ($game_switches[SWITCH_FIRST_RIVAL_BATTLE] rescue false)
          return true
        end
      end
      
      # Check if trainer type is in RIVAL_TYPES array
      return false unless trainer.respond_to?(:trainer_type)
      RIVAL_TYPES.include?(trainer.trainer_type)
    end
    
    # ==========================================================================
    # Pokemon Injection & Replacement
    # ==========================================================================
    
    def inject_wagered_pokemon(trainer)
      return unless trainer
      
      key = trainer_key(trainer)
      return unless key && already_wagered?(key)
      
      wagered_data = wager_history[key]
      return unless wagered_data
      return unless trainer.respond_to?(:party) && trainer.party.is_a?(Array)
      
      if wagered_data[:won]
        # Player won - trainer has replacement Pokemon
        inject_replacement_pokemon(trainer, wagered_data)
      elsif !wagered_data[:won]
        # Player lost - trainer has player's wagered Pokemon
        inject_players_pokemon(trainer, wagered_data)
      end
    end
    
    def inject_replacement_pokemon(trainer, wagered_data)
      if wagered_data[:replacement]
        # Use stored replacement
        replacement = wagered_data[:replacement].clone
        replacement.heal
        replacement.calc_stats
        trainer.party << replacement if trainer.party.length < 6
        ModSettingsMenu.debug_log("PinkSlips: Injected stored replacement: #{replacement.name}") if defined?(ModSettingsMenu)
      else
        # Generate new replacement
        original_pkmn = wagered_data[:pokemon]
        old_types = original_pkmn.types rescue [original_pkmn.type1, original_pkmn.type2].compact
        replacement = generate_replacement_pokemon(old_types, trainer, original_pkmn)
        
        if replacement
          replacement.heal
          replacement.calc_stats
          trainer.party << replacement if trainer.party.length < 6
          wagered_data[:replacement] = replacement.clone
          ModSettingsMenu.debug_log("PinkSlips: Generated and injected replacement: #{replacement.name}") if defined?(ModSettingsMenu)
        end
      end
    end
    
    def inject_players_pokemon(trainer, wagered_data)
      wagered_pkmn = wagered_data[:pokemon]
      return unless wagered_pkmn
      
      # Check if already in party
      already_has = trainer.party.any? do |p|
        p.species == wagered_pkmn.species && p.personalID == wagered_pkmn.personalID
      end
      return if already_has
      
      wagered_clone = wagered_pkmn.clone
      
      # Level up to match trainer's strongest Pokemon
      if trainer.party.length > 0
        max_level = trainer.party.map { |p| p.level rescue 0 }.max
        if max_level > 0 && wagered_clone.level < max_level
          wagered_clone.level = max_level
        end
      end
      
      wagered_clone.heal
      wagered_clone.calc_stats
      
      # Set owner if possible
      if defined?(Pokemon::Owner) && trainer.respond_to?(:id)
        wagered_clone.instance_variable_set(:@owner, Pokemon::Owner.new_from_trainer(trainer))
      end
      
      trainer.party << wagered_clone if trainer.party.length < 6
      ModSettingsMenu.debug_log("PinkSlips: Injected player's wagered Pokemon: #{wagered_clone.name}") if defined?(ModSettingsMenu)
    end
    
    # ==========================================================================
    # Replacement Pokemon Generation
    # ==========================================================================
    
    def generate_replacement_pokemon(target_types, trainer, original_pokemon = nil)
      is_fusion = check_if_fusion(original_pokemon)
      target_types = [target_types] unless target_types.is_a?(Array)
      
      candidates = is_fusion ? generate_fusion_candidates(target_types) : generate_normal_candidates(target_types)
      
      # Fallback if no candidates found
      if candidates.empty?
        candidates = generate_fallback_candidates(is_fusion)
      end
      
      return nil if candidates.empty?
      
      # Pick random candidate
      species_id = candidates.sample
      level = calculate_replacement_level(trainer, original_pokemon)
      
      pokemon = create_pokemon(species_id, level, trainer)
      ModSettingsMenu.debug_log("PinkSlips: Generated replacement: #{pokemon.name} (Level #{level})") if defined?(ModSettingsMenu)
      
      pokemon
    end
    
    def check_if_fusion(pokemon)
      return false unless pokemon
      
      if pokemon.respond_to?(:isFusion?)
        return pokemon.isFusion?
      end
      
      if defined?(NB_POKEMON)
        return pokemon.species > NB_POKEMON
      end
      
      false
    end
    
    def generate_fusion_candidates(target_types)
      return [] unless defined?(NB_POKEMON) && defined?(GameData::Species)
      
      candidates = []
      primary_type = target_types[0]
      tries = 0
      
      while tries < MAX_REPLACEMENT_ATTEMPTS && candidates.length < REPLACEMENT_CANDIDATE_COUNT
        head_id = rand(1..NB_POKEMON)
        body_id = rand(1..NB_POKEMON)
        next if head_id == body_id
        
        fusion_species = head_id * NB_POKEMON + body_id
        species_data = GameData::Species.try_get(fusion_species)
        next unless species_data
        
        t1 = normalize_type(species_data.type1)
        
        if primary_type && t1 == primary_type
          candidates << fusion_species
        end
        
        tries += 1
      end
      
      candidates
    end
    
    def generate_normal_candidates(target_types)
      return [] unless defined?(NB_POKEMON) && defined?(GameData::Species)
      
      candidates = []
      
      (1..NB_POKEMON).each do |species_id|
        species_data = GameData::Species.try_get(species_id)
        next unless species_data
        
        t1 = normalize_type(species_data.type1)
        t2 = normalize_type(species_data.type2)
        
        if target_types.include?(t1) || target_types.include?(t2)
          candidates << species_id
        end
      end
      
      candidates
    end
    
    def generate_fallback_candidates(is_fusion)
      return [] unless defined?(NB_POKEMON)
      
      if is_fusion
        head_id = rand(1..NB_POKEMON)
        body_id = rand(1..NB_POKEMON)
        body_id = rand(1..NB_POKEMON) while body_id == head_id
        [head_id * NB_POKEMON + body_id]
      else
        [rand(1..NB_POKEMON)]
      end
    end
    
    def normalize_type(type)
      return type unless type.is_a?(Symbol)
      PBTypes.const_get(type.to_s.upcase) rescue type
    end
    
    def calculate_replacement_level(trainer, original_pokemon)
      level = 5
      
      # Try to match original level
      if original_pokemon
        level = original_pokemon.level rescue 5
      end
      
      # Or match trainer's average level
      if trainer && trainer.respond_to?(:party) && trainer.party.length > 0
        avg_level = trainer.party.map { |p| p.level rescue 0 }.sum / trainer.party.length
        level = avg_level if avg_level > level
      end
      
      level.clamp(1, 100)
    end
    
    def create_pokemon(species_id, level, trainer = nil)
      pokemon = nil
      
      if defined?(Pokemon) && Pokemon.respond_to?(:new)
        pokemon = Pokemon.new(species_id, level)
      end
      
      return nil unless pokemon
      
      # Set owner if possible
      if trainer && defined?(Pokemon::Owner) && trainer.respond_to?(:id)
        pokemon.instance_variable_set(:@owner, Pokemon::Owner.new_from_trainer(trainer))
      end
      
      pokemon.calc_stats
      pokemon.reset_moves
      pokemon.heal
      
      pokemon
    end
    
    # ==========================================================================
    # Battle Workflow
    # ==========================================================================
    
    def pre_battle(args)
      return unless enabled?
      
      # Recursion guard
      if @in_trainer_battle
        ModSettingsMenu.debug_log("PinkSlips: Recursion detected - skipping pre_battle") if defined?(ModSettingsMenu)
        return
      end
      
      @in_trainer_battle = true
      
      begin
        trainers = resolve_trainers(args)
        return unless eligible_battle?(trainers)
        
        trainer = trainers[0]
        key = trainer_key(trainer)
        return unless key
        
        @state[:trainer_key] = key
        @state[:foe_trainers] = trainers
        
        # Check if already wagered
        if already_wagered?(key)
          if infinite_wagers?
            pbMessage(_INTL("You've already wagered against this trainer, but you can wager again!"))
          else
            ModSettingsMenu.debug_log("PinkSlips: Already wagered against #{key} - skipping wager prompt") if defined?(ModSettingsMenu)
            return
          end
        end
        
        # Prompt for wager
        if pbConfirmMessage(_INTL("Would you like to wager a Pokémon in this battle?"))
          wager_idx = prompt_wager
          
          if wager_idx && wager_idx >= 0
            @state[:active] = true
            @state[:wager_index] = wager_idx
            @state[:wager_mon] = $Trainer.party[wager_idx].clone
            
            pbMessage(_INTL("You wagered {1}!", @state[:wager_mon].name))
            ModSettingsMenu.debug_log("PinkSlips: Wager active: #{@state[:wager_mon].name} at index #{wager_idx}") if defined?(ModSettingsMenu)
          else
            ModSettingsMenu.debug_log("PinkSlips: No wager selected") if defined?(ModSettingsMenu)
          end
        end
      rescue => e
        ModSettingsMenu.debug_log("PinkSlips: Error in pre_battle: #{e.message}") if defined?(ModSettingsMenu)
        ModSettingsMenu.debug_log("PinkSlips: #{e.backtrace.join('\n')}") if defined?(ModSettingsMenu)
        reset!
      ensure
        @in_trainer_battle = false
      end
    end
    
    def resolve_trainers(args)
      trainers = []
      
      args.each do |arg|
        case arg
        when NPCTrainer
          trainers << arg
        when Array
          trainer = pbLoadTrainer(arg[0], arg[1], arg[2]) rescue nil
          
          # Try with modern mode toggle if failed
          if !trainer && defined?(SWITCH_MODERN_MODE) && defined?($game_switches)
            original_modern = $game_switches[SWITCH_MODERN_MODE] rescue false
            begin
              $game_switches[SWITCH_MODERN_MODE] = false
              trainer = pbLoadTrainer(arg[0], arg[1], arg[2]) rescue nil
            ensure
              $game_switches[SWITCH_MODERN_MODE] = original_modern
            end
          end
          
          next unless trainer
          
          # Apply overrides from args
          trainer.trainer_type = arg[5] if arg[5]
          trainer.name = arg[4] if arg[4]
          
          trainers << trainer
        end
      end
      
      trainers.compact
    end
    
    def prompt_wager
      return nil unless defined?($Trainer) && $Trainer
      return nil unless $Trainer.party && !$Trainer.party.empty?
      
      loop do
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, $Trainer.party)
        screen.pbStartScene(_INTL("Choose a Pokémon to wager."), false)
        
        chosen = screen.pbChooseAblePokemon(proc { |pkmn| pkmn && !pkmn.egg? }, false)
        
        if chosen.nil? || chosen < 0
          screen.pbEndScene
          if pbConfirmMessage(_INTL("Continue without wagering?"))
            return nil
          end
          next
        end
        
        selected_mon = $Trainer.party[chosen]
        screen.pbEndScene
        
        commands = [_INTL("Summary"), _INTL("Wager"), _INTL("Cancel")]
        cmd = pbMessage(_INTL("Do what with {1}?", selected_mon.name), commands, -1)
        
        case cmd
        when 0  # Summary
          summary_scene = PokemonSummary_Scene.new
          summary_screen = PokemonSummaryScreen.new(summary_scene)
          summary_screen.pbStartScreen($Trainer.party, chosen)
        when 1  # Wager
          return chosen
        when 2, -1  # Cancel
          # Loop continues
        end
      end
    rescue => e
      ModSettingsMenu.debug_log("PinkSlips: Error in prompt_wager: #{e.message}") if defined?(ModSettingsMenu)
      nil
    end
    
    def record_trainer_party(trainer, party)
      return unless @state[:active]
      return unless trainer && party
      
      key = trainer_key(trainer)
      return unless key == @state[:trainer_key]
      
      @state[:foe_parties][key] = party.map(&:clone)
      ModSettingsMenu.debug_log("PinkSlips: Recorded trainer party for #{key}: #{party.length} Pokemon") if defined?(ModSettingsMenu)
    end
    
    def resolve_after_battle(decision)
      return unless @state[:active]
      
      begin
        case decision
        when 1  # Player won
          handle_player_victory
        when 2, 5  # Player lost or draw
          handle_player_defeat
        else
          ModSettingsMenu.debug_log("PinkSlips: Unexpected battle decision: #{decision}") if defined?(ModSettingsMenu)
        end
        
        # Claim prize immediately before cleanup wipes the state
        claim_stored_prizes if @state[:collecting]
        
      rescue => e
        ModSettingsMenu.debug_log("PinkSlips: Error in resolve_after_battle: #{e.message}") if defined?(ModSettingsMenu)
        ModSettingsMenu.debug_log("PinkSlips: #{e.backtrace.join('\n')}") if defined?(ModSettingsMenu)
      ensure
        cleanup
      end
    end
    
    def handle_player_victory
      return unless @state[:wager_mon] && @state[:trainer_key]
      
      ModSettingsMenu.debug_log("PinkSlips: Player won - selecting prize Pokemon") if defined?(ModSettingsMenu)
      
      foe_party = @state[:foe_parties][@state[:trainer_key]]
      return unless foe_party && !foe_party.empty?
      
      # Filter out eggs and boss/alpha Pokemon
      eligible_prizes = foe_party.select do |pkmn|
        next false if pkmn.egg?
        next false if pkmn.respond_to?(:isBossAlpha?) && pkmn.isBossAlpha?
        next false if pkmn.respond_to?(:alpha?) && pkmn.alpha?
        next false if pkmn.name.end_with?(" A")  # Boss naming convention
        true
      end
      
      if eligible_prizes.empty?
        pbMessage(_INTL("The opponent has no eligible Pokémon to wager!"))
        record_wager_history(won: false, got_prize: false)
        return
      end
      
      # Prompt player to choose prize
      prize = prompt_prize_selection(eligible_prizes)
      
      if prize
        @state[:won_pokemon] = deep_clone_pokemon(prize)
        @state[:collecting] = true
        
        pbMessage(_INTL("You won {1}!", prize.name))
        ModSettingsMenu.debug_log("PinkSlips: Player won: #{prize.name}") if defined?(ModSettingsMenu)
        
        record_wager_history(won: true, got_prize: true)
      else
        ModSettingsMenu.debug_log("PinkSlips: No prize selected") if defined?(ModSettingsMenu)
        record_wager_history(won: true, got_prize: false)
      end
    end
    
    def handle_player_defeat
      return unless @state[:wager_mon] && @state[:wager_index]
      
      ModSettingsMenu.debug_log("PinkSlips: Player lost - removing wagered Pokemon") if defined?(ModSettingsMenu)
      
      # Remove wagered Pokemon from party
      if defined?($Trainer) && $Trainer && $Trainer.party
        if @state[:wager_index] < $Trainer.party.length
          removed = $Trainer.party.delete_at(@state[:wager_index])
          pbMessage(_INTL("You lost {1}...", removed.name)) if removed
          ModSettingsMenu.debug_log("PinkSlips: Removed wagered Pokemon: #{removed.name}") if defined?(ModSettingsMenu)
        end
      end
      
      record_wager_history(won: false, got_prize: false)
    end
    
    def prompt_prize_selection(eligible_prizes)
      return nil if eligible_prizes.empty?
      return eligible_prizes[0] if eligible_prizes.length == 1
      
      # Create selection menu
      commands = eligible_prizes.map.with_index do |pkmn, i|
        "#{pkmn.name} (Lv.#{pkmn.level})"
      end
      commands << "Cancel"
      
      cmd = pbMessage(_INTL("Choose your prize!"), commands, -1)
      
      return nil if cmd < 0 || cmd >= eligible_prizes.length
      eligible_prizes[cmd]
    rescue => e
      ModSettingsMenu.debug_log("PinkSlips: Error in prompt_prize_selection: #{e.message}") if defined?(ModSettingsMenu)
      eligible_prizes[0]  # Default to first if error
    end
    
    def record_wager_history(won:, got_prize: false)
      key = @state[:trainer_key]
      return unless key
      
      history_entry = {
        pokemon: @state[:wager_mon],
        won: won,
        got_prize: got_prize,
        timestamp: Time.now.to_i
      }
      
      if won && got_prize && @state[:won_pokemon]
        history_entry[:prize] = @state[:won_pokemon].clone
        history_entry[:won_pokemon] = @state[:won_pokemon].clone
      end
      
      wager_history[key] = history_entry
      ModSettingsMenu.debug_log("PinkSlips: Recorded wager history for #{key}: won=#{won}, got_prize=#{got_prize}") if defined?(ModSettingsMenu)
    end
    
    # ==========================================================================
    # Prize Collection & Storage
    # ==========================================================================
    
    def claim_stored_prizes
      return unless @state[:collecting] && @state[:won_pokemon]
      
      begin
        pokemon = @state[:won_pokemon]
        
        # Try to add to party
        if defined?($Trainer) && $Trainer && $Trainer.party
          if $Trainer.party.length < (defined?(Settings::MAX_PARTY_SIZE) ? Settings::MAX_PARTY_SIZE : 6)
            $Trainer.party << pokemon
            pbMessage(_INTL("{1} joined your party!", pokemon.name))
            ModSettingsMenu.debug_log("PinkSlips: Added #{pokemon.name} to party") if defined?(ModSettingsMenu)
          elsif defined?($PokemonStorage) && $PokemonStorage
            stored_box = $PokemonStorage.pbStoreCaught(pokemon)
            if stored_box >= 0
              pbMessage(_INTL("{1} was sent to Box {2}.", pokemon.name, stored_box + 1))
              ModSettingsMenu.debug_log("PinkSlips: Stored #{pokemon.name} in box #{stored_box + 1}") if defined?(ModSettingsMenu)
            else
              pbMessage(_INTL("No space to store {1}.", pokemon.name))
              ModSettingsMenu.debug_log("PinkSlips: Failed to store #{pokemon.name} - no space") if defined?(ModSettingsMenu)
            end
          end
        end
      rescue => e
        ModSettingsMenu.debug_log("PinkSlips: Error claiming prize: #{e.message}") if defined?(ModSettingsMenu)
      ensure
        @state[:collecting] = false
        @state[:won_pokemon] = nil
      end
    end
  end
end

# ============================================================================
# Battle Hook
# ============================================================================

unless defined?(PinkSlips::BATTLE_PATCHED)
  alias pinkslips_original_pbTrainerBattleCore pbTrainerBattleCore
  
  def pbTrainerBattleCore(*args)
    # Call Pink Slips pre-battle logic
    PinkSlips.pre_battle(args) if defined?(PinkSlips)
    
    # Call original method
    pinkslips_original_pbTrainerBattleCore(*args)
  end
  
  PinkSlips::BATTLE_PATCHED = true
  ModSettingsMenu.debug_log("PinkSlips: Battle hook installed") if defined?(ModSettingsMenu)
end

# ============================================================================
# Event Handlers
# ============================================================================

# Record trainer parties when loaded
Events.onTrainerPartyLoad += proc { |sender, e|
  next unless PinkSlips.enabled?
  
  begin
    trainer = e.is_a?(Array) ? e[0] : e
    next unless trainer && trainer.respond_to?(:party)
    
    party = trainer.party
    next unless party
    
    # Inject wagered Pokemon for rematches
    PinkSlips.inject_wagered_pokemon(trainer)
    
    # Record party for current battle
    PinkSlips.record_trainer_party(trainer, party)
  rescue => e
    ModSettingsMenu.debug_log("PinkSlips: Error in onTrainerPartyLoad: #{e.message}") if defined?(ModSettingsMenu)
  end
}

# Resolve wagers after battle
Events.onEndBattle += proc { |_sender, e|
  next unless PinkSlips.enabled?
  
  begin
    decision = e[0]
    PinkSlips.resolve_after_battle(decision)
  rescue => e
    ModSettingsMenu.debug_log("PinkSlips: Error in onEndBattle: #{e.message}") if defined?(ModSettingsMenu)
    PinkSlips.cleanup
  end
}

# Claim prizes on map update
Events.onMapUpdate += proc { |_sender, e|
  next unless PinkSlips.enabled?
  
  begin
    PinkSlips.claim_stored_prizes
  rescue => e
    ModSettingsMenu.debug_log("PinkSlips: Error in onMapUpdate: #{e.message}") if defined?(ModSettingsMenu)
  end
}

# ============================================================================
# Pink Slips Submenu Scene
# ============================================================================

class PinkSlipsScene < PokemonOption_Scene
  include ModSettingsSpacing
  
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
    
    # Pink Slips Enabled Toggle
    options << EnumOption.new(
      _INTL("Enable Pink Slips"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:pink_slips_enabled) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:pink_slips_enabled, value == 1) },
      _INTL("Enable the Pink Slips wagering system for trainer battles")
    )
    
    # Infinite Wagers Toggle
    options << EnumOption.new(
      _INTL("Infinite Wagers"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:pink_slips_infinite_wagers) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:pink_slips_infinite_wagers, value == 1) },
      _INTL("Allow wagering against the same trainer multiple times")
    )
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Pink Slips Settings"), 0, 0, Graphics.width, 64, @viewport)
    
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

# ============================================================================
# Mod Settings Registration
# ============================================================================

if defined?(ModSettingsMenu)
  # Register button that opens submenu
  reg_proc = proc {
    ModSettingsMenu.register(:pink_slips_menu, {
      name: "Pink Slips",
      type: :button,
      description: "Wager Pokemon in trainer battles - winner takes a random Pokemon from the loser",
      on_press: proc {
        pbFadeOutIn {
          scene = PinkSlipsScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      },
      category: "Difficulty",
      searchable: [
        "pink slips", "wager", "betting", "gamble", "trainer battle",
        "risk", "stakes", "infinite wagers", "challenge"
      ]
    })
  }
  
  reg_proc.call
  
  ModSettingsMenu.debug_log("PinkSlips: Settings registered")
end

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Pink Slips",
    file: "10c_Pink Slips.rb",
    version: "2.0.1",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/10c_Pink%20Slips.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Changelogs/Pink%20Slips.md",
    graphics: [],
    dependencies: []
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["10c_Pink Slips.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("PinkSlips: Pink Slips #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
