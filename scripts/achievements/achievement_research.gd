extends Achievement


func _ready() -> void:
    super ()
    Signals.new_research.connect(_on_new_research)


func check_progress() -> bool:
    if Globals.research[Data.achievements[name].requirement] == 0:
        return false

    return true


func _on_new_research(research: String, levels: int) -> void:
    if !unlocked and check_progress():
        unlock()
