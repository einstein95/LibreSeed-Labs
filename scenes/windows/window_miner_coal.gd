extends WindowIndexed

@onready var coal: = $PanelContainer / MainContainer / Coal
@onready var upgrade_button: = $UpgradeButton

var level: int
var maxed: bool
var cost: float
var speed: float


func _ready() -> void :
    super ()
    update_all()


func _process(delta: float) -> void :
    super (delta)
    upgrade_button.disabled = !can_upgrade()


func process(delta: float) -> void :
    coal.add(speed * delta)
    coal.production = speed


func update_all() -> void :
    maxed = level >= 25
    if !maxed:
        cost = 3.5 * pow(10, 27) * pow(3.16, level + 1)

    speed = 20000 * pow(3.16, level)
    set_window_name(get_window_name())
    $UpgradeButton / UpgradeContainer / CostContainer / Label.text = Utils.print_string(cost, true)
    $UpgradeButton.visible = !maxed

    if maxed:
        $PanelContainer.theme_type_variation = "WindowPanelContainer"
    else:
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"


func can_upgrade() -> bool:
    if cost > Globals.currencies["money"]: return false

    return !maxed


func upgrade() -> void :
    level += 1

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(2, 2, 2), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    $TitlePanel / TitleContainer / Title.visible_ratio = 0
    tween = create_tween()
    tween.tween_property($TitlePanel / TitleContainer / Title, "visible_ratio", 1, 0.25)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.25)

    var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
    Signals.spawn_particle.emit(particle, global_position + size / 2)

    update_all()


func get_window_name() -> String:
    return super () + " " + tr("mk.") + str(level)


func _on_upgrade_button_pressed() -> void :
    if can_upgrade():
        Globals.currencies["money"] -= cost
        upgrade()
        Sound.play("upgrade")
    Sound.play("click_toggle")


func save() -> Dictionary:
    return super ().merged({
        "level": level
    })
