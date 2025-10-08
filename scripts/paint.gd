@tool
extends Node2D


func _draw() -> void :
    draw_rect(Rect2(Vector2(-5000, -5000), Vector2(10000, 10000)), Color.WHITE)
