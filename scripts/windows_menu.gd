extends Control

signal category_set

const category_tabs: Dictionary = {Utils.window_menus.NETWORK: "network", 
Utils.window_menus.CPU: "cpu", Utils.window_menus.GPU: "gpu", 
Utils.window_menus.RESEARCH: "research", Utils.window_menus.HACKING: "hacking", 
Utils.window_menus.CODING: "coding", Utils.window_menus.UTILITY: "utility"}
const unlock_requirements: Dictionary = {"CPU": "processor", "Network": "network", "GPU": "gpu_cluster", 
"Research": "laboratory", "Hacking": "hacker", "Coding": "coder", "Utilities": "collect"}

@onready var add_button: = $WindowPanel / PanelContainer / InfoPanel / InfoContainer / Add
@onready var windows_scroll: = $WindowsPanel / WindowsContainer / ScrollContainer
@onready var gradient1: = $WindowsPanel / Control / TextureRect
@onready var gradient2: = $WindowsPanel / Control / TextureRect2

var open: bool
var cur_tab: int
var cur_category: String
var cur_window: String
var limit: int
var active: int
var offset: float


func _ready() -> void :
    Signals.tutorial_step.connect(_on_tutorial_step)

    add_button.visible = Globals.platform == 2 or Globals.platform == 3

    set_process(is_visible_in_tree())
    update_tutorial()


func _process(delta: float) -> void :
    add_button.disabled = !can_add()
    gradient1.visible = windows_scroll.scroll_horizontal > 0
    gradient2.visible = windows_scroll.scroll_horizontal < (windows_scroll.get_h_scroll_bar().max_value - windows_scroll.size.x)


func toggle(toggled: bool, tab: int = cur_tab) -> void :
    if open != toggled:
        var tween: Tween = create_tween()
        tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
        tween.set_parallel(true)
        if toggled:
            modulate.a = 0
            visible = true
            tween.tween_property(self, "modulate:a", 1, 0.15)
            tween.tween_property($WindowsPanel, "offset_left", offset, 0.3)
            tween.tween_property($WindowsPanel, "offset_right", - offset, 0.3)
        else:
            modulate.a = 1
            visible = true
            tween.tween_property(self, "modulate:a", 0, 0.15)
            tween.tween_property($WindowsPanel, "offset_left", 483, 0.3)
            tween.tween_property($WindowsPanel, "offset_right", -483, 0.3)
            tween.finished.connect( func() -> void : visible = open)
    open = toggled
    cur_tab = tab
    set_category(category_tabs[cur_tab])

    if !Globals.tutorial_done:
        if open:
            if Globals.tutorial_step == Utils.tutorial_steps.OPEN_MENU:
                Globals.set_tutorial_step(Utils.tutorial_steps.OPEN_MENU + 1)
            elif Globals.tutorial_step == Utils.tutorial_steps.OPEN_MENU2:
                Globals.set_tutorial_step(Utils.tutorial_steps.OPEN_MENU2 + 1)
        else:
            if Globals.tutorial_step == Utils.tutorial_steps.SELECT_UPLOADER:
                Globals.set_tutorial_step(Utils.tutorial_steps.OPEN_MENU)
            elif Globals.tutorial_step == Utils.tutorial_steps.ADD_UPLOADER:
                Globals.set_tutorial_step(Utils.tutorial_steps.OPEN_MENU)
            elif Globals.tutorial_step == Utils.tutorial_steps.SELECT_COLLECTOR:
                Globals.set_tutorial_step(Utils.tutorial_steps.OPEN_MENU2)
            elif Globals.tutorial_step == Utils.tutorial_steps.ADD_COLLECTOR:
                Globals.set_tutorial_step(Utils.tutorial_steps.OPEN_MENU2)


func set_category(category: String) -> void :
    var update: bool = category != cur_category
    cur_category = category

    if update:
        for i: Control in $WindowsPanel / WindowsContainer / ScrollContainer / Windows.get_children():
            i.queue_free()
            $WindowsPanel / WindowsContainer / ScrollContainer / Windows.remove_child(i)

        var count: int
        for i: String in Data.windows:
            if Data.windows[i].category != category:
                continue

            var instance: Control = preload("res://scenes/window_button.tscn").instantiate()
            instance.name = i
            instance.selected.connect(_on_window_selected)
            instance.hovered.connect(_on_window_hovered)
            $WindowsPanel / WindowsContainer / ScrollContainer / Windows.add_child(instance)
            count += 1
        offset = clampf(483 - ((count * 100) + ((count - 1) * 10)) / 2, 0, 483)

        var tween: Tween = create_tween()
        tween.set_parallel()
        tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
        tween.tween_property($WindowsPanel, "offset_left", offset, 0.3)
        tween.tween_property($WindowsPanel, "offset_right", - offset, 0.3)

    category_set.emit()
    set_window("")


