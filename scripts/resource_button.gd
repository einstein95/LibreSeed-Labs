extends DesktopButton


func _ready() -> void :
    pressed.connect(_on_pressed)
    Signals.resource_selected.connect(_on_resource_selected)


func _on_pressed() -> void :
    if button_pressed:
        Signals.resource_selected.emit(null)
    elif !get_parent().resource.is_empty():
        Signals.resource_selected.emit(get_parent())
    Sound.play("click_toggle")


func _on_resource_selected(res: ResourceContainer) -> void :
    button_pressed = res == get_parent()

    if res == get_parent():
        $Icon.self_modulate = Color("ff8500")
    else:
        $Icon.self_modulate = $Icon.color
