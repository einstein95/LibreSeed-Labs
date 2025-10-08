





















class_name ConsentForm
extends MobileSingletonPlugin

static  var _plugin: = _get_plugin("PoingGodotAdMobUserMessagingPlatform")

var _uid: int

func _init(UID: int):
    self._uid = UID

var _on_consent_form_dismissed_callback

func show(on_consent_form_dismissed: = func(form_error: FormError): pass) -> void :
    if _plugin:
        self._on_consent_form_dismissed_callback = on_consent_form_dismissed
        _plugin.show(_uid)
        _plugin.connect("on_consent_form_dismissed", _on_consent_form_dismissed)

func _on_consent_form_dismissed(uid: int, form_error_dictionary: Dictionary) -> void :
    if uid == _uid:
        var formError: FormError = FormError.create(form_error_dictionary) if not form_error_dictionary.is_empty() else null
        _on_consent_form_dismissed_callback.call_deferred(formError)
