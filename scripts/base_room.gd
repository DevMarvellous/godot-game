extends Node3D

## Base Room Controller for modular campus environments.
## Provides room entry points, door triggers, and camera setup.

@export var room_name: String = "Campus Room"
@export var room_id: StringName = &"courtyard"

@onready var player: Player3D = $Player3D
@onready var hud: HUD = $HUD
@onready var mobile_controls: CanvasLayer = $MobileControls
@onready var menus_layer: CanvasLayer = $MenusLayer

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
const HostelCookingScene = preload("res://scenes/hostel_cooking_dialog.tscn")
const BackpackScene = preload("res://scenes/backpack_menu.tscn")
const FridgeScene = preload("res://scenes/fridge_dialog.tscn")
const PenaltyScene = preload("res://scenes/penalty_mini_game.tscn")
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
var hostel_cooking_dialog: Control = null
var backpack_menu: Control = null
var fridge_dialog: Control = null
var penalty_menu: Control = null
var remote_player_nodes: Dictionary = {}
var active_ceiling_fans: Array[Node3D] = []
var _saved_room_lights: Dictionary = {}
var warden_panic_timer: float = 0.0
var is_warden_panic_active: bool = false
var is_contraband_hidden: bool = false
var warden_banner_ui: PanelContainer = null
var warden_countdown_label: Label = null
var autonomous_peers: Array[Dictionary] = []

@onready var food_menu: Control = $MenusLayer/FoodMenu if has_node("MenusLayer/FoodMenu") else null
@onready var study_menu: Control = $MenusLayer/StudyMenu if has_node("MenusLayer/StudyMenu") else null
@onready var ca_test_menu: Control = $MenusLayer/CATestMenu if has_node("MenusLayer/CATestMenu") else null
@onready var dialogue_menu: Control = $MenusLayer/DialogueMenu if has_node("MenusLayer/DialogueMenu") else null
@onready var summary_menu: Control = $MenusLayer/SummaryMenu if has_node("MenusLayer/SummaryMenu") else null


const NPC3DScene = preload("res://scenes/npc_3d.tscn")


func _ready() -> void:
	if player and hud:
		hud.connect_player_needs(player.needs_manager)
		player.needs_manager.player_passed_out.connect(_on_player_passed_out)
		if hud.has_signal("objective_clicked"):
			hud.objective_clicked.connect(_on_transit_requested)

	if mobile_controls and player:
		if mobile_controls.has_method("bind_player"):
			mobile_controls.bind_player(player)
		if mobile_controls.has_signal("transit_requested"):
			mobile_controls.transit_requested.connect(_on_transit_requested)
		if mobile_controls.has_signal("phone_requested"):
			mobile_controls.phone_requested.connect(_on_phone_requested)
		if mobile_controls.has_signal("chat_requested"):
			mobile_controls.chat_requested.connect(_on_chat_requested)
		if mobile_controls.has_signal("backpack_requested"):
			mobile_controls.backpack_requested.connect(func():
				_on_fixture_menu_requested(&"backpack", player)
			)

	if menus_layer:
		for child in menus_layer.get_children():
			if child is CanvasItem:
				child.visible = false
		if menus_layer.has_node("PhoneSystem"):
			phone_menu = menus_layer.get_node("PhoneSystem")
		else:
			phone_menu = PhoneScene.instantiate()
			menus_layer.add_child(phone_menu)
		if phone_menu and phone_menu.has_signal("phone_closed"):
			phone_menu.phone_closed.connect(_on_menu_closed)
		if phone_menu and phone_menu.has_signal("transit_requested"):
			phone_menu.transit_requested.connect(_on_transit_requested)

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
	_polish_room_decor_and_ambient_npcs()
	_connect_interactive_fixtures()
	_gather_ceiling_fans(self)

	# Web performance: disable real-time shadow passes to eliminate GPU draw call stutter
	if OS.has_feature("web") or OS.has_feature("mobile"):
		var room_lights: Array[Light3D] = []
		_gather_room_lights(self, room_lights)
		for l in room_lights:
			l.shadow_enabled = false

	if CampusEvents:
		if not CampusEvents.power_state_changed.is_connected(_on_power_state_changed):
			CampusEvents.power_state_changed.connect(_on_power_state_changed)
		if not CampusEvents.event_triggered.is_connected(_on_campus_event_triggered):
			CampusEvents.event_triggered.connect(_on_campus_event_triggered)
		_apply_power_state(CampusEvents.has_electricity)

	if room_id == &"lecture" or room_id == &"lecture2":
		PropBuilder3D.advance_quest_if_matching(2, player)
		if hud and hud.has_method("_refresh_objective_pill"):
			hud._refresh_objective_pill()

	_init_autonomous_coursemates()


