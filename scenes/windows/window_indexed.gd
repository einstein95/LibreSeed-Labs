class_name WindowIndexed extends WindowBase

@export var window: String
var data: Dictionary


func _enter_tree() -> void:
    if !Data.windows.has(window):
        queue_free()
        for i: ResourceContainer in containers:
            i.close()
        return

    super ()


func _ready() -> void:
    if is_queued_for_deletion():
        return

    Signals.service_purchased.connect(_on_service_purchased)

    Globals.window_count[window] += 1
    if !Data.windows[window].group.is_empty():
        Globals.group_count[Data.windows[window].group] += 1

    Globals.max_window_count += 1
    if Globals.windows_data.has(window):
        data = Globals.windows_data[window]
    help = Data.windows[window].guide
    super ()


func close() -> void:
    Globals.window_count[window] -= 1
    if !Data.windows[window].group.is_empty():
        Globals.group_count[Data.windows[window].group] -= 1

    Globals.max_window_count -= 1
    super ()


func get_window_name() -> String:
    return tr(Data.windows[window].name)


func get_guide() -> String:
    return Data.windows[window].guide


func _on_service_purchased(service: String) -> void:
    if Data.services[service].windows.has(window) or !Data.windows[window].group.is_empty() and \
Data.services[service].window_groups.has(Data.windows[window].group):
        propagate_call("close")


func export() -> Dictionary:
    return super ().merged({
        "window": window
    })
