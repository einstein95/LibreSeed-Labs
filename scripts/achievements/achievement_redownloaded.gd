extends Achievement


func _ready() -> void:
    super ()
    Signals.redownloaded.connect(_on_redownloaded)


func _on_redownloaded(input: ResourceContainer, output: ResourceContainer, count: float) -> void:
    if !unlocked and input.variation & Utils.file_variations.CORRUPTED:
        unlock()