func _polish_room_decor_and_ambient_npcs() -> void:
	if NetworkManager:
		NetworkManager.local_player_data["room"] = String(name)
		if not NetworkManager.chat_received.is_connected(_on_network_peer_chat):
			NetworkManager.chat_received.connect(_on_network_peer_chat)
		if not NetworkManager.emote_received.is_connected(_on_network_peer_emote):
			NetworkManager.emote_received.connect(_on_network_peer_emote)
		if not NetworkManager.money_transfer_received.is_connected(_on_network_money_transfer_received):
			NetworkManager.money_transfer_received.connect(_on_network_money_transfer_received)

	# 0. Architectural floor grid & dynamic Day/Night campus sun lighting
	PropBuilder3D.enhance_room_atmosphere(self)
	if not TimeSystem.minute_passed.is_connected(_on_room_Lighting_tick):
		TimeSystem.minute_passed.connect(_on_room_Lighting_tick)

	# 1. Declutter floating Label3D signs inside RoomDecor using proximity fade
	var decor: Node = get_node_or_null("RoomDecor")
	if decor:
		for child in decor.get_children():
			if child is Label3D and child.name != "RoomTitle3D":
				PropBuilder3D.configure_proximity_label(child as Label3D, 7.0, 22)

	# 2. Ensure every room has active, walking campus students so it never feels empty
	var npcs_root: Node3D = get_node_or_null("NPCs") as Node3D
	if not npcs_root:
		npcs_root = Node3D.new()
		npcs_root.name = "NPCs"
		add_child(npcs_root)

	if npcs_root.get_child_count() < 3:
		var templates: Array[Dictionary] = PropBuilder3D.get_ambient_npcs_for_room(room_id)
		for tpl in templates:
			var npc: NPC3D = NPC3DScene.instantiate() as NPC3D
			npc.character_name = String(tpl.get("name", "Student"))
			npc.character_role = String(tpl.get("role", "Course Mate"))
			npc.shirt_color = tpl.get("color", Color(0.2, 0.5, 0.8))
			npc.position = tpl.get("pos", Vector3(0, 0.1, 2.0))
			var lines_arr: Array[String] = []
			for l in tpl.get("lines", []):
				lines_arr.append(String(l))
			if not lines_arr.is_empty():
				npc.dialogues = lines_arr
			npcs_root.add_child(npc)


func _on_room_Lighting_tick() -> void:
	PropBuilder3D.update_room_day_night_lighting(self)


func _gather_ceiling_fans(node: Node) -> void:
	if node != self and node is Node3D and "fan" in node.name.to_lower():
		active_ceiling_fans.append(node as Node3D)
	for child in node.get_children():
		_gather_ceiling_fans(child)


func _process(delta: float) -> void:
	if CampusEvents and CampusEvents.has_electricity:
		for fan in active_ceiling_fans:
			if is_instance_valid(fan):
				fan.rotate_y(delta * 8.5)

	if is_warden_panic_active:
		warden_panic_timer -= delta
		if warden_countdown_label:
			warden_countdown_label.text = "🚨 HIDE BOILING RING! Warden knocks: %ds remaining!" % [int(ceil(warden_panic_timer))]
		if warden_panic_timer <= 0.0:
			_resolve_warden_caught()

	_process_network_puppets()
	_process_autonomous_coursemates(delta)


func _gather_room_lights(node: Node, result: Array[Light3D]) -> void:
	if node is Light3D:
		result.append(node as Light3D)
	for child in node.get_children():
		_gather_room_lights(child, result)


func _apply_power_state(has_power: bool) -> void:
	var lights: Array[Light3D] = []
	_gather_room_lights(self, lights)
	for light in lights:
		var light_path: String = String(light.get_path())
		if not _saved_room_lights.has(light_path):
			_saved_room_lights[light_path] = {
				"energy": light.light_energy,
				"color": light.light_color
			}
		if not has_power:
			# NEPA blackout: dark dim blue tint
			light.light_energy = 0.12
			light.light_color = Color(0.24, 0.35, 0.65)
		else:
			var orig: Dictionary = _saved_room_lights[light_path]
			light.light_energy = float(orig.get("energy", 1.0))
			light.light_color = orig.get("color", Color.WHITE)


func _on_power_state_changed(has_power: bool) -> void:
	_apply_power_state(has_power)
	if not has_power:
		if SoundManager:
			SoundManager.play_power_cut()
		if player and player.has_method("display_notification"):
			player.display_notification("⚡ NEPA TOOK LIGHT! Blackout in the hall!")
	else:
		if SoundManager:
			SoundManager.play_cheer()
		if player and player.has_method("display_notification"):
			player.display_notification("💡 \"UP NEPA!!\" Power restored across campus!")


func _on_campus_event_triggered(event_id: StringName, event_title: String, _event_desc: String) -> void:
	if (event_id == &"warden_inspection" or event_id == &"boiling_ring_panic") and room_id == &"hostel":
		_trigger_warden_panic()
	elif player and player.has_method("display_notification"):
		player.display_notification("%s" % event_title)


func _trigger_warden_panic() -> void:
	if room_id != &"hostel" or is_warden_panic_active:
		return
	is_warden_panic_active = true
	is_contraband_hidden = false
	warden_panic_timer = 20.0
	if SoundManager:
		SoundManager.play_knock()
	_create_warden_panic_ui()
	if player and player.has_method("display_notification"):
		player.display_notification("🚨 KNOCK KNOCK! 'Hall Warden on rounds! Open this door!'")


