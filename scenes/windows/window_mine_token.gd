extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var gpu: = $PanelContainer / MainContainer / GPU
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float


func _ready() -> void :
    super ()

    update_all()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_string(progress, false) + "C"


func process(delta: float) -> void :
    progress += gpu.count * delta
    var levels: int
    while progress >= goal:
        levels += 1
        progress -= goal
        goal *= 1.071

    if levels > 0:
        var amount: float = 1 * levels
        Globals.mined_tokens += amount
        Globals.currencies["token"] += amount
        Globals.stats.max_tokens += amount
        audio_player.play()
        Signals.currency_popup.emit("token", amount)
        update_all()


func update_all() -> void :
    goal = 5000000000000.0 * (1.071 ** Globals.mined_tokens)
    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_string(goal, false) + "C"
    $PanelContainer / MainContainer / Tokens / Info / Count.text = Utils.print_string(Globals.mined_tokens)


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
