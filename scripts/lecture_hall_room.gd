class_name LectureHallRoom
extends "res://scripts/base_room.gd"

## Faculty Lecture Hall 1 (LT1 - Room 5) Controller.
## Main tiered lecture theatre for academic classes:
## - Interactive tiered seating with risers and timber benches
## - Dynamic Blackboard notes that adapt to student's faculty & department
## - Dual rotating ceiling fans
## - Attendance sheet signing with Course Rep Emeka
## - Dr. Adebayo academic consultation & bonus continuous assessment marks
## - Diligent coursemate Bolanle with study hints
## - In-class exhaustion rescue with first-aid glucose

@onready var ceiling_fan_1: MeshInstance3D = get_node_or_null("LectureFixtures/CeilingFan1") as MeshInstance3D
@onready var ceiling_fan_2: MeshInstance3D = get_node_or_null("LectureFixtures/CeilingFan2") as MeshInstance3D
@onready var blackboard_notes: Label3D = get_node_or_null("LectureFixtures/BlackboardNotes") as Label3D
@onready var quiz_battle_menu: Control = get_node_or_null("MenusLayer/QuizBattleMenu") as Control

var has_consulted_lecturer: bool = false


func _ready() -> void:
	room_name = "Lecture Theatre (Faculty LT 1)"
	room_id = &"lecture"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)

	if quiz_battle_menu:
		quiz_battle_menu.tournament_closed.connect(_on_menu_closed)

	_update_blackboard_curriculum()


func _update_blackboard_curriculum() -> void:
	if not blackboard_notes:
		return

	const ProfileStore = preload("res://scripts/data/student_profile.gd")
	ProfileStore.load_from_disk()
	var fac: String = ProfileStore.admitted_faculty
	var dept: String = ProfileStore.admitted_department
	var course_code: String = "GST 101"

	match fac:
		"Faculty of Computing":
			blackboard_notes.text = "🏛️ FACULTY OF COMPUTING • CSC 101\n• Topic: Data Structures & Binary Search Trees\n• Big-O Complexity: Search = O(log n), Insert = O(log n)\n• Assignment: Implement QuickSort in Godot GDScript\n⚠️ CA TEST NEXT WEEK: 30 MARKS! ATTENDANCE REQUIRED."
		"Faculty of Engineering":
			blackboard_notes.text = "🏛️ FACULTY OF ENGINEERING • ENG 101\n• Topic: Kirchhoff's Current & Voltage Laws (KCL & KVL)\n• Circuit Formula: Σ I_in = Σ I_out | V = I × R\n• Lab: Build 12V DC Rectifier before Friday\n⚠️ CA TEST NEXT WEEK: 30 MARKS! BRING SCIENTIFIC CALCULATOR."
		"Faculty of Law":
			blackboard_notes.text = "🏛️ FACULTY OF LAW • LAW 101\n• Topic: Sources of Nigerian Law & Judicial Precedent\n• Principle: Stare Decisis & Ratio Decidendi\n• Case Study: Nafiu Rabiu v. The State (1980)\n⚠️ CA ESSAY DUE MONDAY 8:00 AM SHARP! NO PLAGIARISM."
		"Faculty of Social & Management Sciences":
			blackboard_notes.text = "🏛️ FACULTY OF SOCIAL SCIENCES • ECO 101\n• Topic: Microeconomic Equilibrium & Price Elasticity\n• Equation: Ed = (% Δ Quantity Demanded) / (% Δ Price)\n• Analysis: Impact of Fuel Subsidy on Consumer Basket\n⚠️ 30-MARK CA TEST IN 2 WEEKS! READ LIPSEY & CHRYSTAL."
		"Faculty of Basic Medical Sciences":
			blackboard_notes.text = "🏛️ BASIC MEDICAL SCIENCES • ANA 101\n• Topic: Gross Anatomy & Cardiovascular Blood Circulation\n• Vessels: Systemic Aorta → Arterioles → Capillary Bed\n• Cadaver Dissection: Thoracic cavity histology on Wednesday\n⚠️ DISSECTION COAT & FORCEPS COMPULSORY!"
		_:
			blackboard_notes.text = "🏛️ 100L GENERAL UNIVERSITY STUDIES (%s)\n• Course: %s • Topic: Academic Ethics & Study Skills\n• Continuous Assessment (CA) = 30 Marks | Exam = 70 Marks\n• Minimum 75%% Attendance Required to sit for Semester Exams!\n⚠️ REVISION MANUALS AVAILABLE AT PHOTOCOPY KIOSK." % [dept, course_code]


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if menu_type == &"attendance_sheet":
		_sign_attendance_sheet(p)
		return
	elif menu_type == &"podium_consult":
		_consult_lecturer(p)
		return
	elif menu_type == &"quiz_battle":
		_open_quiz_battle(p)
		return

	super._on_fixture_menu_requested(menu_type, p)


