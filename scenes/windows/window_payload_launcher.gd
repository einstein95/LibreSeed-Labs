extends WindowIndexed

@export var multiplier: float
@export var attribute: String
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var hack_power := $PanelContainer/MainContainer/HackPower
@onready var damage := $PanelContainer/MainContainer/Damage

var progress: float
var goal: float


func _ready() -> void:
    super ()
    Attributes.attributes["breach_speed_multiplier"].changed.connect(_on_attribute_changed)

    update_goal()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))


func process(delta: float) -> void:
    damage.count = 0
    var effective_damage: float = hack_power.count * multiplier
    var speed: float = Attributes.get_attribute("breach_speed_multiplier")
    damage.limit = effective_damage * Attributes.get_attribute(attribute)
    if hack_power.count > 0:
        progress += speed * delta
        if progress >= goal:
            damage.add(damage.limit)
            progress = fmod(progress, goal)
            if is_processing():
                damage.animate_icon_in()

    damage.production = damage.limit * speed / goal


func update_goal() -> void:
    goal = 1.0 / Attributes.get_attribute("breach_speed_multiplier")
    $PanelContainer/MainContainer/Progress/SpeedContainer/SpeedLabel.text = Utils.print_string(goal, false) + "/s"


func _on_attribute_changed() -> void:
    update_goal()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
