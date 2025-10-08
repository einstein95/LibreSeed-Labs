extends WindowIndexed

const values: Dictionary[String, float] = {"code_bugfix": 1, "code_optimization": 4, 
"code_application": 16, "code_driver": 64}

@onready var code: = $PanelContainer / MainContainer / Code
@onready var contribution: = $PanelContainer / MainContainer / Contribution

var base_value: float


func _ready() -> void :
    super ()

    code.resource_set.connect(_on_code_resource_set)

    update_type()


func process(delta: float) -> void :
    if floorf(code.count) >= 1:
        var count: float = floorf(code.pop(code.count))
        var value: float = count * base_value
        contribution.add(value)
        Globals.stats.commits += count

        Signals.commited.emit(code, count)

        if is_processing():
            contribution.animate_icon_in()

    contribution.production = code.production * base_value


func update_type() -> void :
    if values.has(code.resource):
        base_value = values[code.resource] * Utils.get_code_value_multiplier(code.variation)
    else:
        base_value = 0


func _on_code_resource_set() -> void :
    update_type()
