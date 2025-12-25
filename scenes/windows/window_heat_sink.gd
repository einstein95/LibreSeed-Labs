extends WindowIndexed

const names: Array[String] = ["window_heat_sink", "window_air_cooler", "window_water_cooler",
"window_jet_cooler", "window_cryo_cooler", "window_thermal_field_generator"]

@onready var upgrade_button := $UpgradeButton

var level: int
var input: Array[ResourceContainer]
var cost: float
var maxed: bool
var limit: float


func _ready() -> void:
    super ()
    Attributes.attributes["price_multiplier"].changed.connect(_on_attribute_changed)

    for resource: ResourceContainer in $PanelContainer/MainContainer.get_children():
        input.append(resource)

    update_all()


func _process(delta: float) -> void:
    super (delta)
    upgrade_button.disabled = !can_upgrade()


func process(delta: float) -> void:
    for i: ResourceContainer in input:
        i.pop_all()


func update_all() -> void:
    limit = 50 * pow(2, level)
    cost = 1.0000000000000001e+33 * pow(1000, level) * Attributes.get_attribute("price_multiplier")
    maxed = level >= names.size() - 1

    $UpgradeButton/UpgradeContainer/CostContainer/Label.text = Utils.print_string(cost)
    $UpgradeButton.visible = !maxed

    if !maxed:
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"
    else:
        $PanelContainer.theme_type_variation = "WindowPanelContainer"

    set_window_name(get_window_name())
    update_limits()
    update_visible_inputs()


func update_visible_inputs() -> void:
    var has_free_input: bool = false

    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if !i.get_node("InputConnector").has_connection():
            has_free_input = true
            break

    var shown_invalid: bool = false
    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if i.get_node("InputConnector").has_connection():
            i.visible = true
        else:
            i.visible = !shown_invalid
            shown_invalid = true

    Signals.window_moved.emit(self)


func update_limits() -> void:
    var connected: int
    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if !i.input_id.is_empty():
            connected += 1

    if connected > 0:
        for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
            i.limit = limit / connected
            i.set_required(i.limit)


func can_upgrade() -> bool:
    if cost > Globals.currencies["money"]:
        return false

    return !maxed


func upgrade(levels: int) -> void:
    level += levels

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
    return tr(names[level])


func _on_connection_set() -> void:
    update_visible_inputs()
    update_limits()


func _on_upgrade_button_pressed() -> void:
    if can_upgrade():
        Globals.currencies["money"] -= cost
        upgrade(1)
        Sound.play("upgrade")
    Sound.play("click_toggle")


func _on_attribute_changed() -> void:
    update_all()


func save() -> Dictionary:
    return super ().merged({
        "level": level
    })
