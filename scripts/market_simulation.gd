extends Node

@export var max_value: float = 1.0

var current_value: float
var base_volatility: float = 0.1
var trend_strength: float
var trend_duration: int
var crash_severity: float

var value_history: Array[float]
var max_history_size: int = 50
var ticks: int = 40


func _ready() -> void:
    Signals.tick.connect(_on_tick)

    value_history.append(current_value)


func tick(delta: float) -> void:
    if ticks <= 0:
        ticks = 40
        var random_change: float = randf_range(-base_volatility, base_volatility)

        if trend_duration > 0:
            random_change += trend_strength
            trend_duration -= 1
            if trend_duration <= 0:
                trend_strength = 0.0
        else:
            if randf() < 0.2:
                start_new_trend()

        var mean_reversion: float = - current_value * 0.05
        var momentum: float = calculate_momentum()
        var total_change: float = random_change + mean_reversion + momentum

        crash_severity = maxf(crash_severity - 0.05, 0)
        current_value += total_change

        current_value = clamp(current_value * (1.0 - crash_severity), 1 / max_value, max_value)

        value_history.append(current_value)
        if value_history.size() > max_history_size:
            value_history.pop_front()
    else:
        ticks -= 1


func start_new_trend() -> void:
    trend_strength = randf_range(-0.25, 0.5)
    trend_duration = randi_range(3, 8)


func calculate_momentum() -> float:
    if value_history.size() < 5:
        return 0.0

    var recent_change: float = current_value - value_history[-5]
    return recent_change * 0.1


func crash_market(severity: float = 1.0) -> void:
    crash_severity = clamp(severity, 0.1, 1.0)


func _on_tick() -> void:
    tick(0.05)
