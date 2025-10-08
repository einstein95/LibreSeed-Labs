extends Node

signal apply_set

var boost: Dictionary
var paused: bool


func _ready() -> void :
    boost = Globals.boosts[name]

    if boost.applied:
        apply()


func process(delta: float) -> void :
    boost.time -= delta
    if boost.time <= 0:
        remove()


func apply() -> void :
    Attributes.apply_attribute_dict(Data.boosts[name].attributes, 1)
    Attributes.apply_windows_attribute_dict(Data.boosts[name].window_attributes, 1)
    boost.applied = true
    Signals.tick.connect(_on_tick)

    apply_set.emit()


func add(time: float) -> void :
    boost.time += time
    if !boost.applied:
        apply()


func _on_tick() -> void :
    process(0.05 * Attributes.get_attribute("offline_time_multiplier"))


func remove() -> void :
    Attributes.apply_attribute_dict(Data.boosts[name].attributes, -1)
    Attributes.apply_windows_attribute_dict(Data.boosts[name].window_attributes, -1)
    boost.applied = false
    Signals.tick.disconnect(_on_tick)

    apply_set.emit()
