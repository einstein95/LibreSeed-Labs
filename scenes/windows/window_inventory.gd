extends WindowIndexed

@onready var inputs := $PanelContainer/MainContainer/Input
@onready var outputs := $PanelContainer/MainContainer/Output

var inputting: Dictionary[ResourceContainer, Array]


func _ready() -> void:
    super ()

    update_resources()


func process(delta: float) -> void:
    for input: ResourceContainer in inputting:
        input.production = 0
        for output: ResourceContainer in inputting[input]:
            input.add(output.pop_all())
            input.production += output.production


func update_visible_inputs() -> void:
    var has_free_input: bool = false

    for i: ResourceContainer in inputs.get_children():
        if i.input_id.is_empty():
            has_free_input = true
            break

    var shown_invalid: bool = false
    for i: ResourceContainer in inputs.get_children():
        if !i.input_id.is_empty():
            i.visible = true
        else:
            i.visible = !shown_invalid
            shown_invalid = true

    for i: ResourceContainer in outputs.get_children():
        i.visible = !i.resource.is_empty()

    Signals.window_moved.emit(self)


func update_resources() -> void:
    inputting.clear()
    var new_resources: Dictionary
    var input_resources: Array[Dictionary]

    for i: ResourceContainer in inputs.get_children():
        if i.resource.is_empty():
            continue

        var dict: Dictionary = {
            "resource": i.resource,
            "variation": i.variation
        }
        if input_resources.has(dict):
            continue

        input_resources.append(dict)

    for i: ResourceContainer in outputs.get_children():
        var met: Dictionary
        for o: Dictionary in input_resources:
            if i.resource == o.resource and i.variation == o.variation:
                met = o
                break
        if !met.is_empty():
            input_resources.erase(met)
            continue
        new_resources[i] = {"resource": "", "variation": 0}

    for i: Dictionary in input_resources:
        for o: ResourceContainer in new_resources:
            if new_resources[o].resource.is_empty():
                new_resources[o].resource = i.resource
                new_resources[o].variation = i.variation
                break

    for i: ResourceContainer in new_resources:
        i.set_resource(new_resources[i].resource, new_resources[i].variation)

    for i: ResourceContainer in inputs.get_children():
        if i.resource.is_empty():
            continue

        for o: ResourceContainer in outputs.get_children():
            if o.resource == i.resource and o.variation == i.variation:
                if inputting.has(o):
                    inputting[o].append(i)
                else:
                    inputting[o] = [i]
                break

    update_visible_inputs()


func _on_0_resource_set() -> void:
    update_resources()


func _on_1_resource_set() -> void:
    update_resources()


func _on_2_resource_set() -> void:
    update_resources()


func _on_3_resource_set() -> void:
    update_resources()


func _on_4_resource_set() -> void:
    update_resources()


func _on_connection_set() -> void:
    update_visible_inputs()
