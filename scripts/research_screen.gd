extends Node2D

@onready var research_tree: = $Tree
@onready var research_button: = $ResearchPanel / InfoContainer / Button

var selected_research: String
var level: int
var cost: float
var maxed: bool


func _ready() -> void :
    Signals.research_selected.connect(_on_research_selected)
    Signals.new_research.connect(_on_new_research)

    set_process(false)


func _process(delta: float) -> void :
    research_button.disabled = !can_research()


func _draw() -> void :
    for i: Button in research_tree.get_children():
        if !Data.research[i.name].requirement.is_empty():
            for research: String in Data.research[i.name].requirement:
                if !research_tree.has_node(research): continue

                var target: Control = research_tree.get_node(research)
                var color: Color = Color("91b1e61a")

                if i.name == selected_research:
                    color = Color("ff8500")
                elif Globals.research[research] > 0:
                    color = Color("91b1e6")

                draw_line(i.global_position + (i.size / 2), target.global_position + (target.size / 2), color, 2, true)


func can_research() -> bool:
    if selected_research.is_empty(): return false
    if maxed: return false
    if cost > Globals.currencies[Data.research[selected_research].currency]: return false

    return true























func update_research() -> void :
    level = Globals.research[selected_research]
    var max_level: int = Data.research[selected_research].limit
    maxed = level >= max_level
    cost = Data.research[selected_research].cost * 10 ** Data.research[selected_research].cost_e

    $ResearchPanel / InfoContainer / Name.text = Data.research[selected_research].name
    $ResearchPanel / InfoContainer / Description.text = Data.research[selected_research].description

    if cost > 0.0:
        $ResearchPanel / InfoContainer / Button / CostContainer / Icon.visible = true
        $ResearchPanel / InfoContainer / Button / CostContainer / Label.text = Utils.print_string(cost, true)
    else:
        $ResearchPanel / InfoContainer / Button / CostContainer / Icon.visible = false
        $ResearchPanel / InfoContainer / Button / CostContainer / Label.text = "free"


func set_research(research: String) -> void :
    selected_research = research
    if !selected_research.is_empty():
        update_research()
        var research_button: Button = research_tree.get_node(research)
        $ResearchPanel.position = research_button.position + Vector2(research_button.size.x + 20, 0)
        $ResearchPanel / AnimationPlayer.play("Popup")
        $ResearchPanel / AnimationPlayer.seek(0, true)
    elif $ResearchPanel.visible:
        $ResearchPanel / AnimationPlayer.play("Close")

    for i: Button in research_tree.get_children():
        i.button_pressed = i.name == selected_research

    set_process( !selected_research.is_empty())


func _on_new_research(research: String, levels: int) -> void :
    if !selected_research.is_empty():
        update_research()
    queue_redraw()


func _on_research_selected(research: String) -> void :
    if research == selected_research:
        set_research("")
    else:
        set_research(research)
    queue_redraw()


func _on_research_button_pressed() -> void :
    if can_research():
        Globals.currencies[Data.research[selected_research].currency] -= cost


        var particle: GPUParticles2D = load("res://particles/upgrade.tscn").instantiate()
        Signals.spawn_particle.emit(particle, $ResearchPanel.position + $ResearchPanel.size / 2)

        Globals.add_research(selected_research, 1)
        Sound.play("research")
