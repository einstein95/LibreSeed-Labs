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

@onready var collect_button := $CollectButton
@onready var collect_label := $CollectButton/CollectContainer/AmountContainer/Label
@onready var graph := $PanelContainer/MainContainer/Graph
@onready var coin := $PanelContainer/MainContainer/Coin
@onready var value_label := $PanelContainer/MainContainer/Value/Info/Count
var market: Node

var valid: bool
var coin_value: float
var noise_offset: float
var attribute: String
var cur_amount: float
var graph_ticks: int


func _ready() -> void:
    super ()

    coin.resource_set.connect(_on_resource_set)
    update_coin()


func _process(delta: float) -> void:
    super (delta)
    collect_label.text = "+" + Utils.print_string(cur_amount, true)
    collect_button.disabled = floorf(cur_amount) < 1


func process(delta: float) -> void:
    if !valid:
        return

    update_values()
    if graph_ticks <= 0:
        graph.add_value(market.current_value)
        graph_ticks = 20
    else:
        graph_ticks -= 1


func update_values() -> void:
    value_label.text = "%.0f" % (market.current_value * 100) + "/%.0f%%" % (market.max_value * 100)

    var attribute_multiplier: float = Attributes.get_attribute("income_multiplier") * \
Attributes.get_attribute("mining_multiplier") * Attributes.get_attribute(attribute)
    cur_amount = coin_value * coin.count * attribute_multiplier * market.current_value


func update_coin() -> void:
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


func _on_resource_set() -> void:
    graph.clear_data()
    update_coin()


func _on_collect_button_pressed() -> void:
    coin.pop_all()
    Globals.currencies["money"] += cur_amount
    Globals.max_money += cur_amount
    Globals.stats.max_money += cur_amount
    cur_amount = 0

    market.crash_market(market.current_value / market.max_value)

    Sound.play("cash_register")
