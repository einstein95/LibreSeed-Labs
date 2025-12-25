extends WindowIndexed

@export var upgrade: String
@export var lvl_multiplier: float
@onready var audio_player := $AudioStreamPlayer2D
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var cost := $PanelContainer/MainContainer/Cost
@onready var boost := $PanelContainer/MainContainer/Boost

var multiplier: float


func _ready() -> void:
    super ()
    Signals.new_upgrade.connect(_on_new_upgrade)

    update_upgrade()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, cost.count / cost.required, 1.0 - exp(-50.0 * delta))


func process(delta: float) -> void:
    var levels: int
    while cost.count >= cost.required:
        levels += 1
        cost.pop(cost.required)
        cost.required *= Data.upgrades[upgrade].cost_inc

    if levels > 0:
        Globals.add_upgrade(upgrade, levels)

        var tween: Tween = create_tween()
        tween.tween_property(self, "modulate", Color(2, 2, 2), 0.2)
        tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

        tween = create_tween()
        tween.set_trans(Tween.TRANS_QUAD)
        tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
        tween.tween_property(self, "scale", Vector2(1, 1), 0.25)

        audio_player.play()

    boost.count = multiplier


func update_upgrade() -> void:
    cost.set_required(floorf(Data.upgrades[upgrade].cost * pow(10, Data.upgrades[upgrade].cost_e) * pow(Data.upgrades[upgrade].cost_inc, Globals.upgrades[upgrade])))
    multiplier = lvl_multiplier ** Globals.upgrades[upgrade]
    $PanelContainer/MainContainer/Progress/ProgressContainer/LevelLabel.text = str(Globals.upgrades[upgrade])


func _on_new_upgrade(u: String, levels: int) -> void:
    if u != upgrade:
        return

    update_upgrade()
