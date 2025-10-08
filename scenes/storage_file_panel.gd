extends Panel

@export var file: String
@export var variation: int

@onready var size_label: = $InfoContainer / SizeContainer / Value
@onready var value_label: = $InfoContainer / ValueContainer / Value

var dict: Dictionary


func _ready() -> void :
    Signals.storage_deleted.connect(_on_storage_deleted)

    dict = Globals.storage[file][variation]
    var file_name: String = tr(Data.files[file].name)
    var symbols: String = Utils.get_resource_symbols(Data.resources[file].symbols, variation)
    if !symbols.is_empty():
        file_name += " " + symbols
    $InfoContainer / Name.text = file_name
    $Icon.texture = load("res://textures/icons/" + Data.files[file].icon + ".png")


func _process(delta: float) -> void :
    size_label.text = Utils.print_metric(dict.size, true) + "b"
    var multiplier: float = Attributes.get_attribute(Data.files[file].attribute) * Attributes.get_attribute("income_multiplier")
    if variation & Utils.file_variations.AI:
        multiplier *= Attributes.get_attribute(Data.files[file].ai_attribute)
    value_label.text = Utils.print_string(sqrt(dict.value) * multiplier * 0.02, true) + "/b"


func _on_visibility_changed() -> void :
    set_process(is_visible_in_tree())


func _on_delete_pressed() -> void :
    Globals.storage_size = max(0, Globals.storage_size - dict.size)
    Globals.delete_storage(file, variation)
    Sound.play("close")


func _on_storage_deleted(file: String, variation: int) -> void :
    if file == self.file and variation == self.variation:
        visible = false
        set_process(false)
        queue_free()
