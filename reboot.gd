extends Control

@export var section: int

@onready var progress_bar := $SkipContainer/ProgressBar
@onready var skip_timer := $Timer


func _ready() -> void:
    $AnimationPlayer.play("Intro")

    for i: String in Globals.upgrades:
        if !Data.upgrades.has(i):
            continue
        if !Data.upgrades[i].permanent:
            Globals.upgrades[i] = 0

    Attributes.init_attributes()

    for i: String in Globals.q_research:
        Globals.add_research(i, Globals.q_research[i])
    Globals.q_research.clear()

    for i: String in Globals.q_milestones:
        Globals.add_milestone(i, Globals.q_milestones[i])
        Globals.q_milestones[i] = 0

    Globals.storage_size = 0
    for i: String in Globals.storage:
        Globals.storage[i].clear()
    Globals.storage_value = Globals.get_storage_value()

    Globals.init_upgrades()

    for i: String in Data.windows:
        Globals.window_count[i] = 0
        if !Data.windows[i].data.is_empty():
            Globals.windows_data[i] = Data.windows[i].data.duplicate()

    for i: String in Globals.group_count:
        Globals.group_count[i] = 0

    for i: String in Globals.currencies:
        if i == "token":
            continue

        Globals.currencies[i] = 0

    Globals.hack_level = 0
    Globals.code_level = 0
    Globals.max_window_count = 0
    Globals.set_offline_multiplier(1)

    Globals.stats.reborns += 1


func _process(delta: float) -> void:
    if skip_timer.is_stopped():
        progress_bar.value = 0
    else:
        progress_bar.value = 1 - skip_timer.time_left


func boot() -> void:
    get_tree().change_scene_to_file("res://Main.tscn")


func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.is_pressed():
            var tween: Tween = create_tween()
            tween.tween_property($SkipContainer, "modulate:a", 1, 0.5)
            tween.tween_property($SkipContainer, "modulate:a", 1, 0.5)
            tween.tween_property($SkipContainer, "modulate:a", 0, 0.5)
            skip_timer.start(1)
        else:
            skip_timer.stop()


func _on_timer_timeout() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 0, 0.5)
    tween.finished.connect(boot)
