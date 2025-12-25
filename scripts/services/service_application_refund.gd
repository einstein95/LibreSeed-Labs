extends "res://scripts/services/service.gd"


func apply() -> void:
    super ()
    Globals.currencies["application_point"] = Globals.upgrades["application"]
