#========================================
# PC Organization
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
#========================================

class PokemonStorage
  def swapBoxes(box1, box2)
    return if box1 < 0 || box1 >= @boxes.length
    return if box2 < 0 || box2 >= @boxes.length
    return if box1 == box2
    
    @boxes[box1], @boxes[box2] = @boxes[box2], @boxes[box1]
  end
  
  def moveBox(fromIndex, toIndex)
    return if fromIndex < 0 || fromIndex >= @boxes.length
    return if toIndex < 0 || toIndex > @boxes.length
    return if fromIndex == toIndex
    
    box = @boxes.delete_at(fromIndex)
    
    adjustedIndex = toIndex
    adjustedIndex -= 1 if fromIndex < toIndex
    
    @boxes.insert(adjustedIndex, box)
  end
end

class PokemonStorageScene
  def self._pc_org_type_symbol_from_token(tok)
    t = tok.to_s.strip.downcase
    aliases = {
      "normal"=>:NORMAL, "nor"=>:NORMAL,
      "fighting"=>:FIGHTING, "fight"=>:FIGHTING, "fig"=>:FIGHTING, "fgt"=>:FIGHTING,
      "flying"=>:FLYING, "fly"=>:FLYING,
      "poison"=>:POISON, "poi"=>:POISON,
      "ground"=>:GROUND, "gro"=>:GROUND,
      "rock"=>:ROCK, "roc"=>:ROCK,
      "bug"=>:BUG,
      "ghost"=>:GHOST, "gho"=>:GHOST,
      "steel"=>:STEEL, "ste"=>:STEEL,
      "fire"=>:FIRE, "fir"=>:FIRE,
      "water"=>:WATER, "wat"=>:WATER,
      "grass"=>:GRASS, "gra"=>:GRASS,
      "electric"=>:ELECTRIC, "elec"=>:ELECTRIC, "ele"=>:ELECTRIC,
      "psychic"=>:PSYCHIC, "psy"=>:PSYCHIC, "psych"=>:PSYCHIC,
      "ice"=>:ICE,
      "dragon"=>:DRAGON, "drg"=>:DRAGON,
      "dark"=>:DARK, "dar"=>:DARK,
      "fairy"=>:FAIRY, "fair"=>:FAIRY
    }
    return aliases[t] if aliases.key?(t)
    names_to_sym = {
      "normal"=>:NORMAL, "fighting"=>:FIGHTING, "flying"=>:FLYING, "poison"=>:POISON, "ground"=>:GROUND, "rock"=>:ROCK,
      "bug"=>:BUG, "ghost"=>:GHOST, "steel"=>:STEEL, "fire"=>:FIRE, "water"=>:WATER, "grass"=>:GRASS,
      "electric"=>:ELECTRIC, "psychic"=>:PSYCHIC, "ice"=>:ICE, "dragon"=>:DRAGON, "dark"=>:DARK, "fairy"=>:FAIRY
    }
    names_to_sym.each { |name, sym| return sym if t.length >= 3 && name.start_with?(t) }
    return nil
  end
end

