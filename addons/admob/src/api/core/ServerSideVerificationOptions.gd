





















class_name ServerSideVerificationOptions

var custom_data: String
var user_id: String

func convert_to_dictionary() -> Dictionary:
    return {
        "custom_data": custom_data, 
        "user_id": user_id
    }
