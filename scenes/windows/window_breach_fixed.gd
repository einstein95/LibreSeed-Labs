extends "res://scenes/windows/window_breach.gd"

@export var reward_stat: String

@onready var result := $PanelContainer/MainContainer/Result
@onready var success_audio := $SuccessAudioStream
@onready var fail_audio := $FailAudioStream

var base_reward: float


func update_goal() -> void:
    super ()
    base_reward = pow(2, data.level) * Attributes.get_attribute("breach_reward_multiplier") * Attributes.get_window_attribute(window, "reward_multiplier")
    $ActionContainer/AddButton.disabled = data.level >= data.max_level
    $ActionContainer/ReduceButton.disabled = data.level <= 0


func reward(times: float) -> void:
    var reward: float = base_reward * times
    result.add(reward)
    result.animate_icon_in_pop(reward)
    Globals.stats[reward_stat] += reward


func fail() -> void:
    super ()
    fail_audio.play()


func breach() -> void:
    reward(base_reward)
    super ()
    success_audio.play()


func _on_reduce_button_pressed() -> void:
    level_down(1)
    fail_audio.play()
    Sound.play("click_toggle")


func _on_add_button_pressed() -> void:
    level_up(1)
    success_audio.play()
    Sound.play("click_toggle")
