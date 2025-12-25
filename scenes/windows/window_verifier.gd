extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var clock := $PanelContainer/MainContainer/Clock
@onready var file := $PanelContainer/MainContainer/File
@onready var validated := $PanelContainer/MainContainer/Validated
@onready var corrupted := $PanelContainer/MainContainer/Corrupted
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
    var corrupt_chance: float = Attributes.get_window_attribute(window, "corrupt_chance")
    if floorf(file.count) >= 1:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = file.pop(floorf(progress / goal))
            var validated_count: float = floorf(count * (1.0 - corrupt_chance))
            var corrupted_count: float = floorf(count * corrupt_chance)

            var remaining: float = count - validated_count - corrupted_count
            if remaining > 0.0:
                var bad_from_remaining: float = 0.0
                for i in int(remaining):
                    if randf() < corrupt_chance:
                        bad_from_remaining += 1.0
                validated_count += remaining - bad_from_remaining
                corrupted_count += bad_from_remaining
            validated.add(validated_count)
            corrupted.add(corrupted_count)
            Globals.stats.scanned += count

            progress = fmod(progress, goal)

            if is_processing():
                if validated_count > 0:
                    validated.animate_icon_in()
                if corrupted_count > 0:
                    corrupted.animate_icon_in()
                audio_player.play()
    else:
        progress = 0

    validated.production = min(clock.count / goal, file.production) * (1.0 - corrupt_chance)
    corrupted.production = min(clock.count / goal, file.production) * corrupt_chance


func update_type() -> void:
    if Data.files.has(file.resource):
        goal = Utils.get_file_size(file.resource, file.variation) * Attributes.get_window_attribute(window, "cycles_multiplier")
    else:
        goal = 1

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_file_resource_set() -> void:
    progress = 0

    validated.set_resource(file.resource, file.variation | Utils.file_variations.VALIDATED)
    corrupted.set_resource(file.resource, file.variation | Utils.file_variations.CORRUPTED)
    update_type()


func _on_attribute_changed() -> void:
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
