extends Panel

@onready var purchase_button: = $Purchase

@export var animating: bool
var maxed: bool
var level: int
var cost: float
var requirement_met: bool


func _ready() -> void :
    Signals.new_level.connect(_on_new_level)
    Signals.new_unlock.connect(_on_new_unlock)
    Signals.setting_set.connect(_on_setting_set)

    $Purchase / CostContainer / Icon.texture = load("res://textures/icons/" + Data.currencies[Data.upgrades[name].currency].icon + ".png")

    update_all()
    set_process(is_visible_in_tree())


func _process(delta: float) -> void :
    purchase_button.disabled = !can_purchase()


func update_all() -> void :
    level = Globals.upgrades[name]
    var max_level: int = Data.upgrades[name].limit
    maxed = max_level > 0 and level >= max_level

    requirement_met = Data.upgrades[name].requirement.is_empty()
    if !requirement_met:
        for i: String in Data.upgrades[name].requirement:
            if !Globals.unlocks[i]: break
            requirement_met = true

    cost = Data.upgrades[name].cost * pow(10, Data.upgrades[name].cost_e) * pow(Data.upgrades[name].cost_inc, level)
    if Data.upgrades[name].currency == "money":
        cost *= Attributes.get_attribute("price_multiplier")

    $InfoContainer / Name.text = Data.upgrades[name].name
    if max_level == 0:
        $IconPanel / Count.text = "[" + str(level) + "+]"
    else:
        $IconPanel / Count.text = "[" + str(level) + "/" + str(max_level) + "]"
    $InfoContainer / Description.text = Data.upgrades[name].description
    $IconPanel / Icon.texture = load("res://textures/icons/" + Data.upgrades[name].icon + ".png")

    $Purchase.visible = !maxed
    $Purchase / CostContainer / Label.text = Utils.print_string(cost, true)
    update_visibility()


func update_visibility() -> void :
    visible = get_visibility()


func get_visibility() -> bool:
    if animating: return true
    if maxed: return get_visibility_maxed()
    if Globals.money_level < Data.upgrades[name].level: return false
    if !requirement_met: return false

    return true


func get_visibility_maxed() -> bool:
    if Data.upgrades[name].category != "main": return true
    return Data.show_completed


func can_purchase() -> bool:
    if maxed: return false
    if cost > Globals.currencies[Data.upgrades[name].currency]: return false

    return true


func _on_visibility_changed() -> void :
    update_all()
    set_process(is_visible_in_tree())


func _on_new_level() -> void :
    update_all()


func _on_new_unlock(unlock: String) -> void :
    update_all()


func _on_animation_player_animation_finished(anim_name: StringName) -> void :
    if anim_name == "complete":
        animating = false
        $AnimationPlayer.play("RESET")


func _on_setting_set(setting: String) -> void :
    if setting == "show_completed":
        update_visibility()


func _on_purchase_pressed() -> void :
    if can_purchase():
        Globals.currencies[Data.upgrades[name].currency] -= cost

        $AnimationPlayer.play("upgrade")
        if Data.upgrades[name].limit > 0 and level + 1 >= int(Data.upgrades[name].limit) and !get_visibility_maxed():
            $AnimationPlayer.queue("complete")
            animating = true

        var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
        Signals.spawn_ui_particle.emit(particle, $IconPanel.global_position + $IconPanel.size / 2)

        Globals.add_upgrade(name, 1)
        Sound.play("research")
