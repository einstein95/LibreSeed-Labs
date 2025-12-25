extends PanelContainer


func _ready() -> void:
    Signals.tutorial_step.connect(_on_tutorial_step)
    Signals.screen_set.connect(_on_screen_set)
    Signals.tool_set.connect(_on_tool_set)

    update_buttons()


func _process(delta: float) -> void:
    if !visible or get_viewport().gui_get_focus_owner():
        return

    if Input.is_action_just_pressed("multi_select"):
        Globals.tool = Utils.tools.SELECT
        Signals.tool_set.emit()
        Signals.fixed_notify.emit("selection", "tool_selection")
    elif Input.is_action_just_released("multi_select"):
        Globals.tool = Utils.tools.CURSOR
        Signals.tool_set.emit()
        Signals.fixed_notify.emit("cursor", "tool_cursor")


func update_buttons() -> void:
    visible = Globals.tutorial_done
    $Tools/Cursor.button_pressed = Globals.tool == Utils.tools.CURSOR
    $Tools/Move.button_pressed = Globals.tool == Utils.tools.MOVE
    $Tools/Select.button_pressed = Globals.tool == Utils.tools.SELECT
    $Tools/ConnectionEdit.button_pressed = Globals.editing_connection


func _on_cursor_pressed() -> void:
    Globals.tool = Utils.tools.CURSOR
    Signals.tool_set.emit()
    Signals.fixed_notify.emit("cursor", "tool_cursor")
    Sound.play("click2")


func _on_move_pressed() -> void:
    Globals.tool = Utils.tools.MOVE
    Signals.tool_set.emit()
    Signals.fixed_notify.emit("move", "tool_move")
    Sound.play("click2")


func _on_select_pressed() -> void:
    Globals.tool = Utils.tools.SELECT
    Signals.tool_set.emit()
    Signals.fixed_notify.emit("selection", "tool_selection")
    Sound.play("click2")


func _on_connection_edit_pressed() -> void:
    Globals.editing_connection = !Globals.editing_connection
    Signals.tool_set.emit()
    if Globals.editing_connection:
        Signals.fixed_notify.emit("circle", "tool_connection_editor_on")
    else:
        Signals.fixed_notify.emit("circle", "tool_connection_editor_off")
    Sound.play("click2")


func _on_tutorial_step() -> void:
    update_buttons()


func _on_tool_set() -> void:
    update_buttons()


func _on_screen_set(screen: int) -> void:
    update_buttons()
