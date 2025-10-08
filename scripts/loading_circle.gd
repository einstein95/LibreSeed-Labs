@tool
extends Control

@export_group("Loader Appearance")
@export var arc_color: Color = Color("ff8500")
@export var track_color: Color = Color("455575")
@export var line_width: float = 6.0:
    set(value):
        line_width = max(1.0, value)
        queue_redraw()
@export var arc_angle_degrees: float = 75.0:
    set(value):
        arc_angle_degrees = clamp(value, 10.0, 170.0)
        queue_redraw()

@export_group("Animation")
@export var rotation_speed_dps: float = 180.0
@export var show_track: bool = true:
    set(value):
        show_track = value
        queue_redraw()

var current_rotation_radians: float = 0.0


func _process(delta: float) -> void :
    current_rotation_radians += deg_to_rad(rotation_speed_dps) * delta
    current_rotation_radians = fmod(current_rotation_radians, PI * 2.0)
    queue_redraw()


func _draw() -> void :
    var center: Vector2 = size / 2.0
    var radius: float = min(size.x, size.y) / 2.0 - line_width / 2.0

    if radius <= line_width / 2.0:
        return

    if show_track:
        var track_line_width = line_width * 0.8
        draw_circle(center, radius, track_color.darkened(0.3), false, track_line_width, true)


    var arc_length_radians: float = deg_to_rad(arc_angle_degrees)

    var start_angle1: float = current_rotation_radians
    var end_angle1: float = current_rotation_radians + arc_length_radians
    draw_arc(center, radius, start_angle1, end_angle1, 64, arc_color, line_width, true)

    var start_angle2: float = current_rotation_radians + PI
    var end_angle2: float = current_rotation_radians + PI + arc_length_radians
    draw_arc(center, radius, start_angle2, end_angle2, 64, arc_color, line_width, true)
