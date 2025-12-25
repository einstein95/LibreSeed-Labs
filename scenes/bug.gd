extends Node2D

var target: Vector2
var speed: float = 100


func _ready() -> void:
    position = Vector2(-5000 + (randi() % 100) * 50, -5000 + (randi() % 100) * 50)
    target = position

    var tween: Tween = create_tween()
    tween.set_loops()
    tween.tween_property($Sprite2D, "scale", Vector2(0.15, 0.15), 0.25)
    tween.tween_property($Sprite2D, "scale", Vector2(0.16, 0.16), 0.25)


func _process(delta: float) -> void:
    if position == target:
        if randi() % 2 == 0:
            target = Vector2(clamp(position.x + (-5 + (randi() % 11)) * 50, -5000, 5000), position.y)
        else:
            target = Vector2(position.x, clamp(position.y + (-5 + (randi() % 11)) * 50, -5000, 5000))
    position = position.move_toward(target, delta * speed)
