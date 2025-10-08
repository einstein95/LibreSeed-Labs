extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var download: = $PanelContainer / MainContainer / Download
@onready var upload: = $PanelContainer / MainContainer / Upload
@onready var money: = $PanelContainer / MainContainer / Money
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float = 4


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, false) + "b"


func process(delta: float) -> void :
    var multiplier: float = Attributes.get_attribute("bandwidth_value_multiplier") * Attributes.get_attribute("income_multiplier")
    progress += (upload.count + download.count) * delta
    if progress >= goal:
        var count: float = (progress / goal) * multiplier
        money.add(count)
        Globals.max_money += count
        Globals.stats.max_money += count
        progress = fmod(progress, goal)
        audio_player.play()
        if is_processing():
            money.animate_icon_in_pop(count)

    money.production = (download.count + upload.count) * multiplier / goal
