





















class_name AdSize
extends MobileSingletonPlugin

static  var _plugin: = _get_plugin("PoingGodotAdMobAdSize")

const FULL_WIDTH: = -1

static  var BANNER: = new(320, 50)
static  var FULL_BANNER: = new(468, 60)
static  var LARGE_BANNER: = new(320, 100)
static  var LEADERBOARD: = new(728, 90)
static  var MEDIUM_RECTANGLE: = new(300, 250)
static  var WIDE_SKYSCRAPER: = new(160, 600)

var width: int
var height: int

func _init(width: int, height: int):
    self.width = width
    self.height = height

static func get_smart_banner_ad_size() -> AdSize:
    if _plugin:
        var ad_size_dictionary: Dictionary = _plugin.getSmartBannerAdSize()
        return _create(ad_size_dictionary)
    return AdSize.new(0, 0)

static func get_current_orientation_anchored_adaptive_banner_ad_size(width: int) -> AdSize:
    if _plugin:
        var ad_size_dictionary: Dictionary = _plugin.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width)
        return _create(ad_size_dictionary)
    return AdSize.new(0, 0)

static func get_portrait_anchored_adaptive_banner_ad_size(width: int) -> AdSize:
    if _plugin:
        var ad_size_dictionary: Dictionary = _plugin.getPortraitAnchoredAdaptiveBannerAdSize(width)
        return _create(ad_size_dictionary)
    return AdSize.new(0, 0)

static func get_landscape_anchored_adaptive_banner_ad_size(width: int) -> AdSize:
    if _plugin:
        var ad_size_dictionary: Dictionary = _plugin.getLandscapeAnchoredAdaptiveBannerAdSize(width)
        return _create(ad_size_dictionary)
    return AdSize.new(0, 0)


static func _create(ad_size_dictionary: Dictionary) -> AdSize:
    var width = ad_size_dictionary["width"]
    var height = ad_size_dictionary["height"]
    return AdSize.new(width, height)
