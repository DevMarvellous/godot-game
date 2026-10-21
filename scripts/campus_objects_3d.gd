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
	MINI_FRIDGE
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
			prompt_message = "[E] Sleep until 07:00 (End Day)"
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

	if label_3d:
		label_3d.text = object_name


func interact(player: CharacterBody3D) -> void:
	super.interact(player)
	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	match object_type:
		ObjectType.BED:
			const ProfileStore = preload("res://scripts/data/student_profile.gd")
			ProfileStore.load_from_disk()
			TimeSystem.sleep_until(7)
			needs.energy = needs.max_energy
			needs.stat_changed.emit(&"energy", needs.energy, needs.max_energy)
			if ProfileStore.owned_upgrades.has("hostel_fan"):
				needs.modify_faith(15.0)
				_show_feedback(player, "Slept with your rechargeable fan on! Deep, cool sleep. Energy 100%, Faith +15!")
			else:
				_show_feedback(player, "Slept until 07:00! Full Energy restored.")

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
			if SoundManager:
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
			const ProfileStore = preload("res://scripts/data/student_profile.gd")
			ProfileStore.load_from_disk()
			PropBuilder3D.advance_quest_if_matching(13, player)
			if needs.cgpa >= 4.50 and not ProfileStore.merit_scholarship_claimed:
				ProfileStore.merit_scholarship_claimed = true
				ProfileStore.save_to_disk()
				needs.modify_money(25000)
				if player.has_method("play_celebrate_animation"):
					player.play_celebrate_animation("👑 FIRST CLASS SCHOLARSHIP! +₦25,000")
				_show_feedback(player, "🎉 FIRST CLASS MERIT! University Senate awards you ₦25,000 Scholarship Allowance!")
			else:
				menu_requested.emit(&"exam", player)
				_show_feedback(player, "Senate Registry: Clearance Docket loaded for %s (%s)." % [ProfileStore.student_name, ProfileStore.matric_no])

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
			const ProfileStore = preload("res://scripts/data/student_profile.gd")
			ProfileStore.load_from_disk()
			needs.modify_faith(20.0)
			TimeSystem.advance_minutes(5)
			_show_feedback(player, "Officer Balogun salutes: 'Valid Matric ID: %s (%s). Safe journey, %s!' Faith +20!" % [ProfileStore.matric_no, ProfileStore.admitted_department, ProfileStore.student_name])

		ObjectType.DOOR_EXIT:
			menu_requested.emit(&"shuttle", player)

		ObjectType.MINI_FRIDGE:
			menu_requested.emit(&"fridge", player)


func _show_feedback(player: CharacterBody3D, msg: String) -> void:
	if player.has_method("display_notification"):
		player.display_notification(msg)
