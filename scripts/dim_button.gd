extends DesktopButton

var timer: Timer = Timer.new()
var times_holding: int


func _init() -> void :
    button_down.connect(_on_button_down)
    button_up.connect(_on_button_up)

    add_child(timer)
    timer.one_shot = true
    timer.timeout.connect(press)

    button_mask = 0
    toggle_mode = true


func _on_button_down() -> void :
    timer.start(0.5)


func _on_button_up() -> void :
    timer.stop()
    times_holding = 0
    cancel_press = false


func press() -> void :
    if !disabled and !dragged:
        pressed.emit()
        times_holding += 1
        timer.start(0.5 / sqrt(min(times_holding, 100)))
        cancel_press = true
