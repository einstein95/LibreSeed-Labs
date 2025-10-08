extends WindowIndexed

const resource_multiplier: Dictionary = {"coal": 1, "coal_enriched": 2}

@onready var progress_bar: = $PanelContainer / MainContainer / ConsumptionContainer / ConsumptionBar
@onready var coal: = $PanelContainer / MainContainer / Coal
@onready var power: = $PanelContainer / MainContainer / Power

var speed: float
var active: bool
var consumption: float
var multiplier: float
var time: float


func _ready() -> void :
    super ()

    update_all()


func _process(delta: float) -> void :
    super (delta)
    progress_bar.value = lerpf(progress_bar.value, time / 10.0, 1.0 - exp(-50.0 * delta))


func process(delta: float) -> void :
    if active:
        power.count = speed * multiplier * Attributes.get_attribute("power_multiplier")
        time -= consumption * delta

    if time <= 0:
        if floorf(coal.count) > 0:
            active = true
            time += 10 * coal.pop(floorf(1 + floorf(absf(time) / 10.0)))
            multiplier = resource_multiplier[coal.resource]
        else:
            active = false
            time = 0
            multiplier = 0
            power.count = 0


func update_all() -> void :
    speed = 126
    consumption = 1
    set_window_name(get_window_name())
    $PanelContainer / MainContainer / ConsumptionContainer / ConsumptionLabelContainer / ConsumptionLabel.text = Utils.print_string(consumption / 10, false) + "/s"


func save() -> Dictionary:
    return super ().merged({
        "active": active, 
        "time": time, 
        "multiplier": multiplier
    })
