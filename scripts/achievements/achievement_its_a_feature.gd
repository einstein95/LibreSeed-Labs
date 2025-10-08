extends Achievement


func _ready() -> void :
    super ()
    Signals.commited.connect(_on_commited)


func _on_commited(resource: ResourceContainer, count: int) -> void :
    if !unlocked and resource.variation & Utils.code_variations.BUGGED:
        unlock()
