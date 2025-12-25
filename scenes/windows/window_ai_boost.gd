extends WindowIndexed

@onready var ai := $PanelContainer/MainContainer/AI
@onready var boost := $PanelContainer/MainContainer/Boost


func process(delta: float) -> void:
    if floorf(ai.count) >= 1:
        boost.count = (log(ai.count) * 0.434)
    else:
        boost.count = 0
