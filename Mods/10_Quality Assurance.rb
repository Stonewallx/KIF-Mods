#========================================
# Quality Assurance
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
#========================================
# Mods included: Insta-Hatch (Credit to AnUnsocialPigeon), Remove Disobedience (Credit to AnUnsocialPigeon), Infinite Safari Steps (Credit to Laudron), 
# Rematch Money (Credit to Ceadeus)

# ============================================================================
# AUTO HOOK FISHING MOD
# ============================================================================
module MiscMods
  module AutoHookFishing
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_auto_hook_fishing)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
    
    def self.apply
      return unless defined?(Settings)
      if Settings.const_defined?(:FISHING_AUTO_HOOK)
        Settings.send(:remove_const, :FISHING_AUTO_HOOK)
      end
      
      if enabled?
        Settings.const_set(:FISHING_AUTO_HOOK, true)
      else
        Settings.const_set(:FISHING_AUTO_HOOK, false)
      end
    end
  end
end

MiscMods::AutoHookFishing.apply if defined?(MiscMods::AutoHookFishing)

# ============================================================================
# INFINITE SAFARI STEPS MOD
# ============================================================================
module MiscMods
  module InfiniteSafariSteps
    DEFAULT_ENABLED = false
    DEFAULT_STEPS = 999999
    ORIGINAL_STEPS = 600

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_infinite_safari_steps)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end

    def self.apply
      return unless defined?(Settings)
      if Settings.const_defined?(:SAFARI_STEPS)
        Settings.send(:remove_const, :SAFARI_STEPS)
      end
      
      if enabled?
        Settings.const_set(:SAFARI_STEPS, DEFAULT_STEPS)
      else
        Settings.const_set(:SAFARI_STEPS, ORIGINAL_STEPS)
      end
    end
  end
end

MiscMods::InfiniteSafariSteps.apply if defined?(MiscMods::InfiniteSafariSteps)

# ============================================================================
# REMATCH MONEY MOD
# Allows money gain from trainer rematches
# ============================================================================
module MiscMods
  module RematchMoney
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_rematch_money)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
end

if defined?(PokeBattle_Battle)
  class PokeBattle_Battle
    alias miscmods_rematch_pbGainMoney pbGainMoney unless method_defined?(:miscmods_rematch_pbGainMoney)
    
    def pbGainMoney
      if defined?(MiscMods::RematchMoney) && MiscMods::RematchMoney.enabled?
        was_rematch = $game_switches[SWITCH_IS_REMATCH] if defined?(SWITCH_IS_REMATCH)
        
        $game_switches[SWITCH_IS_REMATCH] = false if defined?(SWITCH_IS_REMATCH)
        
        miscmods_rematch_pbGainMoney
        
        $game_switches[SWITCH_IS_REMATCH] = was_rematch if defined?(SWITCH_IS_REMATCH)
      else
        miscmods_rematch_pbGainMoney
      end
    end
  end
end

# ============================================================================
# SETTINGS CALLBACKS - AUTO-APPLY WHEN CHANGED
# ============================================================================
# Register callbacks to apply settings immediately when changed via ModSettings
if defined?(ModSettingsMenu)
  # Auto Hook Fishing
  ModSettingsMenu.register_on_change(:miscmods_auto_hook_fishing) do |value|
    MiscMods::AutoHookFishing.apply if defined?(MiscMods::AutoHookFishing)
  end
  
  # Infinite Safari Steps
  ModSettingsMenu.register_on_change(:miscmods_infinite_safari_steps) do |value|
    MiscMods::InfiniteSafariSteps.apply if defined?(MiscMods::InfiniteSafariSteps)
  end
  
  # Infinite Money
  ModSettingsMenu.register_on_change(:miscmods_infinite_money) do |value|
    MiscMods::InfiniteMoney.apply if defined?(MiscMods::InfiniteMoney) && value == 1
  end
end

# ============================================================================
# NO MOVE AUTO-TEACH MOD
# ============================================================================
# When enabled:
# - Level-up moves: Shows "{Pokemon} gained knowledge of {Move}" message only
# - TMs/HMs/Tutor.net: Shows confirmation, then goes directly to move selection

module MiscMods
  module NoMoveAutoTeach
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_no_move_auto_teach)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
  
  module MoveTeachPrompt
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_move_teach_prompt)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
end

# ============================================================================
# INFINITE REPEL MOD
# ============================================================================

module MiscMods
  module InfiniteRepel
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_infinite_repel)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
end

begin
  if Object.private_method_defined?(:isRepelActive) && !Object.private_method_defined?(:miscmods_isRepelActive)
    class Object
      alias_method :miscmods_isRepelActive, :isRepelActive
      private :miscmods_isRepelActive rescue nil

      def isRepelActive()
        begin
          return true if defined?(MiscMods::InfiniteRepel) && MiscMods::InfiniteRepel.enabled?
        rescue
        end
        return miscmods_isRepelActive
      end
      private :isRepelActive rescue nil
    end
  end
rescue
end

# ============================================================================
# INFINITE MONEY MOD
# ============================================================================

module MiscMods
  module InfiniteMoney
    DEFAULT_ENABLED = false
    MAX_MONEY = 999999

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_infinite_money)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end

    def self.apply
      return unless enabled?
      $Trainer.money = MAX_MONEY if $Trainer && $Trainer.money < MAX_MONEY
    end
  end
end

begin
  if defined?(Trainer) && !Trainer.method_defined?(:miscmods_infinite_money_money_set)
    class Trainer
      alias miscmods_infinite_money_money_set money=
      def money=(value)
        if defined?(MiscMods::InfiniteMoney) && MiscMods::InfiniteMoney.enabled?
          self.miscmods_infinite_money_money_set(MiscMods::InfiniteMoney::MAX_MONEY)
        else
          self.miscmods_infinite_money_money_set(value)
        end
      end
    end
  end
rescue
end

begin
  if defined?(Scene_Map) && !Scene_Map.method_defined?(:miscmods_infinite_money_update)
    class Scene_Map
      alias miscmods_infinite_money_update update
      def update
        MiscMods::InfiniteMoney.apply if defined?(MiscMods::InfiniteMoney)
        MiscMods::UpgradedPP.apply if defined?(MiscMods::UpgradedPP)
        MiscMods::InfinitePP.apply if defined?(MiscMods::InfinitePP)
        miscmods_infinite_money_update
      end
    end
  end
rescue
end

# ============================================================================
# UPGRADED PP MOD
# ============================================================================
# When enabled, automatically sets all party Pokemon moves to max PP upgrades (ppup = 5)
# and restores PP to full when moves are learned

module MiscMods
  module UpgradedPP
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_upgraded_pp)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end

    def self.apply
      return unless enabled?
      return unless $Trainer && $Trainer.party
      
      $Trainer.party.each do |pkmn|
        next if !pkmn || pkmn.egg?
        
        pkmn.moves.each do |move|
          next if !move || move.total_pp <= 1
          # Set to maximum PP upgrades (5 = PP Max level) and restore PP
          if move.ppup < 5
            move.ppup = 5
            move.pp = move.total_pp  # Restore PP to max
          end
        end
      end
    end
    
    # Apply upgrades to a single move (for when moves are just learned)
    def self.upgrade_move(move)
      return unless enabled?
      return if !move || move.total_pp <= 1
      move.ppup = 5
      move.pp = move.total_pp  # Restore PP to max
    end
  end
end

# Patch Pokemon's learn_move method to immediately upgrade and restore PP
begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:miscmods_upgraded_pp_learn_move)
    class Pokemon
      alias miscmods_upgraded_pp_learn_move learn_move
      
      def learn_move(move_id)
        result = miscmods_upgraded_pp_learn_move(move_id)
        
        # If the move was successfully learned and Upgraded PP is enabled, upgrade it
        if result && defined?(MiscMods::UpgradedPP)
          # Find the newly learned move and upgrade it
          @moves.each do |move|
            if move && move.id == move_id
              MiscMods::UpgradedPP.upgrade_move(move)
              break
            end
          end
        end
        
        return result
      end
    end
  end
rescue => e
  echoln("Error patching learn_move for Upgraded PP: #{e}") rescue nil
end

# ============================================================================
# INFINITE PP MOD
# ============================================================================
# When enabled, continuously restores all party Pokemon moves to full PP

module MiscMods
  module InfinitePP
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_infinite_pp)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end

    def self.apply
      return unless enabled?
      return unless $Trainer && $Trainer.party
      
      $Trainer.party.each do |pkmn|
        next if !pkmn || pkmn.egg?
        
        pkmn.moves.each do |move|
          next if !move || move.total_pp <= 1
          # Restore PP to maximum
          move.pp = move.total_pp
        end
      end
    end
  end
end

# ============================================================================
# REMOVE DISOBEDIENCE MOD
# ============================================================================
# When enabled (Off), Pokemon always obey regardless of level/badges
# When disabled (On), Pokemon can disobey normally based on badges

module MiscMods
  module RemoveDisobedience
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_remove_disobedience)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
end

begin
  if defined?(PokeBattle_Battler) && !PokeBattle_Battler.method_defined?(:miscmods_pbObedienceCheck_original)
    class PokeBattle_Battler
      alias miscmods_pbObedienceCheck_original pbObedienceCheck?
      
      def pbObedienceCheck?(choice)
        # If Remove Disobedience is enabled, always return true (always obey)
        return true if defined?(MiscMods::RemoveDisobedience) && MiscMods::RemoveDisobedience.enabled?
        
        # Otherwise use normal obedience check
        miscmods_pbObedienceCheck_original(choice)
      end
    end
  end
rescue => e
  echoln("Error patching pbObedienceCheck? for Remove Disobedience: #{e}") rescue nil
end

begin
  if defined?(PokeBattle_Battler) && !PokeBattle_Battler.method_defined?(:miscmods_pbDisobey_original)
    class PokeBattle_Battler
      alias miscmods_pbDisobey_original pbDisobey
      
      def pbDisobey(choice, badgeLevel)
        # If Remove Disobedience is enabled, always return true (skip disobedience)
        return true if defined?(MiscMods::RemoveDisobedience) && MiscMods::RemoveDisobedience.enabled?
        
        # Otherwise use normal disobedience behavior
        miscmods_pbDisobey_original(choice, badgeLevel)
      end
    end
  end
