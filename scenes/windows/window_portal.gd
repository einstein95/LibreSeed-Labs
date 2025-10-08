extends WindowBase

@onready var research: = $PanelContainer / MainContainer / Research


func _ready() -> void :
    if Globals.stats.reborns > 0:
        visible = true
    Signals.research_queued.connect(_on_research_queued)
    super ()

    for i: String in Globals.q_research:
        add_research(i)
        $Buttons / Enter.disabled = false


func process(delta: float) -> void :
    research.count = Globals.max_research


func add_research(research: String) -> void :
    var instance: TextureRect = load("res://scenes/new_research_panel.tscn").instantiate()
    instance.name = research
    $PanelContainer / MainContainer / ResearchContainer.add_child(instance)


func _on_open_pressed() -> void :
    Signals.set_screen.emit(1, $PanelContainer / MainContainer / Control / Sprite2D.global_position)
    Sound.play("click2")


func _on_enter_pressed() -> void :
    Signals.popup.emit("Portal")
    Sound.play("click2")


func _on_research_queued(research: String, levels: int) -> void :
    if $PanelContainer / MainContainer / ResearchContainer.has_node(research): return

    add_research(research)
    $Buttons / Enter.disabled = false
