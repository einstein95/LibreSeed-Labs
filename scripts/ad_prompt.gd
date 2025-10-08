extends PanelContainer


func _on_watch_pressed() -> void :
    Ads.show_ad()
    Signals.popup.emit("")
    Sound.play("click2")


func _on_cancel_pressed() -> void :
    Signals.popup.emit("")
    Sound.play("close")
