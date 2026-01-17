#========================================
# PokeVial
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
# Replaces Heal Pokemon in the pause menu with a limited-use PokeVial option.
#========================================

module PauseMenuPokeVial
  #---------------------------------------------------------------------------
  # PokeVial Uses (EDIT THIS IF NOT USING MOD SETTINGS)
  #---------------------------------------------------------------------------
  POKEVIAL_HEAL_USES = 3 # Number of Heal Uses, (0-5) 3 Default

  #---------------------------------------------------------------------------
  # IN-GAME MESSAGES (EDIT THESE TO CHANGE TEXT)
  #---------------------------------------------------------------------------
  MSG_OUT_OF_USES = "You have no PokeVial uses left. Visit a PokeCenter to replenish them."
  MSG_REMAINING = "Remaining PokeVial uses: {1}"
  MSG_REFILLED = "PokeVial uses have been replenished to {1}."
  MSG_COOLDOWN = "The PokeVial is recharging. Please wait {1}."

 # LABEL RENAME
  MENU_LABEL = "PokeVial"

  def self.global
    if defined?($PokemonGlobal) && $PokemonGlobal
      $PokemonGlobal
    else
      $pause_menu_pokevial_dummy ||= Object.new
    end
  end

  def self.configured_max_uses
    begin
      prog = ModSettingsMenu.get(:pokevial_progressive) rescue 0
      if prog && prog.to_i == 1
        badges = 0
        begin
          if defined?($Trainer) && $Trainer && $Trainer.respond_to?(:badge_count)
            badges = $Trainer.badge_count.to_i
          end
        rescue
        end
        dyn = 1 + (badges / 2)
        dyn = 5 if dyn > 5
        dyn = 1 if dyn < 1
        return dyn
      end
      val = ModSettingsMenu.get(:pokevial_heal_uses) rescue nil
      return val.to_i unless val.nil?
    rescue
    end
    return POKEVIAL_HEAL_USES
  end

  def self.menu_label_display
    label = MENU_LABEL
    if configured_max_uses == 0
      begin
        return _INTL("{1} (Off)", label)
      rescue
        return "#{label} (Off)"
      end
    end
    # Show current uses remaining
    current_uses = uses
    begin
      return _INTL("{1} ({2})", label, current_uses)
    rescue
      return "#{label} (#{current_uses})"
    end
  end

  def self.on_settings_changed(new_value)
    begin
      v = (new_value || 0).to_i
      g = global
      g.instance_variable_set(:@pokevial_heal_max_uses, v)
      if g.instance_variable_defined?(:@pokevial_heal_uses)
        cur = g.instance_variable_get(:@pokevial_heal_uses).to_i
        if v == 0
          g.instance_variable_set(:@pokevial_heal_uses, 0)
        elsif cur > v
          g.instance_variable_set(:@pokevial_heal_uses, v)
        end
      else
        g.instance_variable_set(:@pokevial_heal_uses, v)
      end
    rescue
    end
  end

  def self.max_uses
    g = global
    desired = configured_max_uses.to_i
    g.instance_variable_set(:@pokevial_heal_max_uses, desired)
    return desired
  end

  def self.uses
    g = global
    if g.instance_variable_defined?(:@pokevial_heal_uses)
      cur = g.instance_variable_get(:@pokevial_heal_uses).to_i
      mx = configured_max_uses.to_i
      if cur > mx
        cur = mx
        g.instance_variable_set(:@pokevial_heal_uses, cur)
      end
      return cur
    else
      g.instance_variable_set(:@pokevial_heal_uses, max_uses)
    end
  end

  def self.set_uses(value)
    global.instance_variable_set(:@pokevial_heal_uses, value)
  end

  def self.refill
    set_uses(configured_max_uses)
  end

  # --- Cooldown helpers ---
  def self.cooldown_enabled?
    begin
      (ModSettingsMenu.get(:pokevial_cooldown_enabled) || 0).to_i == 1
    rescue
      return false
    end
  end

  # Use the game's overworld clock where available (similar to EconomyMod)
  def self.current_time_seconds
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

  def self.cooldown_seconds
    begin
      val = (ModSettingsMenu.get(:pokevial_cooldown_seconds) || 0).to_i
      val = 0 if val < 0
      return val
    rescue
      return 0
    end
  end

  def self.format_hhmm(total_seconds)
    begin
      s = total_seconds.to_i
      s = 0 if s < 0
      h = s / 3600
      m = (s % 3600) / 60
      return sprintf("%02d:%02d", h, m)
    rescue
      return "00:00"
    end
  end

  def self.record_use_time
    begin
      global.instance_variable_set(:@pokevial_last_use_time, current_time_seconds)
    rescue
    end
  end

  def self.cooldown_remaining_seconds
    begin
      return 0 unless cooldown_enabled?
      last = global.instance_variable_defined?(:@pokevial_last_use_time) ? global.instance_variable_get(:@pokevial_last_use_time) : nil
      return 0 if last.nil?
      now = current_time_seconds
      elapsed_seconds = (now - last).to_f
      remaining = cooldown_seconds - elapsed_seconds
      return remaining.ceil if remaining > 0
      return 0
    rescue
      return 0
    end
  end
