extends CanvasLayer

enum bottom_bars{NONE, WINDOWS, OPTIONS}

@export var research_unlocks: Dictionary[NodePath, String]
@export var level_unlocks: Dictionary[NodePath, int]
const tab_screens: Dictionary = {1: 1}
const progress_buttons: Dictionary = {"Upgrades": Utils.menus.UPGRADES, "Storage": Utils.menus.STORAGE, 
"Tokens": Utils.menus.TOKENS, "Portal": Utils.menus.PORTAL}
const extras_buttons: Dictionary = {"Support": Utils.menus.SUPPORT, "Guide": Utils.menus.GUIDE, 
"Achievements": Utils.menus.ACHIEVEMENTS, "Settings": Utils.menus.SETTINGS}
const windows_buttons: Dictionary = {"CPU": "cpu", "Network": "network", "GPU": "gpu", 
"Research": "research", "Hacking": "hacking", "Coding": "coding", "Utilities": "utility"}

@onready var main: = $Main
@onready var offline_bar: = $Main / MainContainer / Overlay / TopLeftContainer / RestPanel / RestContainer / TimeContainer / ProgressBar
@onready var offline_timer: = $Main / MainContainer / Overlay / TopLeftContainer / RestPanel / RestContainer / TimeContainer / Label
@onready var storage_bar: = $Main / MainContainer / Overlay / TopLeftContainer / StoragePanel / StorageContainer / InfoContainer / ProgressBar
@onready var storage_label: = $Main / MainContainer / Overlay / TopLeftContainer / StoragePanel / StorageContainer / InfoContainer / Label

var cur_menu: int
var cur_bottom_bar: int = bottom_bars.WINDOWS
var available_windows: Array[String]
var transitioning: bool
var storage_str: String


func _enter_tree() -> void :
    get_viewport().size_changed.connect(update_size)


func _ready() -> void :
    Signals.screen_transition_started.connect(_on_screen_transition_started)
    Signals.screen_transition_finished.connect(_on_screen_transition_finished)
    Signals.setting_set.connect(_on_setting_set)
    Signals.tutorial_step.connect(_on_tutorial_step)
    Signals.set_menu.connect(_on_set_menu)
    Signals.menu_set.connect(_on_menu_set)
    Signals.selection_set.connect(_on_selection_set)
    Signals.new_level.connect(_on_new_level)
    Signals.new_unlock.connect(_on_new_unlock)
    Signals.new_perk.connect(_on_new_perk)
    Signals.new_achievement.connect(_on_new_achievement)
    Signals.achievement_claimed.connect(_on_achievement_claimed)
    Signals.new_request.connect(_on_new_request)
    Signals.request_claimed.connect(_on_request_claimed)
    Signals.notify.connect(_on_notify)
    Signals.fixed_notify.connect(_on_fixed_notify)
    Signals.offline_multiplier_set.connect(_on_offline_multiplier_set)
    Signals.create_pointer.connect(_on_create_pointer)
    Signals.tokens_claimed.connect(_on_tokens_claimed)
    Signals.spawn_ui_particle.connect(_on_spawn_ui_particle)
    Signals.spawn_placer.connect(_on_spawn_placer)
    update_unlockables()

    $ColorRect.visible = true
    var tween: Tween = create_tween()
    tween.tween_property($ColorRect, "color:a", 1, 0.3)
    tween.tween_property($ColorRect, "color:a", 0, 0.7)
    tween.step_finished.connect( func(step: int) -> void : Signals.boot.emit())
    tween.finished.connect( func() -> void : $ColorRect.visible = false)

    if Globals.is_mobile():
        if Globals.platform == 3:
            $Main / MainContainer.add_theme_constant_override("margin_right", DisplayServer.get_display_safe_area().position.x)
            $Main / MainContainer.add_theme_constant_override("margin_left", 40)
            $Main / MainContainer.add_theme_constant_override("margin_bottom", 50)
        else:
            $Main / MainContainer.add_theme_constant_override("margin_left", DisplayServer.get_display_safe_area().position.x + 20)
            $Main / MainContainer.add_theme_constant_override("margin_right", 30)
            $Main / MainContainer.add_theme_constant_override("margin_bottom", 30)
        $Main / MainContainer.add_theme_constant_override("margin_top", 30)

    available_windows = get_new_windows()

    Sound.play("boot")
    update_size()
    update_offline_multiplier()
    update_claimables()
    update_tutorial()


