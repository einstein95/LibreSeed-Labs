extends Control

var dragging: Vector2


func _ready() -> void:
    Signals.dragging_set.connect(_on_dragging_set)
    Signals.connection_set.connect(_on_connection_set)


func _process(delta: float) -> void:
    if Globals.dragging or Globals.connecting:
        if dragging.length() > 0:
            Signals.move_camera.emit(dragging * 400 * delta / Globals.camera_zoom)


func _on_up_drag_mouse_entered() -> void:
    dragging.y -= 1


func _on_up_drag_mouse_exited() -> void:
    dragging.y += 1


func _on_right_drag_mouse_entered() -> void:
    dragging.x += 1


func _on_right_drag_mouse_exited() -> void:
    dragging.x -= 1


func _on_left_drag_mouse_entered() -> void:
    dragging.x -= 1


func _on_left_drag_mouse_exited() -> void:
    dragging.x += 1


func _on_down_drag_mouse_entered() -> void:
    dragging.y += 1


func _on_down_drag_mouse_exited() -> void:
    dragging.y -= 1


func _on_dragging_set() -> void:
    visible = Globals.dragging or Globals.connecting


func _on_connection_set() -> void:
    visible = Globals.dragging or Globals.connecting
