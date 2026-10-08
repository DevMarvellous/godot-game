extends Node3D

## Base Room Controller for modular campus environments.
## Provides room entry points, door triggers, and camera setup.

@export var room_name: String = "Campus Room"
@export var room_id: StringName = &"courtyard"

@onready var player: Player3D = $Player3D
@onready var hud: HUD = $HUD
@onready var mobile_controls: CanvasLayer = $MobileControls
@onready var menus_layer: CanvasLayer = $MenusLayer

@onready var food_menu: Control = $MenusLayer/FoodMenu if has_node("MenusLayer/FoodMenu") else null
@onready var study_menu: Control = $MenusLayer/StudyMenu if has_node("MenusLayer/StudyMenu") else null
@onready var ca_test_menu: Control = $MenusLayer/CATestMenu if has_node("MenusLayer/CATestMenu") else null
@onready var dialogue_menu: Control = $MenusLayer/DialogueMenu if has_node("MenusLayer/DialogueMenu") else null
@onready var summary_menu: Control = $MenusLayer/SummaryMenu if has_node("MenusLayer/SummaryMenu") else null


func _ready() -> void:
	if player and hud:
		hud.connect_player_needs(player.needs_manager)
		player.needs_manager.player_passed_out.connect(_on_player_passed_out)

	if mobile_controls and player:
		if mobile_controls.has_method("bind_player"):
			mobile_controls.bind_player(player)
		if mobile_controls.has_signal("transit_requested"):
			mobile_controls.transit_requested.connect(_on_transit_requested)

	if food_menu:
		food_menu.menu_closed.connect(_on_menu_closed)
	if study_menu:
		study_menu.menu_closed.connect(_on_menu_closed)
	if ca_test_menu:
		ca_test_menu.test_closed.connect(_on_menu_closed)
	if dialogue_menu:
		dialogue_menu.dialogue_ended.connect(_on_menu_closed)
	if summary_menu:
		summary_menu.summary_closed.connect(_on_summary_closed)

	if SemesterManager:
		SemesterManager.day_ended.connect(_on_day_ended)
		SemesterManager.semester_finished.connect(_on_semester_finished)

	_connect_interactive_fixtures()


func _connect_interactive_fixtures() -> void:
	# Scan for any interactive fixtures in the room and connect them
	var fixtures: Node = get_node_or_null("WorldObjects")
	if not fixtures:
		return

	for child: Node in fixtures.get_children():
		if child is CampusObject3D:
			child.menu_requested.connect(_on_fixture_menu_requested)

	var npcs: Node = get_node_or_null("NPCs")
	if npcs:
		for child: Node in npcs.get_children():
			if child is NPC3D:
				child.dialogue_requested.connect(_on_npc_dialogue_requested)


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO

	if menu_type == &"food" and food_menu:
		food_menu.open_menu(p)
	elif menu_type == &"study":
		if ca_test_menu and room_id == &"lecture":
			# In lecture hall, taking a desk opens the CA Test Paper!
			ca_test_menu.start_test(p, "CSC 101")
		elif study_menu:
			study_menu.open_menu(p)


func _on_npc_dialogue_requested(npc: NPC3D, p: CharacterBody3D) -> void:
	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
	if dialogue_menu:
		dialogue_menu.open_dialogue(p, npc.character_name, npc.character_role)


func _on_transit_requested(dest: StringName) -> void:
	match dest:
		&"hostel":
			_go_to_scene("res://scenes/rooms/hostel_room.tscn")
		&"class":
			_go_to_scene("res://scenes/rooms/lecture_hall.tscn")
		&"class2":
			_go_to_scene("res://scenes/rooms/lecture_theatre_2.tscn")
		&"library":
			_go_to_scene("res://scenes/rooms/library_hall.tscn")
		&"buka":
			_go_to_scene("res://scenes/rooms/buka_court.tscn")
		&"chapel":
			_go_to_scene("res://scenes/rooms/chapel_hall.tscn")
		&"sub":
			_go_to_scene("res://scenes/rooms/sub_building.tscn")
		&"garden":
			_go_to_scene("res://scenes/rooms/campus_garden.tscn")
		&"salon":
			_go_to_scene("res://scenes/rooms/barbing_salon.tscn")
		&"atm":
			_go_to_scene("res://scenes/main.tscn")


func _go_to_scene(scene_path: String) -> void:
	if get_tree().current_scene.scene_file_path == scene_path:
		if player and player.has_method("display_notification"):
			player.display_notification("Already here!")
		return

	TimeSystem.advance_minutes(5) # Walking travel time
	get_tree().change_scene_to_file(scene_path)


func _on_menu_closed() -> void:
	if player:
		player.set_physics_process(true)


func _on_day_ended(summary_data: Dictionary) -> void:
	TimeSystem.paused = true
	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
	if summary_menu and summary_menu.has_method("show_day_summary"):
		summary_menu.show_day_summary(summary_data)


func _on_semester_finished(final_results: Dictionary) -> void:
	TimeSystem.paused = true
	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
	if summary_menu and summary_menu.has_method("show_semester_results"):
		summary_menu.show_semester_results(final_results)


func _on_summary_closed() -> void:
	TimeSystem.paused = false
	if player:
		player.set_physics_process(true)


func _on_player_passed_out(_reason: String) -> void:
	# If collapsed outside the hostel, wake up back in the hostel
	get_tree().change_scene_to_file("res://scenes/rooms/hostel_room.tscn")

