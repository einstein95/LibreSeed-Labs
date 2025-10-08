extends WindowIndexed

@export var base_goal: float
@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var clock: = $PanelContainer / MainContainer / Clock
@onready var code: = $PanelContainer / MainContainer / Code
@onready var result: = $PanelContainer / MainContainer / Result
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float


func _ready() -> void :
    super ()

    update_type()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "cc"


func process(delta: float) -> void :
    if code.count >= code.required:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = floorf(min(progress / goal, code.count / code.required))
            result.add(count)
            progress = fmod(progress, goal)
            code.pop(count * code.required)
            if is_processing():
                result.animate_icon_in_pop(count)
            audio_player.play()
    else:
        progress = 0

    result.production = min(clock.count / goal, code.production / code.required)


func update_type() -> void :
    goal = base_goal * Attributes.get_window_attribute(window, "cycles_multiplier")

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "cc"


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
