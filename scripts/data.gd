extends Node

const to_load: Array[String] = [
    "attributes", "connectors", "resources", "symbols",
    "currencies", "files", "windows", "upgrades", "storage", "guides", "research",
    "milestones", "perks", "boosts", "services", "stats", "achievements", "requests",
    "themes"
]

var attributes: Dictionary
var connectors: Dictionary
var resources: Dictionary
var symbols: Dictionary
var currencies: Dictionary
var files: Dictionary
var windows: Dictionary
var upgrades: Dictionary
var storage: Dictionary
var research: Dictionary
var milestones: Dictionary
var perks: Dictionary
var boosts: Dictionary
var services: Dictionary
var guides: Dictionary
var stats: Dictionary
var achievements: Dictionary
var requests: Dictionary
var themes: Dictionary
var schematics: Dictionary

var fps_limit: int
var colorblind: bool
var scientific: bool
var mute_sfx: bool
var volume_sfx: float = 1.0
var mute_windows: bool
var volume_windows: float = 0.4
var mute_bgm: bool
var volume_bgm: float = 0.8
var show_completed: bool
var scale: float
var language: String
var glow: bool
var cur_theme: String = "default"

var loading: Dictionary
var wiping: bool
var settings_set: bool


func _init() -> void:
    for i: String in to_load:
        load_data(i)

    if OS.get_name() in ["Windows", "Linux", "macOS"]:
        scale = 0.7
    elif OS.get_name() == "Android":
        scale = snappedf(0.6 * DisplayServer.screen_get_scale(), 0.1)
        glow = false
    elif OS.get_name() == "iOS":
        scale = snappedf(0.6 * DisplayServer.screen_get_scale(), 0.1)

    if TranslationServer.get_loaded_locales().has(OS.get_locale_language()):
        language = OS.get_locale()


func _ready() -> void:
    loading = get_data_from_config(load_save_file("user://savegame.dat"))
    if loading.is_empty():
        loading = get_data_from_config(load_save_file("user://savegame_backup.dat"))
    load_config()

    var config_timer: Timer = Timer.new()
    config_timer.name = "ConfigTimer"
    config_timer.one_shot = true
    add_child(config_timer)
    config_timer.timeout.connect(save_config)

    for i: String in save().keys():
        update_setting(i)

    load_schematics()


func set_setting(setting: String, value) -> void:
    if value != get(setting):
        set(setting, value)
        update_setting(setting)

        $ConfigTimer.start(2)
    Signals.setting_set.emit(setting)


func update_setting(setting: String) -> void:
    if setting == "fps_limit":
        Engine.max_fps = fps_limit
    elif setting == "mute_sfx":
        AudioServer.set_bus_mute(1, mute_sfx)
    elif setting == "volume_sfx":
        AudioServer.set_bus_volume_db(1, linear_to_db(volume_sfx))
    elif setting == "mute_windows":
        AudioServer.set_bus_mute(2, mute_windows)
    elif setting == "volume_windows":
        AudioServer.set_bus_volume_db(2, linear_to_db(volume_windows))
    elif setting == "mute_bgm":
        AudioServer.set_bus_mute(3, mute_bgm)
    elif setting == "volume_bgm":
        AudioServer.set_bus_volume_db(3, linear_to_db(volume_bgm))
    elif setting == "language":
        TranslationServer.set_locale(language)


func load_data(property: String) -> void:
    var file: FileAccess = FileAccess.open("res://data/" + property + ".json", FileAccess.READ)
    var json: Variant = JSON.parse_string(file.get_as_text())
    set(property, json)


func save_data_file(path: String) -> ConfigFile:
    var file: ConfigFile = get_save_as_file()
    file.save_encrypted_pass(path, "wb4Y2glKOoikSazubWWf")

    return file


func load_save_file(path: String) -> ConfigFile:
    var file: ConfigFile = ConfigFile.new()
    if file.load_encrypted_pass(path, "wb4Y2glKOoikSazubWWf") != OK:
        if file.load(path) != OK:
            return null

    return file


func load_save_string(string: String) -> ConfigFile:
    var file: ConfigFile = ConfigFile.new()
    if file.parse(string) != OK:
        return null

    return file


