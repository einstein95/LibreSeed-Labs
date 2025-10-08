





















class_name ResponseInfo

var loaded_adapter_response_info: AdapterResponseInfo
var adapter_responses: Array[AdapterResponseInfo]
var response_extras: Dictionary
var mediation_adapter_class_name: String
var response_id: String

func _init(loaded_adapter_response_info: AdapterResponseInfo, 
            adapter_responses: Array[AdapterResponseInfo], 
            response_extras: Dictionary, 
            mediation_adapter_class_name: String, 
            response_id: String):
    self.loaded_adapter_response_info = loaded_adapter_response_info
    self.adapter_responses = adapter_responses
    self.response_extras = response_extras
    self.mediation_adapter_class_name = mediation_adapter_class_name
    self.response_id = response_id

static func create(response_info_dictionary: Dictionary) -> ResponseInfo:
    if not response_info_dictionary.is_empty():
        var loaded_adapter_response_info: = AdapterResponseInfo.create(response_info_dictionary["loaded_adapter_response_info"])
        var adapter_responses: = AdapterResponseInfo.create_adapter_responses(response_info_dictionary["adapter_responses"])
        var response_extras: Dictionary = response_info_dictionary["response_extras"]
        var mediation_adapter_class_name: String = response_info_dictionary["mediation_adapter_class_name"]
        var response_id: String = response_info_dictionary["response_id"]

        return ResponseInfo.new(loaded_adapter_response_info, adapter_responses, response_extras, mediation_adapter_class_name, response_id)
    return null
