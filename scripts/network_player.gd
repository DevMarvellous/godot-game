class_name NetworkPlayer
extends CharacterBody3D

## Network Puppet Avatar representing another online student in the room.
## Smoothly interpolates position & rotation to eliminate jitter over WebSockets.
## Displays student name, matric tag, and real-time 3D speech bubble for chat.

@export var student_name: String = "Coursemate"
@export var peer_id: int = 0

var target_position: Vector3 = Vector3.ZERO
var target_rotation_y: float = 0.0
var is_moving: bool = false
var walk_anim_time: float = 0.0

@onready var visual_root: Node3D = $Visuals
@onready var torso_mesh: MeshInstance3D = $Visuals/TorsoMesh
@onready var head_mesh: MeshInstance3D = $Visuals/HeadMesh
@onready var hair_mesh: MeshInstance3D = $Visuals/HairMesh
@onready var legs_mesh: MeshInstance3D = $Visuals/LegsMesh
@onready var left_arm: MeshInstance3D = $Visuals/LeftArm
@onready var right_arm: MeshInstance3D = $Visuals/RightArm

@onready var name_label: Label3D = $NameLabel
@onready var chat_bubble: Label3D = $ChatBubble
@onready var chat_timer: Timer = $ChatTimer


func _ready() -> void:
	target_position = global_position
	if name_label:
		name_label.text = "%s\n[Online]" % student_name
	if chat_bubble:
		chat_bubble.visible = false
	if chat_timer:
		chat_timer.timeout.connect(_on_chat_timeout)


func update_network_transform(new_pos: Vector3, new_rot_y: float, moving: bool) -> void:
	target_position = new_pos
	target_rotation_y = new_rot_y
	is_moving = moving


func _process(delta: float) -> void:
	# Smoothly interpolate position and rotation
	global_position = global_position.lerp(target_position, clampf(14.0 * delta, 0.0, 1.0))
	if visual_root:
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_rotation_y, clampf(14.0 * delta, 0.0, 1.0))

	# Animate limb swinging when walking
	if is_moving:
		walk_anim_time += delta * 11.0
		if left_arm and right_arm:
			left_arm.rotation.x = sin(walk_anim_time) * 0.42
			right_arm.rotation.x = -sin(walk_anim_time) * 0.42
	else:
		if left_arm and right_arm:
			left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, 5.0 * delta)
			right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, 5.0 * delta)


func show_chat(msg: String) -> void:
	if chat_bubble:
		chat_bubble.text = "\"%s\"" % msg
		chat_bubble.visible = true
	if chat_timer:
		chat_timer.start(4.5)


func _on_chat_timeout() -> void:
	if chat_bubble:
		chat_bubble.visible = false


func apply_appearance(skin_col: Color, shirt_col: Color, trouser_col: Color, hair_col: Color) -> void:
	if head_mesh:
		var skin_mat = StandardMaterial3D.new()
		skin_mat.albedo_color = skin_col
		skin_mat.roughness = 0.7
		head_mesh.set_surface_override_material(0, skin_mat)
	if hair_mesh:
		var hair_mat = StandardMaterial3D.new()
		hair_mat.albedo_color = hair_col
		hair_mat.roughness = 0.85
		hair_mesh.set_surface_override_material(0, hair_mat)
	if torso_mesh:
		var shirt_mat = StandardMaterial3D.new()
		shirt_mat.albedo_color = shirt_col
		shirt_mat.roughness = 0.6
		torso_mesh.set_surface_override_material(0, shirt_mat)
		if left_arm: left_arm.set_surface_override_material(0, shirt_mat)
		if right_arm: right_arm.set_surface_override_material(0, shirt_mat)
	if legs_mesh:
		var leg_mat = StandardMaterial3D.new()
		leg_mat.albedo_color = trouser_col
		leg_mat.roughness = 0.75
		legs_mesh.set_surface_override_material(0, leg_mat)

