extends VBoxContainer

var initialized: bool


func _ready() -> void :
    Signals.menu_set.connect(_on_menu_set)
    Premiums.updated.connect(_on_premiums_updated)

    update_all()


func update_all() -> void :
    $PremiumInfo / LevelContainer / Label.text = tr("support_level") + " " + str(Premiums.level)

    var remaining_levels: int = Premiums.level
    for i: Control in $PremiumInfo / ProgressContainer / TiersContainer.get_children():
        if i is TextureRect:
            if remaining_levels >= 0:
                i.self_modulate = Color("ff8500")
            else:
                i.self_modulate = Color("91b1e6")
            remaining_levels -= 1
        elif i is ProgressBar:
            if remaining_levels >= 0:
                i.value = 1
            else:
                i.value = 0

    if Premiums.level >= 5:
        $PremiumInfo / LevelContainer / TextureRect.texture = load("res://textures/icons/badge06.png")
    elif Premiums.level >= 4:
        $PremiumInfo / LevelContainer / TextureRect.texture = load("res://textures/icons/badge05.png")
    elif Premiums.level >= 3:
        $PremiumInfo / LevelContainer / TextureRect.texture = load("res://textures/icons/badge04.png")
    elif Premiums.level >= 2:
        $PremiumInfo / LevelContainer / TextureRect.texture = load("res://textures/icons/badge03.png")
    elif Premiums.level >= 1:
        $PremiumInfo / LevelContainer / TextureRect.texture = load("res://textures/icons/badge02.png")
    elif Premiums.level >= 0:
        $PremiumInfo / LevelContainer / TextureRect.texture = load("res://textures/icons/badge01.png")


func _on_premiums_updated() -> void :
    update_all()


func _on_reload_button_pressed() -> void :
    Premiums.reload()
    Sound.play("click2")

    $"../ReloadButton".disabled = true
    get_tree().create_timer(10).timeout.connect( func() -> void : $"../ReloadButton".disabled = false)


func _on_menu_set(menu: int, tab: int) -> void :
    if menu != Utils.menu_types.SIDE and tab != Utils.menus.SUPPORT: return
    if initialized: return

    for i: String in Data.premiums:
        var instance: Panel = preload("res://scenes/premium_panel.tscn").instantiate()
        instance.name = i
        $ScrollContainer / MarginContainer / PremiumsContainer.add_child(instance)

    initialized = true