func _process(delta: float) -> void :
    Globals.ui_mouse_pos = main.get_global_mouse_position()
    offline_bar.value = Globals.offline_time
    offline_timer.text = " %.0f" % Globals.offline_time + tr("second_abbreviation") + " "
    storage_bar.value = Globals.storage_size / Attributes.get_attribute("storage_size")
    storage_label.text = Utils.print_metric(Globals.storage_size) + "b/" + Utils.print_metric(Attributes.get_attribute("storage_size")) + "b"


func _input(event: InputEvent) -> void :
    if event is InputEventKey and event.is_released():
        if event.keycode == KEY_F10:
            visible = !visible


func set_menu(menu: int, tab: int = 0, pressed: bool = false) -> void :
    if cur_menu == menu and menu == Utils.menu_types.NONE: return
    match menu:
        Utils.menu_types.NONE:
            if $Main / MainContainer / Overlay / Menus.open:
                $Main / MainContainer / Overlay / Menus.toggle(false)
            if $Main / MainContainer / Overlay / WindowsMenu.open:
                $Main / MainContainer / Overlay / WindowsMenu.toggle(false)
            if $Main / MainContainer / Overlay / SchematicsMenu.open:
                $Main / MainContainer / Overlay / SchematicsMenu.toggle(false)
            Sound.play("menu_close")
        Utils.menu_types.SIDE:
            if $Main / MainContainer / Overlay / Menus.open and $Main / MainContainer / Overlay / Menus.cur_tab == tab:
                if pressed:
                    set_menu(0)
                return

            $Main / MainContainer / Overlay / Menus.toggle(true, tab)
            Sound.play("menu_open")

            if $Main / MainContainer / Overlay / WindowsMenu.open:
                $Main / MainContainer / Overlay / WindowsMenu.toggle(false)
            if $Main / MainContainer / Overlay / SchematicsMenu.open:
                $Main / MainContainer / Overlay / SchematicsMenu.toggle(false)
        Utils.menu_types.WINDOWS:
            if $Main / MainContainer / Overlay / WindowsMenu.open and $Main / MainContainer / Overlay / WindowsMenu.cur_tab == tab:
                if pressed:
                    set_menu(0)
                return

            if !$Main / MainContainer / Overlay / WindowsMenu.open:
                Sound.play("menu_open")
            $Main / MainContainer / Overlay / WindowsMenu.toggle(true, tab)

            if $Main / MainContainer / Overlay / Menus.open:
                $Main / MainContainer / Overlay / Menus.toggle(false)
            if $Main / MainContainer / Overlay / SchematicsMenu.open:
                $Main / MainContainer / Overlay / SchematicsMenu.toggle(false)
        Utils.menu_types.SCHEMATICS:
            if $Main / MainContainer / Overlay / SchematicsMenu.open:
                if pressed:
                    set_menu(0)
                return

            if !$Main / MainContainer / Overlay / SchematicsMenu.open:
                Sound.play("menu_open")
            $Main / MainContainer / Overlay / SchematicsMenu.toggle(true)

            if $Main / MainContainer / Overlay / Menus.open:
                $Main / MainContainer / Overlay / Menus.toggle(false)
            if $Main / MainContainer / Overlay / WindowsMenu.open:
                $Main / MainContainer / Overlay / WindowsMenu.toggle(false)
    cur_menu = menu
    Signals.menu_set.emit(cur_menu, tab)


