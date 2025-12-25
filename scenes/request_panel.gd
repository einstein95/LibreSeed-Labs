extends Panel

@onready var progress_bar := $InfoContainer/ProgressBar
@onready var progress_label := $InfoContainer/NameContainer/Count

var file: String
var req: float
var req_str: String
var completed: bool
var unlocked: bool


func _ready() -> void:
    Signals.new_unlock.connect(_on_new_unlock)
    Signals.new_request.connect(_on_new_request)
    Signals.request_claimed.connect(_on_request_claimed)

    file = Data.requests[name].file

    $IconPanel/Icon.texture = load("res://textures/icons/" + Data.files[file].icon + ".png")
    $Claim/RewardContainer/Label.text = "%.0f" % Data.requests[name].reward
    req = Data.requests[name].goal * 10 ** Data.requests[name].goal_e
    req_str = Utils.print_string(req, true)

    set_process(is_visible_in_tree())
    update_all()


func _process(delta: float) -> void:
    if !completed:
        var progress: float = Globals.request_progress[name]
        progress_bar.value = progress / req
        progress_label.text = Utils.print_string(progress, true) + "/" + req_str


func update_all() -> void:
    unlocked = is_unlocked()
    completed = Globals.requests[name] >= 1
    var claimed: bool = Globals.requests[name] == 2
    $Claim.disabled = !completed or claimed

    $InfoContainer/NameContainer/Name.text = tr(Data.files[file].name)
    var symbol: String = Utils.get_resource_symbols(Data.resources[file].symbols, Data.requests[name].variation.bin_to_int())
    if !symbol.is_empty():
        $InfoContainer/NameContainer/Name.text += " " + symbol

    if claimed:
        theme_type_variation = "MenuPanelTitle"
    elif completed:
        theme_type_variation = "MenuPanelTitle"
    else:
        theme_type_variation = "MenuPanelTitleDisabled"

    if completed:
        progress_bar.value = 1
        progress_label.text = "completed"

    visible = unlocked


func is_unlocked() -> bool:
    if Data.requests[name].requirement.is_empty():
        return true
    for i: String in Data.requests[name].requirement:
        if Globals.unlocks[i]:
            return true

    return false


func _on_new_request(request: String) -> void:
    update_all()


func _on_request_claimed(request: String) -> void:
    update_all()


func _on_new_unlock(unlock: String) -> void:
    update_all()


func _on_visibility_changed() -> void:
    set_process(is_visible_in_tree())


func _on_claim_pressed() -> void:
    Globals.claim_request(name)

    Signals.currency_popup.emit("token", Data.requests[name].reward)
    Signals.currency_popup_particle.emit("token", get_global_mouse_position())
    $AnimationPlayer.play("Claim")
    Sound.play("claim")
