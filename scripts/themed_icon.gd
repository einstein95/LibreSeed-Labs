class_name ThemedIcon extends TextureRect

var color: Color
var highlight_color: Color


func _ready() -> void:
    color = Color(Data.themes[Data.cur_theme].icon_color)
    self_modulate = color
