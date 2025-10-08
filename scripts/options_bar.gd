extends PanelContainer


func _ready() -> void :
    Signals.tutorial_step.connect(_on_tutorial_step)
    Signals.screen_set.connect(_on_screen_set)
    Signals.selection_set.connect(_on_selection_set)

    update_buttons()
    update_tutorial()


func _process(delta: float) -> void :
    if !visible or get_viewport().gui_get_focus_owner(): return
    if Input.is_action_just_pressed("delete"):
        delete()


func update_buttons() -> void :
    $WindowOptions / Pause.visible = false
    $WindowOptions / Help.visible = Globals.selections.size() == 1 and !Globals.selections[0].help.is_empty()
    $WindowOptions / Color.visible = false
    $WindowOptions / Delete.visible = false

    var nodes_paused: int
    for i: WindowContainer in Globals.selections:
        if i.can_pause and i.paused:
            nodes_paused += 1
        $WindowOptions / Pause.visible = $WindowOptions / Pause.visible or i.can_pause
        $WindowOptions / Color.visible = $WindowOptions / Color.visible or i.has_colors
        $WindowOptions / Delete.visible = $WindowOptions / Delete.visible or i.can_delete

    if nodes_paused > 0:
        $WindowOptions / Pause.icon = load("res://textures/icons/play.png")
    else:
        $WindowOptions / Pause.icon = load("res://textures/icons/pause.png")


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.DELETE_BIN:
        Signals.desktop_point_to.emit(null)
        Signals.interface_point_to.emit($WindowOptions / Delete)


func delete() -> void :
    for i: WindowContainer in Globals.selections:
        if i.can_delete:
            if !i.closing:
                i.propagate_call("close")
    Sound.play("close")
    Globals.set_selection([], [], 0)


func _on_pause_pressed() -> void :
    for i: WindowContainer in Globals.selections:
        if i.can_pause:
            i.toggle_pause()
    update_buttons()
    Sound.play("click2")


func _on_save_pressed() -> void :
    var data: Dictionary = Globals.desktop.copy(Globals.selections)
    Signals.save_schematic.emit(data)
    Sound.play("click2")


func _on_help_pressed() -> void :
    if Globals.selections.size() == 1:
        if !Globals.selections[0].help.is_empty():
            Signals.set_menu.emit(Utils.menu_types.SIDE, Utils.menus.GUIDE)
            Signals.open_guide.emit(Globals.selections[0].help)
    Sound.play("click2")


func _on_color_pressed() -> void :
    for i: WindowContainer in Globals.selections:
        if i.has_colors:
            i.cycle_color()
    Sound.play("click2")


func _on_delete_pressed() -> void :
    delete()


func _on_tutorial_step() -> void :
    update_tutorial()


func _on_selection_set() -> void :
    if Globals.selections.size() > 0:
        update_buttons()


func _on_screen_set(screen: int) -> void :
    update_buttons()


func _on_cancel_pressed() -> void :
    Sound.play("close")
    Globals.set_selection([], [], 0)
