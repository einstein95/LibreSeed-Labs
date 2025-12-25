extends WindowBase


func _ready() -> void:
    super ()

    if $PanelContainer/MainContainer/Resources.get_child_count() > 0:
        return

    for i: String in Data.resources:
        var instance: ResourceContainer = load("res://scenes/output_container.tscn").instantiate()
        instance.name = str($PanelContainer/MainContainer/Resources.get_child_count())
        instance.resource = i
        $PanelContainer/MainContainer/Resources.add_child(instance)
