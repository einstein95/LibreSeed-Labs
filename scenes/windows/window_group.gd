extends WindowContainer

const colors: Array[String] = ["1a202c", "1a2b22", "1a292b", "1a1b2b", "211a2b", "2b1a27", "2b1a1a"]

var delta_pos: Vector2
var moving_windows: Array[WindowContainer]
var moving_connectors: Array[Node2D]
var color: int
var last_mouse_position: Vector2
var resizing_left: bool
var resizing_right: bool
var resizing_top: bool
var resizing_bottom: bool


func _ready() -> void :
    super ()

    update_color()


func _process(delta: float) -> void :
    super (delta)
    if resizing_left or resizing_right or resizing_top or resizing_bottom:
        var delta_pos: Vector2 = get_global_mouse_position().snappedf(50) - last_mouse_position
        last_mouse_position = get_global_mouse_position().snappedf(50)

        var new_rect: Rect2 = Rect2(position, size)

        if resizing_left:
            new_rect.position.x += delta_pos.x
            new_rect.size.x -= delta_pos.x
        if resizing_right:
            new_rect.size.x += delta_pos.x
        if resizing_top:
            new_rect.position.y += delta_pos.y
            new_rect.size.y -= delta_pos.y
        if resizing_bottom:
            new_rect.size.y += delta_pos.y

        size = new_rect.size.clamp(Vector2(200, 100), Vector2.INF)
        position = new_rect.position


func move(pos: Vector2) -> void :
    var last_pos: Vector2 = global_position
    super (pos)

    for i: WindowContainer in moving_windows:
        i.move(i.global_position - (last_pos - global_position))
    for i: Node2D in moving_connectors:
        i.pivot_pos = i.pivot_pos - (last_pos - global_position)


func grab(g: bool) -> void :
    super (g)
    if g:
        for i: WindowContainer in get_tree().get_nodes_in_group("window"):
            if i != self and get_rect().encloses(i.get_rect()):
                moving_windows.append(i)
        for i: Control in get_tree().get_nodes_in_group("pivot"):
            if get_rect().encloses(i.get_rect()):
                moving_connectors.append(i.get_parent())
    else:
        moving_windows.clear()
        moving_connectors.clear()


func set_resizing(l: bool, t: bool, r: bool, b: bool) -> void :
    resizing_left = l
    resizing_top = t
    resizing_right = r
    resizing_bottom = b
    last_mouse_position = get_global_mouse_position().snappedf(50)

    Globals.dragging = resizing_left or resizing_top or resizing_right or resizing_bottom
    Signals.dragging_set.emit()


func update_color() -> void :
    $TitlePanel.self_modulate = Color(colors[color])
    $PanelContainer.self_modulate = Color(colors[color])


func cycle_color() -> void :
    color += 1
    if color >= colors.size():
        color = 0
    update_color()


func _on_selection_set() -> void :
    super ()
    top_level = Globals.selections.has(self)
    $PanelContainer / Control / ExpandButtons.visible = Globals.selections.has(self)


func _on_top_left_button_down() -> void :
    set_resizing(true, true, false, false)


func _on_top_left_button_up() -> void :
    set_resizing(false, false, false, false)


func _on_top_button_down() -> void :
    set_resizing(false, true, false, false)


func _on_top_button_up() -> void :
    set_resizing(false, false, false, false)


func _on_top_right_button_down() -> void :
    set_resizing(false, true, true, false)


func _on_top_right_button_up() -> void :
    set_resizing(false, false, false, false)


func _on_left_button_down() -> void :
    set_resizing(true, false, false, false)


func _on_left_button_up() -> void :
    set_resizing(false, false, false, false)


func _on_bottom_left_button_down() -> void :
    set_resizing(true, false, false, true)


func _on_bottom_left_button_up() -> void :
    set_resizing(false, false, false, false)


func _on_bottom_button_down() -> void :
    set_resizing(false, false, false, true)


func _on_bottom_button_up() -> void :
    set_resizing(false, false, false, false)


func _on_bottom_right_button_down() -> void :
    set_resizing(false, false, true, true)


func _on_bottom_right_button_up() -> void :
    set_resizing(false, false, false, false)


func _on_right_button_down() -> void :
    set_resizing(false, false, true, false)


func _on_right_button_up() -> void :
    set_resizing(false, false, false, false)


func save() -> Dictionary:
    return super ().merged({
        "size": size, 
        "color": color
    })
