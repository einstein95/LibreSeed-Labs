extends Sprite2D

@export var pointing: VisibleOnScreenNotifier2D


func _ready() -> void:
    pointing.screen_entered.connect(_on_screen_entered)
    pointing.screen_exited.connect(_on_screen_exited)
    pointing.tree_exiting.connect(_on_pointing_tree_exiting)

    modulate.a = 0
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 1, 0.4)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "offset:y", -64, 0.4)
    tween.tween_property(self, "offset:y", 0, 0.4)
    tween.set_loops()


func _process(delta: float) -> void:
    var screen_center: Vector2 = get_parent().size / 2
    var target_screen_pos: Vector2 = pointing.global_position - Globals.camera_center + screen_center
    var direction: Vector2 = (target_screen_pos - screen_center).normalized()

    var aspect_ratio = get_parent().size.x / get_parent().size.y
    var edge_pos: Vector2 = screen_center
    if abs(direction.x / aspect_ratio) > abs(direction.y):
        edge_pos.x += (screen_center.x) * sign(direction.x)
        edge_pos.y += (screen_center.x) * (direction.y / direction.x) * sign(direction.x)
    else:
        edge_pos.y += (screen_center.y) * sign(direction.y)
        edge_pos.x += (screen_center.y) * (direction.x / direction.y) * sign(direction.y)

    edge_pos.x = clamp(edge_pos.x, 32, get_parent().size.x - 32)
    edge_pos.y = clamp(edge_pos.y, 32, get_parent().size.y - 32)

    position = edge_pos
    rotation = direction.angle() + PI * 1 / 2


func _on_screen_entered() -> void:
    visible = false
    set_process(false)


func _on_screen_exited() -> void:
    visible = true
    set_process(true)


func _on_pointing_tree_exiting() -> void:
    queue_free()
