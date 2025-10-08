extends Control

@export_range(0.0, 1.0) var texture_scale: float = 1.0:
    set(s): texture_scale = s;update()
@export var texture: Texture2D:
    set(t): texture = t;update()
var rid: RID


func _enter_tree() -> void :
    rid = RenderingServer.canvas_item_create()
    RenderingServer.canvas_item_set_parent(rid, get_canvas_item())


func _ready() -> void :
    update()


func _set(property: StringName, value: Variant) -> bool:
    if property == "self_modulate":
        self_modulate = value
        update()
        return false
    else:
        return false


func update() -> void :
    if rid:
        RenderingServer.canvas_item_clear(rid)
        if texture:
            var tex_size: Vector2 = Vector2(size.x * texture_scale, size.y * texture_scale)
            var tex_position: Vector2 = (size - tex_size) / 2.0
            RenderingServer.canvas_item_add_texture_rect(rid, Rect2(tex_position, tex_size), texture, false, self_modulate)


func _exit_tree() -> void :
    RenderingServer.free_rid(rid)
