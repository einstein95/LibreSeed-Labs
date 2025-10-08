extends Achievement


func _ready() -> void :
    super ()
    Signals.new_upgrade.connect(_on_new_upgrade)


func check_progress() -> bool:
    for i: String in Data.achievements[name].requirement:
        if Globals.upgrades[i] <= 0: return false
    return true


func _on_new_upgrade(upgrade: String, levels: int) -> void :
    if !unlocked and check_progress():
        unlock()
