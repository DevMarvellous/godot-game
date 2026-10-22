class_name StadiumRoom
extends "res://scripts/base_room.gd"

## University Sports Complex & Football Stadium (Room 8) Controller.
## Home of the Inter-Faculty Dean's Cup:
## - Interactive 3D football with dynamic penalty kick physics
## - 400m Olympic running track for stamina and fitness training
## - Coach Balogun & Faculty Football Captain
## - Floodlight towers and PowerPro / MTN stadium pitch perimeter banners
## - Athletic exhaustion rescue with isotonic sports drink

@onready var football: RigidBody3D = get_node_or_null("StadiumFixtures/InteractiveFootball") as RigidBody3D


func _ready() -> void:
	room_name = "University Sports Complex & Football Stadium"
	room_id = &"stadium"
	super._ready()

	if SoundManager:
		SoundManager.play_whistle()


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if menu_type == &"track_sprint":
		_run_track_laps(p)
		return

	super._on_fixture_menu_requested(menu_type, p)


func _run_track_laps(p: CharacterBody3D) -> void:
	if not p:
		return
	var needs: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager
	if needs:
		needs.modify_energy(25.0)
		needs.modify_faith(20.0)
		needs.modify_hunger(-10.0)
	TimeSystem.advance_minutes(20)
	if SoundManager:
		SoundManager.play_whistle()
	if p.has_method("play_celebrate_animation"):
		p.play_celebrate_animation("🏃 400M SPRINT COMPLETE! +25 Energy!")
	if p.has_method("display_notification"):
		p.display_notification("🏃 Coach Balogun blows whistle: 'Great pace, athlete! 400m sprint clocked in record time!' Energy +25, Faith +20!")


func _on_player_passed_out(_reason: String) -> void:
	# If student collapses from athletic exhaustion, Coach Balogun revives them with cold water and isotonic drink
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_energy(50.0)
			needs.modify_hunger(30.0)
			needs.modify_faith(20.0)
		TimeSystem.advance_minutes(25)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("⚽ Coach Balogun revives you: 'Stand up, champ! Drink this cold PowerPro isotonic drink!' Restored +50 Energy!")
		player.global_position = Vector3(0, 0.1, -1.0)

