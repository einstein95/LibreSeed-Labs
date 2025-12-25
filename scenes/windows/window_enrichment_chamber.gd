extends WindowIndexed

@onready var progress_bar := $PanelContainer/MainContainer/Production/ProgressBar
@onready var production_label := $PanelContainer/MainContainer/Production/ProductionContainer/ProductionLabel
@onready var power := $PanelContainer/MainContainer/Power
@onready var coal := $PanelContainer/MainContainer/Coal
@onready var enriched_coal := $PanelContainer/MainContainer/EnrichedCoal

var speed: float = 1
var progress: float
var goal: float = 1


func _ready() -> void:
    super ()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))


func process(delta: float) -> void:
    if coal.count >= coal.required and power.count >= power.required:
        progress += speed * delta
        if progress >= goal:
            var count: float = min(progress / goal, coal.count / coal.required)
            enriched_coal.add(count)
            progress = fmod(progress, goal)
            coal.pop(count * coal.required)
            if is_processing():
                enriched_coal.animate_icon_in_pop(count)
        enriched_coal.production = min(speed / goal, coal.production / coal.required)
    else:
        progress = 0
        enriched_coal.production = 0
