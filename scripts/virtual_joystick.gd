class_name TouchJoystick
extends Control

## Mobile Touch Virtual Joystick.
## Works on touchscreens and emulated mouse clicks.
## Outputs a normalized Vector2 direction for 3D character movement.

signal joystick_moved(output_vector: Vector2)

@export var max_clamp_distance: float = 65.0
@export var deadzone: float = 0.15

@onready var base_circle: Control = $Base
@onready var handle_nub: Control = $Base/Handle

var is_pressed: bool = false
var touch_finger_id: int = -1
var output_vector: Vector2 = Vector2.ZERO


func _ready() -> void:
	if handle_nub:
		handle_nub.position = -handle_nub.size * 0.5


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _is_point_inside(event.position) and touch_finger_id == -1:
			touch_finger_id = event.index
			is_pressed = true
			_update_handle(event.position)
		elif not event.pressed and event.index == touch_finger_id:
			_reset_joystick()

	elif event is InputEventScreenDrag and event.index == touch_finger_id:
		_update_handle(event.position)

	# Mouse fallback for PC testing
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _is_point_inside(event.position):
				is_pressed = true
				_update_handle(event.position)
			elif not event.pressed and is_pressed:
				_reset_joystick()

	elif event is InputEventMouseMotion and is_pressed:
		_update_handle(event.position)


func _is_point_inside(pos: Vector2) -> bool:
	return get_global_rect().has_point(pos)


func _update_handle(target_global_pos: Vector2) -> void:
	var base_center: Vector2 = base_circle.global_position + base_circle.size * 0.5
	var offset: Vector2 = target_global_pos - base_center

	if offset.length() > max_clamp_distance:
		offset = offset.normalized() * max_clamp_distance

	handle_nub.position = (base_circle.size * 0.5 + offset) - handle_nub.size * 0.5

	var raw_vector: Vector2 = offset / max_clamp_distance
	if raw_vector.length() < deadzone:
		output_vector = Vector2.ZERO
	else:
		output_vector = raw_vector

	joystick_moved.emit(output_vector)


func _reset_joystick() -> void:
	is_pressed = false
	touch_finger_id = -1
	output_vector = Vector2.ZERO
	handle_nub.position = (base_circle.size * 0.5) - handle_nub.size * 0.5
	joystick_moved.emit(Vector2.ZERO)
