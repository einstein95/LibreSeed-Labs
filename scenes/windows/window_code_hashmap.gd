extends WindowIndexed

const results: Dictionary[String, String] = {"array_bool": "hashmap_bool", "array_int": "hashmap_int", 
"array_float": "hashmap_float", "array_char": "hashmap_char", "array_bitflag": "hashmap_bitflag", 
"array_bigint": "hashmap_bigint", "array_decimal": "hashmap_decimal", "array_string": "hashmap_string", 
"array_vector": "hashmap_vector"}

@onready var string: = $PanelContainer / MainContainer / String
@onready var input: = $PanelContainer / MainContainer / Input
@onready var output: = $PanelContainer / MainContainer / Output


func _ready() -> void :
    super ()

    update_output()


func process(delta: float) -> void :
    if string.count >= string.required and input.count >= input.required:
        var count: float = min(floorf(string.count / string.required), floorf(input.count / input.required))
        output.add(count)
        string.pop(count * string.required)
        input.pop(count * input.required)
        if is_processing():
            output.animate_icon_in()

    output.production = min(string.production / string.required, input.production / input.required)


func update_output() -> void :
    if results.has(input.resource):
        output.set_resource(results[input.resource])
    else:
        output.set_resource("null")


func _on_input_resource_set() -> void :
    update_output()
