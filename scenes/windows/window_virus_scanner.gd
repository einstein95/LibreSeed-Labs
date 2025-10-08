extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var clock: = $PanelContainer / MainContainer / Clock
@onready var file: = $PanelContainer / MainContainer / File
@onready var clean: = $PanelContainer / MainContainer / Clean
@onready var infected: = $PanelContainer / MainContainer / Infected
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float = 5


func _ready() -> void :
    super ()
    Attributes.window_attributes[window]["cycles_multiplier"].changed.connect(_on_attribute_changed)

    update_type()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "C"


func process(delta: float) -> void :
    var virus_chance: float = Attributes.get_window_attribute(window, "virus_chance")
    if floorf(file.count) >= 1:
        progress += clock.count * delta
        if progress >= goal:
            var count: float = file.pop(floorf(progress / goal))
            var clean_count: float = floorf(count * (1.0 - virus_chance))
            var infected_count: float = floorf(count * virus_chance)

            var remaining: float = count - clean_count - infected_count
            if remaining > 0.0:
                var infected_from_remaining: float = 0.0
                for i in int(remaining):
                    if randf() < virus_chance:
                        infected_from_remaining += 1.0
                clean_count += remaining - infected_from_remaining
                infected_count += infected_from_remaining
            clean.add(clean_count)
            infected.add(infected_count)
            Globals.stats.scanned += count

            progress = fmod(progress, goal)

            if is_processing():
                if clean_count > 0:
                    clean.animate_icon_in()
                if infected_count > 0:
                    infected.animate_icon_in()
                audio_player.play()
    else:
        progress = 0

    clean.production = min(clock.count / goal, file.production) * (1.0 - virus_chance)
    infected.production = min(clock.count / goal, file.production) * virus_chance


func update_type() -> void :
    if Data.files.has(file.resource):
        goal = Utils.get_file_size(file.resource, file.variation) * Attributes.get_window_attribute(window, "cycles_multiplier")
    else:
        goal = 1

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_file_resource_set() -> void :
    progress = 0

    var new_var: int = file.variation
    new_var |= Utils.file_variations.SCANNED

    clean.set_resource(file.resource, new_var)
    infected.set_resource(file.resource, new_var | Utils.file_variations.INFECTED)
    update_type()


func _on_attribute_changed() -> void :
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
