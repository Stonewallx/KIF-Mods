#========================================
# Autosort Bag
# PIF Version: 6.4.5
# KIF Version: 0.20.7
# Script Version: 2.0.1
# Author: Stonewall
#========================================

# Input buttons:
#  - Input::UP
#  - Input::DOWN
#  - Input::LEFT
#  - Input::RIGHT
#  - Input::A
#  - Input::B
#  - Input::C
#  - Input::X
#  - Input::Y
#  - Input::L
#  - Input::R
#  - Input::ACTION    (often mapped to the primary action button)
#  - Input::USE       (used for choosing/confirming)
#  - Input::BACK      (used for cancelling/back)
#  - Input::AUX1      (auxiliary button 1)
#  - Input::AUX2      (auxiliary button 2)
#  - Input::SPECIAL   (engine/game-specific additional button)

module Settings
  BAG_AUTOSORT_BUTTON = Input::SPECIAL

  BAG_AUTOSORT_LIST = {
    :items => [
      :DNASPLICERS,
      :DNAREVERSER,
      :FUSIONREPEL,
      :REPEL,
      :SUPERREPEL,
      :MAXREPEL,
      :ESCAPEROPE,
      :ABILITYCAPSULE,
      :SECRETCAPSULE,
      :HEARTSCALE,
      :DRAGONSCALE,
      :INCUBATOR,
      :INCUBATOR_NORMAL,
      :KURAYEGG_1_BADGE,
      :KURAYEGG_2_BADGES,
      :KURAYEGG_3_BADGES,
      :KURAYEGG_4_BADGES,
      :KURAYEGG_5_BADGES,
      :KURAYEGG_6_BADGES,
      :KURAYEGG_7_BADGES,
      :KURAYEGG_8_BADGES,
      :KURAYEGG_BASE,
      :KURAYEGG_BUG,
      :KURAYEGG_DARK,
      :KURAYEGG_DRAGON,
      :KURAYEGG_ELECTRIC,
      :KURAYEGG_ELITE_4,
      :KURAYEGG_FAIRY,
      :KURAYEGG_FIGHTING,
      :KURAYEGG_FIRE,
      :KURAYEGG_FLYING,
      :KURAYEGG_FUSION,
      :KURAYEGG_GHOST,
      :KURAYEGG_GRASS,
      :KURAYEGG_GROUND,
      :KURAYEGG_ICE,
      :KURAYEGG_LEGENDARY,
      :KURAYEGG_NORMAL,
      :KURAYEGG_POISON,
      :KURAYEGG_PSYCHIC,
      :KURAYEGG_RANDOM,
      :KURAYEGG_ROCK,
      :KURAYEGG_SPARKLING,
      :KURAYEGG_STARTER,
      :KURAYEGG_STEEL,
      :KURAYEGG_WATER,
      :DAWNSTONE,
      :DUSKSTONE,
      :FIRESTONE,
      :ICESTONE,
      :LEAFSTONE,
      :MAGNETSTONE,
      :MISTSTONE,
      :MOONSTONE,
      :OVALSTONE,
      :SHINYSTONE,
      :SUNSTONE,
      :THUNDERSTONE,
      :WATERSTONE,
      :TRANSGENDERSTONE,
      :DEEPSEASCALE,
      :DEEPSEATOOTH,
      :DUBIOUSDISC,
      :ELECTIRIZER,
      :MAGMARIZER,
      :PRISMSCALE,
      :PROTECTOR,
      :RAZORCLAW,
      :RAZORFANG,
      :REAPERCLOTH,
      :UPGRADE,
      :LINKINGCORD,
      :ADAMANTORB,
      :CHARCOAL,
      :DRACOPLATE,
      :DREADPLATE,
      :EARTHPLATE,
      :FISTPLATE,
      :FLAMEPLATE,
      :GRISEOUSORB,
      :ICICLEPLATE,
      :INSECTPLATE,
      :IRONPLATE,
      :LUSTROUSORB,
      :MAGNET,
      :MEADOWPLATE,
      :MINDPLATE,
      :PIXIEPLATE,
      :SHARPBEAK,
      :SILKSCARF,
      :SKYPLATE,
      :SOFTSAND,
      :SPELLTAG,
      :SPLASHPLATE,
      :SPOOKYPLATE,
      :STONEPLATE,
      :TOXICPLATE,
      :ZAPPLATE,
      :BUGGEM,
      :DARKGEM,
      :DRAGONGEM,
      :ELECTRICGEM,
      :FAIRYGEM,
      :FIGHTINGGEM,
      :FIREGEM,
      :FLYINGGEM,
      :GHOSTGEM,
      :GRASSGEM,
      :GROUNDGEM,
      :ICEGEM,
      :POISONGEM,
      :NORMALGEM,
      :PSYCHICGEM,
      :ROCKGEM,
      :STEELGEM,
      :WATERGEM,
      :ADRENALINEORB,
      :AIRBALLOON,
      :AMULETCOIN,
      :BIGROOT,
      :BLACKBELT,
      :BLACKGLASSES,
      :BLACKSLUDGE,
      :BLUESCARF,
      :BRIGHTPOWDER,
      :CHOICESCARF,
      :CHOICESPECS,
      :DAMPROCK,
      :DESTINYKNOT,
      :DRAGONFANG,
      :ELECTRICSEED,
      :EXPERTBELT,
      :EXPSHARE,
      :FLAMEORB,
      :FOCUSSASH,
      :GRASSYSEED,
      :GREENSCARF,
      :GRIPCLAW,
      :HARDSTONE,
      :HEATROCK,
      :ICYROCK,
      :KINGSROCK,
      :LAGGINGTAIL,
      :LEFTOVERS,
      :LIFEORB,
      :LIGHTCLAY,
      :LUCKYEGG,
      :LUMINOUSMOSS,
      :MENTALHERB,
      :METALCOAT,
      :METRONOME,
      :MIRACLESEED,
      :MISTYSEED,
      :MYSTICWATER,
      :NEVERMELTICE,
      :PINKSCARF,
      :POISONBARB,
      :PROTECTIVEPADS,
      :PSYCHICSEED,
      :QUICKCLAW,
      :REDSCARF,
      :SAFETYGOGGLES,
      :SHEDSHELL,
      :SILVERPOWDER,
      :SMOOTHROCK,
      :SNOWBALL,
      :SOOTHEBELL,
      :TERRAINEXTENDER,
      :TOXICORB,
      :TWISTEDSPOON,
      :WEAKNESSPOLICY,
      :WHITEHERB,
      :WISEGLASSES,
      :YELLOWSCARF,
      :ASSAULTVEST,
      :BINDINGBAND,
      :CHOICEBAND,
      :DEVOLUTIONSPRAY,
      :EVERSTONE,
      :EVIOLITE,
      :FOCUSBAND,
      :IRONBALL,
      :MACHOBRACE,
      :MUSCLEBAND,
      :POWERANKLET,
      :POWERBAND,
      :POWERBELT,
      :POWERBRACER,
      :POWERHERB,
      :POWERLENS,
      :POWERWEIGHT,
      :SCOPELENS,
      :SHELLBELL,
      :STICKYBARB,
      :SUPERSPLICERS,
      :WIDELENS,
      :ZOOMLENS,
      :ARMORFOSSIL,
      :CLAWFOSSIL,
      :COVERFOSSIL,
      :DOMEFOSSIL,
      :HELIXFOSSIL,
      :JAWFOSSIL,
      :OLDAMBER,
      :PLUMEFOSSIL,
      :ROOTFOSSIL,
      :SAILFOSSIL,
      :SKULLFOSSIL,
      :BLACKAPRICORN,
      :BLUEAPRICORN,
      :GREENAPRICORN,
      :PINKAPRICORN,
      :REDAPRICORN,
      :WHITEAPRICORN,
      :YELLOWAPRICORN,
      :BLUESHARD,
      :GREENSHARD,
      :REDSHARD,
      :YELLOWSHARD,
      :BIGMUSHROOM,
      :TINYMUSHROOM,
      :ABSORBBULB,
      :BELLSPROUTSTATUE,
      :BURNDRIVE,
      :CELLBATTERY,
      :CHILLDRIVE,
      :DOUSEDRIVE,
      :DYNAMITE,
      :EJECTBUTTON,
      :FLOATSTONE,
      :LUCKYPUNCH,
      :MANKEYPAW,
      :METALPOWDER,
      :NECROZIUM,
      :OLDBOOT,
      :OLDPENDANT,
      :QUICKPOWDER,
      :REDCARD,
      :RINGTARGET,
      :ROCKYHELMET,
      :SAFARISOUVENIR,
      :SHOCKDRIVE,
      :SOULDEW,
      :STICK,
      :THICKCLUB,
      :WHIPPEDDREAM,
      :WHITEFLAG,
      :BLACKFLUTE,
      :CLEANSETAG,
      :SMOKEBALL,
      :HONEY,
      :PUREINCENSE,
      :FULLINCENSE,
      :LAXINCENSE,
      :LUCKINCENSE,
      :ODDINCENSE,
      :ROCKINCENSE,
      :ROSEINCENSE,
      :SEAINCENSE,
      :WAVEINCENSE,
      :ANCIENTSTONE,
      :BALMMUSHROOM,
      :BIGNUGGET,
      :BIGPEARL,
      :COMETSHARD,
      :DAMPMULCH,
      :DIAMOND,
      :DIAMONDNECKLACE,
      :GOLDRING,
      :GOOEYMULCH,
      :GROWTHMULCH,
      :NUGGET,
      :ODDKEYSTONE_FULL,
      :PEARL,
      :PEARLSTRING,
      :POISONMUSHROOM,
      :RAREBONE,
      :RELICBAND,
      :RELICCOPPER,
      :RELICCROWN,
      :RELICGOLD,
      :RELICSILVER,
      :RELICSTATUE,
      :RELICVASE,
      :SEADRAFIN,
      :SHOALSALT,
      :SHOALSHELL,
      :SLOWPOKETAIL,
      :STABLEMULCH,
      :STARDUST,
      :STARPIECE,
      :PRETTYWING,
      :WHITEFLUTE
    ],
    :medicine => [
      :RARECANDY,
      :RAGECANDYBAR,
      :DEBUGCANDY,
      :POTION,
      :SUPERPOTION,
      :HYPERPOTION,
      :MAXPOTION,
      :FULLRESTORE,
      :FRESHWATER,
      :SODAPOP,
      :LEMONADE,
      :MOOMOOMILK,
      :BANANA,
      :BERRYJUICE,
      :COFFEE,
      :PIZZA,
      :GOLDENBANANA,
      :SWEETHEART,
      :FANCYMEAL,
      :ROCKETMEAL,
      :REVIVE,
      :MAXREVIVE,
      :SECRETPOTION,
      :SACREDASH,
      :ANTIDOTE,
      :AWAKENING,
      :BURNHEAL,
      :ICEHEAL,
      :PARLYZHEAL,
      :POISONHEAL,
      :FULLHEAL,
      :LAVACOOKIE,
      :OLDGATEAU,
      :CASTELIACONE,
      :ENERGYPOWDER,
      :ENERGYROOT,
      :HEALPOWDER,
      :HEALINGHERB,
      :REVIVALHERB,
      :ETHER,
      :MAXETHER,
      :ELIXIR,
      :MAXELIXIR,
      :PPUP,
      :PPMAX,
      :CALCIUM,
      :CARBOS,
      :IRON,
      :ZINC,
      :HPUP,
      :PROTEIN,
      :ACCURACYUP,
      :DAMAGEUP,
      :GENIUSWING,
      :HEALTHWING,
      :MUSCLEWING,
      :RESISTWING,
      :CLEVERWING,
      :SWIFTWING
    ],
    :pok_balls => [
      :POKEBALL,
      :GREATBALL,
      :ULTRABALL,
      :MASTERBALL,
      :FUSIONBALL,
      :SAFARIBALL,
      :NETBALL,
      :DIVEBALL,
      :NESTBALL,
      :REPEATBALL,
      :QUICKBALL,
      :TIMERBALL,
      :LUXURYBALL,
      :PREMIERBALL,
      :DUSKBALL,
      :HEAVYBALL,
      :FASTBALL,
      :LEVELBALL,
      :LUREBALL,
      :MOONBALL,
      :FRIENDBALL,
      :LOVEBALL,
      :HEALBALL,
      :SPORTBALL,
      :ABILITYBALL,
      :CANDYBALL,
      :DREAMBALL,
      :FIRECRACKER,
      :FROSTBALL,
      :GENDERBALL,
      :INVISIBALL,
      :PERFECTBALL,
      :PUREBALL,
      :ROCKETBALL,
      :SCORCHBALL,
      :SHINYBALL,
      :SPARKBALL,
      :LIGHTBALL,
      :STATUSBALL,
      :TOXICBALL,
      :TRADEBALL,
      :VIRUSBALL,
      :CHERISHBALL
    ],
    :tms_hms => [
      :HM01,
      :HM02,
      :HM03,
      :HM04,
      :HM05,
      :HM06,
      :HM07,
      :HM08,
      :HM09,
      :HM10,
      :TM00,
      :TM01,
      :TM02,
      :TM03,
      :TM04,
      :TM05,
      :TM06,
      :TM07,
      :TM08,
      :TM09,
      :TM10,
      :TM11,
      :TM12,
      :TM13,
      :TM14,
      :TM15,
      :TM16,
      :TM17,
      :TM18,
      :TM19,
      :TM20,
      :TM21,
      :TM22,
      :TM23,
      :TM24,
      :TM25,
      :TM26,
      :TM27,
      :TM28,
      :TM29,
      :TM30,
      :TM31,
      :TM32,
      :TM33,
      :TM34,
      :TM35,
      :TM36,
      :TM37,
      :TM38,
      :TM39,
      :TM40,
      :TM41,
      :TM42,
      :TM43,
      :TM44,
      :TM45,
      :TM46,
      :TM47,
      :TM48,
      :TM49,
      :TM50,
      :TM51,
      :TM52,
      :TM53,
      :TM54,
      :TM55,
      :TM56,
      :TM57,
      :TM58,
      :TM59,
      :TM60,
      :TM61,
      :TM62,
      :TM63,
      :TM64,
      :TM65,
      :TM66,
      :TM67,
      :TM68,
      :TM69,
      :TM70,
      :TM71,
      :TM72,
      :TM73,
      :TM74,
      :TM75,
      :TM76,
      :TM77,
      :TM78,
      :TM79,
      :TM80,
      :TM81,
      :TM82,
      :TM83,
      :TM84,
      :TM85,
      :TM86,
      :TM87,
      :TM88,
      :TM89,
      :TM90,
      :TM91,
      :TM92,
      :TM93,
      :TM94,
      :TM95,
      :TM96,
      :TM97,
      :TM98,
      :TM99,
      :TM100,
      :TM101,
      :TM102,
      :TM103,
      :TM104,
      :TM105,
      :TM106,
      :TM107,
      :TM108,
      :TM109,
      :TM110,
      :TM111,
      :TM112,
      :TM113,
      :TM114,
      :TM115,
      :TM116,
      :TM117,
      :TM118,
      :TM119,
      :TM120,
      :TM121
    ],
    :berries => [
      :ORANBERRY,
      :SITRUSBERRY,
      :AGUAVBERRY,
      :FIGYBERRY,
      :IAPAPABERRY,
      :MAGOBERRY,
      :WIKIBERRY,
      :CHERIBERRY,
      :CHESTOBERRY,
      :LUMBERRY,
      :PECHABERRY,
      :PERSIMBERRY,
      :RAWSTBERRY,
      :BABIRIBERRY,
      :CHARTIBERRY,
      :CHOPLEBERRY,
      :COBABERRY,
      :COLBURBERRY,
      :HABANBERRY,
      :KASIBBERRY,
      :KEBIABERRY,
      :OCCABERRY,
      :PASSHOBERRY,
      :PAYAPABERRY,
      :RINDOBERRY,
      :SHUCABERRY,
      :TANGABERRY,
      :WACANBERRY,
      :YACHEBERRY,
      :GREPABERRY,
      :HONDEWBERRY,
      :KELPSYBERRY,
      :POMEGBERRY,
      :QUALOTBERRY,
      :TAMATOBERRY,
      :BELUEBERRY,
      :BLUKBERRY,
      :CORNNBERRY,
      :DURINBERRY,
      :MAGOSTBERRY,
      :NANABBERRY,
      :NOMELBERRY,
      :PAMTREBERRY,
      :PINAPBERRY,
      :RABUTABERRY,
      :RAZZBERRY,
      :SPELONBERRY,
      :WATMELBERRY,
      :WEPEARBERRY,
      :STARFBERRY,
      :APICOTBERRY,
      :ASPEARBERRY,
      :CHILANBERRY,
      :CUSTAPBERRY,
      :ENIGMABERRY,
      :GANLONBERRY,
      :JABOCABERRY,
      :LANSATBERRY,
      :LEPPABERRY,
      :LIECHIBERRY,
      :MICLEBERRY,
      :PETAYABERRY,
      :PINKANBERRY,
      :ROWAPBERRY,
      :SALACBERRY
    ],
    :mail => [
      :AIRMAIL,
      :BLOOMMAIL,
      :BRICKMAIL,
      :BUBBLEMAIL,
      :FLAMEMAIL,
      :GRASSMAIL,
      :HEARTMAIL,
      :MOSAICMAIL,
      :SNOWMAIL,
      :SPACEMAIL,
      :STEELMAIL,
      :TUNNELMAIL
    ],
    :battle_items => [
      :POKEDOLL,
      :POKETOY,
      :BLUEFLUTE,
      :REDFLUTE,
      :YELLOWFLUTE,
      :DIREHIT,
      :DIREHIT2,
      :DIREHIT3,
      :GUARDSPEC,
      :XACCURACY,
      :XACCURACY2,
      :XACCURACY3,
      :XACCURACY6,
      :XATTACK,
      :XATTACK2,
      :XATTACK3,
      :XATTACK6,
      :XDEFENSE,
      :XDEFENSE2,
      :XDEFENSE3,
      :XDEFENSE6,
      :XSPATK,
      :XSPATK2,
      :XSPATK3,
      :XSPATK6,
      :XSPDEF,
      :XSPDEF2,
      :XSPDEF3,
      :XSPDEF6,
      :XSPEED,
      :XSPEED2,
      :XSPEED3,
      :XSPEED6,
      :ABILITYURGE,
      :BEER,
      :FLUFFYTAIL,
      :ITEMDROP,
      :ITEMURGE,
      :RESETURGE,
      :SHOOTER,
      :SKINNYLATTE
    ],
    :key_items => [
      :MAGICBOOTS,
      :DEBUGGER,
      :INFINITEREVERSERS,
      :INFINITESPLICERS,
      :INFINITESPLICERS2,
      :TOWNMAP,
      :POKEDEX,
      :POKERADAR,
      :DOWSINGMACHINE,
      :ITEMFINDER,
      :EXPALL,
      :EXPALLOFF,
      :OLDROD,
      :GOODROD,
      :SUPERROD,
      :BICYCLE,
      :RACEBIKE,
      :PICKAXE,
      :LANTERN,
      :MACHETE,
      :TELEPORTER,
      :SURFBOARD,
      :SCUBAGEAR,
      :LEVER,
      :CLIMBINGGEAR,
      :JETPACK,
      :ICEPICK,
      :SLEEPINGBAG,
      :AZUREFLUTE,
      :POKEFLUTE,
      :SHINYCHARM,
      :OVALCHARM,
      :SQUIRTBOTTLE,
      :WAILMERPAIL,
      :EMERALD,
      :RUBY,
      :SAPPHIRE,
      :BANDLOGO,
      :BEDROOMKEY,
      :BERSERKGENE,
      :BOXLINK,
      :BRICKS,
      :CAPTAINSKEY,
      :CARDKEY,
      :COINCASE,
      :CORRUPTEDFEATHER,
      :DARKSTONE,
      :DEMHARDMODE,
      :DEVONSCOPE,
      :DREAMMIRROR,
      :EMERGENCYWHISTLE,
      :GASMASK,
      :GOLDEMBLEM,
      :GRACIDEA,
      :GSBALL,
      :KRABBYLEGS,
      :LIFTKEY,
      :LIGHTSTONE,
      :LUNARFEATHER,
      :MANSIONKEY,
      :MASTERBALLPROTO,
      :NETWORKCHIP,
      :ODDKEYSTONE,
      :OLDSEAMAP,
      :POWERPLANTKEY,
      :REGITABLET,
      :REVEALGLASS,
      :ROCKETID,
      :ROCKETUNIFORM,
      :SILPHSCOPE,
      :SILVEREMBLEM,
      :SOOTSACK,
      :SPRAYDUCK,
      :STRANGEPLANT,
      :STRANGEPRISM,
      :WOODENPLANKS,
      :AURORATICKET,
      :MAGNETPASS,
      :SSTICKET,
      :LOVELETTER,
      :OAKSPARCEL
    ],
    :hold_items => []
  }
  
  # Store a deep copy of the original defaults for restoration
  BAG_AUTOSORT_LIST_DEFAULTS = BAG_AUTOSORT_LIST.dup.each_with_object({}) do |(k, v), h|
    h[k] = v.is_a?(Array) ? v.dup : v
  end


  def self.bag_pocket_key(pocket_index)
    return nil if pocket_index.nil?
    name = bag_pocket_names[pocket_index] rescue nil
    return nil if name.nil?
    name.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym
  end
