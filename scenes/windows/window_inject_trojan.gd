extends WindowIndexed

@onready var trojan: = $PanelContainer / MainContainer / Trojan
@onready var file: = $PanelContainer / MainContainer / File
@onready var output: = $PanelContainer / MainContainer / Output


func process(delta: float) -> void :
    if floorf(file.count) >= 1 and floorf(trojan.count) >= 1:
        var count: float = min(file.count, trojan.count)
        trojan.pop(count)
        file.pop(count)
        output.add(count)

        if is_processing():
            output.animate_icon_in_pop(count)

    output.production = min(trojan.production, file.production)


func _on_file_resource_set() -> void :
    var new_var: int = file.variation
    new_var &= ~ Utils.file_variations.SCANNED
    new_var |= Utils.file_variations.HACKED

    output.set_resource(file.resource, new_var)
