extends WindowIndexed

@onready var power: = $PanelContainer / MainContainer / Power

@export var current: float


func process(delta: float) -> void :
    power.count = current * Attributes.get_attribute("power_multiplier")
