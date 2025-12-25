extends WindowIndexed

@onready var requirements := $PanelContainer/MainContainer/Requirements
@onready var code := $PanelContainer/MainContainer/Code


func process(delta: float) -> void:
    var count: float = INF
    for i: ResourceContainer in requirements.get_children():
        count = floorf(min(count, i.count))

    if count > 0:
        code.add(count)
        for i: ResourceContainer in requirements.get_children():
            i.pop(count)

    code.production = INF
    for i: ResourceContainer in requirements.get_children():
        code.production = min(code.production, i.production)
