extends Control

var open: bool
var cur_tab: int = -1


func _ready() -> void :
    for i: Control in get_children():
        i.offset_right = size.x - 15
        i.offset_left = size.x


func toggle(toggled: bool, tab: int = cur_tab) -> void :
    if toggled:
        if tab != cur_tab:
            close_tab(cur_tab)
        cur_tab = tab
        open_tab(tab)
    else:
        close_tab(cur_tab)
    open = toggled


func open_tab(tab: int) -> void :
    var child: Control = get_child(tab)
    child.visible = true
    child.modulate.a = 0

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.set_parallel()
    tween.tween_property(child, "modulate:a", 1, 0.25)
    tween.tween_property(child, "position:x", 0, 0.25)
    tween.finished.connect( func() -> void : child.visible = true)


func close_tab(tab: int) -> void :
    var child: Control = get_child(tab)
    child.visible = true
    child.modulate.a = 1

    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.set_parallel()
    tween.tween_property(child, "position:x", size.x + 15, 0.25)
    tween.tween_property(child, "modulate:a", 0, 0.25)
    tween.finished.connect( func() -> void : child.visible = false)
