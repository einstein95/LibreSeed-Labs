extends Node

var last_recorded_time: int


func _ready() -> void :
    Signals.setting_set.connect(_on_setting_set)
    Signals.reboot.connect(_on_reboot)
    Signals.new_hack_level.connect(_on_new_hack_level)
    Signals.new_code_level.connect(_on_new_code_level)
    Signals.add_timed_effect.connect(_on_add_timed_effect)
    get_tree().auto_accept_quit = false
    get_tree().create_timer(60).timeout.connect( func() -> void : $AudioStreamPlayer.play())

    for i: String in Data.boosts:
        var boost: Node = load("res://scripts/boost.gd").new()
        boost.name = i
        $Boosts.add_child(boost)

    for i: String in Data.achievements:
        if Globals.achievements[i] >= 1: continue
        var achievement: Node = load("res://scripts/achievements/" + Data.achievements[i].script + ".gd").new()
        achievement.name = i
        $Achievements.add_child(achievement)

    for i: String in Data.requests:
        if Globals.requests[i] >= 1: continue
        var request: Node = load("res://scripts/achievements/request.gd").new()
        request.name = i
        $Requests.add_child(request)

    if Time.get_unix_time_from_system() - Globals.last_recorded_time > 4:
        Globals.add_offline_time((Time.get_unix_time_from_system() - Globals.last_recorded_time) * Attributes.get_attribute("rest_time_multiplier") / 72)
    Globals.last_recorded_time = Time.get_unix_time_from_system()
    last_recorded_time = Time.get_unix_time_from_system()

    update_environment()


func _input(event: InputEvent) -> void :
    if event is InputEventKey and event.is_released():
        if event.keycode == KEY_F11:
            if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
            else:
                DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
        if event.keycode == KEY_F12:
            var dir_access: DirAccess = DirAccess.open("user://")
            if !dir_access.dir_exists("screenshots"):
                dir_access.make_dir("screenshots")

            var file_name: String = Time.get_datetime_string_from_system().replace(":", "-")
            var dir: String = OS.get_user_data_dir().path_join("screenshots")
            var path: String = dir.path_join(file_name)
            var id: int = 1
            while dir_access.file_exists(path + ".png"):
                id += 1
                if file_name.ends_with(")"):
                    file_name = file_name.substr(0, file_name.length() - 3)
                file_name += "(%d)" % id
                path = dir.path_join(file_name)

            path += ".png"
            var image: Image = get_viewport().get_texture().get_image()
            var error: int = image.save_png(path)
            if error == OK:
                Signals.notify.emit("image", "{path}".format({"path": path}))


func tick() -> void :
    if Time.get_unix_time_from_system() - last_recorded_time > 4:
        Globals.add_offline_time((Time.get_unix_time_from_system() - last_recorded_time) * Attributes.get_attribute("rest_time_multiplier") / 72)
    last_recorded_time = Time.get_unix_time_from_system()


func update_environment() -> void :
    if Data.glow:
        $WorldEnvironment.environment.background_mode = 3
    else:
        $WorldEnvironment.environment.background_mode = 0


func _on_sec_timer_timeout() -> void :
    tick()
    Signals.tick.emit()


func _on_save_timer_timeout() -> void :
    Data.save_data_file("user://savegame.dat")


func _on_save_timer2_timeout() -> void :
    Data.save_data_file("user://savegame_backup.dat")


func _notification(what: int) -> void :
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        Data.save_data_file("user://savegame.dat")
        get_tree().quit()


func _on_audio_stream_player_2d_finished() -> void :
    get_tree().create_timer((randi() %3 + 3) * 60).timeout.connect( func() -> void : $AudioStreamPlayer.play())


func _on_reboot() -> void :
    $SecTimer.stop()
    set_process(false)
    set_physics_process(false)
    $HUD / GlitchFade / AnimationPlayer.play("Glitch")
    get_tree().create_timer(1).timeout.connect(
        func() -> void : get_tree().change_scene_to_file("res://reboot.tscn")
        )

func _on_new_hack_level() -> void :
    Signals.notify.emit("hacker", "new_hack_level")
    Sound.play("new_level")


func _on_new_code_level() -> void :
    Signals.notify.emit("code", "new_code_level")
    Sound.play("new_level")


func _on_setting_set(setting: String) -> void :
    update_environment()


func _on_add_timed_effect(effect: Node) -> void :
    $Effects.add_child(effect)