end

SEPARATOR_SENTINEL = :__SEPARATOR__

begin
  if defined?(Game)
    begin
      class << Game
        unless method_defined?(:autosort_orig_load)
          alias_method :autosort_orig_load, :load
          define_method(:load) do |save_data|
            autosort_orig_load(save_data)
            begin
              apply_saved_autosort_to_bag($PokemonBag) rescue nil
              apply_saved_autosort_to_bag($bag) rescue nil
            rescue
            end
          end
        end
        unless method_defined?(:autosort_orig_start_new)
          alias_method :autosort_orig_start_new, :start_new
          define_method(:start_new) do |*args|
            autosort_orig_start_new(*args)
            begin
              apply_saved_autosort_to_bag($PokemonBag) rescue nil
              apply_saved_autosort_to_bag($bag) rescue nil
            rescue
            end
          end
        end
      end
    rescue
    end
  end
rescue
end
 

def bag_autosort_kro_path
  dir = nil
  begin
    dir = File.expand_path(File.dirname(__FILE__))
  rescue
  end
  dir = (File.dirname(__FILE__) rescue '.') if !dir || dir.empty?
  File.join(dir, 'AutosortBag_list.kro')
end

def bag_favorites_kro_path
  dir = nil
  begin
    dir = File.expand_path(File.dirname(__FILE__))
  rescue
  end
  dir = (File.dirname(__FILE__) rescue '.') if !dir || dir.empty?
  File.join(dir, 'AutosortBag_favorites.kro')
