extends Node

var icons: Dictionary
var sounds: Dictionary

func _ready() -> void:
    load_all()


func load_all() -> void:
    load_icons()
    load_sounds()


func load_icons() -> void:
    for i: String in ResourceLoader.list_directory("res://textures/icons"):
        icons[i] = load("res://textures/icons/" + i)


func load_sounds() -> void:
    for i: String in ResourceLoader.list_directory("res://audio/sfx"):
        sounds[i] = load("res://audio/sfx/" + i)
