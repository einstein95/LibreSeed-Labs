class_name WindowsWaiter extends Node

signal initialized

var init_count: int


func _init(windows: Array[WindowContainer]) -> void:
    init_count = windows.size()
    for window: WindowContainer in windows:
        window.initialized.connect(func() -> void: init_count -= 1; if init_count <= 0: initialized.emit())
