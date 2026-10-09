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
@onready var legs_mesh: MeshInstance3D = $Visuals/LegsMesh if has_node("Visuals/LegsMesh") else null
@onready var shoes_mesh: MeshInstance3D = $Visuals/ShoesMesh if has_node("Visuals/ShoesMesh") else null
@onready var left_arm: MeshInstance3D = $Visuals/LeftArm if has_node("Visuals/LeftArm") else null
@onready var right_arm: MeshInstance3D = $Visuals/RightArm if has_node("Visuals/RightArm") else null

@onready var needs_manager: NeedsManager = $NeedsManager
@onready var prompt_label: Label3D = $PromptLabel
@onready var notif_label: Label3D = $NotifLabel
@onready var notif_timer: Timer = $NotifTimer
@onready var chat_bubble: Label3D = $ChatBubble if has_node("ChatBubble") else null
@onready var chat_timer: Timer = $ChatTimer if has_node("ChatTimer") else null
@onready var camera_node: Camera3D = $Camera3D if has_node("Camera3D") else null

var current_interactable: Interactable3D = null
var walk_anim_time: float = 0.0

# Smooth Lagos Life style camera offset & interpolation
var cam_target_offset: Vector3 = Vector3(0, 3.2, 4.6)


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


func set_mobile_movement(vec: Vector2) -> void:
	mobile_input_vector = vec
	if vec != Vector2.ZERO:
		has_nav_target = false # Joystick movement overrides tap-to-move


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
	else:
		input_dir.x = Input.get_axis("move_left", "move_right")
		input_dir.y = Input.get_axis("move_up", "move_down")
		if input_dir != Vector2.ZERO:
			has_nav_target = false

	var target_vel: Vector3 = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		target_vel = Vector3(input_dir.x, 0.0, input_dir.y) * move_speed
		var target_angle: float = atan2(-input_dir.x, -input_dir.y)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, rotation_speed * delta)
	elif has_nav_target:
		# Tap to move towards target position
		var to_target: Vector3 = nav_target_pos - global_position
		to_target.y = 0.0
		var dist: float = to_target.length()
		if dist > 0.4:
			var move_dir: Vector3 = to_target.normalized()
			target_vel = move_dir * move_speed
			var target_angle: float = atan2(-move_dir.x, -move_dir.z)
			visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, rotation_speed * delta)
		else:
			has_nav_target = false

	velocity.x = move_toward(velocity.x, target_vel.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, acceleration * delta)

	move_and_slide()

	# Animate walking limbs and subtle torso bobbing
	var horiz_speed: float = Vector2(velocity.x, velocity.z).length()
	if horiz_speed > 0.3:
		walk_anim_time += delta * 12.0
		if left_arm and right_arm:
			left_arm.rotation.x = sin(walk_anim_time) * 0.45
			right_arm.rotation.x = -sin(walk_anim_time) * 0.45
		if torso_mesh and head_mesh and hair_mesh:
			var bob: float = abs(sin(walk_anim_time)) * 0.035
			torso_mesh.position.y = 0.95 + bob
			head_mesh.position.y = 1.45 + bob
			hair_mesh.position.y = 1.58 + bob
	else:
		if left_arm and right_arm:
			left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, 6.0 * delta)
			right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, 6.0 * delta)
		if torso_mesh and head_mesh and hair_mesh:
			torso_mesh.position.y = move_toward(torso_mesh.position.y, 0.95, 0.4 * delta)
			head_mesh.position.y = move_toward(head_mesh.position.y, 1.45, 0.4 * delta)
			hair_mesh.position.y = move_toward(hair_mesh.position.y, 1.58, 0.4 * delta)

	# Broadcast position and movement to online room peers
	if NetworkManager and is_inside_tree() and NetworkManager.is_online():
		var current_room: String = get_tree().current_scene.name if get_tree().current_scene else "room"
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
	const Customizer = preload("res://scripts/data/character_customizer.gd")
	const StudentProfile = preload("res://scripts/data/student_profile.gd")
	StudentProfile.load_from_disk()

	var skin_idx: int = StudentProfile.complexion_index
	var shirt_idx: int = StudentProfile.shirt_index
	var trouser_idx: int = StudentProfile.trouser_index
	var hair_idx: int = StudentProfile.hair_index

	var skin_color: Color = Customizer.SKIN_TONES[skin_idx].color
	var shirt_color: Color = Customizer.SHIRT_STYLES[shirt_idx].color
	var trouser_color: Color = Customizer.TROUSER_STYLES[trouser_idx].color
	var hair_color: Color = Customizer.HAIR_STYLES[hair_idx].color
	apply_appearance(skin_color, shirt_color, trouser_color, hair_color)


func apply_appearance(skin_color: Color, shirt_color: Color, trouser_color: Color, hair_color: Color) -> void:
	if head_mesh:
		var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
		skin_mat.albedo_color = skin_color
		skin_mat.roughness = 0.7
		head_mesh.set_surface_override_material(0, skin_mat)
	if hair_mesh:
		var hair_mat: StandardMaterial3D = StandardMaterial3D.new()
		hair_mat.albedo_color = hair_color
		hair_mat.roughness = 0.85
		hair_mesh.set_surface_override_material(0, hair_mat)
	if torso_mesh:
		var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
		shirt_mat.albedo_color = shirt_color
		shirt_mat.roughness = 0.6
		torso_mesh.set_surface_override_material(0, shirt_mat)
		if left_arm:
			left_arm.set_surface_override_material(0, shirt_mat)
		if right_arm:
			right_arm.set_surface_override_material(0, shirt_mat)
	if legs_mesh:
		var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
		leg_mat.albedo_color = trouser_color
		leg_mat.roughness = 0.75
		legs_mesh.set_surface_override_material(0, leg_mat)