rescue => e
  echoln("Error patching pbDisobey for Remove Disobedience: #{e}") rescue nil
end

# ============================================================================
# NO AUTO-EVOLVE MOD
# ============================================================================
# When enabled, prompts the player before evolution instead of evolving automatically

module MiscMods
  module NoAutoEvolve
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_no_auto_evolve)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
  
  module QuickRareCandy
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_quick_rare_candy)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
  
  module InstantHatch
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_instant_hatch)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
  end
  
  module LevelLocking
    DEFAULT_ENABLED = false

    def self.enabled?
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:miscmods_level_locking)
        return setting == 1 || setting == true unless setting.nil?
      end
      return DEFAULT_ENABLED
    end
    
    def self.get_level_lock(pokemon)
      return nil unless pokemon
      return pokemon.instance_variable_get(:@level_lock)
    end
    
    def self.set_level_lock(pokemon, level)
      return unless pokemon
      if level && level > 0 && level <= 100
        pokemon.instance_variable_set(:@level_lock, level)
        pokemon.instance_variable_set(:@level_lock_message_shown, false)
      else
        pokemon.instance_variable_set(:@level_lock, nil)
        pokemon.instance_variable_set(:@level_lock_message_shown, false)
      end
    end
    
    def self.clear_level_lock(pokemon)
      return unless pokemon
      pokemon.instance_variable_set(:@level_lock, nil)
      pokemon.instance_variable_set(:@level_lock_message_shown, false)
    end
    
    def self.is_locked?(pokemon)
      return false unless enabled?
      return false unless pokemon
      level_lock = get_level_lock(pokemon)
      return false unless level_lock
      return pokemon.level >= level_lock
    end
  end
end

begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:can_evolve_manually?)
    class Pokemon
      def can_evolve_manually?
        return false if !@declined_evolutions || @declined_evolutions.empty?
        return @declined_evolutions.length > 0
      end
      
      def evolve_manually
        return nil if !@declined_evolutions || @declined_evolutions.empty?
        
        new_species = @declined_evolutions.first
        
        @declined_evolutions.delete(new_species)
        
        return new_species
      end
      
      def level_lock
        return @level_lock
      end
      
      def level_lock=(value)
        if value && value > 0 && value <= 100
          @level_lock = value
        else
          @level_lock = nil
        end
      end
      
      def has_level_lock?
        return @level_lock && @level_lock > 0
      end
      
      def is_level_locked?
        return false unless has_level_lock?
        return self.level >= @level_lock
      end
    end
  end
rescue => e
  echoln("Error adding Pokemon helper methods: #{e}") rescue nil
end

# ============================================================================
# LEVEL LOCKING MOD
# ============================================================================
# Prevents Pokemon from gaining XP/levels beyond their individual level lock

begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:miscmods_level_locking_level_set)
    class Pokemon
      alias miscmods_level_locking_level_set level=
      
      def level=(value)
        unless defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          return self.miscmods_level_locking_level_set(value)
        end
        
        level_lock = MiscMods::LevelLocking.get_level_lock(self)
        # Only apply lock if Pokemon has one AND would exceed it
        if level_lock && level_lock > 0 && value > level_lock
          value = level_lock
          @level_lock_hit = true
        end
        self.miscmods_level_locking_level_set(value)
      end
    end
  end
rescue => e
  echoln("Error patching level= for Level Locking: #{e}") rescue nil
end

begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:miscmods_level_locking_exp_set)
    class Pokemon
      alias miscmods_level_locking_exp_set exp=
      
      def exp=(value)
        unless defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          return self.miscmods_level_locking_exp_set(value)
        end
        
        level_lock = MiscMods::LevelLocking.get_level_lock(self)
        if level_lock && level_lock > 0 && value && self.level >= level_lock
          begin
            max_exp = growth_rate.minimum_exp_for_level(level_lock + 1) - 1
            if value > max_exp
              value = max_exp
              @level_lock_hit = true
            end
          rescue
            if value > @exp
              value = @exp
              @level_lock_hit = true
            end
          end
        end
        self.miscmods_level_locking_exp_set(value)
      end
    end
  end
rescue => e
  echoln("Error patching exp= for Level Locking: #{e}") rescue nil
end

begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:miscmods_level_locking_change_happiness)
    class Pokemon
      alias miscmods_level_locking_change_happiness changeHappiness
      
      def changeHappiness(method)
        unless defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          return miscmods_level_locking_change_happiness(method)
        end
        
        result = miscmods_level_locking_change_happiness(method)
        
        level_lock = MiscMods::LevelLocking.get_level_lock(self)
        if level_lock && level_lock > 0
          if self.level > level_lock
            self.level = level_lock
            max_exp = growth_rate.minimum_exp_for_level(level_lock + 1) - 1
            @exp = [max_exp, @exp].min
            calc_stats
          end
        end
        
        return result
      end
    end
  end
rescue => e
  echoln("Error patching changeHappiness for Level Locking: #{e}") rescue nil
end

begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:can_gain_exp?)
    class Pokemon
      def can_gain_exp?
        growth_rate = self.growth_rate
        return false if self.exp >= growth_rate.maximum_exp 
        
        if defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          level_lock = MiscMods::LevelLocking.get_level_lock(self)
          if level_lock && level_lock > 0
            if self.level >= level_lock
              max_exp_for_lock = growth_rate.minimum_exp_for_level(level_lock + 1) - 1
              return false if self.exp >= max_exp_for_lock
            end
          end
        end
        
        return true
      end
    end
  end
rescue => e
  echoln("Error adding can_gain_exp? helper: #{e}") rescue nil
end

begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:miscmods_level_locking_calc_stats)
    class Pokemon
      alias miscmods_level_locking_calc_stats calc_stats
      
      def calc_stats(this_level = self.level_simple)
        unless defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          return miscmods_level_locking_calc_stats(this_level)
        end
        
        level_lock = MiscMods::LevelLocking.get_level_lock(self)
        
        if level_lock && level_lock > 0 && this_level > level_lock
          return miscmods_level_locking_calc_stats(this_level) if @_in_calc_stats
          
          @_in_calc_stats = true
          
          begin
            this_level = level_lock
            max_exp = growth_rate.minimum_exp_for_level(level_lock + 1) - 1
            @exp = [max_exp, @exp].min if @exp > max_exp
            
            miscmods_level_locking_calc_stats(this_level)
          ensure
            @_in_calc_stats = false
          end
        else
          miscmods_level_locking_calc_stats(this_level)
        end
      end
    end
  end
rescue => e
  echoln("Error patching calc_stats for Level Locking: #{e}") rescue nil
end

begin
  if defined?(Pokemon) && !Pokemon.method_defined?(:miscmods_level_locking_check_during_gain)
    class Pokemon
      def miscmods_level_locking_check_during_gain(curLevel, growth_rate)
        if defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          level_lock = MiscMods::LevelLocking.get_level_lock(self)
          if level_lock && level_lock > 0 && curLevel >= level_lock
            if @exp >= growth_rate.minimum_exp_for_level(level_lock + 1)
              max_exp_for_lock = growth_rate.minimum_exp_for_level(level_lock + 1) - 1
              @exp = max_exp_for_lock
              return true
            end
          end
        end
        return false
      end
    end
  end
rescue => e
  echoln("Error adding level lock check method: #{e}") rescue nil
end



begin
  if defined?(PokeBattle_Battle) && !PokeBattle_Battle.method_defined?(:miscmods_level_locking_pbGainExpOne)
    class PokeBattle_Battle
      alias miscmods_level_locking_pbGainExpOne pbGainExpOne
      
      def pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages = true)
        pkmn = pbParty(0)[idxParty]
        growth_rate = pkmn.growth_rate
        
        if pkmn.respond_to?(:can_gain_exp?) && !pkmn.can_gain_exp?
          if showMessages && !pkmn.instance_variable_get(:@level_lock_message_shown)
            if defined?(MiscMods::LevelLocking)
              level_lock = MiscMods::LevelLocking.get_level_lock(pkmn)
              if level_lock
                pbDisplayPaused(_INTL("{1} is level locked at Lv.{2}!", pkmn.name, level_lock))
                pkmn.instance_variable_set(:@level_lock_message_shown, true)
              end
            end
          end
          pkmn.calc_stats
          return
        end
        
        if defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          level_lock = MiscMods::LevelLocking.get_level_lock(pkmn)
          if level_lock && level_lock > 0 && pkmn.level >= level_lock
            max_exp_for_lock = growth_rate.minimum_exp_for_level(level_lock + 1) - 1
            if pkmn.exp < max_exp_for_lock
              old_exp = pkmn.exp
              pkmn.exp = max_exp_for_lock
              exp_gained = pkmn.exp - old_exp
              
              if showMessages && exp_gained > 0
                pbDisplayPaused(_INTL("{1} got {2} Exp. Points!", pkmn.name, exp_gained))
              end
              
              battler = pbFindBattler(idxParty)
              if battler
                levelMinExp = growth_rate.minimum_exp_for_level(level_lock)
                levelMaxExp = growth_rate.minimum_exp_for_level(level_lock + 1)
                @scene.pbEXPBar(battler, levelMinExp, levelMaxExp, old_exp, pkmn.exp)
                @scene.pbRefreshOne(battler.index)
              end
              
              pkmn.calc_stats
            end
            
            if showMessages && !pkmn.instance_variable_get(:@level_lock_message_shown)
              pbDisplayPaused(_INTL("{1} is level locked at Lv.{2}!", pkmn.name, level_lock))
              pkmn.instance_variable_set(:@level_lock_message_shown, true)
            end
            return
          end
        end
        
        miscmods_level_locking_pbGainExpOne(idxParty, defeatedBattler, numPartic, expShare, expAll, showMessages)
        
        if defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
          level_lock = MiscMods::LevelLocking.get_level_lock(pkmn)
          if level_lock && level_lock > 0 && pkmn.level >= level_lock
            if showMessages && !pkmn.instance_variable_get(:@level_lock_message_shown)
              pbDisplayPaused(_INTL("{1} is level locked at Lv.{2}!", pkmn.name, level_lock))
              pkmn.instance_variable_set(:@level_lock_message_shown, true)
            end
          end
        end
      end
    end
  end
