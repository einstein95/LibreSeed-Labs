extends WindowIndexed

const goals: Dictionary = {"code_bugfix": 4, "code_optimization": 6, "code_application": 20, 
"code_driver": 80}

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var code_speed: = $PanelContainer / MainContainer / CodeSpeed
@onready var code: = $PanelContainer / MainContainer / Code
@onready var fixed: = $PanelContainer / MainContainer / Fixed
@onready var bugged: = $PanelContainer / MainContainer / Bugged
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float = 5


func _ready() -> void :
    super ()

    update_goal()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "ops"


func process(delta: float) -> void :
    if floorf(code.count) >= 1:
        progress += code_speed.count * delta
        if progress >= goal:
            var count: float = code.pop(floorf(progress / goal))

            var fixed_count: float = floorf(count * 0.5)
            var bugged_count: float = floorf(count * 0.5)

            if count > fixed_count + bugged_count:
                if randf() < 0.5:
                    fixed_count += 1.0
                else:
                    bugged_count += 1.0

            fixed.add(fixed_count)
            bugged.add(bugged_count)

            progress = fmod(progress, goal)

            if is_processing():
                if fixed_count > 0:
                    fixed.animate_icon_in()
                if bugged_count > 0:
                    bugged.animate_icon_in()
                audio_player.play()
    else:
        progress = 0

    fixed.production = min(code_speed.count / goal, code.production) * 0.5
    bugged.production = min(code_speed.count / goal, code.production) * 0.5


func update_goal() -> void :
    if !goals.has(code.resource): return
    goal = goals[code.resource]

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "ops"


func _on_code_resource_set() -> void :
    progress = 0

    if code.variation == 0:
        fixed.set_resource(code.resource, Utils.code_variations.FIXED)
        bugged.set_resource(code.resource, Utils.code_variations.BUGGED)
    else:
        fixed.set_resource(code.resource, code.variation)
        bugged.set_resource(code.resource, code.variation)


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