func _create_warden_panic_ui() -> void:
	if warden_banner_ui:
		warden_banner_ui.visible = true
		return

	warden_banner_ui = PanelContainer.new()
	warden_banner_ui.name = "WardenPanicBanner"
	warden_banner_ui.anchors_preset = Control.PRESET_CENTER_TOP
	warden_banner_ui.offset_left = -280.0
	warden_banner_ui.offset_top = 95.0
	warden_banner_ui.offset_right = 280.0
	warden_banner_ui.offset_bottom = 195.0

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.85, 0.15, 0.15, 0.94)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(1.0, 0.85, 0.25, 1.0)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 16.0
	style.content_margin_top = 10.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 10.0
	warden_banner_ui.add_theme_stylebox_override(&"panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 6)
	warden_banner_ui.add_child(vbox)

	warden_countdown_label = Label.new()
	warden_countdown_label.text = "🚨 HIDE BOILING RING! Warden knocks: 20s remaining!"
	warden_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warden_countdown_label.add_theme_font_size_override(&"font_size", 16)
	warden_countdown_label.add_theme_color_override(&"font_color", Color(1.0, 0.95, 0.9))
	vbox.add_child(warden_countdown_label)

	var sub_lbl := Label.new()
	sub_lbl.text = "⚡ Sprint to Wardrobe and press [E] or tap button below!"
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override(&"font_size", 12)
	sub_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.35))
	vbox.add_child(sub_lbl)

	var stow_btn := Button.new()
	stow_btn.text = "🛡️ STOW BOILING RING IN WARDROBE (TAP TO HIDE)"
	stow_btn.custom_minimum_size = Vector2(0, 34)
	stow_btn.focus_mode = Control.FOCUS_NONE
	stow_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	stow_btn.add_theme_font_size_override(&"font_size", 12)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.12, 0.65, 0.32, 0.95)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_right = 8
	btn_style.corner_radius_bottom_left = 8
	btn_style.content_margin_top = 4.0
	btn_style.content_margin_bottom = 4.0
	stow_btn.add_theme_stylebox_override(&"normal", btn_style)
	stow_btn.add_theme_stylebox_override(&"hover", btn_style)
	stow_btn.add_theme_stylebox_override(&"pressed", btn_style)
	stow_btn.pressed.connect(_resolve_warden_success)
	vbox.add_child(stow_btn)

	if menus_layer:
		menus_layer.add_child(warden_banner_ui)


func _resolve_warden_caught() -> void:
	is_warden_panic_active = false
	if is_instance_valid(warden_banner_ui):
		warden_banner_ui.visible = false
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_money(-500)
			needs.modify_faith(-10.0)
		if player.has_method("display_notification"):
			player.display_notification("⚠️ Warden spotted boiling ring! 'Careful with appliances! Warning given!' Faith -10, ₦500 fine.")


func _resolve_warden_success() -> void:
	if not is_warden_panic_active:
		return
	is_warden_panic_active = false
	is_contraband_hidden = true
	if is_instance_valid(warden_banner_ui):
		warden_banner_ui.visible = false
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_money(1500)
			needs.modify_faith(25.0)
		if player.has_method("play_celebrate_animation"):
			player.play_celebrate_animation("🎖️ WARDEN COMMENDATION! +₦1,500")
		if player.has_method("display_notification"):
			player.display_notification("🛡️ Contraband stowed! Warden inspects: 'Very tidy Christian scholar! Commendation awarded!' +₦1,500, +25 Faith!")


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
		if ProfileStore.owned_upgrades.has("mini_fridge") and not decor.has_node("MiniFridgeMesh") and not decor.has_node("HostelMiniFridgeMesh"):
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


func _close_all_active_modals(except_node: Node = null) -> void:
	if menus_layer:
		for child in menus_layer.get_children():
			if child != except_node and child is CanvasItem and child.visible:
				child.visible = false
	if hud and "tasks_sheet" in hud and is_instance_valid(hud.tasks_sheet):
		hud.tasks_sheet.visible = false
	if mobile_controls:
		if "transit_sheet" in mobile_controls and is_instance_valid(mobile_controls.transit_sheet):
			mobile_controls.transit_sheet.visible = false
		if "emote_sheet" in mobile_controls and is_instance_valid(mobile_controls.emote_sheet):
			mobile_controls.emote_sheet.visible = false


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	_close_all_active_modals()
	if is_warden_panic_active and (menu_type == &"wardrobe" or menu_type == &"study"):
		_resolve_warden_success()

	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO

	if menu_type == &"food" and food_menu:
		PropBuilder3D.advance_quest_if_matching(4, p)
		food_menu.open_menu(p)
	elif menu_type == &"study":
		PropBuilder3D.advance_quest_if_matching(3, p)
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
		PropBuilder3D.advance_quest_if_matching(3, p)
		_open_live_lecture(p)
	elif menu_type == &"exam":
		_open_final_exam(p)
	elif menu_type == &"salon" and salon_menu:
		salon_menu.open_salon(p)
	elif menu_type == &"mall" and mall_menu:
		mall_menu.open_mall(p)
	elif (menu_type == &"wardrobe" or menu_type == &"mall") and wardrobe_menu:
		PropBuilder3D.advance_quest_if_matching(0, p)
		wardrobe_menu.open_wardrobe(p)
	elif menu_type == &"snooker":
		if not snooker_menu and menus_layer:
			snooker_menu = SnookerScene.instantiate()
			menus_layer.add_child(snooker_menu)
			if snooker_menu.has_signal("game_closed"):
				snooker_menu.game_closed.connect(func(_winnings): _on_menu_closed())
		if snooker_menu:
			snooker_menu.open_game(p)
	elif menu_type == &"penalty":
		if not penalty_menu and menus_layer:
			penalty_menu = PenaltyScene.instantiate()
			menus_layer.add_child(penalty_menu)
			if penalty_menu.has_signal("dialog_closed"):
				penalty_menu.dialog_closed.connect(_on_menu_closed)
		if penalty_menu:
			penalty_menu.open_penalty(p)
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
					_go_to_scene(target_scene, true)
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
	elif menu_type == &"hostel_cooking":
		if not hostel_cooking_dialog and menus_layer:
			hostel_cooking_dialog = HostelCookingScene.instantiate()
			menus_layer.add_child(hostel_cooking_dialog)
			if hostel_cooking_dialog.has_signal("dialog_closed"):
				hostel_cooking_dialog.dialog_closed.connect(_on_menu_closed)
		if hostel_cooking_dialog:
			hostel_cooking_dialog.open_cooking(p)
	elif menu_type == &"backpack":
		if not backpack_menu and menus_layer:
			backpack_menu = BackpackScene.instantiate()
			menus_layer.add_child(backpack_menu)
			if backpack_menu.has_signal("menu_closed"):
				backpack_menu.menu_closed.connect(_on_menu_closed)
		if backpack_menu:
			backpack_menu.open_menu(p)
	elif menu_type == &"fridge":
		if not fridge_dialog and menus_layer:
			fridge_dialog = FridgeScene.instantiate()
			menus_layer.add_child(fridge_dialog)
			if fridge_dialog.has_signal("fridge_closed"):
				fridge_dialog.fridge_closed.connect(_on_menu_closed)
		if fridge_dialog:
			fridge_dialog.open_fridge(p)


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
	_close_all_active_modals()
	PropBuilder3D.advance_quest_if_matching(1, p if p else player)
	if hud and hud.has_method("_refresh_objective_pill"):
		hud._refresh_objective_pill()
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
		if phone_menu.visible:
			phone_menu.close_phone()
			return
		_close_all_active_modals(phone_menu)
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO
		phone_menu.open_phone(player)


