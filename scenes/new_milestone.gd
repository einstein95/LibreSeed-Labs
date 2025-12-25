extends HBoxContainer


func _ready() -> void:
    Signals.milestone_queued.connect(_on_milestone_queued)
    $Icon.texture = load("res://textures/icons/" + Data.milestones[name].icon + ".png")

    update_all()


func update_all() -> void:
    $Level.text = tr("lv.") + " " + str(Globals.milestones[name])
    $NewLevel.text = str(Globals.milestones[name] + Globals.q_milestones[name])


func _on_visibility_changed() -> void:
    update_all()


func _on_milestone_queued(milestone: String, levels: int) -> void:
    update_all()
