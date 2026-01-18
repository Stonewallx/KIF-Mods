#========================================
# Follower System
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.1.0
# Author: Stonewall
#========================================

#===============================================================================
# Follower Sprite Helpers
#===============================================================================

class SpritePreviewWindow
  attr_accessor :position_mode
  
  def initialize(viewport = nil, position_mode = :center)
    @viewport = viewport || Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @own_viewport = viewport.nil?
    @position_mode = position_mode
    
    @background = Sprite.new(@viewport)
    @background.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @background.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0, 180))
    
    @animated_frame = Sprite.new(@viewport)
    @animated_frame.ox = 0
    @animated_frame.oy = 0
    
    @spritesheet = Sprite.new(@viewport)
    @spritesheet.ox = 0
    @spritesheet.oy = 0
    
    @label = Sprite.new(@viewport)
    @label.bitmap = Bitmap.new(Graphics.width, 40)
    @label.bitmap.font.size = 24
    @label.bitmap.font.bold = true
    @label.y = 10
     
    @frame_counter = 0
    @current_frame = 0
    @current_direction = 0  
    @frame_delay = 15  
    @direction_delay = 80  # Frames to stay in each direction
    @direction_counter = 0
    @full_sprite = nil
    @frame_width = 0
    @frame_height = 0
  end
  
  def set_sprite(character_name, label_text = "")
    return unless character_name
    
    begin
      @full_sprite.dispose if @full_sprite
      @animated_frame.bitmap.dispose if @animated_frame.bitmap
      @spritesheet.bitmap.dispose if @spritesheet.bitmap
      
      path = "Graphics/Characters/#{character_name}"
      path += ".png" unless path.end_with?(".png")
      
      if File.exist?(path)
        @full_sprite = Bitmap.new(path)
        
        @frame_width = @full_sprite.width / 4
        @frame_height = @full_sprite.height / 4
        
        @animated_frame.bitmap = Bitmap.new(@frame_width, @frame_height)
        
        @spritesheet.bitmap = Bitmap.new(@full_sprite.width, @full_sprite.height)
        @spritesheet.bitmap.blt(0, 0, @full_sprite, Rect.new(0, 0, @full_sprite.width, @full_sprite.height))
        
        @current_frame = 0
        @current_direction = 0
        @direction_counter = 0
        update_animation_frame
      else
        @full_sprite = nil
        @animated_frame.bitmap = Bitmap.new(128, 128)
        @animated_frame.bitmap.fill_rect(0, 0, 128, 128, Color.new(128, 128, 128))
        @spritesheet.bitmap = nil
      end
      
      if @position_mode == :left
        if @spritesheet.bitmap
          @spritesheet.x = 20
          @spritesheet.y = 50
        end
        
        @animated_frame.x = 20 + (@spritesheet.bitmap ? @spritesheet.bitmap.width + 40 : 0)
        @animated_frame.y = 50
        
        @label.bitmap.clear
        @label.x = 20
        pbDrawTextPositions(@label.bitmap, [[label_text, 0, 0, 0, Color.new(255, 255, 255), Color.new(0, 0, 0)]])
      else
        if @spritesheet.bitmap
          @spritesheet.x = 20
          @spritesheet.y = 50
        end
        
        @animated_frame.x = 20 + (@spritesheet.bitmap ? @spritesheet.bitmap.width + 40 : 0)
        @animated_frame.y = 50
        
        @label.bitmap.clear
        @label.x = 0
        pbDrawTextPositions(@label.bitmap, [[label_text, Graphics.width / 2, 0, 2, Color.new(255, 255, 255), Color.new(0, 0, 0)]])
      end
    rescue => e
      @full_sprite = nil
      @animated_frame.bitmap = Bitmap.new(128, 128) unless @animated_frame.bitmap
      @animated_frame.bitmap.fill_rect(0, 0, 128, 128, Color.new(128, 128, 128))
    end
  end
  
  def update_animation_frame
    return unless @full_sprite && @animated_frame.bitmap
    
    frame_x = @current_frame * @frame_width
    frame_y = @current_direction * @frame_height  
    
    @animated_frame.bitmap.clear
    src_rect = Rect.new(frame_x, frame_y, @frame_width, @frame_height)
    @animated_frame.bitmap.blt(0, 0, @full_sprite, src_rect)
  end
  
  def update
    Graphics.update
    Input.update
    
    if @full_sprite
      @frame_counter += 1
      if @frame_counter >= @frame_delay
        @frame_counter = 0
        @current_frame = (@current_frame + 1) % 4
        update_animation_frame
      end
      
      @direction_counter += 1
      if @direction_counter >= @direction_delay
        @direction_counter = 0
        @current_direction = (@current_direction + 1) % 4
        update_animation_frame
      end
    end
  end
  
  def dispose
    @full_sprite.dispose if @full_sprite
    @animated_frame.bitmap.dispose if @animated_frame.bitmap
    @animated_frame.dispose
    @spritesheet.bitmap.dispose if @spritesheet.bitmap
    @spritesheet.dispose
    @label.bitmap.dispose if @label.bitmap
    @label.dispose
    @background.bitmap.dispose if @background.bitmap
    @background.dispose
    if @own_viewport
      @viewport.dispose
    end
  end
end

def get_sprite_variations(base_name, folder)
  variations = []
  
  base_path = "Graphics/Characters/#{folder}/#{base_name}.png"
  if File.exist?(base_path)
    variations << base_name
  end
  
  ('a'..'z').each do |letter|
    variant_path = "Graphics/Characters/#{folder}/#{base_name}#{letter}.png"
    if File.exist?(variant_path)
      variations << "#{base_name}#{letter}"
    end
  end
  
  return variations
end

def get_fusion_sprite_variations(pkmn, party_index = nil)
  return [] unless pkmn
  return [] unless pkmn.species_data.is_a?(GameData::FusedSpecies)
  
  head_species = pkmn.species_data.head_pokemon.species
  body_species = pkmn.species_data.body_pokemon.species
  gender = pkmn.gender == 1 rescue false
  shiny = pkmn.shiny? rescue false
  form = pkmn.form rescue 0
  shadow = pkmn.shadowPokemon? rescue false
  
  base_name = generate_fused_sprite_name(head_species.to_s.upcase, body_species.to_s.upcase, gender, false, form, shadow)
  target_folder = shiny ? "Custom Followers shiny" : "Custom Followers"
  
  variations = []
  variation_data = []
  
  custom_variations = get_sprite_variations(base_name, target_folder)
  if custom_variations.empty? && shiny
    custom_variations = get_sprite_variations(base_name, "Custom Followers")
    target_folder = "Custom Followers"
  end
  
  custom_variations.each do |var|
    variation_data << {
      :name => var,
      :folder => target_folder,
      :display_name => var.sub(base_name, ""),
      :type => :custom
    }
  end
  
  fused_sprite_name = generate_fused_sprite_name(head_species, body_species, gender, shiny, form, shadow)
  variation_data << {
    :name => fused_sprite_name,
    :folder => "Followers/FusedPokemon",
    :display_name => "Fusion",
    :type => :generated
  }
  
  head_sprite = find_valid_follower_sprite(build_follower_factors(head_species, gender, shiny, form, shadow))
  if head_sprite
    head_name = GameData::Species.get(head_species).name rescue head_species.to_s
    variation_data << {
      :name => "HEAD_ONLY",
      :folder => head_sprite,
      :display_name => head_name,
      :type => :component
    }
  end
  
  body_sprite = find_valid_follower_sprite(build_follower_factors(body_species, gender, shiny, form, shadow))
  if body_sprite
    body_name = GameData::Species.get(body_species).name rescue body_species.to_s
    variation_data << {
      :name => "BODY_ONLY",
      :folder => body_sprite,
      :display_name => body_name,
      :type => :component
    }
  end
  
  return variation_data
end

def get_regular_sprite_variations(pkmn, party_index = nil)
  return [] unless pkmn
  return [] if pkmn.species_data.is_a?(GameData::FusedSpecies)
  
  gender = pkmn.gender == 1 rescue false
  shiny = pkmn.shiny? rescue false
  form = pkmn.form rescue 0
  species_name = pkmn.species.to_s.upcase
  form_suffix = (form && form > 0) ? "_#{form}" : ""
  
  variation_data = []
  
  base_name = "#{species_name}#{form_suffix}"
  target_folder = shiny ? "Custom Followers shiny" : "Custom Followers"
  
  custom_variations = get_sprite_variations(base_name, target_folder)
  if custom_variations.empty? && shiny
    custom_variations = get_sprite_variations(base_name, "Custom Followers")
    target_folder = "Custom Followers"
  end
  
  custom_variations.each do |var|
    variation_data << {
      :name => var,
      :folder => target_folder,
      :display_name => var.sub(base_name, ""),
      :type => :custom
    }
  end
  
  default_sprite = nil
  if shiny
    default_path = "Followers shiny/#{species_name}#{form_suffix}"
    if check_sprite_exists_no_cache(default_path)
      default_sprite = default_path
    end
  end
  
  if !default_sprite
    default_path = "Followers/#{species_name}#{form_suffix}"
    if check_sprite_exists_no_cache(default_path)
      default_sprite = default_path
    end
  end
  
  if default_sprite
    variation_data << {
      :name => "#{species_name}#{form_suffix}",
      :folder => default_sprite.split('/')[0],
      :display_name => "Default",
      :type => :default
    }
  end
  
  return variation_data
