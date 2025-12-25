extends Achievement


func _ready() -> void:
    super ()
    Signals.window_created.connect(_on_window_created)


func check_progress() -> bool:
    for i: String in Data.achievements[name].requirement:
        if Globals.window_count[i] <= 0:
            return false

    return true


func _on_window_created(window: WindowContainer) -> void:
    if !unlocked and check_progress():
        unlock()
