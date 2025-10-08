





















class_name AdView
extends MobileSingletonPlugin

static  var _plugin: = _get_plugin("PoingGodotAdMobAdView")

var ad_listener: = AdListener.new()
var _uid: int

var ad_position: int


func _init(ad_unit_id: String, ad_size: AdSize, ad_position: AdPosition.Values) -> void :
    self.ad_position = ad_position

    if _plugin:
        var ad_view_dictionary: = {
            "ad_unit_id": ad_unit_id, 
            "ad_position": ad_position, 
            "ad_size": {
                "width": ad_size.width, 
                "height": ad_size.height
            }
        }

        _uid = _plugin.create(ad_view_dictionary)
        _plugin.connect("on_ad_clicked", _on_ad_clicked)
        _plugin.connect("on_ad_closed", _on_ad_closed)
        _plugin.connect("on_ad_failed_to_load", _on_ad_failed_to_load)
        _plugin.connect("on_ad_impression", _on_ad_impression)
        _plugin.connect("on_ad_loaded", _on_ad_loaded)
        _plugin.connect("on_ad_opened", _on_ad_opened)

func load_ad(ad_request: AdRequest) -> void :
    if _plugin:
        _plugin.load_ad(_uid, ad_request.convert_to_dictionary(), ad_request.keywords)

func destroy() -> void :
    if _plugin:
        _plugin.destroy(_uid)

func hide() -> void :
    if _plugin:
        _plugin.hide(_uid)

func show() -> void :
    if _plugin:
        _plugin.show(_uid)

func get_width() -> int:
    if _plugin:
        return _plugin.get_width(_uid)
    return -1

func get_height() -> int:
    if _plugin:
        return _plugin.get_height(_uid)
    return -1

func get_width_in_pixels() -> int:
    if _plugin:
        return _plugin.get_width_in_pixels(_uid)
    return -1

func get_height_in_pixels() -> int:
    if _plugin:
        return _plugin.get_height_in_pixels(_uid)
    return -1

func _on_ad_clicked(uid: int) -> void :
    if uid == _uid:
        ad_listener.on_ad_clicked.call_deferred()

func _on_ad_closed(uid: int) -> void :
    if uid == _uid:
        ad_listener.on_ad_closed.call_deferred()

func _on_ad_failed_to_load(uid: int, load_ad_error_dictionary: Dictionary) -> void :
    if uid == _uid:
        ad_listener.on_ad_failed_to_load.call_deferred(LoadAdError.create(load_ad_error_dictionary))

func _on_ad_impression(uid: int) -> void :
    if uid == _uid:
        ad_listener.on_ad_impression.call_deferred()

func _on_ad_loaded(uid: int) -> void :
    if uid == _uid:
        ad_listener.on_ad_loaded.call_deferred()

func _on_ad_opened(uid: int) -> void :
    if uid == _uid:
        ad_listener.on_ad_opened.call_deferred()
