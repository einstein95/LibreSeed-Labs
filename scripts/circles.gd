@tool
extends Node2D


func _draw() -> void :
    for i: int in range(1, 6):
        draw_circle(Vector2.ZERO, 50 + 128 * i, Color("91b1e61a"), false, 2, true)
