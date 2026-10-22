class_name SenateRoom
extends "res://scripts/base_room.gd"

## University Senate Building & VC Secretariat (Room 13) Controller.
## Highest administrative authority and clearance registry on campus:
## - Dr. Mrs. Adeyemi (Deputy Registrar, Academic Affairs)
## - Baba Gani (Chief Senate Usher & Protocol)
## - Official Clearance & Academic Audit Desk
## - VC First-Class Distinction Honors Roll & Bursary
## - Rotating Senate ceiling fan

@onready var ceiling_fan: MeshInstance3D = get_node_or_null("SenateFixtures/CeilingFan") as MeshInstance3D
@onready var clearance_desk: CampusObject3D = get_node_or_null("WorldObjects/ClearanceDesk") as CampusObject3D


func _ready() -> void:
	room_name = "University Senate Building & VC Secretariat"
	room_id = &"senate"
	super._ready()

	if ceiling_fan:
		active_ceiling_fans.append(ceiling_fan)

	if clearance_desk:
		clearance_desk.interacted.connect(_on_clearance_desk_interacted)


func _on_clearance_desk_interacted() -> void:
	if not player:
		return

	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	var cgpa: float = needs.cgpa if needs else 3.50
	const ProfileStore = preload("res://scripts/data/student_profile.gd")
	var student_name: String = ProfileStore.student_name if not ProfileStore.student_name.is_empty() else "Student"

	if cgpa >= 4.50:
		if needs:
			needs.modify_money(10000)
			needs.modify_faith(40.0)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🏆 VC DISTINCTION ROLL: Dr. Mrs. Adeyemi awarded %s the Senate First-Class Bursary (+₦10,000, +40 Faith)!" % student_name)
	elif cgpa >= 3.50:
		if needs:
			needs.modify_money(2500)
			needs.modify_faith(20.0)
		if SoundManager:
			SoundManager.play_click()
		if player.has_method("display_notification"):
			player.display_notification("📜 SENATE CLEARANCE PASSED: Academic audit complete with Second Class Upper honors! (+₦2,500, +20 Faith)")
	else:
		if needs:
			needs.modify_faith(10.0)
		if SoundManager:
			SoundManager.play_click()
		if player.has_method("display_notification"):
			player.display_notification("📋 CLEARANCE VERIFIED: Matric dossiers authenticated by Deputy Registrar. Keep your CGPA rising above 3.50!")


func _on_player_passed_out(_reason: String) -> void:
	# If student collapses in Senate Chambers from stress, Protocol Officer Baba Gani assists
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_hunger(40.0)
			needs.modify_energy(45.0)
			needs.modify_faith(25.0)
		TimeSystem.advance_minutes(30)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🏛️ Protocol Officer Baba Gani assists you into the VC Protocol Lounge: 'Peace, scholar! Drink this executive malt and rest.' (+45 Energy, +40 Hunger)")
		player.global_position = Vector3(0, 0.1, 2.0)
