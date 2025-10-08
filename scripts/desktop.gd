class_name Desktop extends Control

var heatspot: Vector2
var heatspot_volume: float
var resources: Dictionary
var connections: Dictionary


func _enter_tree() -> void :
    Globals.desktop = self
    Signals.register_resource.connect(_on_register_resource)

    if Globals.tutorial_done:
        if !Data.loading.is_empty():
            add_windows_from_data(Data.loading.windows)
    else:
        var instance: WindowBase = load("res://scenes/windows/window_network.tscn").instantiate()
        instance.position = Vector2(-575, -100)
        instance.name = "Network"
        $Windows.add_child(instance)

        instance = load("res://scenes/windows/window_download_text.tscn").instantiate()
        instance.position = Vector2(-175, -100)
        instance.name = "Downloader"
        $Windows.add_child(instance)

        instance = load("res://scenes/windows/window_bin.tscn").instantiate()
        instance.position = Vector2(225, -100)
        instance.name = "Bin"
        $Windows.add_child(instance)


func _ready() -> void :
    Signals.screen_transition_started.connect(_on_screen_transition_started)
    Signals.screen_transition_finished.connect(_on_screen_transition_finished)
    Signals.create_window.connect(_on_create_window)
    Signals.window_created.connect(_on_window_created)
    Signals.window_deleted.connect(_on_window_deleted)
    Signals.place_schematic.connect(_on_place_schematic)
    Signals.tutorial_step.connect(_on_tutorial_step)
    Signals.dragging_set.connect(_on_dragging_set)
    Signals.selection_set.connect(_on_selection_set)
    Signals.tool_set.connect(_on_tool_set)

    if Globals.platform == 2 or Globals.platform == 3:
        $AdTimer.start(360)

    update_heatspot()
    Signals.desktop_ready.emit()

    if !Globals.tutorial_done:
        Signals.create_connection.emit($ / root / Main / Main2D / Desktop / Windows / Downloader / PanelContainer / MainContainer / File.id, 
        $ / root / Main / Main2D / Desktop / Windows / Bin / PanelContainer / MainContainer / Input.id)

    $Background.color = Color(Data.themes[Data.cur_theme].bg_color)
    Data.loading.clear()


func _input(event: InputEvent) -> void :
    if event is InputEventKey and event.is_released():
        if Input.is_key_pressed(KEY_CTRL):
            if event.keycode == KEY_C and Globals.selections.size() > 0:
                var file: ConfigFile = ConfigFile.new()
                var data: Dictionary = copy(Globals.selections)
                file.set_value("schematic", "windows", data.windows)
                file.set_value("schematic", "connectors", data.connectors)
                file.set_value("schematic", "rect", data.rect)
                DisplayServer.clipboard_set(file.encode_to_text())
            elif event.keycode == KEY_V:
                var data: String = DisplayServer.clipboard_get()
                var file: ConfigFile = ConfigFile.new()
                if file.parse(data) == OK:
                    if !file.has_section("schematic"): return
                    if !file.has_section_key("schematic", "windows"): return
                    if !file.has_section_key("schematic", "connectors"): return
                    var dictionary: Dictionary = {
                        "windows": file.get_value("schematic", "windows"), 
                        "connectors": file.get_value("schematic", "connectors"), 
                        "rect": file.get_value("schematic", "rect")
                    }
                    paste(dictionary.duplicate(true))


func add_windows_from_data(data: Dictionary) -> WindowsWaiter:
    var windows: Array[WindowContainer]

    for window: String in data:
        if !ResourceLoader.exists("res://scenes/windows/" + data[window].filename): continue
        var new_object: Control = get_node_or_null("Desktop/Windows/" + window)
        if !new_object:
            new_object = load("res://scenes/windows/" + data[window].filename).instantiate()
            for key: String in data[window]:
                new_object.set(key, data[window][key])
            new_object.name = window
            $Windows.add_child(new_object)
        else:
            new_object.name = window
            for key: String in data[window]:
                new_object.set(key, data[window][key])

    return WindowsWaiter.new(windows)


func copy(windows: Array[WindowContainer]) -> Dictionary:
    var dict: Dictionary = {"windows": {}, "connectors": {}}
    var rect: Rect2 = Rect2(INF, INF, 0, 0)
    var connections: Dictionary

    for window: WindowContainer in windows:
        rect.position.x = min(rect.position.x, window.position.x)
        rect.position.y = min(rect.position.y, window.position.y)
        rect.size.x = max(rect.size.x, (window.position.x + window.size.x) - rect.position.x)
        rect.size.y = max(rect.size.y, (window.position.y + window.size.y) - rect.position.y)
        for resource: ResourceContainer in window.containers:
            connections[resource.id] = resource.outputs_id

    for window: WindowContainer in windows:
        if !window.can_export: continue
        var data: Dictionary = window.export()
        dict["windows"][str(window.name)] = data
        for resource: String in data.container_data:
            var new_outputs: Array[String]
            for output: String in data.container_data[resource].outputs_id:
                if connections.has(output):
                    new_outputs.append(output)
            data.container_data[resource].outputs_id = new_outputs

    for connector: Connector in $Connectors.get_children():
        if connections.has(connector.input_id):
            dict["connectors"][connector.input_id] = connector.save()

    dict["rect"] = rect

    return dict


