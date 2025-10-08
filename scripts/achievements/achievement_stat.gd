extends "res://scripts/achievements/achievement_tick.gd"

var stat: String
var amount: float


func _ready() -> void :
    stat = Data.achievements[name].stat
    amount = Data.achievements[name].requirement * (10 ** Data.achievements[name].requirement_e)
    super ()


func check_progress() -> bool:
    return Globals.stats[stat] >= amount
