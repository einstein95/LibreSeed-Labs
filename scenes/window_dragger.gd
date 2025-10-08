extends Button

var window: String
var grab_pos: Vector2


func _ready() -> void :
    icon = load("res://textures/icons/" + Data.windows[window].icon + ".png")

    Globals.dragging = true
    Signals.dragging_set.emit()


func _process(delta: float) -> void :
    global_position = get_global_mouse_position() - size / 2


func place() -> void :
    if Globals.max_window_count >= 200:
        Signals.notify.emit("exclamation", "build_limit_reached")
        Sound.play("error")
    elif Utils.can_add_window(window):
        var instance: WindowContainer = load("res://scenes/windows/" + Data.windows[window].scene + ".tscn").instantiate()
        instance.name = window
        var instance_pos: Vector2 = Utils.screen_to_world_pos(global_position + size / 2)
        instance.global_position = (instance_pos - Vector2(175, instance.size.y / 2)).snappedf(50)
        Signals.create_window.emit(instance)

    Globals.dragging = false
    Signals.dragging_set.emit()

    queue_free()


func cancel() -> void :
    Globals.dragging = false
    Signals.dragging_set.emit()

    queue_free()
