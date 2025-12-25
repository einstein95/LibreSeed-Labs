extends GPUParticles2D

var target: Control
var starting_pos: Vector2


func _ready() -> void:
    emitting = true

    var tween: Tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "global_position", starting_pos, 1.3)
    tween.tween_property(self, "global_position", target.global_position + target.size / 2, 0.5)
