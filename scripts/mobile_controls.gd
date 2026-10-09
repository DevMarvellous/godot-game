class_name MobileControls
extends CanvasLayer

## Mobile On-Screen Controls: Virtual Joystick + Action Button + Transit Map.
## Designed specifically for phone screens and mobile web browsers.

signal transit_requested(destination_name: StringName)
signal phone_requested

@onready var joystick: TouchJoystick = %VirtualJoystick
@onready var interact_btn: Button = %InteractButton
@onready var map_btn: Button = %MapButton
@onready var phone_btn: Button = %PhoneButton
@onready var transit_sheet: PanelContainer = %TransitSheet

var bound_player: Player3D = null


func _ready() -> void:
	if joystick:
		joystick.joystick_moved.connect(_on_joystick_moved)
	if interact_btn:
		interact_btn.pressed.connect(_on_interact_pressed)
	if map_btn:
		map_btn.pressed.connect(_toggle_transit_sheet)
	if phone_btn:
		phone_btn.pressed.connect(_on_phone_pressed)
	if transit_sheet:
		transit_sheet.visible = false

	# Wire transit quick-travel buttons
	_wire_transit_btn(%HostelBtn, &"hostel")
	_wire_transit_btn(%BukaBtn, &"buka")
	_wire_transit_btn(%ClassBtn, &"class")
	_wire_transit_btn(%Class2Btn, &"class2")
	_wire_transit_btn(%LibraryBtn, &"library")
	_wire_transit_btn(%ChapelBtn, &"chapel")
	_wire_transit_btn(%SUBBtn, &"sub")
	_wire_transit_btn(%GardenBtn, &"garden")
	_wire_transit_btn(%SalonBtn, &"salon")
	_wire_transit_btn(%ATMBtn, &"atm")
	_wire_transit_btn(%CloseMapBtn, &"close")


func _wire_transit_btn(btn: Button, dest: StringName) -> void:
	if btn:
		btn.pressed.connect(_on_transit_dest_pressed.bind(dest))


func bind_player(p: Player3D) -> void:
	bound_player = p


func _process(_delta: float) -> void:
	# Light up the interact button when player is near something!
	if not interact_btn or not bound_player:
		return

	if bound_player.current_interactable != null:
		interact_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
		interact_btn.text = "INTERACT\n[TAP]"
	else:
		interact_btn.modulate = Color(1.0, 1.0, 1.0, 0.45)
		interact_btn.text = "INTERACT"


func _on_joystick_moved(vec: Vector2) -> void:
	if bound_player:
		bound_player.set_mobile_movement(vec)


func _on_interact_pressed() -> void:
	if bound_player:
		bound_player.trigger_interaction()


func _toggle_transit_sheet() -> void:
	if transit_sheet:
		transit_sheet.visible = not transit_sheet.visible


func _on_phone_pressed() -> void:
	phone_requested.emit()


func _on_transit_dest_pressed(dest: StringName) -> void:
	if transit_sheet:
		transit_sheet.visible = false
	if dest != &"close":
		transit_requested.emit(dest)
