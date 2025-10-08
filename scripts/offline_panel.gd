extends PanelContainer

@onready var accumulated_label: = $OfflineContainer / OfflinePanel / DetailsContainer / InfoContainer / Time / AccumulatedLabel


func _ready() -> void :
    Signals.offline_multiplier_set.connect(_on_offline_multiplier_set)

    update_all()


func _process(delta: float) -> void :
    accumulated_label.text = tr("time") + ": " + Utils.print_string(Globals.offline_time, true) + "s"


func update_all() -> void :
    $OfflineContainer / OfflinePanel / DetailsContainer / InfoContainer / Time / ConsuptionLabel.text = tr("consumption") + ": " + str(pow(Globals.offline_multiplier, 2) * 5) + "/s"
    $OfflineContainer / OfflinePanel / DetailsContainer / OptionsContainer / Off.button_pressed = Globals.offline_multiplier == 1
    $OfflineContainer / OfflinePanel / DetailsContainer / OptionsContainer / x2.button_pressed = Globals.offline_multiplier == 2
    $OfflineContainer / OfflinePanel / DetailsContainer / OptionsContainer / x5.button_pressed = Globals.offline_multiplier == 5
    $OfflineContainer / OfflinePanel / DetailsContainer / OptionsContainer / x10.button_pressed = Globals.offline_multiplier == 10


func _on_offline_multiplier_set() -> void :
    update_all()


func _on_off_pressed() -> void :
    Globals.set_offline_multiplier(1)
    Sound.play("click_toggle")


func _on_x_2_pressed() -> void :
    Globals.set_offline_multiplier(2)
    Sound.play("click_toggle")


func _on_x_5_pressed() -> void :
    Globals.set_offline_multiplier(5)
    Sound.play("click_toggle")


func _on_x_10_pressed() -> void :
    Globals.set_offline_multiplier(10)
    Sound.play("click_toggle")
