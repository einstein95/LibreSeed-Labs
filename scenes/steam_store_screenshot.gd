extends Node

@export var premium: String


func _ready() -> void :
    $PremiumPanel / IconPanel / Icon.texture = load("res://textures/icons/" + Data.premiums[premium].icon + ".png")
    $PremiumPanel / InfoContainer / Name.text = Data.premiums[premium].name
    $PremiumPanel / InfoContainer / Description.text = ""

    var benefits: PackedStringArray = tr(Data.premiums[premium].description).split("\n")
    for i: int in benefits.size():
        $PremiumPanel / InfoContainer / Description.text += "• " + benefits[i]
        if i != benefits.size():
            $PremiumPanel / InfoContainer / Description.text += "\n"
