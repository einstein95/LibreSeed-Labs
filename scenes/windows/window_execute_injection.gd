extends WindowIndexed

@onready var hack_power: = $PanelContainer / MainContainer / HackPower
@onready var vulnerability: = $PanelContainer / MainContainer / Vulnerability


func process(delta: float) -> void :
    if hack_power.count > 0:
        vulnerability.count = log(hack_power.count) * 0.1
    else:
        vulnerability.count = 0