func _on_chat_requested() -> void:
	if chat_menu and player:
		if chat_menu.visible:
			chat_menu.close_chat()
			return
		_close_all_active_modals(chat_menu)
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
		&"tech_hub":
			_go_to_scene("res://scenes/rooms/tech_hub.tscn")
		&"convocation":
			_go_to_scene("res://scenes/rooms/convocation_hall.tscn")
		&"atm":
			_go_to_scene("res://scenes/main.tscn")


func _go_to_scene(scene_path: String, fare_already_paid: bool = false) -> void:
	if get_tree().current_scene.scene_file_path == scene_path:
		if player:
			# If on Task 1 (Wardrobe), walk straight to Wardrobe
			if PropBuilder3D.onboarding_quest_step == 0:
				var fixtures_w: Node = get_node_or_null("WorldObjects")
				if fixtures_w:
					for child in fixtures_w.get_children():
						if child is CampusObject3D and child.object_type == CampusObject3D.ObjectType.WARDROBE:
							player._walk_to_and_interact(child)
							return
			# If on Task 2 (Greet Roommate), walk straight to first NPC
			elif PropBuilder3D.onboarding_quest_step == 1:
				var npcs_w: Node = get_node_or_null("NPCs")
				if npcs_w and npcs_w.get_child_count() > 0:
					var first_npc: Node = npcs_w.get_child(0)
					var area: Interactable3D = first_npc.get_node_or_null("InteractArea") as Interactable3D
					if area:
						player._walk_to_and_interact(area)
						return
			var fixtures: Node = get_node_or_null("WorldObjects")
			if fixtures and fixtures.get_child_count() > 0:
				var target_type: int = -1
				match PropBuilder3D.onboarding_quest_step:
					0: target_type = CampusObject3D.ObjectType.WARDROBE
					3, 6: target_type = CampusObject3D.ObjectType.DESK
					4: target_type = CampusObject3D.ObjectType.CAFETERIA
					5: target_type = CampusObject3D.ObjectType.STADIUM_SPORTS
					7: target_type = CampusObject3D.ObjectType.HUSTLE_DESK
					8: target_type = CampusObject3D.ObjectType.SUB_ARCADE
					9: target_type = CampusObject3D.ObjectType.LIBRARY_CARREL
					10: target_type = CampusObject3D.ObjectType.CHAPEL_WORSHIP
					11: target_type = CampusObject3D.ObjectType.SALON_CHAIR
					12: target_type = CampusObject3D.ObjectType.HOSTEL_KITCHEN
					13: target_type = CampusObject3D.ObjectType.SENATE_REGISTRY

				if target_type != -1:
					for child in fixtures.get_children():
						if child is CampusObject3D and child.object_type == target_type:
							player._walk_to_and_interact(child)
							return

				for child in fixtures.get_children():
					if child is CampusObject3D and child.object_type != CampusObject3D.ObjectType.DOOR_EXIT and child.object_type != CampusObject3D.ObjectType.SHUTTLE_STOP:
						if player.has_method("_walk_to_and_interact"):
							player._walk_to_and_interact(child)
							return
			if player.has_method("display_notification"):
				player.display_notification("Already here! Tap any highlighted object.")
		return

	# Campus Keke Shuttle fare (₦100) except walking to hostel.
	# Skipped when the shuttle stop dialog has already charged the fare.
	if fare_already_paid:
		pass
	elif player and scene_path != "res://scenes/rooms/hostel_room.tscn":
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

	RoomManager.change_room_to_path(scene_path, "", &"", true)


func _on_menu_closed() -> void:
	if player:
		player.set_physics_process(true)
	if hud and hud.has_method("_refresh_objective_pill"):
		hud._refresh_objective_pill()


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
				var pos_init: Vector3 = p_data.get("pos", Vector3(1.5, 0.1, 1.5))
				puppet.position = pos_init
				add_child(puppet)
				if puppet.name_label:
					PropBuilder3D.configure_proximity_label(puppet.name_label, 8.0, 22)
				if puppet.has_method("apply_full_drip") and p_data.has("gender"):
					puppet.apply_full_drip(
						String(p_data.get("gender", "Male")),
						int(p_data.get("skin_idx", 1)),
						int(p_data.get("hair_idx", 0)),
						int(p_data.get("shirt_idx", 0)),
						int(p_data.get("trouser_idx", 0)),
						String(p_data.get("clout_rank", ""))
					)
				elif p_data.has("shirt_col"):
					puppet.apply_appearance(
						Color(0.35, 0.22, 0.14),
						p_data.get("shirt_col", Color(0.2, 0.6, 0.4)),
						p_data.get("trouser_col", Color(0.15, 0.18, 0.24)),
						Color(0.08, 0.08, 0.08)
					)
				if puppet.has_signal("peer_interacted"):
					puppet.peer_interacted.connect(_on_network_puppet_interacted)
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