end
def bag_autosort_txt_path
  dir = nil
  begin
    dir = File.expand_path(File.dirname(__FILE__))
  rescue
  end
  dir = (File.dirname(__FILE__) rescue '.') if !dir || dir.empty?
  File.join(dir, 'AutosortBag_lists.txt')
end

def load_bag_autosort_list_from_kro
  path = bag_autosort_kro_path
  return false if !File.exist?(path)
  begin
    data = File.binread(path)
    obj = Marshal.load(data) rescue nil
    return false unless obj.is_a?(Hash)
    newh = {}
    obj.each do |k, v|
      key = (k.is_a?(String) && k =~ /^\d+$/) ? k.to_i : (k.is_a?(String) ? k.to_sym : k)
      newh[key] = v
    end
    if defined?(Settings) && Settings.const_defined?(:BAG_AUTOSORT_LIST)
      Settings.send(:remove_const, :BAG_AUTOSORT_LIST) rescue nil
    end
    Settings.const_set(:BAG_AUTOSORT_LIST, newh)
    return true
  rescue
    return false
  end
end

def load_bag_favorites_from_kro
  path = bag_favorites_kro_path
  return false if !File.exist?(path)
  begin
    data = File.binread(path)
    obj = Marshal.load(data) rescue nil
    return false unless obj.is_a?(Hash)
    # Normalize to { pocket_key(Integer or Symbol) => Array of Symbols }
    newh = {}
    obj.each do |k, v|
      key = (k.is_a?(String) && k =~ /^\d+$/) ? k.to_i : (k.is_a?(String) ? k.to_sym : k)
      if v.is_a?(Array)
        newh[key] = v.map { |it| it.to_s.gsub(/^:/, '').upcase.to_sym }
      end
    end
    if defined?(Settings)
      if Settings.const_defined?(:BAG_FAVORITES)
        Settings.send(:remove_const, :BAG_FAVORITES) rescue nil
      end
      Settings.const_set(:BAG_FAVORITES, newh)
    end
    return true
  rescue
    return false
  end
end
def save_bag_autosort_list_to_kro(list_hash = nil)
  list_hash ||= (Settings::BAG_AUTOSORT_LIST rescue nil)
  return false if !list_hash
  begin
    data = Marshal.dump(list_hash)
    File.binwrite(bag_autosort_kro_path, data)
    return true
  rescue
    return false
  end
end

def save_bag_favorites_to_kro(fav_hash = nil)
  fav_hash ||= (Settings::BAG_FAVORITES rescue nil)
  return false if !fav_hash
  begin
    data = Marshal.dump(fav_hash)
    File.binwrite(bag_favorites_kro_path, data)
    return true
  rescue
    return false
  end
end
def export_bag_autosort_lists_to_txt
  begin
    begin
      load_bag_autosort_list_from_kro if File.exist?(bag_autosort_kro_path)
    rescue
    end
    lists = (Settings::BAG_AUTOSORT_LIST rescue nil)
    lists = {} unless lists.is_a?(Hash)

    out_lines = []
    out_lines << "# AutosortBag export format"
    out_lines << "# - Edit with any text editor (Notepad, etc.)."
    out_lines << "# - Sections are in [brackets] (one per bag pocket)."
    out_lines << "# - List items either one per line OR comma/semicolon separated."
    out_lines << "# - Lines starting with # are comments and are ignored."
    out_lines << "# - Bullets (-, *, •) or numbers (1., 1) before items are ignored."
    out_lines << "# - Inline comments after # or // are ignored."
    out_lines << "# - Save as UTF-8 or ANSI; UTF-16 (Unicode) is also supported."
    out_lines << "# - Use -- SEPARATOR -- or -- NAME -- for a separator."
    out_lines << "#"

    normalize = proc { |s| s.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym }

    for i in 1...Settings.bag_pocket_names.length
      pname = Settings.bag_pocket_names[i] rescue nil
      next if !pname
      pkey = normalize.call(pname)
      list = lists[i] || lists[pkey] || []
      list = [] unless list.is_a?(Array)

      out_lines << "" if out_lines.length > 0
      out_lines << "# #{pname.upcase}"
      out_lines << "[#{pkey}]"
      list.each do |it|
        if it == SEPARATOR_SENTINEL || (it.is_a?(Array) && it[0] == SEPARATOR_SENTINEL)
          name = nil
          name = it[1] if it.is_a?(Array)
          name = name.to_s.strip.upcase
          name = 'SEPARATOR' if name.nil? || name.empty?
          out_lines << "-- #{name} --"
          next
        end
        begin
          sym = (it.is_a?(Symbol) || it.is_a?(String)) ? it.to_s.gsub(/^:/, '') : (GameData::Item.get(it).id.to_s rescue it.to_s)
        rescue
          sym = it.to_s
        end
        out_lines << sym.upcase
      end
    end

    File.write(bag_autosort_txt_path, out_lines.join("\r\n"))
    return true
  rescue
    return false
  end
