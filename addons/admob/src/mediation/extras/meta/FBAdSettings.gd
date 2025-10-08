





















class_name FBAdSettings
extends MobileSingletonPlugin

static  var _plugin: = _get_plugin("PoingGodotAdMobMetaFBAdSettings") if OS.get_name() == "iOS" else null

static func set_advertiser_tracking_enabled(tracking_required: bool) -> void :
    if _plugin:
        _plugin.set_advertiser_tracking_enabled(tracking_required)
