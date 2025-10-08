extends Panel

@onready var value_label: = $Value
var type: int
var suffix: String


func _ready() -> void :
    type = int(Data.stats[name].type)
    suffix = Data.stats[name].suffix

    update_all()
    set_process(false)


func update_all() -> void :
    $Name.text = tr(Data.stats[name].name)


func _process(delta: float) -> void :
    value_label.text = get_value_string()


func get_value_string() -> String:
    match type:
        0:
            return Utils.print_string(Globals.stats[name], true) + suffix
        1:
            return Utils.print_metric(Globals.stats[name], true) + suffix
        2:
            return Utils.print_string(Globals.stats[name], false) + suffix
        3:
            return Utils.print_metric(Globals.stats[name], false) + suffix
        4:
            return "%02d:%02d:%02d" % [Globals.stats[name] / 3600, int(Globals.stats[name]) %3600 / 60, int(Globals.stats[name]) %60]
    return Globals.stats[name]


func _on_visibility_changed() -> void :
    update_all()
    set_process(is_visible_in_tree())