rescue => e
  echoln("Error patching pbGainExpOne for Level Locking: #{e}") rescue nil
end

# ============================================================================
# LEVEL LOCK MANAGER
# ============================================================================
# Allows setting individual level caps for each Pokemon in the party

def qa_level_lock_manager
  return unless $Trainer && $Trainer.party && $Trainer.party.length > 0
  
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $Trainer.party)
    screen.pbStartScene(_INTL("Choose a Pokémon."), false)
    loop do
      chosen = screen.pbChoosePokemon
      break if chosen < 0
      
      pkmn = $Trainer.party[chosen]
      if pkmn.egg?
        pbMessage(_INTL("Eggs can't have level locks!"))
        next
      end
      
      current_lock = MiscMods::LevelLocking.get_level_lock(pkmn)
      
      commands = []
      if current_lock
        commands << _INTL("Current Lock: Level {1}", current_lock)
        commands << _INTL("Change Level Lock")
        commands << _INTL("Remove Level Lock")
      else
        commands << _INTL("No Level Lock Set")
        commands << _INTL("Set Level Lock")
      end
      commands << _INTL("Cancel")
      
      cmdwindow = Window_CommandPokemonEx.new(commands)
      cmdwindow.z = 99999
      cmdwindow.visible = true
      cmdwindow.resizeToFit(cmdwindow.commands)
      pbPositionNearMsgWindow(cmdwindow, nil, :right)
      
      choice = -1
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          break
        end
        
        if Input.trigger?(Input::USE)
          choice = cmdwindow.index
          pbPlayDecisionSE
          break
        end
      end
      
      cmdwindow.dispose
      
      if choice >= 0
        if current_lock
          case choice
          when 0 # Info display
            next
          when 1 # Change level lock
            params = ChooseNumberParams.new
            params.setRange(pkmn.level, 100)
            params.setDefaultValue(current_lock)
            new_lock = pbMessageChooseNumber(_INTL("Set level lock (current level: {1})", pkmn.level), params)
            if new_lock && new_lock >= pkmn.level
              MiscMods::LevelLocking.set_level_lock(pkmn, new_lock)
              pbMessage(_INTL("{1}'s level lock set to {2}!", pkmn.name, new_lock))
            end
          when 2 # Remove level lock
            if pbConfirmMessage(_INTL("Remove {1}'s level lock?", pkmn.name))
              MiscMods::LevelLocking.clear_level_lock(pkmn)
              pbMessage(_INTL("{1}'s level lock removed!", pkmn.name))
            end
          when 3 # Cancel
            next
          end
        else
          case choice
          when 0 # Info display
            next
          when 1 # Set level lock
            params = ChooseNumberParams.new
            params.setRange(pkmn.level, 100)
            params.setDefaultValue(pkmn.level)
            new_lock = pbMessageChooseNumber(_INTL("Set level lock (current level: {1})", pkmn.level), params)
            if new_lock && new_lock >= pkmn.level
              MiscMods::LevelLocking.set_level_lock(pkmn, new_lock)
              pbMessage(_INTL("{1}'s level lock set to {2}!", pkmn.name, new_lock))
            end
          when 2 # Cancel
            next
          end
        end
      end
    end
    screen.pbEndScene
  }
end

# ============================================================================
# SUPER CANDY FUNCTIONALITY
# ============================================================================
# Level all party Pokémon based on selected mode

def qa_super_candy_party
  return unless $Trainer && $Trainer.party
  
  # Determine target level based on mode
  candy_mode = ModSettingsMenu.get(:miscmods_super_candy_mode) rescue 0
  target_level = nil
  
  case candy_mode.to_i
  when 0  # Level Cap mode
    begin
      if defined?(getkuraylevelcap)
        target_level = getkuraylevelcap()
      end
    rescue
    end
    
    begin
      if !target_level && defined?(Settings) && Settings.respond_to?(:level_cap)
        target_level = Settings.level_cap
      end
    rescue
    end
    
    begin
      if !target_level && defined?($game_variables) && $game_variables
        [100, 101, 102, 103, 104].each do |var_id|
          val = $game_variables[var_id] rescue nil
          if val && val.is_a?(Integer) && val > 0 && val <= 100
            target_level = val
            break
          end
        end
      end
    rescue
    end
    
    if !target_level
      begin
        badges = $Trainer.badge_count rescue 0
        target_level = [badges * 10 + 10, 100].min
      rescue
        target_level = 100
      end
    end
    
  when 1  # Highest Level mode
    target_level = 1
    $Trainer.party.each do |pkmn|
      next if !pkmn || pkmn.egg?
      target_level = pkmn.level if pkmn.level > target_level
    end
    
  when 2  # Set Level mode
    target_level = ModSettingsMenu.get(:miscmods_super_candy_level) rescue 50
    
  else  # Default to level cap
    target_level = 100
  end
  
  target_level = 100 if !target_level || target_level <= 0 || target_level > 100
  
  mode_text = case candy_mode.to_i
    when 0 then "level cap (#{target_level})"
    when 1 then "highest level (#{target_level})"
    when 2 then "set level (#{target_level})"
    else "level #{target_level}"
  end
  mode_text = case candy_mode.to_i
    when 0 then "level cap (#{target_level})"
    when 1 then "highest level (#{target_level})"
    when 2 then "set level (#{target_level})"
    else "level #{target_level}"
  end
  
  if pbConfirmMessage(_INTL("Level all party Pokémon to {1}?", mode_text))
    leveled_count = 0
    locked_count = 0
    level_locking_enabled = defined?(MiscMods::LevelLocking) && MiscMods::LevelLocking.enabled?
    
    # Store original level locking state and temporarily disable it
    original_locking_setting = nil
    if defined?(ModSettingsMenu)
      original_locking_setting = ModSettingsMenu.get(:miscmods_level_locking)
      ModSettingsMenu.set(:miscmods_level_locking, 0)
    end
    
    begin
      $Trainer.party.each do |pkmn|
        next if !pkmn || pkmn.egg?
        
        # Determine the actual level for this specific Pokemon
        pkmn_target = target_level
        hit_lock = false
        
        # Check for individual level lock on this Pokemon
        if level_locking_enabled
          level_lock = MiscMods::LevelLocking.get_level_lock(pkmn)
          if level_lock && level_lock > 0
            # Use the LOWER of target or level lock
            if level_lock < target_level
              pkmn_target = level_lock
              hit_lock = true
            else
              pkmn_target = target_level
            end
          end
        end
        
        # Skip if already at or above target
        next if pkmn.level >= pkmn_target
        
        old_level = pkmn.level
        
        # Set level normally since locking is temporarily disabled
        pkmn.level = pkmn_target
        pkmn.exp = pkmn.growth_rate.minimum_exp_for_level(pkmn_target)
        pkmn.calc_stats
        
        # Learn moves for all levels between old and new
        movelist = pkmn.getMoveList
        (old_level + 1).upto(pkmn_target) do |lv|
          movelist.each do |learn_move|
            next if learn_move[0] != lv
            move_id = learn_move[1]
            next if pkmn.hasMove?(move_id)
            
            if pkmn.numMoves < 4
              pkmn.learn_move(move_id)
            end
          end
        end
        
        leveled_count += 1
        locked_count += 1 if hit_lock
      end
    ensure
      # Restore original level locking state
      if defined?(ModSettingsMenu) && !original_locking_setting.nil?
        ModSettingsMenu.set(:miscmods_level_locking, original_locking_setting)
      end
    end
    
    if locked_count > 0
      pbMessage(_INTL("{1} Pokémon leveled! ({2} stopped at level lock)", leveled_count, locked_count))
    else
      pbMessage(_INTL("{1} Pokémon leveled to {2}!", leveled_count, target_level))
    end
    
    $Trainer.party.each do |pkmn|
      next if !pkmn || pkmn.egg?
      
      species_data = GameData::Species.get(pkmn.species)
      evolutions = species_data.get_evolutions rescue []
      next if evolutions.empty?
      
      evolutions.each do |evo|
        evo_species = evo[0]
        evo_method = evo[1]
        evo_param = evo[2]
        
        can_evolve = false
        
        case evo_method
        when :Level, :LevelMale, :LevelFemale
          can_evolve = true if pkmn.level >= evo_param
        when :Happiness, :HappinessMale, :HappinessFemale
          can_evolve = true if pkmn.happiness >= 220
        when :MaxHappiness
          can_evolve = true if pkmn.happiness >= 255
        when :Beauty
          can_evolve = true if pkmn.beauty >= evo_param
        when :AttackGreater
          can_evolve = true if pkmn.attack > pkmn.defense
        when :DefenseGreater
          can_evolve = true if pkmn.defense > pkmn.attack
        when :AtkDefEqual
          can_evolve = true if pkmn.attack == pkmn.defense
        else
          can_evolve = false
        end
        
        if can_evolve
          evo_name = GameData::Species.get(evo_species).name rescue evo_species.to_s
          
          if pbConfirmMessage(_INTL("{1} can evolve into {2}! Evolve now?", pkmn.name, evo_name))
            old_species = pkmn.species
            
            pbFadeOutInWithMusic {
              evo = PokemonEvolutionScene.new
              evo.pbStartScreen(pkmn, evo_species)
              evo.pbEvolution
              evo.pbEndScreen
            }
            
            if pkmn.species == old_species
              pkmn.instance_variable_set(:@declined_evolutions, []) if !pkmn.instance_variable_get(:@declined_evolutions)
              declined = pkmn.instance_variable_get(:@declined_evolutions)
              if !declined.include?(evo_species)
                declined << evo_species
              end
            end
          else
            pkmn.instance_variable_set(:@declined_evolutions, []) if !pkmn.instance_variable_get(:@declined_evolutions)
            declined = pkmn.instance_variable_get(:@declined_evolutions)
            if !declined.include?(evo_species)
              declined << evo_species
            end
          end
          break 
        end
      end
    end
  end
