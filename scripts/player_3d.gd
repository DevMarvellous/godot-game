class_name Player3D
extends CharacterBody3D

## 3D Top-Down / Isometric Player Controller.
## Movement across X/Z ground plane with smooth rotation and 3D interactions.

@export var move_speed: float = 8.0
@export var acceleration: float = 24.0
@export var gravity: float = 20.0
@export var rotation_speed: float = 12.0

var nav_target_pos: Vector3 = Vector3.ZERO
var has_nav_target: bool = false

@onready var visual_root: Node3D = $Visuals
@onready var torso_mesh: MeshInstance3D = $Visuals/TorsoMesh if has_node("Visuals/TorsoMesh") else null
@onready var head_mesh: MeshInstance3D = $Visuals/HeadMesh if has_node("Visuals/HeadMesh") else null
@onready var hair_mesh: MeshInstance3D = $Visuals/HairMesh if has_node("Visuals/HairMesh") else null
@onready var left_leg: MeshInstance3D = $Visuals/LeftLeg if has_node("Visuals/LeftLeg") else null
@onready var right_leg: MeshInstance3D = $Visuals/RightLeg if has_node("Visuals/RightLeg") else null
@onready var left_arm: MeshInstance3D = $Visuals/LeftArm if has_node("Visuals/LeftArm") else null
@onready var right_arm: MeshInstance3D = $Visuals/RightArm if has_node("Visuals/RightArm") else null

@onready var hair_low_cut: MeshInstance3D = $Visuals/HairMesh if has_node("Visuals/HairMesh") else null
@onready var hair_afro: MeshInstance3D = $Visuals/HairAfro if has_node("Visuals/HairAfro") else null
@onready var hair_braids: MeshInstance3D = $Visuals/HairBraids if has_node("Visuals/HairBraids") else null
@onready var hair_cap: MeshInstance3D = $Visuals/HairCap if has_node("Visuals/HairCap") else null
@onready var hair_headwrap: MeshInstance3D = $Visuals/HairHeadwrap if has_node("Visuals/HairHeadwrap") else null
@onready var senator_tunic: MeshInstance3D = $Visuals/SenatorTunic if has_node("Visuals/SenatorTunic") else null
@onready var corporate_tie: MeshInstance3D = $Visuals/CorporateTie if has_node("Visuals/CorporateTie") else null
@onready var hoodie_cowl: MeshInstance3D = $Visuals/HoodieCowl if has_node("Visuals/HoodieCowl") else null
@onready var gown_flare: MeshInstance3D = $Visuals/GownFlare if has_node("Visuals/GownFlare") else null

@onready var needs_manager: NeedsManager = $NeedsManager
@onready var prompt_label: Label3D = $PromptLabel
@onready var notif_label: Label3D = $NotifLabel
@onready var notif_timer: Timer = $NotifTimer
@onready var chat_bubble: Label3D = $ChatBubble if has_node("ChatBubble") else null
@onready var chat_timer: Timer = $ChatTimer if has_node("ChatTimer") else null
@onready var camera_node: Camera3D = $Camera3D if has_node("Camera3D") else null

var current_interactable: Interactable3D = null
var pending_interactable: Interactable3D = null
var walk_anim_time: float = 0.0
var _net_sync_timer: float = 0.0
var _last_net_pos: Vector3 = Vector3.ZERO
var _last_net_moving: bool = false

var is_sitting: bool = false
var is_emoting: bool = false
var is_dressing_animating: bool = false
var _idle_time: float = 0.0
var _sit_rest_timer: float = 0.0
var _active_emote_tween: Tween = null
var _dress_tween: Tween = null

# Smooth Lagos Life style camera offset & interpolation (Elevated 3/4 Isometric)
var cam_target_offset: Vector3 = Vector3(0, 5.0, 4.8)

# Dynamic Camera Zoom (mouse wheel on desktop, toggle button on mobile)
var cam_zoom_factor: float = 1.0
const CAM_ZOOM_MIN: float = 0.55 # Close-up avatar view
const CAM_ZOOM_MAX: float = 1.8  # Wide room overview
const CAM_ZOOM_STEP: float = 0.12
const CAM_BASE_OFFSET: Vector3 = Vector3(0, 5.0, 4.8)
const CAM_ZOOM_PRESETS: Array[float] = [0.65, 1.0, 1.4] # Close / Medium / Wide
var cam_zoom_preset_idx: int = 1


func _ready() -> void:
	if camera_node:
		camera_node.top_level = true
		camera_node.global_position = global_position + cam_target_offset
	if prompt_label:
		prompt_label.visible = false
	if notif_label:
		notif_label.visible = false
	if notif_timer:
		notif_timer.timeout.connect(_on_notif_timeout)
	if chat_bubble:
		chat_bubble.visible = false
	if chat_timer:
		chat_timer.timeout.connect(_on_chat_timeout)
	if NetworkManager:
		NetworkManager.chat_received.connect(_on_chat_received)
	_load_default_appearance()


