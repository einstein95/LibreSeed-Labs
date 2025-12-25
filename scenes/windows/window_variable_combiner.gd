extends WindowIndexed

const combinations: Dictionary = {
    "bitflag": ["bool", "int"],
    "bigint": ["int", "int"],
    "decimal": ["int", "float"],
    "string": ["char", "char"],
    "vector": ["float", "float"]
}

@onready var input1 := $PanelContainer/MainContainer/Input1
@onready var input2 := $PanelContainer/MainContainer/Input2
@onready var output := $PanelContainer/MainContainer/Output

var valid: bool


func _ready() -> void:
    super ()

    update_output()


func process(delta: float) -> void:
    if valid:
        if floorf(input1.count) > 0 and floorf(input2.count) > 0:
            var count: float = min(input1.count, input2.count)
            output.add(count)
            input1.pop(count)
            input2.pop(count)
            if is_processing():
                output.animate_icon_in_pop(count)

        output.production = min(input1.production, input2.production)
    else:
        output.production = 0


func update_output() -> void:
    var result: String = "null"

    for i: String in combinations:
        if input1.resource == combinations[i][0] and input2.resource == combinations[i][1] or \
            input2.resource == combinations[i][0] and input1.resource == combinations[i][1]:
            result = i
            break

    output.set_resource(result)
    valid = result != "null"


func _on_input_1_resource_set() -> void:
    update_output()


func _on_input_2_resource_set() -> void:
    update_output()
