extends WindowIndexed

@onready var hack_power := $PanelContainer/MainContainer/HackPower
@onready var boost := $PanelContainer/MainContainer/Boost
@onready var trojan := $PanelContainer/MainContainer/Trojan
@onready var experience := $PanelContainer/MainContainer/Experience
@onready var progress_bar := $PanelContainer/MainContainer/ProgressBar

var power: float
var production: float
var required: float


func _ready() -> void:
    super ()
    Signals.new_hack_level.connect(_on_new_hack_level)
    Signals.new_unlock.connect(_on_new_unlock)

    update_all()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, experience.count / required, 1.0 - exp(-50.0 * delta))


func process(delta: float) -> void:
    hack_power.count = power * (1 + boost.count) * Attributes.get_attribute("hack_power_multiplier")
    trojan.production = production * Attributes.get_attribute("trojan_multiplier")
    trojan.add(production * delta)

    var levels: int
    while experience.count >= required:
        levels += 1
        experience.count -= required
        required *= 4

    if levels > 0:
        Globals.add_hack_levels(levels)


func update_all() -> void:
    power = 10.0 * 1.5 ** Globals.hack_level
    production = 2.0 ** Globals.hack_level

    required = Globals.get_hack_required_exp(Globals.hack_level)
    experience.set_required(required)

    boost.visible = Globals.unlocks["research.agi"]
    trojan.visible = Globals.unlocks["research.trojan"]

    set_window_name(get_window_name())


func get_window_name() -> String:
    return super () + " " + tr("lv.") + str(Globals.hack_level)


func _on_new_hack_level() -> void:
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


func _on_new_unlock(unlock: String) -> void:
    update_all()
