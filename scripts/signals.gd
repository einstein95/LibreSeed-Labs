extends Node

signal tick

signal register_resource(id: String, resource: ResourceContainer)
signal resource_renamed(old_id: String, new_id: String)
signal connection_set()
signal connection_droppped(connection: NodePath)
signal create_connection(output: String, input: String)
signal delete_connection(output: String, input: String)
signal connection_created(output: String, input: String)
signal connection_deleted(coutput: String, input: String)
signal highlight_connection(resource: ResourceContainer, type: int)
signal create_window(window: WindowContainer)
signal create_connector(connector: Node2D)
signal window_created(window: WindowContainer)
signal window_deleted(window: WindowContainer)
signal add_timed_effect(effect: Node)
signal tool_set
signal selecting
signal selected
signal selection_set
signal move_selection(offset: Vector2)
signal move_connectors(offset: Vector2)
signal dragging(window: WindowContainer)
signal dragged(window: WindowContainer)
signal dragging_set
signal window_moved(window: Control)
signal set_menu(menu: int, tab: int)
signal menu_set(menu: int, tab: int)
signal open_guide(guide: String)
signal move_camera(offset: Vector2)
signal center_camera(pos: Vector2)
signal offline_multiplier_set
signal resource_selected(resource: ResourceContainer)
signal research_selected(research: String)
signal set_screen(screen: int, position: Vector2)
signal screen_set(screen: int)
signal screen_transition_started
signal screen_transition_finished
signal tutorial_step
signal create_pointer(notifier: VisibleOnScreenNotifier2D)

signal new_upgrade(upgrade: String, levels: int)
signal new_research(research: String, levels: int)
signal research_queued(research: String, levels: int)
signal new_milestone(milestone: String, levels: int)
signal milestone_queued(milestone: String, levels: int)
signal new_perk(perk: String, levels: int)
signal new_unlock(unlock: String)
signal new_level
signal new_research_level
signal new_hack_level
signal new_code_level
signal new_storage(file: String, variation: int)
signal storage_deleted(file: String, variation: int)
signal new_schematic(schematic: String)
signal deleted_schematic(schematic: String)
signal place_schematic(schematic: String)
signal service_purchased(service: String)
signal uploaded(resource: ResourceContainer, count: float)
signal commited(resource: ResourceContainer, count: float)
signal quarantined(input: ResourceContainer, output: ResourceContainer, count: float)
signal redownloaded(input: ResourceContainer, output: ResourceContainer, count: float)
signal compressed(input: ResourceContainer, output: ResourceContainer, count: float)
signal enhanced(input: ResourceContainer, output: ResourceContainer, count: float)
signal breached(breach: WindowIndexed)
signal new_achievement(achievement: String)
signal achievement_claimed(achievement: String)
signal new_request(request: String)
signal request_claimed(request: String)
signal tokens_claimed
signal spawn_particle(particle: GPUParticles2D, pos: Vector2)
signal spawn_ui_particle(particle: GPUParticles2D, pos: Vector2)
signal spawn_popup(text: String, pos: Vector2)
signal spawn_placer(placer: Button)
signal notify(icon: String, text: String)
signal fixed_notify(icon: String, text: String)
signal popup(popup: String)
signal currency_popup(currency: String, amount: float)
signal currency_popup_particle(currency: String, pop: Vector2)
signal save_schematic(data: Dictionary)
signal desktop_point_to(to: Control)
signal interface_point_to(to: Control)

signal boot
signal desktop_ready
signal reboot
signal saving
signal date_changed
signal setting_set(setting: String)
signal movement_input(event: InputEvent, from: Vector2)
