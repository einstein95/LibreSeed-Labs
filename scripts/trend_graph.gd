extends Control

@export var max_points: int = 100
@export var line_color: Color = Color.CYAN
@export var background_color: Color = Color(0.1, 0.1, 0.1, 0.8)
@export var grid_color: Color = Color(0.3, 0.3, 0.3, 0.5)
@export var line_width: float = 2.0
@export var show_grid: bool = true

@export_group("Value Range")
@export var min_range: float = -100.0
@export var max_range: float = 100.0

var data_points: Array[float] = []
var canvas_item: RID

func _ready() -> void :
    canvas_item = RenderingServer.canvas_item_create()
    RenderingServer.canvas_item_set_parent(canvas_item, get_canvas_item())

    resized.connect(_on_resized)

    _update_graph()


func _on_resized() -> void :
    _update_graph()


func _draw_background() -> void :
    var bg_points: PackedVector2Array = PackedVector2Array([
        Vector2.ZERO, 
        Vector2(size.x, 0), 
        Vector2(size.x, size.y), 
        Vector2(0, size.y)
    ])

    var bg_colors: PackedColorArray = PackedColorArray([
        background_color, 
        background_color, 
        background_color, 
        background_color
    ])

    RenderingServer.canvas_item_add_polygon(
        canvas_item, 
        bg_points, 
        bg_colors
    )


func _draw_grid() -> void :
    if !show_grid: return

    var grid_lines: int = 10

    for i in range(grid_lines + 1):
        var x: float = (float(i) / float(grid_lines)) * size.x
        RenderingServer.canvas_item_add_line(
            canvas_item, 
            Vector2(x, 0), 
            Vector2(x, size.y), 
            grid_color, 
            1.0
        )

    for i in range(grid_lines + 1):
        var y: float = (float(i) / float(grid_lines)) * size.y
        RenderingServer.canvas_item_add_line(
            canvas_item, 
            Vector2(0, y), 
            Vector2(size.x, y), 
            grid_color, 
            1.0
        )


func _update_graph() -> void :
    if !canvas_item.is_valid(): return

    RenderingServer.canvas_item_clear(canvas_item)

    _draw_background()
    _draw_grid()

    if data_points.size() < 2: return

    var value_range: float = max_range - min_range

    if value_range <= 0: return

    for i: int in range(data_points.size() - 1):
        var current_point: Vector2 = _data_to_screen_position(i, data_points[i], value_range)
        var next_point: Vector2 = _data_to_screen_position(i + 1, data_points[i + 1], value_range)

        RenderingServer.canvas_item_add_line(
            canvas_item, 
            current_point, 
            next_point, 
            line_color, 
            line_width, 
            true
        )


func _data_to_screen_position(index: int, value: float, value_range: float) -> Vector2:
    var x: float = (float(index) / float(max(max_points - 1, 1))) * size.x

    var clamped_value: float = clampf(value, min_range, max_range)
    var normalized_value: float = (clamped_value - min_range) / value_range
    var y: float = size.y - (normalized_value * size.y)

    return Vector2(x, y)


func add_value(value: float) -> void :
    data_points.append(value)

    if data_points.size() > max_points:
        data_points.pop_front()

    _update_graph()

func add_values(values: Array[float]) -> void :
    for value: float in values:
        data_points.append(value)

    while data_points.size() > max_points:
        data_points.pop_front()

    _update_graph()


func get_range() -> Vector2:
    return Vector2(min_range, max_range)


func clear_data() -> void :
    data_points.clear()
    _update_graph()


func get_data_points() -> Array[float]:
    return data_points.duplicate()


func is_value_in_range(value: float) -> bool:
    return value >= min_range and value <= max_range


func get_value_at_screen_y(screen_y: float) -> float:
    var normalized_y = 1.0 - (screen_y / size.y)
    return min_range + (normalized_y * (max_range - min_range))


func get_latest_value() -> float:
    if data_points.is_empty(): return 0.0
    return data_points[-1]


func get_data_count() -> int:
    return data_points.size()


func _exit_tree() -> void :
    if canvas_item.is_valid():
        RenderingServer.free_rid(canvas_item)
