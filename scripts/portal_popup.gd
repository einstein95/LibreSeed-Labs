extends PanelContainer


func _ready() -> void :
    Signals.milestone_queued.connect(_on_milestone_queued)

    for i: String in Globals.q_milestones:
        if !Data.milestones.has(i): continue
        if Globals.q_milestones[i] > 0:
            queue_milestone(i)

    if $PortalContainer / MainPanel / InfoContainer / Milestones.get_child_count() > 0:
        $PortalContainer / MainPanel / InfoContainer / UnlocksLabel.text = "you_will_unlock"
        $PortalContainer / Buttons / Enter.disabled = false
    else:
        $PortalContainer / MainPanel / InfoContainer / UnlocksLabel.text = "no_new_unlocks"


func queue_milestone(milestone: String) -> void :
    var instance: HBoxContainer = load("res://scenes/new_milestone.tscn").instantiate()
    instance.name = milestone
    $PortalContainer / MainPanel / InfoContainer / Milestones.add_child(instance)


func _on_enter_pressed() -> void :
    Signals.popup.emit("")
    Signals.reboot.emit()
    Sound.play("click2")


func _on_cancel_pressed() -> void :
    Signals.popup.emit("")
    Sound.play("close")


func _on_milestone_queued(milestone: String, levels: int) -> void :
    if !$PortalContainer / MainPanel / InfoContainer / Milestones.has_node(milestone):
        queue_milestone(milestone)
    $PortalContainer / MainPanel / InfoContainer / UnlocksLabel.text = "you_will_unlock"
    $PortalContainer / Buttons / Enter.disabled = false