rescue => e
  echoln("Error patching calc_stats for Level Locking: #{e}") rescue nil
end

# ============================================================================
# NATURE SELECTOR FUNCTIONALITY
# ============================================================================
# Allows changing the nature of any Pokemon in the party

def qa_nature_selector
  return unless $Trainer && $Trainer.party && $Trainer.party.length > 0
  
  pbFadeOutIn {
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $Trainer.party)
    screen.pbStartScene(_INTL("Choose a Pokémon."), false)
    loop do
      chosen = screen.pbChoosePokemon
      break if chosen < 0
      
      pkmn = $Trainer.party[chosen]
      if pkmn.egg?
        pbMessage(_INTL("Eggs don't have natures!"))
        next
      end
      
      nature_data = []
      GameData::Nature.each do |nature|
        display_name = nature.name
        increased_stat_id = nil
        if nature.stat_changes && nature.stat_changes.length > 0
          increased_stat = nil
          decreased_stat = nil
          nature.stat_changes.each do |stat_change|
            stat_id = stat_change[0]
            change_value = stat_change[1]
            stat_abbrev = case stat_id
              when :ATTACK then "Atk"
              when :DEFENSE then "Def"
              when :SPECIAL_ATTACK then "SpAtk"
              when :SPECIAL_DEFENSE then "SpDef"
              when :SPEED then "Spd"
              else stat_id.to_s
            end
            if change_value > 0
              increased_stat = stat_abbrev
              increased_stat_id = stat_id
            elsif change_value < 0
              decreased_stat = stat_abbrev
            end
          end
          if increased_stat && decreased_stat
            display_name = "#{nature.name} ( #{increased_stat} + / #{decreased_stat} - )"
          end
        else
          display_name = "#{nature.name} ( Neutral )"
        end
        nature_data << [display_name, nature.id, increased_stat_id]
      end
      
      stat_order = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
      nature_data.sort! do |a, b|
        stat_a = a[2]
        stat_b = b[2]
        
        if stat_a.nil? && stat_b.nil?
          a[0] <=> b[0] 
        elsif stat_a.nil?
          1 
        elsif stat_b.nil?
          -1 
        else
          index_a = stat_order.index(stat_a) || 999
          index_b = stat_order.index(stat_b) || 999
          if index_a == index_b
            a[0] <=> b[0] 
          else
            index_a <=> index_b
          end
        end
      end
      
      nature_list = nature_data.map { |n| n[0] }
      nature_ids = nature_data.map { |n| n[1] }
      
      current_nature_display = pkmn.nature.name
      if pkmn.nature.stat_changes && pkmn.nature.stat_changes.length > 0
        increased = nil
        decreased = nil
        pkmn.nature.stat_changes.each do |sc|
          stat_abbrev = case sc[0]
            when :ATTACK then "Atk"
            when :DEFENSE then "Def"
            when :SPECIAL_ATTACK then "SpAtk"
            when :SPECIAL_DEFENSE then "SpDef"
            when :SPEED then "Spd"
            else sc[0].to_s
          end
          if sc[1] > 0
            increased = stat_abbrev
          elsif sc[1] < 0
            decreased = stat_abbrev
          end
        end
        current_nature_display = "#{pkmn.nature.name} (#{increased} + / #{decreased} -)" if increased && decreased
      else
        current_nature_display = "#{pkmn.nature.name} (Neutral)"
      end
      pbMessage(_INTL("Current nature: {1}", current_nature_display))
      
      cmdwindow = Window_CommandPokemonEx.new(nature_list + [_INTL("Cancel")])
      cmdwindow.z = 99999
      cmdwindow.visible = true
      cmdwindow.resizeToFit(cmdwindow.commands)
      cmdwindow.height = Graphics.height if cmdwindow.height > Graphics.height
      pbPositionNearMsgWindow(cmdwindow, nil, :right)
      
      current_index = nature_ids.index(pkmn.nature_id)
      cmdwindow.index = current_index if current_index
      
      nature_choice = -1
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          break
        end
        
        if Input.trigger?(Input::USE)
          if cmdwindow.index == nature_list.length 
            pbPlayCancelSE
            break
          else
            nature_choice = cmdwindow.index
            pbPlayDecisionSE
            break
          end
        end
      end
      
      cmdwindow.dispose
      
      if nature_choice >= 0
        old_nature = pkmn.nature.name
        new_nature_id = nature_ids[nature_choice]
        new_nature = GameData::Nature.get(new_nature_id)
        
        pkmn.nature = new_nature_id
        
        # calc_stats handles HP preservation automatically (including BST boost)
        pkmn.calc_stats
        
        pbMessage(_INTL("{1}'s nature changed from {2} to {3}!", pkmn.name, old_nature, new_nature.name))
        screen.pbRefreshSingle(chosen)
      end
    end
    screen.pbEndScene
  }
end

#===============================================================================
# Party Menu Override with Relearn Moves and Evolve Options
#===============================================================================

