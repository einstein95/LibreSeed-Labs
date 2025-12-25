extends Node

const storage_files: Array[String] = ["text", "image", "sound", "video", "program", "game"]

var desktop: Desktop
var cur_screen: int
var tool: int
var editing_connection: bool
var selections: Array[WindowContainer]
var connector_selection: Array[Control]
var selection_type: int
var connecting: String
var connection_type: int
var dragging: bool
var camera_center: Vector2
var camera_zoom: Vector2
var ui_mouse_pos: Vector2
var platform: int
var window_count: Dictionary
var group_count: Dictionary
var script_count: Dictionary
var max_window_count: int
var max_script_count: int
var storage_value: float
var currency_production: Dictionary
var cur_date: Dictionary
var claimabled_tokens: int
var unlocks: Dictionary[String, bool]
var features: Dictionary[String, bool]
var money_level: int
var research_level: int
var time_elapsed: float

var windows_data: Dictionary
var currencies: Dictionary
var upgrades: Dictionary
var research: Dictionary
var q_research: Dictionary
var milestones: Dictionary
var q_milestones: Dictionary
var perks: Dictionary
var boosts: Dictionary
var stats: Dictionary
var achievements: Dictionary
var requests: Dictionary
var request_progress: Dictionary
var storage: Dictionary
var max_money: float
var max_research: float
var mined_tokens: int
var hack_level: int
var code_level: int
var bank_level: int
var storage_size: float
var tutorial_step: int
var tutorial_done: bool
var offline_time: float
var offline_multiplier: int
var last_recorded_time: int
var last_date: Dictionary

func _enter_tree() -> void:
    var platform_map := {
        "Linux": 1,
        "Android": 2,
        "iOS": 3,
        "macOS": 4
    }
    platform = platform_map.get(OS.get_name(), 0)


func _ready() -> void:
    Signals.tick.connect(_on_tick)

func init_vars() -> void:
    group_count = {"breach_skills": 0}

    for i: String in Data.windows:
        if !window_count.has(i):
            window_count[i] = 0
        if !Data.windows[i].data.is_empty():
            if !windows_data.has(i):
                windows_data[i] = Data.windows[i].data.duplicate()
            else:
                windows_data[i] = windows_data[i].merged(Data.windows[i].data.duplicate())

    for i: String in Data.currencies:
        if !currencies.has(i):
            currencies[i] = 0
        currency_production[i] = 0

    for i: String in Data.upgrades:
        if !upgrades.has(i):
            upgrades[i] = 0
        unlocks["upgrade." + i] = false

    for i: String in Data.research:
        if !research.has(i):
            research[i] = 0
        unlocks["research." + i] = false

    for i: String in Data.milestones:
        if !milestones.has(i):
            milestones[i] = 0
        if !q_milestones.has(i):
            q_milestones[i] = 0

    for i: String in Data.perks:
        if !perks.has(i):
            perks[i] = 0
        unlocks["perk." + i] = false

    for i: String in Data.boosts:
        if !boosts.has(i):
            boosts[i] = {"time": 0, "applied": false}

    for i: String in Data.storage:
        if !storage.has(i):
            storage[i] = {}

    for i: String in Data.stats:
        if !stats.has(i):
            stats[i] = 0

    for i: String in Data.achievements:
        if !achievements.has(i):
            achievements[i] = int(0)

    for i: String in Data.requests:
        if !requests.has(i):
            requests[i] = int(0)
        if !request_progress.has(i):
            request_progress[i] = 0

    money_level = floori(log(max_money + 1) / log(10))
    research_level = floori(log(max_research + 1) / log(10))
    init_upgrades()

func init_upgrades() -> void:
    for i: String in upgrades:
        if !Data.upgrades.has(i):
            continue

        unlocks["upgrade." + i] = upgrades[i] > 0

    for i: String in research:
        if !Data.research.has(i):
            continue

        unlocks["research." + i] = research[i] > 0
        for upgrade: String in Data.research[i].upgrades:
            upgrades[upgrade] = max(Data.research[i].upgrades[upgrade], upgrades[upgrade])

    for i: String in perks:
        if !Data.perks.has(i):
            continue

        unlocks["perk." + i] = perks[i] > 0


