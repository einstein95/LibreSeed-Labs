class_name ResourceContainer extends Control

signal initialized
signal tick_set
signal resource_set
signal connection_in_set
signal connection_out_set
signal pulse
signal closing

@onready var count_label: = $Info / Count
@onready var icon: = $ResourceButton / Icon

@export var default_resource: String
@export var default_variation: int
@export var count: float:
    set(c): count = c;needs_update = true
@export var limit: float = pow(10, 305)
@export var required: float
@export var placeholder_name: String = "empty"
@export var force_resource: bool
@export var override_connector: String
@export var override_color: String
@export var excluded_resources: Array[String]
@export var excluded_colors: Array[String]
@export var exporting: Array[ResourceContainer]

var id: String
var resource: String = default_resource
var variation: int = default_variation
var production: float:
    set(p): production = p;needs_update = true
var data: Dictionary
var type: int
var print_type: int
var suffix: String
var hide_decimals: bool
var required_str: String
var animation_busy: bool
var needs_update: bool
var paused: bool

var outputs_id: Array[String]
var input_id: String
var outputs: Array[ResourceContainer]
var input: ResourceContainer
var transfer: Array[ResourceContainer]


func _enter_tree() -> void :
    Signals.resource_renamed.connect(_on_resource_renamed)
    Signals.desktop_ready.connect(_on_desktop_ready)

    resource = default_resource
    variation = default_variation

    validate_resource()


func _ready() -> void :
    initialized.emit()

    if id.is_empty():
        id = Utils.generate_simple_id()
    Signals.register_resource.emit(id, self)

    production = 0
    if type == Utils.resource_types.FLOW or type == Utils.resource_types.BOOST or type == Utils.resource_types.SETTING:
        count = 0

    validate_resource()
    update_all()

    Signals.create_connection.connect(_on_create_connection)
    Signals.delete_connection.connect(_on_delete_connection)


func _process(delta: float) -> void :
    if needs_update:
        count_label.text = get_count_string()
        needs_update = false


func tick() -> void :
    if type == 0:
        if floorf(count) >= transfer.size():
            var remainder: float = fmod(floorf(count), transfer.size())
            var amount: float = (floorf(count) - remainder) / transfer.size()
            count -= amount * transfer.size()
            for i: ResourceContainer in transfer:
                i.count += amount
                i.pulse.emit()
        else:
            for i: int in floori(count):
                var input: ResourceContainer = transfer.pick_random()
                input.count += 1
                count -= 1
                input.pulse.emit()
        for i: ResourceContainer in transfer:
            i.production = production / transfer.size()

    elif type == 1:
        var remaining: float = count
        var unlimited_count: int
        for i: ResourceContainer in transfer:
            if i.limit >= 0:
                var amount: float = min(remaining, i.limit)
                i.count = amount
                remaining -= amount
            else:
                unlimited_count += 1
        if unlimited_count > 0:
            for i: ResourceContainer in transfer:
                if i.limit < 0:
                    i.count = remaining / unlimited_count

    elif type == 2:
        var amount: float = count / transfer.size()
        for i: ResourceContainer in transfer:
            i.count = amount

    elif type == 3:
        while count >= 1.0:
            var available_inputs: Array[ResourceContainer] = transfer.filter(
                func(input): return input.count < input.limit
            )

            if available_inputs.is_empty(): break

            var available_count: float = count
            var num_inputs: int = available_inputs.size()

            if available_count >= num_inputs:
                var base_share: float = available_count / num_inputs
                var remainder: float = fmod(available_count, num_inputs)

                for i: int in num_inputs:
                    var share: float = base_share + (1 if i < remainder else 0)
                    var amount_to_give: float = min(share, available_inputs[i].limit - available_inputs[i].count)

                    available_inputs[i].count += amount_to_give
                    count -= amount_to_give
            else:
                for i: int in range(available_count):
                    var random_input: ResourceContainer = available_inputs[randi() %num_inputs]

                    if random_input.limit - random_input.count > 0:
                        random_input.count += 1
                        count -= 1
        for i: ResourceContainer in transfer:
            i.production = production / transfer.size()

    elif type == 4:
        for i: ResourceContainer in transfer:
            i.count = count

    elif type == 5:
        for i: ResourceContainer in transfer:
            var amount: float = min(count, i.limit)
            i.count = amount
            count -= amount