var mobile_input_vector: Vector2 = Vector2.ZERO
var nav_beacon_instance: Node3D = null


func set_mobile_movement(vec: Vector2) -> void:
	mobile_input_vector = vec
	if vec != Vector2.ZERO:
		has_nav_target = false # Joystick movement overrides tap-to-move
		pending_interactable = null
		_hide_nav_beacon()


func _unhandled_input(event: InputEvent) -> void:
	# Mouse wheel camera zoom (desktop)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			cam_zoom_factor = clampf(cam_zoom_factor - CAM_ZOOM_STEP, CAM_ZOOM_MIN, CAM_ZOOM_MAX)
			cam_target_offset = CAM_BASE_OFFSET * cam_zoom_factor
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cam_zoom_factor = clampf(cam_zoom_factor + CAM_ZOOM_STEP, CAM_ZOOM_MIN, CAM_ZOOM_MAX)
			cam_target_offset = CAM_BASE_OFFSET * cam_zoom_factor
			get_viewport().set_input_as_handled()
			return

	# Tap / Click anywhere to walk or 1-tap auto-interact (Lagos Life tap navigation)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cam: Camera3D = get_viewport().get_camera_3d()
		if cam:
			var from: Vector3 = cam.project_ray_origin(event.position)
			var to: Vector3 = from + cam.project_ray_normal(event.position) * 100.0
			var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

			# 1. Check if player directly tapped an Interactable3D (Layer 2 Area3D)
			var area_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, 2)
			area_query.collide_with_areas = true
			area_query.collide_with_bodies = false
			var area_hit: Dictionary = space_state.intersect_ray(area_query)
			if area_hit.has("collider") and area_hit.collider is Interactable3D:
				var tapped_obj: Interactable3D = area_hit.collider as Interactable3D
				_walk_to_and_interact(tapped_obj)
				return

			# 2. Otherwise raycast to Ground (Layer 4)
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, 4)
			var result: Dictionary = space_state.intersect_ray(query)
			if result.has("position"):
				var hit_pos: Vector3 = result.position
				# Check if tap is right next to an Interactable3D in the room
				var near_obj: Interactable3D = _find_nearest_interactable(hit_pos, 1.85)
				if near_obj:
					_walk_to_and_interact(near_obj)
				else:
					pending_interactable = null
					nav_target_pos = Vector3(hit_pos.x, global_position.y, hit_pos.z)
					has_nav_target = true
					_show_nav_beacon(hit_pos)


func _walk_to_and_interact(target: Interactable3D) -> void:
	if not is_instance_valid(target):
		return
	if current_interactable == target or global_position.distance_to(target.global_position) < 2.2:
		pending_interactable = null
		has_nav_target = false
		_hide_nav_beacon()
		target.interact(self)
		return
	pending_interactable = target
	nav_target_pos = Vector3(target.global_position.x, global_position.y, target.global_position.z)
	has_nav_target = true
	_show_nav_beacon(target.global_position)


func _find_nearest_interactable(world_pos: Vector3, max_radius: float) -> Interactable3D:
	var best: Interactable3D = null
	var best_dist: float = max_radius
	var scene_root: Node = get_tree().current_scene
	if not scene_root:
		return null
	var fixtures: Node = scene_root.get_node_or_null("WorldObjects")
	if fixtures:
		for child in fixtures.get_children():
			if child is Interactable3D:
				var d: float = Vector2(world_pos.x - child.global_position.x, world_pos.z - child.global_position.z).length()
				if d < best_dist:
					best_dist = d
					best = child
	var npcs_node: Node = scene_root.get_node_or_null("NPCs")
	if npcs_node:
		for npc in npcs_node.get_children():
			var area: Interactable3D = npc.get_node_or_null("InteractArea") as Interactable3D
			if area:
				var d_npc: float = Vector2(world_pos.x - npc.global_position.x, world_pos.z - npc.global_position.z).length()
				if d_npc < best_dist:
					best_dist = d_npc
					best = area
	return best


## Toggle camera zoom through Close / Medium / Wide presets (mobile button)
func cycle_camera_zoom() -> String:
	cam_zoom_preset_idx = (cam_zoom_preset_idx + 1) % CAM_ZOOM_PRESETS.size()
	cam_zoom_factor = CAM_ZOOM_PRESETS[cam_zoom_preset_idx]
	cam_target_offset = CAM_BASE_OFFSET * cam_zoom_factor
	var labels: Array[String] = ["Close", "Medium", "Wide"]
	return labels[cam_zoom_preset_idx]


