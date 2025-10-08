





















class_name MobileAds
extends MobileSingletonPlugin

static  var _plugin: = _get_plugin("PoingGodotAdMob")

static  var _current_on_initialization_complete_listener: OnInitializationCompleteListener = null

static func initialize(on_initialization_complete_listener: OnInitializationCompleteListener = null) -> void :
    if _plugin:
        _plugin.initialize()

        if on_initialization_complete_listener:
            _current_on_initialization_complete_listener = on_initialization_complete_listener
            _plugin.connect("on_initialization_complete", _on_initialization_complete, CONNECT_ONE_SHOT)

static func set_request_configuration(request_configuration: RequestConfiguration) -> void :
    if _plugin:

        _plugin.set_request_configuration(request_configuration.convert_to_dictionary(), request_configuration.test_device_ids)

static func get_initialization_status() -> InitializationStatus:
    if _plugin:
        var initialization_status_dictionary: Dictionary = _plugin.get_initialization_status()
        return InitializationStatus.create(initialization_status_dictionary)
    return null

static func set_ios_app_pause_on_background(pause: bool) -> void :
    if _plugin and OS.get_name() == "iOS":
        _plugin.set_ios_app_pause_on_background(pause)

static func _on_initialization_complete(admob_initialization_status: Dictionary) -> void :
    var initialization_status: = InitializationStatus.create(admob_initialization_status)
    _current_on_initialization_complete_listener.on_initialization_complete.call_deferred(initialization_status)
