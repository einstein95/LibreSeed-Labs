





















class_name MobileSingletonPlugin

static func _get_plugin(plugin_name: String) -> Object:
    if (Engine.has_singleton(plugin_name)):
        return Engine.get_singleton(plugin_name)

    if OS.get_name() == "Android" or OS.get_name() == "iOS":
        printerr(plugin_name + " not found, make sure you marked all \'PoingAdMob\' plugins on export tab")

    return null
