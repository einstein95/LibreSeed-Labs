extends Panel

@onready var purchase_button := $Purchase
@onready var duration_label := $IconPanel/Duration

var owned: bool
var obj: Node


func _ready() -> void:
    Signals.new_level.connect(_on_new_level)
    obj = get_node("/root/Main/Boosts/" + name)
    obj.apply_set.connect(_on_apply_set)

    update_all()


func _process(delta: float) -> void:
    var time: float = Globals.boosts[name].time
    purchase_button.disabled = !can_purchase()

    if time > 1000000000000.0:
        duration_label.text = "∞"
    elif time > 3600:
        duration_label.text = "+60m"
    elif time > 0.0:
        duration_label.text = "%02.f:%02.f" % [floor(time / 60), int(time) % 60]
    else:
        duration_label.text = "--"


func update_all() -> void:
    var time: float = Globals.boosts[name].time
    $InfoContainer/Name.text = tr(Data.boosts[name].name)
    $InfoContainer/Description.text = tr(Data.boosts[name].description)
    $IconPanel/Icon.texture = load("res://textures/icons/" + Data.boosts[name].icon + ".png")

    $Purchase/CostContainer/Label.text = Utils.print_string(Data.boosts[name].cost, true)
    $Pause.disabled = time <= 0

    if Globals.boosts[name].applied:
        $Pause.icon = load("res://textures/icons/pause.png")
    else:
        $Pause.icon = load("res://textures/icons/play.png")

    update_visibility()


func update_visibility() -> void:
    visible = get_visibility()


func get_visibility() -> bool:
    if !Data.boosts[name].requirement.is_empty() and !Globals.unlocks[Data.boosts[name].requirement]:
        return false

    if Data.boosts[name].level > Globals.money_level:
        return false

    return true


func can_purchase() -> bool:
    if Data.boosts[name].cost > Globals.currencies["token"]:
        return false

    if owned:
        return false

    return true


func _on_visibility_changed() -> void:
    update_all()


func _on_purchase_pressed() -> void:
    if can_purchase():
        obj.add(Data.boosts[name].duration)
        Globals.currencies["token"] -= Data.boosts[name].cost
    Sound.play("research")


func _on_pause_pressed() -> void:
    if Globals.boosts[name].time > 0:
        if Globals.boosts[name].applied:
            obj.remove()
        else:
            obj.apply()
    Sound.play("click2")


func _on_new_level() -> void:
    update_visibility()


func _on_apply_set() -> void:
    update_all()