end

def get_selected_sprite_variation(pkmn_index)
  return nil unless defined?($PokemonGlobal)
  variations = $PokemonGlobal.instance_variable_get(:@followerSpriteVariations) || {}
  return variations[pkmn_index]
end

def set_selected_sprite_variation(pkmn_index, variation)
  return unless defined?($PokemonGlobal)
  variations = $PokemonGlobal.instance_variable_get(:@followerSpriteVariations) || {}
  variations[pkmn_index] = variation
  $PokemonGlobal.instance_variable_set(:@followerSpriteVariations, variations)
end

def check_sprite_exists_no_cache(path)
  full_path = path.end_with?(".png") ? "Graphics/Characters/#{path}" : "Graphics/Characters/#{path}.png"
  return File.exist?(full_path)
end

module FollowingPkmn
  def self.get_follower_sprite_name(pkmn)
    return nil if !pkmn
    shiny = false
    begin
      shiny = pkmn.shiny?
    rescue
      shiny = false
    end
    names = []
    begin
      species_name = pkmn.species.to_s.upcase
      form = pkmn.respond_to?(:form) ? pkmn.form : 0
      
      names << "#{species_name}_#{form}" if form && form > 0
      names << species_name
      
      begin
        if defined?(GameData) && GameData::Species.exists?(pkmn.species)
          dex_num = GameData::Species.get(pkmn.species).id_number.to_s.rjust(3, '0')
          names << "#{dex_num}_#{form}" if form && form > 0
          names << dex_num
        end
      rescue
      end
    rescue
      names = [pkmn.species.to_s.upcase]
    end

    folders = []

    if shiny
      begin
        names.each do |n|
          begin
            if defined?(pbResolveBitmap)
              return "Followers shiny/#{n}" if pbResolveBitmap("Graphics/Characters/Followers shiny/#{n}")
            else
              return "Followers shiny/#{n}" if File.exist?("Graphics/Characters/Followers shiny/#{n}.png")
            end
          rescue
          end
        end
      rescue
      end
    end

    names.each do |n|
      folders.each do |f|
        begin
          if defined?(pbResolveBitmap)
            return "Followers/#{f}/#{n}" if pbResolveBitmap("Graphics/Characters/Followers/#{f}/#{n}")
          else
            return "Followers/#{f}/#{n}" if File.exist?("Graphics/Characters/Followers/#{f}/#{n}.png")
          end
        rescue
        end
      end
    end

    names.each do |n|
      begin
        if defined?(pbResolveBitmap)
          return "Followers/#{n}" if pbResolveBitmap("Graphics/Characters/Followers/#{n}")
        else
          return "Followers/#{n}" if File.exist?("Graphics/Characters/Followers/#{n}.png")
        end
      rescue
      end
    end

    names.each do |n|
      begin
        if defined?(pbResolveBitmap)
          return n if pbResolveBitmap("Graphics/Characters/#{n}")
        else
          return n if File.exist?("Graphics/Characters/#{n}.png")
        end
      rescue
      end
    end

    return "Followers/#{names.last}"
  end




end

#===============================================================================
# Fusion Sprite Generation
#===============================================================================

def build_follower_factors(species, gender, shiny, form, shadow)
  [].tap do |factors|
    factors.push([4, shadow, false]) if shadow
    factors.push([1, gender, false]) if gender
    factors.push([2, shiny, false]) if shiny
    factors.push([3, form, 0]) unless form.nil? || form == 0
    factors.push([0, species, 0])
  end
end

def find_valid_follower_sprite(factors)
  trySpecies = 0
  tryGender = false
  tryShiny = false
  tryForm = 0
  tryShadow = false
  
  (0...2**factors.length).each do |i|
    factors.each_with_index do |factor, index|
      newVal = ((i / (2**index)) % 2 == 0) ? factor[1] : factor[2]
      case factor[0]
      when 0 then trySpecies = newVal
      when 1 then tryGender = newVal
      when 2 then tryShiny = newVal
      when 3 then tryForm = newVal
      when 4 then tryShadow = newVal
      end
    end
    
    (0...2).each do |j|
      next if trySpecies == 0 && j == 0
      
      begin
        trySpeciesText = if j == 0
          trySpecies.to_s.upcase
        else
          GameData::Species.get(trySpecies).id_number.to_s.rjust(3, '0') rescue trySpecies.to_s.rjust(3, '0')
        end
      rescue
        trySpeciesText = trySpecies.to_s.upcase
      end
      
      bitmapFileName = sprintf("%s%s%s%s%s",
                              trySpeciesText,
                              (tryGender ? "f" : ""),
                              (tryShiny ? "s" : ""),
                              (tryForm != 0 ? "_#{tryForm}" : ""),
                              (tryShadow ? "_shadow" : "")) rescue nil
      
      next if !bitmapFileName
      
      if tryShiny
        return "Custom Followers shiny/#{bitmapFileName}" if check_sprite_exists_no_cache("Custom Followers shiny/#{bitmapFileName}") rescue false
      end
      return "Custom Followers/#{bitmapFileName}" if check_sprite_exists_no_cache("Custom Followers/#{bitmapFileName}") rescue false
      return bitmapFileName if pbResolveBitmap("Graphics/Characters/#{bitmapFileName}") rescue false
      return "Followers/#{bitmapFileName}" if pbResolveBitmap("Graphics/Characters/Followers/#{bitmapFileName}") rescue false
    end
  end
  
  return "Followers/000"
end

def generate_fused_sprite_name(head, body, gender, shiny, form, shadow)
  sprintf("%s_%s%s%s%s%s",
          head,
          body,
          (gender ? "f" : ""),
          (shiny ? "s" : ""),
          (form != 0 ? "_#{form}" : ""),
          (shadow ? "_shadow" : ""))
end

def create_combined_follower_sprite(head_sprite_path, body_sprite_path, output_path)
  
  head_check = head_sprite_path.end_with?(".png") ? head_sprite_path : "#{head_sprite_path}.png"
  body_check = body_sprite_path.end_with?(".png") ? body_sprite_path : "#{body_sprite_path}.png"
  
  fallback = "Graphics/Characters/Followers/000"
  head_sprite_path = fallback unless File.exist?(head_check)
  body_sprite_path = fallback unless File.exist?(body_check)
  
  begin
    head_sprite = Bitmap.new(head_sprite_path)
    body_sprite = Bitmap.new(body_sprite_path)
    
    if head_sprite.height != body_sprite.height
      head_sprite.dispose rescue nil
      body_sprite.dispose rescue nil
      head_sprite = Bitmap.new(fallback)
      body_sprite = Bitmap.new(fallback)
    end
    
    width = head_sprite.width
    height = head_sprite.height
    
    combined_sprite = Bitmap.new(width, height)
    
    (0...4).each do |i|
      bias = height / 32
      
      y = i * (height / 4)
      x = 0
      
      rect_top = Rect.new(x, y, width, (height / 8) + bias)
      combined_sprite.blt(x, y, head_sprite, rect_top)
      
      rect_bottom = Rect.new(x, y + (height / 8) + bias, width, height / 8 - bias)
      combined_sprite.blt(x, y + (height / 8) + bias, body_sprite, rect_bottom)
    end
    
    dir = File.dirname(output_path)
    Dir.mkdir(dir) unless Dir.exist?(dir)
    
    combined_sprite.save_to_png(output_path)
    
    
    head_sprite.dispose
    body_sprite.dispose
    combined_sprite.dispose
    
    return true
  rescue => e
    return false
  end
end

