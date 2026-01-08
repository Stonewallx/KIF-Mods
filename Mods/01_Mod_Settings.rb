#========================================
# Mod Settings Menu
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 3.0.0
# Author: Stonewall
#========================================
#
# NEW IN V3.0: PREDEFINED CATEGORIES AND SEARCH
# ==============================================
# Use these predefined categories when registering settings:
#
# AVAILABLE CATEGORIES:
#   "Interface"     - UI, menus, text speed, visual interface
#   "Features & Systems"    - Major features like seasons, weather, followers
#   "Quality of Life"       - Convenience features, item management, shortcuts
#   "Battle & Combat"       - Battle mechanics, move changes, ability tweaks
#   "Economy & Rewards"     - Money, shops, pickup, loot, prizes
#   "Difficulty & Challenge" - Nuzlocke, boss system, trainer control, challenge modes
#   "Encounters & Spawns"   - Wild encounters, hordes, randomizers, spawn rates
#   "Training & Stats"      - EVs, IVs, experience, stat modifications
#   "Uncategorized"         - Settings without assigned categories
#   "Debug & Developer"     - Testing tools, debug options
#
# USAGE:
#   ModSettingsMenu.register_toggle(
#     :my_setting,
#     "My Setting",
#     "Description",
#     0,  # default
#     "Quality of Life"  # <-- Use one of the categories above
#   )
#
# SEARCH:
#   Press Left Control to search settings by name or description
#   Press Left Control again to clear search
#
# NOTE: Category order is managed right below.
# Use the predefined ones. If you feel like I missed a category that should be added, then please contact me.


### 2. Mod Dependency Support
# **Manifest Format:**
# ```json
# {
#  "ModName": {
#     "version": "1.0.0",
#     "download_url": "...",
#     "dependencies": [
#       "RequiredModName",
#       {"name": "AnotherMod", "version": "2.0.0"}
#     ]
#   }
# }
#
#========================================

# ============================================================================
# PREDEFINED CATEGORIES CONFIGURATION
# ============================================================================
# Edit the priority values here to change the order categories appear in.
# Lower priority = appears first. Do not change the category names.
# ============================================================================
MOD_CATEGORIES = [
  {name: "Interface",     priority: 10, description: "UI, menus, and visual interface options"},
  {name: "Features & Systems",    priority: 20, description: "Major gameplay systems and features"},
  {name: "Quality of Life",       priority: 30, description: "Convenience features and shortcuts"},
  {name: "Battle & Combat",       priority: 40, description: "Battle mechanics and move changes"},
  {name: "Economy & Rewards",     priority: 50, description: "Money, shops, and item rewards"},
  {name: "Difficulty & Challenge", priority: 60, description: "Challenge modes and difficulty options"},
  {name: "Encounters & Spawns",   priority: 70, description: "Wild encounters and spawn settings"},
  {name: "Training & Stats",      priority: 80, description: "EV/IV training and stat modifications"},
  {name: "Uncategorized",         priority: 900, description: "Settings without assigned categories"},
  {name: "Debug & Developer",     priority: 999, description: "Testing and debug tools"},
  {name: "-----------------",     priority: 1000, description: "Separator" },
]

# ============================================================================
# MOD SETTINGS MENU - CORE MODULE
# ============================================================================
# This module provides a centralized system for mods to register their settings
# and display them in a unified "Mod Settings" menu accessible from the Options.
# It handles storage, retrieval, and persistence of mod configuration values.
# ============================================================================

module ModSettingsMenu
  # Debug log file path
  MOD_DEBUG_FILE = "ModsDebug.txt"
  
  # Write debug message to ModsDebug.txt file
  def self.debug_log(message)
    begin
      File.open(MOD_DEBUG_FILE, "a") do |f|
        f.puts("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{message}")
      end
    rescue
      # Silently fail if we can't write to debug file
    end
  end
  
  # Special category constant - options with this category appear without headers
  NOCATEGORY = "__nocategory__"
  
  # Array to store all registered mod settings/options
  @registry = []
  # Array to store predefined categories (initialized from MOD_CATEGORIES)
  @categories = []
  
  class << self
    # Returns the registry of all registered mod settings
    # Each entry contains a key and an option object (toggle, slider, enum, etc.)
    def registry
      @registry ||= []
    end
    
    # Returns the registry of predefined categories
    # Categories are loaded from MOD_CATEGORIES constant
    def categories
      if @categories.nil? || @categories.empty?
        # Initialize from predefined categories (collapsed by default)
        @categories = MOD_CATEGORIES.map do |cat|
          cat.merge(collapsed: true)
        end
      end
      @categories
    end
    
    # Validates that a category name exists in the predefined list
    # @param name [String] Category name to check
    # @return [Boolean] true if category exists
    def valid_category?(name)
      return false if name.nil? || name.empty?
      categories.any? { |c| c[:name] == name }
    end
    
    # Toggles collapse state for a category
    # @param name [String] Category name
    def toggle_category(name)
      cat = categories.find { |c| c[:name] == name }
      if cat
        cat[:collapsed] = !cat[:collapsed]
      end
    end
    
    # Checks if a category is collapsed
    # @param name [String] Category name
    # @return [Boolean] true if collapsed
    def category_collapsed?(name)
      cat = categories.find { |c| c[:name] == name }
      return cat ? cat[:collapsed] : false
    end
    
    # Resets all categories to collapsed state
    def restore_category_states
      categories.each do |cat|
        cat[:collapsed] = true
      end
    end

    # Fallback storage used before $PokemonSystem is available
    # Settings are stored here temporarily and migrated when the save system loads
    def fallback_storage
      @fallback_storage ||= {}
    end

    # Returns the active storage hash for mod settings
    # Tries to use $PokemonSystem.@mod_settings if available, otherwise uses fallback
    # This allows settings to persist across game sessions when saved
    def storage
      begin
        if defined?($PokemonSystem) && $PokemonSystem
          stored = $PokemonSystem.mod_settings rescue nil
          if stored && stored.is_a?(Hash)
            return stored
          end
        end
      rescue
      end
      return fallback_storage
    end

    # Registers a simple On/Off toggle setting
    # @param key [Symbol] Unique identifier for this setting
    # @param name [String] Display name shown in the menu
    # @param description [String] Help text describing what this setting does
    # @param default [Integer] Default value (0 = Off, 1 = On)
    # @param category [String, nil] Optional category name for organization
    # @return [EnumOption] The created option object
    def register_toggle(key, name, description = "", default = 0, category = nil)
      return if registry.any? { |r| r[:key] == key }  # Prevent duplicate registrations
      opt = EnumOption.new(name, [_INTL("Off"), _INTL("On")],
                           proc { ModSettingsMenu.get(key) },
                           proc { |value| ModSettingsMenu.set(key, value) },
                           description)
      registry << {:key => key, :option => opt, :category => category}
      ensure_storage
      st = storage
      st[key] = (default == 0 ? 0 : 1) if st && st[key].nil?
      return opt
    end

    # Registers a custom option object (for advanced use cases)
    # @param option [Option] Pre-configured option object
    # @param key [Symbol] Optional key for storage tracking
    # @param category [String, nil] Optional category name for organization
    # @param searchable_items [Array<String>, nil] Optional array of searchable keywords for ButtonOptions
    # @return [Option] The registered option object
    #
    # For ButtonOption submenus, provide searchable_items to make submenu contents discoverable:
    #   ModSettingsMenu.register_option(btn, :economy_mod, "Economy & Rewards",
    #     ["sales", "markups", "initial money", "battle money", "multiplier", "pokevial cost"])
    def register_option(option, key = nil, category = nil, searchable_items = nil)
      registry << {:key => key, :option => option, :category => category, :searchable_items => searchable_items}
      return option
    end

    # Registers an enumeration (dropdown/choice) setting
    # @param key [Symbol] Unique identifier for this setting
    # @param name [String] Display name shown in the menu
    # @param values [Array<String>] List of choices to display
    # @param default_index [Integer] Index of the default choice
    # @param description [String] Help text describing what this setting does
    # @param category [String, nil] Optional category name for organization
    # @return [EnumOption] The created option object
    def register_enum(key, name, values, default_index = 0, description = "", category = nil)
      opt = EnumOption.new(name, values, proc { ModSettingsMenu.get(key) }, proc { |v| ModSettingsMenu.set(key, v) }, description)
      registry << {:key => key, :option => opt, :category => category}
      ensure_storage
      st = storage
      st[key] = default_index if st && st[key].nil?
      return opt
    end

    # Registers a number input setting
    # @param key [Symbol] Unique identifier for this setting
    # @param name [String] Display name shown in the menu
    # @param startv [Integer] Minimum allowed value
    # @param endv [Integer] Maximum allowed value
    # @param default [Integer] Default value
    # @param description [String] Help text describing what this setting does
    # @param category [String, nil] Optional category name for organization
    # @return [NumberOption] The created option object
    def register_number(key, name, startv, endv, default, description = "", category = nil)
      opt = NumberOption.new(name, startv, endv, proc { ModSettingsMenu.get(key) || 0 }, proc { |v| ModSettingsMenu.set(key, v) })
      registry << {:key => key, :option => opt, :category => category}
      ensure_storage
      st = storage
      st[key] = default if st && st[key].nil?
      return opt
    end

    # Registers a slider setting (for numeric values with intervals)
    # @param key [Symbol] Unique identifier for this setting
    # @param name [String] Display name shown in the menu
    # @param startv [Integer] Minimum allowed value
    # @param endv [Integer] Maximum allowed value
    # @param interval [Integer] Step size for the slider
    # @param default [Integer] Default value
    # @param description [String] Help text describing what this setting does
    # @param category [String, nil] Optional category name for organization
    # @return [SliderOption] The created option object
    def register_slider(key, name, startv, endv, interval, default, description = "", category = nil)
      opt = SliderOption.new(name, startv, endv, interval, proc { ModSettingsMenu.get(key) || 0 }, proc { |v| ModSettingsMenu.set(key, v) }, description)
      registry << {:key => key, :option => opt, :category => category}
      ensure_storage
      st = storage
      st[key] = default if st && st[key].nil?
      return opt
    end

    # Ensures the storage system is properly initialized in $PokemonSystem
    # This migrates any settings from fallback_storage into the save system
    # Called automatically when registering settings or accessing storage
    def ensure_storage
      return unless defined?($PokemonSystem) && $PokemonSystem
      begin
        # Check if mod_settings exists and is properly initialized
        current = $PokemonSystem.mod_settings rescue nil
        
        if current.nil? || !current.is_a?(Hash)
          # Need to initialize - check if we have fallback data to migrate
          if @fallback_storage && @fallback_storage.is_a?(Hash) && @fallback_storage.any?
            $PokemonSystem.mod_settings = @fallback_storage.dup
            @fallback_storage.clear
          else
            $PokemonSystem.mod_settings = {}
          end
        elsif @fallback_storage && @fallback_storage.is_a?(Hash) && @fallback_storage.any?
          # Storage exists but we have pending fallback data to merge
          merged = current.merge(@fallback_storage)
          $PokemonSystem.mod_settings = merged
          @fallback_storage.clear
        end
      rescue Exception => e
        # If anything fails, ensure we at least have fallback working
      end
    end

    # Loads a hash of settings into storage (used when loading from save file)
    # @param hash [Hash] The settings data to load
    # This normalizes keys to symbols and triggers on_change callbacks for all loaded values
    def set_storage(hash)
      return unless hash.is_a?(Hash)
      # Normalize all keys to symbols for consistency
      norm = {}
      begin
        hash.each do |k, v|
          key = (k.is_a?(String) ? k.to_sym : k)
          norm[key] = v
        end
      rescue
        norm = hash
      end
      # Store in either $PokemonSystem or fallback depending on availability
      begin
        if defined?($PokemonSystem) && $PokemonSystem
          $PokemonSystem.instance_variable_set(:@mod_settings, norm)
        else
          @fallback_storage = norm
        end
      rescue
        @fallback_storage = norm
      end
      # Trigger on_change callbacks for all loaded settings
      begin
        if defined?(self) && norm.is_a?(Hash)
          norm.each do |k, v|
            invoke_on_change(k, v) rescue nil
          end
        end
      rescue
      end
    end

    # Retrieves a setting value by key
    # @param key [Symbol/String] The setting identifier
    # @return [Object, nil] The setting value, or nil if not found
    # This method tries multiple key formats (symbol/string) for flexibility
    def get(key)
      ensure_storage
      st = storage
      return nil if !st
      # Try the key as-is first
      if st.key?(key)
        return st[key]
      end
      # Try converting between symbol and string
      sk = key.is_a?(Symbol) ? key.to_s : key.to_sym rescue nil
      if sk && st.key?(sk)
        return st[sk]
      end
      # Try the opposite conversion as well
      sk2 = key.is_a?(String) ? key.to_sym : key.to_s rescue nil
      if sk2 && st.key?(sk2)
        return st[sk2]
      end
      return nil
    end

    # Returns the registry of on_change callbacks
    # Each key can have multiple callbacks that execute when its value changes
    def on_change_registry
      @on_change_registry ||= {}
    end

    # Registers a callback to be executed when a setting value changes
    # @param key [Symbol] The setting identifier to watch
    # @param block [Proc] The callback to execute (receives the new value as parameter)
    # @return [Boolean] true if successfully registered
    # Usage: register_on_change(:my_setting) { |new_value| puts "Changed to #{new_value}" }
    def register_on_change(key, &block)
      return unless block
      k = key.is_a?(String) ? key.to_sym : key
      on_change_registry[k] ||= []
      on_change_registry[k] << block
      return true
    end

    # Executes all registered callbacks for a given key
    # @param key [Symbol] The setting identifier
    # @param value [Object] The new value to pass to callbacks
    # Called automatically when a setting is changed via set() or set_storage()
    def invoke_on_change(key, value)
      k = key.is_a?(String) ? key.to_sym : key
      return unless on_change_registry && on_change_registry[k]
      on_change_registry[k].each do |blk|
        begin
          blk.call(value)
        rescue
        end
      end
    end

    # Sets a setting value and triggers any registered callbacks
    # @param key [Symbol] The setting identifier
    # @param value [Object] The new value to store
    # This is the primary method for changing setting values at runtime
    def set(key, value)
      ensure_storage
      st = storage
      return if !st
      st[key] = value
      # Trigger any registered on_change callbacks
      begin
        invoke_on_change(key, value)
      rescue
      end
    end
    
    # Save current settings to Mod_Settings.kro file
    def save_to_file
      return unless defined?(kurayjson_save) && defined?(RTP)
      return unless defined?($PokemonSystem) && $PokemonSystem
      begin
        save_folder = RTP.getSaveFolder rescue nil
        return unless save_folder
        mods_file = save_folder + "\\Mod_Settings.kro"
        data = nil
        # Get storage without triggering recursion
        if $PokemonSystem.instance_variable_defined?(:@mod_settings)
          data = $PokemonSystem.instance_variable_get(:@mod_settings)
        elsif $PokemonSystem.respond_to?(:mod_settings)
          data = $PokemonSystem.mod_settings
        end
        kurayjson_save(mods_file, data) if data.is_a?(Hash) && !data.empty?
      rescue => e
        # Silently fail to prevent errors from blocking gameplay
      end
    end
    
    # ============================================================================
    # CONFLICT REPORTER
    # ============================================================================
    
    # Detect duplicate setting keys registered by different mods
    # @return [Array<Hash>] Array of conflicts with details
    def detect_conflicts
      conflicts = []
      key_counts = {}
      key_details = {}
      
      # Track how many times each key appears and details about each registration
      registry.each do |entry|
        next unless entry[:key]
        key = entry[:key].to_s
        
        key_counts[key] ||= 0
        key_counts[key] += 1
        
        key_details[key] ||= []
        key_details[key] << {
          option_name: entry[:option].respond_to?(:name) ? entry[:option].name : "Unknown",
          category: entry[:category] || "Uncategorized"
        }
      end
      
      # Find duplicate keys
      key_counts.each do |key, count|
        if count > 1
          conflicts << {
            type: :duplicate_key,
            key: key,
            count: count,
            registrations: key_details[key]
          }
        end
      end
      
      return conflicts
    end
    
    # Generate a readable conflict report
    # @return [String] Formatted report of conflicts
    def generate_conflict_report
      conflicts = detect_conflicts
      
      if conflicts.empty?
        return "No conflicts detected."
      end
      
      report = "Found #{conflicts.length} conflict(s):\n\n"
      
      conflicts.each_with_index do |conflict, i|
        if conflict[:type] == :duplicate_key
          report += "#{i + 1}. Duplicate Key: #{conflict[:key]}\n"
          report += "   Registered #{conflict[:count]} times:\n"
          conflict[:registrations].each do |reg|
            report += "   - #{reg[:option_name]} (#{reg[:category]})\n"
          end
          report += "\n"
        end
      end
      
      return report
    end
    
    # Load settings from Mod_Settings.kro file
    def load_from_file
      return unless defined?(kurayjson_load) && defined?(RTP)
      begin
        save_folder = RTP.getSaveFolder rescue nil
        return unless save_folder
        mods_file = save_folder + "\\Mod_Settings.kro"
        if File.exists?(mods_file)
          loaded = kurayjson_load(mods_file)
          set_storage(loaded) if loaded.is_a?(Hash)
        end
      rescue => e
        # Silently fail
      end
    end
    
    # ============================================================================
    # PRESET MANAGEMENT
    # ============================================================================
    
    # Get the path to the presets file
    def presets_file_path
      return nil unless defined?(RTP)
      save_folder = RTP.getSaveFolder rescue nil
      return nil unless save_folder
      save_folder + "\\ModSettings_Presets.kro"
    end
    
    # Load all presets from file
    def load_presets
      return {} unless defined?(kurayjson_load)
      begin
        path = presets_file_path
        return {} unless path && File.exists?(path)
        loaded = kurayjson_load(path)
        return loaded.is_a?(Hash) ? loaded : {}
      rescue
        return {}
      end
    end
    
    # Save all presets to file
    def save_presets(presets)
      return unless defined?(kurayjson_save)
      begin
        path = presets_file_path
        return unless path
        kurayjson_save(path, presets) if presets.is_a?(Hash)
      rescue
        # Silently fail
      end
    end
    
    # Save current settings as a preset
    def save_preset(preset_name)
      return false if preset_name.nil? || preset_name.empty?
      begin
        current_settings = storage.dup rescue {}
        return false unless current_settings.is_a?(Hash)
        
        presets = load_presets
        presets[preset_name] = {
          settings: current_settings,
          timestamp: Time.now.to_i
        }
        save_presets(presets)
        return true
      rescue
        return false
      end
    end
    
    # Load a preset by name
    def load_preset(preset_name)
      return false if preset_name.nil? || preset_name.empty?
      begin
        presets = load_presets
        return false unless presets[preset_name]
        
        preset_data = presets[preset_name]
        return false unless preset_data.is_a?(Hash) && preset_data[:settings]
        
        set_storage(preset_data[:settings])
        save_to_file
        return true
      rescue
        return false
      end
    end
    
    # Delete a preset by name
    def delete_preset(preset_name)
      return false if preset_name.nil? || preset_name.empty?
      begin
        presets = load_presets
        return false unless presets[preset_name]
        
        presets.delete(preset_name)
        save_presets(presets)
        return true
      rescue
        return false
      end
    end
    
    # Get list of preset names
    def preset_names
      presets = load_presets
      return presets.keys.sort
    end
    
    # Debug logging to file
    def debug_log(message)
      begin
        save_folder = RTP.getSaveFolder rescue nil
        return unless save_folder
        
        log_file = File.join(save_folder, "ModsDebug.txt")
        File.open(log_file, "a") do |f|
          f.puts("[#{Time.now}] #{message}")
        end
      rescue
        # Silent fail
      end
    end
    
    # Export current settings to a file
    def export_to_file(filename)
      return false if filename.nil? || filename.empty?
      begin
        current_settings = storage.dup rescue {}
        return false unless current_settings.is_a?(Hash)
        
        save_folder = RTP.getSaveFolder rescue nil
        return false unless save_folder
        
        # Add MSPresetExport_ prefix
        full_filename = "MSPresetExport_#{filename}"
        filepath = File.join(save_folder, "#{full_filename}.kro")
        
        return false unless defined?(kurayjson_save)
        kurayjson_save(filepath, current_settings)
        
        # Verify the file was created
        if File.exists?(filepath)
          pbMessage("Export Successful")
          return true
        else
          pbMessage("Export Failed")
          return false
        end
      rescue => e
        pbMessage("Export Failed")
        return false
      end
    end
    
    # Import settings from a file
    def import_from_file(filename)
      return false if filename.nil? || filename.empty?
      begin
        save_folder = RTP.getSaveFolder rescue nil
        return false unless save_folder
        
        # Handle both full filename and just the base name
        full_filename = filename.start_with?("MSPresetExport_") ? filename : "MSPresetExport_#{filename}"
        filepath = File.join(save_folder, "#{full_filename}.kro")
        return false unless File.exists?(filepath)
        
        return false unless defined?(kurayjson_load)
        settings = kurayjson_load(filepath)
        
        return false unless settings.is_a?(Hash)
        
        # Convert string keys to symbols if needed
        normalized = {}
        settings.each do |k, v|
          key = k.is_a?(String) ? k.to_sym : k
          normalized[key] = v
        end
        
        set_storage(normalized)
        save_to_file
        return true
      rescue => e
        return false
      end
    end
    
    # Get list of export files
    def export_files
      begin
        save_folder = RTP.getSaveFolder rescue nil
        return [] unless save_folder
        
        # Get all files and filter manually (Dir.glob wildcards don't work in this Ruby environment)
        all_files = Dir.entries(save_folder).reject { |f| f == '.' || f == '..' } rescue []
        export_files = all_files.select { |f| f.start_with?("MSPresetExport_") && f.end_with?(".kro") }
        
        # Strip "MSPresetExport_" prefix and ".kro" extension to show just the name
        return export_files.map { |f| f.sub("MSPresetExport_", "").sub(".kro", "") }.sort
      rescue => e
        return []
      end
    end
  end  # End of class << self
