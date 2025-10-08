extends Panel

@onready var progress_bar: = $ProgressBar

var maxed: bool
var level: int
var cost: float
var requirement_met: bool


func _ready() -> void :
    Signals.milestone_queued.connect(_on_milestone_queued)
    Signals.new_unlock.connect(_on_new_unlock)

    update_all()


func _process(delta: float) -> void :
    progress_bar.value = lerpf(progress_bar.value, Globals.max_research / cost, 1.0 - exp(-50.0 * delta))


func update_all() -> void :
    level = Globals.milestones[name]
    var q_level: int = Globals.q_milestones[name]
    var max_level: int = Data.milestones[name].limit
    maxed = max_level > 0 and level + q_level >= max_level

    requirement_met = Data.milestones[name].requirement.is_empty()
    if !requirement_met:
        for i: String in Data.milestones[name].requirement:
            if !Globals.unlocks[i]: break
            requirement_met = true

    cost = Data.milestones[name].cost * (10 ** Data.milestones[name].cost_e) * (Data.milestones[name].cost_inc ** (level + q_level))

    $InfoContainer / NameContainer / Name.text = Data.milestones[name].name
    if max_level == 0:
        $InfoContainer / NameContainer / Count.text = "[" + tr("lv.") + str(level) + "]"
    else:
        $InfoContainer / NameContainer / Count.text = "[" + tr("lv.") + str(level) + "/" + str(max_level) + "]"

    $InfoContainer / NameContainer / QueueCount.text = "+" + str(q_level)
    $InfoContainer / NameContainer / QueueCount.visible = q_level > 0
    $InfoContainer / Description.text = Data.milestones[name].description
    $IconPanel / Icon.texture = load("res://textures/icons/" + Data.milestones[name].icon + ".png")

    $CostContainer / Label.text = Utils.print_string(cost, true)

    if q_level > 0:
        $AnimationPlayer.play("Available")
    update_visibility()


func update_visibility() -> void :
    visible = get_visibility()


func get_visibility() -> bool:
    if !requirement_met: return false

    return true


func _on_visibility_changed() -> void :
    update_all()
    set_process(is_visible_in_tree())


func _on_milestone_queued(milestone: String, levels: int) -> void :
    update_all()


func _on_new_unlock(unlock: String) -> void :
    update_all()