func _on_network_peer_chat(_sender_name: String, msg: String, peer_id: int) -> void:
	if remote_player_nodes.has(peer_id):
		var puppet_node: NetworkPlayer = remote_player_nodes[peer_id]
		if is_instance_valid(puppet_node) and puppet_node.has_method("show_chat"):
			puppet_node.show_chat(msg)


func _on_network_peer_emote(peer_id: int, emote_name: String) -> void:
	if remote_player_nodes.has(peer_id):
		var puppet_node: NetworkPlayer = remote_player_nodes[peer_id]
		if is_instance_valid(puppet_node) and puppet_node.has_method("play_emote"):
			puppet_node.play_emote(emote_name)


func _on_network_money_transfer_received(sender_name: String, amount: int, note: String) -> void:
	if not player:
		return
	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	if needs:
		needs.modify_money(amount)
		needs.modify_fun(10.0)
	if SoundManager:
		SoundManager.play_cheer()
	if player.has_method("spawn_floating_stat"):
		player.spawn_floating_stat("+₦%d from %s!" % [amount, sender_name], Color(0.25, 0.98, 0.55))
	if player.has_method("display_notification"):
		player.display_notification("💸 CREDIT ALERT! Received +₦%d from %s (%s) via CampusPay!" % [amount, sender_name, note])