end

def import_bag_autosort_lists_from_txt
  path = bag_autosort_txt_path
  return [false, "No file"] unless File.exist?(path)
  
  raw = File.binread(path) rescue nil
  content = raw ? raw.dup : ""
  byte_at = proc do |str, i|
    begin
      if str && str.respond_to?(:getbyte)
        next str.getbyte(i)
      else
        ch = str[i] rescue nil
        next ch.ord if ch && ch.respond_to?(:ord)
        next ch if ch.is_a?(Integer)
      end
    rescue
    end
    next nil
  end
  b0 = byte_at.call(content, 0)
  b1 = byte_at.call(content, 1)
  b2 = byte_at.call(content, 2)
  if content && content.length >= 2 && b0 == 0xFF && b1 == 0xFE
    begin
      content = content.force_encoding('UTF-16LE').encode('UTF-8')
    rescue
    end
  elsif content && content.length >= 2 && b0 == 0xFE && b1 == 0xFF
    begin
      content = content.force_encoding('UTF-16BE').encode('UTF-8')
    rescue
    end
  else
    if b0 == 0xEF && b1 == 0xBB && b2 == 0xBF
      begin
        content = content.byteslice(3, content.length - 3)
      rescue
        content = content[3..-1] rescue content
      end
    end
    begin
      if content.encoding != Encoding::UTF_8
        tmp = content.dup
        tmp.force_encoding(Encoding::UTF_8)
        if tmp.valid_encoding?
          content = tmp
        else
          content.force_encoding(Encoding::Windows_1252)
          content = content.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
        end
      else
        unless content.valid_encoding?
          content = content.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
        end
      end
    rescue
      begin
        content = content.to_s.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '')
      rescue
      end
    end
  end
  lines = content.to_s.gsub("\r\n", "\n").gsub("\r", "\n").split("\n")

  key_map = {}
  begin
    for i in 1...Settings.bag_pocket_names.length
      name = Settings.bag_pocket_names[i] rescue nil
      next unless name
      key = name.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym
      key_map[key] = i
    end
  rescue
  end
  
  result = {}
  current_key = nil
  current_list = []
  stats = { total_items: 0, duplicates_removed: 0, pockets: {}, duplicate_list: [] }
  
  lines.each do |line|
    line = line.to_s.strip
    next if line.empty?
    if line.start_with?('#')
      next
    end
    if line =~ /^\s*\[\s*([^\]]+?)\s*\]\s*$/
      if current_key && current_list.length > 0
        # Remove duplicates and normalize
        original_count = current_list.length
        seen = {}
        cleaned_list = []
        current_list.each do |item|
          if item == SEPARATOR_SENTINEL || (item.is_a?(Array) && item[0] == SEPARATOR_SENTINEL)
            # Always keep separators (they can repeat)
            cleaned_list << item
          else
            # Normalize item (ensure uppercase symbol)
            normalized = item.is_a?(Symbol) ? item.to_s.upcase.to_sym : item.to_s.upcase.to_sym
            unless seen[normalized]
              seen[normalized] = true
              cleaned_list << normalized
            else
              stats[:duplicates_removed] += 1
              stats[:duplicate_list] << normalized.to_s
            end
          end
        end
        
        result[current_key] = cleaned_list
        idx = key_map[current_key] rescue nil
        result[idx] = cleaned_list if idx
        
        stats[:pockets][current_key] = {
          items: cleaned_list.length,
          removed: original_count - cleaned_list.length
        }
      end
      raw_key = $1
      norm_key = raw_key.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym
      current_key = norm_key
      current_list = []
      next
    end

    next unless current_key
    items = line.split(/[;,]/)
    items = [line] if items.length <= 1
    items.each do |tok|
      raw_tok = tok.to_s
      tok = raw_tok
      tok = tok.sub(/\s*(?:#|\/\/).*$/, '')
      tok = tok.gsub(/^\s*(?:[-–—•*]|\d+[\.:\)])\s*/, '')
      clean = tok.strip
      if clean =~ /^[-–—]+\s*([A-Za-z0-9 _]+?)\s*[-–—]+$/
        sepname = $1.to_s.strip.upcase
        sepname = 'SEPARATOR' if sepname.empty?
        current_list << [SEPARATOR_SENTINEL, sepname]
        stats[:total_items] += 1
        next
      end
      tok = clean.upcase
      next if tok.empty?
      tok = tok.gsub(/[^0-9A-Z]+/, '_')
      tok = tok.gsub(/^_+|_+$/, '')
      next if tok.empty?
      if tok == 'SEPARATOR'
        current_list << SEPARATOR_SENTINEL
        stats[:total_items] += 1
        next
      end
      current_list << tok.to_sym
      stats[:total_items] += 1
    end
  end
  
  if current_key && current_list.length > 0
    # Remove duplicates and normalize
    original_count = current_list.length
    seen = {}
    cleaned_list = []
    current_list.each do |item|
      if item == SEPARATOR_SENTINEL || (item.is_a?(Array) && item[0] == SEPARATOR_SENTINEL)
        # Always keep separators (they can repeat)
        cleaned_list << item
      else
        # Normalize item (ensure uppercase symbol)
        normalized = item.is_a?(Symbol) ? item.to_s.upcase.to_sym : item.to_s.upcase.to_sym
        unless seen[normalized]
          seen[normalized] = true
          cleaned_list << normalized
        else
          stats[:duplicates_removed] += 1
          stats[:duplicate_list] << normalized.to_s
        end
      end
    end
    
    result[current_key] = cleaned_list
    idx = key_map[current_key] rescue nil
    result[idx] = cleaned_list if idx
    
    stats[:pockets][current_key] = {
      items: cleaned_list.length,
      removed: original_count - cleaned_list.length
    }
  end
  
  if Settings.const_defined?(:BAG_AUTOSORT_LIST)
    Settings.send(:remove_const, :BAG_AUTOSORT_LIST)
  end
  Settings.const_set(:BAG_AUTOSORT_LIST, result)
  
  save_bag_autosort_list_to_kro(result)
  
  # Build summary message
  final_count = stats[:pockets].values.sum { |p| p[:items] }
  msg = "Import complete!\n"
  msg += "Total items processed: #{stats[:total_items]}\n"
  msg += "Final items: #{final_count}\n"
  if stats[:duplicates_removed] > 0
    msg += "Duplicates removed: #{stats[:duplicates_removed]}\n"
    # List unique duplicates (limit to first 20 to avoid overwhelming display)
    unique_dupes = stats[:duplicate_list].uniq.sort
    if unique_dupes.length > 0
      msg += "\nDuplicate items:\n"
      display_dupes = unique_dupes.take(20)
      display_dupes.each { |d| msg += "- #{d}\n" }
      if unique_dupes.length > 20
        msg += "... and #{unique_dupes.length - 20} more"
      end
    end
  end
  msg += "\nPockets imported: #{stats[:pockets].length}"
  
  return [true, msg]
rescue => e
  begin
    return [false, "Error: #{e.class}: #{e.message}"]
  rescue
    return [false, "Error"]
  end
end

begin
  if File.exist?(bag_autosort_kro_path)
    load_bag_autosort_list_from_kro
  end
  if File.exist?(bag_favorites_kro_path)
    load_bag_favorites_from_kro
  end
rescue
end

def load_bag_autosort_list_from_script
  # First, try to get the defaults from the backup constant
  if defined?(Settings::BAG_AUTOSORT_LIST_DEFAULTS) && Settings::BAG_AUTOSORT_LIST_DEFAULTS.is_a?(Hash)
    # Return a deep copy to prevent modifications
    result = {}
    Settings::BAG_AUTOSORT_LIST_DEFAULTS.each do |k, v|
      result[k] = v.is_a?(Array) ? v.dup : v
    end
    return result
  end
  
  # Fallback: try to parse from the script file
  path = File.expand_path(__FILE__) rescue nil
  return nil if !path || !File.exist?(path)
  content = File.read(path) rescue nil
  return nil if !content
  
  # Look for the BAG_AUTOSORT_LIST definition
  idx = content.index('BAG_AUTOSORT_LIST')
  return nil unless idx
  
  # Find the opening brace
  brace_idx = content.index('{', idx)
  return nil unless brace_idx
  
  # Find the matching closing brace
  i = brace_idx
  depth = 0
  while i < content.length
    ch = content[i]
    depth += 1 if ch == '{'
    depth -= 1 if ch == '}'
    i += 1
    break if depth == 0
  end
  end_idx = i
  literal = content[brace_idx...end_idx]
  
  begin
    # Create a safe eval context
    parsed = eval(literal) rescue nil
    return parsed if parsed.is_a?(Hash)
  rescue => e
    # If eval fails, return nil so we can try other methods
  end
  
  return nil
end

def choose_item_from_debug_list
  used_debug_picker = false
  begin
    if defined?(pbListScreenBlock) && defined?(ItemLister)
      used_debug_picker = true
      chosen = nil
      pbListScreenBlock(_INTL("ADD ITEM"), ItemLister.new) do |button, item|
        if button == Input::USE && item
          chosen = item
          next true
        end
        next false
      end
      return chosen if chosen
    end
  rescue
    used_debug_picker = used_debug_picker || false
  end
  return nil if used_debug_picker
  begin
    return pbChooseItem if defined?(pbChooseItem)
  rescue
  end
  return nil
end

def prompt_separator_name(default_name = 'SEPARATOR')
  name = nil
  begin
    if defined?(pbMessageFreeText)
      name = pbMessageFreeText(_INTL('Separator name (ALL CAPS):'), default_name, false, 24)
    elsif defined?(pbEnterText)
      name = pbEnterText(_INTL('Separator name (ALL CAPS):'), 24) rescue default_name
    end
  rescue
    name = nil
  end
  name = default_name if !name || name.to_s.strip.empty?
  return name.to_s.upcase
end

def item_belongs_in_pocket?(item_id, pocket_index)
  begin
    itm = GameData::Item.get(item_id) rescue nil
    return false if !itm
    pk = itm.pocket rescue nil
    return false if !pk
    return pk == pocket_index
  rescue
    return false
  end
end

begin
  if defined?(ModSettingsMenu)
    ModSettingsMenu.set(:autosort_enabled, 1) if ModSettingsMenu.get(:autosort_enabled).nil?
    ModSettingsMenu.set(:autosort_button_enabled, 1) if ModSettingsMenu.get(:autosort_button_enabled).nil?
    for i in 1...Settings.bag_pocket_names.length
      key = Settings.bag_pocket_key(i) rescue nil
      next unless key
      per = ("autosort_#{key}").to_sym
      ModSettingsMenu.set(per, 4) if ModSettingsMenu.get(per).nil?
    end
  else
    $MOD_SETTINGS_PENDING_REGISTRATIONS ||= []
    $MOD_SETTINGS_PENDING_REGISTRATIONS << proc {
      begin
        ModSettingsMenu.set(:autosort_enabled, 1) if ModSettingsMenu.get(:autosort_enabled).nil?
        ModSettingsMenu.set(:autosort_button_enabled, 1) if ModSettingsMenu.get(:autosort_button_enabled).nil?
        for i in 1...Settings.bag_pocket_names.length
          key = Settings.bag_pocket_key(i) rescue nil
          next unless key
          per = ("autosort_#{key}").to_sym
          ModSettingsMenu.set(per, 4) if ModSettingsMenu.get(per).nil?
        end
      rescue
      end
    }
  end
rescue
end

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

class AutosortBagScene < PokemonOption_Scene
  include ModSettingsSpacing  # Enable automatic spacing
  
  # Menu Transition Fix: Skip fade-in to avoid double-fade (outer pbFadeOutIn handles transition)
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
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
      EnumOption.new(_INTL('Autosort'), [_INTL('Off'), _INTL('On')], 
        proc { ModSettingsMenu.get(:autosort_enabled) || 1 },
        proc { |value| ModSettingsMenu.set(:autosort_enabled, value) },
        _INTL('Automatically sort new items when added to bag')),
      EnumOption.new(_INTL('Autosort Button'), [_INTL('Off'), _INTL('On')], 
        proc { ModSettingsMenu.get(:autosort_button_enabled) || 1 },
        proc { |value| ModSettingsMenu.set(:autosort_button_enabled, value) },
        _INTL('Enable hotkey button to manually sort current bag pocket')),
      ButtonOption.new(_INTL('Per-Pocket Sorting'), proc { 
        pbFadeOutIn {
          scene = AutosortPerPocketScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      }, _INTL('Configure sorting behavior for individual bag pockets')),
      ButtonOption.new(_INTL('Sorting Lists'), proc { 
        pbFadeOutIn {
          run_original_sorting_lists_menu()
        }
      }, _INTL('Edit custom item sorting lists for each pocket')),
      ButtonOption.new(_INTL('Export Lists to Text'), proc { 
        ok = export_bag_autosort_lists_to_txt
        if ok
          pbPlayDecisionSE
          pbMessage(_INTL('Exported to: {1}', bag_autosort_txt_path)) rescue nil
        else
          pbPlayCancelSE
          pbMessage(_INTL('Export failed.')) rescue nil
        end 
      }, _INTL('Export your sorting lists to a text file')),
      ButtonOption.new(_INTL('Import Lists from Text'), proc { 
        begin
          res, msg = import_bag_autosort_lists_from_txt
          if res
            pbPlayDecisionSE
          else
            pbPlayCancelSE
          end
          pbMessage(msg) if msg
        rescue => e
          pbPlayCancelSE
        end 
      }, _INTL('Import sorting lists from a text file'))
    ]
    
    return auto_insert_spacers(options)
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Per-Pocket Sorting"), 0, 0, Graphics.width, 64, @viewport)
    
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

class AutosortPerPocketScene < PokemonOption_Scene
  include ModSettingsSpacing  # Enable automatic spacing
  
  # Menu Transition Fix: Skip fade-in to avoid double-fade (outer pbFadeOutIn handles transition)
  def pbFadeInAndShow(sprites, visiblesprites = nil)
    if visiblesprites
      visiblesprites.each { |s| sprites[s].visible = true }
    else
      sprites.each { |key, sprite| sprite.visible = true if sprite }
    end
  end
  
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
    options = []
    
    # Build options for each pocket using individual method calls to avoid closure issues
    (1...Settings.bag_pocket_names.length).each do |i|
      key = Settings.bag_pocket_key(i) rescue nil
      if key
        per_key = ("autosort_#{key}").to_sym
        pocket_name = Settings.bag_pocket_names[i]
        
        options << create_pocket_option(pocket_name, per_key)
      end
    end
    
    return auto_insert_spacers(options)
  end
  
  private
  
  def create_pocket_option(pocket_name, setting_key)
    EnumOption.new(pocket_name, [_INTL('Off'), _INTL('List'), _INTL('Alphabetical'), _INTL('Top'), _INTL('Bottom')],
      proc { ModSettingsMenu.get(setting_key) || 1 },
      proc { |value| ModSettingsMenu.set(setting_key, value) },
      _INTL('Choose sorting behavior for this pocket'))
  end
  
  def pbStartScene(inloadscreen = false)
    super(inloadscreen)
    
    # Set custom title
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("Per-Pocket Sorting"), 0, 0, Graphics.width, 64, @viewport)
    
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