begin
  if defined?(PokemonPartyScreen) && !PokemonPartyScreen.method_defined?(:pbPokemonScreen_qa_override)
    class PokemonPartyScreen
      alias pbPokemonScreen_qa_override pbPokemonScreen
    
    def pbPokemonScreen
      @scene.pbStartScene(@party,
                          (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
      loop do
        @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
        pkmnid = @scene.pbChoosePokemon(false, -1)
        break if (pkmnid.is_a?(Numeric) && pkmnid < 0) || (pkmnid.is_a?(Array) && pkmnid[1] < 0)
        if pkmnid.is_a?(Array) && pkmnid[0] == 1 
          @scene.pbSetHelpText(_INTL("Move to where?"))
          oldpkmnid = pkmnid[1]
          pkmnid = @scene.pbChoosePokemon(true, -1, 2)
          if pkmnid >= 0 && pkmnid != oldpkmnid
            pbSwitch(oldpkmnid, pkmnid)
          end
          next
        end
        pkmn = @party[pkmnid]
        commands = []
        cmdSummary = -1
        cmdNickname = -1
        cmdMoves = [-1] * pkmn.numMoves
        cmdSwitch = -1
        cmdMail = -1
        cmdItem = -1
        cmdRelearn = -1
        cmdFaint = -1
        cmdEvolve = -1
        cmdLevelLock = -1
        cmdFollow = -1
        cmdPutAway = -1

        commands[cmdSummary = commands.length] = _INTL("Summary")
        if !pkmn.egg?
          pkmn.moves.each_with_index do |m, i|
            if [:MILKDRINK, :SOFTBOILED].include?(m.id) ||
              HiddenMoveHandlers.hasHandler(m.id)
              commands[cmdMoves[i] = commands.length] = [m.name, 1]
            end
          end
        end
        commands[cmdSwitch = commands.length] = _INTL("Switch") if @party.length > 1
        
        relearn_enabled = false
        if defined?(ModSettingsMenu)
          setting = ModSettingsMenu.get(:miscmods_relearn_moves)
          relearn_enabled = (setting == 1 || setting == true)
        end
        if relearn_enabled && !pkmn.egg? && defined?(pbRelearnMoveScreen)
          commands[cmdRelearn = commands.length] = _INTL("Relearn Moves")
        end
        
        if !pkmn.egg? && pkmn.hp > 0 && defined?(nuzlocke_manual_faint)
          commands[cmdFaint = commands.length] = _INTL("Faint Pokemon")
        end
        
        if !pkmn.egg? && pkmn.respond_to?(:can_evolve_manually?) && pkmn.can_evolve_manually?
          commands[cmdEvolve = commands.length] = _INTL("Evolve")
        end
        
        level_lock_enabled = false
        if defined?(ModSettingsMenu)
          setting = ModSettingsMenu.get(:miscmods_level_locking)
          level_lock_enabled = (setting == 1 || setting == true)
        end
        if level_lock_enabled && !pkmn.egg?
          level_lock = MiscMods::LevelLocking.get_level_lock(pkmn)
          if level_lock
            commands[cmdLevelLock = commands.length] = _INTL("Level Lock: {1}", level_lock)
          else
            commands[cmdLevelLock = commands.length] = _INTL("Set Level Lock")
          end
        end
        
        # Add Follow/Put Away options for non-eggs if Follower System is present
        if !pkmn.egg? && defined?(create_follower)
          # Check if ANY follower is active
          follower_active = false
          current_follower_index = nil
          
          # Check $Follower.event first
          if defined?($Follower) && $Follower && $Follower.respond_to?(:event) && $Follower.event
            follower_active = true
            current_follower_index = $Follower.respond_to?(:follower_index) ? $Follower.follower_index : nil
          end
          
          # Also check global flag as backup
          if !follower_active && defined?($PokemonGlobal) && $PokemonGlobal
            follower_active = ($PokemonGlobal.instance_variable_get(:@followerActive) rescue false)
            current_follower_index = ($PokemonGlobal.instance_variable_get(:@followerIndex) rescue nil) if follower_active
          end
          
          # Show appropriate command
          if follower_active && current_follower_index == pkmnid
            commands[cmdPutAway = commands.length] = _INTL("Put Away")
          else
            # Show Follow command if no follower active OR if a different Pokemon is following
            commands[cmdFollow = commands.length] = _INTL("Follow")
          end
        end
        
        if !pkmn.egg?
          if pkmn.mail
            commands[cmdMail = commands.length] = _INTL("Mail")
          else
            commands[cmdItem = commands.length] = _INTL("Item")
          end
        end
        commands[cmdNickname = commands.length] = _INTL("Nickname") if !pkmn.egg?
        commands[commands.length] = _INTL("Cancel")
        command = @scene.pbShowCommands(_INTL("Do what with {1}?", pkmn.name), commands)
        havecommand = false
        
        if cmdFaint >= 0 && command == cmdFaint
          if pbConfirm(_INTL("Are you sure you want to faint {1}?", pkmn.name))
            if defined?(nuzlocke_manual_faint) && nuzlocke_manual_faint(pkmn)
              mode = nuzlocke_on_faint_mode
              case mode
              when 1
                pbDisplay(_INTL("{1} has fainted and will be sent to the PC!", pkmn.name))
              when 2
                pbDisplay(_INTL("{1} has fainted and will be released!", pkmn.name))
              else
                pbDisplay(_INTL("{1} has fainted.", pkmn.name))
              end
              dead_indexes, dead_names = nuzlocke_collect_fainted_party
              case mode
              when 1
                nuzlocke_move_fainted_to_pc(dead_indexes, dead_names)
              when 2
                nuzlocke_release_fainted(dead_indexes, dead_names)
              end
              $nuzlocke_fainted_pokemon = []
              pbRefresh
              break
            end
          end
          next
        end

        if cmdRelearn >= 0 && command == cmdRelearn
          if defined?(pbRelearnMoveScreen)
            if defined?(MoveRelearnerScreen)
              begin
                scene = MoveRelearnerScene.new
                screen = MoveRelearnerScreen.new(scene)
                screen.pbStartScene(pkmn)
              rescue
                pbRelearnMoveScreen(pkmn)
              end
            else
              pbRelearnMoveScreen(pkmn)
            end
            pbRefresh
          end
          next
        end
        
        if cmdLevelLock >= 0 && command == cmdLevelLock
          current_lock = MiscMods::LevelLocking.get_level_lock(pkmn)
          
          if current_lock
            lock_commands = [
              _INTL("Change Level Lock"),
              _INTL("Remove Level Lock"),
              _INTL("Cancel")
            ]
            lock_choice = pbMessage(_INTL("Current level lock: {1}", current_lock), lock_commands, -1)
            
            if lock_choice == 0 # Change
              params = ChooseNumberParams.new
              params.setRange(pkmn.level, 100)
              params.setDefaultValue(current_lock)
              new_lock = pbMessageChooseNumber(_INTL("Set level lock (current level: {1})", pkmn.level), params)
              if new_lock && new_lock >= pkmn.level
                MiscMods::LevelLocking.set_level_lock(pkmn, new_lock)
                pbMessage(_INTL("{1}'s level lock changed to {2}!", pkmn.name, new_lock))
              end
            elsif lock_choice == 1 # Remove
              if pbConfirmMessage(_INTL("Remove {1}'s level lock?", pkmn.name))
                MiscMods::LevelLocking.clear_level_lock(pkmn)
                pbMessage(_INTL("{1}'s level lock removed!", pkmn.name))
              end
            end
          else
            params = ChooseNumberParams.new
            params.setRange(pkmn.level, 100)
            params.setDefaultValue(pkmn.level)
            new_lock = pbMessageChooseNumber(_INTL("Set level lock (current level: {1})", pkmn.level), params)
            if new_lock && new_lock >= pkmn.level
              MiscMods::LevelLocking.set_level_lock(pkmn, new_lock)
              pbMessage(_INTL("{1}'s level lock set to {2}!", pkmn.name, new_lock))
            end
          end
          next
        end
        
        if cmdEvolve >= 0 && command == cmdEvolve
          if pkmn.respond_to?(:evolve_manually)
            new_species = pkmn.evolve_manually
            if new_species
              evo_name = GameData::Species.get(new_species).name rescue new_species.to_s
              
              if pbConfirm(_INTL("Evolve {1} into {2}?", pkmn.name, evo_name))
                old_species = pkmn.species
                
                @scene.pbEndScene
                
                pbFadeOutInWithMusic {
                  evo = PokemonEvolutionScene.new
                  evo.pbStartScreen(pkmn, new_species)
                  evo.pbEvolution
                  evo.pbEndScreen
                }
                
                if pkmn.species == old_species
                  pkmn.instance_variable_set(:@declined_evolutions, []) if !pkmn.instance_variable_get(:@declined_evolutions)
                  declined = pkmn.instance_variable_get(:@declined_evolutions)
                  declined << new_species if !declined.include?(new_species)
                end
                
                @scene.pbStartScene(@party,
                                    (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
                pbRefresh
              else
                pkmn.instance_variable_set(:@declined_evolutions, []) if !pkmn.instance_variable_get(:@declined_evolutions)
                declined = pkmn.instance_variable_get(:@declined_evolutions)
                declined << new_species if !declined.include?(new_species)
              end
            else
              pbDisplay(_INTL("{1} cannot evolve right now.", pkmn.name))
            end
          end
          next
        end
        
        # Handle Follow command
        if cmdFollow >= 0 && command == cmdFollow
          if defined?(create_follower)
            create_follower(pkmnid)
            pbDisplay(_INTL("{1} is now following you!", pkmn.name))
          end
          next
        end
        
        # Handle Put Away command
        if cmdPutAway >= 0 && command == cmdPutAway
          if defined?($Follower) && $Follower
            $Follower.clear_follower if $Follower.respond_to?(:clear_follower)
            pbDisplay(_INTL("{1} returned!", pkmn.name))
          end
          next
        end
        
        cmdMoves.each_with_index do |cmd, i|
          next if cmd < 0 || cmd != command
          havecommand = true
          if [:MILKDRINK, :SOFTBOILED].include?(pkmn.moves[i].id)
            amt = [(pkmn.totalhp / 5).floor, 1].max
            if pkmn.hp <= amt
              pbDisplay(_INTL("Not enough HP..."))
              break
            end
            @scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
            oldpkmnid = pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid = @scene.pbChoosePokemon(true, pkmnid)
              break if pkmnid < 0
              newpkmn = @party[pkmnid]
              movename = pkmn.moves[i].name
              if pkmnid == oldpkmnid
                pbDisplay(_INTL("{1} can't use {2} on itself!", pkmn.name, movename))
              elsif newpkmn.egg?
                pbDisplay(_INTL("{1} can't be used on an Egg!", movename))
              elsif newpkmn.hp == 0 || newpkmn.hp == newpkmn.totalhp
                pbDisplay(_INTL("{1} can't be used on that Pokémon.", movename))
              else
                pkmn.hp -= amt
                hpgain = pbItemRestoreHP(newpkmn, amt)
                @scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.", newpkmn.name, hpgain))
                pbRefresh
              end
              break if pkmn.hp <= amt
            end
            @scene.pbSelect(oldpkmnid)
            pbRefresh
            break
          elsif pbCanUseHiddenMove?(pkmn, pkmn.moves[i].id)
            if pbConfirmUseHiddenMove(pkmn, pkmn.moves[i].id)
              @scene.pbEndScene
              if pkmn.moves[i].id == :FLY || pkmn.moves[i].id == :TELEPORT
                ret = pbBetterRegionMap(-1, true, true)
                if ret
                  $PokemonTemp.flydata = ret
                  return [pkmn, pkmn.moves[i].id]
                end
                @scene.pbStartScene(@party,
                                    (@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
                break
              end
              return [pkmn, pkmn.moves[i].id]
            end
          end
        end
        next if havecommand
        if cmdSummary >= 0 && command == cmdSummary
          @scene.pbSummary(pkmnid) {
            @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
          }
        elsif cmdSwitch >= 0 && command == cmdSwitch
          @scene.pbSetHelpText(_INTL("Move to where?"))
          oldpkmnid = pkmnid
          pkmnid = @scene.pbChoosePokemon(true, -1, 2)
          if pkmnid >= 0 && pkmnid != oldpkmnid
            pbSwitch(oldpkmnid, pkmnid)
          end
        elsif cmdItem >= 0 && command == cmdItem
          itemcommands = []
          cmdUseItem  = -1
          cmdGiveItem = -1
          cmdTakeItem = -1
          cmdMoveItem = -1
          itemcommands[cmdUseItem  = itemcommands.length] = _INTL("Use")
          itemcommands[cmdGiveItem = itemcommands.length] = _INTL("Give")
          itemcommands[cmdTakeItem = itemcommands.length] = _INTL("Take") if pkmn.hasItem?
          itemcommands[cmdMoveItem = itemcommands.length] = _INTL("Move") if pkmn.hasItem? &&
            !GameData::Item.get(pkmn.item).is_mail?
          itemcommands[itemcommands.length] = _INTL("Cancel")
          subcmd = @scene.pbShowCommands(_INTL("Do what with an item?"), itemcommands)
          if cmdUseItem >= 0 && subcmd == cmdUseItem # Use
            item = @scene.pbUseItem($PokemonBag, pkmn) {
              @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
            }
            if item
              pbUseItemOnPokemon(item, pkmn, self)
              pbRefreshSingle(pkmnid) if respond_to?(:pbRefreshSingle)
              pbRefresh if !respond_to?(:pbRefreshSingle)
            end
          elsif cmdGiveItem >= 0 && subcmd == cmdGiveItem # Give
            item = @scene.pbChooseItem($PokemonBag) {
              @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
            }
            if item
              if pbGiveItemToPokemon(item, pkmn, self, pkmnid)
                pbRefreshSingle(pkmnid) if respond_to?(:pbRefreshSingle)
                pbRefresh if !respond_to?(:pbRefreshSingle)
              end
            end
          elsif cmdTakeItem >= 0 && subcmd == cmdTakeItem # Take
            if pbTakeItemFromPokemon(pkmn, self)
              pbRefreshSingle(pkmnid) if respond_to?(:pbRefreshSingle)
              pbRefresh if !respond_to?(:pbRefreshSingle)
            end
          elsif cmdMoveItem >= 0 && subcmd == cmdMoveItem # Move
            item = pkmn.item
            itemname = item.name
            @scene.pbSetHelpText(_INTL("Move {1} to where?", itemname))
            oldpkmnid = pkmnid
            loop do
              @scene.pbPreSelect(oldpkmnid)
              pkmnid = @scene.pbChoosePokemon(true, pkmnid)
              break if pkmnid < 0
              newpkmn = @party[pkmnid]
              break if pkmnid == oldpkmnid
              if newpkmn.egg?
                pbDisplay(_INTL("Eggs can't hold items."))
              elsif !newpkmn.hasItem?
                newpkmn.item = item
                pkmn.item = nil
                @scene.pbClearSwitching
                pbRefresh
                pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
                break
              elsif GameData::Item.get(newpkmn.item).is_mail?
                pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.", newpkmn.name))
              else
                newitem = newpkmn.item
                newitemname = newitem.name
                if newitem == :LEFTOVERS
                  pbDisplay(_INTL("{1} is already holding some {2}.\1", newpkmn.name, newitemname))
                elsif newitemname.starts_with_vowel?
                  pbDisplay(_INTL("{1} is already holding an {2}.\1", newpkmn.name, newitemname))
                else
                  pbDisplay(_INTL("{1} is already holding a {2}.\1", newpkmn.name, newitemname))
                end
                if pbConfirm(_INTL("Would you like to switch the two items?"))
                  newpkmn.item = item
                  pkmn.item = newitem
                  @scene.pbClearSwitching
                  pbRefresh
                  pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
                  pbDisplay(_INTL("{1} was given the {2} to hold.", pkmn.name, newitemname))
                  break
                end
              end
            end
            @scene.pbSelect(oldpkmnid)
            pbRefresh
          end
        elsif cmdMail >= 0 && command == cmdMail
          command = @scene.pbShowCommands(_INTL("Do what with the mail?"),
                                          [_INTL("Read"), _INTL("Take"), _INTL("Cancel")])
          case command
          when 0   # Read
            pbFadeOutIn {
              pbDisplayMail(pkmn.mail, pkmn)
            }
          when 1   # Take
            pbTakeMail(pkmn)
            pbRefresh
          end
        elsif cmdNickname >= 0 && command == cmdNickname
          nickname = pbEnterPokemonName(_INTL("{1}'s nickname?", pkmn.speciesName),
                                        0, Pokemon::MAX_NAME_SIZE, "", pkmn, true)
          pkmn.name = nickname
          pbRefresh
        end
      end
      @scene.pbEndScene
      return nil
    end
  end
  end
rescue => e
  echoln("Error overriding PokemonPartyScreen: #{e}") rescue nil
end

begin
  if !Object.private_method_defined?(:miscmods_no_auto_evolve_pbChangeLevel)
    class Object
      alias_method :miscmods_no_auto_evolve_pbChangeLevel, :pbChangeLevel
      private :miscmods_no_auto_evolve_pbChangeLevel rescue nil
      
      def pbChangeLevel(pkmn, newlevel, scene)
        quick_mode = defined?(MiscMods::QuickRareCandy) && MiscMods::QuickRareCandy.enabled?
        
        if quick_mode
          old_level = pkmn.level
          
          pkmn.level = newlevel
          pkmn.calc_stats
          pkmn.exp = pkmn.growth_rate.minimum_exp_for_level(newlevel)
          
          movelist = pkmn.getMoveList
          movelist.each do |learn_move|
            next unless learn_move[0] > old_level && learn_move[0] <= newlevel
            move_id = learn_move[1]
            next if pkmn.hasMove?(move_id)
            
            pbLearnMove(pkmn, move_id, false, false, true)
          end
          
          scene.pbRefresh if scene && scene.respond_to?(:pbRefresh)
          
          if pkmn.level == newlevel && newlevel > 1
            newspecies = pkmn.check_evolution_on_level_up
            if newspecies
              if defined?(MiscMods::NoAutoEvolve) && MiscMods::NoAutoEvolve.enabled?
                pkmn.instance_variable_set(:@declined_evolutions, []) if !pkmn.instance_variable_get(:@declined_evolutions)
                declined = pkmn.instance_variable_get(:@declined_evolutions)
                if !declined.include?(newspecies)
                  evo_name = GameData::Species.get(newspecies).name rescue newspecies.to_s
                  
                  if pbConfirmMessage(_INTL("{1} can now evolve to {2}! Evolve now?", pkmn.name, evo_name))
                    old_species = pkmn.species
                    
                    pbFadeOutInWithMusic {
                      evo = PokemonEvolutionScene.new
                      evo.pbStartScreen(pkmn, newspecies)
                      evo.pbEvolution
                      evo.pbEndScreen
                      scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
                    }
                    
                    if pkmn.species == old_species
                      declined << newspecies
                    end
                  else
                    declined << newspecies
                  end
                end
              else
                pbFadeOutInWithMusic {
                  evo = PokemonEvolutionScene.new
                  evo.pbStartScreen(pkmn, newspecies)
                  evo.pbEvolution
                  evo.pbEndScreen
                  scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
                }
              end
            end
          end
          
          return
        end
        
        unless defined?(MiscMods::NoAutoEvolve) && MiscMods::NoAutoEvolve.enabled?
          return miscmods_no_auto_evolve_pbChangeLevel(pkmn, newlevel, scene)
        end
        
        old_kuray_setting = nil
        old_system_setting = nil
        if pkmn.respond_to?(:kuray_no_evo?)
          old_kuray_setting = pkmn.kuray_no_evo?
          pkmn.instance_variable_set(:@kuray_no_evo, 1) if pkmn.instance_variable_defined?(:@kuray_no_evo)
        end
        if $PokemonSystem && $PokemonSystem.respond_to?(:kuray_no_evo)
          old_system_setting = $PokemonSystem.kuray_no_evo
          $PokemonSystem.kuray_no_evo = 1
        end
        
        miscmods_no_auto_evolve_pbChangeLevel(pkmn, newlevel, scene)
        
        if old_kuray_setting
          pkmn.instance_variable_set(:@kuray_no_evo, old_kuray_setting) if pkmn.instance_variable_defined?(:@kuray_no_evo)
        end
        if old_system_setting
          $PokemonSystem.kuray_no_evo = old_system_setting
        end
        
        if pkmn.level == newlevel && newlevel > 1
          newspecies = pkmn.check_evolution_on_level_up
          if newspecies
            pkmn.instance_variable_set(:@declined_evolutions, []) if !pkmn.instance_variable_get(:@declined_evolutions)
            declined = pkmn.instance_variable_get(:@declined_evolutions)
            if !declined.include?(newspecies)
              evo_name = GameData::Species.get(newspecies).name rescue newspecies.to_s
              
              if pbConfirmMessage(_INTL("{1} can now evolve to {2}! Evolve now?", pkmn.name, evo_name))
                old_species = pkmn.species
                
                pbFadeOutInWithMusic {
                  evo = PokemonEvolutionScene.new
                  evo.pbStartScreen(pkmn, newspecies)
                  evo.pbEvolution
                  evo.pbEndScreen
                  scene.pbRefresh if scene.is_a?(PokemonPartyScreen)
                }
                
                if pkmn.species == old_species
                  declined << newspecies
                end
              else
                declined << newspecies
              end
            end
          end
        end
      end
      private :pbChangeLevel
    end
  end
rescue => e
  echoln("Error patching pbChangeLevel: #{e}") rescue nil
end

begin
  if !Object.private_method_defined?(:miscmods_no_auto_evolve_pbEvolutionCheck)
    class Object
      alias_method :miscmods_no_auto_evolve_pbEvolutionCheck, :pbEvolutionCheck
      private :miscmods_no_auto_evolve_pbEvolutionCheck rescue nil
      
      def pbEvolutionCheck(currentLevels, scene = nil)
        unless defined?(MiscMods::NoAutoEvolve) && MiscMods::NoAutoEvolve.enabled?
          return miscmods_no_auto_evolve_pbEvolutionCheck(currentLevels, scene)
        end
        
        for i in 0...currentLevels.length
          pkmn = $Trainer.party[i]
          next if !pkmn || (pkmn.hp==0 && !Settings::CHECK_EVOLUTION_FOR_FAINTED_POKEMON)
          next if currentLevels[i] && pkmn.level==currentLevels[i]
          next if pkmn.respond_to?(:kuray_no_evo?) && pkmn.kuray_no_evo? == 1 && $PokemonSystem && $PokemonSystem.kuray_no_evo == 1
          
          newSpecies = pkmn.check_evolution_on_level_up()
          next if !newSpecies
          
          pkmn.instance_variable_set(:@declined_evolutions, []) if !pkmn.instance_variable_get(:@declined_evolutions)
          declined = pkmn.instance_variable_get(:@declined_evolutions)
          if declined.include?(newSpecies)
            next  
          end
          
          evo_name = GameData::Species.get(newSpecies).name rescue newSpecies.to_s
          
          if pbConfirmMessage(_INTL("{1} can now evolve to {2}! Evolve now?", pkmn.name, evo_name))
            old_species = pkmn.species
            
            evo = PokemonEvolutionScene.new
            evo.pbStartScreen(pkmn, newSpecies)
            evo.pbEvolution
            evo.pbEndScreen
            
            if pkmn.species == old_species
              declined << newSpecies
            end
          else
            declined << newSpecies
          end
        end
      end
      private :pbEvolutionCheck rescue nil
    end
  end
rescue => e
  echoln("Error patching pbEvolutionCheck: #{e}") rescue nil
end

# ============================================================================
# INSTANT HATCH MOD
# ============================================================================
# When enabled, eggs hatch after just 1 step

begin
  if defined?(Events) && Events.respond_to?(:onStepTaken)
    Events.onStepTaken += proc { |_sender,_e|
      next unless defined?(MiscMods::InstantHatch) && MiscMods::InstantHatch.enabled?
      
      for egg in $Trainer.party
        next if !egg || egg.steps_to_hatch <= 0
        egg.steps_to_hatch = 1
      end
    }
  end
rescue => e
  echoln("Error patching egg step handler for Instant Hatch: #{e}") rescue nil
end

# ============================================================================
# RELEARN MOVES AND EGG MOVES FUNCTIONALITY
# ============================================================================
# Extend Move Relearner to include egg/event moves when enabled

begin
  if defined?(MoveRelearnerScreen) && !MoveRelearnerScreen.method_defined?(:pbGetRelearnableMoves_qa_toggle)
    class MoveRelearnerScreen
      alias pbGetRelearnableMoves_qa_toggle pbGetRelearnableMoves
      def pbGetRelearnableMoves(pkmn)
        base = pbGetRelearnableMoves_qa_toggle(pkmn)
        
        egg_moves_enabled = false
        if defined?(ModSettingsMenu)
          setting = ModSettingsMenu.get(:miscmods_egg_moves)
          egg_moves_enabled = (setting == 1 || setting == true)
        end
        
        return base unless egg_moves_enabled
        
        begin
          baby = pbGetBabySpecies(pkmn.species)
          egg_moves = pbGetSpeciesEggMoves(baby)
          all = (base | egg_moves)
          if $PokemonSystem && $PokemonSystem.eventmoves && $PokemonSystem.eventmoves > 0 && pkmn.respond_to?(:getEventMoveList)
            all = all | pkmn.getEventMoveList
          end
          return all | []
        rescue
          return base | []
        end
      end
    end
  end
rescue => e
  echoln("Error patching MoveRelearnerScreen for Egg Moves: #{e}") rescue nil
end

# ============================================================================
# COMPATIBILITY FUNCTIONS FOR NUZLOCKE MOD
# ============================================================================
# Provide these functions so Nuzlocke mod can still check if features are enabled

def qa_relearn_moves_enabled?
  if defined?(ModSettingsMenu)
    setting = ModSettingsMenu.get(:miscmods_relearn_moves)
    return (setting == 1 || setting == true)
  end
  false
end

def qa_egg_moves_enabled?
  if defined?(ModSettingsMenu)
    setting = ModSettingsMenu.get(:miscmods_egg_moves)
    return (setting == 1 || setting == true)
  end
  false
end

if !defined?(nuzlocke_relearn_enabled?)
  def nuzlocke_relearn_enabled?
    qa_relearn_moves_enabled?
  end
end

if !defined?(nuzlocke_egg_moves_enabled?)
  def nuzlocke_egg_moves_enabled?
    qa_egg_moves_enabled?
  end
end

# ============================================================================
# QUALITY ASSURANCE SCENE (Mod Settings Menu Integration)
# ============================================================================

class QualityAssuranceScene < PokemonOption_Scene
  include ModSettingsSpacing
  
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
    
    # Auto Hook Fishing
    options << EnumOption.new(
      _INTL("Auto Hook Fishing"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_auto_hook_fishing) || 0 },
      proc { |value|
        ModSettingsMenu.set(:miscmods_auto_hook_fishing, value)
        MiscMods::AutoHookFishing.apply if defined?(MiscMods::AutoHookFishing)
      },
      _INTL("Automatically hooks fish without player input.")
    )
    
    # Infinite Safari Steps
    options << EnumOption.new(
      _INTL("Infinite Safari Steps"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_infinite_safari_steps) || 0 },
      proc { |value|
        ModSettingsMenu.set(:miscmods_infinite_safari_steps, value)
        MiscMods::InfiniteSafariSteps.apply if defined?(MiscMods::InfiniteSafariSteps)
      },
      _INTL("Sets Safari Zone steps to 999999.")
    )
    
    # Rematch Money
    options << EnumOption.new(
      _INTL("Rematch Money"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_rematch_money) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_rematch_money, value) },
      _INTL("Enables prize money from trainer rematches.")
    )
    
    # No Move Auto-Teach
    options << EnumOption.new(
      _INTL("No Move Auto-Teach"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_no_move_auto_teach) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_no_move_auto_teach, value) },
      _INTL("Prevents automatic move learning on level-up.")
    )
    
    # Move Teach Prompt
    options << EnumOption.new(
      _INTL("Move Teach Prompt"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_move_teach_prompt) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_move_teach_prompt, value) },
      _INTL("Prompts before teaching TM/HM/Tutor moves.")
    )
    
    # Infinite Repel
    options << EnumOption.new(
      _INTL("Infinite Repel"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_infinite_repel) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_infinite_repel, value) },
      _INTL("Makes repel effect permanent when enabled.")
    )
    
    # Infinite Money
    options << EnumOption.new(
      _INTL("Infinite Money"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_infinite_money) || 0 },
      proc { |value|
        ModSettingsMenu.set(:miscmods_infinite_money, value)
        MiscMods::InfiniteMoney.apply if defined?(MiscMods::InfiniteMoney) && value == 1
      },
      _INTL("Keeps money at 999999 at all times.")
    )
    
    # Upgraded PP
    options << EnumOption.new(
      _INTL("Upgraded PP"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_upgraded_pp) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_upgraded_pp, value) },
      _INTL("Automatically maximizes PP upgrades for all party Pokemon moves.")
    )
    
    # Infinite PP
    options << EnumOption.new(
      _INTL("Infinite PP"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_infinite_pp) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_infinite_pp, value) },
      _INTL("Continuously restores all moves to full PP.")
    )
    
    # Disobedience (inverted logic: Off = remove disobedience, On = normal behavior)
    options << EnumOption.new(
      _INTL("Disobedience"),
      [_INTL("Off"), _INTL("On")],
      proc { 
        setting = ModSettingsMenu.get(:miscmods_remove_disobedience) || 0
        # Invert: if remove_disobedience is 1 (enabled), show as Off
        setting == 1 ? 0 : 1
      },
      proc { |value|
        # Invert: if user selects Off (0), enable remove_disobedience (1)
        ModSettingsMenu.set(:miscmods_remove_disobedience, value == 0 ? 1 : 0)
      },
      _INTL("Off: Pokemon always obey. On: Pokemon can disobey based on badges.")
    )
    
    # No Auto-Evolve
    options << EnumOption.new(
      _INTL("No Auto-Evolve"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_no_auto_evolve) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_no_auto_evolve, value) },
      _INTL("Prompts before evolution instead of auto-evolving.")
    )
    
    # Quick Rare Candy
    options << EnumOption.new(
      _INTL("Quick Rare Candy"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_quick_rare_candy) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_quick_rare_candy, value) },
      _INTL("Speeds up Rare Candy usage animations.")
    )
    
    # Instant Hatch
    options << EnumOption.new(
      _INTL("Instant Hatch"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_instant_hatch) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_instant_hatch, value) },
      _INTL("Eggs hatch immediately upon receiving.")
    )
    
    # Relearn Moves
    options << EnumOption.new(
      _INTL("Relearn Moves"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_relearn_moves) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_relearn_moves, value) },
      _INTL("Access move relearner functionality.")
    )
    
    # Egg Moves
    options << EnumOption.new(
      _INTL("Egg Moves"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_egg_moves) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_egg_moves, value) },
      _INTL("Enable/disable egg move learning.")
    )
    
    # Level Locking
    options << EnumOption.new(
      _INTL("Level Locking"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:miscmods_level_locking) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_level_locking, value) },
      _INTL("Lock Pokemon levels to prevent over-leveling.")
    )
    
    # Level Lock Manager Button
    options << ButtonOption.new(
      _INTL("Level Lock Manager"),
      proc {
        if defined?(qa_level_lock_manager)
          pbFadeOutIn { qa_level_lock_manager }
        else
          pbMessage(_INTL("Level Lock Manager not available."))
        end
      }
    )
    
    # Super Candy Button
    options << ButtonOption.new(
      _INTL("Super Candy"),
      proc {
        if defined?(qa_super_candy_party)
          pbFadeOutIn { qa_super_candy_party }
        else
          pbMessage(_INTL("Super Candy not available."))
        end
      }
    )
    
    # Super Candy Mode (Custom 2-per-row layout: Level Cap, Highest Level | Set Level)
    options << CustomRowEnumOption.new(
      _INTL("Super Candy Mode"),
      [_INTL("Level Cap"), _INTL("Highest Level"), _INTL("Set Level")],
      proc { ModSettingsMenu.get(:miscmods_super_candy_mode) || 0 },
      proc { |value| ModSettingsMenu.set(:miscmods_super_candy_mode, value) },
      _INTL("Level Cap: levels to cap, Highest: matches highest party, Set: levels to configured value."),
      2  # 2 items per row
    )
    
    # Super Candy Level (Number Input)
    options << NumberOption.new(
      _INTL("Super Candy Level"),
      1, 100,
      proc { 
        actual_level = ModSettingsMenu.get(:miscmods_super_candy_level) || 50
        actual_level - 1  # Convert to 0-based index for NumberOption
      },
      proc { |index_value| 
        actual_level = index_value + 1  # Convert from 0-based index to 1-based level
        ModSettingsMenu.set(:miscmods_super_candy_level, actual_level)
      }
    )
    
    # Nature Selector Button
    options << ButtonOption.new(
      _INTL("Nature Selector"),
      proc {
        if defined?(qa_nature_selector)
          pbFadeOutIn { qa_nature_selector }
        else
          pbMessage(_INTL("Nature Selector not available."))
        end
      }
    )
    
    # Reset Money Button
    options << ButtonOption.new(
      _INTL("Reset Money"),
      proc {
        if pbConfirmMessage(_INTL("Reset money to 3000? This will also disable Infinite Money."))
          ModSettingsMenu.set(:miscmods_infinite_money, 0)
          $Trainer.money = 3000 if $Trainer
          pbMessage(_INTL("Money reset to 3000!"))
        end
      }
    )
    
    options = auto_insert_spacers(options) if defined?(ModSettingsSpacing) && respond_to?(:auto_insert_spacers)
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Quality Assurance"), 0, 0, Graphics.width, 64, @viewport)
    
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
# MOD SETTINGS MENU REGISTRATION
# ============================================================================

