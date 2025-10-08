extends HBoxContainer

var window: String
var required: int


func _ready() -> void :
    if Data.windows.has(window):
        $Icon.texture = load("res://textures/icons/" + Data.windows[window].icon + ".png")
        $Name.text = Data.windows[window].name
    else:
        $Icon.texture = load("res://textures/icons/question_mark.png")
        $Name.text = "invalid_window"


func _on_visibility_changed() -> void :
    if Data.windows.has(window):
        if Attributes.get_window_attribute(window, "limit") >= 0:
            $Progress.text = "%d/%d" % [Attributes.get_window_attribute(window, "limit") - Globals.window_count[window], required]
        else:
            $Progress.text = "%d" % [required]
    else:
        $Progress.text = "?/%d" % required