func update_buttons() -> void :
    for i: String in progress_buttons:
        var button: Button = $Main / MainContainer / Overlay / ProgressButtons / Container.get_node(i)
        button.button_pressed = $Main / MainContainer / Overlay / Menus.open and $Main / MainContainer / Overlay / Menus.cur_tab == progress_buttons[i]
    for i: String in extras_buttons:
        var button: Button = $Main / MainContainer / Overlay / ExtrasButtons / Container.get_node(i)
        button.button_pressed = $Main / MainContainer / Overlay / Menus.open and $Main / MainContainer / Overlay / Menus.cur_tab == extras_buttons[i]
    for i: Button in $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons.get_children():
        i.button_pressed = $Main / MainContainer / Overlay / WindowsMenu.open and windows_buttons[i.name] == $Main / MainContainer / Overlay / WindowsMenu.cur_category
    $Main / MainContainer / Overlay / BottomButtons / SchematicsButton / Schematics.button_pressed = $Main / MainContainer / Overlay / SchematicsMenu.open

    if transitioning:
        $Main / MainContainer / Overlay / ScreenButtons / Container / Desktop.button_mask = 0
        $Main / MainContainer / Overlay / ScreenButtons / Container / Research.button_mask = 0
    else:
        $Main / MainContainer / Overlay / ScreenButtons / Container / Desktop.button_mask = 1
        $Main / MainContainer / Overlay / ScreenButtons / Container / Research.button_mask = 1


func update_unlockables() -> void :
    for i: NodePath in level_unlocks:
        var new_visible: bool = Globals.money_level >= level_unlocks[i]
        if !get_node(i).visible and new_visible:
            var tween: Tween = create_tween()
            tween.set_loops(3)
            tween.tween_property(get_node(i), "modulate", Color(2, 2, 2), 1)
            tween.tween_property(get_node(i), "modulate", Color(1, 1, 1), 1)
        get_node(i).visible = new_visible

    for i: NodePath in research_unlocks:
        var new_visible: bool = Globals.unlocks[research_unlocks[i]]
        if !get_node(i).visible and new_visible:
            var tween: Tween = create_tween()
            tween.set_loops(3)
            tween.tween_property(get_node(i), "modulate", Color(2, 2, 2), 1)
            tween.tween_property(get_node(i), "modulate", Color(1, 1, 1), 1)
        get_node(i).visible = new_visible

    $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / CPU.disabled = !Globals.unlocks["upgrade.processor"]
    $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / GPU.disabled = !Globals.unlocks["upgrade.gpu"]
    $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Research.disabled = !Globals.unlocks["upgrade.research"]
    $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Hacking.visible = Globals.unlocks["research.hacking"]
    $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Coding.visible = Globals.unlocks["research.coding"]
    $Main / MainContainer / Overlay / ProgressButtons.visible = Globals.money_level >= 3
    $Main / MainContainer / Overlay / ScreenButtons.visible = Globals.money_level >= 9
    $Main / MainContainer / Overlay / BottomButtons / SchematicsButton.visible = Globals.money_level >= 6
    $Main / MainContainer / Overlay / TopLeftContainer / Currency / Hack.visible = Globals.unlocks["research.hacking"]
    $Main / MainContainer / Overlay / TopLeftContainer / StoragePanel.visible = Globals.unlocks["upgrade.server"]

    if Globals.tutorial_done:
        $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Network.disabled = false
        $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Utilities.disabled = false
    else:
        var step_network: Array[int] = [Utils.tutorial_steps.OPEN_MENU]
        var step_utils: Array[int] = [Utils.tutorial_steps.OPEN_MENU2]
        $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Network.disabled = !step_network.has(Globals.tutorial_step)
        $Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Utilities.disabled = !step_utils.has(Globals.tutorial_step)


func update_size() -> void :
    var ui_scale: float = Data.scale

    main.scale = Vector2.ONE * ui_scale
    main.size = get_viewport().size / ui_scale


func update_offline_multiplier() -> void :
    $Main / MainContainer / Overlay / TopLeftContainer / RestPanel.visible = floori(Globals.offline_time) > 0
    $Main / MainContainer / Overlay / TopLeftContainer / RestPanel / RestContainer / RestButton.button_pressed = Globals.offline_multiplier > 1
    $Main / MainContainer / Overlay / TopLeftContainer / RestPanel / RestContainer / TimeContainer / ProgressBar.max_value = Attributes.get_attribute("max_rest_time")


