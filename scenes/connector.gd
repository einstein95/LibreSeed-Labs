class_name Connector extends Node2D

const OFFSET: float = 25
const EXTENSION: float = 45

@onready var glow := $Glow
@onready var pivot := $Pivot

var output_id: String
var input_id: String
var output: ResourceContainer
var input: ResourceContainer
var output_point: Node2D
var input_point: Node2D
var color: Color
var pivot_pos: Vector2:
    set(p):
        pivot_pos = p
        update_points()
var has_pivot: bool
var pulse_tween: Tween

var progress: float
var points: Array[Vector2]
var length_share: Array[float]
var thresholds: Array[float]
var rid: RID


func _enter_tree() -> void:
    rid = RenderingServer.canvas_item_create()
    RenderingServer.canvas_item_set_parent(rid, get_canvas_item())


func _ready() -> void:
    Signals.tool_set.connect(_on_tool_set)
    Signals.selection_set.connect(_on_selection_set)
    Signals.connection_deleted.connect(_on_connection_deleted)
    Signals.highlight_connection.connect(_on_highlight_connection)

    output = Globals.desktop.get_resource(output_id)
    input = Globals.desktop.get_resource(input_id)
    var output_connector: ConnectorButton = output.get_node("OutputConnector")
    var input_connector: ConnectorButton = input.get_node("InputConnector")
    input.pulse.connect(_on_pulse)

    output_point = output_connector.get_node("%Connector")
    input_point = input_connector.get_node("%Connector")

    if has_pivot:
        pivot.add_to_group("pivot")

    glow.visible = false
    color = Color(Data.connectors[output_connector.get_connector_color()].color)
    glow.texture = Resources.icons[(output_connector.get_connector_icon(true))]
    glow.self_modulate = color
    pivot.self_modulate = color

    if output.paused or input.paused:
        modulate = Color(0.5, 0.5, 0.5)
    else:
        modulate = Color(1, 1, 1)

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_method(set_progress, 0.0, 1.0, 0.4)

    update_points()


func draw_update() -> void:
    if rid:
        RenderingServer.canvas_item_clear(rid)
        for i: int in (points.size() - 1):
            var segment_start: float = 0.0 if i == 0 else thresholds[i - 1]

            if progress >= thresholds[i]:
                RenderingServer.canvas_item_add_line(rid, points[i], points[i + 1], color, 2, true)
            elif progress > segment_start:
                var segment_length: float = thresholds[i] - segment_start
                var factor: float = (progress - segment_start) / segment_length
                RenderingServer.canvas_item_add_line(rid, points[i], points[i].lerp(points[i + 1], factor), color, 2, true)
                break
            else:
                break


func update_points() -> void:
    if !is_node_ready():
        return

    if pulse_tween and pulse_tween.is_valid():
        pulse_tween.kill()
        glow.visible = false

    points.clear()
    length_share.clear()
    thresholds.clear()

    var start_pos: Vector2 = output_point.global_position
    var end_pos: Vector2 = input_point.global_position
    var fixed_point: Vector2 = input_point.global_position - Vector2(45, 0)

    if has_pivot:
        fixed_point = pivot_pos
    elif input_point.global_position >= output_point.global_position:
        fixed_point = input_point.global_position - Vector2(45, 0)
    else:
        fixed_point = Vector2(output_point.global_position.x + 45, input_point.global_position.y)

    var start_beyond_pivot: bool = start_pos.x + OFFSET >= fixed_point.x
    var pivot_beyond_end: bool = fixed_point.x + OFFSET >= end_pos.x
    var end_beyond_pivot: bool = end_pos.x >= fixed_point.x
    var pivot_in_range: bool = fixed_point.x >= start_pos.x

    if start_beyond_pivot and pivot_beyond_end:
        add_horizontal_path(start_pos, fixed_point.y, end_pos)
    elif start_beyond_pivot and end_beyond_pivot:
        add_extended_pivot_path(start_pos, fixed_point, end_pos)
    elif pivot_in_range and pivot_beyond_end:
        var start_below_pivot: bool = start_pos.y >= fixed_point.y + OFFSET
        var end_at_or_above_pivot: bool = end_pos.y >= fixed_point.y + OFFSET
        var pivot_above_start: bool = fixed_point.y >= start_pos.y
        var pivot_above_end: bool = fixed_point.y >= end_pos.y

        if start_below_pivot and end_at_or_above_pivot:
            if end_pos.y >= start_pos.y:
                add_extended_pivot_path(start_pos, fixed_point, end_pos)
            else:
                add_reverse_extended_path(start_pos, fixed_point, end_pos)
        elif pivot_above_start and pivot_above_end:
            if end_pos.y >= start_pos.y:
                add_reverse_extended_path(start_pos, fixed_point, end_pos)
            else:
                add_extended_pivot_path(start_pos, fixed_point, end_pos)
        else:
            add_pivot_path(start_pos, fixed_point, end_pos)
    else:
        var both_above_pivot: bool = start_pos.y >= fixed_point.y and end_pos.y >= fixed_point.y
        var pivot_above_both: bool = fixed_point.y >= end_pos.y

        if both_above_pivot or pivot_above_both:
            add_reverse_extended_path(start_pos, fixed_point, end_pos)
        else:
            points.append(start_pos)
            points.append(Vector2(fixed_point.x, start_pos.y))
            points.append(Vector2(fixed_point.x, end_pos.y))
            points.append(end_pos - Vector2(EXTENSION, 0))
            points.append(end_pos)

    var segment_lengths: Array[float]
    var total_length: float

    for i: int in (points.size() - 1):
        var length: float = points[i].distance_to(points[i + 1])
        segment_lengths.append(length)
        total_length += length

    var cumulative_length: float
    for length: float in segment_lengths:
        cumulative_length += length
        thresholds.append(cumulative_length / total_length)
        length_share.append(length / total_length)

    if has_pivot:
        pivot.position = pivot_pos - Vector2(25, 25)
    else:
        pivot.position = fixed_point - Vector2(25, 25)
    pivot.visible = get_pivot_visibility()
    draw_update()


