extends Panel

@onready var purchase_button := $Purchase

var maxed: bool
var level: int
var cost: float
var requirement_met: bool


func _ready() -> void:
    Signals.new_level.connect(_on_new_level)
    Signals.new_unlock.connect(_on_new_unlock)

    $Purchase/CostContainer/Icon.texture = load("res://textures/icons/" + Data.currencies[Data.perks[name].currency].icon + ".png")

    update_all()


func _process(delta: float) -> void:
    purchase_button.disabled = !can_purchase()


func update_all() -> void:
    level = Globals.perks[name]
    var max_level: int = Data.perks[name].limit
    maxed = max_level > 0 and level >= max_level

    requirement_met = Data.perks[name].requirement.is_empty()
    if !requirement_met:
        for i: String in Data.perks[name].requirement:
            if !Globals.unlocks[i]:
                break

            requirement_met = true

    cost = Data.perks[name].cost * pow(10, Data.perks[name].cost_e) * pow(Data.perks[name].cost_inc, level)

    $InfoContainer/Name.text = Data.perks[name].name
    if max_level == 0:
        $IconPanel/Count.text = "[" + str(level) + "+]"
    else:
        $IconPanel/Count.text = "[" + str(level) + "/" + str(max_level) + "]"
    $InfoContainer/Description.text = Data.perks[name].description
    $IconPanel/Icon.texture = load("res://textures/icons/" + Data.perks[name].icon + ".png")

    $Purchase.visible = !maxed
    $Purchase/CostContainer/Label.text = Utils.print_string(cost, true)
    update_visibility()


func update_visibility() -> void:
    visible = get_visibility()


func get_visibility() -> bool:
    if Globals.money_level < Data.perks[name].level:
        return false

    if !requirement_met:
        return false

    return true


func can_purchase() -> bool:
    if maxed:
        return false

    if cost > Globals.currencies[Data.perks[name].currency]:
        return false

    return true


func _on_visibility_changed() -> void:
    update_all()
    set_process(is_visible_in_tree())


func _on_new_level() -> void:
    update_all()


func _on_new_unlock(unlock: String) -> void:
    update_all()


func _on_purchase_pressed() -> void:
    if can_purchase():
        Globals.currencies[Data.perks[name].currency] -= cost

        $AnimationPlayer.play("upgrade")

        var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
        Signals.spawn_ui_particle.emit(particle, $IconPanel.global_position + $IconPanel.size / 2)

        Globals.add_perk(name, 1)
        Sound.play("research")