class PokemonStorageScene
  def pbChooseBoxWithRearrange(msg)
    baseCommands = []
    for i in 0...@storage.maxBoxes
      box = @storage[i]
      if box
        baseCommands.push(_INTL("{1} ({2}/{3})", box.name, box.nitems, box.length))
      end
    end
    
    selectedBoxes = []  
    inRearrangeMode = false
    currentIndex = @storage.currentBox
    
    msgwindow = Window_UnformattedTextPokemon.newWithSize("", 180, 0, Graphics.width - 180, 32)
    msgwindow.viewport = @viewport
    msgwindow.visible = true
    msgwindow.letterbyletter = false
    msgwindow.text = msg
    msgwindow.resizeHeightToFit(msg, Graphics.width - 180)
    msgwindow.x = Graphics.width - msgwindow.width
    msgwindow.y = Graphics.height - msgwindow.height
    
    cmdwindow = Window_CommandPokemon.new(baseCommands)
    cmdwindow.viewport = @viewport
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = Graphics.height - msgwindow.height if cmdwindow.height > Graphics.height - msgwindow.height
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = Graphics.height - msgwindow.height - cmdwindow.height
    cmdwindow.index = currentIndex
    
    previewWindow = Window_UnformattedTextPokemon.newWithSize("", 0, 0, 180, Graphics.height - msgwindow.height)
    previewWindow.viewport = @viewport
    previewWindow.visible = true
    previewWindow.baseColor = Color.new(88, 88, 80)
    previewWindow.shadowColor = Color.new(168, 184, 184)
    
    infoWindow = Window_UnformattedTextPokemon.newWithSize("", 0, Graphics.height - 60, 180, 60)
    infoWindow.viewport = @viewport
    infoWindow.visible = true
    infoWindow.baseColor = Color.new(248, 248, 248)
    infoWindow.shadowColor = Color.new(168, 184, 184)
    
    previewSprites = []

    rebuildPreview = Proc.new do |boxIndex|
      previewSprites.each { |sprite| sprite.dispose if sprite }
      previewSprites.clear
      box = @storage[boxIndex]
      maxPreview = 15
      xOffset = 8
      cols = 3
      rows = 5
      availableHeight = (Graphics.height - 60) - 16
      baseIcon = 48
      vPadding = [(availableHeight - rows * baseIcon) / (rows + 1), 4].max
      yOffset = vPadding - 20
      spriteSize = baseIcon
      
      infoText = ""
      if box
        count = 0
        box.length.times do |i|
          pkmn = box[i]
          if pkmn
            count += 1
            if previewSprites.length < maxPreview
              sprite = PokemonIconSprite.new(pkmn, @viewport)
              sprite.x = xOffset + (previewSprites.length % cols) * (spriteSize + 8)
              sprite.y = previewWindow.y + yOffset + (previewSprites.length / cols) * (spriteSize + vPadding)
              sprite.z = 99999
              previewSprites.push(sprite)
            end
          end
        end
        infoText = "Total: #{count}/#{box.length}"
      else
        infoText = "Empty Box"
      end
      infoWindow.text = infoText
    end
    
    ret = -1
    lastIndex = -1
    loop do
      Graphics.update
      Input.update
      msgwindow.update
      cmdwindow.update
      previewWindow.update
      infoWindow.update
      
      targetPreviewIndex = inRearrangeMode && selectedBoxes.any? ? selectedBoxes[0] : cmdwindow.index
      if targetPreviewIndex != lastIndex
        rebuildPreview.call(targetPreviewIndex)
        lastIndex = targetPreviewIndex
      end
      
      previewSprites.each { |sprite| sprite.update if sprite }
      
      self.update
      
      currentIndex = cmdwindow.index
      
      if Input.trigger?(Input::ACTION)
        if selectedBoxes.include?(currentIndex)
          selectedBoxes.clear
          pbPlayCancelSE
          inRearrangeMode = false
        elsif selectedBoxes.empty?
          selectedBoxes = [currentIndex]
          pbPlayDecisionSE
          inRearrangeMode = true
        else
          selectedBoxes = [currentIndex]
          pbPlayDecisionSE
          inRearrangeMode = true
        end
        
        commands = getCommandsWithMarkers(baseCommands, selectedBoxes)
        oldIndex = cmdwindow.index
        cmdwindow.commands = commands
        cmdwindow.index = oldIndex
      end
      
      if inRearrangeMode
        moved = false
        
        if Input.repeat?(Input::UP)
          selectedIndex = selectedBoxes[0]
          if selectedIndex > 0
            @storage.swapBoxes(selectedIndex, selectedIndex - 1)
            selectedBoxes[0] = selectedIndex - 1
            moved = true
            pbPlayCursorSE
          else
            @storage.moveBox(selectedIndex, @storage.maxBoxes)
            selectedBoxes[0] = @storage.maxBoxes - 1
            moved = true
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::DOWN)
          selectedIndex = selectedBoxes[0]
          if selectedIndex < @storage.maxBoxes - 1
            @storage.swapBoxes(selectedIndex, selectedIndex + 1)
            selectedBoxes[0] = selectedIndex + 1
            moved = true
            pbPlayCursorSE
          else
            @storage.moveBox(selectedIndex, 0)
            selectedBoxes[0] = 0
            moved = true
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::LEFT)
          selectedIndex = selectedBoxes[0]
          if selectedIndex >= 3
            targetIndex = selectedIndex - 3
            @storage.moveBox(selectedIndex, targetIndex)
            selectedBoxes[0] = targetIndex
            moved = true
            pbPlayCursorSE
          elsif selectedIndex > 0
            @storage.moveBox(selectedIndex, 0)
            selectedBoxes[0] = 0
            moved = true
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::RIGHT)
          selectedIndex = selectedBoxes[0]
          if selectedIndex <= @storage.maxBoxes - 4
            targetIndex = selectedIndex + 3
            actualTarget = targetIndex + 1
            @storage.moveBox(selectedIndex, actualTarget)
            selectedBoxes[0] = targetIndex
            moved = true
            pbPlayCursorSE
          elsif selectedIndex < @storage.maxBoxes - 1
            @storage.moveBox(selectedIndex, @storage.maxBoxes)
            selectedBoxes[0] = @storage.maxBoxes - 1
            moved = true
            pbPlayCursorSE
          end
        end
        
        if moved
          baseCommands.clear
          for i in 0...@storage.maxBoxes
            box = @storage[i]
            if box
              baseCommands.push(_INTL("{1} ({2}/{3})", box.name, box.nitems, box.length))
            end
          end
          
          commands = getCommandsWithMarkers(baseCommands, selectedBoxes)
          cmdwindow.commands = commands
          cmdwindow.index = selectedBoxes[0]
          
          pbRefresh
          rebuildPreview.call(selectedBoxes[0])
          lastIndex = selectedBoxes[0]
        end
      end
      
      if Input.trigger?(Input::USE)
        if !inRearrangeMode
          ret = cmdwindow.index
          pbPlayDecisionSE
          break
        end
      end
      
      if Input.trigger?(Input::BACK)
        selectedBoxes.clear
        inRearrangeMode = false
        ret = -1
        pbPlayCancelSE
        break
      end
    end
    
    previewSprites.each { |sprite| sprite.dispose if sprite }
    previewSprites.clear
    previewWindow.dispose
    infoWindow.dispose
    
    msgwindow.dispose
    cmdwindow.dispose
    Input.update
    return ret
  end
  
  def getCommandsWithMarkers(baseCommands, selectedBoxes)
    commands = []
    baseCommands.each_with_index do |cmd, i|
      if selectedBoxes.include?(i)
        commands.push(cmd + " +")  
      else
        commands.push(cmd)
      end
    end
    return commands
  end
  
  unless method_defined?(:_old_pbChooseBox_beforeRearrange)
    alias _old_pbChooseBox_beforeRearrange pbChooseBox
  end
  def pbChooseBox(msg)
    pbChooseBoxWithRearrange(msg)
  end
