extends PanelContainer

const icons: Array[String] = ["blueprint", "globe", "processor", "research", "hacker", "code", "brain"]

var data: Dictionary
var icon_index: int


func _ready() -> void:
    Signals.save_schematic.connect(_on_save_schematic)

    for i: Button in $PortalContainer/MainPanel/InfoContainer/IconsContainer.get_children():
        i.pressed.connect(_on_icon_button_pressed.bind(i.get_index()))


func _process(delta: float) -> void:
    if Globals.is_mobile():
        offset_bottom = 119 - DisplayServer.virtual_keyboard_get_height()


func set_icon(icon: int) -> void:
    icon_index = icon
    for i: Button in $PortalContainer/MainPanel/InfoContainer/IconsContainer.get_children():
        i.button_pressed = i.get_index() == icon_index


func _on_save_pressed() -> void:
    data["icon"] = icons[icon_index]

    var schem_name: String = $PortalContainer/MainPanel/InfoContainer/Label.text
    Data.save_schematic(schem_name, data)
    $PortalContainer/MainPanel/InfoContainer/Label.text = ""
    set_icon(0)

    Signals.popup.emit("")
    Sound.play("click2")


func _on_cancel_pressed() -> void:
    $PortalContainer/MainPanel/InfoContainer/Label.text = ""
    set_icon(0)

    Signals.popup.emit("")
    Sound.play("close")


func _on_icon_button_pressed(index: int) -> void:
    set_icon(index)
    Sound.play("click_toggle2")


func _on_save_schematic(schematic: Dictionary) -> void:
    Signals.popup.emit("AddSchematic")
    data = schematic