begin
  if defined?(Events) && !defined?($FollowerDebug_SpritesetHook)
    $FollowerDebug_SpritesetHook = true
    Events.onSritesetCreate += proc { |_sender,e|
      begin
        if defined?($PokemonGlobal) && $PokemonGlobal.respond_to?(:dependentEvents)
          follower_active = ($PokemonGlobal.instance_variable_get(:@followerActive) rescue false)
          unless follower_active
            deps = ($PokemonGlobal.dependentEvents rescue [])
            if deps && deps.any? { |e| e && e[8] == "FollowerPkmn" }
              pbRemoveDependency2("FollowerPkmn") rescue nil
            end
          end
        end
      rescue
      end

      begin
        next unless (defined?($PokemonGlobal) && $PokemonGlobal.instance_variable_get(:@followerDebug))
        spriteset = e[0]
        viewport = e[1]
        begin
          chars = spriteset.instance_variable_get(:@character_sprites) rescue nil
          users = spriteset.instance_variable_get(:@usersprites) rescue nil

          if chars
            chars.each_with_index do |s,i|
              next if !s
              begin
                ch = (s.character rescue nil)
                id = (ch.respond_to?(:id) ? ch.id : nil) rescue nil
                cname = (ch.respond_to?(:character_name) ? ch.character_name : nil) rescue nil
              rescue
              end
            end
          end
          if users
            users.each_with_index do |s,i|
              next if !s
              begin
                assoc = (s.instance_variable_get(:@character) rescue nil)
                assoc_info = if assoc && assoc.respond_to?(:id)
                  "event_id=#{assoc.id} name=#{assoc.respond_to?(:character_name) ? assoc.character_name : 'nil'}"
                else
                  "assoc=#{assoc.class rescue 'nil'}"
                end
              rescue
              end
            end
          end
        rescue => e
        end
      rescue
      end
    }
  end
rescue
end




#===============================================================================
# Scene Map Update
#===============================================================================
class Scene_Map
  unless method_defined?(:update_before_follower)
    alias update_before_follower update

    def update
      update_before_follower
      
      # Check for save switching and clear follower immediately if trainer IDs don't match
      if defined?($Follower) && $Follower && defined?($PokemonGlobal) && defined?($Trainer)
        saved_trainer_id = $PokemonGlobal.instance_variable_get(:@follower_trainer_id)
        current_trainer_id = $Trainer.id rescue nil
        
        if saved_trainer_id && current_trainer_id && saved_trainer_id != current_trainer_id
          # Different save detected - clear follower immediately
          $Follower.clear_follower(false) if $Follower.respond_to?(:clear_follower)
          $Follower = nil
          $PokemonGlobal.instance_variable_set(:@follower_trainer_id, current_trainer_id)
          $PokemonGlobal.instance_variable_set(:@lastFollowerIndex, nil)
          $PokemonGlobal.instance_variable_set(:@lastFollowerTrainerId, nil)
          $PokemonGlobal.instance_variable_set(:@followerActive, false)
          $PokemonGlobal.instance_variable_set(:@followerIndex, nil)
        elsif !saved_trainer_id && current_trainer_id
          # First time setting trainer ID for this save
          $PokemonGlobal.instance_variable_set(:@follower_trainer_id, current_trainer_id)
        end
      end
      
      # Left Control key to toggle follower
      if Input.trigger?(Input::CTRL) && !$game_temp.in_menu && !$game_temp.in_battle && !$game_player.moving?
        # Check if Left Control toggle is enabled
        ctrl_enabled = ModSettingsMenu.get(:follower_ctrl_toggle) rescue true
        
        if ctrl_enabled
          follower_active = false
          if defined?($Follower) && $Follower && $Follower.event
            follower_active = true
          end
          
          if follower_active
            # Put away follower
            $Follower.clear_follower
          else
            # Bring out last follower
            last_index = nil
            last_trainer_id = nil
            current_trainer_id = $Trainer.id rescue nil
            
            if defined?($PokemonGlobal)
              last_index = $PokemonGlobal.instance_variable_get(:@lastFollowerIndex) rescue nil
              last_trainer_id = $PokemonGlobal.instance_variable_get(:@lastFollowerTrainerId) rescue nil
            end
            
            # Only use saved index if trainer IDs match
            if last_index && last_trainer_id && current_trainer_id && last_trainer_id == current_trainer_id
              # Use saved follower index
            else
              # Different save or no saved trainer ID - use first party member
              last_index = 0
            end
            
            # Default to first party member if no index at all
            last_index = 0 if !last_index && $Trainer.party.length > 0
            
            # Try to create follower, if it fails try next party members
            if last_index && defined?(create_follower)
              success = false
              start_index = last_index
              party_size = $Trainer.party.length
              
              party_size.times do |i|
                test_index = (start_index + i) % party_size
                next unless $Trainer.party[test_index]
                
                # Try to create follower with error messages shown
                result = create_follower(test_index, false)
                if result == true
                  success = true
                  break
                end
              end
              
              # Show message if no Pokemon could follow (all failed)
              if !success
                pbMessage(_INTL("No Pokémon in your party can follow you!"))
              end
            end
          end
        end
      end
      
      if defined?($Follower) && $Follower && $Follower.event
        $Follower.apply_pixel_offset
      end
    end
  end
end
 
module TrainerHandler
  module TrainerHandlerUtils
    def self.ensure_map_loaded(map_id)
      return if $game_map.map_id == map_id
      $game_map.setup(map_id)
      $game_map.refresh
    end

    def self.force_map_refresh
      $game_map.need_refresh = true
      $game_map.refresh
      $game_map.events.each_value(&:refresh)
      if $scene.is_a?(Scene_Map)
        $scene.updateSpritesets(true)
      end
      Graphics.update
    end
  end

  def self.event_exists(event_id)
    return $game_map.events[event_id] ? true : false
  end

  def self.create_sprite_event(map_id, trainer_id, x, y, rot = 2, sprite_name = "002", page_list = [RPG::EventCommand.new(101, 0, ["This trainer is not yet implemented..."])], animate_steps = true, skip_sprite_creation = false)
    TrainerHandlerUtils.ensure_map_loaded(map_id)

    if TrainerHandler.event_exists(trainer_id)
      return
    end

    event = RPG::Event.new(x, y)
    event.name = "Trainer #{trainer_id}"
    event.pages << RPG::Event::Page.new.tap do |page|
      page.step_anime = animate_steps
      page.graphic.character_name = sprite_name
      page.graphic.direction = rot
      page.trigger = 0
      page.list = page_list
      page.always_on_top = false
    end

    game_event = Game_Event.new(map_id, event)
    game_event.instance_variable_set(:@id, trainer_id)
    game_event.instance_variable_set(:@map, $game_map)
    game_event.character_name = sprite_name
    game_event.moveto(x, y)
    game_event.instance_variable_set(:@always_on_top, false)
    game_event.instance_variable_set(:@through, true)
    begin
      game_event.instance_variable_set(:@priority_type, 0)
      begin
        if event.pages && event.pages[0]
          event.pages[0].priority = 0 rescue nil
        end
      rescue
      end
    rescue
    end
    $game_map.events[trainer_id] = game_event

    TrainerHandlerUtils.force_map_refresh
  end

  def self.create_new_trainer(tr_type, tr_name, tr_version, pokemon_data)
    party = []
  
    pokemon_data.each do |data|
      species = data[:species]
      level = data[:level]
  
      if species && level.between?(1, GameData::GrowthRate.max_level)
        if data.keys.length > 2
          party.push({
            :species => species,
            :level => level,
            :moves => data[:moves] || [],
            :ability_index => data[:ability_index] || 0,
            :item => data[:item] || nil,
            :gender => data[:gender] || 0,
            :nature => data[:nature] || nil,
            :iv => data[:iv] || {},
            :ev => data[:ev] || {},
            :happiness => data[:happiness] || 70,
            :shininess => data[:shininess] || false
          })
        else
          party.push({
            :species => species,
            :level => level
          })
        end
      else
        raise "Invalid species or level for Pokémon: #{data.inspect}"
      end
    end
  
    if party.empty?
      raise "A trainer must have at least one Pokémon."
    end

    id_number = (GameData::Trainer::DATA.keys.length / 2) + 2
  
    trainer_data = {
      :id => [tr_type.to_sym, tr_name, tr_version],
      :id_number => id_number,
      :trainer_type => tr_type.to_sym,
      :name => tr_name,
      :version => tr_version,
      :items => [],
      :lose_text => "...",
      :pokemon => party
    }
  
    GameData::Trainer::DATA[id_number] = GameData::Trainer.new(trainer_data)
    GameData::Trainer::DATA[trainer_data[:id]] = GameData::Trainer.new(trainer_data)
  
    return trainer_data
  end

  def self.get_trainer(tr_type, tr_name, tr_version = 0, modern = false)
    trainer_key = [tr_type.to_sym, tr_name, tr_version]
    data_module = modern ? GameData::TrainerModern : GameData::Trainer
    return data_module::DATA[trainer_key]
  end

  def self.set_trainer(tr_type, tr_name, tr_version, trainer_data, modern = false)
    trainer_key = [tr_type.to_sym, tr_name, tr_version]
    data_module = modern ? GameData::TrainerModern : GameData::Trainer

    copied_trainer_data = trainer_data.clone
    copied_trainer_data.pokemon = trainer_data.pokemon.clone

    data_module::DATA[trainer_key] = copied_trainer_data
  end

  def self.register_trainer(tr_type, tr_name, tr_version, pokemon_data, gender=0, base_money=30)
    existing_type = GameData::TrainerType.try_get(tr_type)
    if existing_type
      return existing_type
    end

    new_trainer_type_id = GameData::TrainerType::DATA.keys.length + 1
    GameData::TrainerType.register({
      :id => tr_type,
      :id_number => new_trainer_type_id,
      :real_name => tr_type.to_s,
      :battle_BGM => "Battle trainer.ogg",
      :victory_BGM => "Victory trainer.ogg",
      :gender => gender,
      :base_money => base_money
    })
    GameData::TrainerType.save
    GameData::TrainerType.load
  end




  def self.spawn_trainer_event(
    tr_type:,
    tr_name:, 
    tr_version:, 
    pokemon_data:, 
    map_id:, 
    event_id:, 
    x:, 
    y:, 
    page_list:, 
    sprite_name: "002", 
    rotation: 2, 
    animate_steps: true
  )
    register_trainer(tr_type, tr_name, tr_version, pokemon_data)

    trainer = TrainerHandler.create_new_trainer(tr_type, tr_name, tr_version, pokemon_data)
    
    TrainerHandler.create_sprite_event(
      map_id, 
      event_id, 
      x, 
      y, 
      rotation, 
      sprite_name, 
      page_list, 
      animate_steps
    )
    return trainer
  end
