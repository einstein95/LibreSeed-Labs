extends WindowIndexed

@onready var boost: = $PanelContainer / MainContainer / Boost
@onready var download_speed: = $PanelContainer / MainContainer / Download
@onready var upload_speed: = $PanelContainer / MainContainer / Upload
@onready var overclock: = $PanelContainer / MainContainer / Overclock
@onready var heat: = $PanelContainer / MainContainer / Heat
@onready var heat_bar: = $PanelContainer / MainContainer / HeatProgressBar
@onready var upgrade_button: = $UpgradeButton

var level: int
var maxed: bool
var cost: float
var speed: float


func _ready() -> void :
    super ()
    Signals.connection_set.connect(_on_connection_set)
    Signals.tutorial_step.connect(_on_tutorial_step)
    Signals.new_unlock.connect(_on_new_unlock)
    Attributes.attributes["price_multiplier"].changed.connect(_on_attribute_changed)

    update_all()
    update_tutorial()


func _process(delta: float) -> void :
    super (delta)
    upgrade_button.disabled = !can_upgrade()
    heat_bar.value = heat.count


func process(delta: float) -> void :
    var overclock_bonus: float = (1.0 + overclock.count)
    if heat.count >= 100:
        overclock_bonus = 1.0
    var multiplier: float = speed * (1.0 + boost.count) * overclock_bonus * Attributes.get_attribute("bandwidth_multiplier")
    download_speed.count = multiplier * Attributes.get_attribute("download_speed_multiplier")
    upload_speed.count = multiplier * Attributes.get_attribute("upload_speed_multiplier")
    heat.count = ((overclock.count + 1) ** 2) * 50


func update_all() -> void :
    maxed = level >= 200

    speed = roundf(8 * pow(1.414, level))
    cost = 160 * pow(2, level) * Attributes.get_attribute("price_multiplier")

    boost.visible = Globals.unlocks["research.trojan"]
    overclock.visible = Globals.unlocks["research.overclocking"]
    heat.visible = Globals.unlocks["research.overclocking"]
    heat_bar.visible = Globals.unlocks["research.overclocking"]

    set_window_name(get_window_name())
    $UpgradeButton / UpgradeContainer / CostContainer / Label.text = Utils.print_string(cost, true)

    $UpgradeButton.visible = !maxed

    if !maxed:
        $PanelContainer.theme_type_variation = "WindowPanelContainerFlatBottom"
    else:
        $PanelContainer.theme_type_variation = "WindowPanelContainer"


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.DRAG_DOWNLOAD_CONNECTOR:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / Download / OutputConnector)
    elif Globals.tutorial_step == Utils.tutorial_steps.DRAG_UPLOAD_CONNECTOR:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / Upload / OutputConnector)

    if Globals.tutorial_done:
        can_select = true
        can_drag = true
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
    else:
        can_select = false
        can_drag = false
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

    var downloads_steps: Array[int] = [Utils.tutorial_steps.DRAG_DOWNLOAD_CONNECTOR, Utils.tutorial_steps.CONNECT_DOWNLOADER]
    var upload_steps: Array[int] = [Utils.tutorial_steps.DRAG_UPLOAD_CONNECTOR, Utils.tutorial_steps.CONNECT_UPLOADER]
    $PanelContainer / MainContainer / Download / OutputConnector.disabled = !Globals.tutorial_done and !downloads_steps.has(Globals.tutorial_step)
    $PanelContainer / MainContainer / Upload / OutputConnector.disabled = !Globals.tutorial_done and !upload_steps.has(Globals.tutorial_step)


func can_upgrade() -> bool:
    if cost > Globals.currencies["money"]: return false

    return !maxed


func upgrade(levels: int) -> void :
    level += levels

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(2, 2, 2), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    $TitlePanel / TitleContainer / Title.visible_ratio = 0
    tween = create_tween()
    tween.tween_property($TitlePanel / TitleContainer / Title, "visible_ratio", 1, 0.25)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.25)

    var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
    Signals.spawn_particle.emit(particle, global_position + size / 2)

    update_all()


func get_window_name() -> String:
    return super () + " " + tr("mk.") + str(level)


func _on_upgrade_button_pressed() -> void :
    if can_upgrade():
        Globals.currencies["money"] -= cost
        upgrade(1)
        Sound.play("upgrade")
    Sound.play("click_toggle")


func _on_connection_set() -> void :
    if Globals.connection_type == 1:
        if Globals.tutorial_step == Utils.tutorial_steps.DRAG_DOWNLOAD_CONNECTOR:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_DOWNLOAD_CONNECTOR + 1)
        elif Globals.tutorial_step == Utils.tutorial_steps.DRAG_UPLOAD_CONNECTOR:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_UPLOAD_CONNECTOR + 1)
    elif Globals.connection_type == 0:
        if Globals.tutorial_step == Utils.tutorial_steps.CONNECT_DOWNLOADER:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_DOWNLOAD_CONNECTOR)
        elif Globals.tutorial_step == Utils.tutorial_steps.CONNECT_UPLOADER:
            Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_UPLOAD_CONNECTOR)


func _on_new_unlock(unlock: String) -> void :
    update_all()


func _on_attribute_changed() -> void :
    update_all()


func _on_tutorial_step() -> void :
    update_tutorial()


func save() -> Dictionary:
    return super ().merged({
        "level": level
    })
