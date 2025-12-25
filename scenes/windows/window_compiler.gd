extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var clock := $PanelContainer/MainContainer/Clock
@onready var text := $PanelContainer/MainContainer/Text
@onready var program := $PanelContainer/MainContainer/Program
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
    if text.count >= text.required:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = floorf(min(progress / goal, text.count / text.required))
            program.add(count)
            progress = fmod(progress, goal)
            text.pop(count * text.required)
            if is_processing():
                program.animate_icon_in_pop(count)
            audio_player.play()
    else:
        progress = 0

    program.production = min(clock.count / goal, text.production / text.required)


func set_program_variation(variation: int) -> void:
    program.set_resource(program.resource, variation)


func update_type() -> void:
    goal = Utils.get_file_size(program.resource, program.variation) * 2 * Attributes.get_window_attribute(window, "cycles_multiplier")

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_text_resource_set() -> void:
    set_program_variation(text.variation)


func _on_program_resource_set() -> void:
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
