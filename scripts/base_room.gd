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
const WardrobeScene = preload("res://scenes/wardrobe_menu.tscn")
const MallScene = preload("res://scenes/mall_menu.tscn")
const SnookerScene = preload("res://scenes/snooker_mini_game.tscn")
const GigsScene = preload("res://scenes/campus_gigs_menu.tscn")
const ShuttleDialogScene = preload("res://scenes/campus_shuttle_dialog.tscn")
const LibraryStudyScene = preload("res://scenes/library_study_dialog.tscn")
const CourseworkScene = preload("res://scenes/coursework_menu.tscn")
const LectureSessionScene = preload("res://scenes/lecture_session_dialog.tscn")
const LectureDeskScene = preload("res://scenes/lecture_desk_menu.tscn")
const ExamHallScene = preload("res://scenes/exam_hall_menu.tscn")
var phone_menu: Control = null
var salon_menu: Control = null
var chat_menu: Control = null
var wardrobe_menu: Control = null
var mall_menu: Control = null
var snooker_menu: Control = null
var gigs_menu: Control = null
var shuttle_dialog: Control = null
var library_study_dialog: Control = null
var coursework_menu: Control = null
var lecture_session_dialog: Control = null
var lecture_desk_menu: Control = null
var exam_hall_menu: Control = null
var remote_player_nodes: Dictionary = {}
var active_ceiling_fans: Array[Node3D] = []

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
			if chat_menu.has_signal("message_sent"):
				chat_menu.message_sent.connect(func(msg: String):
					if player:
						player.show_chat_bubble(msg)
				)

		if room_id == &"salon":
			if menus_layer.has_node("SalonMenu"):
				salon_menu = menus_layer.get_node("SalonMenu")
			else:
				salon_menu = SalonScene.instantiate()
				menus_layer.add_child(salon_menu)
			if salon_menu and salon_menu.has_signal("salon_closed"):
				salon_menu.salon_closed.connect(_on_menu_closed)

		if room_id == &"mall":
			if menus_layer.has_node("MallMenu"):
				mall_menu = menus_layer.get_node("MallMenu")
			else:
				mall_menu = MallScene.instantiate()
				menus_layer.add_child(mall_menu)
			if mall_menu and mall_menu.has_signal("mall_closed"):
				mall_menu.mall_closed.connect(_on_menu_closed)

	if food_menu:
		food_menu.menu_closed.connect(_on_menu_closed)
	if study_menu:
		study_menu.menu_closed.connect(_on_menu_closed)
		if study_menu.has_signal("live_lecture_requested"):
			study_menu.live_lecture_requested.connect(_on_live_lecture_requested)
	if ca_test_menu:
		ca_test_menu.test_closed.connect(_on_menu_closed)
	if dialogue_menu:
		dialogue_menu.dialogue_ended.connect(_on_menu_closed)
	if summary_menu:
		summary_menu.summary_closed.connect(_on_summary_closed)

	if not wardrobe_menu and menus_layer:
		wardrobe_menu = WardrobeScene.instantiate() as Control
		menus_layer.add_child(wardrobe_menu)
		if wardrobe_menu.has_signal("wardrobe_closed"):
			wardrobe_menu.wardrobe_closed.connect(_on_menu_closed)

	if SemesterManager:
		if not SemesterManager.day_ended.is_connected(_on_day_ended):
			SemesterManager.day_ended.connect(_on_day_ended)
		if not SemesterManager.semester_finished.is_connected(_on_semester_finished):
			SemesterManager.semester_finished.connect(_on_semester_finished)

	_configure_dynamic_hostel_room()
	_connect_interactive_fixtures()
	_gather_ceiling_fans(self)


func _gather_ceiling_fans(node: Node) -> void:
	if node != self and node is Node3D and "fan" in node.name.to_lower():
		active_ceiling_fans.append(node as Node3D)
	for child in node.get_children():
		_gather_ceiling_fans(child)


