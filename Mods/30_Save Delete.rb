#========================================
# Save Delete
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.0
# Author: Stonewall
# Delete Save Game Functionality with SPECIAL (D/(RS)) Input
#========================================

class PokemonLoad_Scene
  def pbChoose(commands, continue_idx)
    @sprites["cmdwindow"].commands = commands
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::USE)
        return @sprites["cmdwindow"].index
      elsif @sprites["cmdwindow"].index == continue_idx
        @sprites["leftarrow"].visible = true
        @sprites["rightarrow"].visible = true
        if Input.trigger?(Input::LEFT)
          return -3
        elsif Input.trigger?(Input::RIGHT)
          return -2
        elsif Input.trigger?(Input::SPECIAL)
          return -4
        end
      else
        @sprites["leftarrow"].visible = false
        @sprites["rightarrow"].visible = false
      end
    end
  end
end

class PokemonLoadScreen
  # Alias the original method if not already done
  unless method_defined?(:savedelete_orig_pbStartLoadScreen)
    alias savedelete_orig_pbStartLoadScreen pbStartLoadScreen
  end
  
  # Override to add version check and save delete functionality
  def pbStartLoadScreen
    # Run all the pre-checks and updates
    updateHttpSettingsFile
    updateCreditsFile
    updateCustomDexFile
    updateOnlineCustomSpritesFile
    newer_version = find_newer_available_version
    if newer_version
      if File.file?('.\INSTALL_OR_UPDATE.bat')
        update_answer = pbMessage(_INTL("Version {1} is now available! Update now?", newer_version), ["Yes","No"], 1)
        if update_answer == 0
          Process.spawn('.\INSTALL_OR_UPDATE.bat', "auto")
          exit
        end
      else
        pbMessage(_INTL("Version {1} is now available! Please check the game's official page to download the newest version.", newer_version))
      end
    end
    
    # Mod auto-update check (from Mod Settings) - runs after game version check
    begin
      if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:perform_auto_update_check)
        ModSettingsMenu.perform_auto_update_check
      end
    rescue
      # Silently fail to prevent blocking game startup
    end

    if $PokemonSystem && $PokemonSystem.shiny_cache == 1
      checkDirectory("Cache")
      checkDirectory("Cache/Shiny")
      Dir.glob("Cache/Shiny/*").each do |file|
        File.delete(file) if File.file?(file)
      end
      checkDirectory("Cache/Shiny/vanilla")
      Dir.glob("Cache/Shiny/vanilla/*").each do |file|
        File.delete(file) if File.file?(file)
      end
    end

    if ($game_temp.unimportedSprites && $game_temp.unimportedSprites.size > 0)
      handleReplaceExistingSprites()
    end
    if ($game_temp.nb_imported_sprites && $game_temp.nb_imported_sprites > 0)
      pbMessage(_INTL("{1} new custom sprites were imported into the game", $game_temp.nb_imported_sprites.to_s))
    end
    checkEnableSpritesDownload
    $game_temp.nb_imported_sprites = nil

    copyKeybindings()
    $KURAY_OPTIONSNAME_LOADED = false
    kurayeggs_main() if $KURAYEGGS_WRITEDATA
    
    # Now run the main load screen logic
    pbStartLoadScreen_WithDelete
  end
  
  # Separate method for the main load screen loop with delete functionality
  def pbStartLoadScreen_WithDelete

    save_file_list = SaveData::AUTO_SLOTS + SaveData::MANUAL_SLOTS
    first_time = true
    loop do
      if @selected_file
        @save_data = load_save_file(SaveData.get_full_path(@selected_file))
      else
        @save_data = {}
      end
      commands = []
      cmd_continue = -1
      cmd_new_game = -1
      cmd_options = -1
      cmd_language = -1
      cmd_mystery_gift = -1
      cmd_debug = -1
      cmd_quit = -1
      cmd_doc         = -1
      cmd_discord         = -1
      cmd_pifdiscord        = -1
      cmd_wiki        = -1
      cmd_save_delete_settings = -1
      show_continue = !@save_data.empty?
      new_game_plus = show_continue && (@save_data[:player].new_game_plus_unlocked || $DEBUG)

      if show_continue
        commands[cmd_continue = commands.length] = "#{@selected_file}"
        commands[cmd_mystery_gift = commands.length] = _INTL('Mystery Gift')
      end

      commands[cmd_new_game = commands.length] = _INTL('New Game')
      if new_game_plus
        commands[cmd_new_game_plus = commands.length] = _INTL('New Game +')
      end
      commands[cmd_options = commands.length] = _INTL('Options')
      commands[cmd_save_delete_settings = commands.length] = _INTL('Save Delete Settings')
      commands[cmd_discord = commands.length]     = _INTL('KIF Discord')
      commands[cmd_doc = commands.length]     = _INTL('KIF Documentation (Obsolete)')
      commands[cmd_pifdiscord = commands.length]     = _INTL('PIF Discord')
      commands[cmd_wiki = commands.length] = _INTL('Wiki')
      commands[cmd_language = commands.length] = _INTL('Language') if Settings::LANGUAGES.length >= 2
      commands[cmd_debug = commands.length] = _INTL('Debug') if $DEBUG
      commands[cmd_quit = commands.length] = _INTL('Quit Game')
      cmd_left = -3
      cmd_right = -2
      cmd_delete = -4

      map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
      @scene.pbStartScene(commands, show_continue, @save_data[:player],
                          @save_data[:frame_count] || 0, map_id)
      @scene.pbSetParty(@save_data[:player]) if show_continue
      if first_time
        @scene.pbStartScene2
        first_time = false
      else
        @scene.pbUpdate
      end

      loop do
        command = @scene.pbChoose(commands, cmd_continue)
        pbPlayDecisionSE if command != cmd_quit

        case command
        when cmd_continue
          @scene.pbEndScene
          Game.load(@save_data)
          $game_switches[SWITCH_V5_1] = true
          ensureCorrectDifficulty()
          setGameMode()
          $PokemonGlobal.alt_sprite_substitutions = {} if !$PokemonGlobal.alt_sprite_substitutions
          $PokemonGlobal.autogen_sprites_cache = {}
          return
        when cmd_new_game
          @scene.pbEndScene
          Game.start_new
          $PokemonGlobal.alt_sprite_substitutions = {} if !$PokemonGlobal.alt_sprite_substitutions
          return
        when cmd_new_game_plus
          @scene.pbEndScene
          Game.start_new(@save_data[:bag], @save_data[:storage_system], @save_data[:player])
          @save_data[:player].new_game_plus_unlocked = true
          return
        when cmd_pifdiscord
          openUrlInBrowser(Settings::PIF_DISCORD_URL)
        when cmd_wiki
          openUrlInBrowser(Settings::WIKI_URL)
        when cmd_doc
          openUrlInBrowser("https://docs.google.com/document/d/1O6pKKL62dbLcapO0c2zDG2UI-eN6uatYlt_0GSk1dbE")
          return
        when cmd_discord
          openUrlInBrowser(Settings::DISCORD_URL)
          return
        when cmd_mystery_gift
          pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
        when cmd_options
          pbFadeOutIn do
            scene = PokemonOption_Scene.new
            screen = PokemonOptionScreen.new(scene)
            screen.pbStartScreen(true)
          end
        when cmd_save_delete_settings
          pbFadeOutIn do
            save_delete_settings_menu
          end
        when cmd_language
          @scene.pbEndScene
          $PokemonSystem.language = pbChooseLanguage
          pbLoadMessages('Data/' + Settings::LANGUAGES[$PokemonSystem.language][1])
          if show_continue
            @save_data[:pokemon_system] = $PokemonSystem
            File.open(SaveData.get_full_path(@selected_file), 'wb') { |file| Marshal.dump(@save_data, file) }
          end
          $scene = pbCallTitle
          return
        when cmd_debug
          pbFadeOutIn { pbDebugMenu(false) }
        when cmd_quit
          pbPlayCloseMenuSE
          @scene.pbEndScene
          $scene = nil
          return
        when cmd_left
          @scene.pbCloseScene
          @selected_file = SaveData.get_prev_slot(save_file_list, @selected_file)
          break 
        when cmd_right
          @scene.pbCloseScene
          @selected_file = SaveData.get_next_slot(save_file_list, @selected_file)
          break 
        when cmd_delete
          if show_continue && @selected_file
            pbPlayDecisionSE
            file_count = count_related_save_files(@selected_file)
            autosave_count = file_count - 2  
            
            if autosave_count > 0
              delete_msg = _INTL("Delete '{1}' and {2} autosave(s)?", @selected_file, autosave_count)
            else
              delete_msg = _INTL("Delete the save file '{1}'?", @selected_file)
            end
            
            if pbConfirmMessageSerious(delete_msg)
              pbMessage(_INTL("Total files to be moved: {1}\\nThey will be moved to DELETED SAVES folder.\\wtnp[30]", file_count))
              if pbConfirmMessageSerious(_INTL("Are you absolutely sure?"))
                delete_current_save_and_related_files
                @scene.pbCloseScene
                temp_file = @selected_file
                @selected_file = nil
                save_file_list.each do |slot|
                  next if slot == temp_file
                  if File.file?(SaveData.get_full_path(slot))
                    @selected_file = slot
                    break
                  end
                end
                @selected_file = SaveData.get_newest_save_slot if @selected_file.nil?
                pbMessage(_INTL("Moved {1} files to DELETED SAVES.", file_count))
                break 
              end
            end
          end
        else
          pbPlayBuzzerSE
        end
      end
    end
  end

  def count_related_save_files(selected_file)
    return 0 if !selected_file
    
    save_dir = SaveData::SAVE_DIR
    count = 0
    
    file_path = SaveData.get_full_path(selected_file)
    count += 1 if File.file?(file_path)
    count += 1 if File.file?(file_path + '.bak')
    
    Dir.foreach(save_dir) do |filename|
      next if filename == '.' || filename == '..'
      next if filename == 'DELETED SAVES'
      
      full_path = File.join(save_dir, filename)
      next unless File.file?(full_path)
      
      if filename.start_with?(selected_file + " ") || 
         (filename.start_with?(selected_file + ".") && filename != selected_file + ".rxdata" && filename != selected_file + ".rxdata.bak")
        count += 1
      end
    end
    
    return count
  end
  
  def delete_current_save_and_related_files
    return if !@selected_file
    
    save_dir = SaveData::SAVE_DIR
    deleted_folder = File.join(save_dir, "DELETED SAVES")
    
    Dir.mkdir(deleted_folder) unless Dir.exist?(deleted_folder)
    
    files_to_move = []
    
    file_path = SaveData.get_full_path(@selected_file)
    files_to_move << file_path if File.file?(file_path)
    files_to_move << (file_path + '.bak') if File.file?(file_path + '.bak')
    
    Dir.foreach(save_dir) do |filename|
      next if filename == '.' || filename == '..'
      next if filename == 'DELETED SAVES' 
      
      full_path = File.join(save_dir, filename)
      next unless File.file?(full_path)
      
      if filename.start_with?(@selected_file + " ") || 
         filename.start_with?(@selected_file + ".") ||
         filename == @selected_file + ".rxdata"
        files_to_move << full_path unless files_to_move.include?(full_path)
      end
    end
    
    count = 0
    files_to_move.each do |file|
      begin
        if File.file?(file)
          dest_path = File.join(deleted_folder, File.basename(file))
          File.rename(file, dest_path)
          count += 1
        end
      rescue SystemCallError => e
      end
    end
  end
