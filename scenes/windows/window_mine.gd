extends WindowIndexed

@export var base_goal: float

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var gpu: = $PanelContainer / MainContainer / GPU
@onready var coin: = $PanelContainer / MainContainer / Coin
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float


func _ready() -> void :
    super ()
    Attributes.window_attributes[window]["cycles_multiplier"].changed.connect(_on_attribute_changed)

    update_goal()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "C"


func process(delta: float) -> void :
    progress += gpu.count * delta
    if progress >= goal:
        var count: float = floorf(progress / goal)
        coin.add(count)
        progress = fmod(progress, goal)
        audio_player.play()
        if is_processing():
            coin.animate_icon_in_pop(count)

    coin.production = gpu.count / goal


func update_goal() -> void :
    goal = base_goal * Attributes.get_window_attribute(window, "cycles_multiplier")
    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_attribute_changed() -> void :
    update_goal()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
