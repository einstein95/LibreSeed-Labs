extends Control

var needs_update: bool
var connector_data: Dictionary


func _enter_tree() -> void:
    Signals.connection_created.connect(_on_connection_created)
    Signals.boot.connect(_on_boot)

    if !Data.loading.is_empty():
        connector_data = Data.loading.connectors


func _ready() -> void:
    Signals.window_moved.connect(_on_window_moved)


func _process(delta: float) -> void:
    if needs_update:
        propagate_call("update_points")
        needs_update = false


func _on_connection_created(output: String, input: String) -> void:
    var connector: Connector = load("res://scenes/connector.tscn").instantiate()
    connector.output_id = output
    connector.input_id = input
    if connector_data.has(input):
        for i: String in connector_data[input]:
            connector.set(i, connector_data[input][i])
    add_child(connector)


func _on_boot() -> void:
    needs_update = true
    connector_data.clear()


func _on_window_moved(window: WindowContainer) -> void:
    needs_update = true


func _on_windows_child_entered_tree(node: Node) -> void:
    for i: int in 12:
        await (get_tree().physics_frame)
    needs_update = true