end  # End of ModSettingsMenu module

# ============================================================================
# POKEMONSYSTEM EXTENSION - ENABLE SAVE PERSISTENCE
# ============================================================================
# Add mod_settings as an attribute to PokemonSystem so it saves with the game
# ============================================================================
if defined?(PokemonSystem)
  class PokemonSystem
    attr_accessor :mod_settings
  end
end

# ============================================================================
# PENDING REGISTRATIONS PROCESSOR
# ============================================================================
# Some mods may try to register settings before this script loads.
# They add their registration code to $MOD_SETTINGS_PENDING_REGISTRATIONS array.
# This section executes all pending registrations now that the system is ready.
# ============================================================================
if defined?($MOD_SETTINGS_PENDING_REGISTRATIONS) && $MOD_SETTINGS_PENDING_REGISTRATIONS.is_a?(Array)
  $MOD_SETTINGS_PENDING_REGISTRATIONS.each do |procobj|
    begin
      procobj.call
    rescue
    end
  end
  $MOD_SETTINGS_PENDING_REGISTRATIONS.clear
end

# ============================================================================
# FILE PERSISTENCE - LOAD SETTINGS FROM DISK
# ============================================================================
# Attempts to load mod settings from Mod_Settings.kro file in the save folder.
# This happens at script initialization to restore settings from previous sessions.
# If loading fails or file doesn't exist, it sets up a pending load to try again later.
# ============================================================================
begin
  begin
    mods_file = RTP.getSaveFolder + "\\Mod_Settings.kro" rescue nil
    if mods_file && File.exists?(mods_file) && defined?(kurayjson_load)
      loaded = kurayjson_load(mods_file) rescue nil
      ModSettingsMenu.set_storage(loaded) if loaded.is_a?(Hash)
    else
      # File doesn't exist yet or kurayjson_load not available, try again later
      $MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
      $MOD_SETTINGS_PENDING_REGISTRATIONS << proc {
        begin
          mods_file2 = RTP.getSaveFolder + "\\Mod_Settings.kro"
          if File.exists?(mods_file2) && defined?(kurayjson_load)
            loaded2 = kurayjson_load(mods_file2) rescue nil
            ModSettingsMenu.set_storage(loaded2) if loaded2.is_a?(Hash)
          end
        rescue
        end
      }
    end
  rescue
  end
rescue
end

# ============================================================================
# SAVE & LOAD PRESETS - OPTION CLASSES
# ============================================================================
# Individual options for the preset management submenu
# ============================================================================

class SavePresetOption < ButtonOption
  def initialize
    super(
      _INTL("Save Preset"),
      proc {
        preset_name = pbMessageFreeText(_INTL("Enter preset name:"), "", false, 30) rescue nil
        if preset_name && !preset_name.empty?
          if ModSettingsMenu.save_preset(preset_name)
            pbMessage(_INTL("Preset '{1}' saved!", preset_name)) if defined?(pbMessage)
          else
            pbMessage(_INTL("Failed to save preset.")) if defined?(pbMessage)
          end
        end
      },
      _INTL("Save your current mod settings as a preset")
    )
  end
end

class LoadPresetOption < ButtonOption
  def initialize
    super(
      _INTL("Load Preset"),
      proc {
        preset_names = ModSettingsMenu.preset_names
        if preset_names.empty?
          pbMessage(_INTL("No presets available.")) if defined?(pbMessage)
        else
          commands = preset_names + [_INTL("Cancel")]
          choice = pbMessage(_INTL("Choose a preset to load:"), commands, -1) rescue -1
          
          if choice >= 0 && choice < preset_names.length
            selected = preset_names[choice]
            confirmed = pbConfirmMessage(_INTL("Load '{1}'? Current settings will be replaced.", selected)) rescue false
            if confirmed
              if ModSettingsMenu.load_preset(selected)
                pbMessage(_INTL("Preset loaded successfully!")) if defined?(pbMessage)
                
                # Refresh all Mod Settings windows to apply changes immediately
                ObjectSpace.each_object(Window_PokemonOption) do |window|
                  if window.respond_to?(:apply_modsettings_theme)
                    window.apply_modsettings_theme
                    window.refresh if window.respond_to?(:refresh)
                  end
                end
              else
                pbMessage(_INTL("Failed to load preset.")) if defined?(pbMessage)
              end
            end
          end
        end
      },
      _INTL("Load a previously saved preset")
    )
  end
end

class DeletePresetOption < ButtonOption
  def initialize
    super(
      _INTL("Delete Preset"),
      proc {
        preset_names = ModSettingsMenu.preset_names
        if preset_names.empty?
          pbMessage(_INTL("No presets to delete.")) if defined?(pbMessage)
        else
          commands = preset_names + [_INTL("Cancel")]
          choice = pbMessage(_INTL("Choose a preset to delete:"), commands, -1) rescue -1
          
          if choice >= 0 && choice < preset_names.length
            selected = preset_names[choice]
            confirmed = pbConfirmMessage(_INTL("Delete '{1}'?", selected)) rescue false
            if confirmed
              if ModSettingsMenu.delete_preset(selected)
                pbMessage(_INTL("Preset deleted!")) if defined?(pbMessage)
              else
                pbMessage(_INTL("Failed to delete preset.")) if defined?(pbMessage)
              end
            end
          end
        end
      },
      _INTL("Delete a saved preset")
    )
  end
end

class ExportPresetOption < ButtonOption
  def initialize
    super(
      _INTL("Export to File"),
      proc {
        default_name = Time.now.strftime('%m-%d-%y')
        filename = pbMessageFreeText(_INTL("Enter export name:"), default_name, false, 50) rescue nil
        if filename && !filename.empty?
          if ModSettingsMenu.export_to_file(filename)
            pbMessage(_INTL("Settings exported to MSPresetExport_{1}.kro!", filename)) if defined?(pbMessage)
          else
            pbMessage(_INTL("Failed to export settings.")) if defined?(pbMessage)
          end
        end
      },
      _INTL("Export current settings to a file")
    )
  end
end

class ImportPresetOption < ButtonOption
  def initialize
    super(
      _INTL("Import from File"),
      proc {
        export_files = ModSettingsMenu.export_files
        if export_files.empty?
          pbMessage(_INTL("No export files found.")) if defined?(pbMessage)
        else
          commands = export_files + [_INTL("Cancel")]
          choice = pbMessage(_INTL("Choose a file to import:"), commands, -1) rescue -1
          
          if choice >= 0 && choice < export_files.length
            selected = export_files[choice]
            
            # Ask if they want to overwrite existing or save as new
            import_commands = [_INTL("Overwrite Existing Preset"), _INTL("Save as New Preset"), _INTL("Cancel")]
            import_choice = pbMessage(_INTL("How do you want to import?"), import_commands, -1) rescue -1
            
            if import_choice == 0  # Overwrite existing
              preset_names = ModSettingsMenu.preset_names
              if preset_names.empty?
                pbMessage(_INTL("No existing presets to overwrite.")) if defined?(pbMessage)
              else
                preset_commands = preset_names + [_INTL("Cancel")]
                preset_choice = pbMessage(_INTL("Choose preset to overwrite:"), preset_commands, -1) rescue -1
                
                if preset_choice >= 0 && preset_choice < preset_names.length
                  preset_name = preset_names[preset_choice]
                  confirmed = pbConfirmMessage(_INTL("Overwrite '{1}'?", preset_name)) rescue false
                  if confirmed
                    # Load the file temporarily
                    if ModSettingsMenu.import_from_file(selected)
                      # Save current settings (which are now the imported ones) as the preset
                      if ModSettingsMenu.save_preset(preset_name)
                        pbMessage(_INTL("Preset '{1}' overwritten with import!", preset_name)) if defined?(pbMessage)
                      else
                        pbMessage(_INTL("Failed to save preset.")) if defined?(pbMessage)
                      end
                    else
                      pbMessage(_INTL("Failed to import file.")) if defined?(pbMessage)
                    end
                  end
                end
              end
              
            elsif import_choice == 1  # Save as new
              preset_name = pbMessageFreeText(_INTL("Enter new preset name:"), "", false, 30) rescue nil
              if preset_name && !preset_name.empty?
                # Load the file temporarily
                if ModSettingsMenu.import_from_file(selected)
                  # Save current settings (which are now the imported ones) as a new preset
                  if ModSettingsMenu.save_preset(preset_name)
                    pbMessage(_INTL("Import saved as preset '{1}'!", preset_name)) if defined?(pbMessage)
                  else
                    pbMessage(_INTL("Failed to save preset.")) if defined?(pbMessage)
                  end
                else
                  pbMessage(_INTL("Failed to import file.")) if defined?(pbMessage)
                end
              end
            end
          end
        end
      },
      _INTL("Import settings from a file")
    )
  end
end

# Delete Export Option
class DeleteExportOption < ButtonOption
  def initialize
    super(
      _INTL("Delete Export"),
      proc {
        export_files = ModSettingsMenu.export_files
        if export_files.empty?
          pbMessage(_INTL("No export files found.")) if defined?(pbMessage)
        else
          commands = export_files + [_INTL("Cancel")]
          choice = pbMessage(_INTL("Choose a file to delete:"), commands, -1) rescue -1
          
          if choice >= 0 && choice < export_files.length
            selected = export_files[choice]
            confirmed = pbConfirmMessage(_INTL("Delete '{1}'?", selected)) rescue false
            if confirmed
              begin
                save_folder = RTP.getSaveFolder rescue nil
                if save_folder
                  full_filename = "MSPresetExport_#{selected}"
                  filepath = File.join(save_folder, "#{full_filename}.kro")
                  
                  if File.exists?(filepath)
                    File.delete(filepath)
                    pbMessage(_INTL("Export '{1}' deleted!", selected)) if defined?(pbMessage)
                  else
                    pbMessage(_INTL("File not found.")) if defined?(pbMessage)
                  end
                else
                  pbMessage(_INTL("Failed to delete export.")) if defined?(pbMessage)
                end
              rescue => e
                pbMessage(_INTL("Error deleting export.")) if defined?(pbMessage)
              end
            end
          end
        end
      },
      _INTL("Delete an exported preset file")
    )
  end
end

# View Conflicts Option
class ViewConflictsOption < ButtonOption
  def initialize
    super(
      _INTL("View Conflicts"),
      proc {
        report = ModSettingsMenu.generate_conflict_report
        pbMessage(_INTL(report)) if defined?(pbMessage)
      },
      _INTL("Check for duplicate keys or naming conflicts")
    )
  end
end

# Mod List Option
class CheckUpdatesOption < ButtonOption
  def initialize
    super(
      _INTL("Mod List"),
      proc {
        results = ModSettingsMenu::UpdateCheck.check_updates
        
        if results[:error]
          pbMessage(_INTL(results[:error])) if defined?(pbMessage)
        else
          # Open the update results scene
          scene = UpdateResultsScene.new(results)
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        end
      },
      _INTL("View all mods and check for updates")
    )
  end
end

# Update All Mods Option
class UpdateAllModsOption < ButtonOption
  def initialize
    super(
      _INTL("Update All Mods"),
      proc {
        results = ModSettingsMenu::UpdateCheck.check_updates
        
        if results[:error]
          pbMessage(_INTL(results[:error])) if defined?(pbMessage)
        else
          # Collect all mods with updates available
          updates_available = results[:major_updates] + results[:minor_updates] + results[:hotfixes]
          
          if updates_available.empty?
            pbMessage(_INTL("All mods are up to date!"))
          else
            # Filter to only mods with download URLs
            updatable = updates_available.select { |mod| mod[:download_url] && !mod[:download_url].empty? }
            
            if updatable.empty?
              pbMessage(_INTL("No mods support auto-update yet."))
            else
              # Confirm with user
              count = updatable.length
              message = sprintf("Update %d mod(s)?", count)
              if pbConfirmMessage(message)
                success_count = 0
                failure_count = 0
                
                updatable.each do |mod|
                  # Update the mod
                  success = ModSettingsMenu::ModUpdater.install_mod(
                    mod[:path],
                    mod[:download_url],
                    mod[:local]
                  )
                  
                  if success
                    success_count += 1
                    # Install graphics if present
                    if mod[:graphics] && mod[:graphics].any?
                      ModSettingsMenu::ModUpdater.install_graphics(mod[:graphics])
                    end
                  else
                    failure_count += 1
                  end
                end
                
                if failure_count > 0
                  pbMessage(sprintf("Updates complete! %d succeeded, %d failed. Restart the game for changes to take effect.", success_count, failure_count))
                else
                  pbMessage(sprintf("All %d mod(s) updated! Please restart the game for changes to take effect.", success_count))
                end
              end
            end
          end
        end
      },
      _INTL("Automatically update all mods that have updates available")
    )
  end
