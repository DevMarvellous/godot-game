class_name Player
extends CharacterBody2D

## Top-Down Player Controller for Campus Life Simulator.
## Handles movement, interaction triggering, and feedback popups.

@export var move_speed: float = 220.0

@onready var needs_manager: NeedsManager = $NeedsManager
@onready var prompt_label: Label = $PromptLabel
@onready var notification_label: Label = $NotificationLabel
@onready var notif_timer: Timer = $NotifTimer

var current_interactable: Interactable = null


func _ready() -> void:
	prompt_label.visible = false
	notification_label.visible = false
	notif_timer.timeout.connect(_on_notif_timeout)


func _physics_process(_delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * move_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed)

	move_and_slide()

	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact(self)


func set_interaction_target(target: Interactable) -> void:
	current_interactable = target
	prompt_label.text = target.prompt_message
	prompt_label.visible = true


func clear_interaction_target(target: Interactable) -> void:
	if current_interactable == target:
		current_interactable = null
		prompt_label.visible = false


func display_notification(msg: String) -> void:
	notification_label.text = msg
	notification_label.visible = true
	notif_timer.start(2.5)


func _on_notif_timeout() -> void:
	notification_label.visible = false

