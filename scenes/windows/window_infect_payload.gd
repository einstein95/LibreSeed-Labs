extends WindowIndexed

@onready var payload_in: = $PanelContainer / MainContainer / PayloadIn
@onready var payload_out: = $PanelContainer / MainContainer / PayloadOut
@onready var infection: = $PanelContainer / MainContainer / Infection


func process(delta: float) -> void :
    var amount: float = payload_in.pop_all()
    payload_out.count = amount
    infection.count = amount * 0.2
    payload_out.production = payload_in.production
    infection.production = payload_in.production * 0.2
