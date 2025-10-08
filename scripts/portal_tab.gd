extends PanelContainer

@onready var research_label: = $Container / StatsContainer / ResearchPanel / InfoContainer / Value

var initialized: bool


func _ready() -> void :
    Signals.menu_set.connect(_on_menu_set)

    set_process(false)


func _process(delta: float) -> void :
    research_label.text = Utils.print_string(Globals.max_research, true)


func _on_enter_pressed() -> void :
    Signals.popup.emit("Portal")
    Sound.play("click2")


func _on_visibility_changed() -> void :
    set_process(is_visible_in_tree())


func _on_menu_set(menu: int, tab: int) -> void :
    if menu != Utils.menu_types.SIDE and tab != Utils.menus.PORTAL: return
    if initialized: return

    for i: String in Data.milestones:
        var instance: Panel = preload("res://scenes/milestone_panel.tscn").instantiate()
        instance.name = i
        $Container / ScrollContainer / MarginContainer / UpgradesContainer.add_child(instance)

    initialized = true