end

#===============================================================================
# Save Delete Settings Menu
#===============================================================================
class SaveDeleteSettings_Scene < PokemonOption_Scene
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Display info about deleted saves
    disk_info = get_deleted_saves_disk_info
    info_text = _INTL("{1} file(s) using {2}", disk_info[:count], disk_info[:size_text])
    
    options << ButtonOption.new(_INTL("Restore Deleted Saves"),
      proc {
        pbRestoreDeletedSaves
        @sprites["option"].refresh if @sprites["option"]
      },
      _INTL("Restore a previously deleted save file"))
    
    options << ButtonOption.new(_INTL("Clean Up Deleted Saves"),
      proc {
        pbCleanUpDeletedSaves
        @sprites["option"].refresh if @sprites["option"]
      },
      _INTL("Permanently delete all files in DELETED SAVES folder"))
    
    options << ButtonOption.new(_INTL("View Deleted Saves Folder"),
      proc {
        pbOpenDeletedSavesFolder
      },
      _INTL("Open the DELETED SAVES folder in Explorer"))
    
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    disk_info = get_deleted_saves_disk_info
    title_text = _INTL("Save Delete Settings ({1} files, {2})", disk_info[:count], disk_info[:size_text])
    
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      title_text, 0, 0, Graphics.width, 64, @viewport)
    
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
  
  def get_deleted_saves_disk_info
    save_dir = SaveData::SAVE_DIR
    deleted_folder = File.join(save_dir, "DELETED SAVES")
    
    count = 0
    total_bytes = 0
    
    if Dir.exist?(deleted_folder)
      Dir.foreach(deleted_folder) do |filename|
        next if filename == '.' || filename == '..'
        full_path = File.join(deleted_folder, filename)
        if File.file?(full_path)
          count += 1
          total_bytes += File.size(full_path)
        end
      end
    end
    
    size_text = format_file_size(total_bytes)
    
    return { count: count, total_bytes: total_bytes, size_text: size_text }
  end
  
  def format_file_size(bytes)
    return "0 bytes" if bytes == 0
    return "#{bytes} bytes" if bytes < 1024
    
    kb = bytes / 1024.0
    return "#{kb.round(1)} KB" if kb < 1024
    
    mb = kb / 1024.0
    return "#{mb.round(2)} MB" if mb < 1024
    
    gb = mb / 1024.0
    return "#{gb.round(2)} GB"
  end
  
  def pbRestoreDeletedSaves
    save_dir = SaveData::SAVE_DIR
    deleted_folder = File.join(save_dir, "DELETED SAVES")
    
    if !Dir.exist?(deleted_folder)
      pbMessage(_INTL("No deleted saves folder found."))
      return
    end
    
    save_files = []
    Dir.foreach(deleted_folder) do |filename|
      next if filename == '.' || filename == '..'
      next unless filename.end_with?(".rxdata")
      next if filename.end_with?(".rxdata.bak")
      save_files.push(filename)
    end
    
    if save_files.empty?
      pbMessage(_INTL("No deleted save files found to restore."))
      return
    end
    
    save_files.sort!
    
    commands = save_files + [_INTL("Cancel")]
    choice = pbMessage(_INTL("Which save file would you like to restore?"), commands, -1)
    
    # Check if user cancelled or selected Cancel option
    return if choice < 0 || choice >= save_files.length
    
    selected_file = save_files[choice]
    base_name = selected_file.gsub(".rxdata", "")
    
    if pbConfirmMessage(_INTL("Restore '{1}'?", base_name))
      restored_count = 0
      
      Dir.foreach(deleted_folder) do |filename|
        next if filename == '.' || filename == '..'
        
        if filename.start_with?(base_name + " ") || 
           filename.start_with?(base_name + ".") ||
           filename == selected_file
          
          source_path = File.join(deleted_folder, filename)
          dest_path = File.join(save_dir, filename)
          
          begin
            if File.file?(source_path)
              File.rename(source_path, dest_path)
              restored_count += 1
            end
          rescue SystemCallError => e
          end
        end
      end
      
      pbMessage(_INTL("Restored {1} files for '{2}'.", restored_count, base_name))
    end
  end
  
  def pbCleanUpDeletedSaves
    save_dir = SaveData::SAVE_DIR
    deleted_folder = File.join(save_dir, "DELETED SAVES")
    
    if !Dir.exist?(deleted_folder)
      pbMessage(_INTL("No deleted saves folder found."))
      return
    end
    
    file_count = 0
    total_bytes = 0
    Dir.foreach(deleted_folder) do |filename|
      next if filename == '.' || filename == '..'
      full_path = File.join(deleted_folder, filename)
      if File.file?(full_path)
        file_count += 1
        total_bytes += File.size(full_path)
      end
    end
    
    if file_count == 0
      pbMessage(_INTL("The deleted saves folder is already empty."))
      return
    end
    
    size_text = format_file_size(total_bytes)
    
    if pbConfirmMessageSerious(_INTL("Permanently delete all {1} files ({2})?", file_count, size_text))
      pbMessage(_INTL("This will free up {1} of disk space.\nThis cannot be undone!\\wtnp[30]", size_text))
      if pbConfirmMessageSerious(_INTL("Are you absolutely sure?"))
        deleted_count = 0
        Dir.foreach(deleted_folder) do |filename|
          next if filename == '.' || filename == '..'
          full_path = File.join(deleted_folder, filename)
          begin
            if File.file?(full_path)
              File.delete(full_path)
              deleted_count += 1
            end
          rescue SystemCallError
          end
        end
        pbMessage(_INTL("Permanently deleted {1} files.", deleted_count))
      end
    end
  end
  
  def pbOpenDeletedSavesFolder
    save_dir = SaveData::SAVE_DIR
    deleted_folder = File.join(save_dir, "DELETED SAVES")
    
    if !Dir.exist?(deleted_folder)
      pbMessage(_INTL("No deleted saves folder found."))
      Dir.mkdir(deleted_folder)
      pbMessage(_INTL("Created DELETED SAVES folder."))
    end
    
    begin
      system("start \"\" \"#{deleted_folder}\"")
      pbMessage(_INTL("Opening DELETED SAVES folder..."))
    rescue
      pbMessage(_INTL("Could not open folder. Path:\n{1}", deleted_folder))
    end
  end
