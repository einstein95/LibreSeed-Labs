extends WindowIndexed

@onready var infections: = $PanelContainer / MainContainer / Infections
@onready var boost: = $PanelContainer / MainContainer / Boost


func process(delta: float) -> void :
    if floorf(infections.count) >= 1:
        boost.count = (log(infections.count) * 0.434) * 0.1
    else:
        boost.count = 0
