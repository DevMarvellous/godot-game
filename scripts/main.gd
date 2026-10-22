class_name Main
extends "res://scripts/base_room.gd"

## Central Courtyard & Academic Quad (Room 3) Controller.
## Main open-air university quad for My Campus Life.
## Connects Player3D, HUD, Mobile Controls, Noticeboards, Photocopy Kiosk, Quad Benches,
## Danfo Shuttle Terminus, ATM, and Campus Sponsor Activation.


func _ready() -> void:
	room_name = "Central Courtyard & Academic Quad"
	room_id = &"courtyard"
	super._ready()


func _on_player_passed_out(_reason: String) -> void:
	# If player passes out in the Quad, transport them back to the Hostel
	if RoomManager:
		TimeSystem.advance_minutes(30)
		RoomManager.change_room(&"hostel", false)
	elif player:
		player.global_position = Vector3(0, 0.1, 0)