func _process(delta: float) -> void:
    pass


func process(delta: float) -> void:
    add_offline_time(Attributes.get_attribute("online_rest_time_gain") * Attributes.get_attribute("rest_time_multiplier") * delta / 72)
    if offline_multiplier > 1:
        if offline_time <= 0:
            set_offline_multiplier(1)

    for i: String in currency_production:
        currency_production[i] = 0

    var new_level: int = floori(log(max_money + 1) / log(10))
    if new_level != money_level:
        money_level = new_level
        Signals.new_level.emit()

    new_level = floori(log(max_research + 1) / log(10))
    if new_level != research_level:
        research_level = new_level
        Signals.new_research_level.emit()

    storage_value = get_storage_value()

    var levels: int
    for i: String in Data.milestones:
        levels = 0
        var requirement: float = Data.milestones[i].cost * (10 ** Data.milestones[i].cost_e) * Data.milestones[i].cost_inc ** (milestones[i] + q_milestones[i])
        while max_research >= requirement:
            levels += 1
            requirement *= Data.milestones[i].cost_inc

        if levels > 0:
            queue_milestone(i, levels)

    if Time.get_date_dict_from_system().day != cur_date.day:
        cur_date = Time.get_date_dict_from_system()
        Signals.date_changed.emit()

    if claimabled_tokens > 0:
        currencies["token"] += claimabled_tokens
        Signals.tokens_claimed.emit()
        claimabled_tokens = 0

    var time_multiplier: float = Attributes.get_attribute("time_multiplier") * Attributes.get_attribute("offline_time_multiplier")
    stats.time_played += delta
    stats.elapsed_time += delta * time_multiplier
    time_elapsed += delta * time_multiplier


func set_unlock(unlock: String, enabled: bool = true) -> void:
    unlocks[unlock] = enabled
    Signals.new_unlock.emit(unlock)


func add_upgrade(upgrade: String, levels: int) -> void:
    upgrades[upgrade] += levels
    set_unlock("upgrade." + upgrade, upgrades[upgrade] > 0)
    Signals.new_upgrade.emit(upgrade, levels)


func add_hack_levels(levels: int) -> void:
    hack_level += levels
    Globals.currencies["hack_point"] += 1
    Signals.new_hack_level.emit()


func add_code_levels(levels: int) -> void:
    code_level += levels
    Signals.new_code_level.emit()


func queue_research(r: String, levels: int) -> void:
    if q_research.has(r):
        q_research[r] += levels
    else:
        q_research[r] = levels
    Signals.research_queued.emit(r, levels)


func add_research(r: String, levels: int) -> void:
    research[r] += levels
    set_unlock("research." + r, research[r])
    Signals.new_research.emit(r, levels)


func add_milestone(milestone: String, levels: int) -> void:
    milestones[milestone] += levels
    Signals.new_milestone.emit(milestone, levels)


func queue_milestone(milestone: String, levels: int) -> void:
    if q_milestones.has(milestone):
        q_milestones[milestone] += levels
    else:
        q_milestones[milestone] = levels
    Signals.milestone_queued.emit(milestone, levels)


func add_perk(perk: String, levels: int) -> void:
    perks[perk] += levels
    set_unlock("perk." + perk, perks[perk] > 0)
    Signals.new_perk.emit(perk, levels)


func add_achievement(achievement: String) -> void:
    achievements[achievement] = int(1)
    Signals.new_achievement.emit(achievement)


func claim_achievement(achievement: String) -> void:
    achievements[achievement] = int(2)
    var reward: float = Data.achievements[achievement].reward
    currencies["token"] += reward
    stats.max_tokens += reward
    Signals.achievement_claimed.emit(achievement)


func add_request(request: String) -> void:
    requests[request] = int(1)
    Signals.new_request.emit(request)


func claim_request(request: String) -> void:
    requests[request] = int(2)
    var reward: float = Data.requests[request].reward
    currencies["token"] += reward
    stats.max_tokens += reward
    Signals.request_claimed.emit(request)