def run_original_sorting_lists_menu()
  list_choices = []
  for i in 1...Settings.bag_pocket_names.length
    list_choices << Settings.bag_pocket_names[i]
  end
  list_choices << _INTL('Back')
  lists_window = Window_CommandPokemonEx.new(list_choices)
  lists_window.z = 99999; lists_window.visible = true
  lists_window.resizeToFit(lists_window.commands)
  pbPositionNearMsgWindow(lists_window, nil, :right)
  begin
    loop do
      Graphics.update; Input.update
      oldli = lists_window.index; lists_window.update
      pbPlayCursorSE if oldli != lists_window.index
      if Input.trigger?(Input::BACK)
        pbPlayCancelSE; break
      end
      if Input.trigger?(Input::USE)
        if lists_window.index >= 0 && lists_window.index < (Settings.bag_pocket_names.length - 1)
          pocket_idx = lists_window.index + 1
          key = Settings.bag_pocket_key(pocket_idx) rescue nil
          storage_key = key || pocket_idx
          orig_list = []
          if defined?(Settings::BAG_AUTOSORT_LIST) && Settings::BAG_AUTOSORT_LIST.is_a?(Hash)
            orig_list = Settings::BAG_AUTOSORT_LIST[pocket_idx] || Settings::BAG_AUTOSORT_LIST[storage_key] || []
          end
          orig_list = [] unless orig_list.is_a?(Array)
          list = orig_list.clone
          undo_snapshot = nil
          script_defaults = load_bag_autosort_list_from_script || {}
          default_for_pocket = script_defaults[storage_key] || script_defaults[pocket_idx] || []

          build_label = proc do |it|
            begin
              if it == SEPARATOR_SENTINEL || (it.is_a?(Array) && it[0] == SEPARATOR_SENTINEL)
                nm = (it.is_a?(Array) ? it[1] : nil)
                nm = nm.to_s.strip.upcase
                nm = 'SEPARATOR' if nm.nil? || nm.empty?
                "-- #{nm} --"
              elsif it.is_a?(Symbol) || it.is_a?(String)
                it.to_s
              else
                GameData::Item.get(it).name rescue it.to_s
              end
            rescue
              it.to_s
            end
          end

          editor = nil
          begin
            editor = Window_CommandPokemonEx.new([])
            editor.z = 99999; editor.visible = true
            picked = nil
            selected_indices = []
            favorites_hash = (Settings::BAG_FAVORITES rescue {})
            favorites_hash = {} unless favorites_hash.is_a?(Hash)
            get_favs = proc do
              favs = favorites_hash[storage_key]
              favs = favorites_hash[pocket_idx] if !favs
              favs = [] unless favs.is_a?(Array)
              favs
            end
            favs = get_favs.call

            rebuild = proc do
              editor.commands.clear
              list.each_with_index do |it, i|
                name = build_label.call(it)
                begin
                  sym = (it.is_a?(Symbol) || it.is_a?(String)) ? it.to_s.gsub(/^:/, '').upcase.to_sym : (GameData::Item.get(it).id.to_s.upcase.to_sym rescue it)
                  if it.is_a?(Array) && it[0] == SEPARATOR_SENTINEL
                  elsif favs.include?(sym)
                    name = _INTL('{1} {2}', name, _INTL('(Fav)'))
                  end
                rescue
                end
                if picked == i
                  editor.commands << _INTL('{1} {2}', name, _INTL('(Picked)'))
                elsif selected_indices.include?(i)
                  editor.commands << _INTL('{1} {2}', name, _INTL('(Selected)'))
                else
                  editor.commands << name
                end
              end
              suffix = []
              suffix << _INTL('Add Item')
              suffix << _INTL('Add Separator')
              suffix << _INTL('Undo Last Change') if undo_snapshot
              suffix << _INTL('Restore Default')
              suffix << _INTL('Clear Favorites') if favs && favs.length > 0
              suffix << _INTL('Back')
              suffix.each { |s| editor.commands << s }
              editor.resizeToFit(editor.commands)
            end

            rebuild.call
            pbPositionNearMsgWindow(editor, nil, :right)

            loop do
              Graphics.update; Input.update
              oldei = editor.index; editor.update
              pbPlayCursorSE if oldei != editor.index
              if Input.trigger?(Input::ACTION)
                ai = editor.index
                if ai < list.length
                  if Input.respond_to?(:press?) && Input.press?(Input::R)
                    if selected_indices.include?(ai)
                      selected_indices.delete(ai)
                    else
                      selected_indices << ai
                      selected_indices.uniq!
                    end
                    picked = nil
                    rebuild.call; editor.refresh; pbPlayDecisionSE
                  elsif selected_indices && selected_indices.length > 0
                    undo_snapshot = list.clone
                    sel_sorted = selected_indices.sort
                    block_items = sel_sorted.map { |i| list[i] }
                    dest = ai
                    removed_before = sel_sorted.count { |ri| ri < dest }
                    dest_selected = sel_sorted.include?(dest)
                    sel_sorted.reverse.each { |ri| list.delete_at(ri) }
                    insertion_index = dest - removed_before
                    insertion_index += 1 unless dest_selected
                    insertion_index = 0 if insertion_index < 0
                    insertion_index = list.length if insertion_index > list.length
                    block_items.each_with_index { |itx, k| list.insert(insertion_index + k, itx) }
                    selected_indices = (0...block_items.length).map { |k| insertion_index + k }
                    picked = nil
                    rebuild.call; editor.index = insertion_index; editor.refresh; pbPlayDecisionSE
                  else
                    if !picked
                      picked = ai
                      rebuild.call; editor.refresh; pbPlayDecisionSE
                    elsif picked == ai
                      picked = nil
                      rebuild.call; pbPlayCancelSE
                    else
                      undo_snapshot = list.clone
                      itm = list.delete_at(picked)
                      pos = ai
                      pos -= 1 if picked < ai
                      list.insert(pos, itm)
                      picked = nil
                      rebuild.call; pbPlayDecisionSE
                    end
                  end
                end
              elsif picked && Input.repeat?(Input::UP) && picked > 0
                undo_snapshot = list.clone
                list[picked], list[picked-1] = list[picked-1], list[picked]
                picked -= 1
                rebuild.call
                editor.index = picked; editor.refresh; pbPlayCursorSE; next
              elsif picked && Input.repeat?(Input::DOWN) && picked < list.length - 1
                undo_snapshot = list.clone
                list[picked], list[picked+1] = list[picked+1], list[picked]
                picked += 1
                rebuild.call
                editor.index = picked; editor.refresh; pbPlayCursorSE; next
              elsif picked && Input.repeat?(Input::LEFT) && picked > 0
                undo_snapshot = list.clone
                len_before = list.length
                target = picked - 10
                target = 0 if target < 0
                itm = list.delete_at(picked)
                list.insert(target, itm)
                picked = target
                rebuild.call
                editor.index = picked; editor.refresh; pbPlayCursorSE; next
              elsif picked && Input.repeat?(Input::RIGHT) && picked < list.length - 1
                undo_snapshot = list.clone
                len_before = list.length
                target = picked + 10
                max_index = len_before - 1
                target = max_index if target > max_index
                itm = list.delete_at(picked)
                target -= 1 if picked < target
                list.insert(target, itm)
                picked = target
                rebuild.call
                editor.index = picked; editor.refresh; pbPlayCursorSE; next
              elsif !picked && (Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT))
                step = Input.repeat?(Input::LEFT) ? -10 : 10
                new_index = editor.index + step
                min_index = 0
                max_index = editor.commands.length - 1
                new_index = min_index if new_index < min_index
                new_index = max_index if new_index > max_index
                if new_index != editor.index
                  editor.index = new_index
                  pbPlayCursorSE
                end
                next
              end
              if Input.trigger?(Input::BACK)
                if picked
                  picked = nil
                  rebuild.call; pbPlayCancelSE; next
                elsif selected_indices && selected_indices.length > 0
                  selected_indices = []
                  rebuild.call; pbPlayCancelSE; next
                end
                pbPlayCancelSE; break
              end
              if Input.trigger?(Input::USE)
                idx = editor.index
                base = list.length
                add_item_idx = base
                add_sep_idx  = base + 1
                offset = 2
                undo_idx = base + offset if undo_snapshot
                offset += 1 if undo_snapshot
                restore_idx = base + offset
                offset += 1
                clear_fav_idx = base + offset if favs && favs.length > 0
                offset += 1 if favs && favs.length > 0
                back_idx = base + offset
                if idx < list.length
                  is_sep = (list[idx] == SEPARATOR_SENTINEL) || (list[idx].is_a?(Array) && list[idx][0] == SEPARATOR_SENTINEL)
                  item_cmds = [_INTL('Insert Below'), _INTL('Insert Separator Below')]
                  item_cmds << _INTL('Toggle Favorite') unless is_sep
                  item_cmds << _INTL('Rename Separator') if is_sep
                  item_cmds << _INTL('Remove')
                  item_cmds << _INTL('Cancel')
                  item_win = Window_CommandPokemonEx.new(item_cmds)
                  item_win.z = 99999; item_win.visible = true
                  item_win.resizeToFit(item_win.commands)
                  pbPositionNearMsgWindow(item_win, nil, :right)
                  begin
                    sel = -1
                    loop do
                      Graphics.update; Input.update; item_win.update
                      if Input.trigger?(Input::BACK)
                        sel = -1; break
                      elsif Input.trigger?(Input::USE)
                        sel = item_win.index; break
                      end
                    end
                    case sel
                    when 0 
                      newitem = choose_item_from_debug_list
                      if newitem
                        if list.include?(newitem)
                          pbPlayCancelSE
                          pbMessage(_INTL('That item is already in this list.')) rescue nil
                        elsif item_belongs_in_pocket?(newitem, pocket_idx)
                          undo_snapshot = list.clone
                          list.insert(idx+1, newitem)
                          selected_indices = []
                          rebuild.call; editor.refresh; pbPlayDecisionSE
                        else
                          pbPlayCancelSE
                          pbMessage(_INTL('That item does not belong in this pocket.')) rescue nil
                        end
                      else
                        pbPlayCancelSE
                      end
                    when 1 
                      undo_snapshot = list.clone
                      sep_name = prompt_separator_name('SEPARATOR')
                      list.insert(idx+1, [SEPARATOR_SENTINEL, sep_name])
                      selected_indices = []
                      rebuild.call; editor.refresh; pbPlayDecisionSE
                    when 2 
                      if !is_sep
                        # Toggle Favorite
                        begin
                          target = list[idx]
                          sym = (target.is_a?(Symbol) || target.is_a?(String)) ? target.to_s.gsub(/^:/, '').upcase.to_sym : (GameData::Item.get(target).id.to_s.upcase.to_sym rescue nil)
                          if sym
                            favs = get_favs.call
                            if favs.include?(sym)
                              favs.delete(sym)
                            else
                              favs << sym
                            end
                            favorites_hash[storage_key] = favs
                            begin
                              if defined?(Settings)
                                if Settings.const_defined?(:BAG_FAVORITES)
                                  Settings.send(:remove_const, :BAG_FAVORITES) rescue nil
                                end
                                Settings.const_set(:BAG_FAVORITES, favorites_hash)
                              end
                            rescue
                            end
                            save_bag_favorites_to_kro(favorites_hash) rescue nil
                            rebuild.call; editor.refresh; pbPlayDecisionSE
                          else
                            pbPlayCancelSE
                          end
                        rescue
                          pbPlayCancelSE
                        end
                      elsif is_sep
                        # Rename Separator
                        undo_snapshot = list.clone
                        cur = list[idx]
                        old_name = (cur.is_a?(Array) ? cur[1] : 'SEPARATOR')
                        new_name = prompt_separator_name(old_name)
                        list[idx] = [SEPARATOR_SENTINEL, new_name]
                        rebuild.call; editor.refresh; pbPlayDecisionSE
                      end
                    when 3
                      # Remove - works for both separators and items
                      if list.length > 0
                        undo_snapshot = list.clone
                        list.delete_at(idx)
                        picked = nil if picked && picked >= list.length
                        if selected_indices && selected_indices.length > 0
                          selected_indices = selected_indices.map { |si| si > idx ? si - 1 : (si == idx ? nil : si) }.compact
                        end
                        rebuild.call; editor.refresh; pbPlayDecisionSE
                      else
                        pbPlayCancelSE
                      end
                    else
                      
                    end
                  ensure
                    item_win.dispose if item_win
                    Input.update
                  end
                elsif idx == add_item_idx  
                  newitem = choose_item_from_debug_list
                  if newitem
                    if list.include?(newitem)
                      pbPlayCancelSE
                      pbMessage(_INTL('That item is already in this list.')) rescue nil
                    elsif item_belongs_in_pocket?(newitem, pocket_idx)
                      undo_snapshot = list.clone
                      list << newitem
                      selected_indices = []
                      rebuild.call; editor.refresh; pbPlayDecisionSE
                    else
                      pbPlayCancelSE
                      pbMessage(_INTL('That item does not belong in this pocket.')) rescue nil
                    end
                  else
                    pbPlayCancelSE
                  end
                elsif idx == add_sep_idx
                  undo_snapshot = list.clone
                  sep_name = prompt_separator_name('SEPARATOR')
                  list << [SEPARATOR_SENTINEL, sep_name]
                  selected_indices = []
                  rebuild.call; editor.refresh; pbPlayDecisionSE
                elsif undo_snapshot && idx == undo_idx
                  list = undo_snapshot.clone
                  undo_snapshot = nil
                  selected_indices = []
                  rebuild.call; editor.refresh; pbPlayDecisionSE
                elsif idx == restore_idx
                  confirm_idx = nil
                  confirm_cmds = [_INTL('Yes'), _INTL('No')]
                  confirm_win = Window_CommandPokemonEx.new(confirm_cmds)
                  confirm_win.z = 99999; confirm_win.visible = true
                  confirm_win.resizeToFit(confirm_win.commands)
                  pbPositionNearMsgWindow(confirm_win, nil, :right)
                  begin
                    loop do
                      Graphics.update; Input.update; confirm_win.update
                      if Input.trigger?(Input::USE)
                        confirm_idx = confirm_win.index; break
                      elsif Input.trigger?(Input::BACK)
                        confirm_idx = 1; break
                      end
                    end
                  ensure
                    confirm_win.dispose if confirm_win
                  end
                  if confirm_idx == 0
                    undo_snapshot = list.clone
                    list = (default_for_pocket.clone rescue [])
                    picked = nil
                    selected_indices = []
                    rebuild.call; editor.refresh; pbPlayDecisionSE
                  else
                    pbPlayCancelSE
                  end
                elsif clear_fav_idx && idx == clear_fav_idx
                  favorites_hash[storage_key] = []
                  begin
                    if defined?(Settings)
                      if Settings.const_defined?(:BAG_FAVORITES)
                        Settings.send(:remove_const, :BAG_FAVORITES) rescue nil
                      end
                      Settings.const_set(:BAG_FAVORITES, favorites_hash)
                    end
                  rescue
                  end
                  save_bag_favorites_to_kro(favorites_hash) rescue nil
                  favs = []
                  rebuild.call; editor.refresh; pbPlayDecisionSE
                elsif idx == back_idx
                  pbPlayDecisionSE; break
                else
                  pbPlayDecisionSE; break
                end
              end
            end
          ensure
            begin
              if defined?(Settings::BAG_AUTOSORT_LIST) && Settings::BAG_AUTOSORT_LIST.is_a?(Hash)
                Settings::BAG_AUTOSORT_LIST[storage_key] = list
                Settings::BAG_AUTOSORT_LIST[pocket_idx] = list
                save_bag_autosort_list_to_kro(Settings::BAG_AUTOSORT_LIST) rescue nil
              end
            rescue
            end
            editor.dispose if editor
          end
        else
          pbPlayDecisionSE; break
        end
      end
    end
  ensure
    lists_window.dispose if lists_window
  end
