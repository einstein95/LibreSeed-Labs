class_name AudioPlayer extends AudioStreamPlayer


func _init(sound: String, gain: float = 0.0, pitch: float = 1.0) -> void :
    stream = Resources.sounds[sound + ".wav"]
    pitch_scale = pitch
    volume_db += gain
    bus = "SFX"
    autoplay = true


func _ready() -> void :
    finished.connect( func() -> void : queue_free())
