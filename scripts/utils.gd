extends Node

enum tools {
    CURSOR,
    MOVE,
    SELECT,
    CONNECTION
}
enum menu_types {
    NONE,
    SIDE,
    WINDOWS,
    SCHEMATICS
}
enum menus {
    UPGRADES,
    STORAGE,
    TOKENS,
    PORTAL,
    GUIDE,
    ACHIEVEMENTS,
    SETTINGS
}
enum window_menus {NETWORK, CPU, GPU, RESEARCH, HACKING, CODING, UTILITY}
enum resource_types {MATERIAL, FLOW, BOOST, MATERIAL_LIMITED, SETTING, FLUID}
enum print_types {STANDARD, METRIC, MULTIPLIER, PERCENTAGE}
enum connections_types {NONE, OUTPUT, INPUT}
enum file_variations {
    SCANNED = 1 << 0,
    VALIDATED = 1 << 1,
    COMPRESSED = 1 << 2,
    COMPRESSED2 = 1 << 3,
    COMPRESSED3 = 1 << 4,
    ENHANCED = 1 << 5,
    ENHANCED2 = 1 << 6,
    ENHANCED3 = 1 << 7,
    INFECTED = 1 << 8,
    REFINED = 1 << 9,
    DISTILLED = 1 << 10,
    ANALYZED = 1 << 11,
    HACKED = 1 << 12,
    CORRUPTED = 1 << 13,
    AI = 1 << 14
}
enum damage_variation {
    STEALTH = 1
}
enum code_variations {
    FIXED = 1,
    BUGGED = 2,
    OPTIMIZED = 4
}
enum tutorial_steps {
    PRESS,
    DRAG_DOWNLOAD_CONNECTOR,
    CONNECT_DOWNLOADER,
    PRESS2,
    DRAG_BIN_CONNECTOR,
    PRESS3,
    OPEN_MENU,
    SELECT_UPLOADER,
    ADD_UPLOADER,
    DRAG_UPLOADER,
    MOVE_UPLOADER,
    DRAG_FILE_CONNECTOR,
    CONNECT_FILE,
    DRAG_UPLOAD_CONNECTOR,
    CONNECT_UPLOADER,
    PRESS4,
    OPEN_MENU2,
    SELECT_COLLECTOR,
    ADD_COLLECTOR,
    DRAG_MONEY_CONNECTOR,
    CONNECT_MONEY,
    PRESS5,
    SELECT_BIN,
    DELETE_BIN,
    PRESS6,
    DONE
}

const suffixes: Array[String] = [
    "", "k", "m", "b", "t", "aa", "ab", "ac", "ad", "ae", "af", "ag", "ah", "ai", "aj", "ak", "al", "am", "an", "ao", "ap",
    "aq", "ar", "as", "at", "au", "av", "aw", "ax", "ay", "az", "ba", "bb", "bc", "bd", "be", "bf", "bg", "bh", "bi", "bj", "bk", "bl", "bm", "bn", "bo", "bp",
    "bq", "br", "bs", "bt", "bu", "bv", "bw", "bx", "by", "bz", "ca", "cb", "cc", "cd", "ce", "cf", "cg", "ch", "ci", "cj", "ck", "cl", "cm", "cn", "co", "cp",
    "cq", "cr", "cs", "ct", "cu", "cv", "cw", "cx", "cy", "cz", "da", "db", "dc", "dd", "de", "df", "dg", "dh", "di", "dj", "dk", "dl", "dm", "dn", "do", "dp",
    "dq", "dr", "ds", "dt", "du", "dv", "dw", "dx", "dy", "dz"
]
const metric: Array[String] = [
    "", "K", "M", "G", "T", "P", "E", "Z", "Y", "R", "Q"
]


func print_string(value: float, hide_decimals: bool = true) -> String:
    if Data.scientific:
        return print_scientific(value, hide_decimals)
    else:
        return to_aa(value, hide_decimals)


func to_aa(value: float, hide_decimals: bool = true) -> String:
    var magnitude: int = log(value) / log(1000)

    if magnitude >= suffixes.size():
        return print_scientific(value, hide_decimals)

    var formattedNumber: String
    if magnitude > 0:
        value /= pow(1000, magnitude)
        formattedNumber = "%.2f" % value
    elif hide_decimals:
        formattedNumber = "%.f" % floorf(value)
    else:
        formattedNumber = "%.2f" % value

    formattedNumber = formattedNumber.substr(0, 4)

    if formattedNumber.find(".") > -1:
        formattedNumber = formattedNumber.rstrip("0").rstrip(".")

    if magnitude > 0:
        return formattedNumber + suffixes[magnitude]
    else:
        return formattedNumber


func print_scientific(value: float, hide_decimals: bool = true) -> String:
    var magnitude: int = floori(log(value) / log(10))
    var normalized: float = value / pow(10, magnitude)

    var formattedNumber: String
    if magnitude >= 3:
        value /= pow(10, magnitude)
        if value >= 10:
            value /= 10
            magnitude += 1
        formattedNumber = "%.2f" % value
    elif hide_decimals:
        formattedNumber = "%.f" % floorf(value)
    else:
        formattedNumber = "%.2f" % value

    formattedNumber = formattedNumber.substr(0, 4)

    if formattedNumber.find(".") > -1:
        formattedNumber = formattedNumber.rstrip("0").rstrip(".")

    if magnitude >= 3:
        return formattedNumber + "e" + str(magnitude)
    else:
        return formattedNumber