func add_offline_time(time: float) -> void:
    offline_time = min(offline_time + time, Attributes.get_attribute("max_rest_time"))


func add_storage(file: String, variation: int) -> void:
    storage[file][variation] = {"value": 0.0, "size": 0.0}
    Signals.new_storage.emit(file, variation)


func delete_storage(file: String, variation: int) -> void:
    storage[file].erase(variation)
    Signals.storage_deleted.emit(file, variation)


func set_offline_multiplier(multiplier: int) -> void:
    Attributes.apply_attribute("offline_time_multiplier", [multiplier - offline_multiplier, 0, 0], 1)
    offline_multiplier = multiplier
    Signals.offline_multiplier_set.emit()


func set_selection(selection: Array[WindowContainer], connectors: Array[Control], type: int) -> void:
    selections = selection
    connector_selection = connectors
    selection_type = type
    Signals.selection_set.emit()


func set_tutorial_step(step: int) -> void:
    if step != tutorial_step:
        tutorial_step = step
        tutorial_done = tutorial_step == Utils.tutorial_steps.DONE
        Signals.tutorial_step.emit()


func clear() -> void:
    cur_screen = 0
    tool = 0
    editing_connection = false
    selections.clear()
    connector_selection.clear()
    selection_type = 0
    connecting = ""
    connection_type = 0
    dragging = false
    window_count.clear()
    group_count.clear()
    script_count.clear()
    max_window_count = 0
    max_script_count = 0
    storage_value = 0
    currency_production.clear()
    cur_date = Time.get_date_dict_from_system()
    claimabled_tokens = 0
    unlocks.clear()
    features.clear()
    money_level = 0
    research_level = 0
    time_elapsed = 0

    achievements.clear()
    requests.clear()
    request_progress.clear()
    stats.clear()
    upgrades.clear()
    research.clear()
    milestones.clear()
    perks.clear()
    q_research.clear()
    q_milestones.clear()
    storage.clear()
    window_count.clear()
    windows_data.clear()
    group_count.clear()
    currencies.clear()
    max_money = 1
    max_research = 1
    mined_tokens = 0
    hack_level = 0
    code_level = 0
    bank_level = 0
    max_window_count = 0
    offline_time = 0
    offline_multiplier = 1
    storage_size = 0
    tutorial_step = 0
    tutorial_done = false
    last_recorded_time = Time.get_unix_time_from_system()
    last_date = Time.get_date_dict_from_system()

func wipe() -> void:
    clear()
    init_vars()
    Attributes.init_attributes()


func get_storage_value() -> float:
    var value: float
    for file: String in storage:
        for variation: int in storage[file]:
            var multiplier: float = Attributes.get_attribute(Data.files[file].attribute)
            if variation & Utils.file_variations.AI:
                multiplier *= Attributes.get_attribute(Data.files[file].ai_attribute)
            value += sqrt(storage[file][variation].value) * multiplier * 0.02

    return value * Attributes.get_attribute("income_multiplier")


func get_hack_required_exp(level: int) -> float:
    return 8 * pow(4, level)


func get_code_required_exp(level: int) -> float:
    return 20 * pow(3, level)


func is_mobile() -> bool:
    return platform == 2 or platform == 3


func _on_tick() -> void:
    process(0.05)


func save() -> Dictionary:
    Signals.saving.emit()

    return {
        "windows_data": windows_data,
        "currencies": currencies,
        "max_money": max_money,
        "max_research": max_research,
        "upgrades": upgrades,
        "storage": storage,
        "storage_size": storage_size,
        "research": research,
        "q_research": q_research,
        "milestones": milestones,
        "mined_tokens": mined_tokens,
        "hack_level": hack_level,
        "code_level": code_level,
        "bank_level": bank_level,
        "perks": perks,
        "boosts": boosts,
        "stats": stats,
        "achievements": achievements,
        "requests": requests,
        "request_progress": request_progress,
        "tutorial_done": tutorial_done,
        "offline_time": offline_time,
        "last_recorded_time": int(Time.get_unix_time_from_system()),
        "last_date": Time.get_date_dict_from_system(),
        "save_ver": 0
    }
