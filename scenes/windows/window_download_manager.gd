extends WindowIndexed

@onready var text_progress_label: = $PanelContainer / MainContainer / Text / Progress / ProgressContainer / ProgressLabel
@onready var text_progress_bar: = $PanelContainer / MainContainer / Text / Progress / ProgressBar
@onready var image_progress_label: = $PanelContainer / MainContainer / Image / Progress / ProgressContainer / ProgressLabel
@onready var image_progress_bar: = $PanelContainer / MainContainer / Image / Progress / ProgressBar
@onready var sound_progress_label: = $PanelContainer / MainContainer / Sound / Progress / ProgressContainer / ProgressLabel
@onready var sound_progress_bar: = $PanelContainer / MainContainer / Sound / Progress / ProgressBar
@onready var video_progress_label: = $PanelContainer / MainContainer / Video / Progress / ProgressContainer / ProgressLabel
@onready var video_progress_bar: = $PanelContainer / MainContainer / Video / Progress / ProgressBar
@onready var program_progress_label: = $PanelContainer / MainContainer / Program / Progress / ProgressContainer / ProgressLabel
@onready var program_progress_bar: = $PanelContainer / MainContainer / Program / Progress / ProgressBar
@onready var game_progress_label: = $PanelContainer / MainContainer / Game / Progress / ProgressContainer / ProgressLabel
@onready var game_progress_bar: = $PanelContainer / MainContainer / Game / Progress / ProgressBar
@onready var download: = $PanelContainer / MainContainer / Download
@onready var text: = $PanelContainer / MainContainer / Text / ResourceContainer / File
@onready var image: = $PanelContainer / MainContainer / Image / ResourceContainer / File
@onready var sound: = $PanelContainer / MainContainer / Sound / ResourceContainer / File
@onready var video: = $PanelContainer / MainContainer / Video / ResourceContainer / File
@onready var program: = $PanelContainer / MainContainer / Program / ResourceContainer / File
@onready var game: = $PanelContainer / MainContainer / Game / ResourceContainer / File
@onready var audio_player: = $AudioStreamPlayer2D

var text_progress: float
var image_progress: float
var sound_progress: float
var video_progress: float
var program_progress: float
var game_progress: float
var text_goal: float
var image_goal: float
var sound_goal: float
var video_goal: float
var program_goal: float
var game_goal: float

var text_expanded: bool
var image_expanded: bool
var sound_expanded: bool
var video_expanded: bool
var program_expanded: bool
var game_expanded: bool

var max_ratio: float
var text_ratio: float
var image_ratio: float
var sound_ratio: float
var video_ratio: float
var program_ratio: float
var game_ratio: float


func _ready() -> void :
    super ()
    Signals.new_unlock.connect(_on_new_unlock)
    Attributes.attributes["download_size_multiplier"].changed.connect(_on_download_size_changed)

    $PanelContainer / MainContainer / Text / RatioContainer.visible = text_expanded
    $PanelContainer / MainContainer / Text / RatioContainer / RatioSlider.value = text_ratio
    $PanelContainer / MainContainer / Image / RatioContainer.visible = image_expanded
    $PanelContainer / MainContainer / Image / RatioContainer / RatioSlider.value = image_ratio
    $PanelContainer / MainContainer / Sound / RatioContainer.visible = sound_expanded
    $PanelContainer / MainContainer / Sound / RatioContainer / RatioSlider.value = sound_ratio
    $PanelContainer / MainContainer / Video / RatioContainer.visible = video_expanded
    $PanelContainer / MainContainer / Video / RatioContainer / RatioSlider.value = video_ratio
    $PanelContainer / MainContainer / Program / RatioContainer.visible = program_expanded
    $PanelContainer / MainContainer / Program / RatioContainer / RatioSlider.value = program_ratio
    $PanelContainer / MainContainer / Game / RatioContainer.visible = game_expanded
    $PanelContainer / MainContainer / Game / RatioContainer / RatioSlider.value = game_ratio

    update_visible_downloads()
    update_ratios()
    update_goal()


