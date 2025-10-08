





















class_name InterstitialAd
extends MobileSingletonPlugin

static  var _plugin = _get_plugin("PoingGodotAdMobInterstitialAd")
var full_screen_content_callback: = FullScreenContentCallback.new()

var _uid: int

func _init(uid: int):
    self._uid = uid
    register_callbacks()

func show() -> void :
    if _plugin:
        _plugin.show(_uid)

func destroy() -> void :
    if _plugin:
        _plugin.destroy(_uid)

func register_callbacks() -> void :
    if _plugin:
        _plugin.connect("on_interstitial_ad_clicked", _on_interstitial_ad_clicked)
        _plugin.connect("on_interstitial_ad_dismissed_full_screen_content", _on_interstitial_ad_dismissed_full_screen_content)
        _plugin.connect("on_interstitial_ad_failed_to_show_full_screen_content", _on_interstitial_ad_failed_to_show_full_screen_content)
        _plugin.connect("on_interstitial_ad_impression", _on_interstitial_ad_impression)
        _plugin.connect("on_interstitial_ad_showed_full_screen_content", _on_interstitial_ad_showed_full_screen_content)

func _on_interstitial_ad_clicked(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_clicked.call_deferred()

func _on_interstitial_ad_dismissed_full_screen_content(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_dismissed_full_screen_content.call_deferred()

func _on_interstitial_ad_failed_to_show_full_screen_content(uid: int, ad_error_dictionary: Dictionary) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_failed_to_show_full_screen_content.call_deferred(AdError.create(ad_error_dictionary))

func _on_interstitial_ad_impression(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_impression.call_deferred()

func _on_interstitial_ad_showed_full_screen_content(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_showed_full_screen_content.call_deferred()
