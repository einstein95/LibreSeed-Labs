extends WindowIndexed

@onready var collect_button := $CollectButton
@onready var collect_label := $CollectButton/CollectContainer/AmountContainer/Label
@onready var graph := $PanelContainer/MainContainer/Graph
@onready var money := $PanelContainer/MainContainer/Money
@onready var value_label := $PanelContainer/MainContainer/Value/Info/Count

var market: Node
var cur_amount: float
var graph_ticks: int


func _ready() -> void:
    super ()
    market = get_node("/root/Main/Markets/money")


func _process(delta: float) -> void:
    super (delta)
    collect_label.text = "+" + Utils.print_string(cur_amount, true)
    collect_button.disabled = floorf(cur_amount) < 1


func process(delta: float) -> void:
    value_label.text = "%.0f" % (market.current_value * 100) + "/%.0f%%" % (market.max_value * 100)
    cur_amount = money.count * market.current_value
    if graph_ticks <= 0:
        graph.add_value(market.current_value)
        graph_ticks = 20
    else:
        graph_ticks -= 1


func _on_collect_button_pressed() -> void:
    money.pop_all()
    Globals.currencies["money"] += cur_amount
    cur_amount = 0

    market.crash_market(market.current_value / market.max_value)

    Sound.play("cash_register")
