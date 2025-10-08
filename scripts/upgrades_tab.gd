extends VBoxContainer

@onready var optimization_points: = $TabContainer / Optimizations / PointsPanel / HBoxContainer / Value
@onready var application_points: = $TabContainer / Applications / PointsPanel / HBoxContainer / Value
@onready var hack_points: = $TabContainer / Hacking / InfoContainer / LevelContainer / PointsPanel / PointsContainer / Value

var initialized: bool


func _ready() -> void :
    Signals.menu_set.connect(_on_menu_set)
    Signals.new_unlock.connect(_on_new_unlock)

    update_buttons()
    set_process(false)


func _process(delta: float) -> void :
    optimization_points.text = "%.0f" % floorf(Globals.currencies["optimization_point"]) + " " + tr("optimization_points")
    application_points.text = "%.0f" % floorf(Globals.currencies["application_point"]) + " " + tr("application_points")
    hack_points.text = "%.0f" % floorf(Globals.currencies["hack_point"]) + " " + tr("hack_points")


func set_tab(tab: int) -> void :
    $TabContainer.current_tab = tab

    for i: Button in $ButtonsPanel / ButtonsContainer.get_children():
        i.button_pressed = tab == i.get_index()


func update_buttons() -> void :
    $ButtonsPanel / ButtonsContainer / Hacking.visible = Globals.unlocks["research.hacking"]
    $ButtonsPanel / ButtonsContainer / Breach.visible = Globals.unlocks["research.breach_corporation"]
    $ButtonsPanel / ButtonsContainer / Optimizations.visible = Globals.unlocks["research.optimizations"]
    $ButtonsPanel / ButtonsContainer / Applications.visible = Globals.unlocks["research.applications"]


func _on_main_pressed() -> void :
    set_tab(0)
    Sound.play("click_toggle2")


func _on_hacking_pressed() -> void :
    set_tab(1)
    Sound.play("click_toggle2")


func _on_breach_pressed() -> void :
    set_tab(2)
    Sound.play("click_toggle2")


func _on_optimizations_pressed() -> void :
    set_tab(3)
    Sound.play("click_toggle2")


func _on_applications_pressed() -> void :
    set_tab(4)
    Sound.play("click_toggle2")


func _on_menu_set(menu: int, tab: int) -> void :
    if initialized: return
    if menu != Utils.menu_types.SIDE and tab != Utils.menus.UPGRADES: return

    for i: String in Data.upgrades:
        if Data.upgrades[i].category == "main":
            var instance: Panel = preload("res://scenes/upgrade_panel.tscn").instantiate()
            instance.name = i
            $TabContainer / Main / MarginContainer / Container.add_child(instance)
        if Data.upgrades[i].category == "hacking":
            var instance: Panel = preload("res://scenes/upgrade_panel.tscn").instantiate()
            instance.name = i
            $TabContainer / Hacking / ScrollContainer / MarginContainer / Container.add_child(instance)
        if Data.upgrades[i].category == "breach":
            var instance: Panel = preload("res://scenes/upgrade_panel.tscn").instantiate()
            instance.name = i
            $TabContainer / Breach / MarginContainer / Container.add_child(instance)
        if Data.upgrades[i].category == "optimizations":
            var instance: Panel = preload("res://scenes/upgrade_panel.tscn").instantiate()
            instance.name = i
            $TabContainer / Optimizations / ScrollContainer / MarginContainer / UpgradesContainer.add_child(instance)
        if Data.upgrades[i].category == "applications":
            var instance: Panel = preload("res://scenes/upgrade_panel.tscn").instantiate()
            instance.name = i
            $TabContainer / Applications / ScrollContainer / MarginContainer / UpgradesContainer.add_child(instance)

    initialized = true


func _on_visibility_changed() -> void :
    set_process(is_visible_in_tree())


func _on_new_unlock(unlock: String) -> void :
    update_buttons()
