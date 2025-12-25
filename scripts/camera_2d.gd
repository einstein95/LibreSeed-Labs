extends Camera2D

@export var limit: float

var dragging: bool
var zooming: bool
var target_zoom: Vector2
var target_pos: Vector2
var touch_points: Dictionary[int, Dictionary] = {0: {"pressed": false, "start_pos": Vector2.ZERO, "last_pos": Vector2.ZERO, "pos": Vector2.ZERO},
1: {"pressed": false, "start_pos": Vector2.ZERO, "last_pos": Vector2.ZERO, "pos": Vector2.ZERO}}
var initial_zoom: Vector2
var min_zoom: Vector2


func _ready() -> void:
    Signals.movement_input.connect(_on_movement_input)
    Signals.center_camera.connect(_on_center_camera)
    Signals.move_camera.connect(_on_move_camera)

    if OS.get_name() == "Android":
        zoom = Vector2(1.4, 1.4)

    target_zoom = zoom


func clamp_pos(to: Vector2) -> Vector2:
    return Vector2(clampf(to.x, -limit, limit), clampf(to.y, -limit, limit))


func _process(delta: float) -> void:
    var movement: Vector2 = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"), Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"))
    if !get_viewport().gui_get_focus_owner() and movement:
        position = clamp_pos(position + movement * 1000 * delta)

    if zooming:
        zoom = zoom.lerp(target_zoom, 1.0 - exp(-10 * delta))
        zooming = !zoom.is_equal_approx(target_zoom)

    Globals.camera_center = get_screen_center_position()
    Globals.camera_zoom = zoom
    position_smoothing_enabled = zooming


func zoom_to(new_zoom: Vector2, world_pos: Vector2) -> void:
    var old_zoom: Vector2 = target_zoom
    target_zoom = new_zoom
    var screen_pos: Vector2 = (world_pos - position) * old_zoom
    var new_camera_pos: Vector2 = world_pos - screen_pos / target_zoom

    zooming = true
    position_smoothing_enabled = zooming
    position = clamp_pos(new_camera_pos)


func handle_movement_input(event: InputEvent, from: Vector2) -> void:
    if event is InputEventScreenTouch:
        if Globals.cur_screen == 0 and Globals.tool == Utils.tools.SELECT:
            pass
        else:
            if event.index >= 2:
                return

            if event.is_pressed():
                touch_points[event.index].start_pos = event.position + from
                touch_points[event.index].last_pos = event.position + from
                touch_points[event.index].pos = event.position + from
            touch_points[event.index].pressed = event.pressed

            var touch_count: int
            for i: int in touch_points:
                if touch_points[i].pressed:
                    touch_count += 1

            if touch_count == 2:
                initial_zoom = zoom
    elif event is InputEventScreenDrag:
        if Globals.cur_screen == 0 and Globals.tool == Utils.tools.SELECT:
            return

        if event.index >= 2:
            return

        touch_points[event.index].last_pos = touch_points[event.index].pos
        touch_points[event.index].pos = event.position + from

        var touch_count: int
        for i: int in touch_points:
            if touch_points[i].pressed:
                touch_count += 1

        if touch_count == 1:
            position = clamp_pos(position + (touch_points[event.index].start_pos - touch_points[event.index].pos))
            zooming = false
        elif touch_count == 2:
            var start_distance: float = touch_points[0].start_pos.distance_to(touch_points[1].start_pos)
            if start_distance <= 0:
                return

            var new_distance: float = touch_points[0].pos.distance_to(touch_points[1].pos)
            var zoom_factor: float = new_distance / start_distance
            var new_zoom: Vector2 = (initial_zoom * zoom_factor).clamp(min_zoom, Vector2(1.6, 1.6))

            zoom = zoom.lerp(new_zoom, 0.1)

            var old_center: Vector2 = (touch_points[0].start_pos + touch_points[1].start_pos) / 2
            var new_center: Vector2 = (touch_points[0].pos + touch_points[1].pos) / 2
            var center_movement: Vector2 = old_center - new_center

            position = clamp_pos(position + center_movement)
            zooming = false
    elif event is InputEventMouseButton:
        var zoom_change: Vector2 = Vector2(0, 0)

        if event.button_index == 4:
            zoom_change = Vector2(0.1, 0.1)

        if event.button_index == 5:
            zoom_change = - Vector2(0.1, 0.1)

        if zoom_change.length() == 0:
            return

        var new_zoom: Vector2 = target_zoom + zoom_change
        new_zoom = new_zoom.clamp(min_zoom, Vector2(1.2, 1.2))

        zoom_to(new_zoom, event.position + from)


func _on_dragger_gui_input(event: InputEvent) -> void:
    handle_movement_input(event, Vector2(-10000, -10000))
    if event is InputEventScreenTouch:
        if event.pressed:
            Signals.set_menu.emit(0, 0)
        else:
            if event.is_released():
                if !dragging:
                    if !Globals.connecting.is_empty():
                        Globals.connecting = ""
                        Globals.connection_type = 0
                        Signals.connection_set.emit()

                    if Globals.cur_screen == 0:
                        if Globals.selection_type != 0:
                            Globals.set_selection([], [], 0)
                            Sound.play("close")

                        Signals.resource_selected.emit(null)
                    elif Globals.cur_screen == 1:
                        Signals.research_selected.emit("")
                dragging = false
    elif event is InputEventScreenDrag:
        if touch_points.size() == 1:
            dragging = true


func _on_move_camera(movement: Vector2) -> void:
    position = clamp_pos(position + movement)


func _on_selector_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        _on_dragger_gui_input(event)


func _on_center_camera(pos: Vector2) -> void:
    position = clamp_pos(pos)


func _on_movement_input(input: InputEvent, from: Vector2) -> void:
    handle_movement_input(input, from)
