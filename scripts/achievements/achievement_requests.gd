extends Achievement


func _ready() -> void :
    super ()
    Signals.new_request.connect(_on_new_request)


func _on_new_request(request: String) -> void :
    if !unlocked and check_progress():
        unlock()


func check_progress() -> bool:
    var count: int
    for i: String in Globals.requests:
        if Globals.requests[i] > 0:
            count += 1
    return count >= Data.requests.size()
