extends WindowIndexed

@onready var progress_bar := $PanelContainer/MainContainer/ProgressBar
@onready var research_power := $PanelContainer/MainContainer/ResearchPower
@onready var boost := $PanelContainer/MainContainer/Boost
@onready var file := $PanelContainer/MainContainer/File
@onready var points := $PanelContainer/MainContainer/Points
@onready var upgrade_button := $UpgradeButton
@onready var audio_player := $AudioStreamPlayer2D

var level: int
var progress: float
var cost: float
var speed: float
var base_research: float
var maxed: bool


func _ready() -> void:
    super ()
    Attributes.attributes["price_multiplier"].changed.connect(_on_attribute_changed)
    Signals.new_unlock.connect(_on_new_unlock)

    update_all()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress, 1.0 - exp(-50.0 * delta))
    upgrade_button.disabled = !can_upgrade()


func process(delta: float) -> void:
    var multiplier: float = base_research * Attributes.get_attribute("research_multiplier")
    research_power.count = speed * (1 + boost.count) * Attributes.get_attribute("research_speed_multiplier")

    if floorf(file.count) >= 1:
        progress += research_power.count * delta
        if progress >= 1.0:
            var count: float = file.pop(floorf(progress))
            var value: float = count * multiplier
            points.add(value)
            Globals.max_research += value
            Globals.stats.max_research += value
            Globals.stats.researched += count
            progress = fmod(progress, 1.0)
            audio_player.play()
            if is_processing():
                points.animate_icon_in_pop(value)
    else:
        progress = 0

    points.production = min(research_power.count, file.production) * multiplier


func update_all() -> void:
    maxed = level >= 200
    cost = 2 * pow(10, 9) * pow(4, level + 1) * Attributes.get_attribute("price_multiplier")

    speed = 0.2 * pow(2, level)
    set_window_name(get_window_name())
    $UpgradeButton/UpgradeContainer/CostContainer/Label.text = Utils.print_string(cost, true)

    if Data.files.has(file.resource):
        base_research = Data.files[file.resource].research * Utils.get_variation_research_multiplier(file.variation)
        if file.variation & Utils.file_variations.ANALYZED:
            speed *= 2
    else:
        base_research = 0

    boost.visible = Globals.unlocks["research.agi"]
    $UpgradeButton.visible = !maxed
    if maxed:
        $PanelContainer.theme_type_variation = "WindowPanelContainer"
    else:
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"


func can_upgrade() -> bool:
    if cost > Globals.currencies["money"]:
        return false

    return !maxed


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
    return super () + " " + tr("lv.") + " " + str(level + 1)


func _on_file_resource_set() -> void:
    update_all()


func _on_upgrade_button_pressed() -> void:
    if can_upgrade():
        Globals.currencies["money"] -= cost
        upgrade()
        Sound.play("upgrade")
    Sound.play("click_toggle")


func _on_attribute_changed() -> void:
    update_all()


func _on_new_unlock(unlock: String) -> void:
    update_all()


func save() -> Dictionary:
    return super ().merged({
        "level": level,
        "progress": progress
    })