end

class Trainer
  unless method_defined?(:__pokevial_original_heal_party)
    alias __pokevial_original_heal_party heal_party
  end

  def heal_party
    stack_text = caller.join("\n").downcase

    if stack_text.include?("001_ui_pausemenu.rb") || stack_text.include?("ui_pausemenu.rb") || (stack_text.include?("pause") && stack_text.include?("menu"))
      ModSettingsMenu.debug_log("PokeVial: heal_party called from pause menu") if defined?(ModSettingsMenu)
      remaining = PauseMenuPokeVial.uses
      ModSettingsMenu.debug_log("PokeVial: Remaining uses: #{remaining}/#{PauseMenuPokeVial.configured_max_uses}") if defined?(ModSettingsMenu)
      if remaining <= 0
        pbMessage(_INTL(PauseMenuPokeVial::MSG_OUT_OF_USES))
        return
      end
      # Enforce cooldown if enabled
      cd = 0
      begin
        cd = PauseMenuPokeVial.cooldown_remaining_seconds
        if cd && cd > 0
          ModSettingsMenu.debug_log("PokeVial: Cooldown active - #{cd} seconds remaining") if defined?(ModSettingsMenu)
        end
      rescue
      end
      if cd && cd > 0
        pbMessage(_INTL(PauseMenuPokeVial::MSG_COOLDOWN, PauseMenuPokeVial.format_hhmm(cd)))
        return
      end
      result = __pokevial_original_heal_party
      PauseMenuPokeVial.set_uses(remaining - 1)
      ModSettingsMenu.debug_log("PokeVial: Party healed - uses consumed, now at #{remaining - 1}") if defined?(ModSettingsMenu)
      begin
        PauseMenuPokeVial.record_use_time
      rescue
      end
      pbMessage(_INTL(PauseMenuPokeVial::MSG_REMAINING, PauseMenuPokeVial.uses))
      return result
    end

    if (stack_text.include?("poke") && stack_text.include?("center")) ||
       (defined?($PokemonGlobal) && defined?($game_map) && $PokemonGlobal.respond_to?(:pokecenterMapId) && $PokemonGlobal.pokecenterMapId == $game_map.map_id)
      
      if defined?(EconomyMod) && defined?(EconomyMod::PokeVialCost) && EconomyMod::PokeVialCost.enabled?
        max_uses = PauseMenuPokeVial.configured_max_uses rescue 0
        current_uses = PauseMenuPokeVial.uses rescue 0
        uses_needed = [max_uses - current_uses, 0].max
        cost_per_use = EconomyMod::PokeVialCost.cost_per_use rescue 0
        total_cost = uses_needed * cost_per_use
        if uses_needed > 0 && total_cost > 0
          current_money = (defined?($Trainer) && $Trainer && $Trainer.respond_to?(:money) ? $Trainer.money : 0)
          if current_money >= total_cost
            if pbConfirmMessage(_INTL("Refill PokeVial ({1} use{2}) for ${3}?", uses_needed, uses_needed == 1 ? "" : "s", total_cost.to_s_formatted))
              result = __pokevial_original_heal_party
              PauseMenuPokeVial.refill
              $Trainer.money -= total_cost
              pbMessage(_INTL(PauseMenuPokeVial::MSG_REFILLED, PauseMenuPokeVial.configured_max_uses))
              return result
            else
              result = __pokevial_original_heal_party
              pbMessage(_INTL("Your Pokémon were healed."))
              return result
            end
          else
            result = __pokevial_original_heal_party
            pbMessage(_INTL("You don't have enough money to refill PokeVial. (Need ${1})", total_cost.to_s_formatted))
            pbMessage(_INTL("Your Pokémon were healed."))
            return result
          end
        elsif uses_needed == 0
          result = __pokevial_original_heal_party
          pbMessage(_INTL("Your PokeVial is already full."))
          pbMessage(_INTL("Your Pokémon were healed."))
          return result
        end
      end
      
      result = __pokevial_original_heal_party
      PauseMenuPokeVial.refill
      ModSettingsMenu.debug_log("PokeVial: Refilled at PokeCenter to #{PauseMenuPokeVial.configured_max_uses} uses") if defined?(ModSettingsMenu)
      pbMessage(_INTL(PauseMenuPokeVial::MSG_REFILLED, PauseMenuPokeVial.configured_max_uses))
      return result
    end

    __pokevial_original_heal_party
  end
