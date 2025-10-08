extends Node

var duration: float
var time_left: float
var attributes: Dictionary


func _ready() -> void :
    Signals.tick.connect(_on_tick)
    time_left = duration

    Attributes.apply_attribute_dict(attributes)


func tick(delta: float) -> void :
    if time_left > 0:
        time_left -= delta
    else:
        Attributes.apply_attribute_dict(attributes, -1)
        Signals.tick.disconnect(_on_tick)
        queue_free()


func _on_tick() -> void :
    tick(0.05 * Attributes.get_attribute("time_multiplier") * Attributes.get_attribute("offline_time_multiplier"))
