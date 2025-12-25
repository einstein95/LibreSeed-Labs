extends Panel

var upgrade: String


func _ready() -> void:
    Signals.new_hack_level.connect(_on_new_hack_level)
    upgrade = Data.hack_levels[name].upgrade

    $InfoContainer/MainInfoContainer/Icon.texture = load("res://textures/icons/" + Data.upgrades[upgrade].icon + ".png")
    $InfoContainer/MainInfoContainer/Name.text = tr(Data.upgrades[upgrade].name)
    $InfoContainer/Description.text = tr(Data.upgrades[upgrade].description)
    $RequirementPanel/RequirementContainer/Level.text = tr("lv.") + "%.0f" % Data.hack_levels[name].level

    update_level()


func update_level() -> void:
    if Globals.hack_level >= Data.hack_levels[name].level:
        modulate.a = 1.0
    else:
        modulate.a = 0.5


func _on_new_hack_level() -> void:
    update_level()