end

class PokemonStorageScreen
  unless method_defined?(:_old_pbBoxCommands_beforeRearrange)
    alias _old_pbBoxCommands_beforeRearrange pbBoxCommands
  end
  
  def pbBoxCommands
    if !$PokemonSystem.respond_to?(:box_name_templates)
      $PokemonSystem.class.send(:attr_accessor, :box_name_templates)
      $PokemonSystem.box_name_templates = {}
    end
    
    ret = _old_pbBoxCommands_beforeRearrange
    return ret
  end
end

class PokemonStorageScene
  def pbEnsureTemplateStorage
    if !$PokemonSystem.respond_to?(:box_name_templates)
      $PokemonSystem.class.send(:attr_accessor, :box_name_templates)
      $PokemonSystem.box_name_templates = {}
    end
    begin
      if !$PC_ORG_TEMPLATES_LOADED && defined?(kurayjson_load)
        path = pc_org_templates_kro_path
        if File.exists?(path)
          loaded = kurayjson_load(path) rescue nil
          if loaded.is_a?(Hash)
            $PokemonSystem.box_name_templates = loaded
          end
        end
        $PC_ORG_TEMPLATES_LOADED = true
      end
    rescue
    end
  end
  
  def pc_org_templates_kro_path
    begin
      return RTP.getSaveFolder + "\\PC_Organization_BoxTemplates.kro"
    rescue
      return File.join('.', 'PC_Organization_BoxTemplates.kro')
    end
  end
  
  def pc_org_save_templates_to_kro
    begin
      return false unless defined?(kurayjson_save)
      data = $PokemonSystem.box_name_templates
      return false unless data.is_a?(Hash)
      kurayjson_save(pc_org_templates_kro_path, data)
      return true
    rescue
      return false
    end
  end
  
  def pbSaveBoxNameTemplate
    pbEnsureTemplateStorage
    names = []
    for i in 0...@storage.maxBoxes
      names << (@storage[i]&.name || _INTL("Box {1}", i+1))
    end
    tmpl_name = pbEnterText(_INTL("Template name:"), 0, 20)
    return if !tmpl_name || tmpl_name.empty?
    $PokemonSystem.box_name_templates[tmpl_name] = names
    pbDisplay(_INTL("Saved template '{1}'.", tmpl_name))
    pc_org_save_templates_to_kro
  end
  
  def pbLoadBoxNameTemplate
    pbEnsureTemplateStorage
    templates = $PokemonSystem.box_name_templates
    if templates.nil? || templates.empty?
      pbDisplay(_INTL("No templates saved."))
      return
    end
    names = templates.keys
    idx = pbShowCommands(_INTL("Load which template?"), names)
    return if idx < 0
    tmpl_name = names[idx]
    arr = templates[tmpl_name]
    limit = [arr.length, @storage.maxBoxes].min
    for i in 0...limit
      if @storage[i]
        @storage[i].name = arr[i]
      end
    end
    @sprites["box"].refreshBox = true if @sprites["box"]
    pbRefresh
  end
  
  def pbDeleteBoxNameTemplate
    pbEnsureTemplateStorage
    templates = $PokemonSystem.box_name_templates
    if templates.nil? || templates.empty?
      pbDisplay(_INTL("No templates to delete."))
      return
    end
    names = templates.keys
    idx = pbShowCommands(_INTL("Delete which template?"), names)
    return if idx < 0
    tmpl_name = names[idx]
    if pbConfirmMessage(_INTL("Delete template '{1}'?", tmpl_name))
      templates.delete(tmpl_name)
      pbDisplay(_INTL("Deleted template '{1}'.", tmpl_name))
      pc_org_save_templates_to_kro
    end
  end
  
  unless method_defined?(:_old_pbBoxName_beforeTemplates)
    alias _old_pbBoxName_beforeTemplates pbBoxName
  end
  
  def pbSearchPokemon
    searchName = pbEnterText(_INTL("Search:"), 0, 24)
    return if !searchName || searchName.empty?
    
    results = []
    for boxNum in 0...@storage.maxBoxes
      box = @storage[boxNum]
      next if !box
      box.length.times do |slot|
        pkmn = box[slot]
        if pkmn
          match_found = false
          
          if pkmn.name.downcase.include?(searchName.downcase)
            match_found = true
          end
          
          species_id = pkmn.species
          
          begin
            species_name = GameData::Species.get(species_id).name
            if species_name.downcase.include?(searchName.downcase)
              match_found = true
            end
          rescue
          end
          
          if defined?(species_is_fusion) && species_is_fusion(species_id)
            begin
              body_species = get_body_species_from_symbol(species_id)
              body_name = GameData::Species.get(body_species).name
              if body_name.downcase.include?(searchName.downcase)
                match_found = true
              end
            rescue
            end
            
            begin
              head_species = get_head_species_from_symbol(species_id)
              head_name = GameData::Species.get(head_species).name
              if head_name.downcase.include?(searchName.downcase)
                match_found = true
              end
            rescue
            end
            
            begin
              if pkmn.fSpecies
                fused_species_name = GameData::Species.get(pkmn.fSpecies).name
                if fused_species_name.downcase.include?(searchName.downcase)
                  match_found = true
                end
              end
            rescue
            end
          end
          
          if pkmn.ability
            begin
              ability_name = GameData::Ability.get(pkmn.ability).name
              if ability_name.downcase.include?(searchName.downcase)
                match_found = true
              end
            rescue
            end
          end
          
          if pkmn.item
            begin
              item_name = GameData::Item.get(pkmn.item).name
              if item_name.downcase.include?(searchName.downcase)
                match_found = true
              end
            rescue
            end
            
            if searchName.downcase == "item"
              match_found = true
            end
          end

          begin
            if pkmn.nature
              nat_name = GameData::Nature.get(pkmn.nature).name
              if nat_name && nat_name.downcase.include?(searchName.downcase)
                match_found = true
              end
            end
          rescue
          end
          
          begin
            t1sym = (pkmn.type1 ? GameData::Type.get(pkmn.type1).id : nil) rescue nil
            t2sym = (pkmn.type2 ? GameData::Type.get(pkmn.type2).id : nil) rescue nil
            query = searchName.downcase.strip
            if query.include?("/")
              parts = query.split("/", 2).map { |s| s.strip }
              sym1 = PokemonStorageScene._pc_org_type_symbol_from_token(parts[0])
              sym2 = PokemonStorageScene._pc_org_type_symbol_from_token(parts[1])
              if sym1 && sym2 && t1sym && t2sym
                if (t1sym == sym1 && t2sym == sym2) || (t1sym == sym2 && t2sym == sym1)
                  match_found = true
                end
              end
            else
              sy = PokemonStorageScene._pc_org_type_symbol_from_token(query)
              if sy
                if (t1sym && t1sym == sy) || (t2sym && t2sym == sy)
                  match_found = true
                end
              else
                t1name = (pkmn.type1 ? GameData::Type.get(pkmn.type1).name.downcase : nil) rescue nil
                t2name = (pkmn.type2 ? GameData::Type.get(pkmn.type2).name.downcase : nil) rescue nil
                if t1name && t1name.include?(query)
                  match_found = true
                elsif t2name && t2name.include?(query)
                  match_found = true
                end
              end
            end
          rescue
          end
          
          begin
            query = searchName.strip
            if query =~ /^bst\s*(>=?|<=?)\s*(\d+)$/i
              op = $1
              threshold = $2.to_i
              bst = pkmn.baseStats[:HP] + pkmn.baseStats[:ATTACK] + pkmn.baseStats[:DEFENSE] +
                    pkmn.baseStats[:SPECIAL_ATTACK] + pkmn.baseStats[:SPECIAL_DEFENSE] + pkmn.baseStats[:SPEED]
              case op
              when ">"
                match_found = true if bst > threshold
              when ">="
                match_found = true if bst >= threshold
              when "<"
                match_found = true if bst < threshold
              when "<="
                match_found = true if bst <= threshold
              end
            end
          rescue
          end
          
          if match_found
            results.push([boxNum, slot, box.name, pkmn.name])
          end
        end
      end
    end
    
    if results.empty?
      pbDisplay(_INTL("No Pokémon found matching '{1}'.", searchName))
      return
    end
    
    resultNames = []
    results.each do |boxNum, slot, boxName, pkmnName|
      resultNames.push(_INTL("{1} in {2}", pkmnName, boxName))
    end
    resultNames.push(_INTL("Cancel"))
    
    choice = pbShowCommands(_INTL("Found {1} result(s)", results.length), resultNames)
    return if choice < 0 || choice >= results.length
    
    selectedBox, selectedSlot = results[choice][0], results[choice][1]
    
    if @storage.currentBox != selectedBox
      pbSwitchBoxToRight(selectedBox) if selectedBox > @storage.currentBox
      pbSwitchBoxToLeft(selectedBox) if selectedBox < @storage.currentBox
      @storage.currentBox = selectedBox
    end
    
    @selection = selectedSlot
    pbSetArrow(@sprites["arrow"], selectedSlot)
    pbUpdateOverlay(selectedSlot)
    pbHardRefresh
  end
  
  def pbBoxName(helptext, minchars, maxchars)
    if !$PokemonSystem.respond_to?(:box_name_templates)
      $PokemonSystem.class.send(:attr_accessor, :box_name_templates)
      $PokemonSystem.box_name_templates = {}
    end
    
    nameMenu = [
      _INTL("Rename Box"),
      _INTL("Templates"),
      _INTL("Search Pokémon"),
      _INTL("Cancel")
    ]
    nameChoice = pbShowCommands(_INTL("Name options"), nameMenu)
    case nameChoice
    when 0
      _old_pbBoxName_beforeTemplates(helptext, minchars, maxchars)
    when 1
      templates_menu = [
        _INTL("Save Template"),
        _INTL("Load Template"),
        _INTL("Delete Template"),
        _INTL("Cancel")
      ]
      templatesChoice = pbShowCommands(_INTL("Templates"), templates_menu)
      case templatesChoice
      when 0
        pbSaveBoxNameTemplate
      when 1
        pbLoadBoxNameTemplate
      when 2
        pbDeleteBoxNameTemplate
      end
    when 2
      pbSearchPokemon
    end
  end