func update_claimables() -> void :
    var is_new: bool = Globals.achievements.values().count(1) > 0 or Globals.requests.values().count(1) > 0
    $Main / MainContainer / Overlay / ExtrasButtons / Container / Achievements / New.visible = is_new

func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.OPEN_MENU:
        Signals.desktop_point_to.emit(null)
        Signals.interface_point_to.emit($Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Network)
    elif Globals.tutorial_step == Utils.tutorial_steps.OPEN_MENU2:
        Signals.desktop_point_to.emit(null)
        Signals.interface_point_to.emit($Main / MainContainer / Overlay / BottomButtons / WindowsButtons / MenuButtons / Utilities)


func check_new_windows() -> void :
    var new: Array[String] = get_new_windows()
    if new.size() > 0:
        var categories: Array
        for i: String in new:
            if categories.has(Data.windows[i].category): continue
            categories.append(Data.windows[i].category)

        for i: String in categories:
            match i:
                "cpu":
                    Signals.notify.emit("processor", "new_windows_processor")
                "network":
                    Signals.notify.emit("web", "new_windows_network")
                "gpu":
                    Signals.notify.emit("gpu", "new_windows_gpu")
                "research":
                    Signals.notify.emit("research", "new_windows_research")
                "hacking":
                    Signals.notify.emit("hacker", "new_windows_hacking")
                "coding":
                    Signals.notify.emit("code", "new_windows_coding")
                "utility":
                    Signals.notify.emit("tools", "new_windows_utilities")
        available_windows.append_array(new)


func set_bottom_bar(bar: int) -> void :
    if bar == cur_bottom_bar: return

    if cur_bottom_bar != bottom_bars.NONE:
        var tween: Tween = create_tween()
        tween.set_parallel()
        tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
        var panel: Control = get_bottom_bar(cur_bottom_bar)

        tween.tween_property(panel, "modulate:a", 0, 0.15)
        tween.tween_property(panel, "offset_bottom", 124, 0.25)
        tween.tween_property(panel, "offset_top", 20, 0.25)
        tween.finished.connect( func() -> void : panel.visible = get_bottom_bar(cur_bottom_bar) == panel)

    if bar != bottom_bars.NONE:
        var tween: Tween = create_tween()
        tween.set_parallel()
        tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
        var panel: Control = get_bottom_bar(bar)

        tween.tween_property(panel, "modulate:a", 1, 0.15)
        tween.tween_property(panel, "offset_bottom", 0, 0.25)
        tween.tween_property(panel, "offset_top", -104, 0.25)
        panel.visible = true

    cur_bottom_bar = bar


func toggle_tools_bar(on: bool) -> void :
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    if on:
        tween.tween_property($Main / MainContainer / Overlay / ToolsBar, "modulate:a", 1, 0.15)
        tween.tween_property($Main / MainContainer / Overlay / ToolsBar, "offset_bottom", 0, 0.25)
        tween.tween_property($Main / MainContainer / Overlay / ToolsBar, "offset_top", -104, 0.25)
        $Main / MainContainer / Overlay / ToolsBar.visible = true
    else:
        tween.tween_property($Main / MainContainer / Overlay / ToolsBar, "modulate:a", 0, 0.15)
        tween.tween_property($Main / MainContainer / Overlay / ToolsBar, "offset_bottom", 124, 0.25)
        tween.tween_property($Main / MainContainer / Overlay / ToolsBar, "offset_top", 20, 0.25)
        tween.finished.connect( func() -> void : $Main / MainContainer / Overlay / ToolsBar.visible = false)


func get_new_windows() -> Array[String]:
    var new: Array[String]
    for i: String in Data.windows:
        if available_windows.has(i): continue
        if !Data.windows[i].requirement.is_empty() and !Globals.unlocks[Data.windows[i].requirement]: continue
        new.append(i)

    return new