func _open_quiz_battle(p: CharacterBody3D) -> void:
	if not quiz_battle_menu:
		quiz_battle_menu = get_node_or_null("MenusLayer/QuizBattleMenu") as Control
	if not quiz_battle_menu:
		var ml: CanvasLayer = get_node_or_null("MenusLayer") as CanvasLayer
		if ml:
			const QuizBattleScene = preload("res://scenes/quiz_battle_menu.tscn")
			quiz_battle_menu = QuizBattleScene.instantiate() as Control
			ml.add_child(quiz_battle_menu)
			if quiz_battle_menu.has_signal("tournament_closed"):
				quiz_battle_menu.tournament_closed.connect(_on_menu_closed)
	if quiz_battle_menu:
		_close_all_active_modals(quiz_battle_menu)
		if p:
			p.set_physics_process(false)
			p.velocity = Vector3.ZERO
		if quiz_battle_menu.has_method("open_tournament"):
			quiz_battle_menu.open_tournament(p)



func _sign_attendance_sheet(p: CharacterBody3D) -> void:
	if not p:
		return
	var needs: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager
	if needs:
		needs.modify_faith(15.0)
	var lec_idx: int = Schedule.get_current_lecture_index()
	if lec_idx != -1 and not Schedule.is_attended(lec_idx):
		Schedule.mark_attended(lec_idx)
	if SoundManager:
		SoundManager.play_click()
	TimeSystem.advance_minutes(5)
	if p.has_method("display_notification"):
		p.display_notification("📋 Attendance Sheet Signed! Course Rep Emeka smiles: 'Marked present! 100% attendance intact!' Faith +15!")


func _consult_lecturer(p: CharacterBody3D) -> void:
	if not p:
		return
	var needs: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if not has_consulted_lecturer:
		has_consulted_lecturer = true
		needs.modify_cgpa(0.06)
		needs.modify_faith(10.0)
		TimeSystem.advance_minutes(10)
		if SoundManager:
			SoundManager.play_click()
		if p.has_method("display_notification"):
			p.display_notification("🎓 Academic Consultation: Dr. Adebayo explains the derivation clearly! (+0.06 CGPA Bonus, +10 Faith)!")
	else:
		if p.has_method("display_notification"):
			p.display_notification("Dr. Adebayo: 'You have consulted today, scholar! Go to your desk and practice the exercises.'")


func _on_player_passed_out(_reason: String) -> void:
	# If student collapses during lecture, Dr. Adebayo and Emeka administer first-aid glucose
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_energy(40.0)
			needs.modify_hunger(30.0)
			needs.modify_faith(15.0)
		TimeSystem.advance_minutes(20)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🏥 In-Class Rescue: Dr. Adebayo: 'Exhaustion! Emeka, give this student glucose and water immediately!' Restored +40 Energy!")
		player.global_position = Vector3(0, 0.45, -2.5)