func set_input(id: String) -> void :
    if input:
        input.closing.disconnect(_on_input_closing)
        input.tick_set.disconnect(_on_input_paused)
        input.resource_set.disconnect(_on_input_resource_set)

    input_id = id
    if id.is_empty():
        input = null
    else:
        var container: ResourceContainer = Globals.desktop.get_resource(id)
        input = container
        input.closing.connect(_on_input_closing)
        input.tick_set.connect(_on_input_paused)
        input.resource_set.connect(_on_input_resource_set)

    production = 0
    if type == Utils.resource_types.FLOW or type == Utils.resource_types.BOOST or type == Utils.resource_types.SETTING:
        count = 0

    connection_in_set.emit()


func add_output(output: String) -> void :
    var container: ResourceContainer = Globals.desktop.get_resource(output)
    if !container: return

    outputs_id.append(output)
    outputs.append(container)
    container.set_resource(resource, variation)
    container.set_input(id)
    container.closing.connect(_on_output_closing.bind(container))
    container.tick_set.connect(_on_output_paused.bind(container))
    container.resource_set.connect(_on_output_resource_set.bind(container))

    Signals.connection_created.emit(id, output)
    connection_out_set.emit()
    update_connections()


func remove_output(output: String) -> void :
    var container: ResourceContainer = Globals.desktop.get_resource(output)
    if !container: return

    outputs_id.erase(output)
    outputs.erase(container)
    container.set_input("")
    container.closing.disconnect(_on_output_closing)
    container.tick_set.disconnect(_on_output_paused)
    container.resource_set.disconnect(_on_output_resource_set)

    Signals.connection_deleted.emit(id, output)
    connection_out_set.emit()
    update_connections()


func update_all() -> void :
    if data.icon.is_empty():
        $ResourceButton / Icon.texture = null
    else:
        $ResourceButton / Icon.texture = Resources.icons[(data.icon + ".png")]

    var display_name: String
    if resource.is_empty():
        display_name = tr(placeholder_name)
    else:
        display_name = tr(data.name)

    if !data.symbols.is_empty():
        var symbols: String = Utils.get_resource_symbols(data.symbols, variation)
        if !symbols.is_empty():
            display_name += " " + symbols
    $Info / Name.text = display_name
    if tr(display_name).length() >= 26:
        $Info / Name.add_theme_font_size_override("font_size", 14)
    elif tr(display_name).length() >= 24:
        $Info / Name.add_theme_font_size_override("font_size", 16)
    elif tr(display_name).length() >= 20:
        $Info / Name.add_theme_font_size_override("font_size", 18)
    elif tr(display_name).length() >= 18:
        $Info / Name.add_theme_font_size_override("font_size", 20)

    $Info / Count.visible = !resource.is_empty()
    $ResourceButton.disabled = resource.is_empty()

    update_required()
    needs_update = true


func update_required() -> void :
    if required > 0:
        if print_type == 1:
            required_str = "/" + Utils.print_metric(required, hide_decimals)
        else:
            required_str = "/" + Utils.print_string(required, hide_decimals)
    else:
        required_str = ""


func update_connections() -> void :
    transfer.clear()
    for i: ResourceContainer in outputs:
        if i.paused or i.is_looping(self):
            transfer.erase(i)
        elif !transfer.has(i):
            transfer.append(i)

    if should_tick():
        if !Signals.tick.is_connected(_on_tick):
            Signals.tick.connect(_on_tick)
    else:
        if Signals.tick.is_connected(_on_tick):
            Signals.tick.disconnect(_on_tick)


func should_tick() -> bool:
    if paused: return false
    if transfer.size() == 0: return false

    return true


func validate_resource() -> void :
    if resource.is_empty():
        data = {
            "name": "empty", 
            "icon": "", 
            "description": "", 
            "type": 0, 
            "print_type": 0, 
            "suffix": "", 
            "hide_decimals": true, 
            "connection": "", 
            "color": "", 
            "symbols": ""
        }
    else:
        if Data.resources.has(resource) and can_set(resource):
            data = Data.resources[resource]
        else:
            set_resource(default_resource, default_variation)
            return
    type = data.type
    suffix = data.suffix
    print_type = data.print_type
    hide_decimals = data.hide_decimals


func set_resource(r: String, v: int = variation) -> void :
    if resource == r and variation == v: return
    remove(count)
    resource = r
    variation = v
    validate_resource()
    resource_set.emit()
    update_all()


func set_required(r: float) -> void :
    required = r
    update_required()
    needs_update = true


func add(amount: float) -> void :
    count += amount


func remove(amount: float) -> void :
    count -= amount


func set_count(amount: float) -> void :
    count = min(amount, limit)


func pop(amount: float) -> float:
    var r: float = min(count, amount)
    remove(r)
    return r


