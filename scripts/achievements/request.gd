extends Node

var file: String
var variation: int
var req: float
var unlocked: bool


func _ready() -> void:
    Signals.new_unlock.connect(_on_new_unlock)
    Signals.new_request.connect(_on_new_request)

    file = Data.requests[name].file
    variation = int(Data.requests[name].variation)
    req = Data.requests[name].goal * 10 ** Data.requests[name].goal_e

    unlocked = is_unlocked()

    if unlocked:
        Signals.tick.connect(_on_tick)


func _on_tick() -> void:
    if !unlocked:
        return

    if Globals.request_progress[name] >= req:
        Globals.add_request(name)


func _on_new_request(request: String) -> void:
    if !unlocked:
        unlocked = is_unlocked()
        if unlocked:
            Signals.tick.connect(_on_tick)
    if Globals.requests[name] >= 1:
        queue_free()


func _on_new_unlock(unlock: String) -> void:
    if !unlocked:
        unlocked = is_unlocked()
        if unlocked:
            Signals.tick.connect(_on_tick)


func is_unlocked() -> bool:
    if Data.requests[name].requirement.is_empty():
        return true

    for i: String in Data.requests[name].requirement:
        if Globals.unlocks[i]:
            return true

    return false
