extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var power := $PanelContainer/MainContainer/Power
@onready var silicon := $PanelContainer/MainContainer/Silicon
@onready var wire := $PanelContainer/MainContainer/Wire
@onready var wafer := $PanelContainer/MainContainer/Wafer

var progress: float
var goal: float = 10


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, true)


func process(delta: float) -> void:
    if wire.count >= wire.required and silicon.count >= silicon.required:
        progress += power.count * delta
        if progress >= goal:
            var count: float = min(progress / goal, wire.count / wire.required, silicon.count / silicon.required)
            wafer.add(count)
            progress = fmod(progress, goal)
            silicon.pop(count * silicon.required)
            wire.pop(count * wire.required)
            if is_processing():
                wafer.animate_icon_in_pop(count)
    else:
        progress = 0


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
