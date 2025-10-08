extends Node2D

var claimed: bool


func _ready() -> void :
    Ads.ad_shown.connect(_on_ad_shown)

    scale = Vector2(0, 0)
    modulate.a = 0
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_BOUNCE)
    tween.set_parallel()
    tween.tween_property(self, "modulate:a", 1, 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.2)

    position = Globals.camera_center + Vector2(-2000 + (randi() %41) * 50, -2000 + (randi() %41) * 50)
    position = position.clamp(Vector2(-4500, -4500), Vector2(4500, 4500))

    Signals.create_pointer.emit($VisibleOnScreenNotifier2D)
    Sound.play("popup")


func _on_timer_timeout() -> void :
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 0, 0.5)
    tween.finished.connect(queue_free)


func _on_icon_gui_input(event: InputEvent) -> void :
    if claimed: return
    if event is InputEventScreenTouch and event.is_pressed():
        Signals.popup.emit("AdPrompt")

        var tween: Tween = create_tween()
        tween.set_trans(Tween.TRANS_BOUNCE)
        tween.set_parallel()
        tween.tween_property(self, "modulate:a", 0, 0.2)
        tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
        tween.finished.connect(queue_free)

        Sound.play("click2")


func _on_ad_shown() -> void :
    claimed = true
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_BOUNCE)
    tween.set_parallel()
    tween.tween_property(self, "modulate:a", 0, 0.2)
    tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)
    tween.finished.connect(queue_free)
