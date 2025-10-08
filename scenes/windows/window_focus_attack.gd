extends WindowIndexed

@onready var input: = $PanelContainer / MainContainer / Input
@onready var input2: = $PanelContainer / MainContainer / Input2
@onready var output: = $PanelContainer / MainContainer / Output


func process(delta: float) -> void :
    output.count = input.pop_all() + input2.pop_all()
    output.production = input.production + input2.production


func set_resource(resource: String, variation: int) -> void :
    input.set_resource(resource, variation)
    input2.set_resource(resource, variation)
    output.set_resource(resource, variation)


func _on_input_resource_set() -> void :
    set_resource(input.resource, input.variation)


func _on_input_2_resource_set() -> void :
    set_resource(input2.resource, input.variation)
