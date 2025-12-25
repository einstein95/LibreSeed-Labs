extends WindowIndexed

@onready var code_speed := $PanelContainer/MainContainer/CodeSpeed
@onready var boost := $PanelContainer/MainContainer/Boost
@onready var contribution := $PanelContainer/MainContainer/Contribution
@onready var progress_bar := $PanelContainer/MainContainer/ProgressBar

var speed: float
var required: float


func _ready() -> void:
    super ()
    Signals.new_code_level.connect(_on_new_code_level)
    Signals.new_unlock.connect(_on_new_unlock)

    update_all()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, contribution.count / required, 1.0 - exp(-50.0 * delta))


func process(delta: float) -> void:
    code_speed.count = speed * (1 + boost.count) * Attributes.get_attribute("code_speed_multiplier")

    var levels: int
    while contribution.count >= required:
        levels += 1
        contribution.count -= required
        required *= 3

    if levels > 0:
        Globals.add_code_levels(levels)


func update_all() -> void:
    speed = 2 * pow(1.5, Globals.code_level)

    required = Globals.get_code_required_exp(Globals.code_level)
    contribution.set_required(required)

    boost.visible = Globals.unlocks["research.agi"]

    set_window_name(get_window_name())


func get_window_name() -> String:
    return super () + " " + tr("lv.") + " " + str(Globals.code_level + 1)


func _on_new_code_level() -> void:
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
