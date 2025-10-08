extends Panel


func _ready() -> void :
    Premiums.updated.connect(_on_premium_updated)

    $IconPanel / Icon.texture = load("res://textures/icons/" + Data.premiums[name].icon + ".png")
    $InfoContainer / Name.text = tr(Data.premiums[name].name)
    $InfoContainer / Description.text = ""

    var benefits: PackedStringArray = tr(Data.premiums[name].description).split("\n")
    for i: int in benefits.size():
        $InfoContainer / Description.text += "• " + benefits[i]
        if i != benefits.size():
            $InfoContainer / Description.text += "\n"

    visible = int(Data.premiums[name].platform) == Globals.platform or Premiums.premiums[name]
    update_all()


func update_all() -> void :
    var owned: bool = Premiums.premiums[name]
    $Purchase.disabled = owned

    if owned:
        $Purchase / Cost.text = tr("owned")
    else:
        if Premiums.product_details.has(Data.premiums[name].id):
            $Purchase / Cost.text = Premiums.product_details[Data.premiums[name].id].price
        else:
            $Purchase / Cost.text = "$%.2f" % Data.premiums[name].default_price


func _on_purchase_pressed() -> void :
    Premiums.attempt_purchase(name)
    Sound.play("click2")


func _on_premium_updated() -> void :
    update_all()
