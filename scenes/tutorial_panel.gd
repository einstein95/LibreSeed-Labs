extends PanelContainer

const continue_steps: Array[int] = [Utils.tutorial_steps.PRESS, Utils.tutorial_steps.PRESS2,
Utils.tutorial_steps.PRESS3, Utils.tutorial_steps.PRESS4, Utils.tutorial_steps.PRESS5,
Utils.tutorial_steps.PRESS6]
const step_descs: Array[String] = [
    "tutorial_desc_press", "tutorial_desc_drag_download",
    "tutorial_desc_connect_download", "tutorial_desc_press2", "tutorial_desc_drag_bin_connector",
    "tutorial_desc_press3", "tutorial_desc_open_menu", "tutorial_desc_select_uploader",
    "tutorial_desc_add_uploader", "tutorial_desc_drag_uploader", "tutorial_desc_move_uploader",
    "tutorial_desc_connect_file", "tutorial_desc_connect_file", "tutorial_desc_connect_upload",
    "tutorial_desc_connect_upload", "tutorial_desc_press4", "tutorial_desc_open_menu2",
    "tutorial_desc_select_collector", "tutorial_desc_add_collector", "tutorial_desc_connect_money",
    "tutorial_desc_connect_money", "tutorial_desc_press5", "tutorial_desc_select_bin",
    "tutorial_desc_delete_bin", "tutorial_desc_press6", ""
]

var cur_step: String
var animation_done: bool
var clicked: bool


func _enter_tree() -> void:
    if Globals.tutorial_done:
        queue_free()
        return
    Signals.tutorial_step.connect(_on_tutorial_step)


func _ready() -> void:
    if Globals.tutorial_done:
        return

    var tween: Tween = create_tween()
    tween.set_loops()
    tween.tween_property($TutorialContainer/DescriptionContainer/TextureRect, "self_modulate:a", 0.3, 0.6)
    tween.tween_property($TutorialContainer/DescriptionContainer/TextureRect, "self_modulate:a", 1, 0.6)
    show()

    update_step()

    if Globals.tutorial_step >= Utils.tutorial_steps.PRESS + 1:
        move_top()


func update_step() -> void:
    if cur_step != step_descs[Globals.tutorial_step]:
        cur_step = step_descs[Globals.tutorial_step]
        $TutorialContainer/DescriptionContainer/Description.text = tr(step_descs[Globals.tutorial_step])
        $TutorialContainer/DescriptionContainer/Description.visible_ratio = 0

        var tween: Tween = create_tween()
        tween.tween_property($TutorialContainer/DescriptionContainer/Description, "visible_ratio", 1.0, 0.4)
        tween.finished.connect(func() -> void: animation_done = continue_steps.has(Globals.tutorial_step); $TutorialContainer/DescriptionContainer/TextureRect.visible = animation_done)


func move_top() -> void:
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "offset_top", 0, 0.6)
    tween.tween_property(self, "offset_bottom", 250, 0.6)
    tween.tween_property(self, "anchor_top", 1, 0.6)
    tween.tween_property(self, "anchor_bottom", 0, 0.6)


func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.is_released():
            if continue_steps.has(Globals.tutorial_step):
                Globals.set_tutorial_step(Globals.tutorial_step + 1)


func _on_tutorial_step() -> void:
    update_step()

    if continue_steps.has(Globals.tutorial_step):
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit(null)

    if Globals.tutorial_step == Utils.tutorial_steps.PRESS + 1:
        move_top()

    if Globals.tutorial_done:
        queue_free()
