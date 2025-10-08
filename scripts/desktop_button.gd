class_name DesktopButton extends Button

var dragged: bool
var cancel_press: bool


func _init() -> void :
    button_mask = 0
    toggle_mode = true


func _gui_input(event: InputEvent) -> void :
    if event is InputEventScreenTouch:
        if event.index >= 1:
            Signals.movement_input.emit(event, global_position)
            return
        button_pressed = event.is_pressed()
        if event.is_pressed():
            button_down.emit()
            Signals.movement_input.emit(event, global_position)
        elif event.is_released():
            if !dragged and !disabled and !cancel_press:
                pressed.emit()
            dragged = false
            button_up.emit()
    elif event is InputEventScreenDrag:
        if event.index >= 1:
            Signals.movement_input.emit(event, global_position)
            return
        dragged = dragged or event.velocity.length() >= 100
        button_pressed = !dragged
        Signals.movement_input.emit(event, global_position)
    else:
        Signals.movement_input.emit(event, global_position)