func print_metric(value: float, hide_decimals: bool = true) -> String:
    if Data.scientific:
        return print_scientific(value, hide_decimals)
    var magnitude: int = log(value) / log(1000)

    if magnitude >= metric.size():
        return print_scientific(value, hide_decimals)

    var formattedNumber: String
    if magnitude > 0:
        value /= pow(1000, magnitude)
        formattedNumber = "%.2f" % value
    elif hide_decimals:
        formattedNumber = "%.f" % floorf(value)
    else:
        formattedNumber = "%.2f" % value

    formattedNumber = formattedNumber.substr(0, 4)

    if formattedNumber.find(".") > -1:
        formattedNumber = formattedNumber.rstrip("0").rstrip(".")

    if magnitude > 0:
        return formattedNumber + metric[magnitude]
    else:
        return formattedNumber


func world_to_screen_pos(pos: Vector2) -> Vector2:
    var camera: Camera2D = get_viewport().get_camera_2d()
    return (pos - camera.global_position) * camera.zoom + get_viewport().get_visible_rect().size / 2


func screen_to_world_pos(pos: Vector2) -> Vector2:
    var camera: Camera2D = get_viewport().get_camera_2d()
    return (pos - get_viewport().get_visible_rect().size / 2) / camera.zoom + camera.global_position


func can_add_window(window: String) -> bool:
    var limit: int = Attributes.get_window_attribute(window, "limit")
    var active: int = Globals.window_count[window]
    if !Data.windows[window].group.is_empty():
        limit = Attributes.get_attribute(Data.windows[window].group)
        active = Globals.group_count[Data.windows[window].group]

    if limit >= 0 and active >= limit:
        return false

    if !Data.windows[window].requirement.is_empty() and !Globals.unlocks[Data.windows[window].requirement]:
        return false


    return true


func get_file_value(file: String, variation: int) -> float:
    return Data.files[file].value * 10 ** Data.files[file].value_e * get_variation_value_multiplier(variation)


func get_file_size(file: String, variation: int) -> float:
    return Data.files[file].size * 10 ** Data.files[file].size_e * get_variation_size_multiplier(variation)


func get_file_research(file: String, variation: int) -> float:
    return Data.files[file].research * get_variation_research_multiplier(variation)


func get_variation_quality_multiplier(variation: int) -> float:
    var multiplier: float = 1.0

    if variation & file_variations.ENHANCED:
        multiplier *= 2
    if variation & file_variations.ENHANCED2:
        multiplier *= 2
    if variation & file_variations.ENHANCED3:
        multiplier *= 2
    if variation & file_variations.AI:
        multiplier *= 2

    return multiplier


func get_variation_value_multiplier(variation: int) -> float:
    var multiplier: float = get_variation_quality_multiplier(variation)

    if variation & file_variations.SCANNED:
        multiplier *= 4
    if variation & file_variations.INFECTED:
        multiplier *= 0.25
    if variation & file_variations.VALIDATED:
        multiplier *= 4
    if variation & file_variations.AI:
        multiplier *= 10000000.0

    return multiplier


func get_variation_research_multiplier(variation: int) -> float:
    var multiplier: float = get_variation_quality_multiplier(variation)

    if variation & file_variations.REFINED:
        multiplier *= 2
    if variation & file_variations.AI:
        multiplier *= 0

    return multiplier


func get_variation_neuron_multiplier(variation: int) -> float:
    var multiplier: float = get_variation_quality_multiplier(variation)

    if variation & file_variations.DISTILLED:
        multiplier *= 2
    if variation & file_variations.AI:
        multiplier *= 0

    return multiplier


func get_variation_size_multiplier(variation: int) -> float:
    var multiplier: float = 1.0

    if variation & file_variations.COMPRESSED:
        multiplier *= 0.5
    if variation & file_variations.COMPRESSED2:
        multiplier *= 0.5
    if variation & file_variations.COMPRESSED3:
        multiplier *= 0.5
    if variation & file_variations.ENHANCED:
        multiplier *= 2
    if variation & file_variations.ENHANCED2:
        multiplier *= 2
    if variation & file_variations.ENHANCED3:
        multiplier *= 2

    return multiplier


func get_code_value_multiplier(variation: int) -> float:
    var multiplier: float = 1.0

    if variation & code_variations.FIXED:
        multiplier += 3
    if variation & code_variations.OPTIMIZED:
        multiplier *= 2

    return multiplier


func get_resource_symbols(type: String, variation: int) -> String:
    var symbols: String

    for i: String in Data.symbols[type].keys():
        if variation & i.bin_to_int():
            symbols += Data.symbols[type][i]

    return symbols


func generate_simple_id() -> String:
    return "%08x%04x" % [randi(), randi() & 65535]


func generate_id_from_seed(seed: int) -> String:
    var rng: RandomNumberGenerator = RandomNumberGenerator.new()
    rng.seed = seed

    return "%08x%04x" % [rng.randi(), rng.randi() & 65535]
