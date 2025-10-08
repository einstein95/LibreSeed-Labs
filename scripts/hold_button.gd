extends Button

signal holded

var timer: Timer = Timer.new()


func _ready() -> void :
    button_down.connect(_on_button_down)
    button_up.connect(_on_button_up)

    add_child(timer)
    timer.one_shot = true
    timer.timeout.connect(_on_timer_timeout)


func _on_button_down() -> void :
    timer.start(0.5)


func _on_button_up() -> void :
    timer.stop()


func _on_timer_timeout() -> void :
    holded.emit()
