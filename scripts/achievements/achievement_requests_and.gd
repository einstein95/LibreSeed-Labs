extends Achievement


func _ready() -> void :
    super ()
    Signals.new_request.connect(_on_new_request)

    if !unlocked and check_progress():
        unlock()


func check_progress() -> bool:
    for i: String in Data.achievements[name].requirement:
        if Globals.requests[i] <= 0: return false
    return true


func _on_new_request(request: String) -> void :
    if !unlocked and check_progress():
        unlock()
