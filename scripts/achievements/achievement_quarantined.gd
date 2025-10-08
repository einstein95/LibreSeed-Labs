extends Achievement


func _ready() -> void :
    super ()
    Signals.quarantined.connect(_on_quarantined)



func _on_quarantined(input: ResourceContainer, output: ResourceContainer, count: float) -> void :
    if !unlocked and input.variation & Utils.file_variations.INFECTED:
        unlock()
