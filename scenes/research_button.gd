@tool
extends Button

@onready var animation := $AnimationPlayer

@export var x: float:
    set(value):
        x = value
        update_radial_pos()
@export var y: float:
    set(value):
        y = value
        update_radial_pos()


func _ready() -> void:
    if Engine.is_editor_hint():
        return
    Signals.new_research.connect(_on_new_research)
    Signals.new_unlock.connect(_on_new_unlock)

    $Icon.texture = load("res://textures/icons/" + Data.research[name].icon + ".png")


func update_state() -> void:
    var owned: bool = Globals.research[name]
    var requirement_met: bool = Data.research[name].requirement.is_empty()
    if !requirement_met:
        for i: String in Data.research[name].requirement:
            if Globals.research[i] > 0:
                requirement_met = true
                break
    disabled = !owned and !requirement_met

    var cost: float = Data.research[name].cost * 10 ** Data.research[name].cost_e

    if owned:
        $Icon.self_modulate = Color("ff8500")
    else:
        if requirement_met:
            $Icon.self_modulate = Color("91b1e6")
        else:
            $Icon.self_modulate = Color("91b1e664")

    if !owned and requirement_met and Globals.currencies[Data.research[name].currency] >= cost:
        animation.play("Available")
    else:
        animation.play("RESET")


func _on_visibility_changed() -> void:
    if Engine.is_editor_hint():
        return
    update_state()


func _on_pressed() -> void:
    Signals.research_selected.emit(name)
    Sound.play("click_toggle")


func _on_new_unlock(unlock: String) -> void:
    update_state()


func _on_new_research(research: String, levels: int) -> void:
    if research == name:
        animation.play("Upgrade")


func update_radial_pos() -> void:
    position = Vector2(-40 + x * 120, -40 + y * 120)
