class_name CampusShuttleDialog
extends Control

## Interactive Keke Napep & Campus Shuttle Park Transit.
## Lets students board affordable campus shuttles between distant university zones with driver banter.

signal destination_chosen(scene_path: String)
signal dialog_closed

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")

var current_player: CharacterBody3D = null

const DESTINATIONS: Array[Dictionary] = [
	{
		"name": "Main Campus Quad & Quadrangle",
		"scene": "res://scenes/main.tscn",
		"icon": "🌳",
		"fare": 100
	},
	{
		"name": "Hostel Quarters (Hall 2 / Moremi)",
		"scene": "res://scenes/rooms/hostel_room.tscn",
		"icon": "🏠",
		"fare": 100
	},
	{
		"name": "Faculty Lecture Theatre 1",
		"scene": "res://scenes/rooms/lecture_hall.tscn",
		"icon": "🎓",
		"fare": 100
	},
	{
		"name": "Faculty Lecture Theatre 2",
		"scene": "res://scenes/rooms/lecture_theatre_2.tscn",
		"icon": "🏛️",
		"fare": 100
	},
	{
		"name": "Central University Library",
		"scene": "res://scenes/rooms/library_hall.tscn",
		"icon": "📚",
		"fare": 100
	},
	{
		"name": "Mama Put Food Canteen",
		"scene": "res://scenes/rooms/mama_put.tscn",
		"icon": "🍲",
		"fare": 100
	},
	{
		"name": "Madam Kikelomo Campus Mall",
		"scene": "res://scenes/rooms/campus_mall.tscn",
		"icon": "🛍️",
		"fare": 100
	},
	{
		"name": "Senate Building & Registry",
		"scene": "res://scenes/rooms/senate_building.tscn",
		"icon": "⚖️",
		"fare": 100
	},
	{
		"name": "Sports Stadium & Arena",
		"scene": "res://scenes/rooms/football_stadium.tscn",
		"icon": "⚽",
		"fare": 100
	},
	{
		"name": "Student Union Building (SUB Arcade)",
		"scene": "res://scenes/rooms/sub_building.tscn",
		"icon": "🎱",
		"fare": 100
	},
	{
		"name": "Main Campus Gate Park",
		"scene": "res://scenes/rooms/campus_gate.tscn",
		"icon": "🚖",
		"fare": 100
	}
]

const DRIVER_BANTERS: Array[String] = [
	"\"Enter with your exact ₦100 change o! I don't have change for ₦1,000 note!\"",
	"\"Direct to Faculty and Senate! One more passenger to complete the seat!\"",
	"\"Hostel express! Jump inside before rain starts falling!\"",
	"\"Campus shuttle moving now! Safe trip to your classes!\""
]

@onready var dest_container: VBoxContainer = %DestContainer if has_node("%DestContainer") else null
@onready var driver_quote: Label = %DriverQuote if has_node("%DriverQuote") else null
@onready var close_btn: Button = %CloseBtn if has_node("%CloseBtn") else null


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_dialog)
	_build_destinations()


func open_shuttle(player: CharacterBody3D) -> void:
	current_player = player
	if driver_quote:
		driver_quote.text = DRIVER_BANTERS[randi() % DRIVER_BANTERS.size()]
	visible = true


func close_dialog() -> void:
	visible = false
	current_player = null
	dialog_closed.emit()


func _build_destinations() -> void:
	if not dest_container:
		return

	for child in dest_container.get_children():
		child.queue_free()

	for d in DESTINATIONS:
		var btn = Button.new()
		btn.text = "%s  %s  (₦%d)" % [String(d.get("icon", "🚖")), String(d.get("name", "Zone")), int(d.get("fare", 100))]
		btn.custom_minimum_size = Vector2(0, 44)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override(&"font_size", 15)
		btn.pressed.connect(_on_destination_selected.bind(d))
		dest_container.add_child(btn)


func _on_destination_selected(dest: Dictionary) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var fare: int = int(dest.get("fare", 100))
	if not needs.modify_money(-fare):
		if driver_quote:
			driver_quote.text = "\"You don't have up to ₦%d fare! Treck to class or withdraw from ATM!\"" % fare
			driver_quote.add_theme_color_override(&"font_color", Color(1.0, 0.35, 0.35))
		if SoundManager:
			SoundManager.play_alert()
		return

	TimeSystem.advance_minutes(10)
	if SoundManager:
		SoundManager.play_coin()

	if current_player.has_method("display_notification"):
		current_player.display_notification("Boarded Campus Shuttle: Arrived at %s (-₦%d)" % [dest.get("name"), fare])

	var target_scene: String = String(dest.get("scene", ""))
	visible = false
	current_player = null
	destination_chosen.emit(target_scene)

