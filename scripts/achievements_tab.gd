extends VBoxContainer

var initialized: bool


func _ready() -> void :
    Signals.menu_set.connect(_on_menu_set)


func set_tab(tab: int) -> void :
    $TabContainer.current_tab = tab
    for i: Button in $Panel / ButtonsContainer.get_children():
        i.button_pressed = i.get_index() == tab


func _on_achievements_pressed() -> void :
    set_tab(0)
    Sound.play("click_toggle2")


func _on_requests_pressed() -> void :
    set_tab(1)
    Sound.play("click_toggle2")


func _on_menu_set(menu: int, tab: int) -> void :
    if menu != Utils.menu_types.SIDE and tab != Utils.menus.ACHIEVEMENTS: return

    var count: int
    for i: String in Globals.achievements:
        if Globals.achievements[i] >= 1:
            count = min(count + 1, Data.achievements.size())
    $TabContainer / Achievements / Progress / ProgressContainer / InfoContainer / LabelContainer / ProgressLabel.text = str(count) + "/" + str(Data.achievements.size())
    $TabContainer / Achievements / Progress / ProgressBar.value = count
    $TabContainer / Achievements / Progress / ProgressBar.max_value = Data.achievements.size()

    if initialized: return

    for i: String in Data.achievements:
        var instance: Panel = preload("res://scenes/achievement_panel.tscn").instantiate()
        instance.name = i
        $TabContainer / Achievements / ScrollContainer / MarginContainer / AchievementsContainer.add_child(instance)

    for i: String in Data.requests:
        var instance: Panel = preload("res://scenes/request_panel.tscn").instantiate()
        instance.name = i
        $TabContainer / Requests / MarginContainer / RequestsContainer.add_child(instance)

    initialized = true