func _process(delta: float) -> void:
	for fan in active_ceiling_fans:
		if is_instance_valid(fan):
			fan.rotate_y(delta * 8.5)
	_process_network_puppets()


func _configure_dynamic_hostel_room() -> void:
	if room_id != &"hostel":
		return

	const ProfileStore = preload("res://scripts/data/student_profile.gd")
	ProfileStore.load_from_disk()
	var is_female: bool = (ProfileStore.gender.to_lower() == "female")

	var room_title: Label3D = get_node_or_null("RoomDecor/RoomTitle3D") as Label3D
	if room_title:
		if is_female:
			room_title.text = "MOREMI HALL (FEMALE HOSTEL - ROOM 204)"
		else:
			room_title.text = "HALL 2 (MALE HOSTEL - ROOM 112)"

	var roommate_npc: NPC3D = get_node_or_null("NPCs/SegunRoommate") as NPC3D
	if roommate_npc:
		if is_female:
			roommate_npc.character_name = "Chisom"
			roommate_npc.character_role = "Hostel Roommate (CSC 100L)"
			roommate_npc.shirt_color = Color(0.85, 0.35, 0.65, 1) # Rose pink
		else:
			roommate_npc.character_name = "Segun"
			roommate_npc.character_role = "Hostel Roommate (CSC 100L)"
			roommate_npc.shirt_color = Color(0.9, 0.45, 0.15, 1) # Orange
		roommate_npc.apply_character_data()

	# Dynamic Room Upgrades Visual Spawning
	var decor: Node3D = get_node_or_null("RoomDecor") as Node3D
	if decor:
		if ProfileStore.owned_upgrades.has("mini_fridge") and not decor.has_node("MiniFridgeMesh"):
			var fridge = MeshInstance3D.new()
			fridge.name = "MiniFridgeMesh"
			var box = BoxMesh.new()
			box.size = Vector3(0.65, 0.85, 0.6)
			fridge.mesh = box
			var mat = StandardMaterial3D.new()
			mat.albedo_color = Color(0.88, 0.90, 0.92, 1)
			mat.metallic = 0.3
			fridge.material_override = mat
			fridge.position = Vector3(-3.2, 0.42, -5.0)
			decor.add_child(fridge)

		if ProfileStore.owned_upgrades.has("sound_speaker") and not decor.has_node("SoundSpeakerMesh"):
			var speaker = MeshInstance3D.new()
			speaker.name = "SoundSpeakerMesh"
			var s_box = BoxMesh.new()
			s_box.size = Vector3(0.35, 0.18, 0.18)
			speaker.mesh = s_box
			var s_mat = StandardMaterial3D.new()
			s_mat.albedo_color = Color(0.12, 0.12, 0.15, 1)
			speaker.material_override = s_mat
			speaker.position = Vector3(5.1, 0.88, -4.8)
			decor.add_child(speaker)

		if ProfileStore.owned_upgrades.has("study_lamp"):
			var lamp_light = decor.get_node_or_null("DeskLampLight") as OmniLight3D
			if lamp_light:
				lamp_light.light_energy = 2.4
				lamp_light.omni_range = 5.5

		if ProfileStore.owned_upgrades.has("hostel_fan") and not decor.has_node("StandingFanPole"):
			var fan_pole = MeshInstance3D.new()
			fan_pole.name = "StandingFanPole"
			var pole_mesh = CylinderMesh.new()
			pole_mesh.top_radius = 0.05
			pole_mesh.bottom_radius = 0.25
			pole_mesh.height = 1.4
			fan_pole.mesh = pole_mesh
			var fan_mat = StandardMaterial3D.new()
			fan_mat.albedo_color = Color(0.18, 0.45, 0.85, 1) # Blue QASA standing fan
			fan_pole.material_override = fan_mat
			fan_pole.position = Vector3(-5.2, 0.7, -3.2)
			decor.add_child(fan_pole)

			var fan_head = MeshInstance3D.new()
			fan_head.name = "StandingFanHead"
			var head_mesh = CylinderMesh.new()
			head_mesh.top_radius = 0.45
			head_mesh.bottom_radius = 0.45
			head_mesh.height = 0.06
			fan_head.mesh = head_mesh
			fan_head.material_override = fan_mat
			fan_head.position = Vector3(0, 0.7, 0)
			fan_head.rotation.x = PI * 0.5
			fan_pole.add_child(fan_head)
			active_ceiling_fans.append(fan_head)

		if ProfileStore.owned_upgrades.has("mac_desk"):
			var laptop_mesh = decor.get_node_or_null("Laptop") as MeshInstance3D
			if laptop_mesh:
				var lap_mat = StandardMaterial3D.new()
				lap_mat.albedo_color = Color(0.85, 0.88, 0.92, 1)
				lap_mat.metallic = 0.8
				lap_mat.roughness = 0.2
				laptop_mesh.material_override = lap_mat


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
		if (room_id == &"lecture" or room_id == &"lecture2"):
			if not lecture_desk_menu and menus_layer:
				lecture_desk_menu = LectureDeskScene.instantiate()
				menus_layer.add_child(lecture_desk_menu)
				if lecture_desk_menu.has_signal("menu_closed"):
					lecture_desk_menu.menu_closed.connect(_on_menu_closed)
				if lecture_desk_menu.has_signal("action_chosen"):
					lecture_desk_menu.action_chosen.connect(_on_lecture_desk_action)
			if lecture_desk_menu:
				lecture_desk_menu.open_desk(p)
		elif study_menu:
			study_menu.open_menu(p)
	elif menu_type == &"live_lecture":
		_open_live_lecture(p)
	elif menu_type == &"exam":
		_open_final_exam(p)
	elif menu_type == &"salon" and salon_menu:
		salon_menu.open_salon(p)
	elif menu_type == &"mall" and mall_menu:
		mall_menu.open_mall(p)
	elif (menu_type == &"wardrobe" or menu_type == &"mall") and wardrobe_menu:
		wardrobe_menu.open_wardrobe(p)
	elif menu_type == &"snooker":
		if not snooker_menu and menus_layer:
			snooker_menu = SnookerScene.instantiate()
			menus_layer.add_child(snooker_menu)
			if snooker_menu.has_signal("game_closed"):
				snooker_menu.game_closed.connect(func(_winnings): _on_menu_closed())
		if snooker_menu:
			snooker_menu.open_game(p)
	elif menu_type == &"gigs":
		if not gigs_menu and menus_layer:
			gigs_menu = GigsScene.instantiate()
			menus_layer.add_child(gigs_menu)
			if gigs_menu.has_signal("menu_closed"):
				gigs_menu.menu_closed.connect(_on_menu_closed)
		if gigs_menu:
			gigs_menu.open_gigs(p)
	elif menu_type == &"shuttle":
		if not shuttle_dialog and menus_layer:
			shuttle_dialog = ShuttleDialogScene.instantiate()
			menus_layer.add_child(shuttle_dialog)
			if shuttle_dialog.has_signal("dialog_closed"):
				shuttle_dialog.dialog_closed.connect(_on_menu_closed)
			if shuttle_dialog.has_signal("destination_chosen"):
				shuttle_dialog.destination_chosen.connect(func(target_scene: String):
					_on_menu_closed()
					_go_to_scene(target_scene)
				)
		if shuttle_dialog:
			shuttle_dialog.open_shuttle(p)
		elif mobile_controls and mobile_controls.has_method("_toggle_transit_sheet"):
			mobile_controls._toggle_transit_sheet()
	elif menu_type == &"library_study":
		if not library_study_dialog and menus_layer:
			library_study_dialog = LibraryStudyScene.instantiate()
			menus_layer.add_child(library_study_dialog)
			if library_study_dialog.has_signal("dialog_closed"):
				library_study_dialog.dialog_closed.connect(_on_menu_closed)
		if library_study_dialog:
			library_study_dialog.open_library_study(p)
	elif menu_type == &"coursework":
		if not coursework_menu and menus_layer:
			coursework_menu = CourseworkScene.instantiate()
			menus_layer.add_child(coursework_menu)
			if coursework_menu.has_signal("menu_closed"):
				coursework_menu.menu_closed.connect(_on_menu_closed)
		if coursework_menu:
			coursework_menu.open_coursework(p)


