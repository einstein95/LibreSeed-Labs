extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var gpu: = $PanelContainer / MainContainer / GPU
@onready var file: = $PanelContainer / MainContainer / File
@onready var neurons: = $PanelContainer / MainContainer / Neurons
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float = 5
var base_neurons: float


func _ready() -> void :
    super ()
    Attributes.window_attributes[window]["cycles_multiplier"].changed.connect(_on_attribute_changed)

    update_type()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "C"


func process(delta: float) -> void :
    if file.count >= file.required:
        progress += gpu.count * delta
        if progress >= goal:
            var count: float = floorf(min(progress / goal, file.count / file.required))
            var amount: float = count * base_neurons * Attributes.get_attribute("neuron_multiplier")
            neurons.add(amount)
            file.pop(count * file.required)
            Globals.stats.max_neurons += amount
            progress = fmod(progress, goal)
            audio_player.play()
            if is_processing():
                neurons.animate_icon_in_pop(amount)
    else:
        progress = 0

    neurons.production = min(gpu.count / goal, file.production / file.required) * base_neurons * Attributes.get_attribute("neuron_multiplier")


func update_type() -> void :
    if Data.files.has(file.resource):
        goal = Utils.get_file_size(file.resource, file.variation) * 40000000000000.0 * Attributes.get_window_attribute(window, "cycles_multiplier")
    else:
        goal = 1
    base_neurons = 1 * Utils.get_variation_neuron_multiplier(file.variation)

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "C"


func _on_file_resource_set() -> void :
    progress = 0
    neurons.set_resource(Data.files[file.resource].neuron)
    update_type()


func _on_attribute_changed() -> void :
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
