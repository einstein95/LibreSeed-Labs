extends Panel

@onready var value_label := $Value
var type: int


func _ready() -> void:
    type = int(Data.attributes[name].type)


func update_all() -> void:
    $Name.text = tr(Data.attributes[name].name)

    set_process(is_visible_in_tree())


func _process(delta: float) -> void:
    value_label.text = get_value_string()


func get_value_string() -> String:
    match type:
        0:
            return Utils.print_string(Attributes.get_attribute(name), true)
        1:
            return Utils.print_string(Attributes.get_attribute(name), false) + "x"
        2:
            return Utils.print_string(Attributes.get_attribute(name) * 100, false) + "%"
    return Globals.stats[name]


func _on_visibility_changed() -> void:
    update_all()
