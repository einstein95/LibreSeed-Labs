extends WindowIndexed

@onready var overclock: = $PanelContainer / MainContainer / Overclock

var power: int = 0


func _ready() -> void :
    super ()

    $PanelContainer / MainContainer / RatioSlider.value = power


func process(delta: float) -> void :
    overclock.count = pow(1.2, power) - 1


func _on_ratio_slider_drag_ended(value_changed: bool) -> void :
    power = $PanelContainer / MainContainer / RatioSlider.value
    Sound.play("click")


func save() -> Dictionary:
    return super ().merged({
        "power": power
    })
