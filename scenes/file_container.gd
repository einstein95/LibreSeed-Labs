extends ResourceContainer

var file_size: float


func _ready() -> void:
    super ()

    Globals.storage_used += file_size * count


func add(amount: float) -> void:
    super (amount)
    Globals.storage_used += file_size * amount


func remove(amount: float) -> void:
    super (amount)
    Globals.storage_used -= file_size * amount


func close() -> void:
    super ()
    Globals.storage_used -= file_size * count


func validate_resource() -> void:
    super ()
    if Data.files.has(resource):
        file_size = Utils.get_file_size(resource, variation)
    else:
        file_size = 0
