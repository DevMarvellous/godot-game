class_name Player3D
extends CharacterBody3D

## 3D Top-Down / Isometric Player Controller.
## Movement across X/Z ground plane with smooth rotation and 3D interactions.

@export var move_speed: float = 8.0
@export var acceleration: float = 24.0
@export var gravity: float = 20.0
@export var rotation_speed: float = 12.0

@onready var visual_root: Node3D = $Visuals
@onready var needs_manager: NeedsManager = $NeedsManager
@onready var prompt_label: Label3D = $PromptLabel
@onready var notif_label: Label3D = $NotifLabel
@onready var notif_timer: Timer = $NotifTimer

var current_interactable: Interactable3D = null


func _ready() -> void:
	if prompt_label:
		prompt_label.visible = false
	if notif_label:
		notif_label.visible = false
	if notif_timer:
		notif_timer.timeout.connect(_on_notif_timeout)


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Get movement input (isometric / top-down perspective)
	var input_dir: Vector2 = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	var target_vel: Vector3 = Vector3.ZERO
	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		# Isometric ground movement: X is left/right, Z is forward/back
		target_vel = Vector3(input_dir.x, 0.0, input_dir.y) * move_speed

		# Smoothly rotate player visuals toward movement direction
		var target_angle: float = atan2(-input_dir.x, -input_dir.y)
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_angle, rotation_speed * delta)

	velocity.x = move_toward(velocity.x, target_vel.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, acceleration * delta)

	move_and_slide()

	# Interaction trigger
	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact(self)


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
	if notif_label:
		notif_label.text = msg
		notif_label.visible = true
	if notif_timer:
		notif_timer.start(2.5)


func _on_notif_timeout() -> void:
	if notif_label:
		notif_label.visible = false

