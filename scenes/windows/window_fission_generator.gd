extends WindowIndexed

@onready var progress_bar: = $PanelContainer / MainContainer / ConsumptionContainer / ConsumptionBar
@onready var stability_bar: = $PanelContainer / MainContainer / StabilityContainer / StabilityBar
@onready var consumption_label: = $PanelContainer / MainContainer / ConsumptionContainer / ConsumptionLabelContainer / ConsumptionLabel
@onready var stability_label: = $PanelContainer / MainContainer / StabilityContainer / StabilityLabelContainer / StabilityLabel
@onready var uranium: = $PanelContainer / MainContainer / Uranium
@onready var boron: = $PanelContainer / MainContainer / Boron
@onready var power: = $PanelContainer / MainContainer / Power

var speed: float
var stability: float
var time: float = 60


func _ready() -> void :
    super ()

    update_all()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, time / 60.0, 1.0 - exp(-50.0 * delta))
    stability_bar.value = lerpf(stability_bar.value, stability, 1.0 - exp(-50.0 * delta))
    consumption_label.text = "%.2f/s" % (stability / 60)
    stability_label.text = "%.f%%" % (stability * 100)


func process(delta: float) -> void :
    if floorf(uranium.count) > 0:
        stability = (boron.count / 10) / uranium.count
        if stability > 0:
            power.count = speed * (1.0 / stability) * Attributes.get_attribute("power_multiplier")
            time -= (1.0 / stability) * delta
        else:
            power.count = 0
    else:
        power.count = 0
        stability = 1.0

    if time <= 0:
        boron.pop(floorf(10 * stability * (1 + floorf(absf(time) / 60.0))))
        time += 60 * uranium.pop(floorf(1 * (1 + floorf(absf(time) / 60.0))))



















func update_all() -> void :
    speed = 1000
    set_window_name(get_window_name())
    $PanelContainer / MainContainer / ConsumptionContainer / ConsumptionLabelContainer / ConsumptionLabel.text = Utils.print_string(1.0 / 60, false) + "/s"


func save() -> Dictionary:
    return super ().merged({
        "time": time
    })
