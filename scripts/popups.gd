extends ColorRect

var can_close: bool
var cur_popup: String


func _ready() -> void:
    Signals.popup.connect(_on_popup)


func popup() -> void:
    visible = true
    modulate.a = 0
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "modulate:a", 1, 0.2)


func set_popup(popup: String) -> void:
    if has_node(cur_popup):
        get_node(cur_popup).visible = false

    cur_popup = popup

    var node: Control = get_node(popup)
    node.move_to_front()
    node.visible = true
    node.pivot_offset = node.size / 2
    node.scale = Vector2(0, 0)
    node.modulate.a = 0
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_BOUNCE)
    tween.set_parallel()
    tween.tween_property(node, "modulate:a", 1, 0.2)
    tween.tween_property(node, "scale", Vector2(1, 1), 0.2)

    Sound.play("open")


func _on_popup(popup: String) -> void:
    if popup.is_empty():
        visible = false
        can_close = false
        return

    if !visible:
        popup()
        get_tree().create_timer(0.15).timeout.connect(func() -> void: can_close = true)

    set_popup(popup)


func _on_gui_input(event: InputEvent) -> void:
    if !can_close:
        return

    if event is InputEventMouseButton and event.is_released():
        Signals.popup.emit("")
        Sound.play("close")
