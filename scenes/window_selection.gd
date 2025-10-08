extends PanelContainer

var selection: WindowContainer
var last_mouse_position: Vector2
var resizing_left: bool
var resizing_right: bool
var resizing_top: bool
var resizing_bottom: bool


func _ready() -> void :
    selection.tree_exiting.connect(_on_selection_tree_exiting)
    Signals.selection_set.connect(_on_selection_set)

    var tween: Tween = create_tween()
    tween.set_loops()
    tween.tween_property(self, "self_modulate:a", 0.3, 0.7)
    tween.tween_property(self, "self_modulate:a", 1, 0.7)


func _process(delta: float) -> void :
    position = selection.position
    size = selection.size
    scale = selection.scale
    pivot_offset = size / 2


func _on_selection_set() -> void :
    queue_free()
    set_process(false)


func _on_selection_tree_exiting() -> void :
    queue_free()
    set_process(false)
