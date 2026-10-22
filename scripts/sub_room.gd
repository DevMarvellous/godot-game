class_name SubRoom
extends "res://scripts/base_room.gd"

## Student Union Building (SUB - Room 12) Controller.
## Main campus hub for student commerce, hustles, and recreation:
## - Comrade Ojo (Student Union President), Brother Chinedu, Mama Nkechi
## - Business centre typing gigs, POS money point, arcade snooker table
## - Dual rotating ceiling fans
## - Campus union relief & passing out rescue

@onready var ceiling_fan_1: MeshInstance3D = get_node_or_null("SUBFixtures/CeilingFan1") as MeshInstance3D
@onready var ceiling_fan_2: MeshInstance3D = get_node_or_null("SUBFixtures/CeilingFan2") as MeshInstance3D


func _ready() -> void:
	room_name = "Campus Market & Business Centre"
	room_id = &"sub"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)


func _on_player_passed_out(_reason: String) -> void:
	# If student faints in SUB from fatigue, Comrade Ojo and Mama Nkechi assist them
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_hunger(40.0)
			needs.modify_energy(40.0)
			needs.modify_faith(20.0)
		TimeSystem.advance_minutes(25)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("✊ Comrade Ojo rallies to assist you: 'Aluta comrade! Drink this cold water and biscuit from Mama Nkechi!' Restored +40 Energy!")
		player.global_position = Vector3(0, 0.1, 0)

