extends WindowIndexed

@export var goal: float
@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var code_speed: = $PanelContainer / MainContainer / CodeSpeed
@onready var result: = $PanelContainer / MainContainer / Result
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float


func _ready() -> void :
    super ()

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(goal, false) + "op"


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, false) + "op"


func process(delta: float) -> void :
    progress += code_speed.count * delta
    if progress >= goal:
        var count: float = floorf(progress / goal)
        result.add(count)

        progress = fmod(progress, goal)
        audio_player.play()
        if is_processing():
            result.animate_icon_in_pop(count)

    result.production = code_speed.count / goal


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