if defined?(ModSettingsMenu)
  # Initialize default values
  ModSettingsMenu.set(:miscmods_auto_hook_fishing, 0) if ModSettingsMenu.get(:miscmods_auto_hook_fishing).nil?
  ModSettingsMenu.set(:miscmods_infinite_safari_steps, 0) if ModSettingsMenu.get(:miscmods_infinite_safari_steps).nil?
  ModSettingsMenu.set(:miscmods_rematch_money, 0) if ModSettingsMenu.get(:miscmods_rematch_money).nil?
  ModSettingsMenu.set(:miscmods_no_move_auto_teach, 0) if ModSettingsMenu.get(:miscmods_no_move_auto_teach).nil?
  ModSettingsMenu.set(:miscmods_move_teach_prompt, 0) if ModSettingsMenu.get(:miscmods_move_teach_prompt).nil?
  ModSettingsMenu.set(:miscmods_infinite_repel, 0) if ModSettingsMenu.get(:miscmods_infinite_repel).nil?
  ModSettingsMenu.set(:miscmods_infinite_money, 0) if ModSettingsMenu.get(:miscmods_infinite_money).nil?
  ModSettingsMenu.set(:miscmods_upgraded_pp, 0) if ModSettingsMenu.get(:miscmods_upgraded_pp).nil?
  ModSettingsMenu.set(:miscmods_infinite_pp, 0) if ModSettingsMenu.get(:miscmods_infinite_pp).nil?
  ModSettingsMenu.set(:miscmods_remove_disobedience, 0) if ModSettingsMenu.get(:miscmods_remove_disobedience).nil?
  ModSettingsMenu.set(:miscmods_no_auto_evolve, 0) if ModSettingsMenu.get(:miscmods_no_auto_evolve).nil?
  ModSettingsMenu.set(:miscmods_quick_rare_candy, 0) if ModSettingsMenu.get(:miscmods_quick_rare_candy).nil?
  ModSettingsMenu.set(:miscmods_instant_hatch, 0) if ModSettingsMenu.get(:miscmods_instant_hatch).nil?
  ModSettingsMenu.set(:miscmods_relearn_moves, 0) if ModSettingsMenu.get(:miscmods_relearn_moves).nil?
  ModSettingsMenu.set(:miscmods_egg_moves, 0) if ModSettingsMenu.get(:miscmods_egg_moves).nil?
  ModSettingsMenu.set(:miscmods_level_locking, 0) if ModSettingsMenu.get(:miscmods_level_locking).nil?
  ModSettingsMenu.set(:miscmods_super_candy_mode, 0) if ModSettingsMenu.get(:miscmods_super_candy_mode).nil?
  ModSettingsMenu.set(:miscmods_super_candy_level, 50) if ModSettingsMenu.get(:miscmods_super_candy_level).nil?
  
  ModSettingsMenu.register(:quality_assurance, {
    name: "Quality Assurance",
    type: :button,
    description: "Quality of life features: instant egg hatching, infinite repel, auto-hook fishing, infinite safari steps, infinite money, upgraded PP, infinite PP, remove disobedience, rematch money, move teaching customization, and more.",
    on_press: proc {
      pbFadeOutIn {
        scene = QualityAssuranceScene.new
        screen = PokemonOptionScreen.new(scene)
        screen.pbStartScreen
      }
    },
    category: "Quality of Life",
    searchable: [
      "egg", "hatch", "instahatch", "instant", "breeding",
      "repel", "infinite", "unlimited",
      "fishing", "auto hook", "autohook",
      "safari", "steps",
      "money", "infinite money", "cash",
      "pp", "power points", "pp up", "pp max", "upgraded pp",
      "rematch", "trainer", "prize money",
      "move", "teach", "auto teach", "level up",
      "quality", "assurance", "qa", "misc", "tools",
      "level lock", "super candy", "nature", "evolve", "rare candy", "relearn",
      "disobedience", "obey", "obedience", "badges"
    ]
  })
