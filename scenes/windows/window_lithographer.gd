extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var power := $PanelContainer/MainContainer/Power
@onready var wafer := $PanelContainer/MainContainer/Wafer
@onready var transistor := $PanelContainer/MainContainer/Transistor

var progress: float
var goal: float = 10


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, true)


func process(delta: float) -> void:
    if wafer.count >= wafer.required:
        progress += power.count * delta
        if progress >= goal:
            var count: float = floorf(progress / goal)
            transistor.add(wafer.pop(count) * 1000)
            progress = fmod(progress, goal)
            if is_processing():
                transistor.animate_icon_in_pop(count)
    else:
        progress = 0


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