func _on_network_puppet_interacted(puppet: NetworkPlayer, p: CharacterBody3D) -> void:
	if not menus_layer or not is_instance_valid(puppet):
		return
	if SoundManager:
		SoundManager.play_click()

	if menus_layer.has_node("NetworkPeerModal"):
		menus_layer.get_node("NetworkPeerModal").queue_free()

	var modal := Control.new()
	modal.name = "NetworkPeerModal"
	modal.set_anchors_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0, 0, 0, 0.72)
	modal.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	modal.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 0)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.08, 0.14, 0.20, 0.98)
	st.border_width_left = 3
	st.border_width_top = 3
	st.border_width_right = 3
	st.border_width_bottom = 3
	st.border_color = Color(0.25, 0.90, 0.55, 0.95)
	st.corner_radius_top_left = 18
	st.corner_radius_top_right = 18
	st.corner_radius_bottom_left = 18
	st.corner_radius_bottom_right = 18
	st.content_margin_left = 22.0
	st.content_margin_top = 18.0
	st.content_margin_right = 22.0
	st.content_margin_bottom = 20.0
	panel.add_theme_stylebox_override(&"panel", st)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 10)
	panel.add_child(vbox)

	# Header Row
	var top_row := HBoxContainer.new()
	vbox.add_child(top_row)

	var title_lbl := Label.new()
	title_lbl.text = "🟢 ONLINE COURSEMATE: %s" % puppet.student_name.to_upper()
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override(&"font_size", 17)
	title_lbl.add_theme_color_override(&"font_color", Color(0.35, 0.98, 0.62))
	top_row.add_child(title_lbl)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(46, 46)
	close_btn.add_theme_font_size_override(&"font_size", 18)
	close_btn.pressed.connect(func():
		modal.queue_free()
		_on_menu_closed()
	)
	top_row.add_child(close_btn)

	# Student ID Info Card
	var id_lbl := Label.new()
	id_lbl.text = "🪪 Status: Live Connected Student • %s\n🎓 Level: 100L Undergraduate • Honours Candidate" % room_name
	id_lbl.add_theme_font_size_override(&"font_size", 13)
	id_lbl.add_theme_color_override(&"font_color", Color(0.82, 0.90, 0.98))
	vbox.add_child(id_lbl)

	var make_action_btn := func(txt: String, bg_col: Color, callback: Callable) -> Button:
		var b := Button.new()
		b.text = txt
		b.custom_minimum_size = Vector2(0, 48)
		b.add_theme_font_size_override(&"font_size", 15)
		var bst := StyleBoxFlat.new()
		bst.bg_color = bg_col
		bst.border_width_left = 1
		bst.border_width_top = 1
		bst.border_width_right = 1
		bst.border_width_bottom = 1
		bst.border_color = Color(1.0, 0.88, 0.35, 0.65)
		bst.corner_radius_top_left = 10
		bst.corner_radius_top_right = 10
		bst.corner_radius_bottom_left = 10
		bst.corner_radius_bottom_right = 10
		b.add_theme_stylebox_override(&"normal", bst)
		b.pressed.connect(callback)
		return b

	# 1. Greet & Banter
	vbox.add_child(make_action_btn.call("👋 Greet & Campus Banter (+8% Fun)", Color(0.12, 0.38, 0.26, 0.95), func():
		if p and p.has_node("NeedsManager"):
			p.get_node("NeedsManager").modify_fun(8.0)
		if NetworkManager:
			NetworkManager.broadcast_emote("wave")
			NetworkManager.broadcast_chat("How far %s! Good to see you!" % puppet.student_name)
		if is_instance_valid(puppet):
			puppet.play_emote("wave")
			puppet.show_chat("My guy! How semester dey go? 👋")
		if p and p.has_method("spawn_floating_stat"):
			p.spawn_floating_stat("👋 +8% Fun (Coursemate Banter)", Color(0.35, 0.95, 0.6))
		modal.queue_free()
		_on_menu_closed()
	))

	# 2. Afrobeat Dance Party
	vbox.add_child(make_action_btn.call("🔥 Afrobeat Dance Party: Gbese! (+15% Fun)", Color(0.48, 0.22, 0.10, 0.95), func():
		if p and p.has_node("NeedsManager"):
			p.get_node("NeedsManager").modify_fun(15.0)
		if p and p.has_method("play_shaku_emote"):
			p.play_shaku_emote()
		if NetworkManager:
			NetworkManager.broadcast_emote("shaku")
		if is_instance_valid(puppet):
			puppet.play_emote("shaku")
			puppet.show_chat("Oya gbese! Gbe body e! 🔥💃")
		if p and p.has_method("spawn_floating_stat"):
			p.spawn_floating_stat("🔥 +15% Fun (Dance Vibez!)", Color(1.0, 0.78, 0.22))
		modal.queue_free()
		_on_menu_closed()
	))

	# 3. Quick Study Group
	vbox.add_child(make_action_btn.call("📚 Share Past Questions & Notes (+12% Academic, -8% Energy)", Color(0.14, 0.26, 0.45, 0.95), func():
		if p and p.has_node("NeedsManager"):
			var nm = p.get_node("NeedsManager")
			nm.modify_academic(12.0)
			nm.modify_energy(-8.0)
		if is_instance_valid(puppet):
			puppet.play_emote("study")
			puppet.show_chat("Check this GST past question, e dey always come out! 📚")
		if p and p.has_method("spawn_floating_stat"):
			p.spawn_floating_stat("📚 +12% Academic (Peer Study Group)", Color(0.4, 0.85, 1.0))
		modal.queue_free()
		_on_menu_closed()
	))

	# 4. Challenge to Snooker at SUB
	vbox.add_child(make_action_btn.call("🎱 Challenge to 9-Ball Snooker at SUB Arcade", Color(0.28, 0.14, 0.38, 0.95), func():
		if is_instance_valid(puppet):
			puppet.show_chat("Oya let's go SUB Snooker table! Ready to lose? 🎱")
		modal.queue_free()
		_on_menu_closed()
		_on_fixture_menu_requested(&"snooker", p)
	))

	# 5. CampusPay P2P Money Transfer (Dash ₦1,000)
	vbox.add_child(make_action_btn.call("💸 Dash ₦1,000 via CampusPay (+12 Faith & Big Boy Clout)", Color(0.08, 0.42, 0.25, 0.95), func():
		var nm: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager if p else null
		if not nm or nm.money < 1000:
			if p and p.has_method("display_notification"):
				p.display_notification("⚠️ Insufficient Wallet Balance! You need at least ₦1,000 to transfer.")
			return
		nm.modify_money(-1000)
		nm.modify_faith(12.0)
		nm.modify_fun(10.0)
		if SoundManager:
			SoundManager.play_cheer()
		if NetworkManager:
			NetworkManager.broadcast_money_transfer(puppet.student_name, 1000, "Coursemate Dash")
		if is_instance_valid(puppet):
			puppet.play_emote("celebrate")
			puppet.show_chat("Omo! Alert of +₦1,000 don enter! Respect Boss! 🙌💸")
		if p and p.has_method("display_notification"):
			p.display_notification("💸 Transferred ₦1,000 to %s via CampusPay! (+12 Faith)" % puppet.student_name)
		modal.queue_free()
		_on_menu_closed()
	))

	# 6. Stadium Penalty Shootout Contest
	if room_id == &"stadium":
		vbox.add_child(make_action_btn.call("⚽ Challenge to Penalty Shootout Contest!", Color(0.10, 0.48, 0.25, 0.95), func():
			if is_instance_valid(puppet):
				puppet.show_chat("Oya penalty shootout! Make we see your shooting power! ⚽")
			modal.queue_free()
			_on_menu_closed()
			_on_fixture_menu_requested(&"penalty", p)
		))

	# 7. Beg for Urgent 2K / Pocket Money Assistance
	vbox.add_child(make_action_btn.call("🤝 Beg for Urgent 2K / Pocket Money Assistance", Color(0.42, 0.30, 0.12, 0.95), func():
		var nm: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager if p else null
		if nm:
			if nm.money < 2500:
				nm.modify_money(1000)
				nm.modify_faith(15.0)
				nm.modify_fun(10.0)
				if SoundManager:
					SoundManager.play_cheer()
				if is_instance_valid(puppet):
					puppet.play_emote("celebrate")
					puppet.show_chat("No wahala my guy! Take ₦1,000 make sapa no finish you! We rise by lifting others! 🤝💸")
				if p and p.has_method("display_notification"):
					p.display_notification("🤝 %s sent you +₦1,000 allowance via CampusPay! (+15 Faith)" % puppet.student_name)
			else:
				if is_instance_valid(puppet):
					puppet.play_emote("shaku")
					puppet.show_chat("Chairman! With all the money inside your account you still dey find urgent 2k? Big man flex! 😂")
				if p and p.has_method("display_notification"):
					p.display_notification("😂 %s: 'Big boy! Your account balance is heavy, go buy us cold drinks!'")
		modal.queue_free()
		_on_menu_closed()
	))

	menus_layer.add_child(modal)


