class_name CampusObject3D
extends Interactable3D

## 3D campus fixtures: Bed, Study Desk, Cafeteria Counter, Chapel Altar, ATM.
## Tied to TimeSystem and Schedule for time-based actions and menus.

signal menu_requested(menu_type: StringName, player: CharacterBody3D)

enum ObjectType {
	BED,
	DESK,
	CAFETERIA,
	FELLOWSHIP,
	ATM,
	HUSTLE_DESK,
	SALON_CHAIR,
	WARDROBE,
	MALL_BOUTIQUE,
	SHUTTLE_STOP,
	DINING_TABLE,
	LIBRARY_CARREL,
	CHAPEL_WORSHIP,
	STADIUM_SPORTS,
	GARDEN_GAZEBO,
	SENATE_REGISTRY,
	SUB_ARCADE,
	HOSTEL_KITCHEN,
	HOSTEL_WATER,
	COURSEWORK_DESK,
	CHAPEL_PIANO,
	GATE_SECURITY,
	DOOR_EXIT,
	MINI_FRIDGE,
	HOSTEL_BOOMBOX,
	NOTICEBOARD,
	SPONSOR_STAND,
	PHOTOCOPY_KIOSK
}

@export var object_type: ObjectType = ObjectType.BED

@onready var label_3d: Label3D = $Label3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	super._ready()
	if mesh_instance:
		mesh_instance.visible = false
	PropBuilder3D.build_campus_prop(self, int(object_type))
	PropBuilder3D.configure_proximity_label(label_3d, 6.2, 24)
	update_object_display()
	TimeSystem.minute_passed.connect(_on_minute_passed)


func _on_minute_passed() -> void:
	if object_type == ObjectType.DESK:
		var lec_idx: int = Schedule.get_current_lecture_index()
		if lec_idx != -1 and not Schedule.is_attended(lec_idx):
			var lec: Dictionary = Schedule.get_lecture(lec_idx)
			prompt_message = "[E] CLASS NOW: %s" % String(lec["name"])
		else:
			prompt_message = "[E] Study & Lecture Options"
	elif object_type == ObjectType.FELLOWSHIP or object_type == ObjectType.CHAPEL_WORSHIP:
		if Schedule.is_fellowship_time():
			prompt_message = "[E] Join Fellowship (+40 Faith, 30m)"
		else:
			prompt_message = "[E] Personal Prayer (+15 Faith, 15m)"


