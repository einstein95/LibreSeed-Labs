extends "res://scenes/wandering_object.gd"


func claim() -> void:
    super ()
    var amount: float = 5 * Attributes.get_attribute("token_multiplier")
    Globals.currencies["token"] += amount
    Globals.stats.max_tokens += amount

    Signals.currency_popup.emit("token", amount)
    Signals.currency_popup_particle.emit("token", Utils.world_to_screen_pos(global_position))
    Sound.play("claim")
