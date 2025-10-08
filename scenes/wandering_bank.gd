extends "res://scenes/wandering_object.gd"


func claim() -> void :
    super ()
    var window: WindowIndexed = load("res://scenes/windows/window_breach_bank.tscn").instantiate()
    window.global_position = global_position - window.size / 2
    Signals.create_window.emit(window)
