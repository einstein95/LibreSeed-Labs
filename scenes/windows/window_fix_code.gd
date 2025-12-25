extends WindowIndexed

@onready var code := $PanelContainer/MainContainer/Code
@onready var bug_fix := $PanelContainer/MainContainer/BugFix
@onready var fixed := $PanelContainer/MainContainer/Fixed


func process(delta: float) -> void:
    if floorf(code.count) > 0 and floorf(bug_fix.count) > 0:
        var count: float = min(code.count, bug_fix.count)
        fixed.add(count)

        code.pop(count)
        bug_fix.pop(count)

    fixed.production = min(code.production, bug_fix.production)


func _on_code_resource_set() -> void:
    var new_variation: int = fixed.variation
    if fixed.variation & Utils.code_variations.BUGGED:
        new_variation = new_variation & ~Utils.code_variations.BUGGED
    new_variation |= Utils.code_variations.FIXED
    fixed.set_resource(code.resource, new_variation)
