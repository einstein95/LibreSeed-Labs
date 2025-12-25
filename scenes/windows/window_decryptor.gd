extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var clock := $PanelContainer/MainContainer/Clock
@onready var encrypted := $PanelContainer/MainContainer/Encrypted
@onready var decrypted := $PanelContainer/MainContainer/Decrypted
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
    progress_label.text = Utils.print_string(progress, false) + "cc"


func process(delta: float) -> void:
    if floorf(encrypted.count) >= 1:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = encrypted.pop(floorf(progress / goal))
            decrypted.add(count)
            Globals.stats.decrypted += count
            progress = fmod(progress, goal)
            if is_processing():
                decrypted.animate_icon_in_pop(count)
                audio_player.play()
    else:
        progress = 0

    decrypted.production = min(clock.count / goal, encrypted.production)


func update_type() -> void:
    goal = pow(10, Data.resources[encrypted.resource].size_e - 2) * Attributes.get_window_attribute(window, "cycles_multiplier") * 5

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_string(goal, false) + "cc"


func _on_file_resource_set() -> void:
    progress = 0
    decrypted.set_resource(Data.resources[encrypted.resource].variations["decrypted"])
    update_type()


func _on_attribute_changed() -> void:
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