func _create_nav_beacon() -> void:
	nav_beacon_instance = Node3D.new()
	nav_beacon_instance.name = "NavBeacon"

	var mesh_inst: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.38
	cylinder.bottom_radius = 0.38
	cylinder.height = 0.02
	mesh_inst.mesh = cylinder

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.18, 0.95, 0.52, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.15, 0.85, 0.45)
	mat.emission_energy_multiplier = 1.3
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_inst.set_surface_override_material(0, mat)

	nav_beacon_instance.add_child(mesh_inst)
	nav_beacon_instance.top_level = true
	nav_beacon_instance.visible = false
	add_child(nav_beacon_instance)


func _show_nav_beacon(pos: Vector3) -> void:
	if not nav_beacon_instance:
		_create_nav_beacon()
	if nav_beacon_instance:
		nav_beacon_instance.global_position = Vector3(pos.x, pos.y + 0.03, pos.z)
		nav_beacon_instance.visible = true
		nav_beacon_instance.scale = Vector3(0.35, 1.0, 0.35)
		var tw: Tween = create_tween()
		tw.tween_property(nav_beacon_instance, "scale", Vector3(1.15, 1.0, 1.15), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _hide_nav_beacon() -> void:
	if nav_beacon_instance and nav_beacon_instance.visible:
		var tw: Tween = create_tween()
		tw.tween_property(nav_beacon_instance, "scale", Vector3(0.01, 1.0, 0.01), 0.15)
		tw.finished.connect(func():
			if nav_beacon_instance:
				nav_beacon_instance.visible = false
		)


func trigger_interaction() -> void:
	if current_interactable:
		pending_interactable = null
		current_interactable.interact(self)


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Get movement input: Mobile Virtual Joystick takes priority, then keyboard, then tap-to-walk
	var input_dir: Vector2 = Vector2.ZERO
	if mobile_input_vector != Vector2.ZERO:
		input_dir = mobile_input_vector
		has_nav_target = false
		pending_interactable = null
		_hide_nav_beacon()
	else:
		input_dir.x = Input.get_axis("move_left", "move_right")
		input_dir.y = Input.get_axis("move_up", "move_down")
		if input_dir != Vector2.ZERO:
			has_nav_target = false
			pending_interactable = null
			_hide_nav_beacon()

	# Check sprint action (Shift or fast push)
	var is_sprinting: bool = Input.is_action_pressed("sprint")
	var current_move_speed: float = move_speed * (1.55 if is_sprinting else 1.0)

	var target_vel: Vector3 = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		target_vel = Vector3(input_dir.x, 0.0, input_dir.y) * current_move_speed
		var target_angle: float = atan2(-input_dir.x, -input_dir.y)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, rotation_speed * delta)
	elif has_nav_target:
		# Tap to move towards target position
		var to_target: Vector3 = nav_target_pos - global_position
		to_target.y = 0.0
		var dist: float = to_target.length()
		var stop_dist: float = 1.65 if is_instance_valid(pending_interactable) else 0.4
		if dist > stop_dist:
			var move_dir: Vector3 = to_target.normalized()
			target_vel = move_dir * current_move_speed
			var target_angle: float = atan2(-move_dir.x, -move_dir.z)
			visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, rotation_speed * delta)
		else:
			has_nav_target = false
			_hide_nav_beacon()
			if is_instance_valid(pending_interactable):
				var obj_to_use: Interactable3D = pending_interactable
				pending_interactable = null
				obj_to_use.interact(self)

	velocity.x = move_toward(velocity.x, target_vel.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, acceleration * delta)

	move_and_slide()

	# Animate walking limbs (arms + legs swinging) and subtle torso bobbing
	var horiz_speed: float = Vector2(velocity.x, velocity.z).length()
	if horiz_speed > 0.3:
		if is_sitting:
			stand_up()
		if is_emoting:
			cancel_emote()
		_idle_time = 0.0

		var speed_factor: float = clampf(horiz_speed / move_speed, 0.8, 1.6)
		walk_anim_time += delta * 12.0 * speed_factor
		var arm_amp: float = 0.45 * speed_factor
		var leg_amp: float = 0.48 * speed_factor

		# Arm swing (opposing)
		if left_arm and right_arm:
			left_arm.rotation.x = sin(walk_anim_time) * arm_amp
			right_arm.rotation.x = -sin(walk_anim_time) * arm_amp
		# Leg stride (opposing to arms)
		if left_leg and right_leg:
			left_leg.rotation.x = -sin(walk_anim_time) * leg_amp
			right_leg.rotation.x = sin(walk_anim_time) * leg_amp
		# Torso bounce & subtle lateral sway
		if torso_mesh and head_mesh and hair_mesh:
			var bob: float = abs(sin(walk_anim_time)) * 0.04
			var sway: float = sin(walk_anim_time * 0.5) * 0.03
			torso_mesh.position.y = 0.95 + bob
			head_mesh.position.y = 1.45 + bob
			hair_mesh.position.y = 1.58 + bob
			torso_mesh.rotation.z = sway
	elif is_sitting:
		# Gradually regain energy while seated and resting
		_sit_rest_timer += delta
		if _sit_rest_timer >= 2.0:
			_sit_rest_timer = 0.0
			if needs_manager:
				needs_manager.modify_energy(1.2)
	elif is_emoting:
		# Emote tween has active control over character pose
		pass
	else:
		# Return smoothly to neutral standing posture
		if left_arm and right_arm:
			left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, 6.0 * delta)
			right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, 6.0 * delta)
		if left_leg and right_leg:
			left_leg.rotation.x = move_toward(left_leg.rotation.x, 0.0, 7.0 * delta)
			right_leg.rotation.x = move_toward(right_leg.rotation.x, 0.0, 7.0 * delta)
		if torso_mesh and head_mesh and hair_mesh:
			torso_mesh.position.y = move_toward(torso_mesh.position.y, 0.95, 0.4 * delta)
			head_mesh.position.y = move_toward(head_mesh.position.y, 1.45, 0.4 * delta)
			hair_mesh.position.y = move_toward(hair_mesh.position.y, 1.58, 0.4 * delta)
			torso_mesh.rotation.z = move_toward(torso_mesh.rotation.z, 0.0, 4.0 * delta)

		# Idle micro-actions (phone check, stretch, look around)
		_idle_time += delta
		if _idle_time >= 8.5:
			_idle_time = 0.0
			_trigger_idle_fidget()

	# Broadcast position and movement to online room peers (Throttled to 4Hz delta-only: <2 KB/min)
	_net_sync_timer += delta
	if _net_sync_timer >= 0.25:
		_net_sync_timer = 0.0
		var is_moving_now: bool = horiz_speed > 0.3
		if NetworkManager and is_inside_tree() and NetworkManager.is_online():
			if global_position.distance_to(_last_net_pos) > 0.15 or is_moving_now != _last_net_moving:
				_last_net_pos = global_position
				_last_net_moving = is_moving_now
				var current_room: String = String(get_tree().current_scene.name) if get_tree().current_scene else "room"
				NetworkManager.broadcast_transform(current_room, global_position, visual_root.rotation.y, is_moving_now)

	# Smooth Lagos Life camera follow (damped lerp)
	if camera_node:
		var desired_cam_pos: Vector3 = global_position + cam_target_offset
		camera_node.global_position = camera_node.global_position.lerp(desired_cam_pos, 7.5 * delta)

	# Interaction trigger
	if Input.is_action_just_pressed("interact"):
		trigger_interaction()


