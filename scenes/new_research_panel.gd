extends TextureRect


func _ready() -> void :
    texture = load("res://textures/icons/" + Data.research[name].icon + ".png")