func _on_live_lecture_requested(p: CharacterBody3D) -> void:
	_open_live_lecture(p)


func _on_lecture_desk_action(action: StringName) -> void:
	if not player:
		return
	match action:
		&"live_lecture":
			_open_live_lecture(player)
		&"coursework":
			if not coursework_menu and menus_layer:
				coursework_menu = CourseworkScene.instantiate()
				menus_layer.add_child(coursework_menu)
				if coursework_menu.has_signal("menu_closed"):
					coursework_menu.menu_closed.connect(_on_menu_closed)
			if coursework_menu:
				coursework_menu.open_coursework(player)
		&"ca_test":
			if ca_test_menu:
				const ProfileStore = preload("res://scripts/data/student_profile.gd")
				const AcademicCatalog = preload("res://scripts/data/academic_catalog.gd")
				var dept: String = ProfileStore.admitted_department
				var dept_info: Dictionary = AcademicCatalog.get_department(dept)
				var dept_courses: Array = dept_info.get("courses", [])
				var course_to_test: String = "GST 101"
				if room_id == &"lecture" and dept_courses.size() > 0:
					course_to_test = String(dept_courses[0].get("code", "GST 101"))
				elif room_id == &"lecture2" and dept_courses.size() > 1:
					course_to_test = String(dept_courses[1].get("code", "GST 102"))
				ca_test_menu.start_test(player, course_to_test)
		&"study_options":
			if study_menu:
				study_menu.open_menu(player)
		&"final_exam":
			_open_final_exam(player)