func set_interaction_target(target: Interactable3D) -> void:
	current_interactable = target
	if prompt_label:
		prompt_label.text = target.prompt_message
		prompt_label.visible = true
	if pending_interactable == target:
		pending_interactable = null
		has_nav_target = false
		_hide_nav_beacon()
		target.interact(self)


func clear_interaction_target(target: Interactable3D) -> void:
	if current_interactable == target:
		current_interactable = null
		if prompt_label:
			prompt_label.visible = false


func display_notification(msg: String) -> void:
	if not notif_label or not is_inside_tree():
		return
	notif_label.text = msg
	notif_label.visible = true
	if notif_timer and notif_timer.is_inside_tree():
		notif_timer.start(2.5)
	elif is_inside_tree() and get_tree():
		get_tree().create_timer(2.5).timeout.connect(func():
			if notif_label and is_inside_tree():
				notif_label.visible = false
		)


func _on_notif_timeout() -> void:
	if notif_label:
		notif_label.visible = false


func show_chat_bubble(msg: String) -> void:
	if not chat_bubble or not is_inside_tree():
		return
	chat_bubble.text = "\"%s\"" % msg
	chat_bubble.visible = true
	if chat_timer and chat_timer.is_inside_tree():
		chat_timer.start(4.5)


func _on_chat_timeout() -> void:
	if chat_bubble:
		chat_bubble.visible = false


func _on_chat_received(_sender_name: String, msg: String, peer_id: int) -> void:
	if peer_id == 1 or (multiplayer.has_multiplayer_peer() and peer_id == multiplayer.get_unique_id()):
		show_chat_bubble(msg)


func _load_default_appearance() -> void:
	const Wardrobe = preload("res://scripts/data/wardrobe_data.gd")
	const ProfileStore = preload("res://scripts/data/student_profile.gd")
	ProfileStore.load_from_disk()

	var skin_idx: int = clampi(ProfileStore.complexion_index, 0, Wardrobe.COMPLEXIONS.size() - 1)
	var hair_idx: int = clampi(ProfileStore.hair_index, 0, Wardrobe.HAIRSTYLES.size() - 1)
	var shirt_idx: int = clampi(ProfileStore.shirt_index, 0, Wardrobe.OUTFITS.size() - 1)
	var trouser_idx: int = ProfileStore.trouser_index

	var hair_item: Dictionary = Wardrobe.HAIRSTYLES[hair_idx]
	var outfit_item: Dictionary = Wardrobe.OUTFITS[shirt_idx]

	var skin_color: Color = Wardrobe.COMPLEXIONS[skin_idx].color
	var shirt_color: Color = outfit_item.get("top_color", Color(0.12, 0.55, 0.32))
	var trouser_color: Color = outfit_item.get("bottom_color", Color(0.15, 0.22, 0.32))
	var hair_color: Color = hair_item.get("default_color", Color(0.08, 0.08, 0.08))

	apply_appearance(
		skin_color,
		shirt_color,
		trouser_color,
		hair_color,
		hair_item.get("mesh_type", "low_cut"),
		outfit_item.get("mesh_type", "casual")
	)