func get_save_as_file() -> ConfigFile:
    var file: ConfigFile = ConfigFile.new()

    var save: Dictionary = {"desktop_data": {}, "connector_data": {}, "globals": {}}
    for node: Node in get_tree().get_nodes_in_group("window"):
        save["desktop_data"][str(node.name)] = node.save()
    for connection: Node in get_tree().get_nodes_in_group("connector"):
        save["connector_data"][connection.input_id] = connection.save()
    save["globals"] = Globals.save()

    file.set_value("save", "windows", save["desktop_data"])
    file.set_value("save", "connectors", save["connector_data"])
    file.set_value("save", "globals", save["globals"])

    return file


func get_data_from_config(file: ConfigFile) -> Dictionary:
    if file:
        var data: Dictionary = {"windows": {}, "connectors": {}, "globals": {}}
        data["windows"] = file.get_value("save", "windows")
        data["connectors"] = file.get_value("save", "connectors", {})
        data["globals"] = file.get_value("save", "globals")

        if !data.globals.has("save_ver"):
            data.globals.storage_size = 0
            data.globals.storage.clear()
        return data
    else:
        return {}


func save_config() -> void:
    var file: ConfigFile = ConfigFile.new()
    var save: Dictionary = save()
    for i: String in save:
        file.set_value("config", i, save[i])

    file.save("user://config.dat")


func load_config() -> bool:
    var file: ConfigFile = ConfigFile.new()
    if file.load("user://config.dat") != OK:
        return false

    for i: String in file.get_section_keys("config"):
        set(i, file.get_value("config", i))

    return true


func save_schematic(name: String, data: Dictionary) -> void:
    var file: ConfigFile = ConfigFile.new()

    var dir_access: DirAccess = DirAccess.open("user://")
    if !dir_access.dir_exists("schematics"):
        dir_access.make_dir("schematics")

    var base_name: String = name
    var dir: String = "user://schematics"
    var id: int = 0
    var path: String

    while true:
        var suffix = "" if id == 0 else str(id)
        path = dir.path_join(base_name + suffix + ".dat")
        if not dir_access.file_exists(path):
            break

        id += 1

    file.set_value("schematic", "windows", data["windows"])
    file.set_value("schematic", "connectors", data["connectors"])
    file.set_value("schematic", "rect", data.rect)
    file.set_value("schematic", "icon", data.icon)
    var error: int = file.save(path)
    if error == OK:
        Signals.notify.emit("blueprint", "schematic_saved")
        add_schematic(path.get_file().get_basename(), data)


func add_schematic(schematic: String, data: Dictionary) -> void:
    schematics[schematic] = data
    Signals.new_schematic.emit(schematic)


func delete_schematic(schematic: String) -> void:
    schematics.erase(schematic)
    var dir_access: DirAccess = DirAccess.open("user://")
    dir_access.remove("schematics".path_join(schematic + ".dat"))
    Signals.deleted_schematic.emit(schematic)


func load_schematic(path: String) -> Dictionary:
    var file: ConfigFile = ConfigFile.new()
    if file.load(path) != OK:
        return {}

    if !file.has_section("schematic"):
        return {}

    if !file.has_section_key("schematic", "windows"):
        return {}

    if !file.has_section_key("schematic", "connectors"):
        return {}


    var data: Dictionary
    data["windows"] = file.get_value("schematic", "windows")
    data["connectors"] = file.get_value("schematic", "connectors")
    data["rect"] = file.get_value("schematic", "rect")
    data["name"] = file.get_value("schematic", "name", "schematic")
    data["icon"] = file.get_value("schematic", "icon", "blueprint")

    return data


func load_schematics() -> void:
    var dir_access: DirAccess = DirAccess.open("user://")
    if !dir_access.dir_exists("schematics"):
        return

    for i: String in dir_access.get_files_at("user://schematics"):
        if !i.ends_with(".dat"):
            continue

        var schem: Dictionary = load_schematic("user://schematics".path_join(i))
        if !schem.is_empty():
            schematics[i.get_basename()] = load_schematic("user://schematics".path_join(i))


func save() -> Dictionary:
    return {
        "fps_limit": fps_limit,
        "glow": glow,
        "colorblind": colorblind,
        "scientific": scientific,
        "mute_sfx": mute_sfx,
        "volume_sfx": volume_sfx,
        "mute_windows": mute_windows,
        "volume_windows": volume_windows,
        "mute_bgm": mute_bgm,
        "volume_bgm": volume_bgm,
        "scale": scale,
        "language": language
    }
