extends VBoxContainer

var schematic: String
var requirements: Dictionary


func _ready() -> void :
    Signals.deleted_schematic.connect(_on_delete_schematic)

    $SchematicButton / Icon.texture = load("res://textures/icons/" + Data.schematics[schematic].icon + ".png")
    $SchematicButton / InfoContainer / Name.text = schematic


func _on_button_pressed() -> void :
    $DetailsPanel.visible = !$DetailsPanel.visible
    if $DetailsPanel / DetailsContainer.get_child_count() == 0:
        for i: String in Data.schematics[schematic].windows:
            if requirements.has(Data.schematics[schematic].windows[i].window):
                requirements[Data.schematics[schematic].windows[i].window] += 1
            else:
                requirements[Data.schematics[schematic].windows[i].window] = 1
        for i: String in requirements:
            var instance: Control = load("res://scenes/schematic_window_container.tscn").instantiate()
            instance.window = i
            instance.required = requirements[i]
            $DetailsPanel / DetailsContainer.add_child(instance)

    Sound.play("click_toggle2")


func _on_add_pressed() -> void :
    Signals.place_schematic.emit(schematic)
    Signals.set_menu.emit(0, 0)
    Sound.play("open")


func _on_delete_pressed() -> void :
    Data.delete_schematic(schematic)
    Sound.play("close")


func _on_delete_schematic(schem: String) -> void :
    if schem == schematic:
        visible = false
        queue_free()