end

if defined?(ModSettingsMenu)
  reg_proc = proc {
    ModSettingsMenu.register(:autosort_bag, {
      name: "Autosort Bag",
      type: :button,
      description: "Configure autosort behavior for new items and pockets",
      on_press: proc {
        pbFadeOutIn {
          scene = AutosortBagScene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen
        }
      },
      category: "Quality of Life",
      searchable: [
        "autosort", "bag", "sorting", "items", "pocket", "list", "organize",
        "favorites", "import", "export", "alphabetical"
      ]
    })
  }
  
  reg_proc.call
end


class PokemonBag
  if instance_methods.include?(:pbStoreItem) && !instance_methods.include?(:autosort_orig_pbStoreItem)
    alias_method :autosort_orig_pbStoreItem, :pbStoreItem
  end

  def pbStoreItem(item, qty = 1)
    # Debug logging for reset investigation
    if defined?(ModSettingsMenu) && !@autosort_store_logged
      ModSettingsMenu.debug_log("AutosortBag: pbStoreItem() called for #{item} x#{qty} - Call stack depth: #{caller.length}")
      ModSettingsMenu.debug_log("AutosortBag: Top 5 callers: #{caller.first(5).join(' -> ')}")
      @autosort_store_logged = true
    end
    
    ret = false
    begin
      itm = GameData::Item.get(item) rescue nil
      return false if !itm
      pocket = itm.pocket
      return false if !pocket
      maxsize = maxPocketSize(pocket)
      maxsize = @pockets[pocket].length + 1 if maxsize < 0
      ret = ItemStorageHelper.pbStoreItem(@pockets[pocket], maxsize, Settings::BAG_MAX_PER_SLOT, itm.id, qty, false) rescue false
    rescue
      ret = false
    end
    begin
      autosort_enabled = 1
      if defined?(ModSettingsMenu)
        autosort_enabled = ModSettingsMenu.get(:autosort_enabled) rescue autosort_enabled
      else
        begin
          st = ModSettingsMenu.storage rescue nil
          autosort_enabled = st && st.key?(:autosort_enabled) ? st[:autosort_enabled] : autosort_enabled
        rescue
        end
      end
      return ret if !ret || autosort_enabled.to_i == 0

      pocket_key = Settings.bag_pocket_key(pocket) rescue nil
      per_mode = 1
      if defined?(ModSettingsMenu) && pocket_key
        per_key = ("autosort_#{pocket_key}").to_sym
        per_mode = ModSettingsMenu.get(per_key) rescue per_mode
      else
        begin
          st = ModSettingsMenu.storage rescue nil
          if st && pocket_key
            per_key = ("autosort_#{pocket_key}").to_sym
            per_mode = st.key?(per_key) ? st[per_key] : per_mode
          end
        rescue
        end
      end
      return ret if per_mode.to_i == 0

      case per_mode.to_i
      when 1
        sortlist = nil
        if defined?(Settings::BAG_AUTOSORT_LIST) && Settings::BAG_AUTOSORT_LIST.is_a?(Hash)
          sortlist = Settings::BAG_AUTOSORT_LIST[pocket]
          if !sortlist && pocket_key
            sortlist = Settings::BAG_AUTOSORT_LIST[pocket_key]
          end
        end
        if sortlist && sortlist.length > 0
          autosort_pocket_by_list(pocket, sortlist)
        else
          sort_pocket_alphabetically()
        end
      when 2
        arr = @pockets[pocket]
        arr.sort! do |a, b|
          GameData::Item.get(a[0]).name <=> GameData::Item.get(b[0]).name
        end
      when 3
        arr = @pockets[pocket]
        idx = nil
        for i in 0...arr.length
          slot = arr[i]
          next if !slot || slot[0] != itm.id
          idx = i
          break
        end
        if idx
          arr.insert(0, arr.delete_at(idx))
        end
      when 4
        arr = @pockets[pocket]
        idx = nil
        for i in 0...arr.length
          slot = arr[i]
          next if !slot || slot[0] != itm.id
          idx = i
          break
        end
        if idx
          arr.push(arr.delete_at(idx))
        end
      end
      begin
        favs_hash = (Settings::BAG_FAVORITES rescue nil)
        if favs_hash && favs_hash.is_a?(Hash)
          favs = favs_hash[pocket]
          if !favs
            pkey = pocket_key
            favs = favs_hash[pkey] if pkey
          end
          promote_favorites_in_pocket(pocket, favs) if favs && favs.is_a?(Array)
        end
      rescue
      end
    rescue
    end
    return ret
  end

  def autosort_pocket_by_list(pocket, order_list)
    return if pocket <= 0 || pocket > PokemonBag.numPockets
    order_list = [] if !order_list
    arr = @pockets[pocket]
    priority = {}
    order_list.each_with_index { |item, i| priority[item] = i }
    arr.sort! do |a, b|
      a_sym = GameData::Item.get(a[0]).id rescue a[0]
      b_sym = GameData::Item.get(b[0]).id rescue b[0]
      a_in = priority.has_key?(a_sym)
      b_in = priority.has_key?(b_sym)
      if a_in && b_in
        comp = priority[a_sym] <=> priority[b_sym]
        next comp if comp != 0
        GameData::Item.get(a[0]).name <=> GameData::Item.get(b[0]).name
      elsif a_in
        -1
      elsif b_in
        1
      else
        GameData::Item.get(a[0]).name <=> GameData::Item.get(b[0]).name
      end
    end
  end

  def promote_favorites_in_pocket(pocket, favorites)
    return if !favorites || favorites.empty?
    arr = @pockets[pocket]
    return if !arr || arr.length == 0
    favset = {}
    favorites.each { |f| favset[f] = true }
    fav_items = []
    other_items = []
    arr.each do |slot|
      next if !slot
      sym = (GameData::Item.get(slot[0]).id rescue slot[0])
      if favset[sym]
        fav_items << slot
      else
        other_items << slot
      end
    end
    @pockets[pocket] = fav_items + other_items
  rescue
  end

  def promote_favorites_by_hash(fav_hash)
    return if !fav_hash || !fav_hash.is_a?(Hash)
    fav_hash.each do |k, favs|
      pk = nil
      if k.is_a?(Integer)
        pk = k
      else
        key_sym = k.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym
        for i in 1...Settings.bag_pocket_names.length
          nm = Settings.bag_pocket_names[i]
          next if !nm
          nm_sym = nm.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym
          if nm_sym == key_sym
            pk = i
            break
          end
        end
      end
      next unless pk && pk.is_a?(Integer)
      promote_favorites_in_pocket(pk, favs)
    end
  rescue
  end


  def autosort_by_list_hash(list_hash)
    return if !list_hash
    list_hash.each do |k, lst|
      pk = nil
      if k.is_a?(Integer)
        pk = k
      else
        key_sym = k.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym
        for i in 1...Settings.bag_pocket_names.length
          nm = Settings.bag_pocket_names[i]
          next if !nm
          nm_sym = nm.to_s.gsub(/[^0-9A-Za-z]/, ' ').strip.downcase.gsub(/\s+/, '_').to_sym
          if nm_sym == key_sym
            pk = i
            break
          end
        end
      end
      if pk && pk.is_a?(Integer) && pk > 0 && pk <= PokemonBag.numPockets
        autosort_pocket_by_list(pk, lst)
      end
    end
  end
