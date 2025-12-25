extends Achievement


func _ready() -> void:
    super ()
    Signals.compressed.connect(_on_compressed)
    Signals.enhanced.connect(_on_enhanced)


func _on_compressed(input: ResourceContainer, output: ResourceContainer, count: float) -> void:
    if !unlocked and input.variation & Utils.file_variations.ENHANCED:
        unlock()


func _on_enhanced(input: ResourceContainer, output: ResourceContainer, count: float) -> void:
    if !unlocked and input.variation & Utils.file_variations.COMPRESSED:
        unlock()
