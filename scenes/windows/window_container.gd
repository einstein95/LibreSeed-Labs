class_name WindowContainer extends VBoxContainer

signal initialized

@export var can_select: bool
@export var can_delete: bool
@export var can_drag: bool
@export var can_multi_select: bool
@export var can_pause: bool
@export var can_export: bool
@export var has_colors: bool
@export var help: String

var closing: bool
var grabbing: bool
var grabbing_pos: Vector2
var dragged: bool
var init_count: int


func _enter_tree() -> void :
    item_rect_changed.connect(_on_item_rect_changed)


func _ready() -> void :
    Signals.selection_set.connect(_on_selection_set)

    global_position = global_position.clampf(-5000, 4650).snappedf(50)
    $VisibleOnScreenNotifier2D.screen_entered.connect(_on_visible_on_screen_notifier_2d_screen_entered)
    $VisibleOnScreenNotifier2D.rect = Rect2(0, 0, size.x, size.y)

    pivot_offset = size / 2
    scale = Vector2(0, 0)
    modulate.a = 0
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_BOUNCE)
    tween.set_parallel()
    tween.tween_property(self, "modulate:a", 1, 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.2)

    Signals.window_created.emit(self)

    process_set(false)

    if init_count == 0:
        initialized.emit()


func _process(delta: float) -> void :
    return


func close() -> void :
    closing = true
    set_process(false)
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_parallel()
    tween.tween_property(self, "modulate:a", 0, 0.2)
    tween.tween_property(self, "scale", Vector2(0, 0), 0.2)
    tween.finished.connect( func() -> void : queue_free())

    Signals.window_deleted.emit(self)

    if grabbing:
        grabbing = false
        Globals.dragging = false
        Signals.dragging_set.emit()


func move(pos: Vector2) -> void :
    global_position = pos


func grab(g: bool) -> void :
    grabbing = g
    if grabbing:
        grabbing_pos = get_global_mouse_position() - global_position
    else:
        Signals.dragged.emit(self)
    Globals.dragging = grabbing
    Signals.dragging_set.emit()


func _on_gui_input(event: InputEvent) -> void :
    if closing: return
    if Globals.tool == Utils.tools.MOVE:
        Signals.movement_input.emit(event, global_position)
        return

    if event is InputEventScreenTouch:
        if event.index >= 1:
            Signals.movement_input.emit(event, global_position)
            return
        if event.pressed:
            get_parent().move_child(self, get_parent().get_child_count() - 1)
            dragged = false
        elif event.is_released() and !dragged and can_select:
            if Input.is_key_pressed(KEY_CTRL):
                var new_selection: Array[WindowContainer] = Globals.selections.duplicate()
                if Globals.selections.has(self):
                    new_selection.erase(self)
                else:
                    new_selection.append(self)
                Globals.set_selection(new_selection, Globals.connector_selection, 1)
            else:
                Globals.set_selection([self], [], 1)
            Sound.click()
        grab(event.is_pressed() and can_drag)
        Signals.set_menu.emit(0, 0)
    elif event is InputEventScreenDrag:
        if event.index >= 1:
            Signals.movement_input.emit(event, global_position)
            return
        dragged = true
        if grabbing:
            var new_pos: Vector2 = (get_global_mouse_position() - grabbing_pos).snappedf(50).clampf(-5000, 5000)
            if Globals.selections.has(self):
                Signals.move_connectors.emit(new_pos - global_position)
                Signals.move_selection.emit(new_pos - global_position)
            else:
                move(new_pos)
    else:
        Signals.movement_input.emit(event, global_position)


func process_set(enabled: bool) -> void :
    set_process(enabled)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void :
    process_set(true)
    $TitlePanel.visible = true
    $PanelContainer.visible = true


func _on_visible_on_screen_notifier_2d_screen_exited() -> void :
    $TitlePanel.visible = grabbing
    $PanelContainer.visible = grabbing


func _on_item_rect_changed() -> void :

    pivot_offset = size / 2
    $VisibleOnScreenNotifier2D.rect = Rect2(0, 0, size.x, size.y)
    Signals.window_moved.emit(self)


func _exit_tree() -> void :
    Globals.selections.erase(self)


func _on_selection_set() -> void :
    if Globals.selections.has(self):
        if Signals.move_selection.is_connected(_on_move_selection): return
        Signals.move_selection.connect(_on_move_selection)
    else:
        if !Signals.move_selection.is_connected(_on_move_selection): return
        Signals.move_selection.disconnect(_on_move_selection)


func _on_move_selection(to: Vector2) -> void :
    move(global_position + to)


func export() -> Dictionary:
    return {
        "filename": scene_file_path.get_file(), 
        "position": position
    }


func save() -> Dictionary:
    return {
        "filename": scene_file_path.get_file(), 
        "position": position
    }
