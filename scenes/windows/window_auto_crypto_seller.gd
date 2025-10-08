extends WindowIndexed

const coins: Dictionary = {
    "litecoin": {
        "value": 1200000.0, 
        "noise_offset": 0, 
        "attribute": "litecoin_value_multiplier"
    }, 
    "bitcoin": {
        "value": 200000000.0, 
        "noise_offset": 1000, 
        "attribute": "bitcoin_value_multiplier"
    }, 
    "ethereum": {
        "value": 60000000.0, 
        "noise_offset": 2000, 
        "attribute": "ethereum_value_multiplier"
    }
}

@onready var graph: = $PanelContainer / MainContainer / Graph
@onready var coin: = $PanelContainer / MainContainer / Coin
@onready var money: = $PanelContainer / MainContainer / Money
@onready var value_label: = $PanelContainer / MainContainer / Value / Info / Count
@onready var audio: = $AudioStreamPlayer2D
var market: Node

var valid: bool
var coin_value: float
var noise_offset: float
var attribute: String
var graph_ticks: int
var autocollect: float = 1.0
var cooldown: float


func _ready() -> void :
    super ()

    coin.resource_set.connect(_on_resource_set)
    update_coin()
    $PanelContainer / MainContainer / RatioContainer / RatioSlider.value = autocollect

    update_auto_collect()


func process(delta: float) -> void :
    if !valid: return

    update_values()
    if graph_ticks <= 0:
        graph.add_value(market.current_value)
        graph_ticks = 20
    else:
        graph_ticks -= 1

    if cooldown <= 0:
        if market.current_value >= autocollect:
            collect()
            cooldown = 2
    else:
        cooldown = max(cooldown - delta, 0)


func collect() -> void :
    var amount: float = money.pop_all()
    coin.pop_all()
    Globals.currencies["money"] += amount
    Globals.max_money += amount
    Globals.stats.max_money += amount

    market.crash_market(market.current_value / market.max_value)
    audio.play()


func update_values() -> void :
    value_label.text = "%.0f" % (market.current_value * 100) + "/%.0f%%" % (market.max_value * 100)

    var attribute_multiplier: float = Attributes.get_attribute("income_multiplier") * \
Attributes.get_attribute("mining_multiplier") * Attributes.get_attribute(attribute)
    money.count = coin_value * coin.count * attribute_multiplier * market.current_value


func update_coin() -> void :
    valid = coins.has(coin.resource)
    if valid:
        market = get_node("/root/Main/Markets/" + coin.resource)
        coin_value = coins[coin.resource].value
        noise_offset = coins[coin.resource].noise_offset
        attribute = coins[coin.resource].attribute

        update_values()

        graph.min_range = 1.0 / market.max_value
        graph.max_range = market.max_value
    else:
        graph.min_range = 0
        graph.max_range = 1.0
    $PanelContainer / MainContainer / RatioContainer / RatioSlider.min_value = graph.min_range
    $PanelContainer / MainContainer / RatioContainer / RatioSlider.max_value = graph.max_range


func update_auto_collect() -> void :
    $PanelContainer / MainContainer / RatioContainer / RatioLabelContainer / RatioLabel.text = "%0.f%%" % (autocollect * 100)


func _on_resource_set() -> void :
    update_coin()


func _on_ratio_slider_drag_ended(value_changed: bool) -> void :
    autocollect = $PanelContainer / MainContainer / RatioContainer / RatioSlider.value
    update_auto_collect()


func save() -> Dictionary:
    return super ().merged({
        "autocollect": autocollect
    })