func apply_appearance(
	skin_color: Color,
	shirt_color: Color,
	trouser_color: Color,
	hair_color: Color,
	hair_type: String = "low_cut",
	outfit_type: String = "casual"
) -> void:
	# 1. Skin tone
	if head_mesh:
		var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
		skin_mat.albedo_color = skin_color
		skin_mat.roughness = 0.7
		head_mesh.set_surface_override_material(0, skin_mat)

	# 2. Distinct 3D Hair Meshes (Afro, Braids, Cap, Gele/Headwrap, Low Cut)
	var all_hairs: Array[MeshInstance3D] = [hair_low_cut, hair_afro, hair_braids, hair_cap, hair_headwrap]
	for h in all_hairs:
		if is_instance_valid(h):
			h.visible = false

	var active_hair: MeshInstance3D = hair_low_cut
	match hair_type:
		"afro":
			active_hair = hair_afro if hair_afro else hair_low_cut
		"braids":
			active_hair = hair_braids if hair_braids else hair_low_cut
		"cap":
			active_hair = hair_cap if hair_cap else hair_low_cut
		"headwrap":
			active_hair = hair_headwrap if hair_headwrap else hair_low_cut
		_:
			active_hair = hair_low_cut

	if is_instance_valid(active_hair):
		active_hair.visible = true
		var hair_mat: StandardMaterial3D = StandardMaterial3D.new()
		hair_mat.albedo_color = hair_color
		hair_mat.roughness = 0.85
		active_hair.set_surface_override_material(0, hair_mat)

	# 3. Distinct 3D Outfit Meshes (Senator Tunic, Tie, Hoodie, Gown, Casual)
	var all_outfit_details: Array[MeshInstance3D] = [senator_tunic, corporate_tie, hoodie_cowl, gown_flare]
	for o in all_outfit_details:
		if is_instance_valid(o):
			o.visible = false

	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = shirt_color
	shirt_mat.roughness = 0.6
	if torso_mesh:
		torso_mesh.set_surface_override_material(0, shirt_mat)
	if left_arm:
		left_arm.set_surface_override_material(0, shirt_mat)
	if right_arm:
		right_arm.set_surface_override_material(0, shirt_mat)

	match outfit_type:
		"senator":
			if senator_tunic:
				senator_tunic.visible = true
				senator_tunic.set_surface_override_material(0, shirt_mat)
		"corporate":
			if corporate_tie:
				corporate_tie.visible = true
		"hoodie":
			if hoodie_cowl:
				hoodie_cowl.visible = true
				hoodie_cowl.set_surface_override_material(0, shirt_mat)
		"gown":
			if gown_flare:
				gown_flare.visible = true
				gown_flare.set_surface_override_material(0, shirt_mat)

	# 4. Trousers / Leggings
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = trouser_color
	leg_mat.roughness = 0.75
	if left_leg:
		left_leg.set_surface_override_material(0, leg_mat)
	if right_leg:
		right_leg.set_surface_override_material(0, leg_mat)


