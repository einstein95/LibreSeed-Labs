extends Node2D

var stopped: bool
var dir: Vector2


func _ready() -> void :
    dir = Vector2([-1, 1].pick_random(), [-1, 1].pick_random())

    scale = Vector2(0, 0)
    modulate.a = 0
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_BOUNCE)
    tween.set_parallel()
    tween.tween_property(self, "modulate:a", 1, 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.2)


func _process(delta: float):
    if stopped: return

    position += dir * delta * 50
    if position.x >= get_parent().size.x - 24:
        dir.x = -1
    elif position.x - 24 <= 0:
        dir.x = 1
    if position.y >= get_parent().size.y - 24:
        dir.y = -1
    elif position.y - 24 <= 0:
        dir.y = 1
