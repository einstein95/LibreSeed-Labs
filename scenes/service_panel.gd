extends Panel

@onready var purchase_button: = $Purchase

var cost: float
var requirement_met: bool
var has_upgrades: bool
var service: RefCounted


func _ready() -> void :
    Signals.new_unlock.connect(_on_new_unlock)

    service = load("res://scripts/services/" + Data.services[name].script + ".gd").new()
    $Purchase / CostContainer / Icon.texture = load("res://textures/icons/" + Data.currencies[Data.services[name].currency].icon + ".png")

    update_all()


func _process(delta: float) -> void :
    purchase_button.disabled = !can_purchase()


func update_all() -> void :
    requirement_met = Data.services[name].requirement.is_empty()
    if !requirement_met:
        for i: String in Data.services[name].requirement:
            if !Globals.unlocks[i]: break
            requirement_met = true

    has_upgrades = Data.services[name].upgrades.is_empty()
    if !has_upgrades:
        for i: String in Data.services[name].upgrades:
            if Globals.upgrades[i] > 0:
                has_upgrades = true
                break

    cost = Data.services[name].cost * pow(10, Data.services[name].cost_e)

    $InfoContainer / Name.text = Data.services[name].name
    $InfoContainer / Description.text = Data.services[name].description
    $IconPanel / Icon.texture = load("res://textures/icons/" + Data.services[name].icon + ".png")

    $Purchase / CostContainer / Label.text = Utils.print_string(cost, true)
    update_visibility()


func update_visibility() -> void :
    visible = get_visibility()


func get_visibility() -> bool:
    if Globals.money_level < Data.services[name].level: return false
    if !requirement_met: return false

    return true


func can_purchase() -> bool:
    if !has_upgrades: return false
    if cost > Globals.currencies[Data.services[name].currency]: return false

    return service.can_purchase()


func _on_visibility_changed() -> void :
    update_all()
    set_process(is_visible_in_tree())


func _on_new_unlock(unlock: String) -> void :
    update_all()


func _on_purchase_pressed() -> void :
    if can_purchase():
        Globals.currencies[Data.services[name].currency] -= cost

        $AnimationPlayer.play("upgrade")

        service.apply()
        for i: String in Data.services[name].upgrades:
            var count: int = Globals.upgrades[i]
            Globals.add_upgrade(i, - count)

        Signals.service_purchased.emit(name)

        Sound.play("research")
