extends Node

## Manages room transitions across campus hubs without loading entire world at once.
## Includes cinematic Danfo / Keke Napep driving transition animation for seamless campus travel.

signal room_changing(from_room: StringName, to_room: StringName)
signal room_loaded(room_name: StringName)

const TransitScreenScene = preload("res://scenes/transit_screen.tscn")
var transit_screen_instance: TransitScreen = null

const ROOM_PATHS: Dictionary = {
	&"admission": "res://scenes/admission_screen.tscn",
	&"courtyard": "res://scenes/main.tscn",
	&"hostel": "res://scenes/rooms/hostel_room.tscn",
	&"lecture": "res://scenes/rooms/lecture_hall.tscn",
	&"class": "res://scenes/rooms/lecture_hall.tscn",
	&"class2": "res://scenes/rooms/lecture_theatre_2.tscn",
	&"library": "res://scenes/rooms/library_hall.tscn",
	&"mama_put": "res://scenes/rooms/mama_put.tscn",
	&"buka": "res://scenes/rooms/mama_put.tscn",
	&"mall": "res://scenes/rooms/campus_mall.tscn",
	&"bistro": "res://scenes/rooms/campus_mall.tscn",
	&"stadium": "res://scenes/rooms/football_stadium.tscn",
	&"chapel": "res://scenes/rooms/chapel_hall.tscn",
	&"sub": "res://scenes/rooms/sub_building.tscn",
	&"market": "res://scenes/rooms/sub_building.tscn",
	&"garden": "res://scenes/rooms/campus_garden.tscn",
	&"salon": "res://scenes/rooms/barbing_salon.tscn",
	&"gate": "res://scenes/rooms/campus_gate.tscn",
	&"senate": "res://scenes/rooms/senate_building.tscn",
	&"convocation": "res://scenes/rooms/convocation_hall.tscn",
	&"tech_hub": "res://scenes/rooms/tech_hub.tscn"
}

const ROOM_NAMES: Dictionary = {
	&"admission": "Admissions Portal",
	&"courtyard": "Main Campus Quad & Courtyard",
	&"hostel": "Student Hostel (Hall 2 / Moremi)",
	&"lecture": "Faculty Lecture Theatre 1",
	&"class": "Faculty Lecture Theatre 1",
	&"class2": "Faculty Lecture Theatre 2",
	&"library": "Central University Library",
	&"mama_put": "Mama Put Food Canteen",
	&"buka": "Mama Put Food Canteen",
	&"mall": "Madam Kikelomo Campus Mall",
	&"bistro": "Madam Kikelomo Campus Mall",
	&"stadium": "Sports Stadium & Arena",
	&"chapel": "University Chapel Hall",
	&"sub": "Student Union Building (SUB)",
	&"market": "Student Union Building (SUB)",
	&"garden": "Campus Botanical Garden & Park",
	&"salon": "Executive Barber & Hair Salon",
	&"gate": "Main Campus Security Gate",
	&"senate": "Senate Administrative Building",
	&"convocation": "Great Hall of Convocation & Alumni Arena",
	&"tech_hub": "Silicon Lagoon Tech Hub & Wellness Clinic"
}

var current_room: StringName = &"courtyard"
var is_transitioning: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if TransitScreenScene:
		transit_screen_instance = TransitScreenScene.instantiate() as TransitScreen
		add_child(transit_screen_instance)


func change_room(target_room: StringName, play_drive: bool = true) -> void:
	if is_transitioning or not ROOM_PATHS.has(target_room):
		return

	if current_room == target_room:
		return

	var target_path: String = ROOM_PATHS[target_room]
	var dest_name: String = ROOM_NAMES.get(target_room, String(target_room).capitalize())
	change_room_to_path(target_path, dest_name, target_room, play_drive)


func change_room_to_path(target_path: String, dest_name: String = "", target_room_id: StringName = &"", play_drive: bool = true) -> void:
	if is_transitioning:
		return

	# Deduce name if empty
	if dest_name.is_empty():
		for r_id in ROOM_PATHS.keys():
			if ROOM_PATHS[r_id] == target_path:
				dest_name = ROOM_NAMES.get(r_id, String(r_id).capitalize())
				if target_room_id == &"":
					target_room_id = r_id
				break
	if dest_name.is_empty():
		dest_name = "Campus Zone"

	is_transitioning = true
	var prev_room: StringName = current_room
	if target_room_id != &"":
		room_changing.emit(prev_room, target_room_id)

	if play_drive and is_instance_valid(transit_screen_instance):
		transit_screen_instance.play_drive_transition(
			dest_name,
			target_path,
			func() -> void:
				var err: Error = get_tree().change_scene_to_file(target_path)
				if err == OK:
					if target_room_id != &"":
						current_room = target_room_id
					room_loaded.emit(current_room)
				else:
					push_error("Failed to load room scene: %s (Error %d)" % [target_path, err])
		)
		await transit_screen_instance.transit_finished
		is_transitioning = false
	else:
		var err: Error = get_tree().change_scene_to_file(target_path)
		if err == OK:
			if target_room_id != &"":
				current_room = target_room_id
			room_loaded.emit(current_room)
		else:
			push_error("Failed to load room scene: %s (Error %d)" % [target_path, err])
		is_transitioning = false
