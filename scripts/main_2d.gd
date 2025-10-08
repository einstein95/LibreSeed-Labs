extends Control

var transitioning_to: int = -1
var screen_position: Array[Vector2] = [Vector2(0, 0), Vector2(0, 800), Vector2(0, 0)]
var screen_zoom: Array[Vector2] = [Vector2(1, 1), Vector2(1, 1), Vector2(1, 1)]
var screen_size: Array[float] = [5000, 1000, 1000]
var screen_min_zoom: Array[Vector2] = [Vector2(0.1, 0.1), Vector2(0.5, 0.5), Vector2(0.5, 0.5)]

@onready var popups: = $Popups

var available_popups: Array[Node2D]

func _ready() -> void :
    Signals.set_screen.connect(_on_set_screen)
    Signals.spawn_particle.connect(_on_spawn_particle)
    Signals.spawn_popup.connect(_on_spawn_popup)

    for i: int in 60:
        available_popups.append(add_popup())

    set_screen(0)


func transition_to(screen: int, center: Vector2) -> void :
    if transitioning_to == -1:
        screen_position[Globals.cur_screen] = $Camera2D.position
        screen_zoom[Globals.cur_screen] = $Camera2D.zoom
        var new_tween: Tween = begin_transition()
        new_tween.finished.connect(end_transition)
    transitioning_to = screen


func begin_transition() -> Tween:
    $Dragger.visible = false
    Signals.screen_transition_started.emit()

    $Camera2D.set_process(false)
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property($Camera2D, "zoom", Vector2(10, 10), 0.5)
    tween.tween_property(self, "modulate:a", 0, 0.25)
    Sound.play("transition" + str(randi() %2 + 1))

    return tween


func end_transition() -> Tween:
    set_screen(transitioning_to)
    transitioning_to = -1
    Signals.screen_transition_finished.emit()

    $Dragger.visible = true
    var tween: Tween = create_tween()
    tween.set_parallel()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property($Camera2D, "zoom", screen_zoom[Globals.cur_screen], 0.5)
    tween.tween_property(self, "modulate:a", 1, 0.25)
    tween.finished.connect( func() -> void : $Camera2D.target_zoom = $Camera2D.zoom;$Camera2D.set_process(true))

    return tween


func set_screen(screen: int) -> void :
    Globals.cur_screen = screen
    Signals.screen_set.emit(screen)

    $Desktop.visible = Globals.cur_screen == 0
    $Research.visible = Globals.cur_screen == 1
    $Ascension.visible = Globals.cur_screen == 2
    $Camera2D.position = screen_position[screen]
    $Camera2D.limit = screen_size[screen]
    $Camera2D.min_zoom = screen_min_zoom[screen]
    $Camera2D.reset_smoothing()


func add_popup() -> Node2D:
    var instance: Node2D = load("res://scenes/label_popup.tscn").instantiate()
    popups.add_child(instance)
    instance.got_free.connect(_on_popup_got_free)
    return instance


func _on_popup_got_free(popup: Node2D) -> void :
    available_popups.append(popup)


func _on_set_screen(screen: int, center: Vector2) -> void :
    transition_to(screen, center)


func _on_spawn_particle(particle: GPUParticles2D, pos: Vector2) -> void :
    add_child(particle)
    particle.global_position = pos


func _on_spawn_popup(text: String, pos: Vector2) -> void :
    var popup: Node2D
    if available_popups.size() > 0:
        popup = available_popups.pop_back()
    else:
        return
    popup.display(text, pos)