func update_object_display() -> void:
	match object_type:
		ObjectType.BED:
			prompt_message = "[E] Power Rest in Bed (Restore 100% Energy)"
			object_name = "Hostel Bed"
		ObjectType.DESK:
			prompt_message = "[E] Study & Lecture Options"
			object_name = "Lecture & Study Desk"
		ObjectType.CAFETERIA:
			prompt_message = "[E] Open Campus Canteen Menu"
			object_name = "Mama Cashout Campus Canteen"
		ObjectType.FELLOWSHIP:
			prompt_message = "[E] Fellowship Chapel"
			object_name = "Chapel Altar"
		ObjectType.ATM:
			prompt_message = "[E] Withdraw Allowance (+₦2,000)"
			object_name = "Campus ATM"
		ObjectType.HUSTLE_DESK:
			prompt_message = "[E] Freelance Typing & Design Work"
			object_name = "Hustle Workstation"
		ObjectType.SALON_CHAIR:
			prompt_message = "[E] Get Fresh Haircut (₦1,000)"
			object_name = "Barber Styling Chair"
		ObjectType.WARDROBE:
			prompt_message = "[E] Open Wardrobe (Change Clothes & Hair)"
			object_name = "Hostel Wardrobe & Mirror"
		ObjectType.MALL_BOUTIQUE:
			prompt_message = "[E] Browse Madam Kikelomo Boutique & Mall"
			object_name = "Madam Kikelomo Boutique Counter"
		ObjectType.SHUTTLE_STOP:
			prompt_message = "[E] Board Campus Keke / Shuttle (₦100)"
			object_name = "Campus Keke & Shuttle Park"
		ObjectType.DINING_TABLE:
			prompt_message = "[E] Sit & Eat Canteen Meal / Eavesdrop on Gist"
			object_name = "Canteen Dining Spot"
		ObjectType.LIBRARY_CARREL:
			prompt_message = "[E] Quiet Past Questions & Deep Study (+0.12 CGPA)"
			object_name = "Library Study Carrel"
		ObjectType.CHAPEL_WORSHIP:
			prompt_message = "[E] Praise, Piano & Prayer (+35 Faith, Peace of Mind)"
			object_name = "Chapel Prayer Bench"
		ObjectType.STADIUM_SPORTS:
			prompt_message = "[E] Football Penalty Shootout & Drills"
			object_name = "Penalty Shootout Spot"
		ObjectType.GARDEN_GAZEBO:
			prompt_message = "[E] Relax Under Acacia Shade (+25 Energy, +20 Faith)"
			object_name = "Love Garden Relaxation Bench"
		ObjectType.SENATE_REGISTRY:
			prompt_message = "[E] Senate Academic Clearance & Scholarship Audit"
			object_name = "Senate Academic Affairs Desk"
		ObjectType.SUB_ARCADE:
			prompt_message = "[E] Play Campus Snooker & Arcade Games (₦200)"
			object_name = "Student Union Arcade & Games Table"
		ObjectType.HOSTEL_KITCHEN:
			prompt_message = "[E] Cook Indomie / Soak Garri / Hot Drink"
			object_name = "Hostel Hotplate & Kitchenette"
		ObjectType.HOSTEL_WATER:
			prompt_message = "[E] Cold Bucket Bath & Face Wash (+30 Energy)"
			object_name = "Hostel Water Jerrycan & Bucket"
		ObjectType.COURSEWORK_DESK:
			prompt_message = "[E] Department Practical Coursework Station"
			object_name = "Department Project & Coursework Station"
		ObjectType.CHAPEL_PIANO:
			prompt_message = "[E] Worship Piano & Keyboard (+40 Faith, 20m)"
			object_name = "Campus Chapel Grand Piano"
		ObjectType.GATE_SECURITY:
			prompt_message = "[E] Security Checkpoint (Show Student Matric ID)"
			object_name = "Campus Security Clearance Barrier"
		ObjectType.DOOR_EXIT:
			prompt_message = "[E] Step Outside to Campus Quad / Catch Shuttle"
			object_name = "Hostel Exit Door"
		ObjectType.MINI_FRIDGE:
			prompt_message = "[E] Open Mini-Fridge (Chilled Food & Drinks)"
			object_name = "Hostel Mini-Fridge"
		ObjectType.HOSTEL_BOOMBOX:
			prompt_message = "[E] Toggle Afrobeats & Lofi Dorm Speaker"
			object_name = "Bluetooth Boombox Speaker"
		ObjectType.NOTICEBOARD:
			prompt_message = "[E] Read Faculty Noticeboard & Timetable"
			object_name = "Departmental Noticeboard & Timetable"
		ObjectType.SPONSOR_STAND:
			prompt_message = "[E] Visit MTN Pulse 5G Sponsor Booth"
			object_name = "MTN Pulse 5G Campus Activation"
		ObjectType.PHOTOCOPY_KIOSK:
			prompt_message = "[E] Photocopy Handouts & Spiral Binding"
			object_name = "Brother Austin Photocopy & Spiral Binding"

	if label_3d:
		label_3d.text = object_name


