extends HBoxContainer

const categories: Dictionary = {
    "cpu": "CPU",
    "network": "Network",
    "gpu": "GPU",
    "research": "Research",
    "hacking": "Hacking",
    "coding": "Coding",
    "utility": "Utilities"
}
const unlock_requirements: Dictionary = {
    "CPU": "processor",
    "Network": "network",
    "GPU": "gpu_cluster",
    "Research": "laboratory",
    "Hacking": "hacker",
    "Coding": "coder",
    "Utilities": "collect"
}

var cur_category: String
var available_windows: Array[String]
var new_windows: Array[String]


func _ready() -> void:
    set_category("network")

    update_categories()


func set_category(category: String) -> void:
    var update: bool = category != cur_category
    cur_category = category
    for i: Button in $ButtonsPanelContainer/ButtonsContainer.get_children():
        i.button_pressed = i.name == categories[category]

    if update:
        for i: Control in $ScrollContainer/MarginContainer/WindowsContainer.get_children():
            i.queue_free()
            $ScrollContainer/MarginContainer/WindowsContainer.remove_child(i)

        for i: String in Data.windows:
            if Data.windows[i].category != category:
                continue
            var instance: Control = preload("res://scenes/window_panel.tscn").instantiate()
            instance.name = i
            if new_windows.has(i):
                instance.is_new = true
                new_windows.erase(i)
            $ScrollContainer/MarginContainer/WindowsContainer.add_child(instance)

    $ButtonsPanelContainer/ButtonsContainer.get_node(categories[category] + "/New").visible = false


func update_categories() -> void:
    for i: String in unlock_requirements:
        $ButtonsPanelContainer/ButtonsContainer.get_node(i).visible = get_category_visibility(i)


func get_category_visibility(category: String) -> bool:
    var window: String = unlock_requirements[category]
    if Globals.money_level < Data.windows[window].level:
        return false
    if !Data.windows[window].upgrade.is_empty() and Globals.upgrades[Data.windows[window].upgrade] <= 0:
        return false

    return true


func _on_cpu_pressed() -> void:
    set_category("cpu")
    Sound.play("click_toggle2")


func _on_network_pressed() -> void:
    set_category("network")
    Sound.play("click_toggle2")


func _on_gpu_pressed() -> void:
    set_category("gpu")
    Sound.play("click_toggle2")


func _on_research_pressed() -> void:
    set_category("research")
    Sound.play("click_toggle2")


func _on_hacking_pressed() -> void:
    set_category("hacking")
    Sound.play("click_toggle2")


func _on_coding_pressed() -> void:
    set_category("coding")
    Sound.play("click_toggle2")


func _on_power_pressed() -> void:
    set_category("power")
    Sound.play("click_toggle2")


func _on_factory_pressed() -> void:
    set_category("factory")
    Sound.play("click_toggle2")


func _on_modules_pressed() -> void:
    set_category("modules")
    Sound.play("click_toggle2")


func _on_utilities_pressed() -> void:
    set_category("utility")
    Sound.play("click_toggle2")
