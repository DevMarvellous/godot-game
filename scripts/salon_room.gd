class_name SalonRoom
extends "res://scripts/base_room.gd"

## Executive Barbing & Braiding Salon (Room 10) Controller.
## Campus grooming & student drip styling center:
## - Master Sunday (Celebrity Campus Barber)
## - Hydraulic barber chairs, vanity mirrors, clipper shelves
## - Rotating ceiling fan
## - Fresh haircut morale boost & passing out rescue

@onready var ceiling_fan: MeshInstance3D = get_node_or_null("SalonDecor/CeilingFan") as MeshInstance3D


func _ready() -> void:
	room_name = "Campus VIP Barbing & Hair Braiding Salon"
	room_id = &"salon"
	super._ready()

	if ceiling_fan:
		active_ceiling_fans.append(ceiling_fan)


func _on_player_passed_out(_reason: String) -> void:
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_energy(45.0)
			needs.modify_hunger(25.0)
			needs.modify_faith(20.0)
		TimeSystem.advance_minutes(25)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("💈 Master Sunday revives you: 'Guy, take it easy! Drink this cold soft drink and relax on the leather sofa!' Restored +45 Energy!")
		player.global_position = Vector3(0, 0.1, 0)