func _init_autonomous_coursemates() -> void:
	if autonomous_peers.size() > 0:
		return
	var peer_configs: Array[Dictionary] = _get_autonomous_peer_configs_for_room()
	for i in range(peer_configs.size()):
		var cfg: Dictionary = peer_configs[i]
		var puppet: NetworkPlayer = NetworkPlayerScene.instantiate() as NetworkPlayer
		puppet.peer_id = -(1001 + i)
		puppet.student_name = String(cfg.get("name", "Coursemate"))
		var spawn_pos: Vector3 = cfg.get("pos", Vector3(1.0, 0.1, 1.0))
		puppet.position = spawn_pos
		add_child(puppet)

		var gender: String = String(cfg.get("gender", "Male"))
		var skin_idx: int = int(cfg.get("skin_idx", 1))
		var hair_idx: int = int(cfg.get("hair_idx", 0))
		var shirt_idx: int = int(cfg.get("shirt_idx", 0))
		var tr_idx: int = int(cfg.get("trouser_idx", 0))
		var dept: String = String(cfg.get("dept", "100L"))
		puppet.apply_full_drip(gender, skin_idx, hair_idx, shirt_idx, tr_idx, dept)
		if puppet.name_label:
			puppet.name_label.text = "%s\n🎓 [%s]" % [puppet.student_name, dept]
			puppet.name_label.modulate = Color(0.40, 0.88, 1.0)
			PropBuilder3D.configure_proximity_label(puppet.name_label, 8.5, 22)

		if puppet.has_signal("peer_interacted"):
			puppet.peer_interacted.connect(_on_network_puppet_interacted)

		var lines_arr: Array[String] = []
		for l in cfg.get("banter", []):
			lines_arr.append(String(l))

		autonomous_peers.append({
			"node": puppet,
			"home_pos": spawn_pos,
			"target_pos": spawn_pos,
			"timer": randf_range(3.5, 8.0),
			"is_walking": false,
			"banter": lines_arr,
			"role": String(cfg.get("role", "Coursemate"))
		})


func _process_autonomous_coursemates(delta: float) -> void:
	for entry in autonomous_peers:
		var node: NetworkPlayer = entry.get("node")
		if not is_instance_valid(node):
			continue
		var is_walking: bool = bool(entry.get("is_walking", false))
		var target: Vector3 = entry.get("target_pos", node.global_position)

		if is_walking:
			var curr_pos: Vector3 = node.global_position
			var diff: Vector3 = target - curr_pos
			diff.y = 0.0
			var dist: float = diff.length()
			if dist < 0.25:
				entry["is_walking"] = false
				entry["timer"] = randf_range(5.0, 12.0)
				node.update_network_transform(target, node.visual_root.rotation.y if node.visual_root else 0.0, false)
				var emotes: Array[String] = ["wave", "shaku", "flex", "celebrate", "sit", "study"]
				if randf() > 0.4:
					node.play_emote(emotes[randi() % emotes.size()])
			else:
				var move_dir: Vector3 = diff.normalized()
				var next_pos: Vector3 = curr_pos + move_dir * (2.2 * delta)
				var rot_y: float = atan2(-move_dir.x, -move_dir.z)
				node.global_position = next_pos
				node.update_network_transform(next_pos, rot_y, true)
		else:
			var t: float = float(entry.get("timer", 5.0)) - delta
			entry["timer"] = t
			if t <= 0.0:
				entry["timer"] = randf_range(6.0, 14.0)
				var roll: float = randf()
				if roll < 0.45:
					var home: Vector3 = entry.get("home_pos", node.global_position)
					var angle: float = randf() * TAU
					var r: float = randf_range(2.0, 5.0)
					var new_dest: Vector3 = home + Vector3(cos(angle) * r, 0.0, sin(angle) * r)
					new_dest.x = clampf(new_dest.x, -14.0, 14.0)
					new_dest.z = clampf(new_dest.z, -10.0, 10.0)
					entry["target_pos"] = new_dest
					entry["is_walking"] = true
				elif roll < 0.75:
					var lines: Array = entry.get("banter", [])
					if not lines.is_empty():
						var line: String = lines[randi() % lines.size()]
						node.show_chat(line)
				else:
					var emotes: Array[String] = ["wave", "shaku", "celebrate", "flex"]
					node.play_emote(emotes[randi() % emotes.size()])