end

# Auto-Update Toggle Option
class AutoUpdateOption < EnumOption
  def initialize
    super(
      _INTL("Auto-Update"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:mod_auto_update) || 0 },
      proc { |value| ModSettingsMenu.set(:mod_auto_update, value) },
      _INTL("Automatically check for mod updates when game checks version")
    )
  end
end

# Auto-Update Confirm Toggle Option
class AutoUpdateConfirmOption < EnumOption
  def initialize
    super(
      _INTL("Auto-Update Confirm"),
      [_INTL("Off"), _INTL("On")],
      proc { ModSettingsMenu.get(:mod_auto_update_confirm) || 1 },
      proc { |value| ModSettingsMenu.set(:mod_auto_update_confirm, value) },
      _INTL("Ask for confirmation before auto-updating mods")
    )
  end
end

# Delete Backup Option
class DeleteBackupOption < ButtonOption
  def initialize
    super(
      _INTL("Delete Backup"),
      proc {
        backups = ModSettingsMenu::ModUpdater.list_backups
        
        if backups.empty?
          pbMessage(_INTL("No backups found."))
        else
          commands = backups.map { |b| b[:display_name] } + [_INTL("Cancel")]
          choice = pbMessage(_INTL("Select backup to delete:"), commands, -1)
          
          if choice >= 0 && choice < backups.length
            selected = backups[choice]
            if pbConfirmMessage(sprintf("Delete %s?", selected[:display_name]))
              if ModSettingsMenu::ModUpdater.delete_backup(selected[:path])
                pbMessage(_INTL("Backup deleted!"))
              else
                pbMessage(_INTL("Failed to delete backup."))
              end
            end
          end
        end
      },
      _INTL("Delete individual mod backup files")
    )
  end
end

# Delete All Backups Option
class DeleteAllBackupsOption < ButtonOption
  def initialize
    super(
      _INTL("Delete All Backups"),
      proc {
        backups = ModSettingsMenu::ModUpdater.list_backups
        
        if backups.empty?
          pbMessage(_INTL("No backups found."))
        else
          count = backups.length
          if pbConfirmMessage(sprintf("Delete all %d backup(s)?", count))
            success_count = 0
            backups.each do |backup|
              if ModSettingsMenu::ModUpdater.delete_backup(backup[:path])
                success_count += 1
              end
            end
            pbMessage(sprintf("Deleted %d of %d backup(s).", success_count, count))
          end
        end
      },
      _INTL("Delete all mod backup files")
    )
  end
end

# ============================================================================
# MOD UPDATES SCENE
# ============================================================================
# Scene for displaying mod update options
# ============================================================================
class ModUpdatesScene < PokemonOption_Scene
  def pbGetOptions(inloadscreen = false)
    options = []
    options << CheckUpdatesOption.new
    options << UpdateAllModsOption.new
    options << AutoUpdateOption.new
    options << AutoUpdateConfirmOption.new
    options << DeleteBackupOption.new
    options << DeleteAllBackupsOption.new
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Mod Updates"), 0, 0, Graphics.width, 64, @viewport)
    
    # Enable purple colors
    if @sprites["option"] && @sprites["option"].respond_to?(:use_blue_colors=)
      @sprites["option"].use_blue_colors = true
    end
    
    # Initialize values
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

# ============================================================================
# PRESET SETTINGS SCENE
# ============================================================================
# Scene for displaying preset management options
# ============================================================================
class PresetSettingsScene < PokemonOption_Scene
  def pbGetOptions(inloadscreen = false)
    options = []
    options << SavePresetOption.new
    options << LoadPresetOption.new
    options << DeletePresetOption.new
    options << ExportPresetOption.new
    options << ImportPresetOption.new
    options << DeleteExportOption.new
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Save & Load Presets"), 0, 0, Graphics.width, 64, @viewport)
    
    # Enable purple colors
    if @sprites["option"] && @sprites["option"].respond_to?(:use_blue_colors=)
      @sprites["option"].use_blue_colors = true
    end
    
    # Initialize values
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

