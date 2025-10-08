extends WindowIndexed

@onready var damage_in: = $PanelContainer / MainContainer / DamageIn
@onready var damage_out: = $PanelContainer / MainContainer / DamageOut


func process(delta: float) -> void :
    var multiplier: float = 0.75
    damage_out.count = damage_in.pop_all() * multiplier
    damage_out.production = damage_in.production * multiplier


func _on_damage_in_resource_set() -> void :
    damage_out.set_resource(damage_in.resource, damage_in.variation | Utils.damage_variation.STEALTH)
