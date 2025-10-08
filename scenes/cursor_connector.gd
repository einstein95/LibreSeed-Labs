extends Node2D

var from_connector: Node2D
var is_input: bool
var color: Color


func _ready() -> void :
    Signals.connection_set.connect(_on_connection_set)

    set_process(false)


func _process(delta: float) -> void :
    queue_redraw()


func _draw() -> void :
    var point_x: float
    if is_input:
        point_x = from_connector.global_position.x - 45
    else:
        point_x = from_connector.global_position.x + 45
    draw_line(from_connector.global_position, Vector2(point_x, from_connector.global_position.y), color, 2, true)
    draw_line(Vector2(point_x, from_connector.global_position.y), Vector2(point_x, get_global_mouse_position().y), color, 2, true)
    draw_line(Vector2(point_x, get_global_mouse_position().y), get_global_mouse_position(), color, 2, true)


func _on_connection_set() -> void :
    set_process(Globals.connection_type > 0)
    visible = Globals.connection_type > 0

    if Globals.connection_type > 0:
        var container: ResourceContainer = Globals.desktop.get_resource(Globals.connecting)
        if Globals.connection_type == 1:
            from_connector = container.get_node("OutputConnector/Connector")
            is_input = false
        elif Globals.connection_type == 2:
            from_connector = container.get_node("InputConnector/Connector")
            is_input = true

        color = Color(Data.connectors[container.get_connector_color()].color)