end

def apply_saved_autosort_to_bag(bag)
  begin
    # Enhanced safety checks
    if !bag
      return
    end
    
    if bag.frozen?
      return
    end
    
    if !bag.respond_to?(:autosort_by_list_hash)
      return
    end
    
    # Guard against recursive initialization
    if bag.instance_variable_get(:@_autosort_initializing)
      return
    end
    
    begin
      # Set initialization flag with enhanced safety
      if bag && !bag.frozen? && bag.respond_to?(:instance_variable_set)
        bag.instance_variable_set(:@_autosort_initializing, true)
      else
        return
      end
      
      begin
        load_bag_autosort_list_from_kro if File.exist?(bag_autosort_kro_path)
      rescue => e
      end
      
      if defined?(Settings::BAG_AUTOSORT_LIST) && Settings::BAG_AUTOSORT_LIST.is_a?(Hash)
        # Guard against recursive calls during initialization - use class variable for safety
        if @@_autosort_in_progress ||= false
        else
          begin
            @@_autosort_in_progress = true
            bag.autosort_by_list_hash(Settings::BAG_AUTOSORT_LIST)
          ensure
            @@_autosort_in_progress = false
          end
        end
      end
      
      begin
        load_bag_favorites_from_kro if File.exist?(bag_favorites_kro_path)
      rescue => e
        if defined?(ModSettingsMenu)
          ModSettingsMenu.debug_log("AutosortBag: Error loading favorites: #{e.class} - #{e.message}")
        end
      end
      
      begin
        if defined?(Settings::BAG_FAVORITES) && Settings::BAG_FAVORITES.is_a?(Hash)
          bag.promote_favorites_by_hash(Settings::BAG_FAVORITES) if bag.respond_to?(:promote_favorites_by_hash)
        end
      rescue => e
        if defined?(ModSettingsMenu)
          ModSettingsMenu.debug_log("AutosortBag: Error promoting favorites: #{e.class} - #{e.message}")
        end
      end
    ensure
      # Safely clear the initialization flag - check if bag is still valid
      if bag && !bag.frozen? && bag.respond_to?(:instance_variable_set)
        begin
          bag.instance_variable_set(:@_autosort_initializing, false)
        rescue => e
        end
      end
    end
  rescue => e
  end