end

# ============================================================================
# LATE-LOAD PATCHES (Must be at end of file to override other mods)
# ============================================================================

if defined?(PokeBattle_Battle) && !PokeBattle_Battle.method_defined?(:miscmods_no_move_auto_teach_pbLearnMove_battle)
  class PokeBattle_Battle
    alias miscmods_no_move_auto_teach_pbLearnMove_battle pbLearnMove
    
    def pbLearnMove(idxParty, newMove)
      mod_enabled = defined?(MiscMods::NoMoveAutoTeach) && MiscMods::NoMoveAutoTeach.enabled?
      
      return miscmods_no_move_auto_teach_pbLearnMove_battle(idxParty, newMove) unless mod_enabled
      
      pkmn = pbParty(0)[idxParty]
      return if !pkmn
      
      pkmnName = pkmn.name
      battler = pbFindBattler(idxParty)
      moveName = GameData::Move.get(newMove).name
      
      return if pkmn.moves.any? { |m| m && m.id == newMove }
      
      pbDisplayPaused(_INTL("{1} gained the knowledge of {2}!", pkmnName, moveName))
      
      if defined?(MiscMods::MoveTeachPrompt) && MiscMods::MoveTeachPrompt.enabled?
        if pbDisplayConfirm(_INTL("Teach {1} to {2}?", moveName, pkmnName))
          if pkmn.moves.length < 4
            pkmn.learn_move(newMove)
            pbDisplayPaused(_INTL("{1} learned {2}!", pkmnName, moveName))
          else
            forgetMove = -1
            pbFadeOutIn {
              scene = PokemonSummary_Scene.new
              screen = PokemonSummaryScreen.new(scene)
              forgetMove = screen.pbStartForgetScreen([pkmn], 0, newMove)
            }
            
            if forgetMove >= 0
              oldmovename = pkmn.moves[forgetMove].name
              pkmn.moves[forgetMove] = Pokemon::Move.new(newMove)
              MiscMods::UpgradedPP.upgrade_move(pkmn.moves[forgetMove]) if defined?(MiscMods::UpgradedPP)
              pbDisplayPaused(_INTL("{1} learned {2}!", pkmnName, moveName))
            end
          end
        end
      end
      
      return
    end
  end
