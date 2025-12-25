extends PanelContainer

@onready var size_label := $Storage/StatsContainer/ValuePanel/InfoContainer/SizeContainer/Value
@onready var value_label := $Storage/StatsContainer/ValuePanel/InfoContainer/ValueContainer/Value

var initialized: bool


func _ready() -> void:
    Signals.menu_set.connect(_on_menu_set)
    Signals.new_storage.connect(_on_new_storage)

    set_process(false)


func _process(delta: float) -> void:
    size_label.text = Utils.print_metric(Globals.storage_size, true) + "b"
    value_label.text = Utils.print_string(Globals.storage_value, true) + "/b"


func add_storage(file: String, variation: int) -> void:
    var instance: Panel = preload("res://scenes/storage_file_panel.tscn").instantiate()
    instance.file = file
    instance.variation = variation
    $Storage/ScrollContainer/MarginContainer/StorageContainer.add_child(instance)


func _on_menu_set(menu: int, tab: int) -> void:
    if initialized:
        return

    if menu != Utils.menu_types.SIDE and tab != Utils.menus.STORAGE:
        return

    for file: String in Globals.storage:
        for variation: int in Globals.storage[file]:
            add_storage(file, variation)

    initialized = true


func _on_visibility_changed() -> void:
    set_process(is_visible_in_tree())


func _on_new_storage(file: String, variation: int) -> void:
    add_storage(file, variation)
