extends VBoxContainer

var initialized: bool


func _ready() -> void :
    Signals.menu_set.connect(_on_menu_set)
    Signals.new_unlock.connect(_on_new_unlock)

    update_buttons()


func set_tab(tab: int) -> void :
    $TabContainer.current_tab = tab

    for i: Button in $Panel / ButtonsContainer.get_children():
        i.button_pressed = tab == i.get_index()


func update_buttons() -> void :
    $Panel / ButtonsContainer / Services.visible = Globals.unlocks["research.hacking"]


func _on_perks_pressed() -> void :
    set_tab(0)
    Sound.play("click_toggle2")


func _on_boosts_pressed() -> void :
    set_tab(1)
    Sound.play("click_toggle2")


func _on_services_pressed() -> void :
    set_tab(2)
    Sound.play("click_toggle2")


func _on_menu_set(menu: int, tab: int) -> void :
    if menu != Utils.menu_types.SIDE and tab != Utils.menus.TOKENS: return
    if initialized: return

    for i: String in Data.perks:
        var instance: Panel = preload("res://scenes/perk_panel.tscn").instantiate()
        instance.name = i
        $TabContainer / Perks / MarginContainer / PerksContainer.add_child(instance)

    for i: String in Data.boosts:
        var instance: Panel = preload("res://scenes/boost_panel.tscn").instantiate()
        instance.name = i
        $TabContainer / Boosts / MarginContainer / BoostsContainer.add_child(instance)


    for i: String in Data.services:
        var instance: Panel = preload("res://scenes/service_panel.tscn").instantiate()
        instance.name = i
        $TabContainer / Services / MarginContainer / ServicesContainer.add_child(instance)

    initialized = true


func _on_new_unlock(unlock: String) -> void :
    update_buttons()