end


#===============================================================================
# Follower Pokémon System
#===============================================================================
class FollowerPokemon
  attr_accessor :event
  attr_accessor :follower_index
  attr_accessor :pixel_offset
  
  def initialize
    @event = nil
    @follower_index = nil
    @pixel_offset = 64
  end
  
  def apply_pixel_offset
    return unless @event && @pixel_offset && @pixel_offset > 0
    
    begin
      current_real_x = @event.instance_variable_get(:@real_x) || (@event.x * Game_Map::REAL_RES_X)
      current_real_y = @event.instance_variable_get(:@real_y) || (@event.y * Game_Map::REAL_RES_Y)
      
      case $game_player.direction
      when 2
        current_real_y -= @pixel_offset
      when 4
        current_real_x += @pixel_offset
      when 6
        current_real_x -= @pixel_offset
      when 8
        current_real_y += @pixel_offset
      end
      
      @event.instance_variable_set(:@real_x, current_real_x)
      @event.instance_variable_set(:@real_y, current_real_y)
    rescue => e
    end
  end
  
  def clear_follower(mark_inactive = true)
    
    pbRemoveDependency2("FollowerPkmn") rescue nil
    
    if defined?($PokemonGlobal) && $PokemonGlobal.dependentEvents
      $PokemonGlobal.dependentEvents.delete_if { |e| e && e[8] == "FollowerPkmn" }
    end
    
    if defined?($PokemonTemp) && $PokemonTemp
      $PokemonTemp.dependentEvents.removeEventByName("FollowerPkmn") rescue nil
    end
    
    @event = nil
    @player_is_moving = 0
    
    if mark_inactive
      @follower_index = nil
      if defined?($PokemonGlobal)
        $PokemonGlobal.instance_variable_set(:@followerActive, false)
        $PokemonGlobal.instance_variable_set(:@followerIndex, nil)
      end
    end
    
    if defined?($PokemonGlobal)
      $PokemonGlobal.instance_variable_set(:@followerPending, false)
      $PokemonGlobal.instance_variable_set(:@followerPendingIndex, nil)
      $PokemonGlobal.instance_variable_set(:@followerPendingDirection, nil)
      $PokemonGlobal.instance_variable_set(:@followerPendingPattern, nil)
      $PokemonGlobal.instance_variable_set(:@followerPendingCharacter, nil)
      $PokemonGlobal.instance_variable_set(:@followerPendingStartPos, nil)
    end
    
    begin
      if $scene.is_a?(Scene_Map)
        $scene.updateSpritesets(true) if $scene.respond_to?(:updateSpritesets)
        Graphics.update
      end
    rescue
    end
  end

  def mark_inactive
    if defined?($PokemonGlobal)
      $PokemonGlobal.instance_variable_set(:@followerActive, false)
      $PokemonGlobal.instance_variable_set(:@followerIndex, nil)
    end
  end

  def place_next_to_player
    return unless @event
  
    target_x = $game_player.x
    target_y = $game_player.y
  
    case $game_player.direction
    when 2
      target_y -= 1
    when 4
      target_x += 1
    when 6
      target_x -= 1
    when 8
      target_y += 1
    end
  
    if target_x < 0 || target_y < 0 || target_x >= $game_map.width || target_y >= $game_map.height
      target_x = $game_player.x
      target_y = $game_player.y
    end

    candidates = []
    case $game_player.direction
    when 2
      candidates << [$game_player.x, $game_player.y - 1]
      candidates << [$game_player.x - 1, $game_player.y]
      candidates << [$game_player.x + 1, $game_player.y]
      candidates << [$game_player.x, $game_player.y + 1]
    when 4
      candidates << [$game_player.x + 1, $game_player.y]
      candidates << [$game_player.x, $game_player.y - 1]
      candidates << [$game_player.x, $game_player.y + 1]
      candidates << [$game_player.x - 1, $game_player.y]
    when 6
      candidates << [$game_player.x - 1, $game_player.y]
      candidates << [$game_player.x, $game_player.y - 1]
      candidates << [$game_player.x, $game_player.y + 1]
      candidates << [$game_player.x + 1, $game_player.y]
    when 8
      candidates << [$game_player.x, $game_player.y + 1]
      candidates << [$game_player.x - 1, $game_player.y]
      candidates << [$game_player.x + 1, $game_player.y]
      candidates << [$game_player.x, $game_player.y - 1]
    else
      candidates << [$game_player.x, $game_player.y]
      candidates << [$game_player.x - 1, $game_player.y]
      candidates << [$game_player.x + 1, $game_player.y]
      candidates << [$game_player.x, $game_player.y - 1]
      candidates << [$game_player.x, $game_player.y + 1]
    end

    moved = false
    candidates.each do |cx, cy|
      next if cx.nil? || cy.nil?
      next if cx < 0 || cy < 0 || cx >= $game_map.width || cy >= $game_map.height
      if cx == $game_player.x && cy == $game_player.y
        next
      end
      begin
        if @event.respond_to?(:moveto)
          @event.moveto(cx, cy)
        elsif @event.respond_to?(:x=) && @event.respond_to?(:y=)
          @event.x = cx
          @event.y = cy
        end
        moved = true
        break
      rescue => e
        next
      end
    end

    unless moved
      begin
        force_x = $game_player.x
        force_y = $game_player.y + 1
        if force_y >= $game_map.height
          force_x = $game_player.x
          force_y = $game_player.y
        end
        if @event.respond_to?(:moveto)
          @event.moveto(force_x, force_y)
        elsif @event.respond_to?(:x=) && @event.respond_to?(:y=)
          @event.x = force_x
          @event.y = force_y
        end
      rescue => e
      end
    end

    begin
      @event.instance_variable_set(:@priority_type, 0) if @event.respond_to?(:instance_variable_set)
      @event.instance_variable_set(:@always_on_top, false) if @event.respond_to?(:instance_variable_set)
      @event.through = true if @event.respond_to?(:through=)
    rescue
    end

    begin
      $scene.updateSpritesets(true) if $scene.is_a?(Scene_Map)
      Graphics.update
    rescue
    end

    @player_is_moving = 0
  end
end


