extends WindowIndexed

@onready var collect_button := $CollectButton

var collecting: Array[ResourceContainer]


func _ready() -> void:
    super ()
    Signals.tutorial_step.connect(_on_tutorial_step)

    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        i.resource_set.connect(_on_resource_set)

    if !Globals.tutorial_done and Globals.tutorial_step <= Utils.tutorial_steps.ADD_COLLECTOR:
        Globals.set_tutorial_step(Utils.tutorial_steps.ADD_COLLECTOR + 1)
        position = Vector2(300, 200)

    update_valid_inputs()
    update_visible_inputs()
    update_tutorial()


func process(delta: float) -> void:
    super (delta)

    collect_button.disabled = true
    for i: ResourceContainer in collecting:
        Globals.currency_production[i.resource] += i.production
        if floorf(i.count) > 0:
            collect_button.disabled = false


func update_valid_inputs() -> void:
    collecting.clear()
    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if !i.resource.is_empty():
            collecting.append(i)


func update_visible_inputs() -> void:
    var has_free_input: bool = false

    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if !i.get_node("InputConnector").has_connection():
            has_free_input = true
            break

    var shown_invalid: bool = false
    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if i.get_node("InputConnector").has_connection():
            i.visible = true
        else:
            i.visible = !shown_invalid
            shown_invalid = true

    Signals.window_moved.emit(self)


func update_tutorial() -> void:
    if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_MONEY:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($"PanelContainer/MainContainer/Input/InputConnector")

    if Globals.tutorial_done:
        can_select = true
        can_drag = true
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
    else:
        can_select = false
        can_drag = false
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        i.get_node("InputConnector").disabled = !Globals.tutorial_done and Globals.tutorial_step != Utils.tutorial_steps.CONNECT_MONEY


func _on_resource_set() -> void:
    update_valid_inputs()


func _on_collect_button_pressed() -> void:
    for i: ResourceContainer in collecting:
        Globals.currencies[i.resource] += i.pop_all()

    Sound.play("cash_register")


func _on_connection_set() -> void:
    update_visible_inputs()
    if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_MONEY:
        Globals.set_tutorial_step(Utils.tutorial_steps.CONNECT_MONEY + 1)


func _on_tutorial_step() -> void:
    update_tutorial()