func _get_autonomous_peer_configs_for_room() -> Array[Dictionary]:
	match room_id:
		&"stadium":
			return [
				{
					"name": "Tunde", "gender": "Male", "dept": "CSC 200L",
					"role": "Computing FC Winger", "pos": Vector3(-5.0, 0.1, 0.0),
					"skin_idx": 1, "hair_idx": 1, "shirt_idx": 1, "trouser_idx": 0,
					"banter": [
						"Coach dey drill us today o! 10 laps round track!",
						"Who dey breathe?! Computing FC all the way!",
						"I need cold PowerPro isotonic drink after this sprint!",
						"The pitch grass is so fresh! Premier league standard!"
					]
				},
				{
					"name": "Folake", "gender": "Female", "dept": "MASS COMM 100L",
					"role": "Campus Sports Blogger", "pos": Vector3(-15.5, 0.7, -2.0),
					"skin_idx": 2, "hair_idx": 2, "shirt_idx": 2, "trouser_idx": 1,
					"banter": [
						"TikTok live stream is buzzing! 2,000 views on Dean's Cup!",
						"These new stadium bleachers look magnificent!",
						"Computing FC must carry the Dean's Cup this year!",
						"Dugout seats are so comfy, coach is enjoying!"
					]
				},
				{
					"name": "Korede", "gender": "Male", "dept": "ENG 300L",
					"role": "Penalty Specialist", "pos": Vector3(2.5, 0.1, -4.5),
					"skin_idx": 0, "hair_idx": 0, "shirt_idx": 3, "trouser_idx": 0,
					"banter": [
						"Make we take penalty shootout! If you score, I owe you cold Malt!",
						"Captain Emeka think say he fit save my curve shot!",
						"Oya let's dance Gbese on the center pitch!"
					]
				}
			]
		&"library":
			return [
				{
					"name": "Chinedu", "gender": "Male", "dept": "MEDICINE 200L",
					"role": "Medical Scholar", "pos": Vector3(-2.8, 0.1, -1.5),
					"skin_idx": 0, "hair_idx": 0, "shirt_idx": 1, "trouser_idx": 0,
					"banter": [
						"Quiet in the library please, Anatomy 201 no be beans!",
						"Study carrels give 2x CGPA focus.",
						"Have you reviewed the 2024 past questions?"
					]
				},
				{
					"name": "Amina", "gender": "Female", "dept": "LAW 100L",
					"role": "Law Undergrad", "pos": Vector3(2.5, 0.1, 1.5),
					"skin_idx": 2, "hair_idx": 2, "shirt_idx": 0, "trouser_idx": 1,
					"banter": [
						"Constitutional Law assignment is 15 pages!",
						"My laptop battery is low, thank God for library sockets.",
						"Success requires discipline and midnight candles!"
					]
				}
			]
		&"lecture", &"lecture2":
			return [
				{
					"name": "Ibrahim", "gender": "Male", "dept": "CSC 100L",
					"role": "Course Rep", "pos": Vector3(-2.2, 0.1, 0.0),
					"skin_idx": 1, "hair_idx": 0, "shirt_idx": 0, "trouser_idx": 0,
					"banter": [
						"Lecturer is coming with test papers!",
						"Sit near the front row for maximum comprehension.",
						"Who has extra pen for attendance sheet?"
					]
				},
				{
					"name": "Blessing", "gender": "Female", "dept": "ACCOUNTING 200L",
					"role": "Honours Scholar", "pos": Vector3(2.0, 0.1, 0.5),
					"skin_idx": 0, "hair_idx": 3, "shirt_idx": 2, "trouser_idx": 0,
					"banter": [
						"Balance sheet must balance by fire by force!",
						"Take good lecture notes, CA test is 30 marks!"
					]
				}
			]
		&"mama_put":
			return [
				{
					"name": "Damilola", "gender": "Male", "dept": "ECONOMICS 300L",
					"role": "Campus Foodie", "pos": Vector3(-1.8, 0.1, 1.0),
					"skin_idx": 2, "hair_idx": 1, "shirt_idx": 3, "trouser_idx": 0,
					"banter": [
						"Mama Cashout Jollof + fried plantain is life-saving!",
						"Sapa was dealing with me until I came here.",
						"Let's link up for a cold drink!"
					]
				},
				{
					"name": "Zainab", "gender": "Female", "dept": "MASS COMM 200L",
					"role": "Lifestyle Influencer", "pos": Vector3(2.0, 0.1, -1.0),
					"skin_idx": 1, "hair_idx": 2, "shirt_idx": 1, "trouser_idx": 1,
					"banter": [
						"Nothing beats hot Amala with Gbegiri & Ewedu!",
						"CampusPay makes paying for food so fast.",
						"Eat well so you have energy for afternoon class!"
					]
				}
			]
		&"hostel":
			return [
				{
					"name": "Tobi", "gender": "Male", "dept": "100L Roommate",
					"role": "Hostel Guy", "pos": Vector3(1.5, 0.1, 1.0),
					"skin_idx": 1, "hair_idx": 1, "shirt_idx": 0, "trouser_idx": 0,
					"banter": [
						"NEPA brought light! Charge your power bank quick!",
						"Watch out for hall warden inspections!",
						"Who used my boiling ring without asking?!"
					]
				},
				{
					"name": "Ngozi", "gender": "Female", "dept": "200L Roommate",
					"role": "Hostel Roommate", "pos": Vector3(-1.5, 0.1, 1.8),
					"skin_idx": 0, "hair_idx": 2, "shirt_idx": 2, "trouser_idx": 1,
					"banter": [
						"I bought extra noodles in the fridge!",
						"Let's review past questions before evening gist!"
					]
				}
			]
		_:
			return [
				{
					"name": "Sadiq", "gender": "Male", "dept": "ELECT ENG 400L",
					"role": "Faculty Senator", "pos": Vector3(2.0, 0.1, 2.5),
					"skin_idx": 2, "hair_idx": 1, "shirt_idx": 0, "trouser_idx": 0,
					"banter": [
						"Aluta Continua! Congress holds this Friday at the SUB!",
						"Danfo bus shuttle just brought 40 students from town.",
						"Keep your CGPA above 4.50 to claim Senate scholarship!"
					]
				},
				{
					"name": "Funke", "gender": "Female", "dept": "BIOCHEM 200L",
					"role": "Fashion Rep", "pos": Vector3(-2.5, 0.1, -2.0),
					"skin_idx": 1, "hair_idx": 3, "shirt_idx": 2, "trouser_idx": 1,
					"banter": [
						"Campus drip is 10/10 today! Rate my fit!",
						"I'm heading to the Mall to buy new sunglasses.",
						"Don't forget to submit assignment before 4 PM!"
					]
				}
			]
