class_name TransitScreen
extends CanvasLayer

## Fullscreen 2D Driving Animation Transition for Campus Travel.
## Replaces abrupt teleportation with an authentic Nigerian campus shuttle drive
## complete with road stripes, suspension bounce, spinning wheels, and driver banter.

signal transit_finished

@onready var backdrop: ColorRect = $Backdrop
@onready var road_rect: ColorRect = $Road
@onready var road_markings: Control = $Road/Markings
@onready var vehicle_root: Control = $VehicleRoot
@onready var bus_body: PanelContainer = $VehicleRoot/BusBody
@onready var destination_label: Label = %DestinationLabel
@onready var banter_label: Label = %BanterLabel
@onready var fare_label: Label = %FareLabel

var is_animating: bool = false
var anim_time: float = 0.0
var road_speed: float = 750.0

const DRIVER_BANTERS: Array[String] = [
	"📢 Driver: \"Hold your exact ₦100 change o! I don't have change for ₦1,000 note!\"",
	"📢 Conductor: \"Direct to Faculty! One more passenger to complete the back seat!\"",
	"📢 Driver: \"Hold your bags tight, major speed bumps ahead by Senate gate!\"",
	"📻 Campus FM 99.5: Playing Burna Boy & Asake student hits 🎵",
	"📢 Conductor: \"Hostel express! Jump inside before the afternoon rain starts!\"",
	"🍃 Gentle campus breeze blowing through the open bus window..."
]


func _ready() -> void:
	visible = false
	layer = 100 # Always on top of all 3D rooms and UI HUDs


func _process(delta: float) -> void:
	if not is_animating:
		return

	anim_time += delta

	# 1. Road markings high-speed scrolling
	if road_markings:
		for dash in road_markings.get_children():
			dash.position.x -= road_speed * delta
			if dash.position.x < -80.0:
				dash.position.x += 160.0 * 6.0 # Wrap around seamlessly

	# 2. Authentic Danfo / Shuttle bumpy road suspension bob
	if vehicle_root and bus_body:
		var bounce: float = sin(anim_time * 24.0) * 3.5 + cos(anim_time * 14.0) * 1.8
		bus_body.position.y = bounce
		var rw: Control = vehicle_root.get_node_or_null("RearWheel") as Control
		var fw: Control = vehicle_root.get_node_or_null("FrontWheel") as Control
		if rw:
			rw.position.y = 84.0 + bounce * 0.45
		if fw:
			fw.position.y = 84.0 + bounce * 0.45


func play_drive_transition(dest_name: String, target_scene_path: String, on_scene_loaded_callback: Callable = Callable()) -> void:
	visible = true
	is_animating = true
	anim_time = 0.0

	# Setup destination and audio
	if destination_label:
		destination_label.text = "🚖 CAMPUS SHUTTLE ➡️ %s" % dest_name.to_upper()
	if banter_label:
		banter_label.text = DRIVER_BANTERS[randi() % DRIVER_BANTERS.size()]
	if fare_label:
		fare_label.text = "Campus Transit Fare: ₦100 | Travel Time: 3 Mins"

	SoundManager.play_transit_horn()

	# Initial setup: start offscreen to the left
	backdrop.modulate.a = 0.0
	var vp_width: float = get_viewport().get_visible_rect().size.x
	var center_x: float = (vp_width * 0.5) - 130.0
	vehicle_root.position.x = -320.0

	# 1. Drive in from left to center
	var tw: Tween = create_tween().set_parallel(true)
	tw.tween_property(backdrop, "modulate:a", 1.0, 0.25)
	tw.tween_property(vehicle_root, "position:x", center_x, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished

	# 2. Cruise at center while scene loads
	await get_tree().create_timer(0.65).timeout

	# Execute scene change while fully covered by the transit screen
	if on_scene_loaded_callback.is_valid():
		on_scene_loaded_callback.call()
	elif not target_scene_path.is_empty():
		get_tree().change_scene_to_file(target_scene_path)

	# 3. Accelerate off-screen to the right and fade out backdrop
	var tw_out: Tween = create_tween().set_parallel(true)
	tw_out.tween_property(vehicle_root, "position:x", vp_width + 150.0, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw_out.tween_property(backdrop, "modulate:a", 0.0, 0.45).set_delay(0.1)
	await tw_out.finished

	is_animating = false
	visible = false
	transit_finished.emit()

