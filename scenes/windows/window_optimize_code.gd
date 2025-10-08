extends WindowIndexed

@onready var code: = $PanelContainer / MainContainer / Code
@onready var optimization: = $PanelContainer / MainContainer / Optimization
@onready var optimized: = $PanelContainer / MainContainer / Optimized


func process(delta: float) -> void :
    if floorf(code.count) > 0 and floorf(optimization.count) > 0:
        var count: float = min(code.count, optimization.count)
        optimized.add(count)

        code.pop(count)
        optimization.pop(count)

    optimized.production = min(code.production, optimization.production)


func _on_code_resource_set() -> void :
    optimized.set_resource(code.resource, code.variation | Utils.code_variations.OPTIMIZED)