# ============================================================================
# SAVE & LOAD PRESETS BUTTON
# ============================================================================
# ButtonOption that opens the preset management scene
# ============================================================================
begin
  if defined?(ModSettingsMenu) && defined?(ButtonOption)
    preset_button = ButtonOption.new(
      _INTL("Save & Load Presets"),
      proc do
        pbFadeOutIn {
          scene = PresetSettingsScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      end,
      _INTL("Save and load preset configurations")
    )
    
    # Register Mod Updates submenu with NOCATEGORY (appears above presets)
    mod_updates_button = ButtonOption.new(
      _INTL("Mod Updates"),
      proc do
        pbFadeOutIn {
          scene = ModUpdatesScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      end,
      _INTL("Check for updates and manage mod backups")
    )
    
    ModSettingsMenu.register_option(
      mod_updates_button,
      :mod_updates_submenu,
      ModSettingsMenu::NOCATEGORY,
      ["update", "updates", "check", "version", "mod", "online", "backup", "delete"]
    )
    
    # Register with NOCATEGORY so it appears without a header
    ModSettingsMenu.register_option(preset_button, :presets_submenu, ModSettingsMenu::NOCATEGORY,
      ["save", "load", "preset", "configuration", "backup", "restore"])
  end
rescue
end

# ============================================================================
# CATEGORY HEADER OPTION
# ============================================================================
# A special option type for collapsible category headers in the mod settings menu.
# Clicking the header toggles its collapsed state, hiding/showing settings in that category.
# ============================================================================
class CategoryHeaderOption < Option
  attr_reader :name
  attr_accessor :category_name
  
  def initialize(category_name, description = "")
    @name = category_name
    @category_name = category_name
    @description = description
  end
  
  # Mark this as a non-selectable UI element
  def non_interactive?
    return true
  end
  
  # Get current value (collapsed state: 0 = expanded, 1 = collapsed)
  def get
    ModSettingsMenu.category_collapsed?(@category_name) ? 1 : 0
  end
  
  # Set value (toggle collapsed state)
  def set(value)
    ModSettingsMenu.toggle_category(@category_name)
  end
  
  # Format display text with collapse indicator
  def format(value)
    # Check if this is a separator (contains only dashes)
    if @name =~ /^-+$/
      return @name  # No indicator for separators
    end
    
    indicator = value == 1 ? "+" : "-"
    return "#{indicator} #{@name}"
  end
  
  # Return empty values array (category headers don't cycle through values)
  def values
    return [""]
  end
  
  # Prevent the default value cycling behavior
  def next(current)
    return current
  end
  
  def prev(current)
    return current
  end
  
  def next_value(current)
    return current
  end
  
  def prev_value(current)
    return current
  end
end

# ============================================================================
# UPDATE RESULTS SCENE
# ============================================================================
# Scene for displaying update check results with colored category headers
# ============================================================================

# Custom category header that stores color theme key
class ColoredCategoryHeaderOption < CategoryHeaderOption
  attr_accessor :color_theme_key
  
  def initialize(name, description, color_theme_key)
    super(name, description)
    @color_theme_key = color_theme_key
  end
  
  # Override format to remove collapse indicators (- or +)
  def format(value)
    return @name
  end
end

# Custom window for update results with specific category colors
class Window_UpdateResults < Window_PokemonOption
  def drawItem(index, _count, rect)
    # Check if this is a colored category header
    if index < @options.length && @options[index].is_a?(ColoredCategoryHeaderOption)
      # Get the specific color for this category
      theme_key = @options[index].color_theme_key
      theme = COLOR_THEMES[theme_key] if theme_key
      
      if theme && theme[:base] && theme[:shadow]
        old_name_base = @nameBaseColor
        old_name_shadow = @nameShadowColor
        old_sel_base = @selBaseColor
        old_sel_shadow = @selShadowColor
        
        @nameBaseColor = theme[:base]
        @nameShadowColor = theme[:shadow]
        @selBaseColor = theme[:base]
        @selShadowColor = theme[:shadow]
        
        # Draw cursor if selected
        if index == self.index
          begin
            arrow = AnimatedBitmap.new("Graphics/Pictures/selarrow")
            src_rect = Rect.new(0, 0, arrow.width, arrow.height)
            self.contents.blt(0, rect.y, arrow.bitmap, src_rect, 255)
            arrow.dispose
          rescue
            pbDrawShadowText(self.contents, 4, rect.y, 32, rect.height, ">",
                           Color.new(255, 255, 255), Color.new(128, 128, 128))
          end
        end
        
        optionvalue = (@options[index].get || 0)
        text = @options[index].format(optionvalue)
        
        # Center the text
        text_width = 200
        if self.contents && self.contents.respond_to?(:text_size)
          begin
            text_size_result = self.contents.text_size(text)
            text_width = text_size_result.width if text_size_result && text_size_result.respond_to?(:width)
          rescue
            text_width = 200
          end
        end
        x_pos = (rect.width - text_width) / 2
        
        pbDrawShadowText(self.contents, x_pos, rect.y, text_width, rect.height, text,
                       @nameBaseColor, @nameShadowColor)
        
        # Restore colors
        @nameBaseColor = old_name_base
        @nameShadowColor = old_name_shadow
        @selBaseColor = old_sel_base
        @selShadowColor = old_sel_shadow
      else
        super(index, _count, rect)
      end
    else
      super(index, _count, rect)
    end
  end
end

class UpdateResultsScene < PokemonOption_Scene
  def initialize(results)
    super()
    @results = results
  end
  
  def initOptionsWindow
    # Use custom window with specific category colors
    optionsWindow = Window_UpdateResults.new(@PokemonOptions, 0,
                                             @sprites["title"].height, Graphics.width,
                                             Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
    optionsWindow.viewport = @viewport
    optionsWindow.visible = true
    return optionsWindow
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Major Updates Needed section (RED)
    if @results[:major_updates].any?
      header = ColoredCategoryHeaderOption.new("Major Updates Available", "Major version (X) behind latest", :red)
      options << header
      @results[:major_updates].each do |mod|
        text = sprintf("%s: %s => %s", mod[:name], mod[:local], mod[:online])
        callback = proc { pbModUpdateActions(mod) }
        opt = ButtonOption.new(text, callback, " ")
        options << opt
      end
    end
    
    # Minor Updates Needed section (ORANGE)
    if @results[:minor_updates].any?
      header = ColoredCategoryHeaderOption.new("Minor Updates Available", "Minor version (Y) behind latest", :orange)
      options << header
      @results[:minor_updates].each do |mod|
        text = sprintf("%s: %s => %s", mod[:name], mod[:local], mod[:online])
        callback = proc { pbModUpdateActions(mod) }
        opt = ButtonOption.new(text, callback, " ")
        options << opt
      end
    end
    
    # Hotfixes Available section (YELLOW)
    if @results[:hotfixes].any?
      header = ColoredCategoryHeaderOption.new("Hotfixes Available", "Hotfix version (Z) behind latest", :yellow)
      options << header
      @results[:hotfixes].each do |mod|
        text = sprintf("%s: %s => %s", mod[:name], mod[:local], mod[:online])
        callback = proc { pbModUpdateActions(mod) }
        opt = ButtonOption.new(text, callback, " ")
        options << opt
      end
    end
    
    # Up to Date section (GREEN)
    if @results[:up_to_date].any?
      header = ColoredCategoryHeaderOption.new("Up to Date", "Mods matching latest version", :green)
      options << header
      @results[:up_to_date].each do |mod|
        text = sprintf("%s (%s)", mod[:name], mod[:local])
        callback = proc { pbModUpdateActions(mod) }
        opt = ButtonOption.new(text, callback, " ")
        options << opt
      end
    end
    
    # Developer Version section (RED)
    if @results[:developer_version].any?
      header = ColoredCategoryHeaderOption.new("Developer Version", "Mods newer than manifest", :red)
      options << header
      @results[:developer_version].each do |mod|
        text = sprintf("%s: %s (%s)", mod[:name], mod[:local], mod[:online])
        callback = proc { pbModUpdateActions(mod) }
        opt = ButtonOption.new(text, callback, " ")
        options << opt
      end
    end
    
    # Not Tracked section (BLUE)
    if @results[:not_tracked].any?
      header = ColoredCategoryHeaderOption.new("Not Tracked", "Mods not in manifest", :blue)
      options << header
      @results[:not_tracked].each do |mod|
        text = sprintf("%s (%s)", mod[:name], mod[:version])
        opt = ButtonOption.new(text, proc {}, " ")
        options << opt
      end
    end
    
    return options
  end
  
  # Handle actions when a mod entry is selected
  def pbModUpdateActions(mod)
    commands = []
    
    # Check if update is needed by comparing versions
    update_needed = false
    if mod[:local] && mod[:online]
      local_parsed = ModSettingsMenu::UpdateCheck.parse_version(mod[:local])
      online_parsed = ModSettingsMenu::UpdateCheck.parse_version(mod[:online])
      
      local_ver, local_has_patch = local_parsed
      online_ver, online_has_patch = online_parsed
      
      local_major, local_minor, local_patch = local_ver
      online_major, online_minor, online_patch = online_ver
      
      # Update needed if local is behind online
      if local_major < online_major || local_minor < online_minor || local_patch < online_patch
        update_needed = true
      end
    end
    
    # Determine if download URL is available
    has_download_url = mod[:download_url] && !mod[:download_url].empty?
    
    # Always show "Update Mod" option
    commands << _INTL("Update Mod")
    
    # Add View Changelog option if URL is available
    if mod[:changelog_url] && !mod[:changelog_url].empty?
      commands << _INTL("View Changelog")
    end
    
    # Add Rollback option
    commands << _INTL("Rollback")
    
    # Always add Cancel option
    commands << _INTL("Cancel")
    
    # Show command menu
    cmd = pbMessage(_INTL("What would you like to do?"), commands, commands.length)
    
    index = 0
    
    # Handle Update Mod
    if cmd == index
      if update_needed && has_download_url
        pbUpdateMod(mod)
      elsif update_needed && !has_download_url
        pbMessage(_INTL("Auto-update for this mod is not supported yet."))
      else
        pbMessage(_INTL("Your mod is already up to date!"))
      end
      return
    end
    index += 1
    
    # Handle View Changelog
    if mod[:changelog_url] && !mod[:changelog_url].empty? && cmd == index
      pbViewChangelog(mod)
      return
    end
    index += 1 if mod[:changelog_url]
    
    # Handle Rollback
    if cmd == index
      pbRollbackMod(mod)
      return
    end
    index += 1
    
    # Cancel - do nothing
  end
  
  # Update a mod
  def pbUpdateMod(mod)
    # Check dependencies first
    if mod[:dependencies] && mod[:dependencies].any?
      missing_deps = []
      local_mods = ModSettingsMenu::UpdateCheck::VersionCheck.collect
      
      mod[:dependencies].each do |dep|
        dep_name = dep.is_a?(Hash) ? dep["name"] : dep
        dep_version = dep.is_a?(Hash) ? dep["version"] : nil
        
        # Check if dependency is installed
        installed = local_mods.find { |m| m[:name] == dep_name }
        
        if installed.nil?
          missing_deps << dep_name
        elsif dep_version
          # Check if version requirement is met
          installed_parsed = ModSettingsMenu::UpdateCheck.parse_version(installed[:version])
          required_parsed = ModSettingsMenu::UpdateCheck.parse_version(dep_version)
          
          inst_ver, _ = installed_parsed
          req_ver, _ = required_parsed
          
          # Simple version check (major.minor.patch)
          if inst_ver[0] < req_ver[0] || 
             (inst_ver[0] == req_ver[0] && inst_ver[1] < req_ver[1]) ||
             (inst_ver[0] == req_ver[0] && inst_ver[1] == req_ver[1] && inst_ver[2] < req_ver[2])
            missing_deps << "#{dep_name} (requires v#{dep_version}, have v#{installed[:version]})"
          end
        end
      end
      
      # Show warning if dependencies are missing
      unless missing_deps.empty?
        warning = "This mod requires:\n"
        missing_deps.each { |dep| warning += "  - #{dep}\n" }
        warning += "\nContinue anyway?"
        return unless pbConfirmMessage(warning)
      end
    end
    
    # Confirm update
    message = sprintf("Update %s from %s to %s?", mod[:name], mod[:local], mod[:online])
    if mod[:graphics] && mod[:graphics].any?
      message += sprintf("\n\nThis will also download %d graphics file(s).", mod[:graphics].length)
    end
    
    return unless pbConfirmMessage(message)
    
    # Update the mod file (download happens quickly, no message needed)
    success = ModSettingsMenu::ModUpdater.install_mod(
      mod[:path],
      mod[:download_url],
      mod[:local]
    )
    
    unless success
      pbMessage(_INTL("Failed to update mod. Check ModsDebug.txt for details."))
      return
    end
    
    # Install graphics if present
    if mod[:graphics] && mod[:graphics].any?
      pbMessage(_INTL("Installing graphics files..."))
      success_count, failure_count = ModSettingsMenu::ModUpdater.install_graphics(mod[:graphics])
      
      if failure_count > 0
        pbMessage(sprintf("Mod updated! Graphics: %d succeeded, %d failed. Please restart the game for changes to take effect.", success_count, failure_count))
      else
        pbMessage(sprintf("Mod updated! Installed %d graphics file(s). Please restart the game for changes to take effect.", success_count))
      end
    else
      pbMessage(_INTL("Mod updated! Please restart the game for changes to take effect."))
    end
  end
  
  # Rollback a mod to a previous backup version
  def pbRollbackMod(mod)
    # Get backups for this specific mod
    backups = ModSettingsMenu::ModUpdater.list_backups_for_mod(mod[:path])
    
    if backups.empty?
      pbMessage(_INTL("No backups found for this mod."))
      return
    end
    
    # Build commands list with backup versions and dates
    commands = backups.map { |b| b[:display_name] } + [_INTL("Cancel")]
    
    # Show selection menu
    choice = pbMessage(_INTL("Select a version to restore:"), commands, -1)
    
    # Handle selection
    if choice >= 0 && choice < backups.length
      selected_backup = backups[choice]
      
      # Confirm rollback
      message = sprintf("Rollback %s to %s?", mod[:name], selected_backup[:version])
      return unless pbConfirmMessage(message)
      
      # Perform rollback
      if ModSettingsMenu::ModUpdater.rollback_mod(mod[:path], selected_backup[:path])
        pbMessage(_INTL("Mod rolled back successfully! Please restart the game."))
      else
        pbMessage(_INTL("Failed to rollback mod. Check ModsDebug.txt for details."))
      end
    end
  end
  
  # View changelog for a mod
  def pbViewChangelog(mod)
    content = ModSettingsMenu::ModUpdater.download_file(mod[:changelog_url])
    
    if content.nil?
      pbMessage(_INTL("Failed to fetch changelog. Check ModsDebug.txt for details."))
      return
    end
    
    # Display changelog in scrollable scene
    ChangelogScene.show(mod[:name], content)
  end
  
  def pbStartScene(inloadscreen = false)
    super
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Update Check Results"), 0, 0, Graphics.width, 64, @viewport)
    
    # Apply menu colors
    if @sprites["option"] && @sprites["option"].respond_to?(:use_blue_colors=)
      @sprites["option"].use_blue_colors = true
    end
    
    # Initialize values
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
end

# ============================================================================
# CHANGELOG VIEWER SCENE
# ============================================================================
class ChangelogScene
  def initialize(mod_name, changelog_text)
    @mod_name = mod_name
    @changelog_text = changelog_text
    
    # Extract first line as header
    lines = changelog_text.split("\n")
    @header = lines.first || mod_name
    @content = lines[1..-1].join("\n") || changelog_text
    
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
  end
  
  def pbStartScene
    # Create title window with first line of changelog
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      @header, 0, 0, Graphics.width, 64, @viewport)
    
    # Create text window for instructions
    @sprites["textbox"] = Window_AdvancedTextPokemon.newWithSize(
      "", 0, Graphics.height - 96, Graphics.width, 96, @viewport)
    @sprites["textbox"].text = _INTL("Move up and down to scroll. Press B to close.")
    
    # Create scrollable content window with word wrap
    content_y = @sprites["title"].height
    content_height = Graphics.height - @sprites["title"].height - @sprites["textbox"].height
    
    # Split content into wrapped lines
    wrapped_lines = []
    @content.split("\n").each do |line|
      if line.strip.empty?
        wrapped_lines << ""
      else
        # Simple word wrap - split long lines
        words = line.split(" ")
        current_line = ""
        words.each do |word|
          test_line = current_line.empty? ? word : "#{current_line} #{word}"
          if test_line.length > 50  # Approximate character limit
            wrapped_lines << current_line unless current_line.empty?
            current_line = word
          else
            current_line = test_line
          end
        end
        wrapped_lines << current_line unless current_line.empty?
      end
    end
    
    # Use Window_CommandPokemon for displaying text lines
    @sprites["content"] = Window_CommandPokemon.newWithSize(
      wrapped_lines, 0, content_y, Graphics.width, content_height, @viewport)
    @sprites["content"].baseColor = Color.new(248, 248, 248)
    @sprites["content"].shadowColor = Color.new(0, 0, 0)
    @sprites["content"].index = 0
    
    pbFadeInAndShow(@sprites)
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbScene
    loop do
      Graphics.update
      Input.update
      pbUpdate
      
      # Handle scrolling with arrow keys - one line at a time
      if Input.repeat?(Input::UP)
        if @sprites["content"].index > 0
          @sprites["content"].index -= 1
        end
      elsif Input.repeat?(Input::DOWN)
        max_index = @sprites["content"].commands.length - 1
        if @sprites["content"].index < max_index
          @sprites["content"].index += 1
        end
      elsif Input.trigger?(Input::BACK)
        break
      end
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
  
  def self.show(mod_name, changelog_text)
    scene = ChangelogScene.new(mod_name, changelog_text)
    scene.pbStartScene
    scene.pbScene
    scene.pbEndScene
  end
end

# ============================================================================
# AUTO-UPDATE NOTIFICATION SCENE
# ============================================================================
# Shows a list of mods with updates available using the same format as Update Results
# ============================================================================
class AutoUpdateNotificationScene < PokemonOption_Scene
  def initialize(updates_available)
    super()
    @updates_available = updates_available
  end
  
  def initOptionsWindow
    # Use custom window with specific category colors
    optionsWindow = Window_UpdateResults.new(@PokemonOptions, 0,
                                             @sprites["title"].height, Graphics.width,
                                             Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
    optionsWindow.viewport = @viewport
    optionsWindow.visible = true
    return optionsWindow
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Organize mods by update severity
    major_updates = []
    minor_updates = []
    hotfixes = []
    
    @updates_available.each do |mod|
      if mod[:local] && mod[:online]
        local_parsed = ModSettingsMenu::UpdateCheck.parse_version(mod[:local])
        online_parsed = ModSettingsMenu::UpdateCheck.parse_version(mod[:online])
        
        local_ver, local_has_patch = local_parsed
        online_ver, online_has_patch = online_parsed
        
        local_major, local_minor, local_patch = local_ver
        online_major, online_minor, online_patch = online_ver
        
        if local_major < online_major
          major_updates << mod
        elsif local_minor < online_minor
          minor_updates << mod
        else
          hotfixes << mod
        end
      end
    end
    
    # Major Updates section (RED)
    if major_updates.any?
      header = ColoredCategoryHeaderOption.new("Major Updates Available", "Major version (X) behind latest", :red)
      options << header
      major_updates.each do |mod|
        text = sprintf("%s: %s => %s", mod[:name], mod[:local], mod[:online])
        opt = ButtonOption.new(text, proc {}, " ")
        options << opt
      end
    end
    
    # Minor Updates section (ORANGE)
    if minor_updates.any?
      header = ColoredCategoryHeaderOption.new("Minor Updates Available", "Minor version (Y) behind latest", :orange)
      options << header
      minor_updates.each do |mod|
        text = sprintf("%s: %s => %s", mod[:name], mod[:local], mod[:online])
        opt = ButtonOption.new(text, proc {}, " ")
        options << opt
      end
    end
    
    # Hotfixes section (YELLOW)
    if hotfixes.any?
      header = ColoredCategoryHeaderOption.new("Hotfixes Available", "Hotfix version (Z) behind latest", :yellow)
      options << header
      hotfixes.each do |mod|
        text = sprintf("%s: %s => %s", mod[:name], mod[:local], mod[:online])
        opt = ButtonOption.new(text, proc {}, " ")
        options << opt
      end
    end
    
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Mod Auto-Update Results"), 0, 0, Graphics.width, 64, @viewport)
    
    # Set custom textbox message
    if @sprites["textbox"]
      @sprites["textbox"].text = _INTL("Press A to continue")
    end
    
    # Apply menu colors
    if @sprites["option"] && @sprites["option"].respond_to?(:use_blue_colors=)
      @sprites["option"].use_blue_colors = true
    end
    
    # Initialize values
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def self.show_and_confirm(updates_available, skip_confirm = false)
    # Show the scene
    scene = AutoUpdateNotificationScene.new(updates_available)
    screen = PokemonOptionScreen.new(scene)
    screen.pbStartScreen
    
    # Ask for confirmation (unless disabled)
    if skip_confirm
      return true
    else
      count = updates_available.length
      return pbConfirmMessage(_INTL("Would you like to update all {1} mod(s)?", count))
    end
  end
end

# ============================================================================
# SEARCH RESULT OPTION
# ============================================================================
# A special read-only option that displays search results count
# ============================================================================
class SearchResultOption < Option
  attr_reader :name
  
  def initialize
    @name = "Search Results"
    @count = 0
  end
  
  def set_count(count)
    @count = count
  end
  
  # Mark this as a non-selectable UI element
  def non_interactive?
    return true
  end
  
  def get
    0
  end
  
  def set(value)
    # Read-only, do nothing
  end
  
  # Return empty values array (search result display doesn't cycle)
  def values
    return [""]
  end
  
  # Prevent the default value cycling behavior
  def next(current)
    return current
  end
  
  def prev(current)
    return current
  end
  
  def format(value)
    return "#{@count} matches found"
  end
end

# ============================================================================
# OPTIONS MENU INTEGRATION
# ============================================================================
# Patches the main Options menu to add a "Mod Settings" button.
# This button appears only when PIF/KIF Settings exist (to avoid clutter on vanilla).
# When clicked, it opens the ModSettingsScene with all registered mod options.
# ============================================================================
class PokemonOption_Scene
  # Create alias of original method if it exists and hasn't been aliased yet
  if method_defined?(:pbAddOnOptions) && !method_defined?(:pbAddOnOptions_modsettings)
    alias pbAddOnOptions_modsettings pbAddOnOptions
  end

  # Override to add "Mod Settings" button to the options list
  # @param in_options [Array] The existing options array
  # @return [Array] Modified options array with Mod Settings button added
  def pbAddOnOptions(in_options)
    options = pbAddOnOptions_modsettings(in_options)
    # Only show Mod Settings if PIF/KIF Settings exist (indicates modded game)
    show_in_options = options.any? do |o|
      o.respond_to?(:name) && (o.name == _INTL("PIF Settings") || o.name == _INTL("KIF Settings"))
    end
    # Don't add the button if we're already in ModSettingsScene or if no PIF/KIF settings exist
    unless self.is_a?(ModSettingsScene) || !show_in_options
      btn = ButtonOption.new(_INTL("Mod Settings"),
        proc {
          @mod_menu = true
          openModSettings()
        },
        "Configure installed mods")
      # Try to insert before "Save & Load Options" if it exists, otherwise append to end
      insert_index = options.index { |o| o.respond_to?(:name) && o.name == _INTL("Save & Load Options") }
      if insert_index && insert_index >= 0
        options.insert(insert_index, btn)
      else
        options << btn
      end
    end
    # Legacy code block - kept for compatibility but currently does nothing
    begin
      st = ModSettingsMenu.storage rescue nil
      if st && st.is_a?(Hash)
        st.keys.each do |k|
          next if false
        end
      end
    rescue
    end
    return options
  end

  # Opens the Mod Settings menu in a fade transition
  def openModSettings()
    return if !@mod_menu
    # Guard: avoid opening Mod Settings while PC Storage scene is active
    begin
      if defined?($scene) && $scene && (
        $scene.class.name.to_s.include?("PokemonStorageScene") ||
        ($scene.respond_to?(:cursormode) && $scene.cursormode.to_s == "multiselect")
      )
        @mod_menu = false
        return
      end
    rescue
    end
    pbFadeOutIn {
      scene = ModSettingsScene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
    }
    @mod_menu = false
  end
end

# ============================================================================
# MOD SETTINGS SCENE - COLOR OVERRIDE
# ============================================================================
# Override Window_PokemonOption to use purple colors (like IVs) in Mod Settings menu
if defined?(Window_PokemonOption) && !defined?($modsettings_blue_color_patched)
  $modsettings_blue_color_patched = true
  
  class Window_PokemonOption
    attr_accessor :use_blue_colors
    attr_accessor :nameBaseColor
    attr_accessor :nameShadowColor
    attr_accessor :selBaseColor
    attr_accessor :selShadowColor
    
    unless method_defined?(:modsettings_original_initialize)
      alias modsettings_original_initialize initialize
      def initialize(options, x, y, width, height)
        modsettings_original_initialize(options, x, y, width, height)
        # Apply color theme if enabled
        apply_modsettings_theme if @use_blue_colors
      end
    end
    
    # Apply the selected color theme
    def apply_modsettings_theme
      return unless defined?(ModSettingsMenu) && defined?(COLOR_THEMES)
      
      theme_index = ModSettingsMenu.get(:modsettings_color_theme) || 0
      theme_key = COLOR_THEMES.keys[theme_index]
      return unless theme_key
      
      theme = COLOR_THEMES[theme_key]
      if theme[:base] && theme[:shadow]
        @nameBaseColor = theme[:base]
        @nameShadowColor = theme[:shadow]
        @selBaseColor = theme[:base]
        @selShadowColor = theme[:shadow]
      end
    end
    
    # Allow setting purple colors after initialization
    def use_blue_colors=(value)
      @use_blue_colors = value
      apply_modsettings_theme if value
      refresh if respond_to?(:refresh)
    end
    
    # Override drawItem to use selected theme colors for CategoryHeaderOption and SearchResultOption
    unless method_defined?(:modsettings_original_drawItem)
      alias modsettings_original_drawItem drawItem
      def drawItem(index, _count, rect)
        # Check if this is a category header or search result
        if index < @options.length && (@options[index].is_a?(CategoryHeaderOption) || @options[index].is_a?(SearchResultOption))
          # Use selected category theme colors for category headers and search results
          old_name_base = @nameBaseColor
          old_name_shadow = @nameShadowColor
          old_sel_base = @selBaseColor
          old_sel_shadow = @selShadowColor
          
          # Get category theme index (default to red = 3)
          category_theme_index = ModSettingsMenu.get(:modsettings_category_theme) || 3
          category_theme_key = COLOR_THEMES.keys[category_theme_index]
          category_theme = COLOR_THEMES[category_theme_key]
          
          @nameBaseColor = category_theme[:base]
          @nameShadowColor = category_theme[:shadow]
          @selBaseColor = category_theme[:base]
          @selShadowColor = category_theme[:shadow]
          
          # For category headers, draw cursor and centered text
          if @options[index].is_a?(CategoryHeaderOption)
            # Draw bright white cursor if this is the selected item
            if index == self.index
              begin
                # Load and draw cursor with bright white tone
                arrow = AnimatedBitmap.new("Graphics/Pictures/selarrow")
                src_rect = Rect.new(0, 0, arrow.width, arrow.height)
                self.contents.blt(0, rect.y, arrow.bitmap, src_rect, 255)
                arrow.dispose
              rescue
                # Fallback if image doesn't exist
                pbDrawShadowText(self.contents, 4, rect.y, 32, rect.height, ">",
                               Color.new(255, 255, 255), Color.new(128, 128, 128))
              end
            end
            
            optionvalue = (@options[index].get || 0)
            text = @options[index].format(optionvalue)
            
            # Calculate text width and center position (x-axis only)
            text_width = 200  # Default width
            if self.contents && self.contents.respond_to?(:text_size)
              begin
                text_size_result = self.contents.text_size(text)
                text_width = text_size_result.width if text_size_result && text_size_result.respond_to?(:width)
              rescue
                text_width = 200
              end
            end
            x_pos = (rect.width - text_width) / 2
            
            # Draw centered text using standard rect.y position
            pbDrawShadowText(self.contents, x_pos, rect.y, text_width, rect.height, text,
                           @nameBaseColor, @nameShadowColor)
          else
            modsettings_original_drawItem(index, _count, rect)
          end
          
          # Restore original colors
          @nameBaseColor = old_name_base
          @nameShadowColor = old_name_shadow
          @selBaseColor = old_sel_base
          @selShadowColor = old_sel_shadow
        else
          # Normal drawing for non-category items
          modsettings_original_drawItem(index, _count, rect)
        end
      end
    end
    
    # Override update to prevent cursor skipping on special options
    unless method_defined?(:modsettings_original_update)
      alias modsettings_original_update update
      def update
        # Store the current index before update
        oldindex = self.index
        
        # Call parent update (handles input and cursor movement)
        modsettings_original_update
        
        # After parent update, check if we landed on a special option type
        if self.index < @options.length
          current_option = @options[self.index]
          
          # Category headers and search results should not trigger value updates
          if current_option.is_a?(CategoryHeaderOption) || current_option.is_a?(SearchResultOption)
            @mustUpdateOptions = false
          end
        end
      end
    end
  end
end

# ============================================================================
# MOD SETTINGS SCENE
# ============================================================================
# Custom scene for displaying all registered mod settings in a menu.
# Inherits from PokemonOption_Scene to reuse the options UI framework.
# Handles deduplication of options and dynamic option generation.
# ============================================================================
class ModSettingsScene < PokemonOption_Scene
  attr_accessor :search_term
  
  def initialize
    super
    @search_term = ""
  end
  
  # Builds the array of options to display in the Mod Settings menu
  # Now with category support and search filtering
  # @param inloadscreen [Boolean] Whether called from load screen (unused)
  # @return [Array<Option>] Array of option objects to display
  def pbGetOptions(inloadscreen = false)
    options = []
    search_active = @search_term && !@search_term.empty?
    search_lower = search_active ? @search_term.downcase : ""
    
    # Organize entries by category
    categorized = {}
    uncategorized = []
    nocategory = []  # Special items that appear without category headers
    seen_keys = {}
    
    ModSettingsMenu.registry.each do |entry|
      key = entry[:key]
      next if key && seen_keys[key]
      
      opt = entry[:option]
      next unless opt.is_a?(Option)
      
      category = entry[:category]
      item_data = {key: key, option: opt, entry: entry}
      
      if category == ModSettingsMenu::NOCATEGORY
        # Special case: no category header
        nocategory << item_data
      elsif category && !category.empty?
        categorized[category] ||= []
        categorized[category] << item_data
      else
        uncategorized << item_data
      end
      
      seen_keys[key] = true if key
    end
    
    # If search is active, filter and flatten all options
    if search_active
      match_count = 0
      
      # Helper method to check if text matches search
      matches_search = proc do |text|
        text && text.to_s.downcase.include?(search_lower)
      end
      
      # First pass: Build mod_names hash for both regular options and ButtonOptions
      mod_names = {}
      all_items = uncategorized + nocategory + categorized.values.flatten
      
      all_items.each do |item|
        opt = item[:option]
        entry = item[:entry] || {}
        
        # For ButtonOption (submenus), use the button name as the mod name
        if opt.is_a?(ButtonOption)
          button_name = opt.respond_to?(:name) ? opt.name.to_s : ""
          if !button_name.empty?
            mod_name_lower = button_name.downcase
            mod_names[mod_name_lower] ||= []
            mod_names[mod_name_lower] << {item: item, is_submenu: true}
          end
          
          # Also check searchable_items for ButtonOption
          if entry[:searchable_items].is_a?(Array)
            entry[:searchable_items].each do |keyword|
              if keyword && matches_search.call(keyword.to_s)
                mod_names[button_name.downcase] ||= []
                mod_names[button_name.downcase] << {item: item, is_submenu: true}
                break
              end
            end
          end
        else
          # For regular options, extract mod name from text before colon
          name = opt.respond_to?(:name) ? opt.name.to_s : ""
          formatted = ""
          if opt.respond_to?(:format) && opt.respond_to?(:get)
            begin
              formatted = opt.format(opt.get || 0).to_s
            rescue
              formatted = ""
            end
          end
          
          # Extract mod name (text before colon)
          mod_name = ""
          if name.include?(":")
            mod_name = name.split(":").first.strip
          elsif formatted.include?(":")
            mod_name = formatted.split(":").first.strip
          end
          
          if !mod_name.empty?
            mod_names[mod_name.downcase] ||= []
            mod_names[mod_name.downcase] << {item: item, is_submenu: false}
          end
        end
      end
      
      # Check if search term matches a mod name or submenu name
      matching_mod_items = []
      mod_names.each do |mod_name_lower, items|
        if matches_search.call(mod_name_lower)
          matching_mod_items.concat(items)
        end
      end
      
      # If search matches a mod/submenu name, show ButtonOption and all settings from that mod
      if matching_mod_items.any?
        matching_mod_items.each do |mod_item|
          options << mod_item[:item][:option]
          match_count += 1
        end
      else
        # Otherwise, search individual settings (including ButtonOptions)
        # Add uncategorized settings that match search
        uncategorized.each do |item|
          opt = item[:option]
          name = opt.respond_to?(:name) ? opt.name.to_s : ""
          desc = opt.respond_to?(:description) ? opt.description.to_s : ""
          formatted = ""
          if opt.respond_to?(:format) && opt.respond_to?(:get)
            begin
              formatted = opt.format(opt.get || 0).to_s
            rescue
              formatted = ""
            end
          end
          
          if matches_search.call(name) || 
             matches_search.call(desc) ||
             matches_search.call(formatted)
            options << opt
            match_count += 1
          end
        end
        
        # Add categorized settings that match search
        ModSettingsMenu.categories.sort_by { |c| c[:priority] }.each do |cat|
          next unless categorized[cat[:name]]
          
          categorized[cat[:name]].each do |item|
            opt = item[:option]
            name = opt.respond_to?(:name) ? opt.name.to_s : ""
            desc = opt.respond_to?(:description) ? opt.description.to_s : ""
            formatted = ""
            if opt.respond_to?(:format) && opt.respond_to?(:get)
              begin
                formatted = opt.format(opt.get || 0).to_s
              rescue
                formatted = ""
              end
            end
            
            if matches_search.call(name) || 
               matches_search.call(desc) ||
               matches_search.call(formatted)
              options << opt
              match_count += 1
            end
          end
        end
      end
      
      # Add search result count at the top
      result_opt = SearchResultOption.new
      result_opt.set_count(match_count)
      options.unshift(result_opt)
    else
      # Normal category display with collapsible headers
      
      # Add ALL categorized settings with headers (sorted by priority)
      ModSettingsMenu.categories.sort_by { |c| c[:priority] }.each do |cat|
        # Check if this category has any items
        has_items = false
        if cat[:name] == "Uncategorized"
          has_items = uncategorized.any?
        else
          has_items = categorized[cat[:name]] && categorized[cat[:name]].any?
        end
        
        # Only show header if category has items
        next unless has_items
        
        # Add category header
        header = CategoryHeaderOption.new(cat[:name], cat[:description])
        options << header
        
        # Add settings if not collapsed
        if cat[:name] == "Uncategorized"
          unless cat[:collapsed]
            uncategorized.each do |item|
              options << item[:option]
            end
          end
        elsif categorized[cat[:name]] && !cat[:collapsed]
          categorized[cat[:name]].each do |item|
            options << item[:option]
          end
        end
      end
      
      # Add nocategory items at the end (no headers)
      nocategory.each do |item|
        options << item[:option]
      end
    end
    
    return options
  end

  # Initializes and displays the Mod Settings scene
  # Sets up the UI, loads saved settings from file, and restores menu position
  # @param inloadscreen [Boolean] Whether called from load screen (unused)
  def pbStartScene(inloadscreen = false)
    # Load settings and restore collapse states BEFORE parent initialization
    begin
      if defined?(ModSettingsMenu)
        mods_file = RTP.getSaveFolder + "\\Mod_Settings.kro"
        if File.exists?(mods_file) && defined?(kurayjson_load)
          loaded = kurayjson_load(mods_file) rescue nil
          if loaded.is_a?(Hash)
            ModSettingsMenu.set_storage(loaded)
          end
        end
        # Restore category collapse states from loaded settings
        ModSettingsMenu.restore_category_states
      end
    rescue
    end
    
    super  # Call parent class initialization
    
    # Set custom title for this scene
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Mod Settings"), 0, 0, Graphics.width, 64, @viewport)
    
    # Enable blue colors for this menu
    if @sprites["option"] && @sprites["option"].respond_to?(:use_blue_colors=)
      @sprites["option"].use_blue_colors = true
    end
    
    # Initialize all option values from storage
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    # Always start at the top (index 0)
    @sprites["option"].index = 0 if @sprites["option"]
    
    @sprites["option"].refresh if @sprites && @sprites["option"]
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  # Creates the search box UI element (only when search is activated)
  def create_search_box
    if @sprites && !@sprites["textbox"]
      @sprites["textbox"] = Window_UnformattedTextPokemon.newWithSize(
        "", 0, Graphics.height - 64, Graphics.width, 64, @viewport)
      @sprites["textbox"].visible = true
      # Set text color to white
      if @sprites["textbox"].respond_to?(:baseColor=)
        @sprites["textbox"].baseColor = Color.new(255, 255, 255)
        @sprites["textbox"].shadowColor = Color.new(128, 128, 128)
      end
    end
  end
  
  # Removes the search box UI element
  def remove_search_box
    if @sprites && @sprites["textbox"]
      @sprites["textbox"].dispose
      @sprites.delete("textbox")
    end
  end
  
  # Updates the search box display
  def update_search_box
    if @sprites && @sprites["textbox"]
      @sprites["textbox"].text = "Search: #{@search_term} (Left Ctrl: clear)"
    end
  end
  
  # Opens search input dialog
  def open_search
    pbPlayDecisionSE
    @search_term = pbMessageFreeText(_INTL("Search settings:"), @search_term, false, 30) || ""
    @search_term = @search_term.strip
    if !@search_term.empty?
      create_search_box
      update_search_box
    end
    refresh_options
  end
  
  # Clears the search term
  def clear_search
    pbPlayDecisionSE
    @search_term = ""
    remove_search_box
    refresh_options
  end
  
  # Refreshes the options list after search or category toggle
  def refresh_options
    # Rebuild options list
    @PokemonOptions = pbGetOptions
    
    # Recreate the option window with new options
    if @sprites && @sprites["option"]
      old_index = @sprites["option"].index rescue 0
      @sprites["option"].dispose
      
      # Calculate height based on whether textbox exists
      textbox_height = (@sprites["textbox"] && @sprites["textbox"].height) || 0
      @sprites["option"] = Window_PokemonOption.new(@PokemonOptions, 0, @sprites["title"].height, 
                                                      Graphics.width, Graphics.height - @sprites["title"].height - textbox_height)
      @sprites["option"].viewport = @viewport
      @sprites["option"].visible = true
      @sprites["option"].use_blue_colors = true if @sprites["option"].respond_to?(:use_blue_colors=)
      
      # Initialize values
      for i in 0...@PokemonOptions.length
        @sprites["option"][i] = (@PokemonOptions[i].get || 0)
      end
      
      # Restore or reset index
      @sprites["option"].index = [old_index, @PokemonOptions.length - 1].min if old_index < @PokemonOptions.length
      @sprites["option"].refresh
    end
  end
  
  # Override to handle category header clicks and search
  def pbOptions
    pbActivateWindow(@sprites, "option") {
      oldopt = -1
      loop do
        # Manual cursor update without calling Window.update to avoid base class navigation bugs
        if @sprites && @sprites["option"]
          idx = @sprites["option"].index
          
          # Update description text when cursor moves
          if idx != oldopt
            oldopt = idx
            if @PokemonOptions[idx] && @PokemonOptions[idx].respond_to?(:description)
              desc = @PokemonOptions[idx].description
              # Only show descriptions in textbox when searching
              if !@search_term.empty?
                update_search_box
              end
            end
          end
        end
        
        Graphics.update
        Input.update
        pbUpdate
        
        # Left Control - Search
        if Input.trigger?(Input::CTRL)
          if @search_term.empty?
            open_search
          else
            clear_search
          end
          next
        end
        
        # Handle USE button for special option types
        if Input.trigger?(Input::USE)
          idx = @sprites["option"].index
          if @PokemonOptions[idx].is_a?(CategoryHeaderOption)
            pbPlayDecisionSE
            @PokemonOptions[idx].set(0) # Toggle
            refresh_options
            next
          elsif @PokemonOptions[idx].is_a?(SearchResultOption)
            # Can't interact with search result display
            pbPlayBuzzerSE
            next
          end
          # Let normal options and parent class handle everything else
        end
        
        # Handle mustUpdateOptions flag for normal option changes
        if @sprites["option"].mustUpdateOptions
          # Set the values of each option (skip category headers and search results)
          for i in 0...@PokemonOptions.length
            next if @PokemonOptions[i].is_a?(CategoryHeaderOption)
            next if @PokemonOptions[i].is_a?(SearchResultOption)
            @PokemonOptions[i].set(@sprites["option"][i])
          end
        end
        
        # Back button - exit search if active, otherwise exit menu
        if Input.trigger?(Input::BACK)
          if !@search_term.empty?
            # Back out of search
            clear_search
            next
          else
            # Exit menu
            break
          end
        end
      end
    }
  end

  # Cleanup when exiting the Mod Settings scene
  # Saves current menu position and writes all settings to Mod_Settings.kro file
  def pbEndScene
    # Write all mod settings to disk
      begin
        if defined?(ModSettingsMenu) && defined?(kurayjson_save)
          mods_file = RTP.getSaveFolder + "\\Mod_Settings.kro"
          data = ModSettingsMenu.storage rescue nil
          kurayjson_save(mods_file, data) if data.is_a?(Hash)
        end
      rescue
      end
    
    super  # Call parent class cleanup
    
    # Clear lingering input state after parent cleanup to prevent sounds on next scene
    begin
      6.times do
        Graphics.update
        Input.update
      end
    rescue
    end
    
    # Failsafe: ensure any lingering windows/viewports are disposed
    begin
      if @sprites && @viewport
        @sprites.each_value do |spr|
          begin
            spr.dispose if spr && spr.respond_to?(:dispose)
          rescue
          end
        end
        @sprites.clear
        @viewport.dispose if @viewport && @viewport.respond_to?(:dispose)
      end
    rescue
    end
  end
end

# Global guard: prevent Mod Settings update/open from interfering with PC Storage scenes
module ModSettingsMenuPCGuard
  def self.in_pc_storage_scene?
    begin
      s = $scene
      return false if s.nil?
      name = s.class.name.to_s
      return (name.include?("PokemonStorageScene") || name.include?("Storage") || name.include?("PC"))
    rescue
      return false
    end
  end
end

# Apply guard to ModSettingsScene update loop if present
if defined?(ModSettingsScene)
  class ModSettingsScene
    if instance_methods(false).include?(:pbUpdate) && !instance_methods(false).include?(:pbUpdate_pc_guarded)
      alias pbUpdate_pc_guarded pbUpdate
      def pbUpdate(*args)
        return if ModSettingsMenuPCGuard.in_pc_storage_scene?
        pbUpdate_pc_guarded(*args)
      end
    end
  end
end

# ============================================================================
# JSON SERIALIZATION INTEGRATION
# ============================================================================
# Hooks into the game's JSON save/load system to include mod settings.
# This ensures mod settings are saved with game options and restored on load.
# Uses method aliasing to extend existing save/load functionality.
# ============================================================================
Object.class_eval do
  # Hook into options serialization to include mod settings in JSON output
  if private_method_defined?(:options_as_json)
    unless private_method_defined?(:options_as_json_modsettings)
      alias_method :options_as_json_modsettings, :options_as_json
    end
    # Extended version that adds mod_settings to the JSON output
    define_method(:options_as_json) do |*args|
      current = options_as_json_modsettings(*args)
      begin
        if defined?(ModSettingsMenu)
          # Add mod settings under "mod_settings" key in the JSON
          current["mod_settings"] = ModSettingsMenu.storage
        end
      rescue
      end
      current
    end
  end
  
  # Hook into options deserialization to restore mod settings from JSON
  if private_method_defined?(:options_load_json)
    unless private_method_defined?(:options_load_json_modsettings)
      alias_method :options_load_json_modsettings, :options_load_json
    end
    # Extended version that extracts and loads mod_settings from JSON
    define_method(:options_load_json) do |jsonparse|
      options_load_json_modsettings(jsonparse)
      begin
        if jsonparse.is_a?(Hash) && jsonparse.key?("mod_settings")
          if defined?(ModSettingsMenu)
            # Restore all mod settings from the saved JSON data
            ModSettingsMenu.set_storage(jsonparse["mod_settings"])
          end
        end
      rescue
      end
    end
  end
end

#========================================
# BATTLE MENU SYSTEM
#========================================
# Opens a command menu when AUX2 (R button) is pressed during battle on your turn.
# Other mods can register commands to appear in this menu (e.g., Quick Throw).
# The system checks conditions and allows mods to execute actions mid-battle.
#========================================

# Register the toggle setting for enabling/disabling the battle menu
if defined?(ModSettingsMenu)
  # Register settings using predefined categories
  ModSettingsMenu.register_toggle(
    :battle_command_menu,
    _INTL("Battle Menu"),
    _INTL("Press AUX2 during battle to open a command menu"),
    0,  # Default: Off (user must enable it)
    "Interface & Menus"
  )
  ModSettingsMenu.register_toggle(
    :overworld_menu,
    _INTL("Overworld Menu"),
    _INTL("Press ACTION in the overworld to open the quick menu"),
    1,  # Default: On to preserve existing behavior
    "Interface & Menus"
  )
end

# ============================================================================
# BATTLE COMMAND MENU - REGISTRY MODULE
# ============================================================================
# Central registry for battle commands that can be executed from the battle menu.
# Mods register their commands here with name, proc, description, condition, priority.
# ============================================================================
module BattleCommandMenu
  # Array to store all registered battle commands
  @registry = []
  
  class << self
    # Returns the registry of all registered battle commands
    def registry
      @registry ||= []
    end
    
    # Registers a new command to appear in the battle menu
    # @param name [String] Display name for the command
    # @param proc [Proc] Code to execute when command is selected (receives battle, idxBattler, scene)
    # @param description [String] Help text describing the command
    # @param condition [Proc, nil] Optional condition check (receives battle, idxBattler) - command only shows if true
    # @param priority [Integer] Sort order (lower numbers appear first, default 100)
    def register_command(name, proc, description = "", condition = nil, priority = 100)
      registry << {
        name: name,
        proc: proc,
        description: description,
        condition: condition,
        priority: priority
      }
    end
    
    # Gets all commands that should be available for the current battle state
    # @param battle [PokeBattle_Battle] The active battle instance
    # @param idxBattler [Integer] Index of the current battler
    # @return [Array<Hash>] Filtered and sorted array of available commands
    def get_available_commands(battle, idxBattler)
      available = []
      registry.each do |cmd|
        # Check condition if one is specified
        if cmd[:condition]
          begin
            next unless cmd[:condition].call(battle, idxBattler)
          rescue
            next  # Skip command if condition check fails
          end
        end
        available << cmd
      end
      # Sort by priority (lower priority values appear first)
      return available.sort_by { |cmd| cmd[:priority] || 100 }
    end
    
    # Clears all registered commands (useful for testing/debugging)
    def clear_registry
      @registry = []
    end
  end
end

# ============================================================================
# BATTLE COMMAND MENU - UI PATCH
# ============================================================================
# Patches PokeBattle_Scene to intercept AUX2 button press during battle.
# When pressed, displays a menu of available battle commands.
# Uses prepend to override pbCommandMenuEx while maintaining access to original.
# ============================================================================
module BattleCommandMenuPatch
  # Override the battle command menu to add AUX2 (R button) handling
  # @param idxBattler [Integer] Index of the current battler making a choice
  # @param texts [Array<String>] Command button texts (Fight, Bag, Pokemon, Run)
  # @param mode [Integer] Command menu mode (0 = normal, 1 = can cancel)
  # @return [Integer] Selected command index, or special values (-1, -2, -100)
  def pbCommandMenuEx(idxBattler, texts, mode = 0)
    # Check if battle menu is enabled in settings
    enabled = false
    begin
      if defined?(ModSettingsMenu)
        setting = ModSettingsMenu.get(:battle_command_menu)
        enabled = (setting == 1 || setting == true)
      end
    rescue
      enabled = false
    end
    
    # If disabled, use original behavior
    if !enabled
      return super
    end
    
    # Show the command window
    pbShowWindow(PokeBattle_Scene::COMMAND_BOX)
    cw = @sprites["commandWindow"]
    cw.setTexts(texts)
    cw.setIndexAndMode(@lastCmd[idxBattler], mode)
    pbSelectBattler(idxBattler)
    ret = -1
    
    # Main input loop
    loop do
      oldIndex = cw.index
      pbUpdate(cw)
      
      # Handle directional input to move cursor
      if Input.trigger?(Input::LEFT)
        cw.index -= 1 if (cw.index & 1) == 1
      elsif Input.trigger?(Input::RIGHT)
        cw.index += 1 if (cw.index & 1) == 0
      elsif Input.trigger?(Input::UP)
        cw.index -= 2 if (cw.index & 2) == 2
      elsif Input.trigger?(Input::DOWN)
        cw.index += 2 if (cw.index & 2) == 0
      end
      pbPlayCursorSE if cw.index != oldIndex
      
      # AUX2 (R button) - Open battle command menu
      if Input.trigger?(Input::AUX2)
        pbPlayDecisionSE
        begin
          menu_result = pbOpenBattleCommandMenu(idxBattler)
          # Special return value for Quick Throw and similar commands
          if menu_result == :quick_throw_used
            ret = -100
            break
          end
          next  # Return to command selection after menu closes
        rescue => e
          pbPrintException(e) if $DEBUG
          next
        end
      end
      
      # USE button (confirm) - Select the highlighted command
      if Input.trigger?(Input::USE)                 
        pbPlayDecisionSE
        ret = cw.index
        @lastCmd[idxBattler] = ret
        break
      # BACK button (cancel) - Only works if mode allows it
      elsif Input.trigger?(Input::BACK) && mode == 1   
        pbPlayCancelSE
        break
      # F9 in debug mode - Debug options
      elsif Input.trigger?(Input::F9) && $DEBUG    
        pbPlayDecisionSE
        ret = -2
        break
      end
    end
    return ret
  end
  
  # Opens the battle command menu and handles command selection
  # @param idxBattler [Integer] Index of the current battler
  # @return [Symbol, Boolean] :quick_throw_used for special commands, true/false otherwise
  def pbOpenBattleCommandMenu(idxBattler)
    # Get all commands available in this battle state
    available_commands = BattleCommandMenu.get_available_commands(@battle, idxBattler)
    
    # Show message if no commands are available
    if available_commands.empty?
      pbDisplay(_INTL("No battle commands available."))
      return false
    end
    
    # Build command list with Cancel option
    command_names = available_commands.map { |cmd| cmd[:name] }
    command_names << _INTL("Cancel")
    
    # Display menu and get player choice
    choice = pbShowCommands_BattleCommandMenu(_INTL("Battle Commands"), command_names, -1)
    
    # Return false if cancelled or invalid choice
    return false if choice < 0 || choice >= available_commands.length
    
    # Execute the selected command's proc
    begin
      selected_command = available_commands[choice]
      result = selected_command[:proc].call(@battle, idxBattler, self)
      # Pass through special return values (like :quick_throw_used)
      return result if result == :quick_throw_used
      return true
    rescue => e
      pbPrintException(e) if $DEBUG
      return false
    end
  end
  
  # Helper method to show command menu with message
  # @param message [String] Title message to display
  # @param commands [Array<String>] List of command names
  # @param default [Integer] Default selected index
  # @return [Integer] Index of selected command, or -1 if cancelled
  def pbShowCommands_BattleCommandMenu(message, commands, default = 0)
    msgwindow = pbDisplayMessage_BattleCommandMenu(message, false)
    
    choice = -1
    if msgwindow
      choice = pbShowMessageChoices_BattleCommandMenu(msgwindow, commands, default)
    end
    
    pbDisposeMessageWindow_BattleCommandMenu(msgwindow) if msgwindow
    return choice
  end
  
  # Displays a command window and handles player selection
  # @param msgwindow [Window] Message window showing the title
  # @param commands [Array<String>] List of commands to display
  # @param default [Integer] Default selected index
  # @return [Integer] Index of selected command, or -1 if cancelled
  def pbShowMessageChoices_BattleCommandMenu(msgwindow, commands, default = 0)
    # Create command selection window
    cmdwindow = Window_CommandPokemon.new(commands)
    cmdwindow.z = 99999  # Ensure it appears above other battle UI
    cmdwindow.index = default if default >= 0 && default < commands.length
    cmdwindow.visible = true
    
    # Position window in bottom-right corner, above message window
    cmdwindow.x = Graphics.width - cmdwindow.width
    cmdwindow.y = Graphics.height - cmdwindow.height - (msgwindow ? msgwindow.height : 0)
    
    ret = -1
    loop do
      # Update graphics and input
      if Graphics.respond_to?(:fast_forward_update)
        Graphics.fast_forward_update
      else
        Graphics.update
      end
      Input.update
      cmdwindow.update
      msgwindow.update if msgwindow
      
      # Handle input
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = cmdwindow.index
        break
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        ret = -1
        break
      end
    end
    
    cmdwindow.dispose
    return ret
  end
  
  # Displays a message window with optional input wait
  # @param message [String] Message to display
  # @param waitForInput [Boolean] Whether to wait for player confirmation
  # @return [Window, nil] Message window (if not waiting), or nil (if waiting)
  def pbDisplayMessage_BattleCommandMenu(message, waitForInput = true)
    msgwindow = pbDisplayMessageWindow_BattleCommandMenu(message)
    if waitForInput
      pbWaitMessage_BattleCommandMenu
      pbDisposeMessageWindow_BattleCommandMenu(msgwindow)
      return nil
    end
    return msgwindow
  end
  
  # Creates and displays a message window
  # @param message [String] Message text to display
  # @return [Window] The created message window
  def pbDisplayMessageWindow_BattleCommandMenu(message)
    # Try to use existing battle message window if available
    if @sprites && @sprites["messageWindow"]
      @sprites["messageWindow"].text = message
      @sprites["messageWindow"].visible = true
      return @sprites["messageWindow"]
    end
    
    # Create new message window if needed
    msgwindow = Window_AdvancedTextPokemon.newWithSize(
      "", 0, Graphics.height - 96, Graphics.width, 96
    )
    msgwindow.z = 99999
    msgwindow.text = message
    msgwindow.visible = true
    return msgwindow
  end
  
  # Safely disposes a message window (unless it's the battle's main message window)
  # @param msgwindow [Window] The window to dispose
  def pbDisposeMessageWindow_BattleCommandMenu(msgwindow)
    return if !msgwindow
    # Don't dispose the battle's permanent message window
    return if @sprites && @sprites["messageWindow"] == msgwindow
    msgwindow.dispose
  end
  
  # Waits for player to press a button to continue
  def pbWaitMessage_BattleCommandMenu
    loop do
      if Graphics.respond_to?(:fast_forward_update)
        Graphics.fast_forward_update
      else
        Graphics.update
      end
      Input.update
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        break
      end
    end
  end
end

# Apply the patch to PokeBattle_Scene using prepend
# Prepend ensures our override runs first, with access to original via super
class PokeBattle_Scene
  prepend BattleCommandMenuPatch
end

# ============================================================================
# PC MOD ACTIONS MENU
# ============================================================================
# Adds a "Mod Actions" option to the PC Pokemon menu (alongside Move, Summary, etc.).
# Mods can register custom actions that appear when this option is selected.
# Examples: changing abilities, editing stats, applying custom effects to Pokemon.
# ============================================================================

# ============================================================================
# PC MOD ACTIONS - REGISTRY MODULE
# ============================================================================
# Central registry for PC mod actions. Mods register handlers here with:
# - name: Display name (can be a Proc for dynamic names)
# - condition: Optional check if action should be available for a Pokemon
# - effect: Code to execute when action is selected
# - supports_batch: Whether this action can be applied to multiple Pokemon at once
# ============================================================================
module ModSettingsMenu
  module PCModActions
    # Array to store all registered PC mod action handlers
    @handlers = []
    
    class << self
      # Returns the registry of all registered PC mod action handlers
      def handlers
        @handlers ||= []
      end
      
      # Registers a new PC mod action handler
      # @param handler [Hash] Handler definition with :name, :condition, :effect, :supports_batch keys
      #   :name - String or Proc returning the display name
      #   :condition - Optional Proc(pokemon) returning true/false if action is available
      #   :effect - Proc(pokemon, selected, heldpoke, scene) to execute the action
      #   :supports_batch - Boolean indicating if action can be applied to multiple Pokemon (default: true)
      def register(handler)
        # Default supports_batch to true if not specified
        handler[:supports_batch] = true unless handler.key?(:supports_batch)
        handlers << handler unless handlers.include?(handler)
      end
      
      # Clears all registered handlers (useful for testing/debugging)
      def clear
        @handlers = []
      end
      
      # Checks if any mod actions are registered
      # @return [Boolean] true if at least one handler is registered
      def has_actions?
        handlers.any?
      end
      
      # Checks if any batch-capable actions are registered
      # @return [Boolean] true if at least one handler supports batch operations
      def has_batch_actions?
        handlers.any? { |h| h[:supports_batch] }
      end
    end
  end
end

# ============================================================================
# UPDATE CHECK MODULE
# ============================================================================
# Checks for mod updates by comparing local versions to online manifest
# ============================================================================
# Adds a simple utility action to list all detected mods and their versions.
# Version is read from the top of each .rb mod file using:
# Script Version: X.Y.Z
# Add this to your mod file then inform Stonewall to include it in the manifest.
# ============================================================================
# Update Check Tiers:
# Major Updates Available (Red Color) - X is different from latest.
# Minor Updates Available (Orange Color) - Y is different from latest
# Hotfixes Available (Yellow Color) - Z is different from latest.
# Up to Date (Green Color) - Version matches latest.
# Not Tracked: Mod is not in the online manifest yet. Contact Stonewall to add it.
# ============================================================================
module ModSettingsMenu
  module VersionCheck
    SEARCH_DIRS = ["Mods"]
    MAX_HEADER_LINES = 40

    # Collects all .rb mod files from known mod folders
    def self.find_mod_files
      files = []
      SEARCH_DIRS.each do |dir|
        begin
          Dir.glob(File.join(dir, "**", "*.rb")) { |f| files << f }
        rescue
        end
      end
      return files
    end

    # Extract a mod display name and version string from file contents
    def self.extract_metadata(path)
      name = File.basename(path, ".rb")
      folder = begin
        parts = path.split(/[\\\/]/)
        parts[0] || ""
      rescue
        ""
      end

      version = nil
      begin
        count = 0
        File.foreach(path) do |line|
          count += 1
          break if count > MAX_HEADER_LINES
          # Only match: # Script Version: x.y.z
          if line =~ /^\s*#\s*Script Version:\s*([^\r\n#]+)/i
            version = $1.to_s.strip
            break
          end
        end
      rescue
      end

      return { name: name, version: version, path: path, folder: folder }
    end

    # Returns an array of unique mods with disambiguated names if needed
    def self.collect
      mods = find_mod_files.map { |p| extract_metadata(p) }
      # Only keep mods with a Script Version header
      mods.select! { |m| m[:version] && !m[:version].empty? }
      # Disambiguate duplicate names across folders
      counts = Hash.new(0)
      mods.each { |m| counts[m[:name]] += 1 }
      mods.each do |m|
        if counts[m[:name]] > 1 && m[:folder] && !m[:folder].empty?
          m[:display_name] = sprintf("%s (%s)", m[:name], m[:folder])
        else
          m[:display_name] = m[:name]
        end
      end
      # Sort alphabetically
      mods.sort_by! { |m| m[:display_name].downcase }
      return mods
    end
  end
  

  module UpdateCheck
    # URL to the online mod versions manifest (JSON format)
    MANIFEST_URL = "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/mod_versions_manifest.json"
    
    # ============================================================================
    # MANIFEST FORMAT
    # ============================================================================
    # The manifest JSON file supports two formats for each mod entry:
    #
    # 1. Simple format (version string only):
    #    "ModName": "3.0.1"
    #
    # 2. Full format (with download URLs and graphics):
    #    "ModName": {
    #      "version": "3.0.1",
    #      "download_url": "https://raw.githubusercontent.com/user/repo/main/mods/ModName.rb",
    #      "changelog_url": "https://raw.githubusercontent.com/user/repo/main/changelogs/modname.txt",
    #      "graphics": [
    #        {
    #          "url": "https://raw.githubusercontent.com/user/repo/main/graphics/sprite1.png",
    #          "path": "Graphics/Battlers/sprite1.png"
    #        },
    #        {
    #          "url": "https://raw.githubusercontent.com/user/repo/main/graphics/sprite2.png",
    #          "path": "Graphics/Characters/sprite2.png"
    #        }
    #      ]
    #    }
    #
    # Fields:
    # - version (required): Semantic version string (X.Y or X.Y.Z)
    # - download_url (optional): Direct URL to download the .rb file
    # - changelog_url (optional): URL to text file with version history
    # - graphics (optional): Array of graphics files with url and relative path
    #
    # Note: "ModName" must exactly match the .rb filename (without extension)
    # ============================================================================
    
    # Parse version string to components (e.g., "3.0.1" -> [[3, 0, 1], true])
    # Returns [[major, minor, patch], has_patch] where has_patch indicates if Z was explicitly specified
    def self.parse_version(version_str)
      return [[0, 0, 0], false] if version_str.nil? || version_str.empty?
      parts = version_str.split('.')
      major = parts[0].to_i
      minor = parts[1].to_i if parts.length > 1
      minor ||= 0
      patch = parts[2].to_i if parts.length > 2
      patch ||= 0
      has_patch = parts.length > 2  # Track if patch was explicitly specified
      return [[major, minor, patch], has_patch]
    end
    
    # Fetch the online manifest and parse JSON
    # Uses the game's built-in HTTPLite module
    def self.fetch_manifest
      begin
        ModSettingsMenu.debug_log("Fetching manifest from: #{MANIFEST_URL}")
        
        # HTTPLite.get returns a hash with :status and :body keys
        response = HTTPLite.get(MANIFEST_URL)
        
        if response.is_a?(Hash) && response[:status] == 200
          # Get response body
          body = response[:body]
          
          # Remove BOM (Byte Order Mark) if present at start of file
          body = body.sub(/^\xEF\xBB\xBF/, '') if body
          
          # Parse JSON from response body using MiniJSON (game's built-in parser)
          manifest = MiniJSON.parse(body)
          ModSettingsMenu.debug_log("Parsed manifest type: #{manifest.class}")
          
          # Validate that manifest is a Hash
          if manifest.is_a?(Hash)
            ModSettingsMenu.debug_log("Manifest loaded successfully with #{manifest.keys.length} mods")
            return manifest
          else
            ModSettingsMenu.debug_log("Error: Parsed manifest is not a Hash, got #{manifest.class}: #{manifest.inspect}")
            return nil
          end
        else
          status = response.is_a?(Hash) ? response[:status] : "unknown"
          ModSettingsMenu.debug_log("Failed to fetch manifest. Status: #{status}")
          return nil
        end
      rescue => e
        # Error during download or JSON parsing
        ModSettingsMenu.debug_log("Error fetching manifest: #{e.class} - #{e.message}")
        ModSettingsMenu.debug_log("Backtrace: #{e.backtrace.first(3).join("\n")}")
        return nil
      end
    end
    
    # Compare local mods with online manifest
    def self.check_updates
      # Get local mod versions
      local_mods = VersionCheck.collect
      return { error: "No local mods found." } if local_mods.nil? || local_mods.empty?
      
      # Fetch online manifest
      manifest = fetch_manifest
      
      # Check if manifest returned an error
      if manifest.is_a?(Hash) && manifest.key?(:error)
        return manifest
      end
      
      return { error: "Could not connect to update server. Check ModsDebug.txt for details." } if manifest.nil?
      
      results = {
        up_to_date: [],
        hotfixes: [],
        minor_updates: [],
        major_updates: [],
        developer_version: [],
        not_tracked: []
      }
      
      # Only loop through mods the user has installed locally
      local_mods.each do |mod|
        mod_name = mod[:name]
        
        # Check if this user's mod is in the manifest
        if manifest.key?(mod_name)
          manifest_entry = manifest[mod_name]
          
          # Parse manifest entry - can be string (version only) or hash (version + urls)
          if manifest_entry.is_a?(String)
            online_version = manifest_entry
            download_url = nil
            changelog_url = nil
            graphics = nil
            dependencies = nil
          elsif manifest_entry.is_a?(Hash)
            online_version = manifest_entry["version"]
            download_url = manifest_entry["download_url"]
            changelog_url = manifest_entry["changelog_url"]
            graphics = manifest_entry["graphics"]
            dependencies = manifest_entry["dependencies"]
          else
            # Invalid manifest entry
            results[:not_tracked] << { name: mod[:display_name], version: mod[:version] }
            next
          end
          
          local_parsed = parse_version(mod[:version])
          online_parsed = parse_version(online_version)
          
          local_ver, local_has_patch = local_parsed
          online_ver, online_has_patch = online_parsed
          
          local_major, local_minor, local_patch = local_ver
          online_major, online_minor, online_patch = online_ver
          
          # Build update info with all metadata
          update_info = {
            name: mod[:display_name],
            mod_name: mod_name,
            local: mod[:version],
            online: online_version,
            path: mod[:path],  # Full path to local mod file
            download_url: download_url,
            changelog_url: changelog_url,
            graphics: graphics,
            dependencies: dependencies
          }
          
          # Check version differences using semantic versioning
          if local_major > online_major || local_minor > online_minor || local_patch > online_patch
            # Local version is newer than manifest - developer version
            results[:developer_version] << update_info
          elsif local_major < online_major
            # Major version different (X.y.z)
            results[:major_updates] << update_info
          elsif local_minor < online_minor
            # Minor version different (x.Y.z)
            results[:minor_updates] << update_info
          elsif local_has_patch && local_patch < online_patch
            # Local has explicit patch and it's behind
            results[:hotfixes] << update_info
          elsif !local_has_patch && online_patch > 0
            # Local has no patch (e.g., "3.0") but manifest has a real patch (e.g., "3.0.1")
            results[:hotfixes] << update_info
          else
            # All versions match - still include full info for changelog access
            results[:up_to_date] << update_info
          end
        else
          # User has this mod but it's not tracked in the manifest
          results[:not_tracked] << { name: mod[:display_name], version: mod[:version] }
        end
      end
      # Note: We never loop through manifest to show mods user doesn't have
      
      return results
    end
    
    # Format results into a readable message
    def self.format_results(results)
      if results[:error]
        return results[:error]
      end
      
      message = ""
      
      if results[:much_older].any?
        message += "Out of Date:\n"
        results[:much_older].each do |mod|
          message += sprintf("  %s: %s → %s\n", mod[:name], mod[:local], mod[:online])
        end
        message += "\n"
      end
      
      if results[:updates_available].any?
        message += "Updates Available:\n"
        results[:updates_available].each do |mod|
          message += sprintf("  %s: %s → %s\n", mod[:name], mod[:local], mod[:online])
        end
        message += "\n"
      end
      
      if results[:up_to_date].any?
        message += "Up to Date:\n"
        results[:up_to_date].each do |mod|
          message += sprintf("  %s (%s)\n", mod[:name], mod[:version])
        end
        message += "\n"
      end
      
      if results[:developer_version].any?
        message += "Developer Version:\n"
        results[:developer_version].each do |mod|
          message += sprintf("  %s: %s (manifest: %s)\n", mod[:name], mod[:local], mod[:online])
        end
        message += "\n"
      end
      
      if results[:not_tracked].any?
        message += "Not Tracked:\n"
        results[:not_tracked].each do |mod|
          message += sprintf("  %s (%s)\n", mod[:name], mod[:version])
        end
      end
      
      return message.empty? ? "No mods found." : message
    end
  end
  
  # ============================================================================
  # MOD UPDATER - Download and Install Mods
  # ============================================================================
  module ModUpdater
    # Get the base game directory (where Game.exe is located)
    def self.get_base_dir
      # File.dirname(__FILE__) already gives us the game root in this environment
      base = File.expand_path(File.dirname(__FILE__))
      ModSettingsMenu.debug_log("Using base directory: #{base}")
      return base
    end
    
    # Create ModsBackup directory if it doesn't exist
    # Always creates in game root directory (where Game.exe is)
    def self.ensure_backup_dir
      base = get_base_dir
      ModSettingsMenu.debug_log("Base game directory: #{base}")
      
      backup_dir = File.join(base, "ModsBackup")
      ModSettingsMenu.debug_log("ModsBackup path: #{backup_dir}")
      
      unless Dir.exist?(backup_dir)
        ModSettingsMenu.debug_log("Creating ModsBackup directory...")
        begin
          Dir.mkdir(backup_dir)
          ModSettingsMenu.debug_log("ModsBackup directory created successfully")
        rescue => e
          ModSettingsMenu.debug_log("Failed to create ModsBackup: #{e.class} - #{e.message}")
          raise
        end
      else
        ModSettingsMenu.debug_log("ModsBackup directory already exists")
      end
      
      return backup_dir
    end
    
    # Download a file from URL using HTTPLite
    # Returns file content as string, or nil on error
    # @param url [String] URL to download from
    # @param progress_callback [Proc, nil] Optional callback to report progress (receives percent 0-100)
    def self.download_file(url, progress_callback = nil)
      begin
        ModSettingsMenu.debug_log("Downloading from: #{url}")
        
        # Show initial progress
        progress_callback.call(0) if progress_callback
        
        response = HTTPLite.get(url)
        
        # Show completion progress
        progress_callback.call(100) if progress_callback
        
        if response.is_a?(Hash) && response[:status] == 200
          content = response[:body]
          ModSettingsMenu.debug_log("Download successful, size: #{content.length} bytes")
          return content
        else
          status = response.is_a?(Hash) ? response[:status] : "unknown"
          ModSettingsMenu.debug_log("Download failed, status: #{status}")
          return nil
        end
      rescue => e
        ModSettingsMenu.debug_log("Download error: #{e.class} - #{e.message}")
        return nil
      end
    end
    
    # Backup a mod file before updating
    # Returns true on success, false on failure
    def self.backup_mod(mod_path, version)
      begin
        ModSettingsMenu.debug_log("Starting backup for: #{mod_path}")
        ModSettingsMenu.debug_log("Version: #{version}")
        
        unless File.exist?(mod_path)
          ModSettingsMenu.debug_log("Error: Mod file does not exist: #{mod_path}")
          return false
        end
        
        backup_dir = ensure_backup_dir
        ModSettingsMenu.debug_log("Using backup directory: #{backup_dir}")
        
        filename = File.basename(mod_path)
        date_str = Time.now.strftime("%Y-%m-%d")
        backup_name = filename.sub(/\.rb$/, "_v#{version}_#{date_str}.rb")
        backup_path = File.join(backup_dir, backup_name)
        
        ModSettingsMenu.debug_log("Backup filename: #{backup_name}")
        ModSettingsMenu.debug_log("Full backup path: #{backup_path}")
        
        # Read original file
        content = File.read(mod_path)
        ModSettingsMenu.debug_log("Read #{content.length} bytes from original file")
        
        # Write to backup
        begin
          File.open(backup_path, 'wb') { |f| f.write(content) }
          ModSettingsMenu.debug_log("Backup file written successfully")
        rescue => write_error
          ModSettingsMenu.debug_log("Error writing backup file: #{write_error.class} - #{write_error.message}")
          return false
        end
        
        # Verify backup was created
        if File.exist?(backup_path)
          ModSettingsMenu.debug_log("Verified: Backup file exists at #{backup_path}")
          return true
        else
          ModSettingsMenu.debug_log("Error: Backup file was not created")
          return false
        end
      rescue => e
        ModSettingsMenu.debug_log("Backup error: #{e.class} - #{e.message}")
        ModSettingsMenu.debug_log("Backtrace: #{e.backtrace.first(3).join("\n")}")
        return false
      end
    end
    
    # Install/update a mod file
    # @param mod_path [String] Full path to local mod file
    # @param download_url [String] URL to download new version from
    # @param current_version [String] Current version for backup naming
    # @param progress_callback [Proc, nil] Optional callback to report download progress
    # Returns true on success, false on failure
    def self.install_mod(mod_path, download_url, current_version, progress_callback = nil)
      begin
        # Backup current version
        unless backup_mod(mod_path, current_version)
          ModSettingsMenu.debug_log("Warning: Backup failed, continuing anyway...")
        end
        
        # Download new version
        content = download_file(download_url, progress_callback)
        return false if content.nil?
        
        # Write new version to same location
        File.open(mod_path, 'wb') { |f| f.write(content) }
        
        ModSettingsMenu.debug_log("Successfully updated: #{File.basename(mod_path)}")
        return true
      rescue => e
        ModSettingsMenu.debug_log("Install error: #{e.class} - #{e.message}")
        return false
      end
    end
    
    # List all backup files in the ModsBackup directory
    # Returns array of hashes with :path, :display_name, :filename
    def self.list_backups
      begin
        base = get_base_dir
        backup_dir = File.join(base, "ModsBackup")
        
        return [] unless Dir.exist?(backup_dir)
        
        backups = []
        Dir.entries(backup_dir).each do |filename|
          next if filename == "." || filename == ".."
          next unless filename.end_with?(".rb")
          
          full_path = File.join(backup_dir, filename)
          backups << {
            path: full_path,
            filename: filename,
            display_name: filename
          }
        end
        
        # Sort by filename
        return backups.sort_by { |b| b[:filename] }
      rescue => e
        ModSettingsMenu.debug_log("Error listing backups: #{e.class} - #{e.message}")
        return []
      end
    end
    
    # List backup files for a specific mod
    # @param mod_path [String] Path to the mod file to find backups for
    # Returns array of hashes with :path, :display_name, :filename, :version, :date
    def self.list_backups_for_mod(mod_path)
      begin
        base = get_base_dir
        backup_dir = File.join(base, "ModsBackup")
        
        return [] unless Dir.exist?(backup_dir)
        
        # Get base filename without extension
        mod_filename = File.basename(mod_path, ".rb")
        ModSettingsMenu.debug_log("Looking for backups of: #{mod_filename}")
        
        backups = []
        Dir.entries(backup_dir).each do |filename|
          next if filename == "." || filename == ".."
          next unless filename.end_with?(".rb")
          
          # Match backups with pattern: ModName_vX.X.X_YYYY-MM-DD.rb
          if filename.start_with?(mod_filename + "_v")
            full_path = File.join(backup_dir, filename)
            
            # Extract version and date from filename
            # Pattern: ModName_vX.X.X_YYYY-MM-DD.rb
            if filename =~ /_v([^_]+)_([\d-]+)\.rb$/
              version = $1
              date = $2
              display = "v#{version} (#{date})"
              
              backups << {
                path: full_path,
                filename: filename,
                display_name: display,
                version: version,
                date: date
              }
              
              ModSettingsMenu.debug_log("Found backup: #{display}")
            end
          end
        end
        
        # Sort by date descending (newest first)
        return backups.sort_by { |b| b[:date] }.reverse
      rescue => e
        ModSettingsMenu.debug_log("Error listing backups for mod: #{e.class} - #{e.message}")
        return []
      end
    end
    
    # Rollback a mod to a previous backup version
    # @param mod_path [String] Path to the current mod file
    # @param backup_path [String] Path to the backup file to restore
    # Returns true on success, false on failure
    def self.rollback_mod(mod_path, backup_path)
      begin
        ModSettingsMenu.debug_log("Starting rollback...")
        ModSettingsMenu.debug_log("Mod path: #{mod_path}")
        ModSettingsMenu.debug_log("Backup path: #{backup_path}")
        
        # Verify backup exists
        unless File.exist?(backup_path)
          ModSettingsMenu.debug_log("Error: Backup file does not exist")
          return false
        end
        
        # Verify mod file exists (we'll overwrite it)
        unless File.exist?(mod_path)
          ModSettingsMenu.debug_log("Error: Mod file does not exist")
          return false
        end
        
        # Read backup content
        backup_content = File.read(backup_path)
        ModSettingsMenu.debug_log("Read #{backup_content.length} bytes from backup")
        
        # Write backup content to mod file
        File.open(mod_path, 'wb') { |f| f.write(backup_content) }
        ModSettingsMenu.debug_log("Wrote backup content to mod file")
        
        # Verify rollback
        if File.exist?(mod_path)
          new_size = File.size(mod_path)
          ModSettingsMenu.debug_log("Rollback successful, new file size: #{new_size} bytes")
          return true
        else
          ModSettingsMenu.debug_log("Error: Mod file disappeared after rollback")
          return false
        end
        
      rescue => e
        ModSettingsMenu.debug_log("Rollback error: #{e.class} - #{e.message}")
        return false
      end
    end
    
    # Delete a specific backup file
    # @param backup_path [String] Full path to backup file
    # Returns true on success, false on failure
    def self.delete_backup(backup_path)
      begin
        if File.exist?(backup_path)
          File.delete(backup_path)
          ModSettingsMenu.debug_log("Deleted backup: #{backup_path}")
          return true
        else
          ModSettingsMenu.debug_log("Backup file not found: #{backup_path}")
          return false
        end
      rescue => e
        ModSettingsMenu.debug_log("Error deleting backup: #{e.class} - #{e.message}")
        return false
      end
    end
    
    # Install graphics files for a mod
    # @param graphics_list [Array] Array of hashes with :url and :path keys
    # Returns [success_count, failure_count]
    def self.install_graphics(graphics_list)
      return [0, 0] if graphics_list.nil? || graphics_list.empty?
      
      base_dir = get_base_dir
      success = 0
      failure = 0
      
      graphics_list.each do |graphic|
        begin
          url = graphic["url"]
          rel_path = graphic["path"]
          
          # Download file
          content = download_file(url)
          if content.nil?
            failure += 1
            next
          end
          
          # Determine full path
          full_path = File.join(base_dir, rel_path)
          
          # Ensure directory exists
          dir = File.dirname(full_path)
          unless Dir.exist?(dir)
            # Create directory recursively
            parts = []
            temp = dir
            while temp != base_dir && !Dir.exist?(temp)
              parts.unshift(File.basename(temp))
              temp = File.dirname(temp)
            end
            parts.each do |part|
              temp = File.join(temp, part)
              Dir.mkdir(temp) unless Dir.exist?(temp)
            end
          end
          
          # Write file
          File.open(full_path, 'wb') { |f| f.write(content) }
          ModSettingsMenu.debug_log("Installed graphic: #{rel_path}")
          success += 1
        rescue => e
          ModSettingsMenu.debug_log("Graphics install error: #{e.class} - #{e.message}")
          failure += 1
        end
      end
      
      return [success, failure]
    end
  end
end

# ============================================================================
# AUTO-UPDATE CHECK
# ============================================================================
# Performs automatic update check when game starts
# ============================================================================
module ModSettingsMenu
  # Perform auto-update check if enabled
  # This is called from the game's version check hook
  def self.perform_auto_update_check
    begin
      debug_log("Auto-update check: Starting...")
      
      # Check if auto-update is enabled
      setting = get(:mod_auto_update)
      debug_log("Auto-update setting value: #{setting.inspect}")
      
      unless setting == 1 || setting == true
        debug_log("Auto-update check: Disabled, skipping")
        return
      end
      
      debug_log("Auto-update check: Enabled, checking for updates...")
      
      # Perform update check
      results = UpdateCheck.check_updates
      
      # Count total updates available
      if results[:error]
        debug_log("Auto-update check failed: #{results[:error]}")
        return
      end
      
      # Collect all mods with updates available
      updates_available = results[:major_updates] + results[:minor_updates] + results[:hotfixes]
      
      if updates_available.any?
        count = updates_available.length
        debug_log("Auto-update found #{count} updates available")
        
        # Filter to only mods with download URLs
        updatable = updates_available.select { |mod| mod[:download_url] && !mod[:download_url].empty? }
        
        if updatable.empty?
          debug_log("Auto-update: No mods support auto-update yet")
          pbMessage(_INTL("{1} mod update(s) available, but auto-update not supported yet.\n\nCheck 'Mod Updates' in Options menu.", count)) if defined?(pbMessage)
          return
        end
        
        # Check if confirmation is enabled
        confirm_setting = get(:mod_auto_update_confirm)
        skip_confirm = (confirm_setting == 0 || confirm_setting == false)
        
        # Show notification scene and get confirmation
        if defined?(AutoUpdateNotificationScene)
          confirmed = AutoUpdateNotificationScene.show_and_confirm(updatable, skip_confirm)
          
          if confirmed
            debug_log("Auto-update: User confirmed, updating #{updatable.length} mods")
            success_count = 0
            failure_count = 0
            
            updatable.each do |mod|
              # Update the mod
              success = ModUpdater.install_mod(
                mod[:path],
                mod[:download_url],
                mod[:local]
              )
              
              if success
                success_count += 1
                # Install graphics if present
                if mod[:graphics] && mod[:graphics].any?
                  ModUpdater.install_graphics(mod[:graphics])
                end
              else
                failure_count += 1
              end
            end
            
            # Show completion message
            if failure_count > 0
              pbMessage(sprintf("Updates complete! %d succeeded, %d failed. Please restart the game for changes to take effect.", success_count, failure_count)) if defined?(pbMessage)
              # Wait for USE button press
              loop do
                Graphics.update
                Input.update
                break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
              end
            else
              pbMessage(sprintf("All %d mod(s) updated! Please restart the game for changes to take effect.", success_count)) if defined?(pbMessage)
              # Wait for USE button press
              loop do
                Graphics.update
                Input.update
                break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
              end
            end
          else
            debug_log("Auto-update: User cancelled")
          end
        end
      else
        debug_log("Auto-update check complete: All mods up to date")
      end
    rescue => e
      debug_log("Auto-update check error: #{e.class} - #{e.message}")
      debug_log("Backtrace: #{e.backtrace.first(3).join('\n')}")
    end
  end
end

# Initialize auto-update setting with default value (off)
begin
  if defined?(ModSettingsMenu) && ModSettingsMenu.get(:mod_auto_update).nil?
    ModSettingsMenu.set(:mod_auto_update, 0)  # Default: Off
    ModSettingsMenu.debug_log("Initialized mod_auto_update setting to 0 (Off)")
  end
  if defined?(ModSettingsMenu) && ModSettingsMenu.get(:mod_auto_update_confirm).nil?
    ModSettingsMenu.set(:mod_auto_update_confirm, 1)  # Default: On (ask for confirmation)
    ModSettingsMenu.debug_log("Initialized mod_auto_update_confirm setting to 1 (On)")
  end
rescue
  # Silently fail during initialization
end

# ============================================================================
# HOOK INTO GAME VERSION CHECK
# ============================================================================
# Patch PokemonLoadScreen to trigger mod update check when game checks version
# ============================================================================
if defined?(PokemonLoadScreen)
  class PokemonLoadScreen
    # Create alias of original method if not already aliased
    unless method_defined?(:modsettings_orig_pbStartLoadScreen)
      alias modsettings_orig_pbStartLoadScreen pbStartLoadScreen
    end
    
    # Override to add mod update check after game version check
    def pbStartLoadScreen
      # Log that we're starting the load screen
      begin
        ModSettingsMenu.debug_log("=== pbStartLoadScreen called ===")
      rescue
      end
      
      # Call original method (includes game version check)
      modsettings_orig_pbStartLoadScreen
      
      # Trigger mod auto-update check if enabled
      begin
        ModSettingsMenu.debug_log("Attempting to call perform_auto_update_check")
        if defined?(ModSettingsMenu) && ModSettingsMenu.respond_to?(:perform_auto_update_check)
          ModSettingsMenu.debug_log("ModSettingsMenu.perform_auto_update_check exists, calling it...")
          ModSettingsMenu.perform_auto_update_check
        else
          ModSettingsMenu.debug_log("ERROR: ModSettingsMenu.perform_auto_update_check not found!")
        end
      rescue => e
        # Log error but don't block game startup
        begin
          ModSettingsMenu.debug_log("Error in auto-update hook: #{e.class} - #{e.message}")
        rescue
        end
      end
    end
  end
end

# ============================================================================
# PC STORAGE SCREEN INTEGRATION - MOD ACTIONS HANDLER
# ============================================================================
# Adds the pbModActions method to PokemonStorageScreen.
# Called when player selects "Mod Actions" from the PC Pokemon menu.
# Displays available mod actions and executes the selected one.
# ============================================================================
if defined?(PokemonStorageScreen)
  class PokemonStorageScreen
    # Displays and executes mod actions for the selected Pokemon
    # @param selected [Array] [box_index, position] of selected Pokemon
    # @param heldpoke [Pokemon, nil] Pokemon currently being held by cursor
    def pbModActions(selected, heldpoke)
      # Determine which Pokemon to act on (held or selected)
      pokemon = heldpoke
      if heldpoke
        pokemon = heldpoke
      elsif selected[0] == -1  # -1 indicates party
        pokemon = @storage.party[selected[1]]
      else  # Otherwise it's a box Pokemon
        pokemon = @storage.boxes[selected[0]][selected[1]]
      end
      
      return unless defined?(ModSettingsMenu::PCModActions)
      
      commands = []
      cmdCancel = -1
      mod_commands = []  # Track which command indices map to which handlers
      
      # Build list of available mod actions for this Pokemon
      ModSettingsMenu::PCModActions.handlers.each do |handler|
        begin
          # Check condition if specified (skip if condition returns false)
          next unless handler[:condition].nil? || handler[:condition].call(pokemon, selected, heldpoke)
          # Get display name (can be dynamic via Proc)
          name = handler[:name].is_a?(Proc) ? handler[:name].call(pokemon, selected, heldpoke) : handler[:name]
          next if name.nil? || name.empty?
          # Store mapping of command index to handler
          mod_commands << {index: commands.length, handler: handler}
          commands << name
        rescue => e
          # Silently skip handlers that error during condition check
        end
      end
      
      # Show message if no actions are available
      if mod_commands.empty?
        @scene.pbDisplay(_INTL("No mod actions available."))
        return
      end
      
      # Add Cancel option
      commands[cmdCancel = commands.length] = _INTL("Cancel")
      
      # Display the menu
      helptext = _INTL("{1} is selected.", pokemon.name)
      command = @scene.pbShowCommands(helptext, commands)
      
      # Execute selected action if not Cancel
      mod_cmd = mod_commands.find { |mc| mc[:index] == command }
      if mod_cmd
        begin
          # Call the handler's effect proc
          result = mod_cmd[:handler][:effect].call(pokemon, selected, heldpoke, @scene)
          # Refresh the display if the action requests it
          if result
            @scene.pbHardRefresh
          end
        rescue => e
          @scene.pbDisplay(_INTL("Error: {1}", e.message))
        end
      end
    end
  end
end

# ============================================================================
# STORAGE SCENE - SCREEN REFERENCE
# ============================================================================
# Adds storage_screen accessor to PokemonStorageScene.
# This allows the scene to access the parent PokemonStorageScreen.
# Also aliases pbStartBox to store the screen reference.
# ============================================================================
if defined?(PokemonStorageScene)
  class PokemonStorageScene
    attr_accessor :storage_screen
    
    # Create alias of original method if not already aliased
    unless method_defined?(:modsettings_orig_pbStartBox)
      alias :modsettings_orig_pbStartBox :pbStartBox
    end
    
    # Override to store screen reference before calling original
    # @param screen [PokemonStorageScreen] The parent storage screen
    # @param mode [Integer] The display mode
    def pbStartBox(screen, mode)
      @storage_screen = screen
      modsettings_orig_pbStartBox(screen, mode)
    end
  end
end

# Precise injection: capture last selection from storage scene for use by Mod Actions
if defined?(PokemonStorageScene)
  class PokemonStorageScene
    if method_defined?(:pbSelectBox) && !method_defined?(:modsettings_orig_pbSelectBox)
      alias :modsettings_orig_pbSelectBox :pbSelectBox
      def pbSelectBox(party)
        ret = modsettings_orig_pbSelectBox(party)
        begin
          if @storage_screen && @storage_screen.respond_to?(:mod_last_selected=)
            @storage_screen.mod_last_selected = ret
          end
        rescue
        end
        return ret
      end
    end
  end
end

# Screen accessor to hold last selected slot
if defined?(PokemonStorageScreen)
  class PokemonStorageScreen
    attr_accessor :mod_last_selected
  end
end

# Precise injection: add "Mod Actions" to per-Pokémon menu only when safe
if defined?(PokemonStorageScreen)
  class PokemonStorageScreen
    if method_defined?(:pbShowCommands) && !method_defined?(:modsettings_orig_pbShowCommands)
      alias :modsettings_orig_pbShowCommands :pbShowCommands
      def pbShowCommands(helptext, commands, index = 0)
        begin
          # Only inject when not in multiselect and handlers exist
          if @scene && @scene.respond_to?(:cursormode) && @scene.cursormode.to_s != "multiselect" &&
             defined?(ModSettingsMenu::PCModActions) && ModSettingsMenu::PCModActions.has_actions?
            selected = @mod_last_selected
            # Verify a valid Pokémon is selected
            valid_selection = false
            pokemon = nil
            heldpoke = nil
            begin
              heldpoke = pbHeldPokemon if respond_to?(:pbHeldPokemon)
            rescue
              heldpoke = nil
            end
            if selected.is_a?(Array)
              if selected[0] == -1
                pokemon = @storage.party[selected[1]] rescue nil
              elsif selected[0].is_a?(Integer) && selected[1].is_a?(Integer)
                pokemon = @storage[selected[0], selected[1]] rescue nil
              end
              valid_selection = (!!pokemon) || (!!heldpoke)
            end
            # Ensure this is the initial per-Pokémon action menu, not a nested submenu
            is_initial_menu = false
            begin
              expected_text = pokemon ? _INTL("{1} is selected.", pokemon.name) : (heldpoke ? _INTL("{1} is selected.", heldpoke.name) : nil)
              if helptext.is_a?(String) && expected_text && helptext == expected_text
                # Initial menu typically includes Summary and Cancel entries
                has_summary = commands.any? { |c| c.to_s == _INTL("Summary") }
                has_cancel = commands.any? { |c| c.to_s == _INTL("Cancel") }
                is_initial_menu = has_summary && has_cancel
              end
            rescue
              is_initial_menu = false
            end
            if valid_selection && is_initial_menu
              # Build augmented command list
              commands_aug = commands.dup
              # Insert above Cancel (assumed last entry)
              mod_index = [commands_aug.length - 1, 0].max
              commands_aug.insert(mod_index, _INTL("Mod Actions"))
              choice = @scene.pbShowCommands(helptext, commands_aug, index)
              if choice == mod_index
                begin
                  pbModActions(selected, heldpoke)
                  # Treat as cancel in caller to avoid double-handling
                  return commands.length - 1
                rescue
                  # Fall back to cancel
                  return commands.length - 1
                end
              else
                return choice
              end
            end
          end
        rescue
        end
        # Default behavior
        return modsettings_orig_pbShowCommands(helptext, commands, index)
      end
    end
  end
end

# ============================================================================
# STORAGE SCREEN - MAIN MENU OVERRIDE
# ============================================================================
# Completely overrides pbStartScreen to add "Mod Actions" to the PC Pokemon menu.
# This is a complex override that recreates the entire PC menu flow to inject
# the new option alongside existing ones (Move, Summary, Fuse, Release, etc.).
# Uses aliasing to preserve original behavior for non-box modes.
# ============================================================================
if defined?(PokemonStorageScreen)
  class PokemonStorageScreen
    # Create alias of original method if not already aliased
    unless method_defined?(:modsettings_orig_pbStartScreen)
      alias :modsettings_orig_pbStartScreen :pbStartScreen
    end
    
    # Override to add "Mod Actions" option to PC Pokemon menu
    # @param command [Integer] Command mode (0 = box operations, other = original behavior)
    def pbStartScreen(command)
      # Delegate entirely to original for box operations to preserve multiselect behavior
      if command == 0
        return modsettings_orig_pbStartScreen(command)
      end
      # For non-box commands, use original behavior
      modsettings_orig_pbStartScreen(command)
    end
  end
end

# ============================================================================
# COLOR THEMES
# ============================================================================

# Available color themes
COLOR_THEMES = {
  purple: {
    name: "Purple",
    base: Color.new(168, 128, 228),
    shadow: Color.new(64, 44, 84)
  },
  blue: {
    name: "Blue",
    base: Color.new(88, 176, 248),
    shadow: Color.new(32, 64, 96)
  },
  green: {
    name: "Green",
    base: Color.new(120, 200, 120),
    shadow: Color.new(44, 76, 44)
  },
  red: {
    name: "Red",
    base: Color.new(240, 120, 120),
    shadow: Color.new(92, 44, 44)
  },
  orange: {
    name: "Orange",
    base: Color.new(248, 168, 88),
    shadow: Color.new(96, 64, 32)
  },
  cyan: {
    name: "Cyan",
    base: Color.new(88, 224, 224),
    shadow: Color.new(32, 84, 84)
  },
  pink: {
    name: "Pink",
    base: Color.new(248, 136, 192),
    shadow: Color.new(96, 52, 72)
  },
  yellow: {
    name: "Yellow",
    base: Color.new(240, 224, 88),
    shadow: Color.new(92, 84, 32)
  }
}

# Custom Window for Color Scene to show colors in their respective colors
class Window_PokemonOption_Color < Window_PokemonOption
  def drawItem(index, _count, rect)
    # For the Category Theme option (index 1), draw label normally but value in its color
    if index == 1 && @options[index]
      return if dont_draw_item(index)
      rect = drawCursor(index, rect)
      
      # Draw the option name (label) in normal menu colors
      optionname = @options[index].name
      optionwidth = rect.width * 9 / 20
      pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                       @nameBaseColor, @nameShadowColor)
      
      # Get the current value and its theme
      optionvalue = self[index] || 0
      value = @options[index].values[optionvalue]
      theme_key = COLOR_THEMES.keys[optionvalue]
      theme = COLOR_THEMES[theme_key] if theme_key
      
      # Draw the value text in the color it represents
      if theme && theme[:base] && theme[:shadow]
        xpos = optionwidth + rect.x
        pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                         theme[:base], theme[:shadow])
      else
        # Fallback to normal drawing if theme not found
        xpos = optionwidth + rect.x
        pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                         @selBaseColor, @selShadowColor)
      end
    else
      # All other options use standard drawing
      super(index, _count, rect)
    end
  end
