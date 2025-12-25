extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var clock := $PanelContainer/MainContainer/Clock
@onready var file := $PanelContainer/MainContainer/Compressed
@onready var zip := $PanelContainer/MainContainer/Zip
@onready var audio_player := $AudioStreamPlayer2D

var progress: float
var goal: float


func _ready() -> void:
    super ()
    Attributes.window_attributes[window]["cycles_multiplier"].changed.connect(_on_attribute_changed)

    update_type()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "cc"


func process(delta: float) -> void:
    if file.count >= file.required:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = floorf(min(progress / goal, file.count / file.required))
            zip.add(count)
            Globals.stats.packaged += count
            progress = fmod(progress, goal)
            file.pop(count * file.required)
            if is_processing():
                zip.animate_icon_in_pop(count)
                audio_player.play()
    else:
        progress = 0

    zip.production = min(clock.count / goal, file.production / file.required)


func update_type() -> void:
    if Data.files.has(file.resource):
        goal = pow(10, Data.files[file.resource].size_e - 2) * Attributes.get_window_attribute(window, "cycles_multiplier") * 5
    else:
        goal = 1

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_string(goal, false) + "cc"


func _on_file_resource_set() -> void:
    progress = 0
    zip.set_resource(Data.files[file.resource].variations["pack"])
    update_type()


func _on_attribute_changed() -> void:
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
