extends Achievement

var timer: Timer = Timer.new()
var breaches: Dictionary = {"anonymous": false, "corporation": false, "government": false}


func _enter_tree() -> void :
    add_child(timer)
    timer.timeout.connect(_on_timer_timeout)
    timer.one_shot = true


func _ready() -> void :
    super ()
    Signals.breached.connect(_on_breached)


func _on_breached(breach: WindowIndexed) -> void :
    match breach.window:
        "breach_anonymous":
            breaches["anonymous"] = true
        "breach_corps":
            breaches["corporation"] = true
        "breach_government":
            breaches["government"] = true
    if timer.is_stopped():
        timer.start(1)


func _on_timer_timeout() -> void :
    if !unlocked and breaches["anonymous"] and breaches["corporation"] and breaches["government"]:
        unlock()
    else:
        breaches["anonymous"] = false
        breaches["corporation"] = false
        breaches["government"] = false
