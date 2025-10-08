





















class_name AdError

var code: int
var domain: String
var message: String
var cause: AdError

func _init(code: int, domain: String, message: String, cause: AdError):
    self.code = code
    self.domain = domain
    self.message = message
    self.cause = cause


static func create(ad_error_dictionary: Dictionary) -> AdError:
    if not ad_error_dictionary.is_empty():
        var code: int = ad_error_dictionary["code"]
        var domain: String = ad_error_dictionary["domain"]
        var message: String = ad_error_dictionary["message"]
        var cause: = AdError.create(ad_error_dictionary["cause"])

        return AdError.new(code, domain, message, cause)
    return null
