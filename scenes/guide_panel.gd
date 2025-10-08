extends VBoxContainer

var open: bool


func _ready() -> void :
    Signals.new_level.connect(_on_new_level)

    if open: expand()

    update_visibility()


func update_all() -> void :
    $GuideButton / Icon.texture = load("res://textures/icons/" + Data.guides[name].icon + ".png")
    $GuideButton / Name.text = tr(Data.guides[name].name)

    if open:
        $PanelContainer / Label.text = ""
        for i: Dictionary in Data.guides[name].entries:
            if Globals.money_level < i.level: continue
            var parsened_text: String = tr(i.text)
            parsened_text = parsened_text.replace("[h]", "[font_size=40][color=ff8500]")
            parsened_text = parsened_text.replace("[/h]", "[/color][/font_size]")
            parsened_text = parsened_text.replace("[l]", "[color=ffaf59]")
            parsened_text = parsened_text.replace("[/l]", "[/color]")
            parsened_text += "\n"
            $PanelContainer / Label.append_text(parsened_text)

    if open:
        $GuideButton / TextureRect.texture = load("res://textures/icons/chevron_up.png")
    else:
        $GuideButton / TextureRect.texture = load("res://textures/icons/chevron_down.png")


func update_visibility() -> void :
    visible = false
    for i: Dictionary in Data.guides[name].entries:
        if Globals.money_level < i.level: continue
        if !i.requirement.is_empty() and !Globals.unlocks[i.requirement]: continue

        visible = true


func expand() -> void :
    open = true
    update_all()
    $PanelContainer.visible = true
    $GuideButton.button_pressed = true


func close() -> void :
    open = false
    update_all()
    $PanelContainer.visible = false
    $GuideButton.button_pressed = false


func _on_guide_button_pressed() -> void :
    if open:
        close()
    else:
        expand()
    Sound.play("click_toggle")


func _on_visibility_changed() -> void :
    update_all()


func _on_label_meta_clicked(meta: Variant) -> void :
    Signals.open_guide.emit(meta)
    Sound.play("click_toggle")


func _on_new_level() -> void :
    update_visibility()
