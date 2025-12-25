extends PanelContainer

var selection: Control


func _ready() -> void:
    selection.tree_exiting.connect(_on_selection_tree_exiting)
    Signals.selection_set.connect(_on_selection_set)

    var tween: Tween = create_tween()
    tween.set_loops()
    tween.tween_property(self, "self_modulate:a", 0.3, 0.7)
    tween.tween_property(self, "self_modulate:a", 1, 0.7)


func _process(delta: float) -> void:
    position = selection.position + Vector2(14, 14)
    scale = selection.scale


func _on_selection_set() -> void:
    queue_free()
    set_process(false)


func _on_selection_tree_exiting() -> void:
    queue_free()
    set_process(false)
