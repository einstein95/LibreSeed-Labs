extends WindowIndexed

@onready var splitting: = $PanelContainer / MainContainer / Splitting
@onready var splitted: = $PanelContainer / MainContainer / Splitted
@onready var splitted2: = $PanelContainer / MainContainer / Splitted2

var ratio: float = 0.5


func _ready() -> void :
    super ()
    update_all()


func process(delta: float) -> void :
    splitted.count = splitting.count * (1 - ratio)
    splitted2.count = splitting.count * ratio


func update_all() -> void :
    $PanelContainer / MainContainer / RatioContainer / RatioSlider.value = ratio
    $PanelContainer / MainContainer / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.0f" % ((1 - ratio) * 10) + " : " + "%.0f" % (ratio * 10)


func _on_splitting_resource_set() -> void :
    $PanelContainer / MainContainer / Splitted.set_resource(splitting.resource)
    $PanelContainer / MainContainer / Splitted2.set_resource(splitting.resource)


func _on_ratio_slider_drag_ended(value_changed: bool) -> void :
    ratio = $PanelContainer / MainContainer / RatioContainer / RatioSlider.value
    Sound.play("click")
    update_all()


func save() -> Dictionary:
    return super ().merged({
        "ratio": ratio
    })
