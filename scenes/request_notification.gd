extends PanelContainer

var request: String
var closing: bool


func _ready() -> void :
    var file: String = Data.requests[request].file
    var file_name: String = tr(Data.files[file].name)
    file_name += " " + Utils.get_resource_symbols(Data.resources[file].symbols, Data.requests[request].variation.bin_to_int())
    $NotificationContainer / InfoContainer / Name.text = file_name

    $NotificationContainer.visible = false
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "custom_minimum_size:y", 110, 0.2)
    tween.tween_property($NotificationContainer, "modulate:a", 1, 0.2)
    tween.step_finished.connect( func(step: int) -> void : $NotificationContainer.visible = true)


func close() -> void :
    if closing: return
    closing = true
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 0, 1)
    tween.finished.connect(queue_free)


func _on_timer_timeout() -> void :
    close()
