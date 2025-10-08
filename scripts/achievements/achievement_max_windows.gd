extends "res://scripts/achievements/achievement_tick.gd"

var amount: float


func _ready() -> void :
    amount = Data.achievements[name].requirement
    super ()


func check_progress() -> bool:
    return Globals.max_window_count >= amount
