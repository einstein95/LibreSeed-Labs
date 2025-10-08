extends WindowIndexed

@export var currency: String
@export var base_goal: float
@export var goal_e: float
@export var goal_inc: float

@onready var progress_label: = $PanelContainer / MainContainer / Optimizations / ProgressContainer / Amount
@onready var progress_bar: = $PanelContainer / MainContainer / Optimizations / ProgressBar
@onready var requirements: = $PanelContainer / MainContainer / Requirements
@onready var points: = $PanelContainer / MainContainer / Points

var progress: float
var goal: float
var goal_str: String


func _ready() -> void :
    super ()

    update_goal()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, true) + "/" + goal_str


func process(delta: float) -> void :
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


func complete(times: float) -> void :
    progress += times
    while progress >= goal:
        progress -= goal
        data.level += 1
        Globals.currencies[currency] += 1
        update_goal()


func update_goal() -> void :
    goal = base_goal * 10 ** goal_e
    goal *= goal_inc ** data.level

    goal_str = Utils.print_string(goal, true)
    $PanelContainer / MainContainer / Points / Info / Count.text = "+%.0f" % (data.level)


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