func _process(delta: float) -> void :
    super (delta)
    text_progress_bar.value = lerpf(text_progress_bar.value, text_progress / text_goal, 1.0 - exp(-50.0 * delta))
    text_progress_label.text = Utils.print_metric(text_progress, false) + "b"
    image_progress_bar.value = lerpf(image_progress_bar.value, image_progress / image_goal, 1.0 - exp(-50.0 * delta))
    image_progress_label.text = Utils.print_metric(image_progress, false) + "b"
    sound_progress_bar.value = lerpf(sound_progress_bar.value, sound_progress / sound_goal, 1.0 - exp(-50.0 * delta))
    sound_progress_label.text = Utils.print_metric(sound_progress, false) + "b"
    video_progress_bar.value = lerpf(video_progress_bar.value, video_progress / video_goal, 1.0 - exp(-50.0 * delta))
    video_progress_label.text = Utils.print_metric(video_progress, false) + "b"
    program_progress_bar.value = lerpf(program_progress_bar.value, program_progress / program_goal, 1.0 - exp(-50.0 * delta))
    program_progress_label.text = Utils.print_metric(program_progress, false) + "b"
    game_progress_bar.value = lerpf(game_progress_bar.value, game_progress / game_goal, 1.0 - exp(-50.0 * delta))
    game_progress_label.text = Utils.print_metric(game_progress, false) + "b"


func process(delta: float) -> void :
    text_progress += download.count * (text_ratio / max_ratio) * delta
    if text_progress >= text_goal:
        var count: float = floorf(text_progress / text_goal)
        text.add(count)
        Globals.stats.downloads += count
        text_progress = fmod(text_progress, text_goal)
        audio_player.play()
        if is_processing():
            text.animate_icon_in_pop(count)
    text.production = download.count * (text_ratio / max_ratio) / text_goal

    image_progress += download.count * (image_ratio / max_ratio) * delta
    if image_progress >= image_goal:
        var count: float = floorf(image_progress / image_goal)
        image.add(count)
        Globals.stats.downloads += count
        image_progress = fmod(image_progress, image_goal)
        audio_player.play()
        if is_processing():
            image.animate_icon_in_pop(count)
    image.production = download.count * (image_ratio / max_ratio) / image_goal

    sound_progress += download.count * (sound_ratio / max_ratio) * delta
    if sound_progress >= sound_goal:
        var count: float = floorf(sound_progress / sound_goal)
        sound.add(count)
        Globals.stats.downloads += count
        sound_progress = fmod(sound_progress, sound_goal)
        audio_player.play()
        if is_processing():
            sound.animate_icon_in_pop(count)
    sound.production = download.count * (sound_ratio / max_ratio) / sound_goal

    video_progress += download.count * (video_ratio / max_ratio) * delta
    if video_progress >= video_goal:
        var count: float = floorf(video_progress / video_goal)
        video.add(count)
        Globals.stats.downloads += count
        video_progress = fmod(video_progress, video_goal)
        audio_player.play()
        if is_processing():
            video.animate_icon_in_pop(count)
    video.production = download.count * (video_ratio / max_ratio) / video_goal

    program_progress += download.count * (program_ratio / max_ratio) * delta
    if program_progress >= program_goal:
        var count: float = floorf(program_progress / program_goal)
        program.add(count)
        Globals.stats.downloads += count
        program_progress = fmod(program_progress, program_goal)
        audio_player.play()
        if is_processing():
            program.animate_icon_in_pop(count)
    program.production = download.count * (program_ratio / max_ratio) / program_goal

    game_progress += download.count * (game_ratio / max_ratio) * delta
    if game_progress >= game_goal:
        var count: float = floorf(game_progress / game_goal)
        game.add(count)
        Globals.stats.downloads += count
        game_progress = fmod(game_progress, game_goal)
        audio_player.play()
        if is_processing():
            game.animate_icon_in_pop(count)
    game.production = download.count * (game_ratio / max_ratio) / game_goal


func update_visible_downloads() -> void :
    $PanelContainer / MainContainer / Text.visible = true
    $PanelContainer / MainContainer / Image.visible = Globals.upgrades["image_downloader"]
    $PanelContainer / MainContainer / Sound.visible = Globals.upgrades["sound_downloader"]
    $PanelContainer / MainContainer / Video.visible = Globals.upgrades["video_downloader"]
    $PanelContainer / MainContainer / Program.visible = Globals.upgrades["program_downloader"]
    $PanelContainer / MainContainer / Game.visible = Globals.upgrades["game_downloader"]


