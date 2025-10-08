





















class_name LoadAdError
extends AdError

var response_info: ResponseInfo

func _init(response_info: ResponseInfo, code: int, domain: String, message: String, cause: AdError):
    super ._init(code, domain, message, cause)
    self.response_info = response_info


static func create(load_ad_error_dictionary: Dictionary) -> AdError:
    if not load_ad_error_dictionary.is_empty():
        var adError: = AdError.create(load_ad_error_dictionary)
        var responseInfo: = ResponseInfo.create(load_ad_error_dictionary["response_info"])

        return LoadAdError.new(responseInfo, adError.code, adError.domain, adError.message, adError.cause)
    return null