end

# Mod Settings Color Scene
class ModSettingsColorScene < PokemonOption_Scene
  def initOptionsWindow
    # Use custom window class that shows colors
    optionsWindow = Window_PokemonOption_Color.new(@PokemonOptions, 0,
                                             @sprites["title"].height, Graphics.width,
                                             Graphics.height - @sprites["title"].height - @sprites["textbox"].height)
    optionsWindow.viewport = @viewport
    optionsWindow.visible = true
    return optionsWindow
  end
  
  def pbGetOptions(inloadscreen = false)
    options = []
    
    # Create enum option for menu color theme selection
    theme_names = COLOR_THEMES.keys.map { |k| COLOR_THEMES[k][:name] }
    current_theme = ModSettingsMenu.get(:modsettings_color_theme) || 0
    
    opt = EnumOption2.new(
      _INTL("Menu Theme"),
      theme_names,
      proc { ModSettingsMenu.get(:modsettings_color_theme) || 0 },
      proc { |value| 
        ModSettingsMenu.set(:modsettings_color_theme, value)
        # Apply immediately
        if @sprites["option"]
          apply_color_theme(@sprites["option"], value)
        end
      }
    )
    options << opt
    
    # Create enum option for category color theme selection
    opt2 = EnumOption2.new(
      _INTL("Category Theme"),
      theme_names,
      proc { ModSettingsMenu.get(:modsettings_category_theme) || 3 },  # Default to red (index 3)
      proc { |value| 
        ModSettingsMenu.set(:modsettings_category_theme, value)
        # Apply immediately to category headers
        if @sprites["option"]
          @sprites["option"].refresh
        end
      }
    )
    options << opt2
    
    return options
  end
  
  def pbStartScene(inloadscreen = false)
    super
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Mod Settings Colors"), 0, 0, Graphics.width, 64, @viewport)
    
    # Apply current color theme
    theme_index = ModSettingsMenu.get(:modsettings_color_theme) || 0
    apply_color_theme(@sprites["option"], theme_index) if @sprites["option"]
    
    # Initialize values
    for i in 0...@PokemonOptions.length
      @sprites["option"][i] = (@PokemonOptions[i].get || 0)
    end
    @sprites["option"].refresh
    
    pbFadeInAndShow(@sprites) { pbUpdate }
  end
  
  def apply_color_theme(window, theme_index)
    return unless window
    theme_key = COLOR_THEMES.keys[theme_index]
    return unless theme_key
    
    theme = COLOR_THEMES[theme_key]
    if theme[:base] && theme[:shadow]
      window.nameBaseColor = theme[:base]
      window.nameShadowColor = theme[:shadow]
      window.selBaseColor = theme[:base]
      window.selShadowColor = theme[:shadow]
      window.refresh if window.respond_to?(:refresh)
    end
  end
  
  def pbEndScene
    # Apply the selected menu theme to parent Mod Settings menu when backing out
    super
    # Find and update the parent Mod Settings window if it exists
    ObjectSpace.each_object(Window_PokemonOption) do |window|
      if window.respond_to?(:apply_modsettings_theme)
        window.apply_modsettings_theme
        window.refresh if window.respond_to?(:refresh)
      end
    end
  end
