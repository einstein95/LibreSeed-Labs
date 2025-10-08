





















class_name RewardedAdLoader
extends MobileSingletonPlugin

static  var _plugin = _get_plugin("PoingGodotAdMobRewardedAd")

var rewarded_ad_load_callback: RewardedAdLoadCallback
var _uid: int

func _init():
    if _plugin:
        _uid = _plugin.create()

func load(
    ad_unit_id: String, 
    ad_request: AdRequest, 
    rewarded_ad_load_callback: = RewardedAdLoadCallback.new()) -> void :

    if _plugin:
        self.rewarded_ad_load_callback = rewarded_ad_load_callback
        _plugin.connect("on_rewarded_ad_loaded", _on_rewarded_ad_loaded, CONNECT_DEFERRED)
        _plugin.connect("on_rewarded_ad_failed_to_load", _on_rewarded_ad_failed_to_load, CONNECT_DEFERRED)
        reference()
        _plugin.load(ad_unit_id, ad_request.convert_to_dictionary(), ad_request.keywords, _uid)

func _on_rewarded_ad_loaded(uid: int) -> void :
    if uid == _uid:
        rewarded_ad_load_callback.on_ad_loaded.call(RewardedAd.new(uid))
        unreference.call_deferred()

func _on_rewarded_ad_failed_to_load(uid: int, load_ad_error_dictionary: Dictionary) -> void :
    if uid == _uid:
        rewarded_ad_load_callback.on_ad_failed_to_load.call(LoadAdError.create(load_ad_error_dictionary))
        unreference.call_deferred()
