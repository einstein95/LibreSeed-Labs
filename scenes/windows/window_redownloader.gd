extends WindowIndexed

@onready var progress_label := $PanelContainer/MainContainer/Progress/ProgressContainer/ProgressLabel
@onready var progress_bar := $PanelContainer/MainContainer/Progress/ProgressBar
@onready var download := $PanelContainer/MainContainer/Download
@onready var file := $PanelContainer/MainContainer/File
@onready var output := $PanelContainer/MainContainer/Output
@onready var audio_player := $AudioStreamPlayer2D

var progress: float
var goal: float = 5


func _ready() -> void:
    super ()
    Attributes.attributes["download_size_multiplier"].changed.connect(_on_download_size_changed)

    update_type()


func _process(delta: float) -> void:
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, false) + "b"


func process(delta: float) -> void:
    if floorf(file.count) >= 1:
        progress += download.count * delta
        if progress >= goal:
            var count: float = file.pop(floorf(progress / goal))
            output.add(count)
            Globals.stats.redownloaded += count
            progress = fmod(progress, goal)

            Signals.redownloaded.emit(file, output, count)
            if is_processing():
                output.animate_icon_in_pop(count)
                audio_player.play()
    else:
        progress = 0

    output.production = min(download.count / goal, file.production)


func update_type() -> void:
    if Data.files.has(file.resource):
        goal = Utils.get_file_size(file.resource, file.variation) * Attributes.get_attribute("download_size_multiplier")

        if file.variation & Utils.file_variations.CORRUPTED:
            goal *= 0.5
    else:
        goal = 1

    $PanelContainer/MainContainer/Progress/ProgressContainer/SizeLabel.text = Utils.print_metric(goal, false) + "b"


func _on_file_resource_set() -> void:
    progress = 0
    output.set_resource(file.resource, (file.variation | Utils.file_variations.VALIDATED) & ~Utils.file_variations.CORRUPTED)
    update_type()


func _on_download_size_changed() -> void:
    update_type()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
