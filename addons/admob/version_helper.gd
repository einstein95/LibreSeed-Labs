





















class_name PoingAdMobVersionHelper
extends Object

static  var version_formated: String = _get_plugin_version_formated():
    set(value):
        version_formated = _get_plugin_version_formated()

static func get_plugin_version() -> String:
    var plugin_config_file: = ConfigFile.new()
    var version: String = "v3.1.2"

    if plugin_config_file.load("res://addons/admob/plugin.cfg") == OK:
        version = plugin_config_file.get_value("plugin", "version")
    else:
        push_error("Failed to load plugin.cfg")
    return version

static func _get_plugin_version_formated() -> String:
    var version: = get_plugin_version()

    var pattern = RegEx.new()
    pattern.compile("(?:v)?(\\d+\\.\\d+\\.\\d+)")

    var matchs: = pattern.search(version)
    if matchs != null:
        version = matchs.get_string(1)
    return version