func get_bottom_bar(bar: int) -> Control:
    match bar:
        bottom_bars.WINDOWS:
            return $Main / MainContainer / Overlay / BottomButtons
        bottom_bars.OPTIONS:
            return $Main / MainContainer / Overlay / OptionsBar

    return null


func _on_desktop_pressed() -> void :
    if Globals.cur_screen != 0:
        Signals.set_screen.emit(0, Globals.camera_center)
        $Main / MainContainer / Overlay / ScreenButtons / Container / Research.button_pressed = false
    $Main / MainContainer / Overlay / ScreenButtons / Container / Desktop.button_pressed = true

    Sound.play("click_toggle")


func _on_research_pressed() -> void :
    if Globals.cur_screen != 1:
        Signals.set_screen.emit(1, Globals.camera_center)
        $Main / MainContainer / Overlay / ScreenButtons / Container / Desktop.button_pressed = false
    $Main / MainContainer / Overlay / ScreenButtons / Container / Research.button_pressed = true

    Sound.play("click_toggle")


func _on_upgrades_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.UPGRADES, true)
    $Main / MainContainer / Overlay / ProgressButtons / Container / Upgrades / New.visible = false

    Sound.play("click_toggle")


func _on_storage_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.STORAGE, true)
    Sound.play("click_toggle")


func _on_tasks_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.TOKENS, true)
    Sound.play("click_toggle")


func _on_portal_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.PORTAL, true)
    Sound.play("click_toggle")


func _on_support_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.SUPPORT, true)
    Sound.play("click_toggle")


func _on_guide_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.GUIDE, true)
    Sound.play("click_toggle")


func _on_achievements_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.ACHIEVEMENTS, true)
    Sound.play("click_toggle")


func _on_settings_pressed() -> void :
    set_menu(Utils.menu_types.SIDE, Utils.menus.SETTINGS, true)
    Sound.play("click_toggle")


func _on_window_network_pressed() -> void :
    set_menu(Utils.menu_types.WINDOWS, Utils.window_menus.NETWORK, true)
    Sound.play("click_toggle")


func _on_window_cpu_pressed() -> void :
    set_menu(Utils.menu_types.WINDOWS, Utils.window_menus.CPU, true)
    Sound.play("click_toggle")


func _on_window_gpu_pressed() -> void :
    set_menu(Utils.menu_types.WINDOWS, Utils.window_menus.GPU, true)
    Sound.play("click_toggle")


func _on_window_research_pressed() -> void :
    set_menu(Utils.menu_types.WINDOWS, Utils.window_menus.RESEARCH, true)
    Sound.play("click_toggle")


func _on_window_hacking_pressed() -> void :
    set_menu(Utils.menu_types.WINDOWS, Utils.window_menus.HACKING, true)
    Sound.play("click_toggle")


func _on_window_coding_pressed() -> void :
    set_menu(Utils.menu_types.WINDOWS, Utils.window_menus.CODING, true)
    Sound.play("click_toggle")


func _on_window_utilities_pressed() -> void :
    set_menu(Utils.menu_types.WINDOWS, Utils.window_menus.UTILITY, true)
    Sound.play("click_toggle")


func _on_schematics_pressed() -> void :
    set_menu(Utils.menu_types.SCHEMATICS, 0, true)
    Sound.play("click_toggle")


func _on_rest_button_pressed() -> void :
    Signals.popup.emit("RestTime")
    $Main / MainContainer / Overlay / TopLeftContainer / RestPanel / RestContainer / RestButton.button_pressed = Globals.offline_multiplier > 1

    Sound.play("click_toggle")


func _on_screen_transition_started() -> void :
    transitioning = true
    if Globals.cur_screen == 0:
        set_bottom_bar(bottom_bars.NONE)
        toggle_tools_bar(false)
    set_menu(0, 0, false)

    update_buttons()


func _on_screen_transition_finished() -> void :
    transitioning = false
    if Globals.cur_screen == 0:
        if Globals.selections.size() == 0:
            set_bottom_bar(bottom_bars.WINDOWS)
        else:
            set_bottom_bar(bottom_bars.OPTIONS)
        toggle_tools_bar(true)

    update_buttons()
    $Main / MainContainer / Overlay / Pointers.visible = Globals.cur_screen == 0


