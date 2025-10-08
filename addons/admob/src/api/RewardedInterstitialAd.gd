





















class_name RewardedInterstitialAd
extends MobileSingletonPlugin

static  var _plugin = _get_plugin("PoingGodotAdMobRewardedInterstitialAd")
var full_screen_content_callback: = FullScreenContentCallback.new()

var _uid: int

func _init(uid: int):
    self._uid = uid
    register_callbacks()

var _on_user_earned_reward_listener: OnUserEarnedRewardListener

func show(on_user_earned_reward_listener: = OnUserEarnedRewardListener.new()) -> void :
    if _plugin:
        self._on_user_earned_reward_listener = on_user_earned_reward_listener
        _plugin.show(_uid)
        _plugin.connect("on_rewarded_interstitial_ad_user_earned_reward", _on_rewarded_interstitial_ad_user_earned_reward)

func destroy() -> void :
    if _plugin:
        _plugin.destroy(_uid)

func set_server_side_verification_options(server_side_verification_options: ServerSideVerificationOptions):
    if _plugin:
        _plugin.set_server_side_verification_options(_uid, server_side_verification_options.convert_to_dictionary())

func register_callbacks() -> void :
    if _plugin:
        _plugin.connect("on_rewarded_interstitial_ad_clicked", _on_rewarded_interstitial_ad_clicked)
        _plugin.connect("on_rewarded_interstitial_ad_dismissed_full_screen_content", _on_rewarded_interstitial_ad_dismissed_full_screen_content)
        _plugin.connect("on_rewarded_interstitial_ad_failed_to_show_full_screen_content", _on_rewarded_interstitial_ad_failed_to_show_full_screen_content)
        _plugin.connect("on_rewarded_interstitial_ad_impression", _on_rewarded_interstitial_ad_impression)
        _plugin.connect("on_rewarded_interstitial_ad_showed_full_screen_content", _on_rewarded_interstitial_ad_showed_full_screen_content)

func _on_rewarded_interstitial_ad_user_earned_reward(uid: int, rewarded_item_dictionary: Dictionary) -> void :
    if uid == _uid:
        _on_user_earned_reward_listener.on_user_earned_reward.call_deferred(RewardedItem.create(rewarded_item_dictionary))

func _on_rewarded_interstitial_ad_clicked(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_clicked.call_deferred()

func _on_rewarded_interstitial_ad_dismissed_full_screen_content(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_dismissed_full_screen_content.call_deferred()

func _on_rewarded_interstitial_ad_failed_to_show_full_screen_content(uid: int, ad_error_dictionary: Dictionary) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_failed_to_show_full_screen_content.call_deferred(AdError.create(ad_error_dictionary))

func _on_rewarded_interstitial_ad_impression(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_impression.call_deferred()

func _on_rewarded_interstitial_ad_showed_full_screen_content(uid: int) -> void :
    if uid == _uid:
        full_screen_content_callback.on_ad_showed_full_screen_content.call_deferred()
