extends WindowIndexed

@onready var money: = $PanelContainer / MainContainer / Money
@onready var product: = $PanelContainer / MainContainer / Product

@export var price: float
@export var price_e: int


func _ready() -> void :
    super ()
    money.set_required(price * pow(10, price_e))


func process(delta: float) -> void :
    if money.count >= money.required:
        var count: float = floorf(money.count / money.required)
        money.pop(count * money.required)
        product.add(count)
        if is_processing():
            product.animate_icon_in_pop(count)

    product.production = money.production / money.required
