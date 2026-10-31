class_name PropBuilder3D
extends RefCounted

## Central procedural 3D prop builder & My Campus Life data hub.
## Builds multi-part low-poly 3D meshes for all 24 CampusObject3D types (0 KB external asset weight),
## configures proximity label fading, and provides room-aware student NPC & objective data.

static var _mat_cache: Dictionary = {}
static var onboarding_quest_step: int = 0

const ONBOARDING_QUESTS: Array[Dictionary] = [
	{"text": "📋 Task 1/14: Try on an Outfit at Hostel Wardrobe (+₦500)", "dest": &"hostel", "color": Color(1.0, 0.88, 0.28), "reward": 500},
	{"text": "📋 Task 2/14: Greet your Roommate or Coursemate (+₦500)", "dest": &"hostel", "color": Color(0.45, 0.95, 0.62), "reward": 500},
	{"text": "📋 Task 3/14: Ride the Danfo Shuttle to Faculty Hall LT1 (+₦500)", "dest": &"class", "color": Color(0.38, 0.88, 1.0), "reward": 500},
	{"text": "📋 Task 4/14: Study or Attend Class at Lecture Desk (+₦1,000)", "dest": &"class", "color": Color(1.0, 0.78, 0.32), "reward": 1000},
	{"text": "📋 Task 5/14: Eat a hot meal at Mama Put Canteen (+₦1,000)", "dest": &"mama_put", "color": Color(1.0, 0.58, 0.28), "reward": 1000},
	{"text": "📋 Task 6/14: Score a Penalty Goal in the Stadium (+₦1,500)", "dest": &"stadium", "color": Color(0.35, 0.95, 0.58), "reward": 1500},
	{"text": "📋 Task 7/14: Take an In-Course CA Test at Lecture Hall (+₦2,000)", "dest": &"class", "color": Color(1.0, 0.82, 0.25), "reward": 2000},
	{"text": "📋 Task 8/14: Complete a Freelance Tech Gig at the SUB (+₦2,500)", "dest": &"sub", "color": Color(0.40, 0.85, 1.0), "reward": 2500},
	{"text": "📋 Task 9/14: Play Snooker Match at the SUB Arcade (+₦1,000)", "dest": &"sub", "color": Color(0.95, 0.55, 0.85), "reward": 1000},
	{"text": "📋 Task 10/14: Study Past Questions at Library Carrel (+₦1,500)", "dest": &"library", "color": Color(0.55, 0.88, 1.0), "reward": 1500},
	{"text": "📋 Task 11/14: Fellowship & Prayer at the Chapel (+₦1,000)", "dest": &"chapel", "color": Color(0.95, 0.85, 0.55), "reward": 1000},
	{"text": "📋 Task 12/14: Get a Fresh Haircut/Styling at the Salon (+₦1,000)", "dest": &"salon", "color": Color(1.0, 0.65, 0.45), "reward": 1000},
	{"text": "📋 Task 13/14: Cook a hot meal in the Hostel Kitchenette (+₦1,000)", "dest": &"hostel", "color": Color(0.98, 0.55, 0.35), "reward": 1000},
	{"text": "📋 Task 14/14: Senate Clearance & Merit Scholarship (+₦5,000)", "dest": &"senate", "color": Color(1.0, 0.85, 0.20), "reward": 5000}
]


static func advance_quest_if_matching(step_index: int, player: Node = null) -> void:
	if onboarding_quest_step != step_index or onboarding_quest_step >= ONBOARDING_QUESTS.size():
		return
	var q: Dictionary = ONBOARDING_QUESTS[onboarding_quest_step]
	var reward: int = int(q.get("reward", 500))
	onboarding_quest_step += 1

	var target_player: Node = player
	if not target_player:
		var st = Engine.get_main_loop() as SceneTree
		if st and st.current_scene:
			target_player = st.current_scene.get_node_or_null("Player3D")

	if target_player:
		var needs = target_player.get_node_or_null("NeedsManager")
		if needs and needs.has_method("modify_money"):
			needs.modify_money(reward)
		if target_player.has_method("play_celebrate_animation"):
			target_player.play_celebrate_animation("✅ TASK %d DONE! +₦%d" % [step_index + 1, reward])
		if target_player.is_inside_tree() and target_player.get_tree() and target_player.get_tree().current_scene:
			var hud = target_player.get_tree().current_scene.get_node_or_null("HUD")
			if hud and hud.has_method("_refresh_objective_pill"):
				hud._refresh_objective_pill()


static func complete_semester_task(step_index: int, player: Node = null) -> void:
	advance_quest_if_matching(step_index, player)


static func get_mat(color: Color, roughness: float = 0.65, metallic: float = 0.05, emission_energy: float = 0.0) -> StandardMaterial3D:
	var key: String = "%s_%.2f_%.2f_%.2f" % [color.to_html(), roughness, metallic, emission_energy]
	if _mat_cache.has(key):
		return _mat_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	if emission_energy > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission_energy
	_mat_cache[key] = m
	return m


static func _add_box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, rot_deg: Vector3 = Vector3.ZERO, metallic: float = 0.05, emission: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.material_override = get_mat(color, 0.6, metallic, emission)
	parent.add_child(mi)
	return mi


