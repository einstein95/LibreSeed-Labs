extends Node


func _ready() -> void :
    process_mode = Node.PROCESS_MODE_ALWAYS


func play(sound: String, gain: float = 0.0, pitch: float = 1.0) -> void :
    var stream: AudioPlayer = AudioPlayer.new(sound, gain, pitch)
    add_child(stream)


func click() -> void :
    play("click")
