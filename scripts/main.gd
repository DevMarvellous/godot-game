class_name Main
extends Node3D

## Main 3D Campus World scene.
## Connects 3D Player, HUD, Mobile Touch Controls, fixtures, and interactive modal menus.

@onready var player: Player3D = $Player3D
@onready var hud: HUD = $HUD
@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment = $WorldEnvironment

@onready var hostel_bed: CampusObject3D = $WorldObjects/HostelBed
@onready var study_desk: CampusObject3D = $WorldObjects/StudyDesk
@onready var cafeteria: CampusObject3D = $WorldObjects/Cafeteria
@onready var chapel: CampusObject3D = $WorldObjects/Chapel
@onready var atm: CampusObject3D = $WorldObjects/ATM

@onready var food_menu: Control = $MenusLayer/FoodMenu
@onready var study_menu: Control = $MenusLayer/StudyMenu
@onready var summary_menu: Control = $MenusLayer/SummaryMenu
@onready var mobile_controls: CanvasLayer = $MobileControls


func _ready() -> void:
	if player and hud:
		hud.connect_player_needs(player.needs_manager)
		player.needs_manager.player_passed_out.connect(_on_player_passed_out)

	# Connect mobile touch controls
	if mobile_controls and player:
		if mobile_controls.has_method("bind_player"):
			mobile_controls.bind_player(player)
		if mobile_controls.has_signal("transit_requested"):
			mobile_controls.transit_requested.connect(_on_transit_requested)

	# Connect day/night lighting
	TimeSystem.minute_passed.connect(_update_day_night_lighting)
	_update_day_night_lighting()

	# Connect interactive menus
	if cafeteria:
		cafeteria.menu_requested.connect(_on_menu_requested)
	if study_desk:
		study_desk.menu_requested.connect(_on_menu_requested)

	if food_menu:
		food_menu.menu_closed.connect(_on_menu_closed)
	if study_menu:
		study_menu.menu_closed.connect(_on_menu_closed)

	# Connect Semester Manager daily summary & graduation results
	if SemesterManager:
		SemesterManager.day_ended.connect(_on_day_ended)
		SemesterManager.semester_finished.connect(_on_semester_finished)
	if summary_menu:
		summary_menu.summary_closed.connect(_on_summary_closed)

	# Configure 3D world objects with distinct colors & types
	_setup_3d_object(hostel_bed, CampusObject3D.ObjectType.BED, "Hostel Bed", Color(0.2, 0.45, 0.85))
	_setup_3d_object(study_desk, CampusObject3D.ObjectType.DESK, "Lecture & Study Desk", Color(0.65, 0.42, 0.22))
	_setup_3d_object(cafeteria, CampusObject3D.ObjectType.CAFETERIA, "Buka / Cafeteria", Color(0.9, 0.45, 0.15))
	_setup_3d_object(chapel, CampusObject3D.ObjectType.FELLOWSHIP, "Chapel Altar", Color(0.85, 0.75, 0.2))
	_setup_3d_object(atm, CampusObject3D.ObjectType.ATM, "Campus ATM", Color(0.18, 0.75, 0.35))


func _on_transit_requested(dest: StringName) -> void:
	if not player:
		return

	var target_pos: Vector3 = Vector3.ZERO
	var dest_title: String = ""

	match dest:
		&"hostel":
			if hostel_bed:
				target_pos = hostel_bed.global_position + Vector3(0, 0.1, 2.8)
				dest_title = "Hostel Room"
		&"class":
			if study_desk:
				target_pos = study_desk.global_position + Vector3(0, 0.1, 2.8)
				dest_title = "Study Hall & Lectures"
		&"buka":
			if cafeteria:
				target_pos = cafeteria.global_position + Vector3(0, 0.1, 2.8)
				dest_title = "Buka Food Court"
		&"chapel":
			if chapel:
				target_pos = chapel.global_position + Vector3(0, 0.1, 2.8)
				dest_title = "Fellowship Chapel"
		&"atm":
			if atm:
				target_pos = atm.global_position + Vector3(0, 0.1, 2.8)
				dest_title = "Campus ATM"

	if dest_title != "":
		player.global_position = target_pos
		player.velocity = Vector3.ZERO
		TimeSystem.advance_minutes(5) # Walking travel time across campus
		if player.has_method("display_notification"):
			player.display_notification("Arrived at %s! (5m walk)" % dest_title)


func _on_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if player:
		player.set_physics_process(false)
		player.velocity = Vector3.ZERO

	if menu_type == &"food" and food_menu:
		food_menu.open_menu(p)
	elif menu_type == &"study" and study_menu:
		study_menu.open_menu(p)


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


func _update_day_night_lighting() -> void:
	if not sun or not world_env:
		return

	var hour: float = TimeSystem.get_hour_float()

	if hour >= 6.0 and hour < 8.0:
		var t: float = (hour - 6.0) / 2.0
		sun.light_color = Color(1.0, 0.72, 0.45).lerp(Color(1.0, 0.95, 0.88), t)
		sun.light_energy = lerpf(0.3, 1.1, t)
		sun.rotation_degrees.x = lerpf(-15.0, -45.0, t)
	elif hour >= 8.0 and hour < 17.0:
		sun.light_color = Color(1.0, 0.96, 0.9)
		sun.light_energy = 1.15
		sun.rotation_degrees.x = -50.0
	elif hour >= 17.0 and hour < 19.5:
		var t: float = (hour - 17.0) / 2.5
		sun.light_color = Color(1.0, 0.96, 0.9).lerp(Color(0.98, 0.45, 0.2), t)
		sun.light_energy = lerpf(1.15, 0.25, t)
		sun.rotation_degrees.x = lerpf(-50.0, -10.0, t)
	else:
		sun.light_color = Color(0.35, 0.48, 0.8)
		sun.light_energy = 0.18
		sun.rotation_degrees.x = -35.0


func _on_player_passed_out(_reason: String) -> void:
	if player and hostel_bed:
		player.global_position = hostel_bed.global_position + Vector3(0, 0.1, 2.0)


func _setup_3d_object(obj: CampusObject3D, type: CampusObject3D.ObjectType, title: String, col: Color) -> void:
	if not obj:
		return
	obj.object_type = type
	obj.object_name = title
	obj.update_object_display()

	var mesh_inst: MeshInstance3D = obj.get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_inst:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = col
		mat.roughness = 0.5
		mesh_inst.set_surface_override_material(0, mat)
