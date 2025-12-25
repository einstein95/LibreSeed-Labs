extends WindowIndexed

var collecting: Array[ResourceContainer]


func _ready() -> void:
    super ()
    Signals.storage_deleted.connect(_on_storage_deleted)

    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        i.resource_set.connect(_on_resource_set)

    check_storage()
    update_valid_inputs()


func process(delta: float) -> void:
    for i: ResourceContainer in collecting:
        var free_storage: float = maxf(Attributes.get_attribute("storage_size") - Globals.storage_size, 0)
        var file_size: float = Utils.get_file_size(i.resource, i.variation)
        var count: float = i.pop(floorf(free_storage / file_size))
        Globals.storage[i.resource][i.variation].value += count * Data.files[i.resource].value_multiplier * Utils.get_variation_value_multiplier(i.variation)
        Globals.storage[i.resource][i.variation].size += count * file_size
        Globals.storage_size += count * file_size


func check_storage() -> void:
    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if i.resource.is_empty():
            continue

        if !Globals.storage[i.resource].has(i.variation):
            Globals.add_storage(i.resource, i.variation)


func update_valid_inputs() -> void:
    collecting.clear()
    for i: ResourceContainer in $PanelContainer/MainContainer.get_children():
        if !i.resource.is_empty():
            collecting.append(i)


func _on_resource_set() -> void:
    check_storage()
    update_valid_inputs()


func _on_storage_deleted(file: String, variation: int) -> void:
    check_storage()
