extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var upload: = $PanelContainer / MainContainer / Upload
@onready var file: = $PanelContainer / MainContainer / File
@onready var result: = $PanelContainer / MainContainer / Result
@onready var infections: = $PanelContainer / MainContainer / Infections
@onready var audio_player: = $AudioStreamPlayer2D

var progress: float
var goal: float = 5
var base_value: float
var base_infection: float
var multipliers: Array[String]
var multiplier: float


func _ready() -> void :
    super ()
    Signals.connection_set.connect(_on_connection_set)
    Signals.tutorial_step.connect(_on_tutorial_step)
    Attributes.attributes["upload_size_multiplier"].changed.connect(_on_upload_size_changed)

    if !Globals.tutorial_done and Globals.tutorial_step <= Utils.tutorial_steps.ADD_UPLOADER:
        Globals.set_tutorial_step(Utils.tutorial_steps.ADD_UPLOADER + 1)

    update_type()
    update_tutorial()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, false) + "b"


func process(delta: float) -> void :
    multiplier = 1.0
    for i: String in multipliers:
        multiplier *= Attributes.get_attribute(i)
    if floorf(file.count) >= 1:
        progress += upload.count * delta
        if progress >= goal:
            var count: float = file.pop(floorf(progress / goal))
            var value: float = count * base_value * multiplier
            var infected: float = count * base_infection
            result.add(value)
            infections.add(infected)

            if result.resource == "money":
                Globals.max_money += value
                Globals.stats.max_money += value
            Globals.stats.uploads += count

            Signals.uploaded.emit(file, count)
            progress = fmod(progress, goal)
            audio_player.play()
            if is_processing():
                result.animate_icon_in()
                infections.animate_icon_in()
    else:
        progress = 0

    result.production = min(upload.count / goal, file.production) * base_value * multiplier
    infections.production = min(upload.count / goal, file.production) * base_infection


func grab(g: bool) -> void :
    if g:
        if Globals.tutorial_step == Utils.tutorial_steps.DRAG_UPLOADER:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_UPLOADER + 1)
    else:
        if !g:
            if Globals.tutorial_step == Utils.tutorial_steps.MOVE_UPLOADER:
                if Rect2(-225, 150, 450, 500).encloses(get_rect()):
                    Globals.set_tutorial_step(Utils.tutorial_steps.MOVE_UPLOADER + 1)
                else:
                    Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_UPLOADER)
    super (g)


func update_type() -> void :
    multipliers.clear()
    if Data.files.has(file.resource):
        goal = Utils.get_file_size(file.resource, file.variation) * Attributes.get_attribute("upload_size_multiplier")
        base_value = Utils.get_file_value(file.resource, file.variation)
        if file.variation & Utils.file_variations.HACKED:
            base_infection = Data.files[file.resource].research * Utils.get_variation_value_multiplier(file.variation)
        else:
            base_infection = 0

        if result.resource == "money":
            multipliers.append("income_multiplier")
            multipliers.append("upload_value_multiplier")
            multipliers.append(Data.files[file.resource].attribute)
            if file.variation & Utils.file_variations.AI:
                multipliers.append(Data.files[file.resource].ai_attribute)
    else:
        goal = 1
        base_value = 0

    if file.variation & Utils.file_variations.HACKED:
        infections.visible = true
    else:
        infections.visible = false
    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(goal, false) + "b"


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.DRAG_UPLOADER:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($TitlePanel)
    elif Globals.tutorial_step == Utils.tutorial_steps.CONNECT_FILE:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / File / InputConnector)
    elif Globals.tutorial_step == Utils.tutorial_steps.CONNECT_UPLOADER:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / Upload / InputConnector)
    elif Globals.tutorial_step == Utils.tutorial_steps.DRAG_MONEY_CONNECTOR:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / Result / OutputConnector)

    var title_steps: Array[int] = [Utils.tutorial_steps.DRAG_UPLOADER, Utils.tutorial_steps.MOVE_UPLOADER]

    if Globals.tutorial_done:
        can_drag = true
        can_select = true
        can_delete = true
        can_pause = true
    else:
        can_drag = title_steps.has(Globals.tutorial_step)
        can_select = false
        can_delete = false
        can_pause = false

    if !Globals.tutorial_done and !title_steps.has(Globals.tutorial_step):
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
    else:
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP

    var upload_steps: Array[int] = [Utils.tutorial_steps.CONNECT_UPLOADER]
    var file_steps: Array[int] = [Utils.tutorial_steps.CONNECT_FILE]
    var money_steps: Array[int] = [Utils.tutorial_steps.DRAG_MONEY_CONNECTOR, Utils.tutorial_steps.CONNECT_MONEY]
    $PanelContainer / MainContainer / Upload / InputConnector.disabled = !Globals.tutorial_done and !upload_steps.has(Globals.tutorial_step)
    $PanelContainer / MainContainer / File / InputConnector.disabled = !Globals.tutorial_done and !file_steps.has(Globals.tutorial_step)
    $PanelContainer / MainContainer / Result / OutputConnector.disabled = !Globals.tutorial_done and !money_steps.has(Globals.tutorial_step)


func _on_file_resource_set() -> void :
    progress = 0
    result.set_resource(Data.files[file.resource].upload)

    update_type()


func _on_upload_size_changed() -> void :
    update_type()


func _on_tutorial_step() -> void :
    update_tutorial()


func _on_connection_set() -> void :
    if Globals.connection_type == 1:
        if Globals.tutorial_step == Utils.tutorial_steps.DRAG_MONEY_CONNECTOR:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_MONEY_CONNECTOR + 1)
    elif Globals.connection_type == 0:
        if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_MONEY:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_MONEY_CONNECTOR)


func _on_upload_connection_set() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_UPLOADER:
        Globals.set_tutorial_step(Utils.tutorial_steps.CONNECT_UPLOADER + 1)


func _on_file_connection_set() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_FILE:
        Globals.set_tutorial_step(Utils.tutorial_steps.CONNECT_FILE + 1)


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
