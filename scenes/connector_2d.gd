extends Line2D

var output: ResourceContainer
var input: ResourceContainer
var output_connector: Node2D
var input_connector: Node2D
var color: Color

var progress: float


func _ready() -> void :
    Signals.window_moved.connect(_on_window_moved)
    Signals.delete_connection.connect(_on_delete_connection)

    output_connector = output.get_node("%Connector")
    input_connector = input.get_node("%Connector")

    default_color = Color(Data.resources[output.resource].color)

    var tween: Tween = create_tween()
    tween.tween_method(set_progress, 0.0, 1.0, 0.5)


func _process(delta: float) -> void :
    set_point_position(0, Vector2(output_connector.global_position))
    set_point_position(1, Vector2(output_connector.global_position) + Vector2(50, 0))
    set_point_position(2, Vector2(output_connector.global_position.x + 50, input_connector.global_position.y))
    set_point_position(3, Vector2(input_connector.global_position))
    set_process(false)


func set_progress(p: float) -> void :
    progress = p
    modulate.a = progress
    queue_redraw()


func _on_window_moved(window: Control) -> void :
    set_process(true)


func _on_delete_connection(from: NodePath, to: NodePath) -> void :
    if from.is_empty() or to.is_empty(): return
    if get_node(from) == output and get_node(to) == input:
        queue_free()
        visible = false
