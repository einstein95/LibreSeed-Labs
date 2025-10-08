extends WindowIndexed

@onready var clock: = $PanelContainer / MainContainer / Clock
@onready var money: = $PanelContainer / MainContainer / Money


func process(delta: float) -> void :
    var multiplier: float = 2 * Attributes.get_attribute("income_multiplier") * Attributes.get_attribute("processing_value_multiplier")
    var count: float = clock.count * multiplier * delta
    money.add(count)
    Globals.max_money += count
    Globals.stats.max_money += count

    money.production = clock.count * multiplier
