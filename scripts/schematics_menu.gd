extends PanelContainer

var open: bool


func _ready() -> void:
    Signals.new_schematic.connect(_on_new_schematic)
    Signals.deleted_schematic.connect(_on_deleted_schematic)

    $MarginContainer/Label.visible = Data.schematics.size() == 0
    for i: String in Data.schematics:
        add_schematic(i)


func toggle(toggle: bool) -> void:
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.set_parallel(true)
    if toggle:
        modulate.a = 0
        offset_top = 0
        visible = true
        tween.tween_property(self, "modulate:a", 1, 0.15)
        tween.tween_property(self, "offset_top", -857, 0.25)
    else:
        modulate.a = 1
        offset_top = -857
        visible = true
        tween.tween_property(self, "modulate:a", 0, 0.15)
        tween.tween_property(self, "offset_top", 0, 0.25)
        tween.finished.connect(func() -> void: visible = open)
    open = toggle


func add_schematic(schematic: String) -> void:
    var instance: Control = load("res://scenes/schematic_container.tscn").instantiate()
    instance.schematic = schematic
    $MarginContainer/ScrollContainer/MarginContainer/Schematics.add_child(instance)


func _on_new_schematic(schematic: String) -> void:
    add_schematic(schematic)
    $MarginContainer/Label.visible = Data.schematics.size() == 0


func _on_deleted_schematic(schematic: String) -> void:
    $MarginContainer/Label.visible = Data.schematics.size() == 0
