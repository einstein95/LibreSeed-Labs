extends WindowIndexed

@export var defense: int
@export var base_time: float = 10
@export var stat: String
@export_range(0.0, 1.0) var firewall_ratio: float = 0.5

@onready var firewall_label: = $PanelContainer / MainContainer / Firewall / ProgressContainer / Amount
@onready var firewall_bar: = $PanelContainer / MainContainer / Firewall / ProgressBar
@onready var breach_label: = $PanelContainer / MainContainer / Breached / ProgressContainer / Amount
@onready var breach_bar: = $PanelContainer / MainContainer / Breached / ProgressBar
@onready var time_label: = $PanelContainer / MainContainer / Time / ProgressContainer / Amount
@onready var time_bar: = $PanelContainer / MainContainer / Time / ProgressBar
@onready var breach_damage: = $PanelContainer / MainContainer / BreachDamage
@onready var infection_damage: = $PanelContainer / MainContainer / InfectionDamage
@onready var vulnerability: = $PanelContainer / MainContainer / Vulnerability

var firewall: float
var max_firewall: float
var breached: float
var max_breach: float
var time: float
var max_time: float
var max_firewall_str: String
var max_breach_str: String
var detected: bool


func _ready() -> void :
    super ()
    Signals.new_unlock.connect(_on_new_unlock)

    update_goal()
    update_visible_damages()
    if time <= 0:
        reset()


func _process(delta: float) -> void :
    super (delta)
    firewall_bar.value = lerpf(firewall_bar.value, firewall / max_firewall, 1.0 - exp(-50.0 * delta))
    firewall_label.text = Utils.print_string(firewall, true) + "/" + max_firewall_str
    breach_bar.value = lerpf(breach_bar.value, breached / max_breach, 1.0 - exp(-50.0 * delta))
    breach_label.text = Utils.print_string(breached, true) + "/" + max_breach_str
    time_bar.value = lerpf(time_bar.value, time, 1.0 - exp(-50.0 * delta))
    time_label.text = "%.0fs" % time


func process(delta: float) -> void :
    if breach_damage.count > 0 or infection_damage.count > 0:
        var p_damage: float = breach_damage.pop_all()
        var i_damage: float = infection_damage.count * delta

        p_damage *= (1.0 + vulnerability.count)
        i_damage *= (1.0 + vulnerability.count)

        if p_damage > 0 and !breach_damage.variation & Utils.damage_variation.STEALTH:
            p_damage -= damage_firewall(p_damage)
        if i_damage > 0 and !infection_damage.variation & Utils.damage_variation.STEALTH:
            i_damage -= damage_firewall(i_damage)

        var damage: float = p_damage + i_damage
        var damage_dealt: float = damage(damage)
        detected = true

    if breached >= max_breach:
        breach()
    elif detected:
        time -= delta
        if time <= 0:
            fail()


func damage(amount: float) -> float:
    var delta: float = min(max_breach, amount)
    breached += delta
    return delta


func damage_firewall(amount: float) -> float:
    var delta: float = min(firewall, amount)
    firewall -= delta

    return delta


func breach() -> void :
    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(1, 2, 1), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    if data.level >= data.max_level:
        data.max_level = data.level + 1

    Globals.stats[stat] += 1
    Signals.breached.emit(self)
    reset()


func fail() -> void :
    reset()

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(2, 1, 1), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)


func level_up(times: int) -> void :
    data.level = min(data.level + times, data.max_level)

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(1, 2, 1), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.25)



    reset()


func level_down(times: int) -> void :
    data.level = max(data.level - times, 0)

    var tween: Tween = create_tween()
    tween.tween_property(self, "modulate", Color(2, 1, 1), 0.2)
    tween.tween_property(self, "modulate", Color(1, 1, 1), 0.25)

    tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.2)
    tween.tween_property(self, "scale", Vector2(1, 1), 0.25)



    reset()


func reset() -> void :
    update_goal()
    breached = 0
    firewall = max_firewall
    time = max_time
    infection_damage.count = 0
    detected = false


func update_goal() -> void :
    var total: float = floorf(40.0 * (2 ** (float(get_level() + defense))) * Attributes.get_attribute("breach_layers_multiplier") * Attributes.get_window_attribute(window, "layers_multiplier"))
    max_breach = total * (1.0 - firewall_ratio)
    max_firewall = total * firewall_ratio
    max_time = base_time * Attributes.get_attribute("breach_time_multiplier") * Attributes.get_window_attribute(window, "time_multiplier")
    time_bar.max_value = max_time
    max_breach_str = Utils.print_string(max_breach, true)
    max_firewall_str = Utils.print_string(max_firewall, true)

    $PanelContainer / MainContainer / Level / Info / Count.text = tr("level") + " %0.f" % data.level + "/%.0f" % (data.max_level)


func update_visible_damages() -> void :
    $PanelContainer / MainContainer / InfectionDamage.visible = Globals.unlocks["research.infection_damage"]
    $PanelContainer / MainContainer / Vulnerability.visible = Globals.unlocks["research.injection"]


func get_level() -> int:
    return data.level


func _on_new_unlock(unlock: String) -> void :
    update_visible_damages()


func save() -> Dictionary:
    return super ().merged({
        "breached": breached, 
        "firewall": firewall, 
        "time": time, 
        "detected": detected
    })