end

class PokemonPauseMenu_Scene
  if method_defined?(:pbShowCommands) && !method_defined?(:__pokevial_old_pbShowCommands)
    alias __pokevial_old_pbShowCommands pbShowCommands
  end

  def pbShowCommands(commands)
    ret = -1
    cmdwindow = @sprites["cmdwindow"]
    display_commands = commands.map do |c|
      begin
        if c == _INTL("Heal Pokémon") || c == "Heal Pokémon"
          PauseMenuPokeVial.menu_label_display
        else
          c
        end
      rescue
        c == "Heal Pokémon" ? PauseMenuPokeVial.menu_label_display : c
      end
    end
    cmdwindow.commands = display_commands
    cmdwindow.index = [$PokemonTemp.menuLastChoice, commands.length - 1].min
    cmdwindow.resizeToFit(commands)
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = 0
    cmdwindow.visible = true
    loop do
      cmdwindow.update
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.trigger?(Input::BACK)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        current = cmdwindow.commands[cmdwindow.index]
        if (current && current.to_s.length > 0)
          begin
            curr_down = current.to_s.downcase
            heal_label = (_INTL("Heal Pokémon") rescue "Heal Pokémon").to_s.downcase
            menu_label = (PauseMenuPokeVial::MENU_LABEL.to_s).downcase
            if curr_down.include?(heal_label) || curr_down.include?(menu_label)
              if PauseMenuPokeVial.configured_max_uses == 0
                pbPlayCancelSE
                pbMessage(_INTL(PauseMenuPokeVial::MSG_OUT_OF_USES))
                next
              end
              remaining = PauseMenuPokeVial.uses
              if remaining <= 0
                pbPlayCancelSE
                pbMessage(_INTL(PauseMenuPokeVial::MSG_OUT_OF_USES))
                next
              end
              begin
                cd = PauseMenuPokeVial.cooldown_remaining_seconds
                if cd && cd > 0
                  pbPlayCancelSE
                  pbMessage(_INTL(PauseMenuPokeVial::MSG_COOLDOWN, PauseMenuPokeVial.format_hhmm(cd)))
                  next
                end
              rescue
              end
              pbPlayDecisionSE
            end
          rescue
          end
        end
        ret = cmdwindow.index
        $PokemonTemp.menuLastChoice = ret
        break
      end
    end
    return ret
  end
end

# ============================================================================
# POKEVIAL SETTINGS SCENE (Modern Pattern)
# ============================================================================
if defined?(PokemonOption_Scene)
  class PokeVialScene < PokemonOption_Scene
    include ModSettingsSpacing if defined?(ModSettingsSpacing)
    
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
      
      # Get current progressive state to determine Heal Uses availability
      prog_enabled = (::ModSettingsMenu.get(:pokevial_progressive) || 0).to_i == 1
      
      # Progressive Uses
      options << EnumOption.new(
        _INTL("Progressive Uses"),
        [_INTL("Off"), _INTL("On")],
        proc { ::ModSettingsMenu.get(:pokevial_progressive) || 0 },
        proc { |value|
          ::ModSettingsMenu.set(:pokevial_progressive, value)
          PauseMenuPokeVial.on_settings_changed(PauseMenuPokeVial.configured_max_uses)
        },
        _INTL("Auto-Handles Heal Uses. Scales by badges (0-1=1, 2-3=2, 4-5=3, 6-7=4, 8+=5).")
      )
      
      # Heal Uses (disabled when Progressive is On)
      if prog_enabled
        auto_uses = PauseMenuPokeVial.configured_max_uses
        options << EnumOption.new(
          _INTL("Heal Uses"),
          [_INTL("Auto (#{auto_uses})")],
          proc { 0 },
          proc { |value| },
          _INTL("Number of PokeVial uses (automatically set by Progressive mode).")
        )
      else
        options << StoneSliderOption.new(
          _INTL("Heal Uses"),
          0, 5, 1,
          proc { ::ModSettingsMenu.get(:pokevial_heal_uses) || 0 },
          proc { |value|
            ::ModSettingsMenu.set(:pokevial_heal_uses, value)
            PauseMenuPokeVial.on_settings_changed(value)
          },
          _INTL("Number of PokeVial uses per encounter (0 = disabled).")
        )
      end
      
      # Cooldown Toggle
      options << EnumOption.new(
        _INTL("Cooldown"),
        [_INTL("Off"), _INTL("On")],
        proc { ::ModSettingsMenu.get(:pokevial_cooldown_enabled) || 0 },
        proc { |value| ::ModSettingsMenu.set(:pokevial_cooldown_enabled, value) },
        _INTL("Enforce real-time cooldown between PokeVial uses.")
      )
      
      # Cooldown Time
      allowed_cd = [4*60*60, 8*60*60, 12*60*60, 18*60*60, 24*60*60]
      cd_labels = allowed_cd.map { |secs| PauseMenuPokeVial.format_hhmm(secs) }
      options << EnumOption.new(
        _INTL("Cooldown Time"),
        cd_labels,
        proc {
          cursec = (::ModSettingsMenu.get(:pokevial_cooldown_seconds) || allowed_cd.first).to_i
          idx = allowed_cd.index(cursec) || 0
          idx
        },
        proc { |idx|
          ::ModSettingsMenu.set(:pokevial_cooldown_seconds, allowed_cd[idx])
        },
        _INTL("Duration between PokeVial uses when cooldown is enabled.")
      )
      
      # Use auto_insert_spacers if available, otherwise return options as-is
      if defined?(ModSettingsSpacing) && respond_to?(:auto_insert_spacers)
        return auto_insert_spacers(options)
      else
        return options
      end
    end
    
    def pbStartScene(inloadscreen = false)
      super(inloadscreen)
      
      # Set custom title
      @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("PokeVial Settings"), 0, 0, Graphics.width, 64, @viewport)
      
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
end