end

begin
  if !Object.private_method_defined?(:miscmods_no_move_auto_teach_pbLearnMove_kernel)
    class Object
      alias_method :miscmods_no_move_auto_teach_pbLearnMove_kernel, :pbLearnMove
      private :miscmods_no_move_auto_teach_pbLearnMove_kernel
      
      def pbLearnMove(pkmn, move, ignoreifknown = false, bymachine = false, fast = false, &block)
        mod_enabled = defined?(MiscMods::NoMoveAutoTeach) && MiscMods::NoMoveAutoTeach.enabled?
        
        return miscmods_no_move_auto_teach_pbLearnMove_kernel(pkmn, move, ignoreifknown, bymachine, fast, &block) unless mod_enabled
        
        return false if ignoreifknown && pkmn.hasMove?(move)
        movename = GameData::Move.get(move).name
        
        is_special_caller = false
        begin
          caller_locations.each do |loc|
            if loc.path && (loc.path.include?("Tutor.net") || loc.path.include?("MoveRelearner"))
              is_special_caller = true
              break
            end
          end
        rescue
        end
        
        if pkmn.hasMove?(move)
          pbMessage(_INTL("{1} already knows {2}.", pkmn.name, movename))
          block.call if block
          return false
        end
        
        if bymachine || is_special_caller
          is_move_relearner = false
          begin
            caller_locations.each do |loc|
              if loc.path && loc.path.include?("MoveRelearner")
                is_move_relearner = true
                break
              end
            end
          rescue
          end
          
          show_confirmation = !is_move_relearner
          
          if !show_confirmation || pbConfirmMessage(_INTL("Teach {1} to {2}?", movename, pkmn.name))
            if pkmn.moves.length < 4
              pkmn.learn_move(move)
              pbMessage(_INTL("{1} learned {2}!", pkmn.name, movename))
              block.call if block
              return true
            else
              forgetMove = -1
              pbFadeOutIn {
                scene = PokemonSummary_Scene.new
                screen = PokemonSummaryScreen.new(scene)
                forgetMove = screen.pbStartForgetScreen([pkmn], 0, move)
              }
              
              if forgetMove >= 0
                oldmovename = pkmn.moves[forgetMove].name
                pkmn.moves[forgetMove] = Pokemon::Move.new(move)
                MiscMods::UpgradedPP.upgrade_move(pkmn.moves[forgetMove]) if defined?(MiscMods::UpgradedPP)
                pbMessage(_INTL("{1} learned {2}!", pkmn.name, movename))
                block.call if block
                return true
              end
            end
          end
          block.call if block
          return false
        else
          pbMessage(_INTL("{1} gained the knowledge of {2}!", pkmn.name, movename))
          
          if defined?(MiscMods::MoveTeachPrompt) && MiscMods::MoveTeachPrompt.enabled?
            if pbConfirmMessage(_INTL("Teach {1} to {2}?", movename, pkmn.name))
              if pkmn.moves.length < 4
                pkmn.learn_move(move)
                pbMessage(_INTL("{1} learned {2}!", pkmn.name, movename))
                block.call if block
                return true
              else
                forgetMove = -1
                pbFadeOutIn {
                  scene = PokemonSummary_Scene.new
                  screen = PokemonSummaryScreen.new(scene)
                  forgetMove = screen.pbStartForgetScreen([pkmn], 0, move)
                }
                
                if forgetMove >= 0
                  oldmovename = pkmn.moves[forgetMove].name
                  pkmn.moves[forgetMove] = Pokemon::Move.new(move)
                  MiscMods::UpgradedPP.upgrade_move(pkmn.moves[forgetMove]) if defined?(MiscMods::UpgradedPP)
                  pbMessage(_INTL("{1} learned {2}!", pkmn.name, movename))
                  block.call if block
                  return true
                end
              end
            end
          end
          
          block.call if block
          return false
        end
      end
      private :pbLearnMove
    end
  end
rescue
end

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Quality Assurance",
    file: "10_Quality Assurance.rb",
    version: "2.0.0",
    download_url: "https://raw.githubusercontent.com/Stonewall0210/KIF-Mods/main/Mods/10_Quality%20Assurance.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewall0210/KIF-Mods/main/Changelogs/Quality%20Assurance.md",
    graphics: [],
    dependencies: []
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["10_Quality Assurance.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("QualityAssurance: Quality Assurance #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end

# ============================================================================
# OVERWORLD MENU REGISTRATION
# ============================================================================
if defined?(OverworldMenu)
  OverworldMenu.register(:quality_assurance, {
    label: "QoL Options",
    handler: proc { |screen|
      pbFadeOutIn {
        scene = QualityAssuranceScene.new
        screen_obj = PokemonOptionScreen.new(scene)
        screen_obj.pbStartScreen
      }
    },
    priority: 40,
    condition: proc { true },
    exit_on_select: false
  })
end