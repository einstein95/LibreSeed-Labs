extends Node2D

@onready var lines: = $Lines
@onready var research_buttons: = $Research


func _ready() -> void :
    Signals.research_queued.connect(_on_research_queued)

    update_lines()


func update_lines() -> void :
    RenderingServer.canvas_item_clear(lines.get_canvas_item())

    for i: Button in research_buttons.get_children():
        if !Data.research[i.name].requirement.is_empty():
            for research: String in Data.research[i.name].requirement:
                var target: Control = research_buttons.get_node(research)
                var line: RID = RenderingServer.canvas_item_create()
                var color: Color = Color("91b1e61a")

                if Globals.research[research] or Globals.q_research.has(research):
                    color = Color("91b1e6")

                if target.radius != i.radius:
                    RenderingServer.canvas_item_add_line(line, i.global_position + (i.size / 2), target.global_position + (target.size / 2), color, 2, true)
                else:
                    var points: PackedVector2Array
                    var colors: PackedColorArray

                    for step: int in range(0, abs(target.angle_degrees - i.angle_degrees) + 1, 1):
                        var current_angle: float = i.angle_degrees + step * sign(target.angle_degrees - i.angle_degrees)

                        var t: float = float(step) / abs(target.angle_degrees - i.angle_degrees) if target.angle_degrees != i.angle_degrees else 0

                        var pos = Vector2(
                            (50 + target.radius * 128) * cos(deg_to_rad(current_angle)), 
                            (50 + target.radius * 128) * sin(deg_to_rad(current_angle))
                        )

                        points.append(pos)
                        colors.append(color)
                    RenderingServer.canvas_item_add_polyline(line, points, colors, 2, true)
                RenderingServer.canvas_item_set_parent(line, lines.get_canvas_item())











func _on_research_queued(research: String, levels: int) -> void :
    update_lines()