# ============================================================================
# MOD SETTINGS REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu)
  # Initialize default settings
  ModSettingsMenu.set(:pokevial_heal_uses, PauseMenuPokeVial::POKEVIAL_HEAL_USES) if ModSettingsMenu.get(:pokevial_heal_uses).nil?
  ModSettingsMenu.set(:pokevial_progressive, 0) if ModSettingsMenu.get(:pokevial_progressive).nil?
  ModSettingsMenu.set(:pokevial_cooldown_enabled, 0) if ModSettingsMenu.get(:pokevial_cooldown_enabled).nil?
  ModSettingsMenu.set(:pokevial_cooldown_seconds, 4*60*60) if ModSettingsMenu.get(:pokevial_cooldown_seconds).nil?
  
  if defined?(PokeVialScene)
    ModSettingsMenu.register(:pokevial_settings, {
      name: "PokeVial",
      type: :button,
      description: "Configure limited-use healing: adjust uses, enable cooldowns, and progressive badge-based scaling.",
      on_press: proc {
        pbFadeOutIn {
          scene = PokeVialScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      },
      category: "Quality of Life",
      searchable: [
        "pokevial", "vial", "heal", "healing", "limited", "uses",
        "cooldown", "progressive", "badge", "scaling",
        "party heal", "replenish", "potion", "center"
      ]
    })
  else
    # Fallback if PokeVialScene wasn't defined
    puts "PokeVial: Warning - PokeVialScene class not defined, cannot register settings menu"
  end
end

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "PokeVial",
    file: "10a_PokeVial.rb",
    version: "2.0.0",
    download_url: "https://raw.githubusercontent.com/Stonewall0210/KIF-Mods/main/Mods/10a_PokeVial.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewall0210/KIF-Mods/main/Changelogs/PokeVial.md",
    graphics: [],
    dependencies: []
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["10a_PokeVial.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("PokeVial: PokeVial #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end

# ============================================================================
# OVERWORLD MENU REGISTRATION
# ============================================================================
if defined?(OverworldMenu)
  OverworldMenu.register(:pokevial_settings, {
    label: "PokeVial",
    handler: proc { |screen|
      begin
        ::ModSettingsMenu.debug_log("PokeVial: Opening PokeVial settings from Overworld Menu") if defined?(::ModSettingsMenu)
        # Hide party sprites before opening menu
        screen.instance_variable_get(:@scene).hide_party_sprites if screen.instance_variable_get(:@scene).respond_to?(:hide_party_sprites)
        
        # Open the PokeVial settings menu directly
        pbFadeOutIn {
          scene = PokeVialScene.new
          screen_obj = PokemonOptionScreen.new(scene)
          screen_obj.pbStartScreen
        }
        
        # Show party sprites after menu closes
        screen.instance_variable_get(:@scene).show_party_sprites if screen.instance_variable_get(:@scene).respond_to?(:show_party_sprites)
        ::ModSettingsMenu.debug_log("PokeVial: PokeVial settings closed") if defined?(::ModSettingsMenu)
        nil  # Don't exit menu
      rescue => e
        ::ModSettingsMenu.debug_log("PokeVial: Error opening PokeVial settings: #{e.class} - #{e.message}") if defined?(::ModSettingsMenu)
        screen.instance_variable_get(:@scene).hide_party_sprites if screen.instance_variable_get(:@scene).respond_to?(:hide_party_sprites)
        pbMessage("An error occurred opening PokeVial settings.")
        screen.instance_variable_get(:@scene).show_party_sprites if screen.instance_variable_get(:@scene).respond_to?(:show_party_sprites)
        nil
      end
    },
    priority: 50,
    condition: proc { true },
    exit_on_select: false
  })
end

