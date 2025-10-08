extends Panel

@onready var add_buton: = $AddButton

var limit: int
var active: int
var is_new: bool


func _ready() -> void :
    Signals.new_unlock.connect(_on_new_unlock)
    Signals.window_created.connect(_on_window_created)
    Signals.window_deleted.connect(_on_window_deleted)

    update_all()


func _process(delta: float) -> void :
    add_buton.disabled = !can_build()


func update_all() -> void :
    limit = Attributes.get_window_attribute(name, "limit")
    active = Globals.window_count[name]
    if !Data.windows[name].group.is_empty():
        limit = Attributes.get_attribute(Data.windows[name].group)
        active = Globals.group_count[Data.windows[name].group]
    var maxed: bool = limit >= 0 and active >= limit

    if limit >= 0:
        $InfoContainer / Owned.text = tr("active") + ": " + str(active) + "/%.0f" % limit
    else:
        $InfoContainer / Owned.text = tr("active") + ": " + str(active)
    $InfoContainer / Name.text = tr(Data.windows[name].name)
    $InfoContainer / Name.add_theme_font_size_override("font_size", min(32, snappedi(32 - (tr(Data.windows[name].name).length() - 20), 2)))
    $InfoContainer / Description.text = tr(Data.windows[name].description)
    $InfoContainer / IconPanel / Icon.texture = load("res://textures/icons/" + Data.windows[name].icon + ".png")

    update_visibility()


func update_visibility() -> void :
    visible = get_visibility()


func can_build() -> bool:
    if limit >= 0 and active >= limit: return false

    return true


func get_visibility() -> bool:
    if !Data.windows[name].requirement.is_empty() and !Globals.unlocks[Data.windows[name].requirement]: return false

    return Globals.money_level >= Data.windows[name].level


func _on_visibility_changed() -> void :
    set_process(visible)


func _on_window_created(window: WindowContainer) -> void :
    update_all()


func _on_window_deleted(window: WindowContainer) -> void :
    update_all()


func _on_new_unlock(unlock: String) -> void :
    update_all()


func _on_add_button_pressed() -> void :
    if Globals.max_window_count >= 200:
        Signals.notify.emit("exclamation", "build_limit_reached")
        Sound.play("error")
        return

    is_new = false
    var window: WindowContainer = load("res://scenes/windows/" + Data.windows[name].scene + ".tscn").instantiate()
    window.global_position = Vector2(Globals.camera_center - window.size / 2).snappedf(50)
    Signals.create_window.emit(window)
    Signals.set_menu.emit(0, 0)
