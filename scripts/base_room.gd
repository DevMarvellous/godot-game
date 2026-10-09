extends Node3D

## Base Room Controller for modular campus environments.
## Provides room entry points, door triggers, and camera setup.

@export var room_name: String = "Campus Room"
@export var room_id: StringName = &"courtyard"

@onready var player: Player3D = $Player3D
@onready var hud: HUD = $HUD
@onready var mobile_controls: CanvasLayer = $MobileControls
@onready var menus_layer: CanvasLayer = $MenusLayer

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")
const PhoneScene = preload("res://scenes/phone_system.tscn")
const SalonScene = preload("res://scenes/salon_menu.tscn")
const ChatScene = preload("res://scenes/chat_wheel.tscn")
const NetworkPlayerScene = preload("res://scenes/network_player.tscn")
var phone_menu: Control = null
var salon_menu: Control = null
var chat_menu: Control = null
var remote_player_nodes: Dictionary = {}

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
		if mobile_controls.has_signal("phone_requested"):
			mobile_controls.phone_requested.connect(_on_phone_requested)
		if mobile_controls.has_signal("chat_requested"):
			mobile_controls.chat_requested.connect(_on_chat_requested)

	if menus_layer:
		if menus_layer.has_node("PhoneSystem"):
			phone_menu = menus_layer.get_node("PhoneSystem")
		else:
			phone_menu = PhoneScene.instantiate()
			menus_layer.add_child(phone_menu)
		if phone_menu and phone_menu.has_signal("phone_closed"):
			phone_menu.phone_closed.connect(_on_menu_closed)

		if not menus_layer.has_node("ChatWheel"):
			chat_menu = ChatScene.instantiate()
			menus_layer.add_child(chat_menu)
			if chat_menu.has_signal("chat_closed"):
				chat_menu.chat_closed.connect(_on_menu_closed)

		if room_id == &"salon":
			if menus_layer.has_node("SalonMenu"):
				salon_menu = menus_layer.get_node("SalonMenu")
			else:
				salon_menu = SalonScene.instantiate()
				menus_layer.add_child(salon_menu)
			if salon_menu and salon_menu.has_signal("salon_closed"):
				salon_menu.salon_closed.connect(_on_menu_closed)

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
	elif menu_type == &"salon" and salon_menu:
		salon_menu.open_salon(p)


func _on_npc_dialogue_requested(npc: NPC3D, p: CharacterBody3D) -> void:
	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
	if dialogue_menu:
		dialogue_menu.open_dialogue(p, npc.character_name, npc.character_role)


func _on_phone_requested() -> void:
	if phone_menu and player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
		phone_menu.open_phone(player)


func _on_chat_requested() -> void:
	if chat_menu and player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
		chat_menu.open_chat()


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

	# Campus Keke Shuttle fare (₦100) except walking to hostel
	if player and scene_path != "res://scenes/rooms/hostel_room.tscn":
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			if not needs.modify_money(-100):
				# Out of money: forced to walk (takes 20 mins instead of 3 mins)
				TimeSystem.advance_minutes(20)
				needs.modify_energy(-10.0)
				if player.has_method("display_notification"):
					player.display_notification("No Keke money! Trekked on foot (-10 Energy, 20m)")
			else:
				TimeSystem.advance_minutes(3) # Fast keke ride
				if SoundManager:
					SoundManager.play_transit_horn()
				if player.has_method("display_notification"):
					player.display_notification("Took Campus Keke Shuttle! Paid ₦100")
	else:
		TimeSystem.advance_minutes(5) # Walking to hostel is free

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


func _process(_delta: float) -> void:
	if not NetworkManager or not NetworkManager.is_online():
		return

	var current_scene_name: String = String(name)
	var active_peers: Dictionary = NetworkManager.remote_players

	# Spawn or update remote player puppets in this room
	for peer_id: int in active_peers.keys():
		var p_data: Dictionary = active_peers[peer_id]
		var peer_room: String = String(p_data.get("room", ""))

		if peer_room == current_scene_name:
			if not remote_player_nodes.has(peer_id):
				var puppet: NetworkPlayer = NetworkPlayerScene.instantiate() as NetworkPlayer
				puppet.peer_id = peer_id
				puppet.student_name = String(p_data.get("name", "Student"))
				add_child(puppet)
				remote_player_nodes[peer_id] = puppet
			var puppet_node: NetworkPlayer = remote_player_nodes[peer_id]
			var pos: Vector3 = p_data.get("pos", Vector3.ZERO)
			var rot_y: float = float(p_data.get("rot_y", 0.0))
			var is_moving: bool = bool(p_data.get("is_moving", false))
			puppet_node.update_network_transform(pos, rot_y, is_moving)
		else:
			# Player moved to another room
			if remote_player_nodes.has(peer_id):
				var puppet_to_remove: Node = remote_player_nodes[peer_id]
				puppet_to_remove.queue_free()
				remote_player_nodes.erase(peer_id)

	# Clean up disconnected peers
	for peer_id: int in remote_player_nodes.keys():
		if not active_peers.has(peer_id):
			var puppet_to_remove: Node = remote_player_nodes[peer_id]
			puppet_to_remove.queue_free()
			remote_player_nodes.erase(peer_id)

