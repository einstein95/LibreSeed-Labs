extends WindowIndexed

@export var upgrade: String

@onready var progress_label := $PanelContainer/MainContainer/Optimizations/ProgressContainer/Amount
@onready var progress_bar := $PanelContainer/MainContainer/Optimizations/ProgressBar
@onready var requirements := $PanelContainer/MainContainer/Requirements
@onready var points := $PanelContainer/MainContainer/Points

var progress: float
var goal: float
var goal_str: String


func _ready() -> void:
    super ()
    Signals.new_upgrade.connect(_on_new_upgrade)

    update_goal()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, true) + "/" + goal_str


func process(delta: float) -> void:
    if check_requirements():
        var count: float = INF
        for i: ResourceContainer in requirements.get_children():
            count = floorf(min(count, i.count / i.required))

        complete(count)
        for i: ResourceContainer in requirements.get_children():
            i.pop(count * i.required)


func check_requirements() -> bool:
    for i: ResourceContainer in requirements.get_children():
        if i.count < i.required:
            return false

    return true


func complete(times: float) -> void:
    progress += times
    while progress >= goal:
        progress -= goal
        Globals.add_upgrade(upgrade, 1)


func update_goal() -> void:
    goal = Data.upgrades[upgrade].cost * 10 ** Data.upgrades[upgrade].cost_e
    goal *= Data.upgrades[upgrade].cost_inc ** Globals.upgrades[upgrade]

    goal_str = Utils.print_string(goal, true)
    $PanelContainer/MainContainer/Level/Info/Count.text = tr("version") + " %.0f.0" % (Globals.upgrades[upgrade] + 1)
    $PanelContainer/MainContainer/Points/Info/Count.text = Utils.print_string(1.2 ** Globals.upgrades[upgrade], false) + "x"


func _on_new_upgrade(upgrade: String, levels: int) -> void:
    update_goal()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