func interact(player: CharacterBody3D) -> void:
	super.interact(player)
	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	match object_type:
		ObjectType.BED:
			StudentProfile.load_from_disk()
			var is_mp_synced: bool = OS.has_feature("web") or (NetworkManager != null and NetworkManager.get_real_player_count() > 0)
			if player.has_method("play_sleep_animation"):
				player.play_sleep_animation(self, func():
					if not is_mp_synced:
						TimeSystem.sleep_until(7)
					else:
						TimeSystem.sync_to_shared_world_clock()
					needs.energy = needs.max_energy
					needs.stat_changed.emit(&"energy", needs.energy, needs.max_energy)
					if StudentProfile.owned_upgrades.has("hostel_fan"):
						needs.modify_faith(15.0)
						_show_feedback(player, "Power rested with your rechargeable fan on! Energy 100%, Faith +15!")
					else:
						_show_feedback(player, "Power rest complete! Energy 100% restored.")
				)
			else:
				if not is_mp_synced:
					TimeSystem.sleep_until(7)
				else:
					TimeSystem.sync_to_shared_world_clock()
				needs.energy = needs.max_energy
				needs.stat_changed.emit(&"energy", needs.energy, needs.max_energy)
				if StudentProfile.owned_upgrades.has("hostel_fan"):
					needs.modify_faith(15.0)
					_show_feedback(player, "Power rested with your rechargeable fan on! Energy 100%, Faith +15!")
				else:
					_show_feedback(player, "Power rest complete! Energy 100% restored.")

		ObjectType.DESK:
			menu_requested.emit(&"study", player)

		ObjectType.CAFETERIA:
			menu_requested.emit(&"food", player)

		ObjectType.FELLOWSHIP:
			if Schedule.is_fellowship_time():
				needs.modify_faith(40.0)
				needs.modify_energy(10.0)
				TimeSystem.advance_minutes(30)
				_show_feedback(player, "Blessed fellowship hour! Faith +40, Energy +10")
			else:
				needs.modify_faith(15.0)
				TimeSystem.advance_minutes(15)
				_show_feedback(player, "Quiet time & prayer! Faith +15")

		ObjectType.ATM:
			needs.modify_money(2000)
			TimeSystem.advance_minutes(5)
			_show_feedback(player, "Allowance received! +₦2,000")

		ObjectType.HUSTLE_DESK:
			menu_requested.emit(&"gigs", player)

		ObjectType.SALON_CHAIR:
			menu_requested.emit(&"salon", player)
		ObjectType.WARDROBE:
			menu_requested.emit(&"wardrobe", player)
		ObjectType.MALL_BOUTIQUE:
			menu_requested.emit(&"mall", player)
		ObjectType.SHUTTLE_STOP:
			menu_requested.emit(&"shuttle", player)

		ObjectType.DINING_TABLE:
			if needs.modify_money(-300):
				needs.modify_hunger(35.0)
				needs.modify_energy(20.0)
				TimeSystem.advance_minutes(25)
				if SoundManager:
					SoundManager.play_sizzle()
				if player.has_method("play_eating_animation"):
					player.play_eating_animation()
				const GISTS: Array[String] = [
					"Overheard at table: 'The past questions in the library carrel have the exact questions from last semester!'",
					"Coursemate banter: 'Mama Cashout jollof rice is the only reason I survived 8 AM calculus!'",
					"Campus gist: 'The Student Union President Comrade Ojo is submitting an electricity petition today!'",
					"Exam whisper: 'The lecturer announced the test will cover chapters 1 to 4 this week!'"
				]
				var gist_msg: String = GISTS[randi() % GISTS.size()]
				_show_feedback(player, "Ate canteen meal & zobo (-₦300)! %s" % gist_msg)
			else:
				needs.modify_energy(10.0)
				TimeSystem.advance_minutes(15)
				_show_feedback(player, "Rested at dining table! Overheard: 'Study hard, semester exams start soon!'")

		ObjectType.LIBRARY_CARREL:
			menu_requested.emit(&"library_study", player)

		ObjectType.CHAPEL_WORSHIP:
			needs.modify_faith(35.0)
			needs.modify_energy(15.0)
			TimeSystem.advance_minutes(20)
			PropBuilder3D.advance_quest_if_matching(10, player)
			if player.has_method("play_pray_animation"):
				player.play_pray_animation()
			_show_feedback(player, "Deep worship and prayer! Peace of Mind granted. Faith +35, Energy +15!")

		ObjectType.STADIUM_SPORTS:
			TimeSystem.advance_minutes(25)
			if player.has_method("play_penalty_kick_animation"):
				player.play_penalty_kick_animation()
			elif SoundManager:
				SoundManager.play_whistle()
			# Physically kick the 3D football towards the goal net!
			var ball: RigidBody3D = get_tree().current_scene.get_node_or_null("StadiumFixtures/InteractiveFootball") as RigidBody3D
			if ball:
				ball.global_position = Vector3(0, 0.4, -4.0)
				ball.linear_velocity = Vector3.ZERO
				ball.angular_velocity = Vector3.ZERO
				ball.apply_central_impulse(Vector3(randf_range(-3.5, 3.5), 7.2, -18.0))

			PropBuilder3D.advance_quest_if_matching(5, player)
			if randi() % 100 < 70:
				needs.modify_money(1000)
				needs.modify_energy(15.0)
				if player.has_method("play_celebrate_animation"):
					player.play_celebrate_animation("⚽ GOAL! +₦1,000")
				_show_feedback(player, "GOAL! Curled into top corner! Coach awards you ₦1,000 & Athletic Fame!")
			else:
				needs.modify_energy(10.0)
				_show_feedback(player, "Good penalty strike! Sweated out all the exam fatigue. Energy +10!")

		ObjectType.GARDEN_GAZEBO:
			needs.modify_energy(25.0)
			needs.modify_faith(20.0)
			TimeSystem.advance_minutes(20)
			if player.has_method("play_pray_animation"):
				player.play_pray_animation()
			_show_feedback(player, "Relaxed under the cool park shade with gentle breeze. Stress 0%!")

		ObjectType.SENATE_REGISTRY:
			StudentProfile.load_from_disk()
			PropBuilder3D.advance_quest_if_matching(13, player)
			if needs.cgpa >= 4.50 and not StudentProfile.merit_scholarship_claimed:
				StudentProfile.merit_scholarship_claimed = true
				StudentProfile.save_to_disk()
				needs.modify_money(25000)
				if player.has_method("play_celebrate_animation"):
					player.play_celebrate_animation("👑 FIRST CLASS SCHOLARSHIP! +₦25,000")
				_show_feedback(player, "🎉 FIRST CLASS MERIT! University Senate awards you ₦25,000 Scholarship Allowance!")
			else:
				menu_requested.emit(&"exam", player)
				_show_feedback(player, "Senate Registry: Clearance Docket loaded for %s (%s)." % [StudentProfile.student_name, StudentProfile.matric_no])

		ObjectType.SUB_ARCADE:
			menu_requested.emit(&"snooker", player)

		ObjectType.HOSTEL_KITCHEN:
			menu_requested.emit(&"hostel_cooking", player)

		ObjectType.HOSTEL_WATER:
			needs.modify_energy(30.0)
			TimeSystem.advance_minutes(10)
			if player.has_method("play_dressing_animation"):
				player.play_dressing_animation()
			_show_feedback(player, "Took a cold bucket bath! Morning sleepiness washed away. Energy +30%!")

		ObjectType.COURSEWORK_DESK:
			menu_requested.emit(&"coursework", player)

		ObjectType.CHAPEL_PIANO:
			needs.modify_faith(40.0)
			needs.modify_energy(15.0)
			TimeSystem.advance_minutes(20)
			if player.has_method("play_pray_animation"):
				player.play_pray_animation()
			_show_feedback(player, "Played uplifting hymns on the chapel piano! Faith +40, Energy +15!")

		ObjectType.GATE_SECURITY:
			StudentProfile.load_from_disk()
			needs.modify_faith(20.0)
			TimeSystem.advance_minutes(5)
			if SoundManager:
				SoundManager.play_bell()
			# Lift the boom barrier arm smoothly
			var gate_barrier = get_node_or_null("ProceduralProp")
			if gate_barrier:
				var tw = create_tween()
				tw.tween_property(gate_barrier, "rotation_degrees:z", 75.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw.tween_interval(3.0)
				tw.tween_property(gate_barrier, "rotation_degrees:z", 0.0, 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			_show_feedback(player, "Officer Balogun salutes: 'Valid Matric ID: %s (%s). Safe journey, %s!' Gate barrier lifted! Faith +20!" % [StudentProfile.matric_no, StudentProfile.admitted_department, StudentProfile.student_name])

		ObjectType.DOOR_EXIT:
			menu_requested.emit(&"shuttle", player)

		ObjectType.MINI_FRIDGE:
			menu_requested.emit(&"fridge", player)

		ObjectType.HOSTEL_BOOMBOX:
			if SoundManager:
				var is_playing: bool = SoundManager.toggle_boombox()
				if is_playing:
					needs.modify_faith(15.0)
					if player.has_method("play_celebrate_animation"):
						player.play_celebrate_animation("🎶 CHILL AFROBEATS!")
					_show_feedback(player, "🎶 Bluetooth Boombox ON! Relaxing Afrobeats & Lofi dorm vibes! Faith +15!")
				else:
					_show_feedback(player, "🔇 Bluetooth Boombox paused.")

		ObjectType.NOTICEBOARD:
			StudentProfile.load_from_disk()
			needs.modify_faith(15.0)
			TimeSystem.advance_minutes(10)
			if SoundManager:
				SoundManager.play_click()
			var lec_idx: int = Schedule.get_current_lecture_index()
			var tip: String = "No lectures right now. Final exam revision is ongoing in the Library!"
			if lec_idx != -1:
				var lec = Schedule.get_lecture(lec_idx)
				tip = "ACTIVE LECTURE: %s at Faculty Hall LT1!" % String(lec.get("name", "Lecture"))
			_show_feedback(player, "📋 NOTICEBOARD: %s | Dean's Honour Roll posted. Faith +15!" % tip)

		ObjectType.SPONSOR_STAND:
			if AdManager:
				AdManager.show_rewarded_ad("quad_sponsor", player)
			else:
				needs.modify_money(1500)
				_show_feedback(player, "Visited MTN Pulse Booth! +₦1,500 promo airtime allowance!")

		ObjectType.PHOTOCOPY_KIOSK:
			if needs.money >= 300:
				needs.modify_money(-300)
				needs.modify_cgpa(0.04)
				needs.modify_energy(-5.0)
				TimeSystem.advance_minutes(15)
				if SoundManager:
					SoundManager.play_click()
				_show_feedback(player, "Brother Austin printed & stapled your Course Handout Pack (-₦300)! Study Boost! CGPA +0.04!")
			else:
				needs.modify_money(1200)
				needs.modify_energy(-15.0)
				TimeSystem.advance_minutes(25)
				_show_feedback(player, "Assisted Brother Austin with spiral binding! Earned ₦1,200 quick hustle cash!")


func _show_feedback(player: CharacterBody3D, msg: String) -> void:
	if player.has_method("display_notification"):
		player.display_notification(msg)
