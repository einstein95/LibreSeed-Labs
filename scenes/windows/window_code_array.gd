extends WindowIndexed

const results: Dictionary[String, String] = {"bool": "array_bool", "int": "array_int", 
"float": "array_float", "char": "array_char", "bitflag": "array_bitflag", 
"bigint": "array_bigint", "decimal": "array_decimal", "string": "array_string", 
"vector": "array_vector"}

@onready var variable: = $PanelContainer / MainContainer / Variable
@onready var array: = $PanelContainer / MainContainer / Array


func _ready() -> void :
    super ()

    update_type()


func process(delta: float) -> void :
    if variable.count >= variable.required:
        var count: float = floorf(variable.count / variable.required)
        array.add(count)
        variable.pop(count * variable.required)
        if is_processing():
            array.animate_icon_in()

    array.production = variable.production / variable.required


func update_type() -> void :
    if results.has(variable.resource):
        array.set_resource(results[variable.resource])
    else:
        array.set_resource("null")


func _on_variable_resource_set() -> void :
    update_type()