func paste(data: Dictionary) -> void :
    var seed: int = randi() / 10
    var new_windows: Dictionary
    var to_connect: Dictionary[String, Array]
    for window: String in data.windows:
        if !Utils.can_add_window(data.windows[window].window): continue

        for resource: String in data.windows[window].container_data:
            var new_name: String = Utils.generate_id_from_seed(data.windows[window].container_data[resource].id.hash() + seed)
            data.windows[window].container_data[resource].id = new_name
            data.windows[window].container_data[resource].erase("count")
            data.windows[window].container_data[resource].erase("variation")
            data.windows[window].container_data[resource].erase("resource")
            to_connect[new_name] = []
            for output: String in data.windows[window].container_data[resource].outputs_id:
                to_connect[new_name].append(Utils.generate_id_from_seed(output.hash() + seed))
            data.windows[window].container_data[resource].outputs_id.clear()

        var new_name: String = find_window_name(window)
        new_windows[new_name] = data.windows[window].duplicate()
        new_windows[new_name].position -= data.rect.position - Globals.camera_center.snappedf(50) + (data.rect.size / 2)

    data.windows = new_windows
    add_windows_from_data(data.windows)

    for i: String in data.connectors:
        var new_id: String = Utils.generate_id_from_seed(i.hash() + seed)
        data.connectors[i].pivot_pos -= data.rect.position - Globals.camera_center.snappedf(50) + (data.rect.size / 2)
        $Connectors.connector_data[new_id] = data.connectors[i]

    for i: String in to_connect:
        for output: String in to_connect[i]:
            Signals.create_connection.emit(i, output)

    $Connectors.connector_data.clear()


func update_heatspot() -> void :
    var sum: Vector2
    for i: WindowContainer in $Windows.get_children():
        sum += i.position
    heatspot = sum / $Windows.get_child_count()
    heatspot_volume = linear_to_db(min(0.8, 0.01 + 0.12 * Globals.max_window_count))

    $AmbiencePlayer.position = heatspot
    $AmbiencePlayer.volume_db = heatspot_volume
    $AmbiencePlayer.max_distance = 2000 * (0.02 * Globals.max_window_count + 1)


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.MOVE_UPLOADER:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($TutorialPoint)


func get_blocker_visibility() -> bool:
    if Globals.cur_screen == 0 and Globals.tool == Utils.tools.SELECT: return true

    return false


func get_resource(id: String) -> ResourceContainer:
    if resources.has(id):
        return resources[id]
    else:
        return null


func _on_create_window(window: WindowContainer) -> void :








































    window.name = find_window_name(str(window.name))



    $Windows.add_child(window)

    Sound.play("open")


func _on_register_resource(id: String, resource: ResourceContainer) -> void :
    var new_id: String = id
    while resources.has(new_id):
        new_id = Utils.generate_simple_id()
    resources[new_id] = resource

    if id != new_id:
        Signals.resource_renamed.emit(id, new_id)
func find_window_name(cur_name: String) -> String:
    var id: int
    while $Windows.has_node(cur_name + str(id)):
        id += 1

    return cur_name + str(id)


func _on_window_created(window: WindowContainer) -> void :
    update_heatspot()


func _on_window_deleted(window: WindowContainer) -> void :
    update_heatspot()


func _on_place_schematic(schematic: String) -> void :
    paste(Data.schematics[schematic].duplicate(true))


func _on_token_timer_timeout() -> void :
    var token: Node2D = load("res://scenes/wandering_token.tscn").instantiate()
    $Spawnables.add_child(token)


func _on_bank_timer_timeout() -> void :
    if Globals.window_count["breach_bank"] == 0:
        var bank: Node2D = load("res://scenes/wandering_bank.tscn").instantiate()
        $Spawnables.add_child(bank)


func _on_ad_timer_timeout() -> void :
    var token: Node2D = load("res://scenes/wandering_ad.tscn").instantiate()
    $Spawnables.add_child(token)


func _on_selection_set() -> void :
    for i: WindowContainer in Globals.selections:
        var selection: PanelContainer = load("res://scenes/window_selection.tscn").instantiate()
        selection.selection = i
        $WindowSelections.add_child(selection)
    for i: Control in Globals.connector_selection:
        var selection: PanelContainer = load("res://scenes/connector_selection.tscn").instantiate()
        selection.selection = i
        $WindowSelections.add_child(selection)


func _on_tool_set() -> void :
    $InputBlocker.visible = get_blocker_visibility()


func _on_dragging_set() -> void :
    update_heatspot()


func _on_tutorial_step() -> void :
    update_tutorial()


func _on_screen_transition_started() -> void :
    if Globals.cur_screen == 0:
        var tween: Tween = create_tween()
        tween.tween_property($AmbiencePlayer, "volume_db", -40, 0.5)
    $InputBlocker.visible = true


func _on_screen_transition_finished() -> void :
    if Globals.cur_screen == 0:
        var tween: Tween = create_tween()
        tween.tween_property($AmbiencePlayer, "volume_db", heatspot_volume, 0.5)
    $InputBlocker.visible = get_blocker_visibility()
