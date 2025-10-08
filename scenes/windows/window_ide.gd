extends WindowIndexed

@onready var bool_progress_label: = $PanelContainer / MainContainer / bool / Progress / ProgressContainer / ProgressLabel
@onready var bool_progress_bar: = $PanelContainer / MainContainer / bool / Progress / ProgressBar
@onready var float_progress_label: = $PanelContainer / MainContainer / float / Progress / ProgressContainer / ProgressLabel
@onready var float_progress_bar: = $PanelContainer / MainContainer / float / Progress / ProgressBar
@onready var char_progress_label: = $PanelContainer / MainContainer / char / Progress / ProgressContainer / ProgressLabel
@onready var char_progress_bar: = $PanelContainer / MainContainer / char / Progress / ProgressBar
@onready var int_progress_label: = $PanelContainer / MainContainer / int / Progress / ProgressContainer / ProgressLabel
@onready var int_progress_bar: = $PanelContainer / MainContainer / int / Progress / ProgressBar
@onready var code_speed: = $PanelContainer / MainContainer / CodeSpeed
@onready var var_bool: = $PanelContainer / MainContainer / bool / ResourceContainer / Resource
@onready var var_float: = $PanelContainer / MainContainer / float / ResourceContainer / Resource
@onready var var_char: = $PanelContainer / MainContainer / char / ResourceContainer / Resource
@onready var var_int: = $PanelContainer / MainContainer / int / ResourceContainer / Resource
@onready var audio_player: = $AudioStreamPlayer2D

var var_bool_progress: float
var var_float_progress: float
var var_char_progress: float
var var_int_progress: float

var var_bool_expanded: bool
var var_float_expanded: bool
var var_char_expanded: bool
var var_int_expanded: bool

var max_ratio: float
var var_bool_ratio: float
var var_float_ratio: float
var var_char_ratio: float
var var_int_ratio: float


func _ready() -> void :
    super ()

    $PanelContainer / MainContainer / bool / RatioContainer.visible = var_bool_expanded
    $PanelContainer / MainContainer / bool / RatioContainer / RatioSlider.value = var_bool_ratio
    $PanelContainer / MainContainer / float / RatioContainer.visible = var_float_expanded
    $PanelContainer / MainContainer / float / RatioContainer / RatioSlider.value = var_float_ratio
    $PanelContainer / MainContainer / char / RatioContainer.visible = var_char_expanded
    $PanelContainer / MainContainer / char / RatioContainer / RatioSlider.value = var_char_ratio
    $PanelContainer / MainContainer / int / RatioContainer.visible = var_int_expanded
    $PanelContainer / MainContainer / int / RatioContainer / RatioSlider.value = var_int_ratio

    update_ratios()


func _process(delta: float) -> void :
    super (delta)
    bool_progress_bar.value = lerpf(bool_progress_bar.value, var_bool_progress, 1.0 - exp(-50.0 * delta))
    bool_progress_label.text = Utils.print_metric(var_bool_progress, false) + "op"
    float_progress_bar.value = lerpf(float_progress_bar.value, var_float_progress, 1.0 - exp(-50.0 * delta))
    float_progress_label.text = Utils.print_metric(var_float_progress, false) + "op"
    char_progress_bar.value = lerpf(char_progress_bar.value, var_char_progress, 1.0 - exp(-50.0 * delta))
    char_progress_label.text = Utils.print_metric(var_char_progress, false) + "op"
    int_progress_bar.value = lerpf(int_progress_bar.value, var_int_progress, 1.0 - exp(-50.0 * delta))
    int_progress_label.text = Utils.print_metric(var_int_progress, false) + "op"


