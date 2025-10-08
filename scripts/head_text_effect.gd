@tool
class_name RichTextHeadEffect
extends RichTextEffect

var bbcode: = "heading"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
    char_fx.color = Color("ff8500")
    char_fx.transform = char_fx.transform.scaled(Vector2(1.5, 1.5))
    char_fx.range *= 4
    return true
