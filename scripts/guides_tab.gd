extends VBoxContainer

var cur_category: int


func _ready() -> void:
    Signals.open_guide.connect(_on_open_guide)

    set_category(0)


func set_category(category: int, focus: String = "") -> void:
    cur_category = category
    for i: Button in $Panel/ButtonsContainer.get_children():
        i.button_pressed = i.get_index() == cur_category

    for i: Control in $ScrollContainer/MarginContainer/GuidesContainer.get_children():
        i.queue_free()
        $ScrollContainer/MarginContainer/GuidesContainer.remove_child(i)

    for i: String in Data.guides:
        if int(Data.guides[i].type) != cur_category:
            continue

        var instance: VBoxContainer = preload("res://scenes/guide_panel.tscn").instantiate()
        instance.name = i
        instance.open = i == focus
        $ScrollContainer/MarginContainer/GuidesContainer.add_child(instance)

    if !focus.is_empty():
        $ScrollContainer.scroll_vertical = 80 * $ScrollContainer/MarginContainer/GuidesContainer.get_node(focus).get_index()


func _on_basics_pressed() -> void:
    set_category(0)
    Sound.play("click_toggle2")


func _on_nodes_pressed() -> void:
    set_category(1)
    Sound.play("click_toggle2")


func _on_open_guide(guide: String) -> void:
    if !Data.guides.has(guide):
        return

    if int(Data.guides[guide].type) == cur_category:
        var node: VBoxContainer = $ScrollContainer/MarginContainer/GuidesContainer.get_node(guide)
        node.expand()
        $ScrollContainer.scroll_vertical = 80 * node.get_index()
    else:
        set_category(int(Data.guides[guide].type), guide)
