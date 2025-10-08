class_name Achievement extends Node

var unlocked: bool


func _ready() -> void :
    Signals.new_achievement.connect(_on_new_achievement)

    if check_progress():
        unlock()
        unlocked = true


func check_progress() -> bool:
    return false


func unlock() -> void :
    if unlocked: return
    Globals.add_achievement(name)


func _on_new_achievement(achievement: String) -> void :
    unlocked = Globals.achievements[name] >= 1
    if unlocked:
        queue_free()
