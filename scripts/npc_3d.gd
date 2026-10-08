class_name NPC3D
extends CharacterBody3D

## Lightweight campus student & lecturer NPC.
## Moves between waypoints and provides Nigerian campus banter when talked to.

@export var character_name: String = "Student"
@export var character_role: String = "Course Mate"
@export var shirt_color: Color = Color(0.85, 0.45, 0.2, 1.0)
@export var move_speed: float = 3.2
@export var patrol_radius: float = 8.0
@export var dialogues: Array[String] = [
	"Guy, how far? Did you submit that GST assignment?",
	"This cafeteria price is increasing everyday o!",
	"Have you seen the past questions for this course?",
	"I need to read before this lecturer catches me unprepared."
]

@onready var visual_root: Node3D = $Visuals
@onready var body_mesh: MeshInstance3D = $Visuals/BodyMesh
@onready var name_label: Label3D = $NameLabel
@onready var speech_label: Label3D = $SpeechLabel
@onready var speech_timer: Timer = $SpeechTimer
@onready var interact_area: Area3D = $InteractArea

var spawn_origin: Vector3 = Vector3.ZERO
var target_destination: Vector3 = Vector3.ZERO
var wait_timer: float = 0.0
var is_moving: bool = false
var current_player: CharacterBody3D = null


func _ready() -> void:
	spawn_origin = global_position
	target_destination = spawn_origin
	wait_timer = randf_range(1.0, 3.0)

	# Visual setup
	if name_label:
		name_label.text = "%s\n[%s]" % [character_name, character_role]
	if speech_label:
		speech_label.visible = false
	if speech_timer:
		speech_timer.timeout.connect(_on_speech_timeout)

	# Shirt color
	if body_mesh:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = shirt_color
		mat.roughness = 0.6
		body_mesh.set_surface_override_material(0, mat)

	# Interaction trigger setup
	if interact_area:
		interact_area.body_entered.connect(_on_body_entered)
		interact_area.body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = 0.0

	# If currently chatting with player, stop walking
	if speech_label and speech_label.visible:
		velocity.x = move_toward(velocity.x, 0.0, 10.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
		move_and_slide()
		return

	if is_moving:
		var dir_to_target: Vector3 = target_destination - global_position
		dir_to_target.y = 0.0
		var dist: float = dir_to_target.length()

		if dist < 0.6:
			# Reached destination, wait
			is_moving = false
			velocity.x = 0.0
			velocity.z = 0.0
			wait_timer = randf_range(3.0, 7.0)
		else:
			var move_dir: Vector3 = dir_to_target.normalized()
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed

			# Turn toward walking direction
			var angle: float = atan2(-move_dir.x, -move_dir.z)
			visual_root.rotation.y = lerp_angle(visual_root.rotation.y, angle, 8.0 * delta)
	else:
		wait_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 8.0 * delta)
		if wait_timer <= 0.0:
			_pick_new_waypoint()

	move_and_slide()


func _pick_new_waypoint() -> void:
	var random_offset: Vector2 = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized() * randf_range(2.0, patrol_radius)
	target_destination = spawn_origin + Vector3(random_offset.x, 0.0, random_offset.y)
	is_moving = true


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("set_interaction_target"):
		current_player = body as CharacterBody3D
		# Pass dummy interactable proxy
		var _proxy: Dictionary = {"prompt_message": "[E] Talk to %s" % character_name}
		# Player can talk


func _on_body_exited(body: Node3D) -> void:
	if body == current_player:
		current_player = null


func talk() -> void:
	if dialogues.is_empty():
		return

	var line: String = dialogues.pick_random()
	if speech_label:
		speech_label.text = "\"%s\"" % line
		speech_label.visible = true
	if speech_timer:
		speech_timer.start(4.0)

	# Face the player if nearby
	if current_player:
		var to_player: Vector3 = current_player.global_position - global_position
		to_player.y = 0.0
		if to_player.length_squared() > 0.01:
			visual_root.rotation.y = atan2(-to_player.normalized().x, -to_player.normalized().z)


func _on_speech_timeout() -> void:
	if speech_label:
		speech_label.visible = false
