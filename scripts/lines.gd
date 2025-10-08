extends Control

var rid: RID


func _enter_tree() -> void :
    rid = RenderingServer.canvas_item_create()
    RenderingServer.canvas_item_set_parent(rid, get_canvas_item())


func _ready() -> void :
    for y: int in range(-99, 102):
        var length: int = 2
        if (y - 1) %10 == 0:
            length = 4
        RenderingServer.canvas_item_add_line(rid, Vector2(-5000, 50 * y), Vector2(5100, 50 * y), Color(1, 1, 1, 0.1), length)
    for x: int in range(-99, 102):
        var length: int = 2
        if (x - 1) %10 == 0:
            length = 4
        RenderingServer.canvas_item_add_line(rid, Vector2(50 * x, -5000), Vector2(50 * x, 5100), Color(1, 1, 1, 0.1), length)


func _process(delta: float) -> void :
    visible = Globals.camera_zoom.x >= 0.4


func _exit_tree() -> void :
    RenderingServer.free_rid(rid)
