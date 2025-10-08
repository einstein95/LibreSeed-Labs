extends WindowIndexed

const base: float = pow(10, 10) * 8

@onready var cores: = $PanelContainer / MainContainer / Cores
@onready var boost: = $PanelContainer / MainContainer / Boost
@onready var clock: = $PanelContainer / MainContainer / Clock


func process(delta: float) -> void :
    clock.count = base * pow(cores.count, 0.4) * (1.0 + boost.count) * Attributes.get_attribute("gpu_multiplier")
