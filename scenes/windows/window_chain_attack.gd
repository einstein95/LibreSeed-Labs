extends WindowIndexed

@onready var input := $PanelContainer/MainContainer/Input
@onready var output := $PanelContainer/MainContainer/Output
@onready var output2 := $PanelContainer/MainContainer/Output2


func process(delta: float) -> void:
    output.count = input.pop_all()
    output2.count = output.count
    output.production = input.production
    output2.production = input.production


func _on_input_resource_set() -> void:
    output.set_resource(input.resource, input.variation)
    output2.set_resource(input.resource, input.variation)
