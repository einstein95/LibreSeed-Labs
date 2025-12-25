extends Node2D

signal got_free(node: Node2D)

@onready var label := $Label


func _ready() -> void:
    visible = false


func display(text: String, pos: Vector2) -> void:
    label.text = text

    modulate.a = 0
    global_position = pos
    var tween: Tween = create_tween()
    tween.set_parallel(true)
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "global_position:y", pos.y - 50, 0.8)

    var alpha_tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    alpha_tween.tween_property(self, "modulate:a", 1, 0.2)
    alpha_tween.tween_property(self, "modulate:a", 1, 0.2)
    alpha_tween.tween_property(self, "modulate:a", 0, 0.41)
    alpha_tween.finished.connect(remove)

    show()


func remove() -> void:
    got_free.emit(self)
    hide()
