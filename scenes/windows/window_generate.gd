extends WindowIndexed

@export var multiplier: float = 20000000000.0

@onready var neuron := $PanelContainer/MainContainer/Neuron
@onready var file := $PanelContainer/MainContainer/File


func process(delta: float) -> void:
    file.production = neuron.count * multiplier
    var count: float = floorf(file.production * delta)
    file.add(count)
    Globals.stats.generated += count
