extends WindowIndexed

@export var output_count: float = 1

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var clock := $PanelContainer/MainContainer/Clock
@onready var input := $PanelContainer/MainContainer/Input
@onready var output := $PanelContainer/MainContainer/Output
@onready var audio_player := $AudioStreamPlayer2D

var progress: float
var goal: float = 10


func _ready() -> void:
    super ()

    update_type()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "C"


func process(delta: float) -> void:
    if floorf(input.count) >= 1:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = input.pop(floorf(progress / goal)) * output_count
            output.add(count)
            progress = fmod(progress, goal)
            if is_processing():
                output.animate_icon_in_pop(count)
            audio_player.play()
    else:
        progress = 0

    output.production = min(clock.count / goal, input.production) * output_count


func set_output_variation(variation: int) -> void:
    output.set_resource(output.resource, variation)


func update_type() -> void:
    goal = Utils.get_file_size(input.resource, input.variation) * 2 * Attributes.get_window_attribute(window, "cycles_multiplier")

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_input_resource_set() -> void:
    set_output_variation(input.variation)
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
