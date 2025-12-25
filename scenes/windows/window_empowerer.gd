extends WindowIndexed

@onready var power := $PanelContainer/MainContainer/Power
@onready var boost := $PanelContainer/MainContainer/Boost


func process(delta: float) -> void:
    boost.count = power.count * Attributes.get_attribute("empower_power")
