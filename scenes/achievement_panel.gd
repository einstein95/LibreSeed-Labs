extends Panel


func _ready() -> void:
    Signals.new_achievement.connect(_on_new_achievement)
    Signals.achievement_claimed.connect(_on_achievement_claimed)

    update_all()
    set_process(is_visible_in_tree())


func update_all() -> void:
    var unlocked: bool = Globals.achievements[name] >= 1
    var claimed: bool = Globals.achievements[name] == 2
    $InfoContainer/Name.text = tr(Data.achievements[name].name)
    $InfoContainer/Description.text = tr(Data.achievements[name].description)
    $IconPanel/Icon.texture = load("res://textures/icons/" + Data.achievements[name].icon + ".png")

    $Claim/RewardContainer/Label.text = "%.0f" % Data.achievements[name].reward
    $Claim.disabled = claimed or !unlocked

    if claimed:
        theme_type_variation = "MenuPanelTitle"
    elif unlocked:
        theme_type_variation = "MenuPanelTitle"
    else:
        theme_type_variation = "MenuPanelTitleDisabled"


func _on_new_achievement(achievement: String) -> void:
    update_all()


func _on_achievement_claimed(achievement: String) -> void:
    update_all()


func _on_visibility_changed() -> void:
    update_all()
    set_process(is_visible_in_tree())


func _on_claim_pressed() -> void:
    Globals.claim_achievement(name)

    Signals.currency_popup.emit("token", Data.achievements[name].reward)
    Signals.currency_popup_particle.emit("token", get_global_mouse_position())
    $AnimationPlayer.play("upgrade")
    Sound.play("claim")
