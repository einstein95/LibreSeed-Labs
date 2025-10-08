extends Sprite2D

var following: Control


func _ready() -> void :
    Signals.interface_point_to.connect(_on_interface_point_to)

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "offset:y", -480, 0.4)
    tween.tween_property(self, "offset:y", -320, 0.4)
    tween.set_loops()

    set_process(false)


func _process(delta: float) -> void :
    visible = following.is_visible_in_tree()
    global_position = following.global_position + Vector2(following.size.x / 2 * Data.scale, 0)


func _on_interface_point_to(node: Control) -> void :
    following = node
    visible = is_instance_valid(following)
    set_process(is_instance_valid(following))
