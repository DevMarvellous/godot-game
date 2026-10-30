class_name StadiumRoom
extends "res://scripts/base_room.gd"

## University Sports Complex & Football Stadium (Room 8) Controller.
## Home of the Inter-Faculty Dean's Cup:
## - Interactive 3D football with dynamic penalty kick physics
## - 400m Olympic running track for stamina and fitness training
## - Coach Balogun & Faculty Football Captain Emeka
## - Goalkeeper 3D diving physics and stadium goal net collisions
## - Floodlight towers and PowerPro / MTN stadium pitch perimeter banners
## - Athletic exhaustion rescue with isotonic sports drink

@onready var football: RigidBody3D = get_node_or_null("StadiumFixtures/InteractiveFootball") as RigidBody3D
@onready var captain_emeka: Node3D = get_node_or_null("NPCs/CaptainKunle") as Node3D


func _ready() -> void:
	room_name = "University Sports Complex & Football Stadium"
	room_id = &"stadium"
	super._ready()

	# Position Captain Emeka near goal line for penalty goalkeeping
	if captain_emeka:
		captain_emeka.global_position = Vector3(0, 0.1, -10.0)
		captain_emeka.rotation_degrees.y = 0.0

	if SoundManager:
		SoundManager.play_whistle()


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if menu_type == &"track_sprint":
		_run_track_laps(p)
		return
	elif menu_type == &"penalty":
		_open_penalty_shootout(p)
		return

	super._on_fixture_menu_requested(menu_type, p)


func _open_penalty_shootout(p: CharacterBody3D) -> void:
	if not penalty_menu and menus_layer:
		penalty_menu = PenaltyScene.instantiate()
		menus_layer.add_child(penalty_menu)
		if penalty_menu.has_signal("dialog_closed"):
			penalty_menu.dialog_closed.connect(_on_menu_closed)
		if penalty_menu.has_signal("penalty_taken"):
			penalty_menu.penalty_taken.connect(_on_penalty_physically_taken)

	if penalty_menu:
		penalty_menu.open_penalty(p)


func _on_penalty_physically_taken(corner: String, shot_power: float, _stake: int, is_goal: bool, _payout: int) -> void:
	# 1. Physically launch 3D football towards the goal net
	if football:
		football.global_position = Vector3(0, 0.4, -4.0)
		football.linear_velocity = Vector3.ZERO
		football.angular_velocity = Vector3.ZERO

		var p_ratio: float = clampf(shot_power / 100.0, 0.25, 1.25)
		var impulse := Vector3.ZERO
		var spin := Vector3.ZERO

		match corner:
			"top_left":
				impulse = Vector3(-2.2 * p_ratio, 5.8 * p_ratio, -18.0 * p_ratio)
				spin = Vector3(2.0, -9.0, 4.0)
			"roof_center":
				impulse = Vector3(0.0, 6.2 * p_ratio, -19.5 * p_ratio)
				spin = Vector3(-4.0, 0.0, 0.0)
			"top_right":
				impulse = Vector3(2.2 * p_ratio, 5.8 * p_ratio, -18.0 * p_ratio)
				spin = Vector3(2.0, 9.0, -4.0)
			"bottom_left":
				impulse = Vector3(-2.3 * p_ratio, 1.8 * p_ratio, -17.0 * p_ratio)
				spin = Vector3(1.0, -4.0, 2.0)
			"panenka_center":
				impulse = Vector3(0.0, 3.8 * p_ratio, -11.5 * p_ratio)
				spin = Vector3(-1.0, 0.0, 0.0)
			"bottom_right":
				impulse = Vector3(2.3 * p_ratio, 1.8 * p_ratio, -17.0 * p_ratio)
				spin = Vector3(1.0, 4.0, -2.0)
			_:
				impulse = Vector3(0.0, 4.5 * p_ratio, -16.0 * p_ratio)

		if shot_power > 92.0:
			# High blast over crossbar
			impulse.y *= 1.45

		football.angular_velocity = spin
		football.apply_central_impulse(impulse)

	# 2. Goalkeeper dive reaction
	if captain_emeka:
		var target_x: float = 0.0
		if not is_goal:
			# Keeper guessed correctly!
			if corner.contains("left"):
				target_x = -1.8
			elif corner.contains("right"):
				target_x = 1.8
			else:
				target_x = 0.0
		else:
			# Keeper dived opposite or wrong way!
			if corner.contains("left"):
				target_x = 1.6
			elif corner.contains("right"):
				target_x = -1.6
			else:
				target_x = 1.5 if randf() > 0.5 else -1.5

		# Tween goalkeeper dive movement
		var tw = create_tween()
		tw.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(captain_emeka, "global_position:x", target_x, 0.35)
		tw.parallel().tween_property(captain_emeka, "rotation_degrees:z", -25.0 if target_x > 0 else 25.0, 0.3)
		# Recover back to center after 1.8s
		tw.tween_interval(1.2)
		tw.tween_property(captain_emeka, "global_position:x", 0.0, 0.5)
		tw.parallel().tween_property(captain_emeka, "rotation_degrees:z", 0.0, 0.4)


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
