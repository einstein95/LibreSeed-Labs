extends WindowIndexed

@onready var text_neuron := $PanelContainer/MainContainer/TextNeuron
@onready var image_neuron := $PanelContainer/MainContainer/ImageNeuron
@onready var sound_neuron := $PanelContainer/MainContainer/SoundNeuron
@onready var video_neuron := $PanelContainer/MainContainer/VideoNeuron
@onready var program_neuron := $PanelContainer/MainContainer/ProgramNeuron
@onready var game_neuron := $PanelContainer/MainContainer/GameNeuron
@onready var ai := $PanelContainer/MainContainer/AI


func process(delta: float) -> void:
    ai.count = min(text_neuron.count / 10000000000000.0, image_neuron.count / 100000000000.0,
    sound_neuron.count / 1000000000.0, video_neuron.count / 10000000.0,
    program_neuron.count / 100000.0, game_neuron.count / 1000.0)