func set_window(window: String) -> void :
    cur_window = window
    for i: Button in $WindowsPanel / WindowsContainer / ScrollContainer / Windows.get_children():
        i.button_pressed = i.name == cur_window
    $WindowPanel.visible = !cur_window.is_empty()

    if Globals.tutorial_step == Utils.tutorial_steps.SELECT_UPLOADER and window == "upload":
        Globals.set_tutorial_step(Utils.tutorial_steps.SELECT_UPLOADER + 1)
    elif Globals.tutorial_step == Utils.tutorial_steps.ADD_UPLOADER and window.is_empty():
        Globals.set_tutorial_step(Utils.tutorial_steps.SELECT_UPLOADER)
    elif Globals.tutorial_step == Utils.tutorial_steps.SELECT_COLLECTOR and window == "collect":
        Globals.set_tutorial_step(Utils.tutorial_steps.SELECT_COLLECTOR + 1)
    elif Globals.tutorial_step == Utils.tutorial_steps.ADD_COLLECTOR and window.is_empty():
        Globals.set_tutorial_step(Utils.tutorial_steps.SELECT_COLLECTOR)

    update_window()


func update_window() -> void :
    if cur_window.is_empty():
        return

    limit = Attributes.get_window_attribute(cur_window, "limit")
    active = Globals.window_count[cur_window]
    if !Data.windows[cur_window].group.is_empty():
        limit = Attributes.get_attribute(Data.windows[cur_window].group)
        active = Globals.group_count[Data.windows[cur_window].group]

    if limit >= 0:
        $WindowPanel / PanelContainer / TitlePanel / TitleContainer / Count.text = str(active) + "/%.0f" % limit
    else:
        $WindowPanel / PanelContainer / TitlePanel / TitleContainer / Count.text = "+" + str(active)

    $WindowPanel / PanelContainer / TitlePanel / TitleContainer / Icon.texture = load("res://textures/icons/" + Data.windows[cur_window].icon + ".png")
    $WindowPanel / PanelContainer / TitlePanel / TitleContainer / Name.text = tr(Data.windows[cur_window].name)
    $WindowPanel / PanelContainer / InfoPanel / InfoContainer / Description.text = tr(Data.windows[cur_window].description)

    $WindowPanel.global_position.x = (get_global_mouse_position().x - 250 * Data.scale)


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.ADD_UPLOADER:
        Signals.desktop_point_to.emit(null)
        Signals.interface_point_to.emit(add_button)
    elif Globals.tutorial_step == Utils.tutorial_steps.ADD_COLLECTOR:
        Signals.desktop_point_to.emit(null)
        Signals.interface_point_to.emit(add_button)


func can_add() -> bool:
    if limit >= 0 and active >= limit:
        return false

    return true


func add_window(w: String) -> void :
    var window: WindowContainer = load("res://scenes/windows/" + Data.windows[w].scene + ".tscn").instantiate()
    window.name = w
    window.global_position = Vector2(Globals.camera_center - window.size / 2).snappedf(50)
    Signals.create_window.emit(window)


func _on_add_pressed() -> void :
    if Globals.max_window_count >= 200:
        Signals.notify.emit("exclamation", "build_limit_reached")
        Sound.play("error")
        return
    elif Utils.can_add_window(cur_window):
        var window: WindowContainer = load("res://scenes/windows/" + Data.windows[cur_window].scene + ".tscn").instantiate()
        window.name = cur_window
        window.global_position = Vector2(Globals.camera_center - window.size / 2).snappedf(50)
        Signals.create_window.emit(window)
        Signals.set_menu.emit(0, 0)


func _on_window_selected(w: String) -> void :
    if Globals.platform == 2 or Globals.platform == 3:
        if w == cur_window:
            set_window("")
        else:
            set_window(w)
    elif !w.is_empty():
        if Globals.max_window_count >= 200:
            Signals.notify.emit("exclamation", "build_limit_reached")
            Sound.play("error")
            return
        elif Utils.can_add_window(w):
            add_window(w)
            Signals.set_menu.emit(0, 0)


func _on_window_hovered(w: String) -> void :
    if Globals.platform == 2 or Globals.platform == 3:
        pass
    else:
        set_window(w)


func _on_visibility_changed() -> void :
    set_process(is_visible_in_tree())
    update_window()


func _on_tutorial_step() -> void :
    update_tutorial()
