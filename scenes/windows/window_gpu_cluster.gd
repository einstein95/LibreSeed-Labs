extends WindowIndexed

@onready var boost := $PanelContainer/MainContainer/Boost
@onready var clocks := $PanelContainer/MainContainer/Clocks
@onready var overclock := $PanelContainer/MainContainer/Overclock
@onready var heat := $PanelContainer/MainContainer/Heat
@onready var heat_bar := $PanelContainer/MainContainer/HeatProgressBar
@onready var add_button := $ActionContainer/AddButton
@onready var upgrade_button := $ActionContainer/UpgradeButton

var count: int
var level: int
var upgrade_maxed: bool
var add_cost: float
var upgrade_cost: float
var speed: float


func _ready() -> void:
    super ()
    Signals.new_unlock.connect(_on_new_unlock)
    Attributes.attributes["price_multiplier"].changed.connect(_on_attribute_changed)

    level = max(Attributes.get_window_attribute(window, "minimum_level"), level)

    update_all()


func _process(delta: float) -> void:
    super (delta)
    add_button.disabled = !can_purchase()
    upgrade_button.disabled = !can_upgrade()
    heat_bar.value = heat.count


func process(delta: float) -> void:
    var overclock_bonus: float = (1.0 + overclock.count)
    if heat.count >= 100:
        overclock_bonus = 1.0
    for i: ResourceContainer in clocks.get_children():
        i.count = speed * (1.0 + boost.count) * overclock_bonus * Attributes.get_attribute("gpu_multiplier")
    heat.count = ((overclock.count + 1) ** 2) * 50


func update_all() -> void:
    upgrade_maxed = level >= 200
    add_cost = 4 * pow(10, 6) * pow(1000, count + 1) * Attributes.get_attribute("price_multiplier")
    upgrade_cost = 4 * pow(10, 6) * pow(4, level + 1) * Attributes.get_attribute("price_multiplier")

    speed = 3000.0 * pow(2, level)
    boost.visible = Globals.unlocks["research.trojan"]
    overclock.visible = Globals.unlocks["research.overclocking"]
    heat.visible = Globals.unlocks["research.overclocking"]
    heat_bar.visible = Globals.unlocks["research.overclocking"]

    set_window_name(get_window_name())
    $ActionContainer/AddButton/UpgradeContainer/CostContainer/Label.text = Utils.print_string(add_cost, true)
    $ActionContainer/UpgradeButton/UpgradeContainer/CostContainer/Label.text = Utils.print_string(upgrade_cost, true)
    $ActionContainer/AddButton.visible = count < 4
    $ActionContainer/UpgradeButton.visible = !upgrade_maxed
    $ActionContainer/ColorRect.visible = count < 4 and !upgrade_maxed

    for i: Control in $PanelContainer/MainContainer/Clocks.get_children():
        i.visible = i.get_index() <= count

    if count < 4 and !upgrade_maxed:
        $ActionContainer/AddButton.theme_type_variation = "WindowButtonBottom1"
        $ActionContainer/UpgradeButton.theme_type_variation = "WindowButtonBottom3"
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"
    elif count >= 4 and !upgrade_maxed:
        $ActionContainer/UpgradeButton.theme_type_variation = "WindowButtonBottom2"
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"
    elif count < 4 and upgrade_maxed:
        $ActionContainer/AddButton.theme_type_variation = "WindowButtonBottom2"
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"
    else:
        $PanelContainer.theme_type_variation = "WindowPanelContainer"


func can_purchase() -> bool:
    if add_cost > Globals.currencies["money"]:
        return false

    return count < 4


func can_upgrade() -> bool:
    if upgrade_cost > Globals.currencies["money"]:
        return false

    return !upgrade_maxed


func add() -> void:
    count += 1

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(2, 2, 2), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    $TitlePanel/TitleContainer/Title.visible_ratio = 0
    tween = create_tween()
    tween.tween_property($TitlePanel/TitleContainer/Title, "visible_ratio", 1, 0.25)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.25)

    var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
    Signals.spawn_particle.emit(particle, global_position + size / 2)

    update_all()


func upgrade() -> void:
    level += 1

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(2, 2, 2), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    $TitlePanel/TitleContainer/Title.visible_ratio = 0
    tween = create_tween()
    tween.tween_property($TitlePanel/TitleContainer/Title, "visible_ratio", 1, 0.25)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.25)

    var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
    Signals.spawn_particle.emit(particle, global_position + size / 2)

    update_all()


func get_window_name() -> String:
    return super () + " " + tr("mk.") + str(level)


func _on_add_button_pressed() -> void:
    if can_purchase():
        Globals.currencies["money"] -= add_cost
        add()
        Sound.play("upgrade")
    Sound.play("click_toggle")


func _on_upgrade_button_pressed() -> void:
    if can_upgrade():
        Globals.currencies["money"] -= upgrade_cost
        upgrade()
        Sound.play("upgrade")
    Sound.play("click_toggle")


func _on_new_unlock(unlock: String) -> void:
    update_all()


func _on_attribute_changed() -> void:
    update_all()


func save() -> Dictionary:
    return super ().merged({
        "count": count,
        "level": level
    })