func pop_all() -> float:
    var r: float = count
    remove(r)
    return r


func close() -> void :
    closing.emit()
    if Globals.connecting == id:
        Globals.connecting = ""
        Globals.connection_type = 0
        Signals.connection_set.emit()


func get_count_string() -> String:
    if production > 0:
        return get_base_print(count) + required_str + suffix + " [" + get_base_print(production, false) + suffix + "/s]"
    else:
        return get_base_print(count) + required_str + suffix


func get_base_print(value: float, hide_decimals: bool = hide_decimals) -> String:
    if print_type == 2:
        return Utils.print_string(1.0 + value, hide_decimals)
    elif print_type == 3:
        return Utils.print_string(100 * value, hide_decimals)
    elif print_type == 1:
        return Utils.print_metric(value, hide_decimals)
    else:
        return Utils.print_string(value, hide_decimals)


func get_connection_shape() -> String:
    if override_connector.is_empty():
        return data.connection
    else:
        return override_connector


func get_connector_color() -> String:
    if override_color.is_empty():
        return data.color
    else:
        return override_color


func can_connect(to: ResourceContainer) -> bool:
    if !is_instance_valid(to): return false
    if get_connection_shape() != to.get_connection_shape(): return false
    if (get_connector_color() != "white" and to.get_connector_color() != "white") and get_connector_color() != to.get_connector_color(): return false
    if !can_set(to.resource) or !to.can_set(resource): return false
    if excluded_resources.has(to.resource): return false
    if excluded_colors.has(to.get_connector_color()): return false

    return true


func can_set(to: String) -> bool:
    if force_resource and to != default_resource: return false

    return true


func is_looping(with: ResourceContainer, visited: Array[ResourceContainer] = []) -> bool:
    visited.append(self)
    if with in visited: return true

    var checks: Array[ResourceContainer] = exporting.duplicate()
    checks.append_array(outputs)
    for i: ResourceContainer in checks:
        if visited.has(i): continue
        if i.is_looping(with, visited):
            return true

    return false


func animate_icon_in() -> void :
    if animation_busy: return
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
    tween.tween_property(icon, "scale", Vector2(1.2, 1.2), 0.15)
    tween.tween_property(icon, "scale", Vector2(1, 1), 0.15)
    tween.finished.connect(_on_animation_finished)
    animation_busy = true


func animate_icon_in_pop(value: float) -> void :
    animate_icon_in()


func process_set(enabled: bool) -> void :
    set_process(enabled)


func set_ticking(enabled: bool) -> void :
    paused = !enabled
    if paused:
        production = 0
        if type == Utils.resource_types.FLOW or type == Utils.resource_types.BOOST or type == Utils.resource_types.SETTING:
            count = 0
        for i: ResourceContainer in transfer:
            i.production = 0
            if type == Utils.resource_types.FLOW or type == Utils.resource_types.BOOST or type == Utils.resource_types.SETTING:
                i.count = 0
    tick_set.emit()


func _on_resource_renamed(old_id: String, new_id: String) -> void :
    if old_id == id:
        id = new_id


func _on_input_paused() -> void :
    input.update_connections()


func _on_input_closing() -> void :
    input.remove_output(id)


func _on_input_resource_set() -> void :
    if can_connect(input):
        set_resource(input.resource, input.variation)
    else:
        input.remove_output(id)


func _on_output_paused(output: ResourceContainer) -> void :
    update_connections()


func _on_output_closing(output: ResourceContainer) -> void :
    remove_output(output.id)


func _on_output_resource_set(output: ResourceContainer) -> void :
    if !can_connect(output):
        remove_output(output.id)


func _on_tick() -> void :
    tick()


func _on_create_connection(output: String, input: String) -> void :
    if output == id:
        if can_connect(Globals.desktop.get_resource(input)):
            add_output(input)


func _on_delete_connection(output: String, input: String) -> void :
    if output == id:
        if outputs_id.has(input):
            remove_output(input)


func _on_desktop_ready() -> void :
    var to_connect: Array[String] = outputs_id.duplicate()
    outputs_id.clear()
    for i: String in to_connect:
        if !can_connect(Globals.desktop.get_resource(i)): continue
        add_output(i)


func _on_animation_finished() -> void :
    animation_busy = false


func export() -> Dictionary:
    return {
        "id": id, 
        "outputs_id": outputs_id
    }


func save() -> Dictionary:
    return {
        "id": id, 
        "resource": resource, 
        "variation": variation, 
        "count": count, 
        "outputs_id": outputs_id
    }
