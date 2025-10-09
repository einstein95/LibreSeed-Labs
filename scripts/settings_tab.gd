extends VBoxContainer

const language_buttons: Dictionary = {"en": "English", "zh": "TrChinese", "es": "Spanish", "fr": "French", 
"de": "German", "pt": "Portuguese", "id": "Indonesian", "ja": "Japanese", "ko": "Korean", "pl": "Polish"}

var initialized: bool


func _ready() -> void :
	Signals.setting_set.connect(_on_setting_set)
	Signals.menu_set.connect(_on_menu_set)

	if Globals.is_mobile():
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.min_value = 0.8
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.max_value = 1.3
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.tick_count = 6
	else:
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.min_value = 0.5
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.max_value = 1.0
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.tick_count = 6

	$TabContainer / Preferences / MarginContainer / SettingsContainer / LimitFPS / HSlider.value = Data.fps_limit
	$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.value = Data.scale
	$TabContainer / Preferences / MarginContainer / SettingsContainer / Colorblind / CheckButton.button_pressed = Data.colorblind
	$TabContainer / Preferences / MarginContainer / SettingsContainer / Scientific / CheckButton.button_pressed = Data.scientific
	$TabContainer / Preferences / MarginContainer / SettingsContainer / Glow / CheckButton.button_pressed = Data.glow
	$TabContainer / Preferences / MarginContainer / SettingsContainer / MuteSFX / CheckButton.button_pressed = Data.mute_sfx
	$TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeSFX / HSlider.value = Data.volume_sfx
	$TabContainer / Preferences / MarginContainer / SettingsContainer / MuteWindows / CheckButton.button_pressed = Data.mute_windows
	$TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeWindows / HSlider.value = Data.volume_windows
	$TabContainer / Preferences / MarginContainer / SettingsContainer / MuteBGM / CheckButton.button_pressed = Data.mute_bgm
	$TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeBGM / HSlider.value = Data.volume_bgm

	for i: Button in $TabContainer / Preferences / MarginContainer / SettingsContainer / Language / ScrollContainer / MarginContainer / LanguageContainer.get_children():
		i.pressed.connect(_on_language_button_pressed.bind(i.get_meta("language")))

	update_settings_label()


func set_tab(tab: int) -> void :
	$TabContainer.current_tab = tab
	for i: Button in $Panel / ButtonsContainer.get_children():
		i.button_pressed = i.get_index() == tab


func update_settings_label() -> void :
	$TabContainer / Preferences / MarginContainer / SettingsContainer / LimitFPS / LabelContainer / Value.text = str(Data.fps_limit)

	if Globals.is_mobile():
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / LabelContainer / Value.text = "%.1fx" % (Data.scale)
	else:
		$TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / LabelContainer / Value.text = "%.1fx" % (Data.scale + 0.3)

	$TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeSFX / LabelContainer / Value.text = "%.0f%%" % (Data.volume_sfx * 100)
	$TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeWindows / LabelContainer / Value.text = "%.0f%%" % (Data.volume_windows * 100)
	$TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeBGM / LabelContainer / Value.text = "%.0f%%" % (Data.volume_bgm * 100)

	if language_buttons.has(TranslationServer.get_locale()):
		for i: Button in $TabContainer / Preferences / MarginContainer / SettingsContainer / Language / ScrollContainer / MarginContainer / LanguageContainer.get_children():
			i.button_pressed = i.name == language_buttons[TranslationServer.get_locale()]


func _on_settings_pressed() -> void :
	set_tab(0)
	Sound.play("click_toggle2")


func _on_save_pressed() -> void :
	set_tab(1)
	Sound.play("click_toggle2")


func _on_stats_pressed() -> void :
	set_tab(2)
	Sound.play("click_toggle2")


func _on_attributes_pressed() -> void :
	set_tab(3)
	Sound.play("click_toggle2")


func _on_colorblind_check_button_pressed() -> void :
	Data.set_setting("colorblind", $TabContainer / Preferences / MarginContainer / SettingsContainer / Colorblind / CheckButton.button_pressed)
	Sound.play("click_toggle2")


