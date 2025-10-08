extends WindowIndexed

const base: float = pow(10, 16) * 6

@onready var cores: = $PanelContainer / MainContainer / Cores
@onready var clock: = $PanelContainer / MainContainer / Clock
@onready var boost: = $PanelContainer / MainContainer / Boost


func process(delta: float) -> void :
    clock.count = base * pow(cores.count, 0.4) * (1.0 + boost.count) * Attributes.get_attribute("clock_multiplier")
