extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var clock := $PanelContainer/MainContainer/Clock
@onready var video := $PanelContainer/MainContainer/Video
@onready var program := $PanelContainer/MainContainer/Program
@onready var game := $PanelContainer/MainContainer/Game
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
    if video.count >= video.required and program.count >= program.required:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = floorf(min(progress / goal, video.count / video.required, program.count / program.required))
            game.add(count)
            progress = fmod(progress, goal)
            program.pop(count * program.required)
            video.pop(count * video.required)
            if is_processing():
                game.animate_icon_in_pop(count)
    else:
        progress = 0

    game.production = min(clock.count / goal, video.production / video.required, program.production / program.required)


func set_game_variation(variation: int) -> void:
    game.set_resource(game.resource, variation)


func update_type() -> void:
    goal = Utils.get_file_size(game.resource, game.variation) * 2 * Attributes.get_window_attribute(window, "cycles_multiplier")

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_video_resource_set() -> void:
    set_game_variation(video.variation & program.variation)


func _on_program_resource_set() -> void:
    set_game_variation(video.variation & program.variation)


func _on_game_resource_set() -> void:
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