#===============================================================================
# Follower Setup Functions
#===============================================================================
def get_follower_sprite_name(follower_pokemon, party_index = nil)
  return nil unless follower_pokemon
  
  # Skip triple fusions
  if follower_pokemon.respond_to?(:is_triple_fusion?) && follower_pokemon.is_triple_fusion?
    return nil
  end
  
  follower_sprite = nil
  
  if follower_pokemon.species_data.is_a?(GameData::FusedSpecies)
    head_species = follower_pokemon.species_data.head_pokemon.species
    body_species = follower_pokemon.species_data.body_pokemon.species
    
    gender = follower_pokemon.gender == 1 rescue false
    shiny = follower_pokemon.shiny? rescue false
    form = follower_pokemon.form rescue 0
    shadow = follower_pokemon.shadowPokemon? rescue false
    
    fused_species_name = follower_pokemon.species.to_s.upcase
    base_name = generate_fused_sprite_name(head_species.to_s.upcase, body_species.to_s.upcase, gender, false, form, shadow)
    
    custom_fused_sprite = nil
    use_generated = false
    
    stored_variation = party_index ? get_selected_sprite_variation(party_index) : nil
    
    if stored_variation.is_a?(Hash)
      if stored_variation[:type] == :component
        custom_fused_sprite = stored_variation[:folder]
      elsif stored_variation[:type] == :generated
        use_generated = true
      else
        custom_fused_sprite = "#{stored_variation[:folder]}/#{stored_variation[:name]}"
      end
    else
      check_names = [base_name, fused_species_name]
      target_folder = shiny ? "Custom Followers shiny" : "Custom Followers"
      
      check_names.each do |name|
        available_variations = get_sprite_variations(name, target_folder)
        
        if available_variations.length > 0
          selected_variation = available_variations[0]
          custom_fused_sprite = "#{target_folder}/#{selected_variation}"
          break
        end
      end
      
      if !custom_fused_sprite && shiny
        check_names.each do |name|
          available_variations = get_sprite_variations(name, "Custom Followers")
          
          if available_variations.length > 0
            selected_variation = available_variations[0]
            custom_fused_sprite = "Custom Followers/#{selected_variation}"
            break
          end
        end
      end
    end
    
    if custom_fused_sprite
      follower_sprite = custom_fused_sprite
    end
    
    if !custom_fused_sprite || use_generated
      fused_sprite_name = generate_fused_sprite_name(head_species, body_species, gender, shiny, form, shadow)
      follower_sprite = "Followers/FusedPokemon/#{fused_sprite_name}"
    end
  end
  
  if !follower_sprite
    gender = follower_pokemon.gender == 1 rescue false
    shiny = follower_pokemon.shiny? rescue false
    form = follower_pokemon.form rescue 0
    species_name = follower_pokemon.species.to_s.upcase
    form_suffix = (form && form > 0) ? "_#{form}" : ""
    
    if shiny
      custom_sprite = "Custom Followers shiny/#{species_name}#{form_suffix}"
      if check_sprite_exists_no_cache(custom_sprite)
        follower_sprite = custom_sprite
      end
    end
    
    if !follower_sprite
      custom_sprite = "Custom Followers/#{species_name}#{form_suffix}"
      if check_sprite_exists_no_cache(custom_sprite)
        follower_sprite = custom_sprite
      end
    end
    
    if !follower_sprite
      begin
        follower_sprite = FollowingPkmn.get_follower_sprite_name(follower_pokemon)
      rescue
        follower_sprite = "Followers/#{species_name}#{form_suffix}"
      end
    end
  end
  
  return follower_sprite
end

def setup_follower_pokemon(party_index = nil, silent = false)
  return unless $Follower
  
  party_index = $Follower.follower_index if party_index.nil?
  unless party_index
    return $Follower.clear_follower
  end
  
  follower_pokemon = $Trainer.party[party_index]
  unless follower_pokemon
    return $Follower.clear_follower
  end
  
  $Follower.follower_index = party_index
  
  follower_sprite = nil
  
  # Skip triple fusions - they don't have follower sprites
  if follower_pokemon.respond_to?(:is_triple_fusion?) && follower_pokemon.is_triple_fusion?
    pbMessage(_INTL("Triple fusions cannot follow you!")) unless silent
    $Follower.clear_follower
    return false
  end
  
  if follower_pokemon.species_data.is_a?(GameData::FusedSpecies)
    
    head_species = follower_pokemon.species_data.head_pokemon.species
    body_species = follower_pokemon.species_data.body_pokemon.species
    
    gender = follower_pokemon.gender == 1 rescue false
    shiny = follower_pokemon.shiny? rescue false
    form = follower_pokemon.form rescue 0
    shadow = follower_pokemon.shadowPokemon? rescue false
    
    fused_species_name = follower_pokemon.species.to_s.upcase
    base_name = generate_fused_sprite_name(head_species.to_s.upcase, body_species.to_s.upcase, gender, false, form, shadow)
    
    custom_fused_sprite = nil
    use_generated = false
    
    stored_variation = get_selected_sprite_variation(party_index)
    
    if stored_variation.is_a?(Hash)
      if stored_variation[:type] == :component
        custom_fused_sprite = stored_variation[:folder]
      elsif stored_variation[:type] == :generated
        use_generated = true
      else
        custom_fused_sprite = "#{stored_variation[:folder]}/#{stored_variation[:name]}"
      end
    else
      check_names = [base_name, fused_species_name]
      target_folder = shiny ? "Custom Followers shiny" : "Custom Followers"
      
      check_names.each do |name|
        available_variations = get_sprite_variations(name, target_folder)
        
        if available_variations.length > 0
          if stored_variation && available_variations.include?(stored_variation)
            selected_variation = stored_variation
          else
            selected_variation = available_variations[0]
          end
          custom_fused_sprite = "#{target_folder}/#{selected_variation}"
          break
        end
      end
      
      if !custom_fused_sprite && shiny
        check_names.each do |name|
          available_variations = get_sprite_variations(name, "Custom Followers")
          
          if available_variations.length > 0
            if stored_variation && available_variations.include?(stored_variation)
              selected_variation = stored_variation
            else
              selected_variation = available_variations[0]
            end
            custom_fused_sprite = "Custom Followers/#{selected_variation}"
            break
          end
        end
      end
    end
    
    if custom_fused_sprite
      follower_sprite = custom_fused_sprite
    end
    
    if !custom_fused_sprite || use_generated
      fused_folder = "Graphics/Characters/Followers/FusedPokemon"
      Dir.mkdir(fused_folder) unless Dir.exist?(fused_folder)
      
      fused_sprite_name = generate_fused_sprite_name(head_species, body_species, gender, shiny, form, shadow)
      fused_sprite_path = "#{fused_folder}/#{fused_sprite_name}.png"
      follower_sprite = "Followers/FusedPokemon/#{fused_sprite_name}"
      
      unless File.exist?(fused_sprite_path)
        
        head_factors = build_follower_factors(head_species, gender, shiny, form, shadow)
        body_factors = build_follower_factors(body_species, gender, shiny, form, shadow)
        
        head_sprite = find_valid_follower_sprite(head_factors)
        body_sprite = find_valid_follower_sprite(body_factors)
        
        head_path = "Graphics/Characters/#{head_sprite}"
        body_path = "Graphics/Characters/#{body_sprite}"
        
        if create_combined_follower_sprite(head_path, body_path, fused_sprite_path)
        else
          follower_sprite = "Followers/000"
        end
      end
    end
  end
  
  if !follower_sprite
    gender = follower_pokemon.gender == 1 rescue false
    shiny = follower_pokemon.shiny? rescue false
    form = follower_pokemon.form rescue 0
    species_name = follower_pokemon.species.to_s.upcase
    form_suffix = (form && form > 0) ? "_#{form}" : ""
    
    if shiny
      custom_sprite = "Custom Followers shiny/#{species_name}#{form_suffix}"
      if check_sprite_exists_no_cache(custom_sprite)
        follower_sprite = custom_sprite
      end
    end
    
    if !follower_sprite
      custom_sprite = "Custom Followers/#{species_name}#{form_suffix}"
      if check_sprite_exists_no_cache(custom_sprite)
        follower_sprite = custom_sprite
      end
    end
    
    if !follower_sprite
      begin
        follower_sprite = FollowingPkmn.get_follower_sprite_name(follower_pokemon)
      rescue
        follower_sprite = "Followers/#{species_name}#{form_suffix}"
      end
    end
  end
  
  if !follower_sprite
    pbMessage(_INTL("{1} cannot follow you!", follower_pokemon.name)) unless silent
    $Follower.clear_follower
    return false
  end
  
  # Verify the sprite file actually exists
  sprite_path = "Graphics/Characters/#{follower_sprite}.png"
  if !File.exist?(sprite_path)
    pbMessage(_INTL("{1} cannot follow you!", follower_pokemon.name)) unless silent
    $Follower.clear_follower
    return false
  end
  
  recreate_x = ($PokemonGlobal.instance_variable_get(:@followerRecreateX) rescue nil)
  recreate_y = ($PokemonGlobal.instance_variable_get(:@followerRecreateY) rescue nil)
  
  if recreate_x && recreate_y
    spawn_x = recreate_x
    spawn_y = recreate_y
    $PokemonGlobal.instance_variable_set(:@followerRecreateX, nil)
    $PokemonGlobal.instance_variable_set(:@followerRecreateY, nil)
  else
    spawn_x = $game_player.x
    spawn_y = $game_player.y
    begin
      case $game_player.direction
      when 2
        spawn_y -= 1
      when 4
        spawn_x += 1
      when 6
        spawn_x -= 1
      when 8
        spawn_y += 1
      end
      if spawn_x < 0 || spawn_y < 0 || spawn_x >= $game_map.width || spawn_y >= $game_map.height
        spawn_x = $game_player.x
        spawn_y = $game_player.y + 1
        if spawn_y >= $game_map.height
          spawn_x = $game_player.x
          spawn_y = $game_player.y
        end
      end
    rescue
      spawn_x = $game_player.x
      spawn_y = $game_player.y
    end
  end
  
  begin
    pbRemoveDependency2("FollowerPkmn") rescue nil
  rescue
  end
  
  follower_event_id = 6969
  
  $game_map.events.delete(follower_event_id) if $game_map.events[follower_event_id]
  
  rpgEvent = RPG::Event.new(spawn_x, spawn_y)
  rpgEvent.id = follower_event_id
  rpgEvent.name = "FollowerPkmn"
  
  page = RPG::Event::Page.new
  page.graphic.character_name = follower_sprite
  page.graphic.direction = 2
  page.move_type = 0
  page.always_on_top = false
  page.through = true
  rpgEvent.pages = [page]
  
  begin
    if follower_sprite.start_with?("Custom Followers")
      full_sprite_path = "Graphics/Characters/#{follower_sprite}"
      if defined?(pbClearBitmapCache) && File.exist?("#{full_sprite_path}.png")
        pbClearBitmapCache(full_sprite_path)
      end
    end
  rescue
  end
  
  gameEvent = Game_Event.new($game_map.map_id, rpgEvent)
  gameEvent.character_name = follower_sprite
  gameEvent.moveto(spawn_x, spawn_y)
  
  $game_map.events[follower_event_id] = gameEvent
  
  begin
    pbAddDependency(gameEvent, true)
  rescue => e
  end
  
  begin
    events = $PokemonGlobal.dependentEvents
    for i in 0...events.length
      if events[i] && events[i][1] == follower_event_id
        events[i][8] = "FollowerPkmn"
        break
      end
    end
  rescue => e
  end
  
  if defined?($PokemonGlobal)
    $PokemonGlobal.instance_variable_set(:@followerActive, true)
    $PokemonGlobal.instance_variable_set(:@followerIndex, party_index)
  end
  
  $Follower.event = gameEvent
  
  $Follower.apply_pixel_offset
  
  begin
    if defined?($PokemonTemp) && $PokemonTemp.respond_to?(:dependentEvents)
      dep_events = $PokemonTemp.dependentEvents
      if dep_events && dep_events.respond_to?(:updateDependentEvents)
        dep_events.updateDependentEvents
      end
    end
  rescue => e
  end
  
  begin
    if $scene.is_a?(Scene_Map)
      $scene.updateSpritesets(true) if $scene.respond_to?(:updateSpritesets)
      Graphics.update
    end
  rescue => e
  end
