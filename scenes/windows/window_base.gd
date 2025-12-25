class_name WindowBase extends WindowContainer

var containers: Array[ResourceContainer]
var container_data: Dictionary
var paused: bool


func _enter_tree() -> void:
    super ()
    theme = load("res://themes/" + Data.themes[Data.cur_theme].file + ".tres")

    for i: Node in find_children("*"):
        if i.is_in_group("persistent_container"):
            containers.append(i)

    if !container_data.is_empty():
        for container: String in container_data:
            var new_object: ResourceContainer = get_node_or_null(container)
            if new_object:
                init_count += 1
                new_object.initialized.connect(func() -> void:
                    for key: String in container_data[container]:
                        new_object.set(key, container_data[container][key])
                    init_count -= 1
                    if init_count <= 0:
                        initialized.emit()
                )


func _ready() -> void:
    set_ticking(!paused)
    Signals.tick.connect(_on_tick)
    super ()

    set_window_name(get_window_name())
    container_data.clear()


func process(delta: float) -> void:
    pass


func close() -> void:
    set_ticking(false)
    super ()


func toggle_pause() -> void:
    paused = !paused
    set_ticking(!paused)


func process_set(enabled: bool) -> void:
    super (enabled)
    for i: ResourceContainer in containers:
        i.process_set(enabled)
    if enabled:
        set_deferred("size:y", 0)


func set_ticking(enabled: bool) -> void:
    if enabled:
        modulate = Color(1, 1, 1)
    else:
        modulate = Color(0.7, 0.7, 0.7)
    for i: ResourceContainer in containers:
        i.set_ticking(enabled)


func set_window_name(new_name: String) -> void:
    $TitlePanel/TitleContainer/Title.text = new_name
    $TitlePanel/TitleContainer/Title.add_theme_font_size_override("font_size", min(26, snappedi(26 - (new_name.length() - 20), 2)))


func get_window_name() -> String:
    return $TitlePanel/TitleContainer/Title.text


func get_guide() -> String:
    return ""


func _on_tick() -> void:
    if !paused:
        process(0.05 * Attributes.get_attribute("time_multiplier") * Attributes.get_attribute("offline_time_multiplier"))


func _on_selection_set() -> void:
    super ()
    if Globals.selections.has(self):
        size.y = 0


func export() -> Dictionary:
    var container_data: Dictionary

    for i: ResourceContainer in containers:
        container_data[str(get_path_to(i))] = i.export()

    return super ().merged({
        "container_data": container_data
    })


func save() -> Dictionary:
    var container_data: Dictionary

    for i: ResourceContainer in containers:
        container_data[str(get_path_to(i))] = i.save()

    return super ().merged({
        "paused": paused,
        "container_data": container_data
    })