end

# Simplified entry point
def save_delete_settings_menu
  scene = SaveDeleteSettings_Scene.new
  screen = PokemonOptionScreen.new(scene)
  screen.pbStartScreen
end

class SaveDeleteSettings_Screen
  def initialize(scene)
    @scene = scene
  end
  
  def pbStartScreen
    @scene.pbStartScreen
  end
end

#===============================================================================
# Register with ModSettingsMenu
#===============================================================================
if defined?(ModSettingsMenu)
  ModSettingsMenu.register(:save_delete_settings, {
    name: "Save Delete",
    type: :button,
    description: "Manage deleted save files, restore or permanently clean up old saves",
    on_press: proc {
      pbFadeOutIn {
        save_delete_settings_menu
      }
    },
    category: "Debug & Developer",
    searchable: ["save", "delete", "restore", "backup", "clean", "cleanup", "deleted saves"]
  })
end

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Save Delete",
    file: "30_Save Delete.rb",
    version: "2.0.0",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/30_Save%20Delete.rb",
    changelog_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/main/Changelogs/Save%20Delete.md",
    graphics: [],
    dependencies: []
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["30_Save Delete.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("SaveDelete: Save Delete #{version_str} loaded successfully") if defined?(ModSettingsMenu)
  rescue
    # Silently fail if we can't log
  end
end