func update_goal() -> void :
    text_goal = Utils.get_file_size(text.resource, text.variation) * Attributes.get_attribute("download_size_multiplier")
    $PanelContainer / MainContainer / Text / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(text_goal, false) + "b"
    image_goal = Utils.get_file_size(image.resource, image.variation) * Attributes.get_attribute("download_size_multiplier")
    $PanelContainer / MainContainer / Image / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(image_goal, false) + "b"
    sound_goal = Utils.get_file_size(sound.resource, sound.variation) * Attributes.get_attribute("download_size_multiplier")
    $PanelContainer / MainContainer / Sound / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(sound_goal, false) + "b"
    video_goal = Utils.get_file_size(video.resource, video.variation) * Attributes.get_attribute("download_size_multiplier")
    $PanelContainer / MainContainer / Video / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(video_goal, false) + "b"
    program_goal = Utils.get_file_size(program.resource, program.variation) * Attributes.get_attribute("download_size_multiplier")
    $PanelContainer / MainContainer / Program / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(program_goal, false) + "b"
    game_goal = Utils.get_file_size(game.resource, game.variation) * Attributes.get_attribute("download_size_multiplier")
    $PanelContainer / MainContainer / Game / Progress / ProgressContainer / SizeLabel.text = Utils.print_metric(game_goal, false) + "b"


func update_ratios() -> void :
    max_ratio = max(text_ratio + image_ratio + sound_ratio + video_ratio + program_ratio + game_ratio, 1)

    $PanelContainer / MainContainer / Text / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((text_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / Image / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((image_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / Sound / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((sound_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / Video / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((video_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / Program / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((program_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / Game / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((game_ratio * 100) / max_ratio)


func _on_text_expand_button_pressed() -> void :
    text_expanded = $PanelContainer / MainContainer / Text / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / Text / RatioContainer.visible = text_expanded
    Sound.play("click_toggle")


func _on_image_expand_button_pressed() -> void :
    image_expanded = $PanelContainer / MainContainer / Image / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / Image / RatioContainer.visible = image_expanded
    Sound.play("click_toggle")


func _on_sound_expand_button_pressed() -> void :
    sound_expanded = $PanelContainer / MainContainer / Sound / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / Sound / RatioContainer.visible = sound_expanded
    Sound.play("click_toggle")


func _on_video_expand_button_pressed() -> void :
    video_expanded = $PanelContainer / MainContainer / Video / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / Video / RatioContainer.visible = video_expanded
    Sound.play("click_toggle")


func _on_program_expand_button_pressed() -> void :
    program_expanded = $PanelContainer / MainContainer / Program / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / Program / RatioContainer.visible = program_expanded
    Sound.play("click_toggle")


func _on_game_expand_button_pressed() -> void :
    game_expanded = $PanelContainer / MainContainer / Game / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / Game / RatioContainer.visible = game_expanded
    Sound.play("click_toggle")


func _on_text_ratio_slider_drag_ended(value_changed: bool) -> void :
    text_ratio = $PanelContainer / MainContainer / Text / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_image_ratio_slider_drag_ended(value_changed: bool) -> void :
    image_ratio = $PanelContainer / MainContainer / Image / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_sound_ratio_slider_drag_ended(value_changed: bool) -> void :
    sound_ratio = $PanelContainer / MainContainer / Sound / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_video_ratio_slider_drag_ended(value_changed: bool) -> void :
    video_ratio = $PanelContainer / MainContainer / Video / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_program_ratio_slider_drag_ended(value_changed: bool) -> void :
    program_ratio = $PanelContainer / MainContainer / Program / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_game_ratio_slider_drag_ended(value_changed: bool) -> void :
    game_ratio = $PanelContainer / MainContainer / Game / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_new_unlock(unlock: String) -> void :
    update_visible_downloads()


func _on_download_size_changed() -> void :
    update_goal()


func save() -> Dictionary:
    return super ().merged({
        "text_progress": text_progress, 
        "image_progress": image_progress, 
        "sound_progress": sound_progress, 
        "video_progress": video_progress, 
        "program_progress": program_progress, 
        "game_progress": game_progress, 
        "text_ratio": text_ratio, 
        "image_ratio": image_ratio, 
        "sound_ratio": sound_ratio, 
        "video_ratio": video_ratio, 
        "program_ratio": program_ratio, 
        "game_ratio": game_ratio
    })
