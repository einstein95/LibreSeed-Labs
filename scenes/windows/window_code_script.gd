extends WindowIndexed

@onready var requirements: = $PanelContainer / MainContainer / Requirements
@onready var code: = $PanelContainer / MainContainer / Code


func _ready() -> void :
    super ()


func process(delta: float) -> void :
    if check_requirements():
        var count: float = INF
        for i: ResourceContainer in requirements.get_children():
            count = floorf(min(count, i.count / i.required))
        code.add(count)
        for i: ResourceContainer in requirements.get_children():
            i.pop(count * i.required)
        if is_processing():
            code.animate_icon_in_pop(count)

    code.production = INF
    for i: ResourceContainer in requirements.get_children():
        code.production = min(code.production, i.production / i.required)


func check_requirements() -> bool:
    for i: ResourceContainer in requirements.get_children():
        if i.count < i.required:
            return false

    return true
