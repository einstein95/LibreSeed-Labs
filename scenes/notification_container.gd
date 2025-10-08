extends PanelContainer

var closing: bool
var icon: String
var text: String


func _ready() -> void :
    $NotificationContainer / Icon.texture = load("res://textures/icons/" + icon + ".png")
    $NotificationContainer / Label.text = text
    custom_minimum_size.x = 30 + text.length() * 18

    $NotificationContainer.visible = false
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "custom_minimum_size:y", 70, 0.2)
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
