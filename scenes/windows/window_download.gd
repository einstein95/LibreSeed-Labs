extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var download: = $PanelContainer / MainContainer / Download
@onready var file: = $PanelContainer / MainContainer / File
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float


func _ready() -> void :
    super ()
    Signals.tutorial_step.connect(_on_tutorial_step)
    Signals.connection_set.connect(_on_connection_set)
    Attributes.attributes["download_size_multiplier"].changed.connect(_on_download_size_changed)

    update_goal()
    update_tutorial()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, false) + "b"


func process(delta: float) -> void :
    progress += download.count * delta
    if progress >= goal:
        var count: float = floorf(progress / goal)
        file.add(count)
        Globals.stats.downloads += count
        progress = fmod(progress, goal)
        audio_player.play()
        if is_processing():
            file.animate_icon_in_pop(count)

    file.production = download.count / goal


func update_goal() -> void :
    goal = Utils.get_file_size(file.resource, file.variation) * Attributes.get_attribute("download_size_multiplier")
    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(goal, false) + "b"


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_DOWNLOADER:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / Download / InputConnector)
    elif Globals.tutorial_step == Utils.tutorial_steps.DRAG_FILE_CONNECTOR:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / File / OutputConnector)

    if Globals.tutorial_done:
        can_select = true
        can_drag = true
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
    else:
        can_select = false
        can_drag = false
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

    var downloads_steps: Array[int] = [Utils.tutorial_steps.CONNECT_DOWNLOADER]
    var file_steps: Array[int] = [Utils.tutorial_steps.DRAG_FILE_CONNECTOR, Utils.tutorial_steps.CONNECT_FILE]
    $PanelContainer / MainContainer / Download / InputConnector.disabled = !Globals.tutorial_done and !downloads_steps.has(Globals.tutorial_step)
    $PanelContainer / MainContainer / File / OutputConnector.disabled = !Globals.tutorial_done and !file_steps.has(Globals.tutorial_step)


func _on_download_size_changed() -> void :
    update_goal()


func _on_tutorial_step() -> void :
    update_tutorial()


func _on_connection_set() -> void :
    if Globals.connection_type == 1:
        if Globals.tutorial_step == Utils.tutorial_steps.DRAG_FILE_CONNECTOR:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_FILE_CONNECTOR + 1)
    elif Globals.connection_type == 0:
        if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_FILE:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_FILE_CONNECTOR)


func _on_download_connection_set() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_DOWNLOADER:
        Globals.set_tutorial_step(Utils.tutorial_steps.CONNECT_DOWNLOADER + 1)


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
