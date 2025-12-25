extends WindowIndexed

const upgrades: Dictionary = {
    "code_optimization": "optimization",
    "code_application": "application",
    "code_driver": "driver"
}

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/Amount
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var code := $PanelContainer/MainContainer/Code
@onready var points := $PanelContainer/MainContainer/Points

var valid: bool
var base_progress: float
var progress: float
var goal: float
var goal_str: String
var upgrade: String


func _ready() -> void:
    super ()
    Signals.new_upgrade.connect(_on_new_upgrade)

    update_upgrade()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, true) + "/" + goal_str


func process(delta: float) -> void:
    if !valid:
        return

    if floorf(code.count) > 0:
        var times: float = code.pop(floorf(code.count))
        progress += times * base_progress
        var levels: int
        while progress >= goal:
            levels += 1
            progress -= goal
            goal *= Data.upgrades[upgrade].cost_inc
        if levels > 0:
            Globals.add_upgrade(upgrade, levels)

            if upgrade == "optimization":
                Globals.currencies["optimization_point"] += levels
                Signals.notify.emit("work", "new_optimization_point")
                Sound.play("new_level")
            elif upgrade == "application":
                Globals.currencies["application_point"] += levels
                Signals.notify.emit("bracket", "new_application_point")
                Sound.play("new_level")
            animate()


func update_upgrade() -> void:
    valid = upgrades.has(code.resource)
    $PanelContainer/MainContainer/Progress.visible = valid
    $PanelContainer/MainContainer/Points.visible = valid

    if valid:
        upgrade = upgrades[code.resource]
        $PanelContainer/MainContainer/Upgrade/Info/Name.text = Data.upgrades[upgrade].name
        $PanelContainer/MainContainer/Points/ResourceButton/Icon.texture = load("res://textures/icons/" + Data.upgrades[upgrade].icon + ".png")

        match upgrade:
            "optimization":
                $PanelContainer/MainContainer/Points/Info/Name.text = "optimization_points"
            "application":
                $PanelContainer/MainContainer/Points/Info/Name.text = "application_points"
            "driver":
                $PanelContainer/MainContainer/Points/Info/Name.text = "hardware_multiplier"
    else:
        $PanelContainer/MainContainer/Upgrade/Info/Name.text = "invalid_project"

    update_level()


func update_level() -> void:
    if valid:
        base_progress = Utils.get_code_value_multiplier(code.variation)
        goal = Data.upgrades[upgrade].cost * 10 ** Data.upgrades[upgrade].cost_e
        goal *= Data.upgrades[upgrade].cost_inc ** Globals.upgrades[upgrade]

        goal_str = Utils.print_string(goal, true)

        if upgrade == "driver":
            $PanelContainer/MainContainer/Upgrade/Info/Version.text = tr("version") + " %.0f.0" % (Globals.upgrades[upgrade] + 1)
            $PanelContainer/MainContainer/Points/Info/Count.text = Utils.print_string(1.2 ** Globals.upgrades[upgrade], false) + "x"
        else:
            $PanelContainer/MainContainer/Upgrade/Info/Version.text = tr("lv.") + " %.0f" % (Globals.upgrades[upgrade])
            $PanelContainer/MainContainer/Points/Info/Count.text = "+%.0f" % Globals.upgrades[upgrade]
    else:
        $PanelContainer/MainContainer/Upgrade/Info/Version.text = "invalid_project_desc"


func animate() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(2, 2, 2), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.25)

    var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
    Signals.spawn_particle.emit(particle, global_position + size / 2)


func _on_code_resource_set() -> void:
    update_upgrade()


func _on_new_upgrade(upgrade: String, levels: int) -> void:
    update_level()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
