extends WindowIndexed

@onready var output := $PanelContainer/MainContainer/Output

var input: Array[ResourceContainer]


func _ready() -> void:
    super ()

    for resource: ResourceContainer in $PanelContainer/MainContainer/Input.get_children():
        input.append(resource)

    update_visible_inputs()


func process(delta: float) -> void:
    output.count = 0
    for i: ResourceContainer in input:
        output.count += i.count


func update_visible_inputs() -> void:
    var has_free_input: bool = false

    for i in $PanelContainer/MainContainer/Input.get_children():
        if i.connection_path.is_empty():
            has_free_input = true
            break

    var shown_invalid: bool = false
    for i in $PanelContainer/MainContainer/Input.get_children():
        if !i.connection_path.is_empty():
            i.visible = true
        else:
            i.visible = !shown_invalid
            shown_invalid = true

    Signals.window_moved.emit(self)


func _on__connection_set() -> void:
    update_visible_inputs()