end

def initialize_trainer_with_follower(party_index = nil)
  return unless $Trainer && $Trainer.party.length > 0

  if !$Follower
    $Follower = FollowerPokemon.new
  end

  if !$Follower.event
    follower_active = defined?($PokemonGlobal) ? $PokemonGlobal.instance_variable_get(:@followerActive) : false
    if party_index || follower_active
      setup_follower_pokemon(party_index)
    else
      begin
        if defined?($PokemonGlobal) && $PokemonGlobal.respond_to?(:dependentEvents)
          deps = ($PokemonGlobal.dependentEvents rescue [])
          if deps && deps.any? { |e| e && e[8] == "FollowerPkmn" }
            pbRemoveDependency2("FollowerPkmn") rescue nil
          end
        end
      rescue
      end
    end
  end
end


def create_follower(party_index = nil, silent = false)
  return unless $game_map && $Trainer && $Trainer.party
  return unless $Trainer.party.length > 0
  
  follower_event_id = 6969

  if $game_map && $Trainer && $Trainer.party.length > 0
    if $Follower && $Follower.event
      $Follower.clear_follower
    end

    if !$Follower
      $Follower = FollowerPokemon.new
    end

    result = setup_follower_pokemon(party_index, silent)
    return result if result == false || result == nil
    
    # Store last follower index and trainer ID
    if defined?($PokemonGlobal) && party_index && defined?($Trainer)
      $PokemonGlobal.instance_variable_set(:@lastFollowerIndex, party_index)
      $PokemonGlobal.instance_variable_set(:@lastFollowerTrainerId, $Trainer.id)
    end
  end
  
  return true
end

#===============================================================================
# Follower System Menu
#===============================================================================

def follower_system_menu
  scene = FollowerSystemScene.new
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

class FollowerSystemScene < PokemonOption_Scene
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
    
    options << EnumOption.new(_INTL("Left Ctrl Toggle"), [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:follower_ctrl_toggle) ? 1 : 0 },
      proc { |value| ModSettingsMenu.set(:follower_ctrl_toggle, value == 1) },
      _INTL("Enable/disable Left Control key to quickly toggle follower on/off"))
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Follower System"), 0, 0, Graphics.width, 64, @viewport)
    
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
# Party Screen Integration
#===============================================================================
if defined?(PokemonPartyScreen) && !PokemonPartyScreen.method_defined?(:pbPokemonScreen_follower_system)
  class PokemonPartyScreen
    def pbPokemonScreen_follower_system; end
    
    alias pbPokemonScreen_before_follower_system pbPokemonScreen
    
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
            if defined?($Follower) && $Follower && $Follower.event && $Follower.follower_index
              if $Follower.follower_index == oldpkmnid
                $Follower.follower_index = pkmnid
                create_follower(pkmnid) if defined?(create_follower)
              elsif $Follower.follower_index == pkmnid
                $Follower.follower_index = oldpkmnid
                create_follower(oldpkmnid) if defined?(create_follower)
              end
            end
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
        
        if !pkmn.egg?
          if defined?(nuzlocke_relearn_enabled?) && nuzlocke_relearn_enabled?
            if (defined?(pbRelearnMoveScreen)) && (pkmn.respond_to?(:can_relearn_move?) ? (pkmn.can_relearn_move? != false) : true)
              commands[cmdRelearn = commands.length] = _INTL("Relearn Moves")
            end
          end
        end
        
        if !pkmn.egg? && pkmn.hp > 0 && defined?(nuzlocke_manual_faint)
          commands[cmdFaint = commands.length] = _INTL("Faint Pokemon")
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
        
        if cmdFaint >= 0 && command == cmdFaint && defined?(nuzlocke_manual_faint)
          if pbConfirm(_INTL("Are you sure you want to faint {1}?", pkmn.name))
            if nuzlocke_manual_faint(pkmn)
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
            if defined?(nuzlocke_egg_moves_enabled?) && nuzlocke_egg_moves_enabled? && defined?(MoveRelearnerScreen)
              begin
                scene = MoveRelearnerScene.new
                screen = MoveRelearnerScreen.new(scene)
                screen.pbStartScreen(pkmn)
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
            if defined?($Follower) && $Follower && $Follower.event && $Follower.follower_index
              if $Follower.follower_index == oldpkmnid
                $Follower.follower_index = pkmnid
                create_follower(pkmnid) if defined?(create_follower)
              elsif $Follower.follower_index == pkmnid
                $Follower.follower_index = oldpkmnid
                create_follower(oldpkmnid) if defined?(create_follower)
              end
            end
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
          if cmdUseItem >= 0 && subcmd == cmdUseItem 
            item = @scene.pbUseItem($PokemonBag, pkmn) {
              @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
            }
            if item
              pbUseItemOnPokemon(item, pkmn, self)
              pbRefreshSingle(pkmnid) if respond_to?(:pbRefreshSingle)
              pbRefresh if !respond_to?(:pbRefreshSingle)
            end
          elsif cmdGiveItem >= 0 && subcmd == cmdGiveItem 
            item = @scene.pbChooseItem($PokemonBag) {
              @scene.pbSetHelpText((@party.length > 1) ? _INTL("Choose a Pokémon.") : _INTL("Choose Pokémon or cancel."))
            }
            if item
              if pbGiveItemToPokemon(item, pkmn, self, pkmnid)
                pbRefreshSingle(pkmnid) if respond_to?(:pbRefreshSingle)
                pbRefresh if !respond_to?(:pbRefreshSingle)
              end
            end
          elsif cmdTakeItem >= 0 && subcmd == cmdTakeItem 
            if pbTakeItemFromPokemon(pkmn, self)
              pbRefreshSingle(pkmnid) if respond_to?(:pbRefreshSingle)
              pbRefresh if !respond_to?(:pbRefreshSingle)
            end
          elsif cmdMoveItem >= 0 && subcmd == cmdMoveItem 
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
          when 0   
            pbFadeOutIn {
              pbDisplayMail(pkmn.mail, pkmn)
            }
          when 1   
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






#===============================================================================
# Simple Follower Management During Surfing
#===============================================================================
Events.onMapUpdate += proc { |_sender, e|
  begin
    if defined?($PokemonGlobal) && $PokemonGlobal && defined?($Follower) && $Follower
      was_surfing = ($PokemonGlobal.instance_variable_get(:@wasSurfingLastFrame) rescue false)
      currently_surfing = ($PokemonGlobal.surfing rescue false)
      
      $PokemonGlobal.instance_variable_set(:@wasSurfingLastFrame, currently_surfing)
      
      if !was_surfing && currently_surfing
        $Follower.clear_follower(false) 
      elsif was_surfing && !currently_surfing
        if $Follower.follower_index
          setup_follower_pokemon($Follower.follower_index)
        end
      end
    end
  rescue => e
  end
}

def put_away_follower_for_surfing
  if $Follower
    $Follower.clear_follower(false)
    return true
  end
  return false
