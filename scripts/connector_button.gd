class_name ConnectorButton extends "res://scripts/primitive_texture_rect.gd"

signal dropped(connection: String, type: int)
signal dragged

@export var type: int

var container: ResourceContainer
var hovering: bool
var dragging: bool
var dimmed: bool
var disabled: bool:
    set(d): disabled = d; update_connector_animation()


func _enter_tree() -> void:
    super ()
    container = get_parent()
    container.closing.connect(close)


func _ready() -> void:
    super ()
    Signals.connection_set.connect(_on_connection_set)
    Signals.connection_droppped.connect(_on_connection_dropped)
    Signals.highlight_connection.connect(_on_highlight_connection)
    Signals.setting_set.connect(_on_settings_set)
    container.resource_set.connect(_on_resource_set)

    if type == Utils.connections_types.OUTPUT:
        container.connection_out_set.connect(_on_connection_set)
    elif type == Utils.connections_types.INPUT:
        container.connection_in_set.connect(_on_connection_set)

    update_all.call_deferred()


func update_all() -> void:
    update_settings()
    update_connector_button()


func update_settings() -> void:
    if Data.colorblind:
        texture_scale = 0.5
    else:
        texture_scale = 0.35
    $ColorLabel.visible = Data.colorblind
    if !get_connector_color().is_empty():
        $ColorLabel.text = Data.connectors[get_connector_color()].letter
        $ColorLabel.add_theme_color_override("font_color", get_connector_color())
    queue_redraw()


func update_connector_button() -> void:
    self_modulate = get_color()
    var t: String = get_connector_icon(has_connection())
    if !t.is_empty():
        texture = Resources.icons[(get_connector_icon(has_connection()))]
    visible = !get_connection_shape().is_empty()

    update_connector_animation()
    queue_redraw()


func update_connector_animation() -> void:
    if disabled:
        $AnimationPlayer.play("Disabled")
    else:
        if Globals.connection_type != Utils.connections_types.NONE:
            var resource: ResourceContainer = Globals.desktop.get_resource(Globals.connecting)
            var connectable: bool = container.can_connect(resource) and Globals.connection_type != type
            if connectable:
                $AnimationPlayer.play("Glow")
            else:
                $AnimationPlayer.play("Disabled")
        elif dimmed:
            $AnimationPlayer.play("Disabled")
        else:
            $AnimationPlayer.play("RESET")


func animate_scale() -> void:
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.1)


func can_connect(resource: ResourceContainer, type: int) -> bool:
    if type == self.type:
        return false

    return container.can_connect(resource)


func has_connection() -> bool:
    if type == Utils.connections_types.OUTPUT:
        return container.outputs_id.size() > 0

    if type == Utils.connections_types.INPUT:
        return !container.input_id.is_empty()

    return false


func get_connection_shape() -> String:
    return container.get_connection_shape()


func get_connector_color() -> String:
    return container.get_connector_color()


func get_connector_icon(is_connected: bool) -> String:
    match get_connection_shape():
        "circle":
            if is_connected:
                return "circle_full.png"
            else:
                return "circle_empty.png"
        "square":
            if is_connected:
                return "square_full.png"
            else:
                return "square_empty.png"
        "triangle":
            if is_connected:
                return "triangle_full.png"
            else:
                return "triangle_empty.png"
        "triangle_down":
            if is_connected:
                return "triangle_down_full.png"
            else:
                return "triangle_down_empty.png"
        "rhombus":
            if is_connected:
                return "rhombus_full.png"
            else:
                return "rhombus_empty.png"
        "pentagon":
            if is_connected:
                return "pentagon_full.png"
            else:
                return "pentagon_empty.png"
        "octagon":
            if is_connected:
                return "octagon_full.png"
            else:
                return "octagon_empty.png"
        "hexagon":
            if is_connected:
                return "hexagon_full.png"
            else:
                return "hexagon_empty.png"

    if is_connected:
        return ""
    else:
        return ""


func get_color() -> Color:
    if get_connector_color().is_empty():
        return Color.BLACK
    else:
        return Color(Data.connectors[get_connector_color()].color)


func get_visibility() -> bool:
    if type == Utils.connections_types.OUTPUT:
        return get_connector_color() != "black"

    return true


func close() -> void:
    disabled = true


func _on_gui_input(event: InputEvent) -> void:
    if disabled:
        return

    if Globals.tool == Utils.tools.MOVE:
        Signals.movement_input.emit(event, global_position)
        return

    if event is InputEventScreenTouch:
        if event.index >= 1:
            Signals.movement_input.emit(event, global_position)
            return
        if type == Utils.connections_types.INPUT and has_connection():
            Signals.delete_connection.emit(container.input_id, container.id)
        if event.is_released():
            if dragging:
                Signals.connection_droppped.emit(container.id, type)
                Globals.connecting = ""
                Globals.connection_type = 0
                Signals.connection_set.emit()
            else:
                if Globals.connecting.is_empty():
                    Globals.connecting = container.id
                    Globals.connection_type = type
                    Signals.connection_set.emit()
                    dragged.emit()
                    Sound.play("connector")
                else:
                    Signals.connection_droppped.emit(Globals.connecting, Globals.connection_type)
                    if Globals.connection_type == Utils.connections_types.INPUT:
                        Globals.connecting = ""
                        Globals.connection_type = 0
                        Signals.connection_set.emit()
            dragging = false
    elif event is InputEventScreenDrag:
        if event.index >= 1:
            Signals.movement_input.emit(event, global_position)
            return
        dragging = true
        if Globals.connecting.is_empty():
            Globals.connecting = container.id
            Globals.connection_type = type
            Signals.connection_set.emit()
            dragged.emit()
            Sound.play("connector")
    else:
        Signals.movement_input.emit(event, global_position)


func _on_connection_set() -> void:
    update_connector_button()


func _on_resource_set() -> void:
    update_connector_button()


func _on_connection_dropped(connection: String, type: int) -> void:
    if !hovering:
        return

    if disabled:
        return

    if connection.is_empty():
        return

    var resource: ResourceContainer = Globals.desktop.get_resource(connection)
    if can_connect(resource, type):
        if self.type == Utils.connections_types.OUTPUT:
            Signals.create_connection.emit(container.id, connection)
        elif self.type == Utils.connections_types.INPUT:
            if has_connection():
                Signals.delete_connection.emit(container.input_id, container.id)
            Signals.create_connection.emit(connection, container.id)
        Sound.play("connect")

    dropped.emit(connection, type)


func _on_highlight_connection(resource: ResourceContainer) -> void:
    if resource:
        if resource == container or container.outputs.has(resource) or container.input == resource:
            dimmed = false
        else:
            dimmed = true
    else:
        dimmed = false
    update_connector_animation()


func _on_connector_button_mouse_entered() -> void:
    if disabled:
        return

    hovering = true
    scale = Vector2(1.2, 1.2)
    if !has_connection():
        return

    Signals.highlight_connection.emit(container)


func _on_connector_button_mouse_exited() -> void:
    if disabled:
        return

    hovering = false
    scale = Vector2(1, 1)
    Signals.highlight_connection.emit(null)


func _on_settings_set(setting: String) -> void:
    if setting != "colorblind":
        return

    update_settings()
