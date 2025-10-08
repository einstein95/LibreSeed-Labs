extends WindowIndexed

@export var base_goal: float
@export var goal_e: float

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var processor: = $PanelContainer / MainContainer / Processor
@onready var sound: = $PanelContainer / MainContainer / Sound
@onready var image: = $PanelContainer / MainContainer / Image
@onready var video: = $PanelContainer / MainContainer / Video
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
    if sound.count >= sound.required and image.count >= image.required:
        progress += processor.count * delta
        if progress >= goal:
            var count: float = floorf(min(progress / goal, sound.count / sound.required, image.count / image.required))
            video.add(count)
            progress = fmod(progress, goal)
            image.pop(count * image.required)
            sound.pop(count * sound.required)
            if is_processing():
                video.animate_icon_in_pop(count)
            audio_player.play()
    else:
        progress = 0

    video.production = min(processor.count / goal, sound.production / sound.required, image.production / image.required)


func set_video_variation(variation: int) -> void :
    video.set_resource(video.resource, variation)


func update_type() -> void :
    goal = Utils.get_file_size(video.resource, video.variation) * (base_goal * 10 ** goal_e) * Attributes.get_window_attribute(window, "cycles_multiplier")

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_image_resource_set() -> void :
    set_video_variation(sound.variation & image.variation)


func _on_sound_resource_set() -> void :
    set_video_variation(sound.variation & image.variation)


func _on_video_resource_set() -> void :
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
