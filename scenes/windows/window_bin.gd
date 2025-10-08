extends WindowBase

@onready var input: = $PanelContainer / MainContainer / Input


func _ready() -> void :
    super ()
    Signals.tutorial_step.connect(_on_tutorial_step)

    update_tutorial()


func process(delta: float) -> void :
    input.pop_all()


func update_tutorial() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.DRAG_BIN_CONNECTOR:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($PanelContainer / MainContainer / Input / InputConnector)
    elif Globals.tutorial_step == Utils.tutorial_steps.SELECT_BIN:
        Signals.interface_point_to.emit(null)
        Signals.desktop_point_to.emit($TitlePanel)

    if Globals.tutorial_done:
        can_select = true
        can_drag = true
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
    elif Globals.tutorial_step == Utils.tutorial_steps.SELECT_BIN:
        can_select = true
        can_drag = false
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
    else:
        can_select = false
        can_drag = false
        $TitlePanel.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

    var file_steps: Array[int] = [Utils.tutorial_steps.DRAG_BIN_CONNECTOR]
    $PanelContainer / MainContainer / Input / InputConnector.disabled = !Globals.tutorial_done and !file_steps.has(Globals.tutorial_step)


func close() -> void :
    super ()
    if Globals.tutorial_step == Utils.tutorial_steps.DELETE_BIN:
        Globals.set_tutorial_step(Utils.tutorial_steps.DELETE_BIN + 1)


func _on_tutorial_step() -> void :
    update_tutorial()


func _on_input_connection_set() -> void :
    if Globals.tutorial_step == Utils.tutorial_steps.DRAG_BIN_CONNECTOR:
        Globals.set_tutorial_step(Utils.tutorial_steps.DRAG_BIN_CONNECTOR + 1)


func _on_selection_set() -> void :
    super ()
    if Globals.tutorial_step == Utils.tutorial_steps.SELECT_BIN and Globals.selections.has(self):
        Globals.set_tutorial_step(Utils.tutorial_steps.SELECT_BIN + 1)
    elif Globals.tutorial_step == Utils.tutorial_steps.DELETE_BIN and !Globals.selections.has(self):
        Globals.set_tutorial_step(Utils.tutorial_steps.SELECT_BIN)
