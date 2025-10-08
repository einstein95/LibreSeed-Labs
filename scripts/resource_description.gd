extends Panel

var selected_resource: ResourceContainer
var offset: float


func _ready() -> void :
    Signals.resource_selected.connect(_on_resource_selected)

    set_process(false)


func _process(delta: float) -> void :
    if selected_resource:
        position = selected_resource.global_position + Vector2(offset, 0)


func set_resource(resource: ResourceContainer) -> void :
    if selected_resource:
        selected_resource.closing.disconnect(_on_resource_closing)

    selected_resource = resource
    if selected_resource:
        update_resource()
        offset = - size.x - 20
        if selected_resource.has_node("InputConnector"):
            offset = resource.size.x + 20

        $AnimationPlayer.play("Popup")
        $AnimationPlayer.seek(0, true)
        selected_resource.closing.connect(_on_resource_closing)
    elif visible:
        $AnimationPlayer.play("Close")


func update_resource() -> void :
    var resource: String = selected_resource.resource
    var variation: int = selected_resource.variation

    $InfoContainer / Name.text = Data.resources[resource].name
    $InfoContainer / Variations.visible = variation > 0
    if !Data.resources[resource].symbols.is_empty():
        $InfoContainer / Variations.text = Utils.get_resource_symbols(Data.resources[resource].symbols, variation)
    $InfoContainer / Description.text = Data.resources[resource].description

    $InfoContainer / FileInfoContainer.visible = Data.files.has(resource)
    if Data.files.has(resource):
        $InfoContainer / FileInfoContainer / Quality.text = tr("quality") + ": %.0f" % Utils.get_variation_quality_multiplier(variation)
        $InfoContainer / FileInfoContainer / Value.text = tr("value") + ": " + Utils.print_string(Utils.get_file_value(resource, variation), true)
        $InfoContainer / FileInfoContainer / Size.text = tr("size") + ": " + Utils.print_metric(Utils.get_file_size(resource, variation), true) + "b"
        $InfoContainer / FileInfoContainer / Research.text = tr("research") + ": " + Utils.print_string(Utils.get_file_research(resource, variation), true)


func _on_resource_selected(resource: ResourceContainer) -> void :
    if resource == selected_resource:
        set_resource(null)
    else:
        set_resource(resource)
    set_process(is_instance_valid(selected_resource))


func _on_resource_closing() -> void :
    Signals.resource_selected.emit(null)