func set_progress(p: float) -> void:
    progress = p
    draw_update()


func get_pivot_visibility() -> bool:
    return has_pivot or Globals.editing_connection


func _on_pulse() -> void:
    if glow.visible:
        return

    glow.global_position = points[0] - Vector2(12, 12)
    glow.visible = true
    pulse_tween = create_tween()
    pulse_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
    for i: int in (points.size() - 1):
        pulse_tween.tween_property(glow, "global_position", points[i + 1] - Vector2(12, 12), 0.5 * length_share[i])
    pulse_tween.finished.connect(_on_glow_tween_finished)


func _on_glow_tween_finished() -> void:
    glow.visible = false


func _on_control_gui_input(event: InputEvent) -> void:
    if Globals.tool == Utils.tools.MOVE:
        Signals.movement_input.emit(event, pivot.global_position)
        return

    if event is InputEventScreenTouch:
        if event.index >= 1:
            Signals.movement_input.emit(event, pivot.global_position)
            return
        if event.is_pressed():
            has_pivot = true
            pivot.scale = Vector2(1.2, 1.2)
            Globals.dragging = true
            Signals.dragging_set.emit()

            Sound.play("connector")
            glow.visible = false

            if !pivot.is_in_group("pivot"):
                pivot.add_to_group("pivot")
        else:
            pivot.scale = Vector2(1, 1)
            Sound.play("connect")
            Globals.dragging = false
            Signals.dragging_set.emit()
    elif event is InputEventScreenDrag:
        var new_pos: Vector2 = get_global_mouse_position().snappedf(25)
        if absf(new_pos.y - input_point.global_position.y) < 25:
            new_pos = Vector2(new_pos.x, input_point.global_position.y)
        elif absf(new_pos.y - output_point.global_position.y) < 25:
            new_pos = Vector2(new_pos.x, output_point.global_position.y)

        if Globals.connector_selection.has(pivot):
            if new_pos != pivot_pos:
                Signals.move_connectors.emit(new_pos - pivot_pos)
        else:
            pivot_pos = new_pos
    else:
        Signals.movement_input.emit(event, pivot.global_position)


func _on_pivot_mouse_entered() -> void:
    Signals.highlight_connection.emit(input)
    pivot.scale = Vector2(1.2, 1.2)


func _on_pivot_mouse_exited() -> void:
    Signals.highlight_connection.emit(null)
    pivot.scale = Vector2(1, 1)


func _on_tool_set() -> void:
    pivot.visible = get_pivot_visibility()


func _on_selection_set() -> void:
    if Globals.connector_selection.has(pivot):
        if Signals.move_connectors.is_connected(_on_move_connectors):
            return

        Signals.move_connectors.connect(_on_move_connectors)
    else:
        if !Signals.move_connectors.is_connected(_on_move_connectors):
            return

        Signals.move_connectors.disconnect(_on_move_connectors)


func _on_move_connectors(offset: Vector2) -> void:
    pivot_pos += offset


func _on_highlight_connection(resource: ResourceContainer) -> void:
    if resource:
        if resource == output or output.outputs.has(resource):
            modulate = Color(1, 1, 1)
            z_index = 1
        else:
            modulate = Color(0.5, 0.5, 0.5)
            z_index = 0
    else:
        modulate = Color(1, 1, 1)
        z_index = 0


func add_horizontal_path(from_pos: Vector2, to_x: float, then_to: Vector2) -> void:
    points.append(from_pos)
    points.append(from_pos + Vector2(EXTENSION, 0))
    points.append(Vector2(from_pos.x + EXTENSION, to_x))
    points.append(Vector2(then_to.x - EXTENSION, to_x))
    points.append(then_to - Vector2(EXTENSION, 0))
    points.append(then_to)


func add_pivot_path(from_pos: Vector2, pivot: Vector2, to_pos: Vector2) -> void:
    points.append(from_pos)
    points.append(Vector2(pivot.x, from_pos.y))
    points.append(pivot)
    points.append(Vector2(pivot.x, to_pos.y))
    points.append(to_pos)


func add_extended_pivot_path(from_pos: Vector2, pivot: Vector2, to_pos: Vector2) -> void:
    points.append(from_pos)
    points.append(from_pos + Vector2(EXTENSION, 0))
    points.append(Vector2(from_pos.x + EXTENSION, pivot.y))
    points.append(pivot)
    points.append(Vector2(pivot.x, to_pos.y))
    points.append(to_pos)


func add_reverse_extended_path(from_pos: Vector2, pivot: Vector2, to_pos: Vector2) -> void:
    points.append(from_pos)
    points.append(Vector2(pivot.x, from_pos.y))
    points.append(pivot)
    points.append(Vector2(to_pos.x - EXTENSION, pivot.y))
    points.append(to_pos - Vector2(EXTENSION, 0))
    points.append(to_pos)


func _on_connection_deleted(output: String, input: String) -> void:
    if input == input_id:
        visible = false
        set_process(false)
        queue_free()


func _exit_tree() -> void:
    RenderingServer.free_rid(rid)


func save() -> Dictionary:
    return {
        "pivot_pos": pivot_pos,
        "has_pivot": has_pivot
    }
