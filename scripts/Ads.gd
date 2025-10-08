extends Node

signal ad_shown

var _rewarded_ad: RewardedAd
var _full_screen_content_callback: = FullScreenContentCallback.new()
var on_user_earned_reward_listener: = OnUserEarnedRewardListener.new()
var _consent_form: ConsentForm


func _ready() -> void :
	var request: = ConsentRequestParameters.new()
	request.tag_for_under_age_of_consent = false
	UserMessagingPlatform.consent_information.update(request, _on_consent_info_updated_success, _on_consent_info_updated_failure)

	MobileAds.initialize()

	_full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void :
		load_ad()
	_full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(ad_error: AdError) -> void :
		load_ad()
	_full_screen_content_callback.on_ad_impression = func() -> void :
		print("on_ad_impression")
	_full_screen_content_callback.on_ad_showed_full_screen_content = func() -> void :
		print("on_ad_showed_full_screen_content")
	on_user_earned_reward_listener.on_user_earned_reward = func(rewarded_item: RewardedItem) -> void :
		reward()

	get_tree().create_timer(10).timeout.connect( func() -> void : load_ad())


func load_ad() -> void :
	if _rewarded_ad:
		_rewarded_ad.destroy()
		_rewarded_ad = null

	var unit_id: String
	if OS.get_name() == "Android":
		unit_id = "ca-app-pub-3330675275727576/4417211986"
	elif OS.get_name() == "iOS":
		unit_id = "ca-app-pub-3330675275727576/2627131901"

	var rewarded_ad_load_callback: = RewardedAdLoadCallback.new()
	rewarded_ad_load_callback.on_ad_failed_to_load = func(adError: LoadAdError) -> void :
		print(adError.message)
		get_tree().create_timer(10).timeout.connect( func() -> void : load_ad())

	rewarded_ad_load_callback.on_ad_loaded = func(rewarded_ad: RewardedAd) -> void :
		print("rewarded ad loaded" + str(rewarded_ad._uid))
		rewarded_ad.full_screen_content_callback = _full_screen_content_callback
		_rewarded_ad = rewarded_ad

	RewardedAdLoader.new().load(unit_id, AdRequest.new(), rewarded_ad_load_callback)


func show_ad() -> void :
	if _rewarded_ad:
		ad_shown.emit()
		_rewarded_ad.show(on_user_earned_reward_listener)


func reward() -> void :
	Globals.currencies["token"] += 50


func _on_consent_info_updated_success():
	if UserMessagingPlatform.consent_information.get_is_consent_form_available():
		load_form()


func _on_consent_info_updated_failure(form_error: FormError):
	print(form_error.message)


func load_form():
	UserMessagingPlatform.load_consent_form(_on_consent_form_load_success, _on_consent_form_load_failure)


func _on_consent_form_load_success(consent_form: ConsentForm):
	_consent_form = consent_form
	if UserMessagingPlatform.consent_information.get_consent_status() == UserMessagingPlatform.consent_information.ConsentStatus.REQUIRED:
		consent_form.show(_on_consent_form_dismissed)


func _on_consent_form_load_failure(form_error: FormError):
	print(form_error.message)


func _on_consent_form_dismissed(form_error: FormError):
	if UserMessagingPlatform.consent_information.get_consent_status() == UserMessagingPlatform.consent_information.ConsentStatus.OBTAINED:
		pass
	load_form()
