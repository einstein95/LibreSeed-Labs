





















class_name Vungle
extends MobileSingletonPlugin

static  var _plugin: = _get_plugin("PoingGodotAdMobVungle")

enum Consent{
    OPTED_IN, 
    OPTED_OUT
}


static func update_consent_status(consent: Consent, consent_message_version: String) -> void :
    if _plugin:
        _plugin.update_consent_status(consent, consent_message_version)

static func update_ccpa_status(consent: Consent) -> void :
    if _plugin:
        _plugin.update_ccpa_status(consent)
