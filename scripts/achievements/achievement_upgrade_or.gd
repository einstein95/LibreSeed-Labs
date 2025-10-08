extends Achievement


func _ready() -> void :
    super ()
    Signals.new_upgrade.connect(_on_new_upgrade)


func check_progress() -> bool:
    for i: String in Data.achievements[name].requirement:
        if Globals.upgrades[i] >= 1: return true
    return false


func _on_new_upgrade(upgrade: String, levels: int) -> void :
    if !unlocked and check_progress():
        unlock()
