extends PanelContainer

@onready var time_bar: = $PortalContainer / MainPanel / MainContainer / ProgressContainer / ProgressBar
@onready var time_label: = $PortalContainer / MainPanel / MainContainer / ProgressContainer / LabelContainer / Duration


func _ready() -> void :
    Signals.new_perk.connect(_on_new_perk)
    Signals.offline_multiplier_set.connect(_on_offline_multiplier_set)

    update_all()


func _process(delta: float) -> void :
    time_bar.value = Globals.offline_time
    time_label.text = "%.0f" % Globals.offline_time + tr("second_abbreviation")


func update_all() -> void :
    time_bar.max_value = Attributes.get_attribute("max_rest_time")
    $PortalContainer / MainPanel / MainContainer / ProgressContainer / LabelContainer / Max.text = "%.0f" % Attributes.get_attribute("max_rest_time") + tr("second_abbreviation")


func _on_offline_multiplier_set() -> void :
    update_all()


func _on_toggle_pressed() -> void :
    if $PortalContainer / MainPanel / Toggle.button_pressed:
        Globals.set_offline_multiplier(5)
    else:
        Globals.set_offline_multiplier(1)
    Sound.play("click_toggle2")


func _on_cancel_pressed() -> void :
    Signals.popup.emit("")
    Sound.play("close")


func _on_new_perk(perk: String, levels: int) -> void :
    update_all()
