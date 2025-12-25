extends Achievement


func _ready() -> void:
    super ()

    if !unlocked:
        Signals.tick.connect(_on_tick)


func _on_tick() -> void:
    if !unlocked and check_progress():
        unlock()
