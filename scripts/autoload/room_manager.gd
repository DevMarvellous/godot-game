extends Node

## Manages room transitions across campus hubs without loading entire world at once.
## Saves mobile battery, memory, and draw calls by running isolated hub environments.

signal room_changing(from_room: StringName, to_room: StringName)
signal room_loaded(room_name: StringName)

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
	&"senate": "res://scenes/rooms/senate_building.tscn"
}

var current_room: StringName = &"courtyard"
var is_transitioning: bool = false


func change_room(target_room: StringName) -> void:
	if is_transitioning or not ROOM_PATHS.has(target_room):
		return

	if current_room == target_room:
		return

	is_transitioning = true
	var prev_room: StringName = current_room
	room_changing.emit(prev_room, target_room)

	var target_path: String = ROOM_PATHS[target_room]
	var err: Error = get_tree().change_scene_to_file(target_path)
	if err == OK:
		current_room = target_room
		is_transitioning = false
		room_loaded.emit(target_room)
	else:
		is_transitioning = false
		push_error("Failed to load room scene: %s (Error %d)" % [target_path, err])
