extends Node

var attributes: Dictionary[String, Attribute]
var window_attributes: Dictionary
var applied_premiums: Dictionary


func _ready() -> void :
    Signals.new_upgrade.connect(_on_new_upgrade)
    Signals.new_research.connect(_on_new_research)
    Signals.new_milestone.connect(_on_new_milestone)
    Signals.new_perk.connect(_on_new_perk)
    Premiums.updated.connect(_on_premiums_updated)


func init_attributes() -> void :
    for i: String in Data.attributes:
        attributes[i] = Attribute.new(Data.attributes[i].default)
    for i: String in Globals.group_count:
        attributes[i] = Attribute.new(0)
    for window: String in Data.windows:
        window_attributes[window] = {}
        for i: String in Data.windows[window].attributes:
            window_attributes[window][i] = Attribute.new(Data.windows[window].attributes[i])

    for i: String in Data.premiums:
        applied_premiums[i] = false

    for upgrade: String in Globals.upgrades:
        if !Data.upgrades.has(upgrade): continue
        apply_attribute_dict(Data.upgrades[upgrade].attributes, Globals.upgrades[upgrade])
        apply_windows_attribute_dict(Data.upgrades[upgrade].window_attributes, Globals.upgrades[upgrade])

    for research: String in Globals.research:
        if !Data.research.has(research): continue
        apply_attribute_dict(Data.research[research].attributes, Globals.research[research])
        apply_windows_attribute_dict(Data.research[research].window_attributes, Globals.research[research])

    for milestone: String in Globals.milestones:
        if !Data.milestones.has(milestone): continue
        apply_attribute_dict(Data.milestones[milestone].attributes, Globals.milestones[milestone])
        apply_windows_attribute_dict(Data.milestones[milestone].window_attributes, Globals.milestones[milestone])

    for perk: String in Globals.perks:
        if !Data.perks.has(perk): continue
        apply_attribute_dict(Data.perks[perk].attributes, Globals.perks[perk])
        apply_windows_attribute_dict(Data.perks[perk].window_attributes, Globals.perks[perk])

    update_premiums()


func update_premiums() -> void :
    for premium: String in Premiums.premiums:
        if Premiums.premiums[premium]:
            if !applied_premiums[premium]:
                apply_attribute_dict(Data.premiums[premium].attributes, 1)
                apply_windows_attribute_dict(Data.premiums[premium].window_attributes, 1)
                applied_premiums[premium] = true
        elif applied_premiums[premium]:
                apply_attribute_dict(Data.premiums[premium].attributes, -1)
                apply_windows_attribute_dict(Data.premiums[premium].window_attributes, -1)
                applied_premiums[premium] = false


func apply_attribute_dict(attributes: Dictionary, times: int = 1) -> void :
    for i: String in attributes:
        apply_attribute(i, attributes[i], times)


func apply_attribute(attribute: String, values: Array, times: int = 1) -> void :
    attributes[attribute].add(values[0] * times, values[1] * times, values[2], times)


func get_attribute(attribute: String) -> float:
    return attributes[attribute].raw


func apply_windows_attribute_dict(attributes: Dictionary, times: int = 1) -> void :
    for window: String in attributes:
        for i: String in attributes[window]:
            apply_window_attribute_dict(window, attributes[window], times)


func apply_window_attribute_dict(window: String, attributes: Dictionary, times: int = 1) -> void :
    for i: String in attributes:
        apply_window_attribute(window, i, attributes[i], times)


func apply_window_attribute(window: String, attribute: String, values: Array, times: int = 1) -> void :
    window_attributes[window][attribute].add(values[0] * times, values[1] * times, values[2], times)


func get_window_attribute(window: String, attribute: String) -> float:
    return window_attributes[window][attribute].raw


func _on_new_upgrade(upgrade: String, levels: int) -> void :
    apply_attribute_dict(Data.upgrades[upgrade].attributes, levels)
    apply_windows_attribute_dict(Data.upgrades[upgrade].window_attributes, levels)


func _on_new_research(research: String, levels: int) -> void :
    apply_attribute_dict(Data.research[research].attributes, levels)
    apply_windows_attribute_dict(Data.research[research].window_attributes, levels)


func _on_new_milestone(milestone: String, levels: int) -> void :
    apply_attribute_dict(Data.milestones[milestone].attributes, levels)
    apply_windows_attribute_dict(Data.milestones[milestone].window_attributes, levels)


func _on_new_perk(perk: String, levels: int) -> void :
    apply_attribute_dict(Data.perks[perk].attributes, levels)
    apply_windows_attribute_dict(Data.perks[perk].window_attributes, levels)


func _on_premiums_updated() -> void :
    update_premiums()
