extends Button

const tutorial_windows: Dictionary = {
    "upload": [Utils.tutorial_steps.SELECT_UPLOADER, Utils.tutorial_steps.ADD_UPLOADER], 
    "collect": [Utils.tutorial_steps.SELECT_COLLECTOR, Utils.tutorial_steps.ADD_COLLECTOR]
}

signal selected(window: String)
signal hovered(window: String)

var placer: Button
var starting_drag: Vector2


func _ready() -> void :
    Signals.tutorial_step.connect(_on_tutorial_step)
    Signals.new_unlock.connect(_on_new_unlock)

    update_all()
    update_tutorial()


func update_all() -> void :
    var unlocked: bool = is_unlocked()

    if unlocked:
        icon = load("res://textures/icons/" + Data.windows[name].icon + ".png")
    else:
        icon = load("res://textures/icons/question_mark.png")

    if Globals.tutorial_done:
        disabled = !unlocked
    else:
        disabled = true
        if tutorial_windows.has(name):
            disabled = !tutorial_windows[name].has(Globals.tutorial_step)

    visible = unlocked or !Data.windows[name].hidden


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.SELECT_UPLOADER and name == "upload":
        Signals.desktop_point_to.emit(null)
        Signals.interface_point_to.emit(self)
    elif Globals.tutorial_step == Utils.tutorial_steps.SELECT_COLLECTOR and name == "collect":
        Signals.desktop_point_to.emit(null)
        Signals.interface_point_to.emit(self)


func is_unlocked() -> bool:
    if !Data.windows[name].requirement.is_empty() and !Globals.unlocks[Data.windows[name].requirement]: return false

    return Globals.money_level >= Data.windows[name].level


func _on_visibility_changed() -> void :
    update_all()


func _on_pressed() -> void :
    selected.emit(name)
    Sound.play("click_toggle2")


func _on_tutorial_step() -> void :
    update_all()
    update_tutorial()


func _on_new_unlock(unlock: String) -> void :
    update_all()


func _on_gui_input(event: InputEvent) -> void :
    if event is InputEventScreenTouch:
        if event.is_pressed():
            starting_drag = event.position
        if event.is_released() and placer:
            if event.position.y <= -10:
                placer.place()
            else:
                placer.cancel()
            placer = null
    elif event is InputEventScreenDrag and !placer and !disabled:
        if Utils.can_add_window(name):
            var instance: Button = load("res://scenes/window_dragger.tscn").instantiate()
            instance.window = name
            instance.grab_pos = starting_drag
            placer = instance
            selected.emit("")
            hovered.emit("")

            Signals.spawn_placer.emit(instance)

    if placer:
        modulate.a = 0
    else:
        modulate.a = 1


func _on_mouse_entered() -> void :
    if disabled: return
    hovered.emit(name)


func _on_mouse_exited() -> void :
    hovered.emit("")