end

begin
  begin
    apply_saved_autosort_to_bag($PokemonBag) if defined?($PokemonBag) && $PokemonBag
  rescue
  end
  begin
    apply_saved_autosort_to_bag($bag) if defined?($bag) && $bag
  rescue
  end
rescue
end

begin
  if defined?(PokemonBag) && !PokemonBag.ancestors.any? { |a| a.to_s == 'AutosortBagInitHook' }
    module AutosortBagInitHook
      def initialize(*args, &block)
        super(*args, &block)
        begin
          apply_saved_autosort_to_bag(self)
        rescue => e
        end
      end
    end
    PokemonBag.prepend(AutosortBagInitHook)
  end
rescue
end

class Window_PokemonBag
  if instance_methods.include?(:update) && !instance_methods.include?(:autosort_original_update)
    alias_method :autosort_original_update, :update
  end

  def update
    # Debug logging for reset investigation
    if defined?(ModSettingsMenu) && !@autosort_update_logged
      ModSettingsMenu.debug_log("AutosortBag: update() called - Call stack depth: #{caller.length}")
      @autosort_update_logged = true
    end
    
    autosort_original_update if respond_to?(:autosort_original_update)
    return if disposed?
      if Input.trigger?(Settings::BAG_AUTOSORT_BUTTON)
        enabled = 1
        if defined?(ModSettingsMenu)
          enabled = ModSettingsMenu.get(:autosort_button_enabled) rescue enabled
        else
          begin
            st = ModSettingsMenu.storage rescue nil
            enabled = st && st.key?(:autosort_button_enabled) ? st[:autosort_button_enabled] : enabled
          rescue
          end
        end
        return if enabled.to_i == 0
        perform_autosort_and_clear_confirm
        return
      end
  end

  def perform_autosort_and_clear_confirm
    pocket_key = Settings.bag_pocket_key(@pocket) rescue nil
    per_mode = 1
    if defined?(ModSettingsMenu) && pocket_key
      per_key = ("autosort_#{pocket_key}").to_sym
      per_mode = ModSettingsMenu.get(per_key) rescue per_mode
    else
      begin
        st = ModSettingsMenu.storage rescue nil
        if st && pocket_key
          per_key = ("autosort_#{pocket_key}").to_sym
          per_mode = st.key?(per_key) ? st[per_key] : per_mode
        end
      rescue
      end
    end
    if per_mode.to_i == 0
      pbPlayCancelSE
      return
    end

    case per_mode.to_i
    when 1
      sortlist = nil
      if defined?(Settings::BAG_AUTOSORT_LIST) && Settings::BAG_AUTOSORT_LIST.is_a?(Hash)
        sortlist = Settings::BAG_AUTOSORT_LIST[@pocket]
        if !sortlist && Settings.respond_to?(:bag_pocket_key)
          key = Settings.bag_pocket_key(@pocket)
          sortlist = Settings::BAG_AUTOSORT_LIST[key] if key
        end
      end
      if sortlist && sortlist.length > 0
        @bag.autosort_pocket_by_list(@pocket, sortlist)
      else
        @bag.sort_pocket_alphabetically()
      end
    when 2
      arr = @bag.pockets[@pocket]
      arr.sort! { |a, b| GameData::Item.get(a[0]).name <=> GameData::Item.get(b[0]).name }
    when 3
      arr = @bag.pockets[@pocket]
      idx = nil
      for i in 0...arr.length
        slot = arr[i]
        next if !slot
        idx = i if slot[0] == arr[i][0]
      end
      if idx
        arr.insert(0, arr.delete_at(idx))
      end
    when 4
      arr = @bag.pockets[@pocket]
      idx = nil
      for i in 0...arr.length
        slot = arr[i]
        next if !slot
        idx = i if slot[0] == arr[i][0]
      end
      if idx
        arr.push(arr.delete_at(idx))
      end
    end
    begin
      favs_hash = (Settings::BAG_FAVORITES rescue nil)
      if favs_hash && favs_hash.is_a?(Hash)
        favs = favs_hash[@pocket]
        if !favs && Settings.respond_to?(:bag_pocket_key)
          key = Settings.bag_pocket_key(@pocket)
          favs = favs_hash[key] if key
        end
        @bag.promote_favorites_in_pocket(@pocket, favs) if favs && favs.is_a?(Array)
      end
    rescue
    end
    @autosort_confirming = false
    pbPlayDecisionSE
    self.refresh
  end
end

# ============================================================================
# AUTO-UPDATE SELF-REGISTRATION
# ============================================================================
# Register this mod for auto-updates
# ============================================================================
if defined?(ModSettingsMenu::ModRegistry)
  ModSettingsMenu::ModRegistry.register(
    name: "Autosort Bag",
    file: "06_AutosortBag.rb",
    version: "2.0.1",
    download_url: "https://raw.githubusercontent.com/Stonewallx/KIF-Mods/refs/heads/main/Mods/06_AutosortBag.rb",
    changelog_url: "https://github.com/Stonewallx/KIF-Mods/raw/refs/heads/main/Changelogs/Autosort%20Bag.md",
    graphics: [],
    dependencies: [
      {name: "01_Mod_Settings", version: "3.1.4"}
    ]
  )
  
  # Log initialization with version from registration
  begin
    version = ModSettingsMenu::ModRegistry.all["06_AutosortBag.rb"][:version] rescue nil
    version_str = version ? "v#{version}" : "(version unknown)"
    ModSettingsMenu.debug_log("AutosortBag: Autosort Bag #{version_str} loaded successfully")
  rescue
    # Silently fail if we can't log
  end
end
