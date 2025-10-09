extends Control


func _ready() -> void :
	if Data.wiping:
		Globals.wipe()
		Data.wiping = false
	elif !Data.loading.is_empty():
		Globals.clear()
		for i: String in Data.loading.globals:
			Globals.set(i, Data.loading.globals[i])
		Globals.init_vars()
		Attributes.init_attributes()
	else:
		Globals.clear()
		Globals.init_vars()
		Attributes.init_attributes()

	$LogoContainer.position.y = size.y
	ResourceLoader.load_threaded_request("res://Main.tscn")
	var timer: SceneTreeTimer = get_tree().create_timer(3)
	timer.timeout.connect(check_loaded)

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($LogoContainer, "position:y", size.y / 2 - $LogoContainer.size.y / 2, 0.4)
	$AnimationPlayer.play("FadeIn")

	$LogoContainer / Name.text = tr("labs_os") + " " + ProjectSettings.get_setting("application/config/version")


func check_loaded() -> void :
	if ResourceLoader.load_threaded_get_status("res://Main.tscn") == 3:
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.5)
		tween.finished.connect(change_scene)
	else:
		var timer: SceneTreeTimer = get_tree().create_timer(0.1)
		timer.timeout.connect(check_loaded)


func change_scene() -> void :
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://Main.tscn"))
