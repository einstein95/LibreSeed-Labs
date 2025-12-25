extends Panel

@onready var purchase_button := $Purchase


func _ready() -> void:
    Signals.new_level.connect(_on_new_level)
    Signals.new_unlock.connect(_on_new_unlock)

    $IconPanel/Icon.texture = load("res://textures/icons/" + Data.upgrades[name].icon + ".png")

    update_all()


func _process(delta: float) -> void:
    purchase_button.disabled = !can_purchase()


func update_all() -> void:
    $InfoContainer/Name.text = tr(Data.upgrades[name].name)
    $InfoContainer/Description.text = tr(Data.upgrades[name].description)

    $Purchase.visible = !Globals.upgrades[name]
    update_visibility()


func update_visibility() -> void:
    visible = get_visibility()


func get_visibility() -> bool:
    var requirement_met: bool = Data.upgrades[name].requirement.is_empty()
    if !requirement_met:
        for i: String in Data.upgrades[name].requirement:
            if !Globals.unlocks[i]:
                break

            requirement_met = true

    return requirement_met


func can_purchase() -> bool:
    if Data.upgrades[name].limit > 0 and Globals.upgrades[name] >= Data.upgrades[name].limit:
        return false

    if Attributes.get_attribute("optimization_points") < 1:
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
        Globals.add_upgrade(name, 1)

        var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
        Signals.spawn_ui_particle.emit(particle, $IconPanel.global_position + $IconPanel.size / 2)
        $AnimationPlayer.play("upgrade")

        Sound.play("research")
