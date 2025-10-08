extends Panel

var center: Vector2


func _ready() -> void :
    Signals.selecting.connect(_on_selecting)
    Signals.selected.connect(_on_selected)


func _process(delta: float) -> void :
    if get_global_mouse_position().x >= center.x:
        size.x = get_global_mouse_position().x - center.x
        global_position.x = center.x
    else:
        size.x = center.x - get_global_mouse_position().x
        global_position.x = get_global_mouse_position().x

    if get_global_mouse_position().y >= center.y:
        size.y = get_global_mouse_position().y - center.y
        global_position.y = center.y
    else:
        size.y = center.y - get_global_mouse_position().y
        global_position.y = get_global_mouse_position().y


func _on_input_blocker_gui_input(event: InputEvent) -> void :
    if event is InputEventScreenTouch:
        if event.is_pressed():
            if Globals.tool == Utils.tools.MOVE:
                Signals.movement_input.emit(event, Vector2(-10000, -10000))
            elif Globals.cur_screen == 0 and Globals.tool == Utils.tools.SELECT:
                _on_selecting()
        elif visible:
            _on_selected()
    else:
        if Globals.tool == Utils.tools.MOVE:
            Signals.movement_input.emit(event, Vector2(-10000, -10000))


func _on_selecting() -> void :
    center = get_global_mouse_position()
    global_position = get_global_mouse_position()
    visible = true
    set_process(true)
    Globals.dragging = true
    Signals.dragging_set.emit()


func _on_selected() -> void :
    var windows: Array[WindowContainer]
    var connectors: Array[Control]
    for i: WindowContainer in get_tree().get_nodes_in_group("window"):
        if i.can_multi_select and get_rect().intersects(i.get_rect()):
            windows.append(i)
    for i: Control in get_tree().get_nodes_in_group("pivot"):
        if get_rect().intersects(i.get_rect()):
            connectors.append(i)

    if Input.is_key_pressed(KEY_CTRL):
        for i: WindowContainer in Globals.selections:
            if !windows.has(i):
                windows.append(i)
        for i: Control in Globals.connector_selection:
            if !connectors.has(i):
                connectors.append(i)

    Globals.set_selection(windows, connectors, 2)
    Globals.dragging = false
    Signals.dragging_set.emit()

    if windows.size() + connectors.size() > 0:
        hide()

        if !Input.is_action_pressed("multi_select"):
            Globals.tool = 0
            Signals.tool_set.emit()

        Sound.click()
    else:
        hide()

        Sound.play("close")


func hide() -> void :
    super ()
    set_process(false)
