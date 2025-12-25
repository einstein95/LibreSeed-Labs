extends PanelContainer


func _on_confirm_pressed() -> void:
    Data.wiping = true
    get_tree().change_scene_to_file("res://boot.tscn")
    Sound.play("click2")


func _on_cancel_pressed() -> void:
    Signals.popup.emit("")
    Sound.play("close")
