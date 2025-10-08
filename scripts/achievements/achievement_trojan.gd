extends Achievement


func _ready() -> void :
    super ()
    Signals.uploaded.connect(_on_uploaded)


func _on_uploaded(resource: ResourceContainer, count: float) -> void :
    if !unlocked and resource.variation & Utils.file_variations.HACKED:
        unlock()
