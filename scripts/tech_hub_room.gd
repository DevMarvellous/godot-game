class_name TechHubRoom
extends "res://scripts/base_room.gd"

## Silicon Lagoon Tech Hub & Campus Wellness Clinic (Room 16) Controller.
## Modern Nigerian campus innovation lab + student medical & mental wellness bay:
## - Tech Bro Segun (Software Lead & Hackathon Mentor), Nurse Amaka (Campus Clinic Officer)
## - Coding & Hackathon Workstation, AI Research Lab Desk, VR Esports Pod, Wellness Rest Bay
## - Dual rotating ceiling fans & emergency medical recovery if a student passes out

@onready var ceiling_fan_1: MeshInstance3D = get_node_or_null("HubFixtures/CeilingFan1") as MeshInstance3D
@onready var ceiling_fan_2: MeshInstance3D = get_node_or_null("HubFixtures/CeilingFan2") as MeshInstance3D


func _ready() -> void:
	room_name = "Silicon Lagoon Tech Hub & Wellness Clinic"
	room_id = &"tech_hub"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)


func _on_player_passed_out(_reason: String) -> void:
	# Nurse Amaka immediately treats the student in the Campus Wellness Clinic
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_hunger(55.0)
			needs.modify_energy(65.0)
			needs.modify_faith(25.0)
		TimeSystem.advance_minutes(20)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🏥 Nurse Amaka treats you at the Campus Clinic: 'Take this Lucozade Boost & Vitamin C! Don't burn out coding all night!' (+65 Energy, +55 Hunger)")
		player.global_position = Vector3(5.5, 0.1, 1.5)