func _open_live_lecture(p: CharacterBody3D) -> void:
	if not lecture_session_dialog and menus_layer:
		lecture_session_dialog = LectureSessionScene.instantiate()
		menus_layer.add_child(lecture_session_dialog)
		if lecture_session_dialog.has_signal("dialog_closed"):
			lecture_session_dialog.dialog_closed.connect(_on_menu_closed)
	if lecture_session_dialog:
		lecture_session_dialog.start_lecture(p)


func _open_final_exam(p: CharacterBody3D) -> void:
	if not exam_hall_menu and menus_layer:
		exam_hall_menu = ExamHallScene.instantiate()
		menus_layer.add_child(exam_hall_menu)
		if exam_hall_menu.has_signal("menu_closed"):
			exam_hall_menu.menu_closed.connect(_on_menu_closed)
	if exam_hall_menu:
		exam_hall_menu.open_exam(p)


func _on_npc_dialogue_requested(npc: NPC3D, p: CharacterBody3D) -> void:
	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
	if npc and npc.character_name == "Madam Kikelomo" and mall_menu:
		mall_menu.open_mall(p)
		return
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
		&"mama_put", &"buka":
			_go_to_scene("res://scenes/rooms/mama_put.tscn")
		&"mall", &"bistro":
			_go_to_scene("res://scenes/rooms/campus_mall.tscn")
		&"stadium":
			_go_to_scene("res://scenes/rooms/football_stadium.tscn")
		&"chapel":
			_go_to_scene("res://scenes/rooms/chapel_hall.tscn")
		&"sub":
			_go_to_scene("res://scenes/rooms/sub_building.tscn")
		&"garden":
			_go_to_scene("res://scenes/rooms/campus_garden.tscn")
		&"salon":
			_go_to_scene("res://scenes/rooms/barbing_salon.tscn")
		&"gate":
			_go_to_scene("res://scenes/rooms/campus_gate.tscn")
		&"senate":
			_go_to_scene("res://scenes/rooms/senate_building.tscn")
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


func _process_network_puppets() -> void:
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