end

def restore_follower_after_surfing
  if $Follower && $Follower.follower_index
    setup_follower_pokemon($Follower.follower_index)
    return true
  end
  return false
end

#===============================================================================
# Event Hooks
#===============================================================================
Events.onMapUpdate += proc {
  if !defined?($Follower) || !$Follower
    $Follower = FollowerPokemon.new
  end
  
  # Check if follower Pokemon has fainted and put it away
  if defined?($Follower) && $Follower && $Follower.follower_index && defined?($Trainer) && $Trainer
    begin
      follower_pokemon = $Trainer.party[$Follower.follower_index] rescue nil
      if follower_pokemon && follower_pokemon.hp == 0
        $Follower.clear_follower
      end
    rescue => e
      # Silent fail
    end
  end
  
  if defined?($PokemonGlobal) && $PokemonGlobal
    unless $PokemonGlobal.instance_variable_get(:@wasSurfingLastFrame).is_a?(TrueClass) || $PokemonGlobal.instance_variable_get(:@wasSurfingLastFrame).is_a?(FalseClass)
      $PokemonGlobal.instance_variable_set(:@wasSurfingLastFrame, ($PokemonGlobal.surfing rescue false))
    end
  end
}

Events.onMapSceneChange += proc { |_sender, e|
  mapChanged = e[1] if e
  begin
    if defined?($PokemonGlobal) && $PokemonGlobal.respond_to?(:dependentEvents)
      deps = ($PokemonGlobal.dependentEvents rescue [])
      if deps && deps.length > 0
        has_follower = (defined?($Follower) && $Follower && $Follower.event)
        follower_active = ($PokemonGlobal.instance_variable_get(:@followerActive) rescue false)
        unless has_follower || follower_active
          deps.each_with_index do |entry, i|
            if entry && entry[8] == "FollowerPkmn"
              begin
                pbRemoveDependency2("FollowerPkmn") rescue nil
              rescue
              end
              break
            end
          end
        end
      end
    end
  rescue => err
  end
}

Events.onMapChange += proc {
  if $Trainer && $game_map
    map_id = $game_map.map_id rescue nil
    
    follower_active = false
    follower_index = nil
    
    if defined?($Follower) && $Follower && $Follower.event
      follower_active = true
      follower_index = $Follower.follower_index
    elsif defined?($PokemonGlobal)
      follower_active = $PokemonGlobal.instance_variable_get(:@followerActive) rescue false
      follower_index = $PokemonGlobal.instance_variable_get(:@followerIndex) rescue nil
    end
    
    if follower_active && follower_index
      
      begin
        if defined?($PokemonGlobal) && $PokemonGlobal.dependentEvents
          events = $PokemonGlobal.dependentEvents
          events.each do |entry|
            if entry && entry[8] == "FollowerPkmn"
              entry[2] = map_id
              break
            end
          end
        end
      rescue => e
      end
      
      if defined?($Follower) && $Follower
        begin
          follower_event = nil
          
          if defined?(pbGetDependency)
            begin
              follower_event = pbGetDependency("FollowerPkmn")
            rescue => e
            end
          else
          end
          
          if !follower_event
            if defined?($PokemonTemp) && $PokemonTemp.respond_to?(:dependentEvents)
              begin
                dep_events = $PokemonTemp.dependentEvents
                real_events = dep_events.instance_variable_get(:@realEvents)
                global_events = $PokemonGlobal.dependentEvents
                
                if global_events && real_events
                  global_events.each_with_index do |entry, i|
                    if entry && entry[8] == "FollowerPkmn"
                      if real_events[i]
                        follower_event = real_events[i]
                        break
                      else
                      end
                    end
                  end
                else
                end
              rescue => err
              end
            else
            end
          end
          
          if follower_event
            $Follower.event = follower_event
            $Follower.follower_index = follower_index
            $Follower.apply_pixel_offset if $Follower.respond_to?(:apply_pixel_offset)
          else
            $Follower.event = nil
          end
        rescue => e
          $Follower.event = nil
        end
      else
      end
    end
  end
}

begin
  class Game_Player
    if method_defined?(:pbHasDependentEvents?)
      alias_method :pbHasDependentEvents_follower_orig, :pbHasDependentEvents?
    end
    

    def pbHasDependentEvents?
      begin
        deps = ($PokemonGlobal.dependentEvents rescue [])
        return false if !deps || deps.length == 0
        deps.each do |entry|
          begin
            name = entry[8] rescue nil
            if name != "FollowerPkmn"
              return true
            end
          rescue
            return true
          end
        end
        return false
      rescue
        begin
          return pbHasDependentEvents_follower_orig
        rescue
          return ($PokemonGlobal.dependentEvents.length>0) rescue false
        end
      end
    end
  end
end

begin
rescue
end

# Clear follower data when loading a save to prevent cross-save contamination
if defined?(Events)
  Events.onMapChanging += proc { |_sender, _e|
    begin
      if defined?($Follower) && $Follower && defined?($PokemonGlobal) && defined?($Trainer)
        saved_trainer_id = $PokemonGlobal.instance_variable_get(:@follower_trainer_id)
        current_trainer_id = $Trainer.id rescue nil
        
        if saved_trainer_id && current_trainer_id && saved_trainer_id != current_trainer_id
          $Follower.clear_follower(false) if $Follower.respond_to?(:clear_follower)
          $Follower = nil
          $PokemonGlobal.instance_variable_set(:@follower_trainer_id, current_trainer_id)
          $PokemonGlobal.instance_variable_set(:@lastFollowerIndex, nil)
          $PokemonGlobal.instance_variable_set(:@lastFollowerTrainerId, nil)
          $PokemonGlobal.instance_variable_set(:@followerActive, false)
          $PokemonGlobal.instance_variable_set(:@followerIndex, nil)
        elsif !saved_trainer_id && current_trainer_id
          # First time setting trainer ID for this save
          $PokemonGlobal.instance_variable_set(:@follower_trainer_id, current_trainer_id)
        end
      elsif defined?($PokemonGlobal) && defined?($Trainer)
        $PokemonGlobal.instance_variable_set(:@follower_trainer_id, $Trainer.id) rescue nil
      end
    rescue => e
    end
  }
end

#===============================================================================
# Overworld Menu Handler Extension
#===============================================================================

