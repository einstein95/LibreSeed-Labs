extends Timer

@export var min_start_time: float
@export var max_start_time: float
@export var repeat_time: float


func _ready() -> void :
    timeout.connect(_on_timeout)

    if can_start():
        begin_timer()


func begin_timer() -> void :
    start(min_start_time + randf() * max_start_time)


func can_start() -> bool:
    return true


func _on_timeout() -> void :
    start(repeat_time)
