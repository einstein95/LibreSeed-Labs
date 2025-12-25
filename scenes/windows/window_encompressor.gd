extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var clock := $PanelContainer/MainContainer/Clock
@onready var file := $PanelContainer/MainContainer/File
@onready var output := $PanelContainer/MainContainer/Output
@onready var audio_player := $AudioStreamPlayer2D

var progress: float
var goal: float = 5


func _ready() -> void:
    super ()
    Attributes.window_attributes[window]["cycles_multiplier"].changed.connect(_on_attribute_changed)

    update_type()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "C"


func process(delta: float) -> void:
    if floorf(file.count) >= 1:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = floorf(min(progress / goal, file.count))
            output.add(count)
            Globals.stats.compressed += count
            progress = fmod(progress, goal)
            file.pop(count)
            if is_processing():
                output.animate_icon_in_pop(count)
                audio_player.play()
    else:
        progress = 0

    output.production = min(clock.count / goal, file.production)


func update_type() -> void:
    if Data.files.has(file.resource):
        goal = Utils.get_file_size(file.resource, file.variation) * 6 * Attributes.get_window_attribute(window, "cycles_multiplier")
    else:
        goal = 1

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_file_resource_set() -> void:
    progress = 0

    var max_level: int = Attributes.get_window_attribute(window, "level")
    var new_var: int = file.variation

    if max_level >= 1 and file.variation & Utils.file_variations.COMPRESSED:
        new_var |= Utils.file_variations.COMPRESSED2
    elif max_level > 2 and file.variation & Utils.file_variations.COMPRESSED2:
        new_var |= Utils.file_variations.COMPRESSED3
    else:
        new_var |= Utils.file_variations.COMPRESSED

    if max_level >= 1 and file.variation & Utils.file_variations.ENHANCED:
        new_var |= Utils.file_variations.ENHANCED2
    elif max_level >= 2 and file.variation & Utils.file_variations.ENHANCED2:
        new_var |= Utils.file_variations.ENHANCED3
    else:
        new_var |= Utils.file_variations.ENHANCED

    output.set_resource(file.resource, new_var)
    update_type()


func _on_attribute_changed() -> void:
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
