@tool
extends Button

@export var radius: int:
    set(value):
        radius = value
        update_radial_pos()
@export var angle_degrees: float:
    set(value):
        angle_degrees = value
        update_radial_pos()


func _ready() -> void:
    if Engine.is_editor_hint():
        return

    Signals.research_queued.connect(_on_research_queued)
    Signals.research_selected.connect(_on_research_selected)

    $Icon.texture = load("res://textures/icons/" + Data.research[name].icon + ".png")


func update_state() -> void:
    var owned: bool = Globals.research[name]
    var queued: bool = Globals.q_research.has(name)
    var requirement_met: bool = Data.research[name].requirement.is_empty()
    if !requirement_met:
        for i: String in Data.research[name].requirement:
            if !Globals.unlocks["research." + i] and !Globals.q_research.has(i):
                break

            requirement_met = true
    disabled = !owned and !requirement_met

    if owned:
        $Icon.self_modulate = Color("ff8500")
    elif queued:
        $Icon.self_modulate = Color("00ffb8")
    elif requirement_met:
        $Icon.self_modulate = Color("91b1e6")
    else:
        $Icon.self_modulate = Color("91b1e664")


func _on_visibility_changed() -> void:
    if Engine.is_editor_hint():
        return

    update_state()


func _on_pressed() -> void:
    Signals.research_selected.emit(name)
    Sound.play("click_toggle")


func _on_research_queued(research: String, levels: int) -> void:
    update_state()


func _on_research_selected(research: String) -> void:
    button_pressed = name == research


func update_radial_pos() -> void:
    position = Vector2(-40 + (50 + radius * 128) * cos(deg_to_rad(angle_degrees)), -40 + (50 + radius * 128) * sin(deg_to_rad(angle_degrees)))