func _on_tutorial_step() -> void :
    update_tutorial()
    update_unlockables()


func _on_selection_set() -> void :
    if Globals.selections.size() == 0:
        set_bottom_bar(bottom_bars.WINDOWS)
    else:
        set_bottom_bar(bottom_bars.OPTIONS)


func _on_set_menu(menu: int, tab: int) -> void :
    set_menu(menu, tab)


func _on_menu_set(toggled: bool, tab: int) -> void :
    update_buttons()


func _on_setting_set(setting: String) -> void :
    if setting == "scale":
        update_size()


func _on_new_level() -> void :
    update_unlockables()

    var has_new: bool
    for i: String in Data.upgrades:
        if !Data.upgrades[i].category == "main": continue
        if int(Data.upgrades[i].level) == Globals.money_level:
            has_new = true

    if has_new:
        $Main / MainContainer / Overlay / ProgressButtons / Container / Upgrades / New.visible = true
        Signals.notify.emit("up_arrow", tr("new_upgrades_available"))


func _on_notify(icon: String, text: String) -> void :
    var instance: PanelContainer = load("res://scenes/notification_container.tscn").instantiate()
    instance.icon = icon
    instance.text = text
    $Main / MainContainer / Overlay / Notifications / Container.add_child(instance)


func _on_fixed_notify(icon: String, text: String) -> void :
    $Main / MainContainer / Overlay / Notifications / FixedNotification.visible = true
    $Main / MainContainer / Overlay / Notifications / FixedNotification / NotificationContainer / Icon.texture = load("res://textures/icons/" + icon + ".png")
    $Main / MainContainer / Overlay / Notifications / FixedNotification / NotificationContainer / Label.text = text
    $Main / MainContainer / Overlay / Notifications / FixedNotification / AnimationPlayer.play("notify")
    $Main / MainContainer / Overlay / Notifications / FixedNotification / AnimationPlayer.seek(0, true)

func _on_new_achievement(achievement: String) -> void :
    var instance: PanelContainer = load("res://scenes/achievement_notification.tscn").instantiate()
    instance.achievement = achievement
    $Main / MainContainer / Overlay / Notifications / Container.add_child(instance)
    Sound.play("new_achievement")
    update_claimables()

func _on_achievement_claimed(achievement: String) -> void :
    update_claimables()

func _on_new_request(request: String) -> void :
    var instance: PanelContainer = load("res://scenes/request_notification.tscn").instantiate()
    instance.request = request
    $Main / MainContainer / Overlay / Notifications / Container.add_child(instance)
    Sound.play("new_achievement")
    update_claimables()

func _on_request_claimed(request: String) -> void :
    update_claimables()

func _on_new_unlock(unlock: String) -> void :
    check_new_windows()
    update_unlockables()

func _on_new_perk(perk: String, levels: int) -> void :
    update_offline_multiplier()

func _on_offline_multiplier_set() -> void :
    update_offline_multiplier()

func _on_create_pointer(visibility_notifier: VisibleOnScreenNotifier2D) -> void :
    var pointer: Sprite2D = load("res://scenes/offscreen_pointer.tscn").instantiate()
    pointer.pointing = visibility_notifier
    $Main / MainContainer / Overlay / Pointers.add_child(pointer)

func _on_tokens_claimed() -> void :
    var instance: PanelContainer = load("res://scenes/premium_notification.tscn").instantiate()
    $Main / MainContainer / Overlay / Notifications / Container.add_child(instance)
    Sound.play("new_achievement")

func _on_spawn_ui_particle(particle: GPUParticles2D, pos: Vector2) -> void :
    $Main / Particles.add_child(particle)
    particle.global_position = pos

func _on_windows_buttons_category_set() -> void :
    update_buttons()


func _on_spawn_placer(placer: Button) -> void :
    $Main / DragControl.add_child(placer)
