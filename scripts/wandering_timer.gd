extends "res://scripts/random_timer.gd"

@export var requirements: Array[String]
@export var level_requirement: int


func _ready() -> void :
    if !can_start():
        Signals.new_unlock.connect(_on_new_unlock)
        Signals.new_level.connect(_on_new_level)
        Signals.tutorial_step.connect(_on_tutorial_step)

    super ()


func can_start() -> bool:
    for i: String in requirements:
        if !Globals.unlocks[i]: return false

    if Globals.money_level < level_requirement: return false
    if !Globals.tutorial_done: return false

    return true


func disconnect_signals() -> void :
    Signals.new_unlock.disconnect(_on_new_unlock)
    Signals.new_level.disconnect(_on_new_level)
    Signals.tutorial_step.disconnect(_on_tutorial_step)


func _on_new_unlock(unlock: String) -> void :
    if can_start():
        begin_timer()
        disconnect_signals()


func _on_new_level() -> void :
    if can_start():
        begin_timer()
        disconnect_signals()


func _on_tutorial_step() -> void :
    if can_start():
        begin_timer()
        disconnect_signals()
