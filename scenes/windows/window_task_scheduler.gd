extends WindowIndexed

@onready var clock: = $PanelContainer / MainContainer / Clock
@onready var gpu: = $PanelContainer / MainContainer / GPU


func process(delta: float) -> void :
    clock.count = gpu.count * 0.5 * Attributes.get_window_attribute(window, "efficiency")
