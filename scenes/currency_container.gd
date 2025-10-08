extends PanelContainer

@onready var amount_label: = $Container / Amount
@onready var production_label: = $Container / Production
var cur_amount: float


func _ready() -> void :
    Signals.new_level.connect(_on_new_level)
    Signals.new_unlock.connect(_on_new_unlock)
    Signals.currency_popup.connect(_on_currency_popup)
    Signals.currency_popup_particle.connect(_on_currency_popup_particle)

    $Container / Icon.texture = load("res://textures/icons/" + Data.currencies[name].icon + ".png")
    $Container / Production.visible = Data.currencies[name].production

    modulate.a = 0
    visible = get_visibility()


func _process(delta: float) -> void :
    var amount: float = cur_amount + (Globals.currencies[name] - cur_amount) * (1.0 - exp(-3 * delta))
    if Data.currencies[name].metric:
        amount_label.text = Utils.print_metric(roundf(amount), true)
        production_label.text = Utils.print_metric(Globals.currency_production[name], false) + "/s"
    else:
        amount_label.text = Utils.print_string(roundf(amount), true)
        production_label.text = Utils.print_string(Globals.currency_production[name], false) + "/s"
    cur_amount = amount


func get_visibility() -> bool:
    if Globals.money_level < Data.currencies[name].level: return false
    if !Data.currencies[name].requirement.is_empty() and !Globals.unlocks[Data.currencies[name].requirement]: return false

    return true


func _on_visibility_changed() -> void :
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate:a", 1, 1)


func _on_new_level() -> void :
    visible = get_visibility()


func _on_new_unlock(unlock: String) -> void :
    visible = get_visibility()


func _on_currency_popup(currency: String, amount: float) -> void :
    if currency == name:
        $Popup.position.x = size.x + 16
        $Popup / Label.text = "+" + Utils.print_string(amount, true)
        $AnimationPlayer.play("popup")
        $AnimationPlayer.seek(0, true)


func _on_currency_popup_particle(currency: String, pos: Vector2) -> void :
    if currency == name:
        var particle: GPUParticles2D = load("res://particles/following_token.tscn").instantiate()
        particle.starting_pos = pos
        particle.target = $Container / Icon
        Signals.spawn_ui_particle.emit(particle, pos)