end

# Add L/R box switching when holding a Pokémon in PC
class PokemonStorageScene
  alias _pcBoxRearrange_pbSelectBoxInternal pbSelectBoxInternal
  
  def pbSelectBoxInternal(_party)
    selection = @selection
    pbSetArrow(@sprites["arrow"], selection)
    pbUpdateOverlay(selection)
    pbSetMosaic(selection)
    loop do
      Graphics.update
      Input.update
      key = -1
      
      rBoxSwitch = false
      if Input.press?(Input::R)
        if Input.trigger?(Input::LEFT) || Input.trigger?(Input::RIGHT)
          rBoxSwitch = true
        end
      end
      
      if !rBoxSwitch
        key = Input::DOWN if Input.repeat?(Input::DOWN)
        key = Input::RIGHT if Input.repeat?(Input::RIGHT)
        key = Input::LEFT if Input.repeat?(Input::LEFT)
        key = Input::UP if Input.repeat?(Input::UP)
      end
      
      if key >= 0
        pbPlayCursorSE
        selection = pbChangeSelection(key, selection)
        pbSetArrow(@sprites["arrow"], selection)
        if selection == -4
          nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
        elsif selection == -5
          nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
        end
        selection = -1 if selection == -4 || selection == -5
        pbUpdateOverlay(selection)
        pbSetMosaic(selection)
        if @screen.multiSelectRange
          pbUpdateSelectionRect(@storage.currentBox, selection)
        end
      end
      self.update
      
      if Input.press?(Input::R)
        if Input.trigger?(Input::LEFT)
          pbPlayCursorSE
          nextbox = (@storage.currentBox + @storage.maxBoxes - 1) % @storage.maxBoxes
          pbSwitchBoxToLeft(nextbox)
          @storage.currentBox = nextbox
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        elsif Input.trigger?(Input::RIGHT)
          pbPlayCursorSE
          nextbox = (@storage.currentBox + 1) % @storage.maxBoxes
          pbSwitchBoxToRight(nextbox)
          @storage.currentBox = nextbox
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        elsif Input.trigger?(Input::SPECIAL)
          # R + (RS) for search function
          if @command == 0 && defined?(ModSettingsMenu) && ModSettingsMenu.get(:pc_org_search_button) == 1
            pbPlayDecisionSE if defined?(pbPlayDecisionSE)
            pbSearchPokemon
            selection = @selection
            pbSetArrow(@sprites["arrow"], selection)
            pbUpdateOverlay(selection)
            pbSetMosaic(selection)
          end
        end
      elsif Input.trigger?(Input::SPECIAL) 
        if selection != -1
          pbPlayCursorSE
          selection = -1
          pbSetArrow(@sprites["arrow"], selection)
          pbUpdateOverlay(selection)
          pbSetMosaic(selection)
        end
      elsif Input.trigger?(Input::ACTION) && @command == 0 
        pbPlayDecisionSE
        pbNextCursorMode
      elsif Input.trigger?(Input::BACK)
        @selection = selection
        return nil
      elsif Input.trigger?(Input::USE)
        @selection = selection
        if selection >= 0
          return [@storage.currentBox, selection]
        elsif selection == -1 
          return [-4, -1]
        elsif selection == -2 
          return [-2, -1]
        elsif selection == -3 
          return [-3, -1]
        end
      end
    end
  end
