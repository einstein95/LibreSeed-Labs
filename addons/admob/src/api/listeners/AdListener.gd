





















class_name AdListener

var on_ad_clicked: Callable = func(): pass
var on_ad_closed: Callable = func(): pass
var on_ad_failed_to_load: Callable = func(load_ad_error: LoadAdError): pass
var on_ad_impression: Callable = func(): pass
var on_ad_loaded: Callable = func(): pass
var on_ad_opened: Callable = func(): pass