func process(delta: float) -> void :
    var_bool_progress += code_speed.count * (var_bool_ratio / max_ratio) * delta
    if var_bool_progress >= 1.0:
        var count: float = floorf(var_bool_progress)
        var_bool.add(count)
        Globals.stats.downloads += count
        var_bool_progress -= count
        audio_player.play()
        if is_processing():
            var_bool.animate_icon_in_pop(count)
    var_bool.production = code_speed.count * (var_bool_ratio / max_ratio)

    var_float_progress += code_speed.count * (var_float_ratio / max_ratio) * delta
    if var_float_progress >= 1.0:
        var count: float = floorf(var_float_progress)
        var_float.add(count)
        Globals.stats.downloads += count
        var_float_progress -= count
        audio_player.play()
        if is_processing():
            var_float.animate_icon_in_pop(count)
    var_float.production = code_speed.count * (var_float_ratio / max_ratio)

    var_char_progress += code_speed.count * (var_char_ratio / max_ratio) * delta
    if var_char_progress >= 1.0:
        var count: float = floorf(var_char_progress)
        var_char.add(count)
        Globals.stats.downloads += count
        var_char_progress -= count
        audio_player.play()
        if is_processing():
            var_char.animate_icon_in_pop(count)
    var_char.production = code_speed.count * (var_char_ratio / max_ratio)

    var_int_progress += code_speed.count * (var_int_ratio / max_ratio) * delta
    if var_int_progress >= 1.0:
        var count: float = floorf(var_int_progress)
        var_int.add(count)
        Globals.stats.downloads += count
        var_int_progress -= count
        audio_player.play()
        if is_processing():
            var_int.animate_icon_in_pop(count)
    var_int.production = code_speed.count * (var_int_ratio / max_ratio)


func update_ratios() -> void :
    max_ratio = max(var_bool_ratio + var_float_ratio + var_char_ratio + var_int_ratio, 1)

    $PanelContainer / MainContainer / bool / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((var_bool_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / float / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((var_float_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / char / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((var_char_ratio * 100) / max_ratio)
    $PanelContainer / MainContainer / int / RatioContainer / RatioLabelContainer / RatioLabel.text = "%.2f%%" % ((var_int_ratio * 100) / max_ratio)


func _on_var_bool_expand_button_pressed() -> void :
    var_bool_expanded = $PanelContainer / MainContainer / bool / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / bool / RatioContainer.visible = var_bool_expanded
    Sound.play("click_toggle")


func _on_var_float_expand_button_pressed() -> void :
    var_float_expanded = $PanelContainer / MainContainer / float / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / float / RatioContainer.visible = var_float_expanded
    Sound.play("click_toggle")


func _on_var_char_expand_button_pressed() -> void :
    var_char_expanded = $PanelContainer / MainContainer / char / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / char / RatioContainer.visible = var_char_expanded
    Sound.play("click_toggle")


func _on_var_int_expand_button_pressed() -> void :
    var_int_expanded = $PanelContainer / MainContainer / int / ResourceContainer / ExpandButton.button_pressed
    $PanelContainer / MainContainer / int / RatioContainer.visible = var_int_expanded
    Sound.play("click_toggle")


func _on_var_bool_ratio_slider_drag_ended(value_changed: bool) -> void :
    var_bool_ratio = $PanelContainer / MainContainer / bool / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_var_float_ratio_slider_drag_ended(value_changed: bool) -> void :
    var_float_ratio = $PanelContainer / MainContainer / float / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_var_char_ratio_slider_drag_ended(value_changed: bool) -> void :
    var_char_ratio = $PanelContainer / MainContainer / char / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func _on_var_int_ratio_slider_drag_ended(value_changed: bool) -> void :
    var_int_ratio = $PanelContainer / MainContainer / int / RatioContainer / RatioSlider.value
    update_ratios()
    Sound.play("click")


func save() -> Dictionary:
    return super ().merged({
        "var_bool_progress": var_bool_progress, 
        "var_float_progress": var_float_progress, 
        "var_char_progress": var_char_progress, 
        "var_int_progress": var_int_progress, 
        "var_bool_ratio": var_bool_ratio, 
        "var_float_ratio": var_float_ratio, 
        "var_char_ratio": var_char_ratio, 
        "var_int_ratio": var_int_ratio
    })
