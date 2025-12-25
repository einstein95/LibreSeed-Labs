extends WindowIndexed

@onready var splitting := $PanelContainer/MainContainer/Splitting
@onready var splitted := $PanelContainer/MainContainer/Splitted
@onready var splitted2 := $PanelContainer/MainContainer/Splitted2

var ratio: float = 0.5


func _ready() -> void:
    super ()
    update_all()


func process(delta: float) -> void:
    if floorf(splitting.count) * ratio >= 1.0:
        var amount: float = splitting.pop(floorf(splitting.count * ratio))
        splitted.add(amount * (1 - ratio))
        splitted2.add(amount * ratio)
    else:
        if randf() > ratio:
            splitted.add(splitting.pop(floorf(splitting.count)))
        else:
            splitted2.add(splitting.pop(floorf(splitting.count)))
    splitted.production = splitting.production * (1 - ratio)
    splitted2.production = splitting.production * ratio


func update_all() -> void:
    $PanelContainer/MainContainer/RatioContainer/RatioSlider.value = ratio
    $PanelContainer/MainContainer/RatioContainer/RatioLabelContainer/RatioLabel.text = "%.0f" % ((1 - ratio) * 10) + " : " + "%.0f" % (ratio * 10)


func _on_splitting_resource_set() -> void:
    $PanelContainer/MainContainer/Splitted.set_resource(splitting.resource, splitting.variation)
    $PanelContainer/MainContainer/Splitted2.set_resource(splitting.resource, splitting.variation)


func _on_ratio_slider_drag_ended(value_changed: bool) -> void:
    ratio = $PanelContainer/MainContainer/RatioContainer/RatioSlider.value
    Sound.play("click")
    update_all()


func save() -> Dictionary:
    return super ().merged({
        "ratio": ratio
    })
