extends WindowIndexed

@onready var progress_label: = $PanelContainer / MainContainer / Progress / ProgressContainer / ProgressLabel
@onready var progress_bar: = $PanelContainer / MainContainer / Progress / ProgressBar
@onready var upload: = $PanelContainer / MainContainer / Upload
@onready var file: = $PanelContainer / MainContainer / File
@onready var request_status: = $PanelContainer / MainContainer / Request / Info / Status
@onready var request_bar: = $PanelContainer / MainContainer / RequestProgressBar
@onready var audio_player: = $AudioStreamPlayer2D

var valid: bool
var completed: bool
var request: String
var progress: float
var goal: float = 5
var request_goal: float


func _ready() -> void :
    super ()
    Attributes.attributes["upload_size_multiplier"].changed.connect(_on_upload_size_changed)
    Signals.new_request.connect(_on_new_request)
    Signals.new_unlock.connect(_on_new_unlock)

    update_goal()
    update_request()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, progress / goal, 1.0 - exp(-50.0 * delta))
    progress_label.text = Utils.print_metric(progress, false) + "b"
    if valid:
        request_bar.value = lerpf(request_bar.value, Globals.request_progress[request] / request_goal, 1.0 - exp(-50.0 * delta))
        if completed:
            request_status.text = "completed"
        else:
            request_status.text = Utils.print_string(Globals.request_progress[request], true) + "/" + Utils.print_string(request_goal, true)
    else:
        request_bar.value = 0


func process(delta: float) -> void :
    if !valid or completed: return
    if floorf(file.count) >= 1:
        progress += upload.count * delta
        if progress >= goal:
            var count: float = file.pop(floorf(progress / goal))
            Globals.request_progress[request] += count
            progress = fmod(progress, goal)
            audio_player.play()
    else:
        progress = 0


func update_goal() -> void :
    if Data.files.has(file.resource):
        goal = Utils.get_file_size(file.resource, file.variation) * Attributes.get_attribute("upload_size_multiplier")
    else:
        goal = 1

    $PanelContainer / MainContainer / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(goal, false) + "b"


func update_request() -> void :
    request = ""
    if Data.files.has(file.resource):
        for i: String in Data.requests:
            if !is_request_unlocked(i): continue
            if Data.requests[i].file != file.resource: continue
            if !Data.requests[i].variation.is_empty() and !file.variation & Data.requests[i].variation.bin_to_int(): continue
            request = i
            if Globals.requests[request] == 0: break

    valid = !request.is_empty()

    if valid:
        var file: String = Data.requests[request].file
        var file_name: String = tr(Data.files[file].name)
        file_name += " " + Utils.get_resource_symbols(Data.resources[file].symbols, Data.requests[request].variation.bin_to_int())
        $PanelContainer / MainContainer / Request / Info / Name.text = file_name
        request_goal = Data.requests[request].goal * 10 ** Data.requests[request].goal_e
        completed = Globals.requests[request] > 0
    else:
        request_goal = 1
        $PanelContainer / MainContainer / Request / Info / Name.text = "invalid_request"
        $PanelContainer / MainContainer / Request / Info / Status.text = "invalid_request_desc"


func is_request_unlocked(r: String) -> bool:
    if Data.requests[r].requirement.is_empty(): return true
    for i: String in Data.requests[r].requirement:
        if Globals.unlocks[i]: return true

    return false


func _on_file_resource_set() -> void :
    progress = 0

    update_request()


func _on_upload_size_changed() -> void :
    update_goal()


func _on_new_request(r: String) -> void :
    if request == r:
        update_request()


func _on_new_unlock(unlock: String) -> void :
    if valid and !completed: return
    update_request()


func save() -> Dictionary:
    return super ().merged({
        "progress": progress
    })
