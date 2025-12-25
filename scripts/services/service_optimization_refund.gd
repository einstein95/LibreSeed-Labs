extends "res://scripts/services/service.gd"


func apply() -> void:
    super ()
    Globals.currencies["optimization_point"] = Globals.upgrades["optimization"]