## Plays a stylish 360-degree spin dressing animation with bounce & sparkle
func play_dressing_animation(midpoint_callback: Callable = Callable()) -> void:
	if not visual_root or not is_inside_tree():
		if midpoint_callback.is_valid():
			midpoint_callback.call()
		return

	if _dress_tween and _dress_tween.is_valid():
		_dress_tween.kill()

	is_dressing_animating = true

	var start_rot: float = visual_root.rotation.y
	var full_spin_rot: float = start_rot + TAU

	# First half spin (0 to 180 degrees) with subtle wind-up crouch
	_dress_tween = create_tween().set_parallel(true)
	_dress_tween.tween_property(visual_root, "rotation:y", start_rot + PI, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_dress_tween.tween_property(visual_root, "scale", Vector3(0.90, 1.10, 0.90), 0.22)
	await _dress_tween.finished

	# Swap clothes at the midpoint!
	if midpoint_callback.is_valid():
		midpoint_callback.call()

	# Midpoint celebratory sparkle & chime
	if SoundManager:
		SoundManager.play_bell()

	# Second half spin (180 to 360 degrees) with celebratory bounce
	_dress_tween = create_tween().set_parallel(true)
	_dress_tween.tween_property(visual_root, "rotation:y", full_spin_rot, 0.26).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_dress_tween.tween_property(visual_root, "scale", Vector3(1.20, 1.20, 1.20), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await _dress_tween.finished

	# Settle smoothly back to regular scale & normalize rotation
	var settle_tween: Tween = create_tween()
	settle_tween.tween_property(visual_root, "scale", Vector3.ONE, 0.12)
	await settle_tween.finished

	visual_root.rotation.y = fmod(visual_root.rotation.y, TAU)
	is_dressing_animating = false


## Spawns a floating stat particle above player's head (Sims / Lagos Life style)
func spawn_floating_stat(text_val: String, color_val: Color = Color.WHITE) -> void:
	if not is_inside_tree():
		return
	var label = Label3D.new()
	label.text = text_val
	label.font_size = 28
	label.outline_size = 6
	label.modulate = color_val
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 2.3, 0)
	add_child(label)

	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(label, "position:y", 3.2, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(label, "modulate:a", 0.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(label.queue_free)


## Plays an eating animation with head-bobbing and food chew
func play_eating_animation() -> void:
	if not visual_root or not is_inside_tree():
		return
	spawn_floating_stat("🍲 Delicious! +Energy", Color(0.25, 0.95, 0.45, 1.0))
	if SoundManager:
		SoundManager.play_click()

	var chew_tween: Tween = create_tween()
	for i in range(3):
		chew_tween.tween_property(head_mesh, "rotation:x", 0.22, 0.12)
		chew_tween.tween_property(head_mesh, "rotation:x", -0.05, 0.12)
	chew_tween.tween_property(head_mesh, "rotation:x", 0.0, 0.1)


## Plays a celebratory jump and victory fist-pump
func play_celebrate_animation(bonus_text: String = "🎉 WINNER!") -> void:
	if not visual_root or not is_inside_tree():
		return
	spawn_floating_stat(bonus_text, Color(1.0, 0.85, 0.2, 1.0))
	if SoundManager:
		SoundManager.play_coin()

	var jump_tween: Tween = create_tween().set_parallel(true)
	jump_tween.tween_property(visual_root, "position:y", 0.65, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(visual_root, "scale", Vector3(1.15, 1.2, 1.15), 0.24)
	if left_arm and right_arm:
		jump_tween.tween_property(left_arm, "rotation:x", -PI * 0.8, 0.24)
		jump_tween.tween_property(right_arm, "rotation:x", -PI * 0.8, 0.24)

	jump_tween.chain().tween_property(visual_root, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	jump_tween.parallel().tween_property(visual_root, "scale", Vector3.ONE, 0.2)
	if left_arm and right_arm:
		jump_tween.parallel().tween_property(left_arm, "rotation:x", 0.0, 0.2)
		jump_tween.parallel().tween_property(right_arm, "rotation:x", 0.0, 0.2)


## Plays a focused study posture with jotting
func play_study_animation() -> void:
	if not visual_root or not is_inside_tree():
		return
	spawn_floating_stat("📚 +0.12 CGPA!", Color(0.35, 0.85, 1.0, 1.0))
	if SoundManager:
		SoundManager.play_click()

	var study_tween: Tween = create_tween()
	study_tween.tween_property(torso_mesh, "rotation:x", 0.2, 0.2)
	if right_arm:
		for i in range(4):
			study_tween.tween_property(right_arm, "rotation:x", -0.35, 0.1)
			study_tween.tween_property(right_arm, "rotation:x", -0.15, 0.1)
	study_tween.tween_property(torso_mesh, "rotation:x", 0.0, 0.2)
	if right_arm:
		study_tween.parallel().tween_property(right_arm, "rotation:x", 0.0, 0.2)


## Plays a respectful prayer posture
func play_pray_animation() -> void:
	if not visual_root or not is_inside_tree():
		return
	spawn_floating_stat("✨ Peace of Mind!", Color(0.9, 0.7, 1.0, 1.0))
	if SoundManager:
		SoundManager.play_bell()

	var pray_tween: Tween = create_tween().set_parallel(true)
	pray_tween.tween_property(head_mesh, "rotation:x", 0.35, 0.3)
	if left_arm and right_arm:
		pray_tween.tween_property(left_arm, "rotation:z", -0.3, 0.3)
		pray_tween.tween_property(right_arm, "rotation:z", 0.3, 0.3)

	pray_tween.chain().tween_interval(0.6)
	pray_tween.chain().tween_property(head_mesh, "rotation:x", 0.0, 0.25)
	if left_arm and right_arm:
		pray_tween.parallel().tween_property(left_arm, "rotation:z", 0.0, 0.25)
		pray_tween.parallel().tween_property(right_arm, "rotation:z", 0.0, 0.25)


## Natural sitting posture on hostel bunk, dining chair, or lecture bench
func play_sit_animation(seat_node: Node3D = null) -> void:
	if not visual_root or not is_inside_tree():
		return
	cancel_emote()
	is_sitting = true
	_idle_time = 0.0
	spawn_floating_stat("🪑 Resting... +Energy", Color(0.4, 0.9, 0.6))
	if SoundManager:
		SoundManager.play_click()

	if seat_node:
		global_position = Vector3(seat_node.global_position.x, global_position.y, seat_node.global_position.z)
		visual_root.rotation.y = seat_node.global_rotation.y

	var sit_tween: Tween = create_tween().set_parallel(true)
	_active_emote_tween = sit_tween
	if torso_mesh:
		sit_tween.tween_property(torso_mesh, "position:y", 0.62, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		sit_tween.tween_property(torso_mesh, "rotation:x", 0.08, 0.28)
	if head_mesh:
		sit_tween.tween_property(head_mesh, "position:y", 1.12, 0.28)
	if hair_mesh:
		sit_tween.tween_property(hair_mesh, "position:y", 1.25, 0.28)
	if left_leg and right_leg:
		sit_tween.tween_property(left_leg, "rotation:x", -PI * 0.45, 0.28)
		sit_tween.tween_property(right_leg, "rotation:x", -PI * 0.45, 0.28)
	if left_arm and right_arm:
		sit_tween.tween_property(left_arm, "rotation:x", -0.4, 0.28)
		sit_tween.tween_property(right_arm, "rotation:x", -0.4, 0.28)

	if NetworkManager:
		NetworkManager.broadcast_emote("sit")


## Returns from seated pose back to standing
func stand_up() -> void:
	if not is_sitting:
		return
	is_sitting = false
	_idle_time = 0.0
	if _active_emote_tween and _active_emote_tween.is_valid():
		_active_emote_tween.kill()

	var stand_tw: Tween = create_tween().set_parallel(true)
	if torso_mesh:
		stand_tw.tween_property(torso_mesh, "position:y", 0.95, 0.2)
		stand_tw.tween_property(torso_mesh, "rotation:x", 0.0, 0.2)
	if head_mesh:
		stand_tw.tween_property(head_mesh, "position:y", 1.45, 0.2)
	if hair_mesh:
		stand_tw.tween_property(hair_mesh, "position:y", 1.58, 0.2)
	if left_leg and right_leg:
		stand_tw.tween_property(left_leg, "rotation:x", 0.0, 0.2)
		stand_tw.tween_property(right_leg, "rotation:x", 0.0, 0.2)
	if left_arm and right_arm:
		stand_tw.tween_property(left_arm, "rotation:x", 0.0, 0.2)
		stand_tw.tween_property(right_arm, "rotation:x", 0.0, 0.2)

	if NetworkManager:
		NetworkManager.broadcast_emote("stand")


## Authentic Nigerian campus celebration dance (Legwork / Shaku-Shaku)
func play_shaku_dance_animation() -> void:
	if not visual_root or not is_inside_tree():
		return
	if is_sitting:
		stand_up()
	cancel_emote()
	is_emoting = true
	_idle_time = 0.0
	spawn_floating_stat("💃 Gbe Body! Shaku Shaku!", Color(1.0, 0.85, 0.2))
	if SoundManager:
		SoundManager.play_coin()

	var dance_tw: Tween = create_tween()
	_active_emote_tween = dance_tw

	# 2 lively legwork cycles
	for i in range(2):
		dance_tw.tween_callback(func():
			if left_leg: left_leg.rotation.x = -0.75
			if right_leg: right_leg.rotation.x = 0.35
			if right_arm: right_arm.rotation.x = -1.1
			if left_arm: left_arm.rotation.z = -0.6
			if torso_mesh:
				torso_mesh.rotation.y = 0.25
				torso_mesh.position.y = 1.05
		)
		dance_tw.tween_interval(0.18)

		dance_tw.tween_callback(func():
			if left_leg: left_leg.rotation.x = 0.35
			if right_leg: right_leg.rotation.x = -0.75
			if left_arm: left_arm.rotation.x = -1.1
			if right_arm: right_arm.rotation.z = 0.6
			if torso_mesh:
				torso_mesh.rotation.y = -0.25
				torso_mesh.position.y = 1.05
		)
		dance_tw.tween_interval(0.18)

	# Hop jump with hands raised
	dance_tw.tween_callback(func():
		if torso_mesh:
			torso_mesh.position.y = 1.25
			torso_mesh.rotation.y = 0.0
		if left_arm and right_arm:
			left_arm.rotation.x = -2.4
			right_arm.rotation.x = -2.4
		if left_leg and right_leg:
			left_leg.rotation.x = -0.2
			right_leg.rotation.x = -0.2
	)
	dance_tw.tween_interval(0.28)

	# Settle back to standing
	dance_tw.tween_callback(func():
		cancel_emote()
	)

	if NetworkManager:
		NetworkManager.broadcast_emote("shaku")


## Friendly wave greeting to nearby coursemates
func play_wave_animation() -> void:
	if not visual_root or not is_inside_tree():
		return
	if is_sitting:
		stand_up()
	cancel_emote()
	is_emoting = true
	_idle_time = 0.0
	spawn_floating_stat("👋 How far!", Color(0.3, 0.85, 1.0))
	if SoundManager:
		SoundManager.play_bell()

	var wave_tw: Tween = create_tween()
	_active_emote_tween = wave_tw

	wave_tw.tween_callback(func():
		if right_arm:
			right_arm.rotation.x = -2.4
			right_arm.rotation.z = 0.4
		if head_mesh:
			head_mesh.rotation.z = -0.15
	)
	wave_tw.tween_interval(0.15)

	for i in range(3):
		wave_tw.tween_callback(func():
			if right_arm: right_arm.rotation.z = -0.25
		)
		wave_tw.tween_interval(0.12)
		wave_tw.tween_callback(func():
			if right_arm: right_arm.rotation.z = 0.45
		)
		wave_tw.tween_interval(0.12)

	wave_tw.tween_callback(func():
		cancel_emote()
	)

	if NetworkManager:
		NetworkManager.broadcast_emote("wave")


## Dispatches an emote by identifier and broadcasts over network
func play_emote(emote_name: String) -> void:
	match emote_name.to_lower():
		"shaku", "dance", "gbese":
			play_shaku_dance_animation()
		"wave":
			play_wave_animation()
		"sit":
			if is_sitting:
				stand_up()
			else:
				play_sit_animation()
		"study":
			play_study_animation()
			if NetworkManager: NetworkManager.broadcast_emote("study")
		"eat":
			play_eating_animation()
			if NetworkManager: NetworkManager.broadcast_emote("eat")
		"celebrate":
			play_celebrate_animation()
			if NetworkManager: NetworkManager.broadcast_emote("celebrate")
		"pray":
			play_pray_animation()
			if NetworkManager: NetworkManager.broadcast_emote("pray")
		_:
			play_wave_animation()


## Cancels any running emote and smoothly restores neutral posture
func cancel_emote() -> void:
	is_emoting = false
	if _active_emote_tween and _active_emote_tween.is_valid():
		_active_emote_tween.kill()
		_active_emote_tween = null
	if left_arm: left_arm.rotation = Vector3.ZERO
	if right_arm: right_arm.rotation = Vector3.ZERO
	if left_leg: left_leg.rotation = Vector3.ZERO
	if right_leg: right_leg.rotation = Vector3.ZERO
	if head_mesh:
		head_mesh.rotation = Vector3.ZERO
		head_mesh.position = Vector3(0, 1.45, 0)
	if hair_mesh: hair_mesh.position = Vector3(0, 1.58, 0)
	if torso_mesh:
		torso_mesh.rotation = Vector3.ZERO
		torso_mesh.position = Vector3(0, 0.95, 0)


## Subtle natural idle movements (stretch, phone check, look around)
func _trigger_idle_fidget() -> void:
	if not visual_root or not is_inside_tree() or is_sitting or is_emoting:
		return
	var choice: int = randi() % 3
	var fidget_tw: Tween = create_tween()
	match choice:
		0:
			# Phone check
			if right_arm and head_mesh:
				fidget_tw.tween_property(right_arm, "rotation:x", -1.2, 0.25)
				fidget_tw.parallel().tween_property(head_mesh, "rotation:x", 0.28, 0.25)
				fidget_tw.tween_interval(1.6)
				fidget_tw.tween_property(right_arm, "rotation:x", 0.0, 0.25)
				fidget_tw.parallel().tween_property(head_mesh, "rotation:x", 0.0, 0.25)
		1:
			# Stretch / yawn
			if left_arm and right_arm and torso_mesh:
				fidget_tw.tween_property(left_arm, "rotation:x", -2.2, 0.35)
				fidget_tw.parallel().tween_property(right_arm, "rotation:x", -2.2, 0.35)
				fidget_tw.parallel().tween_property(torso_mesh, "rotation:x", -0.15, 0.35)
				fidget_tw.tween_interval(1.0)
				fidget_tw.tween_property(left_arm, "rotation:x", 0.0, 0.3)
				fidget_tw.parallel().tween_property(right_arm, "rotation:x", 0.0, 0.3)
				fidget_tw.parallel().tween_property(torso_mesh, "rotation:x", 0.0, 0.3)
		2:
			# Campus look around
			if head_mesh:
				fidget_tw.tween_property(head_mesh, "rotation:y", 0.55, 0.3)
				fidget_tw.tween_interval(0.6)
				fidget_tw.tween_property(head_mesh, "rotation:y", -0.55, 0.4)
				fidget_tw.tween_interval(0.6)
				fidget_tw.tween_property(head_mesh, "rotation:y", 0.0, 0.25)

