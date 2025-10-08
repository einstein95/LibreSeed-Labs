





















class_name UserMessagingPlatform
extends MobileSingletonPlugin

static  var _plugin: = _get_plugin("PoingGodotAdMobUserMessagingPlatform")

static  var consent_information: = ConsentInformation.new()

static  var _on_consent_form_load_success_listener_callback
static  var _on_consent_form_load_failure_listener_callback

static func load_consent_form(
        on_consent_form_load_success_listener: = func(consent_form: ConsentForm): pass, 
        on_consent_form_load_failure_listener: = func(form_error: FormError): pass) -> void :
    if _plugin:
        _on_consent_form_load_success_listener_callback = on_consent_form_load_success_listener
        _on_consent_form_load_failure_listener_callback = on_consent_form_load_failure_listener
        _plugin.load_consent_form()
        _plugin.connect("on_consent_form_load_success_listener", _on_consent_form_load_success_listener, CONNECT_ONE_SHOT)
        _plugin.connect("on_consent_form_load_failure_listener", _on_consent_form_load_failure_listener, CONNECT_ONE_SHOT)

static func _on_consent_form_load_success_listener(UID: int) -> void :
    _on_consent_form_load_success_listener_callback.call_deferred(ConsentForm.new(UID))

static func _on_consent_form_load_failure_listener(form_error_dictionary: Dictionary) -> void :
    _on_consent_form_load_failure_listener_callback.call_deferred(FormError.create(form_error_dictionary))
