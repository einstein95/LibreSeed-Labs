extends "res://scenes/windows/window_breach.gd"


func fail() -> void:
    super ()

    if !closing:
        propagate_call("close")

    Signals.notify.emit("breach", "breach_bank_failed")
    Sound.play("error")


func breach() -> void:
    super ()
    Globals.bank_level += 1
    Globals.currencies["token"] += 20
    Globals.stats.max_tokens += 20

    if !closing:
        propagate_call("close")

    Signals.currency_popup.emit("token", 20)
    Signals.notify.emit("breach", "breach_bank_success")
    Sound.play("task_completed2")


func get_level() -> int:
    return Globals.bank_level
