extends WindowIndexed

@onready var payload_in := $PanelContainer/MainContainer/PayloadIn
@onready var payload_out := $PanelContainer/MainContainer/PayloadOut


func process(delta: float) -> void:
    var crit_chance: float = Attributes.get_attribute("breach_critical_chance")
    var crit_multiplier: float = Attributes.get_attribute("breach_critical_multiplier")
    if floorf(payload_in.count) > 0:
        if randf() < crit_chance:
            payload_out.count = payload_in.pop_all()
            Signals.spawn_popup.emit(tr("critical"), global_position + Vector2(size.x / 2, 0))
        else:
            payload_out.count = payload_in.pop_all() * (1 + crit_multiplier)
    else:
        payload_out.pop_all()
    payload_out.production = payload_in.production * ((1 + crit_chance) * crit_multiplier)


func _on_payload_in_resource_set() -> void:
    payload_out.set_resource(payload_in.resource, payload_in.variation)
