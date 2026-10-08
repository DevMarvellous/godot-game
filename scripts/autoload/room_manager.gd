class_name RoomManager
extends Node

## Manages room transitions across campus hubs without loading entire world at once.
## Saves mobile battery, memory, and draw calls by running isolated hub environments.

signal room_changing(from_room: StringName, to_room: StringName)
signal room_loaded(room_name: StringName)

const ROOM_PATHS: Dictionary = {
	&"courtyard": "res://scenes/main.tscn",
	&"hostel": "res://scenes/rooms/hostel_room.tscn",
	&"lecture": "res://scenes/rooms/lecture_hall.tscn",
	&"buka": "res://scenes/rooms/buka_court.tscn",
	&"chapel": "res://scenes/rooms/chapel_hall.tscn"
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