end

# ============================================================================
# MOD SETTINGS REGISTRATION
# ============================================================================
# SpacerOption Class (for vertical spacing)
class SpacerOption < Option
  attr_reader :name
  attr_reader :values
  
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

class PCOrganizationScene < PokemonOption_Scene
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
  
  def pbGetOptions(inloadscreen = false)
    options = [
      EnumOption.new(_INTL('Search Button'), [_INTL('Off'), _INTL('On')],
        proc { ModSettingsMenu.get(:pc_org_search_button) || 1 },
        proc { |value| ModSettingsMenu.set(:pc_org_search_button, value) },
        _INTL('Press R+(RS) in PC to search for Pokemon'))
    ]
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("PC Organization"), 0, 0, Graphics.width, 64, @viewport)
    
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
    ModSettingsMenu.register(:pc_organization, {
      name: "PC Organization",
      type: :button,
      description: "Configure PC Organization settings",
      on_press: proc {
        pbFadeOutIn {
          scene = PCOrganizationScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      },
      category: "Quality of Life",
      searchable: [
        "pc", "organization", "box", "boxes", "search", "rearrange",
        "pokemon", "storage", "organize"
      ]
    })
  }
  
  reg_proc.call
end

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
# Register this mod for auto-updates
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "PC Organization",
    file: "07_PC Organization.rb",
    version: "2.0.0",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/main/Mods/07_PC%20Organization.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/main/Changelogs/PC%20Organization.md",
    graphics: [],
    dependencies: [
      {name: "01_Mod_Settings", version: "3.1.4"}
    ]
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["07_PC Organization.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("PCOrganization: PC Organization #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
