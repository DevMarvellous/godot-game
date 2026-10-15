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
var walk_anim_time: float = 0.0

# Smooth Lagos Life style camera offset & interpolation (Elevated 3/4 Isometric)
var cam_target_offset: Vector3 = Vector3(0, 5.0, 4.8)


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
		_hide_nav_beacon()


func _unhandled_input(event: InputEvent) -> void:
	# Tap / Click anywhere on ground to walk there (Lagos Life tap navigation)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cam: Camera3D = get_viewport().get_camera_3d()
		if cam:
			var from: Vector3 = cam.project_ray_origin(event.position)
			var to: Vector3 = from + cam.project_ray_normal(event.position) * 100.0
			var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, 4) # layer 4 = Ground
			var result: Dictionary = space_state.intersect_ray(query)
			if result.has("position"):
				nav_target_pos = Vector3(result.position.x, global_position.y, result.position.z)
				has_nav_target = true
				_show_nav_beacon(result.position)


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
		_hide_nav_beacon()
	else:
		input_dir.x = Input.get_axis("move_left", "move_right")
		input_dir.y = Input.get_axis("move_up", "move_down")
		if input_dir != Vector2.ZERO:
			has_nav_target = false
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
		if dist > 0.4:
			var move_dir: Vector3 = to_target.normalized()
			target_vel = move_dir * current_move_speed
			var target_angle: float = atan2(-move_dir.x, -move_dir.z)
			visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, rotation_speed * delta)
		else:
			has_nav_target = false
			_hide_nav_beacon()

	velocity.x = move_toward(velocity.x, target_vel.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, acceleration * delta)

	move_and_slide()

	# Animate walking limbs (arms + legs swinging) and subtle torso bobbing
	var horiz_speed: float = Vector2(velocity.x, velocity.z).length()
	if horiz_speed > 0.3:
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

	# Broadcast position and movement to online room peers
	if NetworkManager and is_inside_tree() and NetworkManager.is_online():
		var current_room: String = String(get_tree().current_scene.name) if get_tree().current_scene else "room"
		NetworkManager.broadcast_transform(current_room, global_position, visual_root.rotation.y, horiz_speed > 0.3)

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


func _on_chat_received(_sender_name: String, msg: String, _peer_id: int) -> void:
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

	var start_rot: float = visual_root.rotation.y
	var full_spin_rot: float = start_rot + TAU

	# First half spin (0 to 180 degrees) with subtle wind-up crouch
	var half_tween: Tween = create_tween().set_parallel(true)
	half_tween.tween_property(visual_root, "rotation:y", start_rot + PI, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	half_tween.tween_property(visual_root, "scale", Vector3(0.92, 1.08, 0.92), 0.22)
	await half_tween.finished

	# Swap clothes at the midpoint!
	if midpoint_callback.is_valid():
		midpoint_callback.call()

	# Midpoint celebratory sparkle & chime
	if SoundManager:
		SoundManager.play_bell()

	# Second half spin (180 to 360 degrees) with celebratory bounce
	var second_tween: Tween = create_tween().set_parallel(true)
	second_tween.tween_property(visual_root, "rotation:y", full_spin_rot, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	second_tween.tween_property(visual_root, "scale", Vector3(1.15, 1.15, 1.15), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await second_tween.finished

	# Settle smoothly back to regular scale & normalize rotation
	var settle_tween: Tween = create_tween()
	settle_tween.tween_property(visual_root, "scale", Vector3.ONE, 0.12)
	visual_root.rotation.y = fmod(visual_root.rotation.y, TAU)


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
