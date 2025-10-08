





















class_name AdapterStatus

var latency: int
var initialization_state: InitializationState
var description: String

enum InitializationState{
    NOT_READY, 
    READY
}

func _init(latency: int, initialization_state: InitializationState, description: String) -> void :
    self.latency = latency
    self.initialization_state = initialization_state
    self.description = description