end

# Mod Settings Color Option (button to open color scene)
class ModSettingsColorOption < ButtonOption
  def initialize
    super(
      _INTL("Mod Settings Colors"),
      proc {
        scene = ModSettingsColorScene.new
        screen = PokemonOptionScreen.new(scene)
        screen.pbStartScreen
      },
      _INTL("Customize the color theme for Mod Settings")
    )
  end
end

# ============================================================================
# AUTO-REGISTER OPTIONS
# ============================================================================

if defined?(ModSettingsMenu)
  # Register the View Conflicts button in Debug & Developer
  ModSettingsMenu.register_option(
    ViewConflictsOption.new,
    :view_conflicts,
    "Debug & Developer"
  )
  
  # Register the Color Settings button in Interface
  ModSettingsMenu.register_option(
    ModSettingsColorOption.new,
    :modsettings_colors,
    "Interface"
  )
  
  # Initialize the color theme storage values if they don't exist
  # (No UI registration needed - users change these via the Colors button above)
  if ModSettingsMenu.get(:modsettings_color_theme).nil?
    ModSettingsMenu.set(:modsettings_color_theme, 0)  # Default to purple
  end
  if ModSettingsMenu.get(:modsettings_category_theme).nil?
    ModSettingsMenu.set(:modsettings_category_theme, 3)  # Default to red
  end
end