func _on_scientific_check_button_pressed() -> void :
	Data.set_setting("scientific", $TabContainer / Preferences / MarginContainer / SettingsContainer / Scientific / CheckButton.button_pressed)
	Sound.play("click_toggle2")


func _on_glow_check_button_pressed() -> void :
	Data.set_setting("glow", $TabContainer / Preferences / MarginContainer / SettingsContainer / Glow / CheckButton.button_pressed)
	Sound.play("click_toggle2")


func _on_mute_sfx_check_button_pressed() -> void :
	Data.set_setting("mute_sfx", $TabContainer / Preferences / MarginContainer / SettingsContainer / MuteSFX / CheckButton.button_pressed)
	Sound.play("click_toggle2")


func _on_volume_sfx_slider_drag_ended(value_changed: bool) -> void :
	Data.set_setting("volume_sfx", $TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeSFX / HSlider.value)
	Sound.play("click")


func _on_mute_windows_check_button_pressed() -> void :
	Data.set_setting("mute_windows", $TabContainer / Preferences / MarginContainer / SettingsContainer / MuteWindows / CheckButton.button_pressed)
	Sound.play("click_toggle2")


func _on_volume_windows_slider_drag_ended(value_changed: bool) -> void :
	Data.set_setting("volume_windows", $TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeWindows / HSlider.value)
	Sound.play("click")


func _on_mute_bgm_check_button_pressed() -> void :
	Data.set_setting("mute_bgm", $TabContainer / Preferences / MarginContainer / SettingsContainer / MuteBGM / CheckButton.button_pressed)
	Sound.play("click_toggle2")


func _on_volume_bgm_slider_drag_ended(value_changed: bool) -> void :
	Data.set_setting("volume_bgm", $TabContainer / Preferences / MarginContainer / SettingsContainer / VolumeBGM / HSlider.value)
	Sound.play("click")


func _on_setting_set(setting: String) -> void :
	update_settings_label()


func _on_menu_set(menu: int, tab: int) -> void :
	if menu != Utils.menu_types.SIDE and tab != Utils.menus.SETTINGS: return
	if initialized: return

	for i: String in Data.stats:
		if Data.stats[i].hidden: continue
		var instance: Panel = preload("res://scenes/stat_panel.tscn").instantiate()
		instance.name = i
		$TabContainer / Stats / MarginContainer / StatsContainer.add_child(instance)

	initialized = true


func _on_limit_fps_slider_drag_ended(value_changed: bool) -> void :
	Data.set_setting("fps_limit", $TabContainer / Preferences / MarginContainer / SettingsContainer / LimitFPS / HSlider.value)
	Sound.play("click")


func _on_ui_scale_slider_drag_ended(value_changed: bool) -> void :
	Data.set_setting("scale", $TabContainer / Preferences / MarginContainer / SettingsContainer / UiScale / HSlider.value)
	Sound.play("click")


func _on_export_pressed() -> void :
	var save: Dictionary = Data.get_save_data()
	var file: ConfigFile = ConfigFile.new()
	file.set_value("save", "desktop_data", save["desktop_data"])
	file.set_value("save", "globals", save["globals"])
	$TabContainer / Save / Export / Code.text = Marshalls.utf8_to_base64(file.encode_to_text())


func _on_import_pressed() -> void :
	var save: String = Marshalls.base64_to_utf8($TabContainer / Save / Export / Code.text)

	var file: ConfigFile = ConfigFile.new()
	if file.parse(save) == OK:
		Data.load_save_data({"desktop_data": file.get_value("save", "desktop_data"), "globals": file.get_value("save", "globals")})
		get_tree().change_scene_to_file("res://boot.tscn")


func _on_language_button_pressed(language: String) -> void :
	Data.set_setting("language", language)
	Sound.play("click")


func _on_wipe_pressed() -> void :
	Signals.popup.emit("Wipe")
	Sound.play("click")


func _on_sync_pressed() -> void :
	Signals.popup.emit("SaveSync")
	Sound.play("click")

func _on_quit_pressed() -> void :
	get_tree().quit()
	Sound.play("click")