static func _add_cyl(parent: Node3D, top_r: float, bot_r: float, h: float, pos: Vector3, color: Color, rot_deg: Vector3 = Vector3.ZERO, metallic: float = 0.1, emission: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = top_r
	cm.bottom_radius = bot_r
	cm.height = h
	cm.radial_segments = 12
	mi.mesh = cm
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.material_override = get_mat(color, 0.55, metallic, emission)
	parent.add_child(mi)
	return mi


static func _add_steam(parent: Node3D, pos: Vector3) -> CPUParticles3D:
	var steam := CPUParticles3D.new()
	steam.name = "CookingSteam"
	steam.amount = 14
	steam.lifetime = 1.3
	steam.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	steam.emission_sphere_radius = 0.08
	steam.direction = Vector3.UP
	steam.spread = 15.0
	steam.gravity = Vector3(0, 0.45, 0)
	steam.initial_velocity_min = 0.15
	steam.initial_velocity_max = 0.4
	var smat := StandardMaterial3D.new()
	smat.albedo_color = Color(1.0, 1.0, 1.0, 0.28)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var s_mesh := SphereMesh.new()
	s_mesh.radius = 0.04
	s_mesh.height = 0.08
	s_mesh.material = smat
	steam.mesh = s_mesh
	steam.position = pos
	parent.add_child(steam)
	return steam


## Configures a Label3D so it only appears when the player walks near it (My Campus Life clean view)
static func configure_proximity_label(lbl: Label3D, max_dist: float = 6.5, font_sz: int = 24) -> void:
	if not lbl:
		return
	lbl.font_size = font_sz
	lbl.outline_size = 6
	lbl.visibility_range_end = max_dist + 3.0
	lbl.visibility_range_end_margin = 2.0
	lbl.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF


## Builds a recognizable 3D prop + interactive ground ring for any CampusObject3D
static func build_campus_prop(obj: Node3D, obj_type: int) -> Node3D:
	if obj.has_node("ProceduralProp"):
		return obj.get_node("ProceduralProp") as Node3D

	var root := Node3D.new()
	root.name = "ProceduralProp"
	obj.add_child(root)

	# Subtle interactive ground ring under every usable prop
	var ring := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.72
	cyl.bottom_radius = 0.78
	cyl.height = 0.02
	cyl.radial_segments = 18
	ring.mesh = cyl
	ring.position = Vector3(0, 0.015, 0)
	var ring_mat := StandardMaterial3D.new()
	ring_mat.albedo_color = Color(1.0, 0.82, 0.24, 0.32)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	root.add_child(ring)

	const WOOD_DARK := Color(0.36, 0.22, 0.12)
	const WOOD_WARM := Color(0.58, 0.38, 0.20)
	const METAL_DARK := Color(0.18, 0.20, 0.24)
	const METAL_SILVER := Color(0.78, 0.82, 0.86)
	const DANFO_YELLOW := Color(0.96, 0.76, 0.08)
	const NAIJA_GREEN := Color(0.10, 0.58, 0.32)
	const CREAM_WHITE := Color(0.94, 0.93, 0.88)

	match obj_type:
		0: # BED
			_add_box(root, Vector3(1.2, 0.28, 1.9), Vector3(0, 0.22, 0), WOOD_DARK)
			_add_box(root, Vector3(1.2, 0.75, 0.10), Vector3(0, 0.45, -0.92), WOOD_DARK) # Headboard
			_add_box(root, Vector3(1.12, 0.22, 1.78), Vector3(0, 0.42, 0.02), CREAM_WHITE) # Mattress
			_add_box(root, Vector3(1.14, 0.24, 1.05), Vector3(0, 0.43, 0.36), Color(0.16, 0.48, 0.78)) # Duvet
			_add_box(root, Vector3(0.75, 0.12, 0.36), Vector3(0, 0.56, -0.62), Color(0.98, 0.98, 1.0)) # Pillow
			# 4 Nigerian hostel mosquito net poles
			_add_cyl(root, 0.02, 0.02, 1.35, Vector3(-0.55, 0.92, -0.88), METAL_DARK)
			_add_cyl(root, 0.02, 0.02, 1.35, Vector3(0.55, 0.92, -0.88), METAL_DARK)
			_add_cyl(root, 0.02, 0.02, 1.35, Vector3(-0.55, 0.92, 0.88), METAL_DARK)
			_add_cyl(root, 0.02, 0.02, 1.35, Vector3(0.55, 0.92, 0.88), METAL_DARK)
			# Top mosquito net canopy frame
			_add_box(root, Vector3(1.14, 0.03, 0.03), Vector3(0, 1.58, -0.88), METAL_DARK)
			_add_box(root, Vector3(1.14, 0.03, 0.03), Vector3(0, 1.58, 0.88), METAL_DARK)
			_add_box(root, Vector3(0.03, 0.03, 1.78), Vector3(-0.55, 1.58, 0), METAL_DARK)
			_add_box(root, Vector3(0.03, 0.03, 1.78), Vector3(0.55, 1.58, 0), METAL_DARK)
		1, 11, 19: # DESK, LIBRARY_CARREL, COURSEWORK_DESK
			_add_box(root, Vector3(1.3, 0.07, 0.75), Vector3(0, 0.74, 0), WOOD_WARM)
			_add_box(root, Vector3(0.08, 0.72, 0.68), Vector3(-0.56, 0.36, 0), METAL_DARK, Vector3.ZERO, 0.4)
			_add_box(root, Vector3(0.08, 0.72, 0.68), Vector3(0.56, 0.36, 0), METAL_DARK, Vector3.ZERO, 0.4)
			# Open laptop + textbook stack
			_add_box(root, Vector3(0.38, 0.02, 0.26), Vector3(-0.15, 0.79, 0.05), METAL_SILVER, Vector3.ZERO, 0.6)
			_add_box(root, Vector3(0.38, 0.24, 0.02), Vector3(-0.15, 0.90, -0.07), Color(0.18, 0.65, 0.95), Vector3(-12, 0, 0), 0.2, 0.5)
			_add_box(root, Vector3(0.26, 0.08, 0.32), Vector3(0.34, 0.81, 0), Color(0.78, 0.22, 0.18))
			# Electric pressing iron on study desk
			_add_box(root, Vector3(0.12, 0.05, 0.20), Vector3(0.48, 0.79, 0.22), METAL_SILVER, Vector3(0, 25, 0), 0.7)
			_add_box(root, Vector3(0.08, 0.04, 0.12), Vector3(0.48, 0.83, 0.22), Color(0.12, 0.35, 0.75), Vector3(0, 25, 0))
		2: # CAFETERIA (Mama Put Canteen Counter & Steaming Warmers)
			_add_box(root, Vector3(2.0, 0.90, 0.85), Vector3(0, 0.45, 0), Color(0.72, 0.28, 0.16))
			_add_box(root, Vector3(2.08, 0.06, 0.92), Vector3(0, 0.92, 0), METAL_SILVER, Vector3.ZERO, 0.70)
			# Glass sneeze guard
			_add_box(root, Vector3(1.95, 0.42, 0.04), Vector3(0, 1.15, 0.40), Color(0.85, 0.95, 1.0, 0.4))
			# Jollof and Egusi warmer pots
			_add_cyl(root, 0.26, 0.24, 0.22, Vector3(-0.55, 1.05, 0.05), METAL_SILVER, Vector3.ZERO, 0.75)
			_add_cyl(root, 0.26, 0.24, 0.22, Vector3(0.52, 1.05, 0.05), METAL_SILVER, Vector3.ZERO, 0.75)
			_add_steam(root, Vector3(-0.55, 1.25, 0.05))
			_add_steam(root, Vector3(0.52, 1.25, 0.05))
		17: # HOSTEL_KITCHEN (Wooden Stool, Electric Coil Burner, Boiling Pot & Steam)
			_add_box(root, Vector3(0.75, 0.55, 0.75), Vector3(0, 0.28, 0), WOOD_DARK)
			# Electric coil hotplate base
			_add_box(root, Vector3(0.52, 0.08, 0.52), Vector3(0, 0.60, 0), METAL_DARK, Vector3.ZERO, 0.4)
			# Glowing heating coil
			_add_cyl(root, 0.18, 0.18, 0.02, Vector3(0, 0.65, 0), Color(0.98, 0.32, 0.12), Vector3.ZERO, 0.2, 0.9)
			# Small Indomie pot with steam
			_add_cyl(root, 0.16, 0.15, 0.18, Vector3(0, 0.76, 0), METAL_SILVER, Vector3.ZERO, 0.8)
			_add_steam(root, Vector3(0, 0.92, 0))
		3, 12: # FELLOWSHIP, CHAPEL_WORSHIP
			_add_box(root, Vector3(0.9, 1.05, 0.55), Vector3(0, 0.52, 0), WOOD_DARK)
			_add_box(root, Vector3(1.05, 0.08, 0.65), Vector3(0, 1.06, 0), WOOD_WARM, Vector3(12, 0, 0))
			_add_box(root, Vector3(0.08, 0.42, 0.04), Vector3(0, 0.68, 0.29), DANFO_YELLOW, Vector3.ZERO, 0.4, 0.4)
			_add_box(root, Vector3(0.26, 0.08, 0.04), Vector3(0, 0.76, 0.29), DANFO_YELLOW, Vector3.ZERO, 0.4, 0.4)
		4: # ATM
			_add_box(root, Vector3(0.78, 1.55, 0.68), Vector3(0, 0.78, 0), Color(0.14, 0.28, 0.52), Vector3.ZERO, 0.4)
			_add_box(root, Vector3(0.52, 0.38, 0.05), Vector3(0, 1.12, 0.33), Color(0.20, 0.88, 0.55), Vector3(-10, 0, 0), 0.1, 0.8)
			_add_box(root, Vector3(0.76, 0.18, 0.70), Vector3(0, 1.62, 0), NAIJA_GREEN, Vector3.ZERO, 0.2, 0.3)
		5: # HUSTLE_DESK
			_add_box(root, Vector3(1.35, 0.75, 0.70), Vector3(0, 0.38, 0), WOOD_DARK)
			_add_box(root, Vector3(0.52, 0.34, 0.05), Vector3(0, 0.98, -0.12), Color(0.15, 0.85, 0.55), Vector3.ZERO, 0.2, 0.6)
			_add_box(root, Vector3(0.45, 0.22, 0.35), Vector3(0.42, 0.86, 0.05), CREAM_WHITE) # Printer
		6: # SALON_CHAIR
			_add_cyl(root, 0.08, 0.28, 0.42, Vector3(0, 0.21, 0), METAL_SILVER, Vector3.ZERO, 0.8)
			_add_box(root, Vector3(0.62, 0.12, 0.62), Vector3(0, 0.46, 0), Color(0.78, 0.14, 0.14))
			_add_box(root, Vector3(0.62, 0.65, 0.12), Vector3(0, 0.82, -0.26), Color(0.78, 0.14, 0.14))
		7: # WARDROBE
			_add_box(root, Vector3(1.15, 1.85, 0.58), Vector3(0, 0.92, 0), WOOD_WARM)
			_add_box(root, Vector3(0.46, 1.35, 0.03), Vector3(0.26, 0.98, 0.29), Color(0.72, 0.88, 0.96), Vector3.ZERO, 0.85) # Mirror
		8: # MALL_BOUTIQUE
			_add_box(root, Vector3(1.5, 0.90, 0.68), Vector3(0, 0.45, 0), Color(0.88, 0.72, 0.32), Vector3.ZERO, 0.35)
			_add_box(root, Vector3(1.42, 0.35, 0.62), Vector3(0, 1.05, 0), Color(0.82, 0.92, 0.98, 0.6))
		9: # SHUTTLE_STOP (Danfo Yellow Signpost + Waiting Bench)
			_add_cyl(root, 0.05, 0.05, 2.1, Vector3(-0.55, 1.05, 0), METAL_DARK, Vector3.ZERO, 0.5)
			_add_box(root, Vector3(0.72, 0.42, 0.08), Vector3(-0.55, 1.95, 0), DANFO_YELLOW, Vector3.ZERO, 0.2, 0.3)
			_add_box(root, Vector3(0.74, 0.10, 0.09), Vector3(-0.55, 1.95, 0), Color(0.08, 0.08, 0.08)) # Danfo black stripe
			_add_box(root, Vector3(1.15, 0.42, 0.45), Vector3(0.25, 0.22, 0), WOOD_WARM)
		10, 14: # DINING_TABLE, GARDEN_GAZEBO
			_add_cyl(root, 0.68, 0.68, 0.06, Vector3(0, 0.72, 0), WOOD_WARM)
			_add_cyl(root, 0.08, 0.26, 0.70, Vector3(0, 0.35, 0), METAL_DARK)
			_add_cyl(root, 1.15, 0.05, 0.38, Vector3(0, 1.85, 0), NAIJA_GREEN) # Shade umbrella
			_add_cyl(root, 0.04, 0.04, 1.15, Vector3(0, 1.28, 0), METAL_SILVER)
		13: # STADIUM_SPORTS
			_add_cyl(root, 0.26, 0.26, 0.04, Vector3(0, 0.03, 0), CREAM_WHITE, Vector3.ZERO, 0.1, 0.3)
			_add_cyl(root, 0.04, 0.18, 0.38, Vector3(-0.55, 0.19, 0), Color(0.98, 0.38, 0.08)) # Training cone
			_add_cyl(root, 0.04, 0.18, 0.38, Vector3(0.55, 0.19, 0), Color(0.98, 0.38, 0.08))
		15: # SENATE_REGISTRY
			_add_box(root, Vector3(1.65, 0.95, 0.75), Vector3(0, 0.48, 0), WOOD_DARK)
			_add_box(root, Vector3(1.70, 0.08, 0.80), Vector3(0, 0.98, 0), DANFO_YELLOW, Vector3.ZERO, 0.4)
		16: # SUB_ARCADE (Green Felt Snooker Table)
			_add_box(root, Vector3(1.65, 0.76, 0.95), Vector3(0, 0.38, 0), WOOD_DARK)
			_add_box(root, Vector3(1.52, 0.05, 0.82), Vector3(0, 0.78, 0), Color(0.08, 0.56, 0.24))
		18: # HOSTEL_WATER (Yellow Jerrycan + Blue Bucket)
			_add_box(root, Vector3(0.36, 0.52, 0.28), Vector3(-0.24, 0.26, 0), DANFO_YELLOW)
			_add_cyl(root, 0.25, 0.19, 0.42, Vector3(0.24, 0.21, 0), Color(0.16, 0.48, 0.88))
		20: # CHAPEL_PIANO
			_add_box(root, Vector3(1.38, 0.86, 0.58), Vector3(0, 0.43, 0), Color(0.10, 0.10, 0.12), Vector3.ZERO, 0.5)
			_add_box(root, Vector3(1.22, 0.06, 0.22), Vector3(0, 0.78, 0.22), CREAM_WHITE)
		21: # GATE_SECURITY
			_add_box(root, Vector3(0.32, 1.05, 0.32), Vector3(-0.75, 0.52, 0), DANFO_YELLOW)
			_add_box(root, Vector3(1.65, 0.10, 0.10), Vector3(0.05, 0.88, 0), Color(0.88, 0.18, 0.16))
		22: # DOOR_EXIT (Framed Exit Door + Glowing Green Welcome Mat)
			_add_box(root, Vector3(1.28, 2.15, 0.14), Vector3(0, 1.08, -0.15), WOOD_DARK)
			_add_box(root, Vector3(1.08, 2.02, 0.18), Vector3(0, 1.02, -0.15), WOOD_WARM)
			_add_box(root, Vector3(0.14, 0.06, 0.08), Vector3(0.38, 0.98, -0.04), DANFO_YELLOW, Vector3.ZERO, 0.8, 0.4)
			_add_box(root, Vector3(1.20, 0.03, 0.65), Vector3(0, 0.02, 0.25), NAIJA_GREEN, Vector3.ZERO, 0.1, 0.35)
		23: # MINI_FRIDGE
			_add_box(root, Vector3(0.72, 0.98, 0.65), Vector3(0, 0.49, 0), METAL_SILVER, Vector3.ZERO, 0.55)
			_add_box(root, Vector3(0.05, 0.42, 0.06), Vector3(0.28, 0.58, 0.34), Color(0.20, 0.78, 0.95), Vector3.ZERO, 0.6, 0.4)
		24: # HOSTEL_BOOMBOX (Portable Bluetooth Afrobeats Speaker)
			_add_box(root, Vector3(0.48, 0.24, 0.24), Vector3(0, 0.12, 0), Color(0.12, 0.14, 0.18), Vector3.ZERO, 0.6)
			_add_cyl(root, 0.08, 0.08, 0.02, Vector3(-0.12, 0.12, 0.12), Color(0.85, 0.22, 0.22), Vector3(90, 0, 0)) # Red speaker grill
			_add_cyl(root, 0.08, 0.08, 0.02, Vector3(0.12, 0.12, 0.12), Color(0.22, 0.65, 0.85), Vector3(90, 0, 0)) # Blue speaker grill
			_add_box(root, Vector3(0.04, 0.06, 0.04), Vector3(0, 0.26, 0), Color(0.20, 0.85, 1.0), Vector3.ZERO, 0.2, 0.8) # Glowing LED
		25: # NOTICEBOARD (Faculty Circulars & Examination Timetable)
			_add_cyl(root, 0.05, 0.06, 2.2, Vector3(-1.1, 1.1, 0), WOOD_DARK)
			_add_cyl(root, 0.05, 0.06, 2.2, Vector3(1.1, 1.1, 0), WOOD_DARK)
			_add_box(root, Vector3(2.4, 1.3, 0.08), Vector3(0, 1.35, 0), WOOD_DARK)
			_add_box(root, Vector3(2.25, 1.15, 0.04), Vector3(0, 1.35, 0.03), Color(0.72, 0.58, 0.38))
			_add_box(root, Vector3(2.6, 0.06, 0.45), Vector3(0, 2.05, 0.12), METAL_DARK, Vector3(15, 0, 0))
			_add_box(root, Vector3(0.42, 0.55, 0.02), Vector3(-0.65, 1.4, 0.06), CREAM_WHITE, Vector3(0, 0, 3))
			_add_box(root, Vector3(0.40, 0.50, 0.02), Vector3(-0.15, 1.35, 0.06), DANFO_YELLOW, Vector3(0, 0, -2))
			_add_box(root, Vector3(0.45, 0.58, 0.02), Vector3(0.40, 1.42, 0.06), CREAM_WHITE, Vector3(0, 0, 1))
			_add_box(root, Vector3(0.38, 0.42, 0.02), Vector3(0.85, 1.25, 0.06), Color(0.95, 0.82, 0.82), Vector3(0, 0, -4))
		26: # SPONSOR_STAND (MTN 5G Pulse & Indomie Campus Promo Gazebo)
			_add_cyl(root, 0.035, 0.035, 2.2, Vector3(-1.1, 1.1, -1.1), DANFO_YELLOW, Vector3.ZERO, 0.4)
			_add_cyl(root, 0.035, 0.035, 2.2, Vector3(1.1, 1.1, -1.1), DANFO_YELLOW, Vector3.ZERO, 0.4)
			_add_cyl(root, 0.035, 0.035, 2.2, Vector3(-1.1, 1.1, 1.1), DANFO_YELLOW, Vector3.ZERO, 0.4)
			_add_cyl(root, 0.035, 0.035, 2.2, Vector3(1.1, 1.1, 1.1), DANFO_YELLOW, Vector3.ZERO, 0.4)
			_add_box(root, Vector3(2.4, 0.35, 2.4), Vector3(0, 2.3, 0), DANFO_YELLOW)
			_add_box(root, Vector3(2.48, 0.08, 2.48), Vector3(0, 2.15, 0), Color(0.10, 0.28, 0.65))
			_add_box(root, Vector3(1.6, 0.85, 0.55), Vector3(0, 0.42, 0.4), CREAM_WHITE)
			_add_box(root, Vector3(1.62, 0.42, 0.02), Vector3(0, 0.45, 0.68), DANFO_YELLOW)
			_add_box(root, Vector3(0.55, 1.6, 0.02), Vector3(1.4, 0.82, 0.5), DANFO_YELLOW, Vector3(0, -15, 0))
			_add_box(root, Vector3(0.58, 0.06, 0.22), Vector3(1.4, 0.03, 0.5), METAL_SILVER, Vector3(0, -15, 0), 0.7)
		27: # PHOTOCOPY_KIOSK (Brother Austin's Campus Spiral Binding & Copy Shop)
			_add_box(root, Vector3(2.2, 1.1, 1.4), Vector3(0, 0.55, 0), WOOD_DARK)
			_add_box(root, Vector3(2.28, 0.06, 1.48), Vector3(0, 1.12, 0), WOOD_WARM)
			_add_box(root, Vector3(2.4, 0.06, 1.6), Vector3(0, 2.2, 0.15), Color(0.12, 0.38, 0.75), Vector3(10, 0, 0))
			_add_cyl(root, 0.03, 0.03, 1.2, Vector3(-1.05, 1.65, 0.65), METAL_DARK)
			_add_cyl(root, 0.03, 0.03, 1.2, Vector3(1.05, 1.65, 0.65), METAL_DARK)
			_add_box(root, Vector3(0.68, 0.42, 0.52), Vector3(-0.52, 1.34, 0.05), Color(0.85, 0.87, 0.90), Vector3.ZERO, 0.3)
			_add_box(root, Vector3(0.42, 0.04, 0.32), Vector3(-0.52, 1.56, 0.05), Color(0.18, 0.20, 0.24))
			_add_box(root, Vector3(0.32, 0.18, 0.25), Vector3(0.45, 1.22, -0.15), DANFO_YELLOW)
			_add_box(root, Vector3(0.30, 0.14, 0.22), Vector3(0.48, 1.38, -0.15), CREAM_WHITE)
			_add_box(root, Vector3(0.42, 0.16, 0.28), Vector3(0.42, 1.21, 0.32), Color(0.12, 0.45, 0.85))
		_:
			_add_box(root, Vector3(0.9, 0.8, 0.9), Vector3(0, 0.4, 0), WOOD_WARM)

	return root


## Returns ambient student NPC templates so every room feels populated in My Campus Life
static func get_ambient_npcs_for_room(room_id: StringName) -> Array[Dictionary]:
	match room_id:
		&"courtyard", &"main":
			return [
				{"name": "Comrade Ojo", "role": "SUG President", "color": Color(0.12, 0.58, 0.25), "pos": Vector3(-5.0, 0.1, -6.5), "lines": ["Great Nigerian Students! Aluta Continua!", "Congress holds this Friday at the SUB—be there to voice your hostel concerns!", "Check the Departmental Noticeboard for your lecture schedules and dockets!"]},
				{"name": "Sister Blessing", "role": "Fellowship Exec", "color": Color(0.68, 0.35, 0.85), "pos": Vector3(-4.0, 0.1, 3.5), "lines": ["Academic brilliance without peace of mind is incomplete!", "Join us at the Chapel for Midweek Fellowship—prayers for semester success!", "Have a blessed and productive day on campus!"]},
				{"name": "Brother Austin", "role": "Photocopy Boss", "color": Color(0.25, 0.45, 0.75), "pos": Vector3(7.2, 0.1, -6.5), "lines": ["Handouts and past questions for all 34 departments ready!", "Fast spiral binding available—don't wait till exam morning!", "Need extra pocket money? Jump in for a 20-minute printing hustle!"]},
				{"name": "Dr. Adebayo", "role": "Faculty Dean", "color": Color(0.75, 0.22, 0.25), "pos": Vector3(3.5, 0.1, -2.5), "lines": ["Good day, scholar. 75% lecture attendance is strictly enforced.", "Have you checked the library archives for past questions?", "Students with CGPA >= 4.50 can claim their ₦25,000 Senate scholarship!"]}
			]
		&"hostel":
			return [
				{"name": "Tunde (100L)", "role": "Hall Rep", "color": Color(0.18, 0.55, 0.85), "pos": Vector3(-2.5, 0.1, 2.5), "lines": ["NEPA just flashed light o, charge your phone fast!", "Who took my bucket by the tap?!", "Shuttle to Lecture Hall leaves every 3 minutes."]},
				{"name": "Kemi (200L)", "role": "Block Senior", "color": Color(0.88, 0.32, 0.52), "pos": Vector3(2.8, 0.1, 1.8), "lines": ["Don't forget to check your Mini-Fridge before 8 AM class!", "First Class scholarship at Senate pays ₦25,000 cash o."]}
			]
		&"lecture", &"lecture2":
			return [
				{"name": "Chinedu", "role": "Course Rep", "color": Color(0.16, 0.62, 0.38), "pos": Vector3(-3.2, 0.1, 1.5), "lines": ["Attendance sheet is passing round o!", "Tap any study desk to join the live lecture or write CA test!"]},
				{"name": "Zainab", "role": "Scholar (4.85 CGPA)", "color": Color(0.65, 0.28, 0.78), "pos": Vector3(3.0, 0.1, 2.0), "lines": ["Sitting in the front row gives you bonus focus!", "Read past questions at the Library Carrel before exams."]}
			]
		&"mama_put", &"buka":
			return [
				{"name": "Bolanle", "role": "Foodie", "color": Color(0.92, 0.52, 0.14), "pos": Vector3(-2.8, 0.1, 2.2), "lines": ["Mama Cashout's Jollof + Plantain is undefeated!", "Buy extra Malt or Shawarma to store in your Hostel Fridge."]},
				{"name": "Emeka", "role": "Final Year Bro", "color": Color(0.22, 0.38, 0.72), "pos": Vector3(2.6, 0.1, 2.6), "lines": ["Nothing beats hot Amala after a 3-hour lecture!", "If you're broke, hit the SUB Hustle Desk for quick gigs."]}
			]
		_:
			return [
				{"name": "Damilola", "role": "Campus Hustler", "color": Color(0.95, 0.72, 0.15), "pos": Vector3(-3.0, 0.1, 2.5), "lines": ["My Campus Life is all about timing—watch your Energy & CGPA!", "Tap any object once and your character walks right to it."]},
				{"name": "Sadiq", "role": "SUG Exco", "color": Color(0.15, 0.68, 0.45), "pos": Vector3(3.2, 0.1, 2.2), "lines": ["Aluta continua! Check the SUB Arcade or Football Pitch to unwind.", "Use the yellow Shuttle Stop or Map button to ride the Danfo bus."]}
			]


## Computes a dynamic, actionable "Next Hustle" objective for the HUD pill
static func get_smart_objective(energy: float, hunger: float, money: int, cgpa: float) -> Dictionary:
	if onboarding_quest_step < ONBOARDING_QUESTS.size():
		return ONBOARDING_QUESTS[onboarding_quest_step]
	var lec_idx: int = Schedule.get_current_lecture_index()
	if lec_idx != -1 and not Schedule.is_attended(lec_idx):
		var lec: Dictionary = Schedule.get_lecture(lec_idx)
		return {
			"text": "🎯 CLASS LIVE: Attend %s at Lecture Hall!" % String(lec.get("name", "Lecture")),
			"dest": &"class",
			"color": Color(1.0, 0.84, 0.25)
		}
	if hunger < 32.0:
		return {
			"text": "🍲 Hungry (%.0f%%): Eat at Mama Put or open Hostel Fridge" % hunger,
			"dest": &"mama_put",
			"color": Color(1.0, 0.55, 0.28)
		}
	if energy < 28.0:
		return {
			"text": "⚡ Low Energy (%.0f%%): Sleep in Hostel Bed or drink Malt" % energy,
			"dest": &"hostel",
			"color": Color(0.98, 0.42, 0.42)
		}
	if money < 500:
		return {
			"text": "💸 Low Cash (₦%d): Do a gig at SUB or visit Campus ATM" % money,
			"dest": &"sub",
			"color": Color(0.35, 0.95, 0.58)
		}
	if TimeSystem.is_night():
		return {
			"text": "🌙 Late Night: Head to Hostel Bed to rest for 07:00 AM",
			"dest": &"hostel",
			"color": Color(0.68, 0.78, 1.0)
		}
	if cgpa < 3.5:
		return {
			"text": "📚 Boost CGPA (%.2f): Study Past Questions at Library" % cgpa,
			"dest": &"library",
			"color": Color(0.38, 0.86, 1.0)
		}

	# Dynamic Hour-Aware Campus Goals & Endless Hustles
	var h: int = TimeSystem.current_hour
	var day_str: String = TimeSystem.get_day_string()

	if day_str == "Sunday" and h >= 8 and h <= 13:
		return {
			"text": "⛪ Sunday Service: Worship & Piano at Campus Chapel",
			"dest": &"chapel",
			"color": Color(1.0, 0.88, 0.45)
		}
	elif h >= 7 and h < 11:
		return {
			"text": "⚽ Dean's Cup Derby: Score Penalty Kick in the Stadium",
			"dest": &"stadium",
			"color": Color(0.35, 0.95, 0.58)
		}
	elif h >= 11 and h < 14:
		return {
			"text": "🍲 Campus Lunch: Fresh Jollof Rice & Plantain at Mama Put",
			"dest": &"mama_put",
			"color": Color(1.0, 0.65, 0.28)
		}
	elif h >= 14 and h < 17:
		return {
			"text": "💻 Freelance Tech Hub: Complete Coding Tasks for Cash",
			"dest": &"tech_hub",
			"color": Color(0.35, 0.85, 1.0)
		}
	elif h >= 17 and h < 20:
		return {
			"text": "🎱 SUB Arcade: Play 9-Ball Snooker Stake Match",
			"dest": &"sub",
			"color": Color(0.95, 0.55, 0.85)
		}
	elif h >= 20 and h < 22:
		return {
			"text": "🌳 Evening Refreshment: Walk and reflect at Botanical Gardens",
			"dest": &"garden",
			"color": Color(0.55, 0.95, 0.65)
		}

	return {
		"text": "🎯 Campus Hustle: Explore SUB, Library, or catch a Danfo Shuttle",
		"dest": &"sub",
		"color": Color(0.88, 0.94, 1.0)
	}


## Adds procedural WorldEnvironment, DirectionalLight3D, architectural floor grid lines, and room-specific lighting
static func enhance_room_atmosphere(room: Node3D) -> void:
	if not room:
		return

	# 1. Procedural WorldEnvironment for vibrant tropical sky and ACES tonemapping
	if not room.has_node("ProceduralWorldEnv"):
		var env_node := WorldEnvironment.new()
		env_node.name = "ProceduralWorldEnv"
		var env := Environment.new()
		env.background_mode = Environment.BG_SKY
		var sky := Sky.new()
		var sky_mat := ProceduralSkyMaterial.new()
		sky_mat.sky_top_color = Color(0.22, 0.52, 0.88)
		sky_mat.sky_horizon_color = Color(0.82, 0.88, 0.96)
		sky_mat.ground_bottom_color = Color(0.24, 0.20, 0.16)
		sky_mat.ground_horizon_color = Color(0.75, 0.82, 0.90)
		sky.sky_material = sky_mat
		env.sky = sky
		env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		env.ambient_light_sky_contribution = 0.60
		env.ambient_light_color = Color(0.92, 0.88, 0.82)
		env.ambient_light_energy = 0.95
		env.tonemap_mode = Environment.TONE_MAPPER_ACES
		env.tonemap_exposure = 1.12
		env.glow_enabled = true
		env.glow_intensity = 0.35
		env.glow_bloom = 0.12
		env_node.environment = env
		room.add_child(env_node)

	# 2. Procedural Sun (DirectionalLight3D) if room has none
	var has_dir_light: bool = false
	for child in room.get_children():
		if child is DirectionalLight3D:
			has_dir_light = true
			break
	if not has_dir_light:
		var sun := DirectionalLight3D.new()
		sun.name = "DirectionalLight3D"
		sun.position = Vector3(4.0, 14.0, 6.0)
		sun.rotation_degrees = Vector3(-48.0, 32.0, 0.0)
		sun.light_color = Color(1.0, 0.94, 0.84)
		sun.light_energy = 1.25
		# Zero lag optimization: disable shadows on web/mobile browsers
		if OS.has_feature("web") or OS.has_feature("mobile"):
			sun.shadow_enabled = false
		else:
			sun.shadow_enabled = true
			sun.shadow_bias = 0.05
		room.add_child(sun)

	# 3. Room-Specific Atmospheric Accent Lights
	var r_name: String = room.name.to_lower()
	if not room.has_node("RoomAtmosphereLight"):
		var acc_light := OmniLight3D.new()
		acc_light.name = "RoomAtmosphereLight"
		if "hostel" in r_name:
			acc_light.light_color = Color(1.0, 0.84, 0.52) # Warm incandescent hostel bulb
			acc_light.light_energy = 1.4
			acc_light.omni_range = 8.5
			acc_light.position = Vector3(0, 2.4, 0)
		elif "lecture" in r_name:
			acc_light.light_color = Color(0.92, 0.96, 1.0) # Daylight lecture fluorescent
			acc_light.light_energy = 1.5
			acc_light.omni_range = 11.0
			acc_light.position = Vector3(0, 3.2, 0)
		elif "mama_put" in r_name or "buka" in r_name:
			acc_light.light_color = Color(1.0, 0.65, 0.25) # Warm food warmer glow
			acc_light.light_energy = 1.6
			acc_light.omni_range = 9.5
			acc_light.position = Vector3(0, 2.6, 0)
		elif "chapel" in r_name:
			acc_light.light_color = Color(1.0, 0.85, 0.40) # Serene cathedral amber
			acc_light.light_energy = 1.8
			acc_light.omni_range = 12.0
			acc_light.position = Vector3(0, 3.5, 0)
		elif "stadium" in r_name:
			acc_light.light_color = Color(0.96, 1.0, 0.96) # Stadium floodlight
			acc_light.light_energy = 2.0
			acc_light.omni_range = 18.0
			acc_light.position = Vector3(0, 5.0, 0)
		elif "mall" in r_name or "sub" in r_name:
			acc_light.light_color = Color(0.40, 0.85, 1.0) # Neon cyan arcade/mall
			acc_light.light_energy = 1.5
			acc_light.omni_range = 10.0
			acc_light.position = Vector3(0, 2.8, 0)
		else:
			acc_light.light_color = Color(1.0, 0.92, 0.80)
			acc_light.light_energy = 1.2
			acc_light.omni_range = 8.0
			acc_light.position = Vector3(0, 2.5, 0)
		room.add_child(acc_light)

	# 4. Architectural 3D floor tile grid lines for depth perception
	if not room.has_node("ArchitecturalPolish"):
		var arch := Node3D.new()
		arch.name = "ArchitecturalPolish"
		room.add_child(arch)
		var grid_col := Color(0.95, 0.92, 0.85, 0.16)
		var grid_mat := StandardMaterial3D.new()
		grid_mat.albedo_color = grid_col
		grid_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		grid_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for i in range(-5, 6, 2):
			var strip_x := MeshInstance3D.new()
			var bx := BoxMesh.new()
			bx.size = Vector3(14.0, 0.008, 0.035)
			strip_x.mesh = bx
			strip_x.position = Vector3(0, 0.006, float(i))
			strip_x.material_override = grid_mat
			arch.add_child(strip_x)

			var strip_z := MeshInstance3D.new()
			var bz := BoxMesh.new()
			bz.size = Vector3(0.035, 0.008, 14.0)
			strip_z.mesh = bz
			strip_z.position = Vector3(float(i), 0.006, 0)
			strip_z.material_override = grid_mat
			arch.add_child(strip_z)

	# 5. Brighten and stylize room floor & wall surfaces (eliminate dark/muddy look)
	_brighten_room_surfaces(room, r_name)

	# 6. Procedural authentic room signature fixtures (chalkboards, plates, posters, pitch markings)
	_inject_room_decor(room, r_name)

	update_room_day_night_lighting(room)


static func _brighten_room_surfaces(room: Node3D, r_name: String) -> void:
	if not room:
		return

	# 1. Elevate floor surface to bright, warm, slightly reflective material
	var floor_node: MeshInstance3D = null
	if room.has_node("Floor/MeshInstance3D"):
		floor_node = room.get_node("Floor/MeshInstance3D") as MeshInstance3D
	elif room.has_node("PitchFloor/MeshInstance3D"):
		floor_node = room.get_node("PitchFloor/MeshInstance3D") as MeshInstance3D
	elif room.has_node("Floor"):
		var f_child = room.get_node("Floor")
		if f_child is MeshInstance3D:
			floor_node = f_child

	if floor_node:
		var floor_mat := StandardMaterial3D.new()
		floor_mat.roughness = 0.42
		floor_mat.metallic = 0.04
		if "hostel" in r_name:
			floor_mat.albedo_color = Color(0.86, 0.74, 0.58) # Warm parquet
		elif "lecture" in r_name:
			floor_mat.albedo_color = Color(0.88, 0.90, 0.92) # Clean terrazzo
		elif "mama_put" in r_name or "buka" in r_name:
			floor_mat.albedo_color = Color(0.90, 0.84, 0.74) # Cheerful cafeteria tile
		elif "chapel" in r_name:
			floor_mat.albedo_color = Color(0.90, 0.86, 0.80) # Sanctuary marble
		elif "library" in r_name:
			floor_mat.albedo_color = Color(0.84, 0.80, 0.72) # Oak study wood
		elif "stadium" in r_name:
			floor_mat.albedo_color = Color(0.20, 0.62, 0.25) # Lush pitch green
		elif "garden" in r_name:
			floor_mat.albedo_color = Color(0.24, 0.65, 0.28) # Park lawn
		elif "sub" in r_name:
			floor_mat.albedo_color = Color(0.20, 0.24, 0.32) # Sleek lounge
		elif "mall" in r_name or "salon" in r_name:
			floor_mat.albedo_color = Color(0.92, 0.92, 0.95) # Glossy porcelain
		elif "senate" in r_name:
			floor_mat.albedo_color = Color(0.92, 0.90, 0.84) # Senate marble
		elif "gate" in r_name:
			floor_mat.albedo_color = Color(0.78, 0.76, 0.72) # Campus road paving
		elif "courtyard" in r_name or "main" in r_name:
			floor_mat.albedo_color = Color(0.84, 0.82, 0.78) # Paved academic quad
		else:
			floor_mat.albedo_color = Color(0.86, 0.84, 0.80)
		floor_node.material_override = floor_mat

	# 2. Brighten walls to clean warm ivory
	var walls_node: Node = room.get_node_or_null("Walls")
	if not walls_node:
		walls_node = room.get_node_or_null("BoundaryWalls")
	if walls_node:
		var wall_mat := StandardMaterial3D.new()
		wall_mat.albedo_color = Color(0.96, 0.94, 0.89)
		wall_mat.roughness = 0.85
		for child in walls_node.get_children():
			if child is MeshInstance3D and not "fence" in child.name.to_lower():
				child.material_override = wall_mat


static func _inject_room_decor(room: Node3D, r_name: String) -> void:
	if not room or room.has_node("AtmosphereDecor"):
		return

	var decor := Node3D.new()
	decor.name = "AtmosphereDecor"
	room.add_child(decor)

	if "mama_put" in r_name or "buka" in r_name:
		# Stack of red & green Nigerian beverage crates in corner
		_add_box(decor, Vector3(0.55, 0.32, 0.42), Vector3(-6.2, 0.16, -4.5), Color(0.85, 0.15, 0.15))
		_add_box(decor, Vector3(0.55, 0.32, 0.42), Vector3(-6.2, 0.48, -4.5), Color(0.12, 0.65, 0.25))
		_add_box(decor, Vector3(0.55, 0.32, 0.42), Vector3(-5.5, 0.16, -4.5), Color(0.12, 0.65, 0.25))

		# Dining table food plates on dining spots
		var plates_pos: Array[Vector3] = [Vector3(-2.8, 0.82, -1.0), Vector3(2.8, 0.82, -1.0), Vector3(0, 0.82, 3.2)]
		for pos in plates_pos:
			_add_cyl(decor, 0.22, 0.22, 0.02, pos, Color.WHITE) # Plate
			_add_cyl(decor, 0.14, 0.16, 0.06, pos + Vector3(0, 0.03, 0), Color(0.95, 0.62, 0.12)) # Jollof rice
			_add_box(decor, Vector3(0.08, 0.04, 0.12), pos + Vector3(0.12, 0.04, 0), Color(0.85, 0.45, 0.08)) # Dodo
			_add_box(decor, Vector3(0.10, 0.06, 0.14), pos + Vector3(-0.10, 0.05, 0), Color(0.68, 0.24, 0.14)) # Chicken

	elif "lecture" in r_name:
		# Front wall faculty chalkboard
		_add_box(decor, Vector3(6.4, 2.3, 0.05), Vector3(0, 2.3, -11.45), Color(0.52, 0.34, 0.18)) # Wood frame
		_add_box(decor, Vector3(6.2, 2.1, 0.06), Vector3(0, 2.3, -11.44), Color(0.10, 0.22, 0.14)) # Dark green board
		var board_lbl := Label3D.new()
		board_lbl.text = "FACULTY OF COMPUTING & SCIENCE — LT1\nCSC 101: INTRO TO LOGIC & ALGORITHMS\n• Time Complexity: O(log N)  • Pointer Ops\nNOTE: 1st In-Course Test next week!"
		board_lbl.font_size = 20
		board_lbl.outline_size = 4
		board_lbl.modulate = Color(0.92, 0.96, 0.88)
		board_lbl.position = Vector3(0, 2.3, -11.38)
		decor.add_child(board_lbl)

	elif "hostel" in r_name:
		# Hostel wall poster
		_add_box(decor, Vector3(1.1, 1.5, 0.02), Vector3(-2.8, 2.2, -5.85), Color(0.96, 0.78, 0.18))
		var poster_lbl := Label3D.new()
		poster_lbl.text = "MY CAMPUS LIFE 2026\nANNUAL CARNIVAL\n& AFROBEATS NIGHT\n\"No Dulling This Semester!\""
		poster_lbl.font_size = 18
		poster_lbl.outline_size = 4
		poster_lbl.modulate = Color(0.10, 0.12, 0.15)
		poster_lbl.position = Vector3(-2.8, 2.2, -5.82)
		decor.add_child(poster_lbl)

	elif "stadium" in r_name:
		# White field markings
		var line_mat := StandardMaterial3D.new()
		line_mat.albedo_color = Color(0.96, 0.96, 0.96, 0.85)
		line_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

		# Center circle
		var c_ring := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = 4.2
		cyl.bottom_radius = 4.28
		cyl.height = 0.006
		cyl.radial_segments = 24
		c_ring.mesh = cyl
		c_ring.position = Vector3(0, 0.008, 0)
		c_ring.material_override = line_mat
		decor.add_child(c_ring)

		# Center halfway line
		var half_line := _add_box(decor, Vector3(34.0, 0.006, 0.12), Vector3(0, 0.008, 0), Color.WHITE)
		half_line.material_override = line_mat

		# Penalty area box
		var box_front := _add_box(decor, Vector3(14.0, 0.006, 0.12), Vector3(0, 0.008, -6.5), Color.WHITE)
		box_front.material_override = line_mat

	elif "gate" in r_name:
		# Zebra crossing road markings on asphalt
		var zebra_mat := StandardMaterial3D.new()
		zebra_mat.albedo_color = Color(0.96, 0.96, 0.96, 0.92)
		zebra_mat.roughness = 0.5
		for z in range(-3, 4):
			var stripe := MeshInstance3D.new()
			var b := BoxMesh.new()
			b.size = Vector3(0.65, 0.008, 4.2)
			stripe.mesh = b
			stripe.position = Vector3(float(z) * 1.25, 0.006, -6.8)
			stripe.material_override = zebra_mat
			decor.add_child(stripe)

		# Mama Boli Charcoal smoke particles
		var boli_smoke := CPUParticles3D.new()
		boli_smoke.name = "BoliCharcoalSmoke"
		boli_smoke.amount = 12
		boli_smoke.lifetime = 1.4
		boli_smoke.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
		boli_smoke.emission_sphere_radius = 0.12
		boli_smoke.direction = Vector3.UP
		boli_smoke.spread = 18.0
		boli_smoke.gravity = Vector3(0, 0.35, 0)
		boli_smoke.initial_velocity_min = 0.1
		boli_smoke.initial_velocity_max = 0.3
		var smat := StandardMaterial3D.new()
		smat.albedo_color = Color(0.9, 0.9, 0.9, 0.22)
		smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var smesh := SphereMesh.new()
		smesh.radius = 0.05
		smesh.height = 0.1
		smesh.material = smat
		boli_smoke.mesh = smesh
		boli_smoke.position = Vector3(-8.0, 0.88, -5.5)
		decor.add_child(boli_smoke)

	elif "courtyard" in r_name or "main" in r_name:
		# Central University Quad Monument / Obelisk
		_add_box(decor, Vector3(2.4, 0.45, 2.4), Vector3(0, 0.22, 0), Color(0.65, 0.62, 0.58))
		_add_box(decor, Vector3(1.8, 0.35, 1.8), Vector3(0, 0.60, 0), Color(0.75, 0.72, 0.68))
		_add_cyl(decor, 0.28, 0.45, 3.2, Vector3(0, 2.35, 0), Color(0.88, 0.86, 0.82), Vector3.ZERO, 0.3)
		_add_cyl(decor, 0.05, 0.28, 0.75, Vector3(0, 4.30, 0), Color(0.96, 0.78, 0.15), Vector3.ZERO, 0.6, 0.3)

		# Gold university monument plaque
		var plaque_lbl := Label3D.new()
		plaque_lbl.text = "★ MY CAMPUS LIFE UNIVERSITY ★\nCENTRAL ACADEMIC QUAD\n\"EXCELLENCE, WISDOM & ENTERPRISE\"\nEST. 1962"
		plaque_lbl.font_size = 20
		plaque_lbl.outline_size = 4
		plaque_lbl.modulate = Color(0.12, 0.14, 0.18)
		plaque_lbl.position = Vector3(0, 0.62, 0.92)
		decor.add_child(plaque_lbl)

		# 4-Direction Campus Fingerpost Sign
		_add_cyl(decor, 0.04, 0.04, 2.6, Vector3(-1.8, 1.3, -2.5), Color(0.2, 0.22, 0.25), Vector3.ZERO, 0.4)
		var sign_n := Label3D.new()
		sign_n.text = "⬆ NORTH: Lecture Theatres LT1 & LT2 • Library"
		sign_n.font_size = 18
		sign_n.outline_size = 4
		sign_n.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sign_n.position = Vector3(-1.8, 2.6, -2.5)
		decor.add_child(sign_n)

		var sign_s := Label3D.new()
		sign_s.text = "⬇ SOUTH: Hall 2 Hostels • Campus Security Gate"
		sign_s.font_size = 18
		sign_s.outline_size = 4
		sign_s.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sign_s.position = Vector3(-1.8, 2.35, -2.5)
		decor.add_child(sign_s)

		var sign_e := Label3D.new()
		sign_e.text = "➡ EAST: Mama Put Canteen • Campus Mall"
		sign_e.font_size = 18
		sign_e.outline_size = 4
		sign_e.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sign_e.position = Vector3(-1.8, 2.1, -2.5)
		decor.add_child(sign_e)

		var sign_w := Label3D.new()
		sign_w.text = "⬅ WEST: Student Union Building (SUB) • Chapel"
		sign_w.font_size = 18
		sign_w.outline_size = 4
		sign_w.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sign_w.position = Vector3(-1.8, 1.85, -2.5)
		decor.add_child(sign_w)


static func update_room_day_night_lighting(room: Node3D) -> void:
	if not room:
		return
	var dir_light: DirectionalLight3D = room.get_node_or_null("DirectionalLight3D") as DirectionalLight3D
	if not dir_light:
		for child in room.get_children():
			if child is DirectionalLight3D:
				dir_light = child
				break
	if not dir_light:
		return

	var hr: int = TimeSystem.get_hour()
	if hr >= 6 and hr < 10:
		# Warm Campus Morning Sun
		dir_light.light_color = Color(1.0, 0.92, 0.76)
		dir_light.light_energy = 1.15
	elif hr >= 10 and hr < 17:
		# Bright Tropical Afternoon
		dir_light.light_color = Color(1.0, 0.98, 0.92)
		dir_light.light_energy = 1.35
	elif hr >= 17 and hr < 20:
		# Golden Evening / Sunset
		dir_light.light_color = Color(1.0, 0.72, 0.48)
		dir_light.light_energy = 0.95
	else:
		# Cozy Campus Night / Security Lamp Ambience
		dir_light.light_color = Color(0.58, 0.72, 0.98)
		dir_light.light_energy = 0.68
