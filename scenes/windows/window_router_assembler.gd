extends WindowIndexed

@onready var production_label: = $PanelContainer / MainContainer / Progress / ProductionContainer / ProductionLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var power: = $PanelContainer / MainContainer / Power
@onready var pcb: = $PanelContainer / MainContainer / PCB
@onready var router: = $PanelContainer / MainContainer / Router
@onready var upgrade_button: = $UpgradeButton
@onready var audio_player: = $AudioStreamPlayer2D

var level: int
var maxed: bool
var cost: float
var progress: float
var speed: float
var goal: float = 1


func _ready() -> void :
    super ()
    update_all()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    production_label.text = Utils.print_string(speed / goal, false) + "/s"
    upgrade_button.disabled = !can_upgrade()


func process(delta: float) -> void :
    if power.count >= power.required:
        if pcb.count >= pcb.required:
            progress += speed * delta
            if progress >= goal:
                var count: float = min(progress / goal, pcb.count / pcb.required)
                router.add(count)
                Globals.stats.routers_assembled += count
                progress = fmod(progress, goal)
                pcb.pop(count * pcb.required)
                audio_player.play()
                if is_processing():
                    router.animate_icon_in_pop(count)
        else:
            progress = 0
        router.production = min(speed / goal, pcb.production / pcb.required)
    else:
        router.production = 0


func update_all() -> void :
    maxed = level >= 25
    if !maxed:
        cost = 2.5 * pow(10, 28) * pow(4.472, level + 1)

    speed = 0.05 * pow(4.6, level)
    power.limit = 200 * pow(1.2, level)
    power.set_required(power.limit)

    set_window_name(get_window_name())
    $UpgradeButton / UpgradeContainer / CostContainer / Label.text = Utils.print_string(cost, true)
    $UpgradeButton.visible = !maxed

    if maxed:
        $PanelContainer.theme_type_variation = "WindowPanelContainer"
    else:
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"


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


func can_upgrade() -> bool:
    if cost > Globals.currencies["money"]: return false

    return !maxed


func _on_upgrade_button_pressed() -> void :
    if can_upgrade():
        Globals.currencies["money"] -= cost
        upgrade()
        Sound.play("upgrade")
    Sound.play("click_toggle")


func save() -> Dictionary:
    return super ().merged({
        "level": level, 
        "progress": progress
    })
