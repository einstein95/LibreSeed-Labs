extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var clock: = $PanelContainer / MainContainer / Clock
@onready var video: = $PanelContainer / MainContainer / Video
@onready var image: = $PanelContainer / MainContainer / Image
@onready var sound: = $PanelContainer / MainContainer / Sound
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float = 10


func _ready() -> void :
    super ()

    update_type()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "C"


func process(delta: float) -> void :
    if floorf(video.count) >= 1:
        progress += clock.count * delta
        if progress >= goal:
            var image_count: float = video.pop(floorf(progress / goal)) * 50000000.0
            var sound_count: float = video.pop(floorf(progress / goal)) * 50000000.0
            image.add(image_count)
            sound.add(sound_count)
            progress = fmod(progress, goal)
            if is_processing():
                image.animate_icon_in_pop(image_count)
                sound.animate_icon_in_pop(sound_count)
            audio_player.play()
    else:
        progress = 0

    image.production = min(clock.count / goal) * 2500.0
    sound.production = min(clock.count / goal) * 250.0


func set_output_variation(variation: int) -> void :
    image.set_resource(image.resource, variation)
    sound.set_resource(sound.resource, variation)


func update_type() -> void :
    goal = Utils.get_file_size(video.resource, video.variation) * 2 * Attributes.get_window_attribute(window, "cycles_multiplier")

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_video_resource_set() -> void :
    set_output_variation(video.variation)
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