if defined?(OverworldMenuHandler)
  class OverworldMenuHandler
    def show_follower_menu(parent_index = 0)
      return unless defined?($Trainer) && $Trainer && $Trainer.party && $Trainer.party.length > 0
      
      # Check for save switching and clear follower immediately if trainer IDs don't match
      if defined?($Follower) && $Follower && defined?($PokemonGlobal)
        saved_trainer_id = $PokemonGlobal.instance_variable_get(:@follower_trainer_id)
        current_trainer_id = $Trainer.id rescue nil
        
        if saved_trainer_id && current_trainer_id && saved_trainer_id != current_trainer_id
          # Different save detected - clear follower immediately
          $Follower.clear_follower(false) if $Follower.respond_to?(:clear_follower)
          $Follower = nil
          $PokemonGlobal.instance_variable_set(:@follower_trainer_id, current_trainer_id)
          $PokemonGlobal.instance_variable_set(:@lastFollowerIndex, nil)
          $PokemonGlobal.instance_variable_set(:@lastFollowerTrainerId, nil)
          $PokemonGlobal.instance_variable_set(:@followerActive, false)
          $PokemonGlobal.instance_variable_set(:@followerIndex, nil)
        elsif !saved_trainer_id && current_trainer_id
          # First time setting trainer ID for this save
          $PokemonGlobal.instance_variable_set(:@follower_trainer_id, current_trainer_id)
        end
      end
      
      # Build follower management menu
      commands = []
      cmdFollow = -1
      cmdPutAway = -1
      cmdSprite = -1
      
      follower_active = false
      current_follower_index = nil
      
      if defined?($Follower) && $Follower && $Follower.event
        follower_active = true
        current_follower_index = $Follower.follower_index
      end
      
      if !follower_active && defined?($PokemonGlobal)
        follower_active = $PokemonGlobal.instance_variable_get(:@followerActive) rescue false
        current_follower_index = $PokemonGlobal.instance_variable_get(:@followerIndex) rescue nil
      end
      
      commands[cmdFollow = commands.length] = "Follow Me"
      commands[cmdPutAway = commands.length] = "Put Away" if follower_active
      commands[cmdSprite = commands.length] = "Sprite Variation"
      commands[commands.length] = "Cancel"
      
      choice = @scene.pbShowCommands(commands, 0)
      
      if cmdFollow >= 0 && choice == cmdFollow
        # Build Pokemon selection command window
        pkmn_commands = []
        $Trainer.party.each_with_index do |pkmn, i|
          pkmn_commands << pkmn.name
        end
        pkmn_commands << _INTL("Cancel")
        
        # Create preview window
        preview = SpritePreviewWindow.new(nil, :left)
        
        cmdwindow = Window_CommandPokemonEx.new(pkmn_commands)
        cmdwindow.z = 99999
        cmdwindow.visible = true
        cmdwindow.resizeToFit(cmdwindow.commands)
        cmdwindow.x = Graphics.width - cmdwindow.width - 10
        cmdwindow.y = Graphics.height - cmdwindow.height - 10
        cmdwindow.index = 0
        
        last_index = -1
        
        # Show initial preview
        if $Trainer.party[0]
          pkmn = $Trainer.party[0]
          sprite_name = get_follower_sprite_name(pkmn, 0)
          preview.set_sprite(sprite_name, pkmn.name) if sprite_name
          last_index = 0
        end
        
        chosen = -1
        loop do
          preview.update
          cmdwindow.update
          
          # Update preview when selection changes
          if cmdwindow.index >= 0 && cmdwindow.index < $Trainer.party.length && cmdwindow.index != last_index
            pkmn = $Trainer.party[cmdwindow.index]
            sprite_name = get_follower_sprite_name(pkmn, cmdwindow.index)
            preview.set_sprite(sprite_name, pkmn.name) if sprite_name
            last_index = cmdwindow.index
          end
          
          if Input.trigger?(Input::BACK)
            pbPlayCancelSE
            chosen = -1
            break
          elsif Input.trigger?(Input::USE)
            if cmdwindow.index < $Trainer.party.length
              pbPlayDecisionSE
              chosen = cmdwindow.index
              break
            else
              pbPlayCancelSE
              chosen = -1
              break
            end
          end
        end
        
        preview.dispose
        cmdwindow.dispose
        
        if chosen >= 0 && chosen < $Trainer.party.length
          pkmn = $Trainer.party[chosen]
          if defined?(create_follower)
            result = create_follower(chosen, false)
            if result == true
              # Store last follower index and trainer ID
              if defined?($PokemonGlobal) && defined?($Trainer)
                $PokemonGlobal.instance_variable_set(:@lastFollowerIndex, chosen)
                $PokemonGlobal.instance_variable_set(:@lastFollowerTrainerId, $Trainer.id)
              end
              @scene.hide_party_sprites if @scene.respond_to?(:hide_party_sprites)
              pbMessage(_INTL("{1} is now following you!", pkmn.name))
              @scene.show_party_sprites if @scene.respond_to?(:show_party_sprites)
            end
          end
        end
      elsif cmdPutAway >= 0 && choice == cmdPutAway
        if defined?($Follower) && $Follower
          pkmn_name = ""
          if $Follower.follower_index && $Trainer.party[$Follower.follower_index]
            pkmn_name = $Trainer.party[$Follower.follower_index].name
          end
          $Follower.clear_follower
          @scene.hide_party_sprites if @scene.respond_to?(:hide_party_sprites)
          pbMessage(_INTL("{1} returned!", pkmn_name)) if pkmn_name != ""
          @scene.show_party_sprites if @scene.respond_to?(:show_party_sprites)
        end
      elsif cmdSprite >= 0 && choice == cmdSprite
        # Check if there's an active follower
        if !defined?($Follower) || !$Follower || !$Follower.event || $Follower.follower_index.nil?
          @scene.hide_party_sprites if @scene.respond_to?(:hide_party_sprites)
          pbMessage(_INTL("No active follower! Use 'Follow Me' first."))
          @scene.show_party_sprites if @scene.respond_to?(:show_party_sprites)
          return nil
        end
        
        chosen = $Follower.follower_index
        pkmn = $Trainer.party[chosen]
        
        if pkmn
          
          # Get sprite variations for this Pokemon
          sprite_variations = []
          if pkmn.species_data.is_a?(GameData::FusedSpecies)
            sprite_variations = get_fusion_sprite_variations(pkmn, chosen)
          else
            sprite_variations = get_regular_sprite_variations(pkmn, chosen)
          end
          
          if sprite_variations.length > 0
            var_commands = []
            sprite_variations.each do |var_data|
              if var_data[:display_name].empty?
                var_commands << "Fusion (Base)"
              else
                var_commands << var_data[:display_name].upcase
              end
            end
            var_commands << _INTL("Cancel")
            
            preview = SpritePreviewWindow.new
            
            cmdwindow = Window_CommandPokemonEx.new(var_commands)
            cmdwindow.z = 99999
            cmdwindow.visible = true
            cmdwindow.resizeToFit(cmdwindow.commands)
            cmdwindow.x = Graphics.width - cmdwindow.width - 10
            cmdwindow.y = Graphics.height - cmdwindow.height - 10
            cmdwindow.index = 0
            
            last_index = -1
            
            if sprite_variations[0]
              var_data = sprite_variations[0]
              if var_data[:type] == :component
                preview.set_sprite(var_data[:folder], var_commands[0])
              else
                preview.set_sprite("#{var_data[:folder]}/#{var_data[:name]}", var_commands[0])
              end
              last_index = 0
            end
            
            selected = -1
            loop do
              preview.update
              cmdwindow.update
              
              if cmdwindow.index >= 0 && cmdwindow.index < sprite_variations.length && cmdwindow.index != last_index
                var_data = sprite_variations[cmdwindow.index]
                if var_data[:type] == :component
                  preview.set_sprite(var_data[:folder], var_commands[cmdwindow.index])
                else
                  preview.set_sprite("#{var_data[:folder]}/#{var_data[:name]}", var_commands[cmdwindow.index])
                end
                last_index = cmdwindow.index
              end
              
              if Input.trigger?(Input::BACK)
                pbPlayCancelSE
                selected = -1
                break
              elsif Input.trigger?(Input::USE)
                if cmdwindow.index < sprite_variations.length
                  pbPlayDecisionSE
                  selected = cmdwindow.index
                  break
                else
                  pbPlayCancelSE
                  selected = -1
                  break
                end
              end
            end
            
            preview.dispose
            cmdwindow.dispose
            
            if selected >= 0 && selected < sprite_variations.length
              var_data = sprite_variations[selected]
              # Store the variation data as a hash
              set_selected_sprite_variation(chosen, var_data)
              
              # Force recreate the follower with new sprite by putting away and bringing back out
              if defined?($Follower) && $Follower && $Follower.follower_index == chosen
                pkmn_name = $Trainer.party[chosen].name
                # Put away
                $Follower.clear_follower
                # Wait a frame
                Graphics.update
                # Bring back out with new sprite
                create_follower(chosen)
                @scene.hide_party_sprites if @scene.respond_to?(:hide_party_sprites)
                pbMessage(_INTL("{1}'s sprite updated!", pkmn_name))
                @scene.show_party_sprites if @scene.respond_to?(:show_party_sprites)
              end
            end
          else
            @scene.hide_party_sprites if @scene.respond_to?(:hide_party_sprites)
            pbMessage(_INTL("No sprite variations available for {1}.", pkmn.name))
            @scene.show_party_sprites if @scene.respond_to?(:show_party_sprites)
          end
        end
      end
      
      return nil
    end
  end
end

#===============================================================================
# Overworld Menu Registration
#===============================================================================

if defined?(OverworldMenu)
  OverworldMenu.register(:follower, {
    label: "Follower",
    handler: proc { |screen|
      screen.show_follower_menu(0)
    },
    priority: 15,
    condition: proc { 
      defined?($Trainer) && $Trainer && $Trainer.party && $Trainer.party.length > 0
    },
    exit_on_select: true
  })
end

# ============================================================================
# MOD SETTINGS REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu)
  # Initialize default setting
  ModSettingsMenu.set(:follower_ctrl_toggle, true) if ModSettingsMenu.get(:follower_ctrl_toggle).nil?
  
  # Register the submenu button
  reg_proc = proc {
    ModSettingsMenu.register(:follower_system_menu, {
      name: "Follower System",
      type: :button,
      description: "Configure follower Pokemon settings and Left Control key toggle",
      on_press: proc {
        pbFadeOutIn {
          follower_system_menu
        }
      },
      category: "Major Systems",
      searchable: [
        "follower", "follow", "pokemon", "ctrl", "control",
        "toggle", "sprite", "variation"
      ]
    })
  }
  
  reg_proc.call
end

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Follower System",
    file: "08_Follower System.rb",
    version: "2.1.0",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/08_Follower%20System.rb",
    changelog_url: "https://github.com/Stonewallx/KIF-Mods/raw/refs/heads/main/Changelogs/Follower%20System.md",
    graphics: [
      {
        url: "https://github.com/Stonewallx/KIF-Mods/raw/refs/heads/main/Graphics/08_Follower%20System.zip"
      }
    ],
    dependencies: [
      {name: "01_Mod_Settings", version: "3.1.4"},
      {name: "01a_Overworld_Menu", version: "2.0.0"}
    ]
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["08_Follower System.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("FollowerSystem: Follower System #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end