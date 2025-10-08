extends WindowIndexed

@onready var inputs: = $PanelContainer / MainContainer / Inputs
@onready var added: = $PanelContainer / MainContainer / Added


func process(delta: float) -> void :
    var boost_empower: float
    var boost_overclock: float
    var boost: float
    for i: ResourceContainer in inputs.get_children():
        if i.resource == "boost_empower":
            boost_empower += i.count
        if i.resource == "boost_overclock":
            boost_overclock += i.count
        if i.resource == "boost":
            boost += i.count
    added.count = (1 + boost) * (1 + boost_empower) * (1 + boost_overclock) - 1.0
