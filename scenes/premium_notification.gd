extends PanelContainer

var closing: bool


func close() -> void :
    if closing: return
    closing = true
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 0, 1)
    tween.finished.connect(queue_free)


func _on_timer_timeout() -> void :
    close()
