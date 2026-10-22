class_name RoommateAI
extends NPC3D

## Living Hostel Roommate AI with Dynamic Daily Routine.
## Automatically switches behaviors, locations, and dialogue based on TimeSystem.hour:
## - 07:00 - 08:30: Morning prep & ironing
## - 08:30 - 15:30: Away at lectures & faculty library (leaves door note)
## - 15:30 - 19:00: Cooking spicy Indomie noodles on hot plate (shares food!)
## - 19:00 - 23:00: Night study session with past questions (shares exam hints!)
## - 23:00 - 07:00: Sleeping on bunk bed with Zzz bubble

enum RoutineState {
	MORNING_PREP,
	AWAY_AT_CLASS,
	COOKING_NOODLES,
	NIGHT_STUDY,
	SLEEPING
}

var current_state: RoutineState = RoutineState.MORNING_PREP
var indomie_shared_today: bool = false
var study_hint_shared_today: bool = false
var last_day_checked: int = 1

var dorm_note_mesh: MeshInstance3D = null
var dorm_note_label: Label3D = null


func _ready() -> void:
	super._ready()
	_setup_dorm_note()
	TimeSystem.minute_passed.connect(_on_time_minute_passed)
	_update_routine_state()


func _setup_dorm_note() -> void:
	dorm_note_mesh = MeshInstance3D.new()
	dorm_note_mesh.name = "DormNoteMesh"
	var box = BoxMesh.new()
	box.size = Vector3(0.5, 0.02, 0.4)
	dorm_note_mesh.mesh = box
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.95, 0.6) # Yellow sticky note
	dorm_note_mesh.material_override = mat
	dorm_note_mesh.position = Vector3(-4.2, 0.9, -4.8) # On bunk table
	dorm_note_mesh.visible = false

	dorm_note_label = Label3D.new()
	dorm_note_label.name = "DormNoteLabel"
	dorm_note_label.text = "📝 Roommate Note:\n'Gone for lectures & library.\nLock room when leaving!'"
	dorm_note_label.font_size = 18
	dorm_note_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dorm_note_label.position = Vector3(0, 0.35, 0)
	dorm_note_mesh.add_child(dorm_note_label)

	add_child(dorm_note_mesh)


func _on_time_minute_passed() -> void:
	if TimeSystem.day != last_day_checked:
		last_day_checked = TimeSystem.day
		indomie_shared_today = false
		study_hint_shared_today = false
	_update_routine_state()


func _update_routine_state() -> void:
	var h: int = TimeSystem.get_hour()

	var new_state: RoutineState
	if h >= 7 and h < 9:
		new_state = RoutineState.MORNING_PREP
	elif h >= 9 and h < 16:
		new_state = RoutineState.AWAY_AT_CLASS
	elif h >= 16 and h < 19:
		new_state = RoutineState.COOKING_NOODLES
	elif h >= 19 and h < 23:
		new_state = RoutineState.NIGHT_STUDY
	else:
		new_state = RoutineState.SLEEPING

	if new_state != current_state:
		current_state = new_state
		_apply_routine_behavior()


func _apply_routine_behavior() -> void:
	match current_state:
		RoutineState.MORNING_PREP:
			visible = true
			if dorm_note_mesh:
				dorm_note_mesh.visible = false
			global_position = Vector3(-4.2, 0.1, 1.2)
			target_destination = global_position
			is_moving = false
			dialogues = [
				"Good morning roomie! Ready for lectures today?",
				"I left the electric pressing iron on the study desk if you need it.",
				"Let's hurry so we can catch front seats in the lecture theatre!",
				"Remember to put your student ID card inside your pocket!"
			]

		RoutineState.AWAY_AT_CLASS:
			# Segun/Chisom is away on campus
			visible = false
			if dorm_note_mesh:
				dorm_note_mesh.visible = true
				if dorm_note_label:
					dorm_note_label.text = "📝 %s's Note:\n'Gone to Faculty lecture hall & library.\nLock the door when leaving!'" % character_name

		RoutineState.COOKING_NOODLES:
			visible = true
			if dorm_note_mesh:
				dorm_note_mesh.visible = false
			global_position = Vector3(-3.2, 0.1, -4.2)
			target_destination = global_position
			is_moving = false
			dialogues = [
				"Welcome back from classes! I'm boiling hot Indomie noodles with eggs.",
				"Today's lectures were intense! Food is almost ready.",
				"Take a warm plate of Indomie from the stove!",
				"After eating, we have to start revising today's lecture notes."
			]

		RoutineState.NIGHT_STUDY:
			visible = true
			if dorm_note_mesh:
				dorm_note_mesh.visible = false
			global_position = Vector3(3.2, 0.1, -4.2) # Next to study table
			target_destination = global_position
			is_moving = false
			dialogues = [
				"I'm solving the past 5 years of exam questions for our course.",
				"Listen to this formula: remember chapters 2 and 3 are on the test!",
				"If you want to do group study, sit down at the desk with me.",
				"Night reading hits different when you want a First Class!"
			]

		RoutineState.SLEEPING:
			visible = true
			if dorm_note_mesh:
				dorm_note_mesh.visible = false
			global_position = Vector3(-4.5, 0.8, -4.8) # On bunk bed
			target_destination = global_position
			is_moving = false
			dialogues = [
				"Zzz... (Fast asleep)",
				"Zzz... snoring softly...",
				"Mmm... turn off the desk lamp please... Zzz..."
			]


func talk() -> void:
	super.talk()

	PropBuilder3D.complete_semester_task(1)

	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	# Roommate live campus gist & peer support
	if CampusEvents and not CampusEvents.has_electricity:
		if current_player.has_method("display_notification"):
			current_player.display_notification("%s: \"Omo! NEPA has taken light again! Better preserve your phone battery!\"" % character_name)
		return

	match current_state:
		RoutineState.MORNING_PREP:
			needs.modify_faith(10.0)
			if current_player.has_method("display_notification"):
				current_player.display_notification("%s: \"You're looking sharp, roomie! Let's get front seats in the lecture hall!\" Faith +10!" % character_name)
		RoutineState.COOKING_NOODLES:
			if not indomie_shared_today:
				indomie_shared_today = true
				needs.modify_hunger(40.0)
				needs.modify_energy(20.0)
				if current_player.has_method("play_eating_animation"):
					current_player.play_eating_animation()
				if current_player.has_method("display_notification"):
					current_player.display_notification("%s shared a hot bowl of Indomie & eggs! +40 Hunger, +20 Energy!" % character_name)
			else:
				if current_player.has_method("display_notification"):
					current_player.display_notification("%s: \"Food was sweet right? Let's digest and get ready for evening prep.\"" % character_name)
		RoutineState.NIGHT_STUDY:
			if not study_hint_shared_today:
				study_hint_shared_today = true
				needs.modify_cgpa(0.08)
				if current_player.has_method("play_study_animation"):
					current_player.play_study_animation()
				if current_player.has_method("display_notification"):
					current_player.display_notification("%s explained tricky exam derivations to you! CGPA preparation +0.08!" % character_name)
			else:
				if current_player.has_method("display_notification"):
					current_player.display_notification("%s: \"Keep revising! Night study is the secret of First Class students!\"" % character_name)
		RoutineState.SLEEPING:
			if current_player.has_method("display_notification"):
				current_player.display_notification("%s is fast asleep on the bunk bed. (Zzz...)" % character_name)
