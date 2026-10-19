class_name ExamHallMenu
extends Control

## Comprehensive Final Semester Examination Sitting & Official Senate Statement of Results.
## Combines transparent activity marks:
## - Class Attendance: 20 Marks
## - Department Coursework / Practical Project: 30 Marks
## - Library Archives & Revision Mastery: 20 Marks
## - Final Written Hall Exam Paper: 30 Marks
## Total = 100 Marks ➔ Official University Letter Grade (A, B, C, D, E, F) and CGPA Calculation.

signal exam_completed(total_score: float, grade_letter: String, new_cgpa: float)
signal menu_closed

const StudentProfile = preload("res://scripts/data/student_profile.gd")
const StudentCoursework = preload("res://scripts/data/student_coursework.gd")
const LectureContent = preload("res://scripts/data/lecture_content_data.gd")

@onready var close_btn: Button = %CloseBtn
@onready var exam_header_label: Label = %ExamHeaderLabel
@onready var candidate_docket_label: Label = %CandidateDocketLabel

# Breakdown labels
@onready var attendance_score_label: Label = %AttendanceScoreLabel
@onready var coursework_score_label: Label = %CourseworkScoreLabel
@onready var library_score_label: Label = %LibraryScoreLabel
@onready var exam_paper_score_label: Label = %ExamPaperScoreLabel
@onready var total_pre_exam_label: Label = %TotalPreExamLabel

# Exam paper view
@onready var exam_paper_panel: PanelContainer = %ExamPaperPanel
@onready var question_progress_label: Label = %QuestionProgressLabel
@onready var question_text: Label = %QuestionText
@onready var scholar_hint_label: Label = %ScholarHintLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var expo_stealth_btn: Button = %ExpoStealthBtn

# Results view
@onready var results_panel: PanelContainer = %ResultsPanel
@onready var results_transcript_text: Label = %ResultsTranscriptText
@onready var advance_semester_btn: Button = %AdvanceSemesterBtn

var current_player: CharacterBody3D = null
var current_course_data: Dictionary = {}

# Marks calculation
var marks_attendance: float = 0.0
var marks_coursework: float = 0.0
var marks_library: float = 0.0
var marks_exam_paper: float = 0.0

# Exam questions
var questions_list: Array = []
var current_q_idx: int = 0
var exam_correct_count: int = 0
var expo_bonus_active: bool = false


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_exam)
	if expo_stealth_btn:
		expo_stealth_btn.pressed.connect(_on_expo_stealth_pressed)
	if advance_semester_btn:
		advance_semester_btn.pressed.connect(_on_advance_semester_pressed)


func open_exam(player: CharacterBody3D) -> void:
	current_player = player
	StudentProfile.load_from_disk()

	var dept: String = StudentProfile.admitted_department
	current_course_data = LectureContent.get_lecture_for_department(dept)

	# Calculate transparent marks
	_calculate_continuous_assessment()

	# Generate 3 exam questions based on department
	_generate_exam_questions()
	current_q_idx = 0
	exam_correct_count = 0
	expo_bonus_active = false

	if exam_header_label:
		exam_header_label.text = "🏛️ %s FINAL SEMESTER EXAMINATION (100 MARKS)" % current_course_data.get("code", "GST 101")

	if candidate_docket_label:
		candidate_docket_label.text = """CANDIDATE: %s | MATRIC: %s
PROGRAMME: %s (%d Level, Semester %d)
CHIEF INVIGILATOR: Dr. Adebayo & Faculty Examination Board""" % [
			StudentProfile.student_name,
			StudentProfile.matric_no,
			StudentProfile.admitted_course_title,
			StudentProfile.current_level,
			StudentProfile.current_semester
		]

	_update_breakdown_display()

	if results_panel:
		results_panel.visible = false
	if exam_paper_panel:
		exam_paper_panel.visible = true

	_load_exam_question(0)
	visible = true

	if SoundManager:
		SoundManager.play_bell()


func _calculate_continuous_assessment() -> void:
	# 1. Attendance: Out of 20 Marks
	var lecs: Array = Schedule.get_lectures() if Schedule else []
	var attended_count: int = 0
	for i in range(lecs.size()):
		if Schedule and Schedule.is_attended(i):
			attended_count += 1
	var att_pct: float = float(attended_count) / float(max(lecs.size(), 1))
	marks_attendance = clampf(att_pct * 20.0, 10.0, 20.0) # Attending earns 10-20 marks

	# 2. Practical Coursework: Out of 30 Marks
	var cw_pct: float = StudentCoursework.get_project_progress() / 100.0
	marks_coursework = clampf(cw_pct * 30.0, 12.0, 30.0)

	# 3. Library Revision: Out of 20 Marks
	# Based on current player CGPA and study consistency
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager if current_player else null
	var current_cgpa: float = needs.cgpa if needs else 3.50
	var lib_ratio: float = clampf(current_cgpa / 5.0, 0.4, 1.0)
	marks_library = lib_ratio * 20.0

	marks_exam_paper = 0.0


func _update_breakdown_display() -> void:
	if attendance_score_label:
		attendance_score_label.text = "Attendance: %.1f / 20" % marks_attendance
	if coursework_score_label:
		coursework_score_label.text = "Coursework: %.1f / 30" % marks_coursework
	if library_score_label:
		library_score_label.text = "Library Revision: %.1f / 20" % marks_library
	if exam_paper_score_label:
		exam_paper_score_label.text = "Final Exam: Pending / 30"
	if total_pre_exam_label:
		var ca_total: float = marks_attendance + marks_coursework + marks_library
		total_pre_exam_label.text = "Continuous Assessment (CA) Subtotal: %.1f / 70 Marks" % ca_total


func _generate_exam_questions() -> void:
	var code: String = current_course_data.get("code", "GST 101")
	var qte_jot: String = current_course_data.get("qte_jot", "Key Principle")
	var pq: Dictionary = current_course_data.get("pop_question", {})

	questions_list = [
		{
			"q": "Question 1: In %s, what is the core functional principle regarding: '%s'?" % [code, qte_jot],
			"options": [
				"Consistent systematic execution according to fundamental theory",
				"Random arbitrary trial and error without documentation",
				"Ignoring standard constraints and boundary conditions"
			],
			"correct": 0,
			"hint": "💡 Covered during lecture blackboard notes and textbook revision!"
		},
		{
			"q": "Question 2: %s" % String(pq.get("question", "What is the standard methodology in this discipline?")),
			"options": pq.get("options", ["Primary Theoretical Rule", "Unverified Rumour", "Skip Procedure"]),
			"correct": int(pq.get("correct", 0)),
			"hint": "💡 Dr. Adebayo highlighted this formula specifically during class!"
		},
		{
			"q": "Question 3: Professional Ethics & Quality Standards: What is required when submitting final project findings?",
			"options": [
				"Rigorous integrity, verified references, and zero plagiarism",
				"Copy-pasting from Wikipedia without acknowledgment",
				"Paying an agent to forge laboratory data"
			],
			"correct": 0,
			"hint": "💡 University Senate strictly enforces the academic integrity code."
		}
	]


func _load_exam_question(idx: int) -> void:
	if idx >= questions_list.size():
		_finish_exam_paper()
		return

	current_q_idx = idx
	var q_data: Dictionary = questions_list[idx]

	if question_progress_label:
		question_progress_label.text = "EXAM QUESTION %d OF %d (10 MARKS EACH)" % [idx + 1, questions_list.size()]
	if question_text:
		question_text.text = String(q_data["q"])

	# Show scholar hint if player has good coursework / library revision
	if scholar_hint_label:
		var has_scholar_edge: bool = (marks_coursework >= 20.0 or marks_library >= 14.0)
		scholar_hint_label.visible = has_scholar_edge
		scholar_hint_label.text = String(q_data.get("hint", ""))

	# Clear previous options
	if options_container:
		for child: Node in options_container.get_children():
			child.queue_free()

		var opts: Array = q_data["options"]
		var correct_idx: int = int(q_data["correct"])

		for i in range(opts.size()):
			var btn: Button = Button.new()
			btn.text = "%c) %s" % [65 + i, String(opts[i])]
			btn.custom_minimum_size = Vector2(0, 48)
			btn.add_theme_font_size_override(&"font_size", 14)
			btn.pressed.connect(_on_answer_chosen.bind(i == correct_idx))
			options_container.add_child(btn)


func _on_answer_chosen(is_correct: bool) -> void:
	if is_correct:
		exam_correct_count += 1
		if SoundManager: SoundManager.play_coin()
	else:
		if SoundManager: SoundManager.play_click()

	current_q_idx += 1
	_load_exam_question(current_q_idx)


func _on_expo_stealth_pressed() -> void:
	# Quick-tension stealth expo: 75% success if alert, 25% risk
	if expo_bonus_active:
		return

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager if current_player else null
	if randf() < 0.75:
		expo_bonus_active = true
		exam_correct_count = max(exam_correct_count + 1, 3)
		if expo_stealth_btn:
			expo_stealth_btn.disabled = true
			expo_stealth_btn.text = "✓ Expo Sheet Consulted (+10 Marks)"
		if SoundManager: SoundManager.play_coin()
		if current_player and current_player.has_method("display_notification"):
			current_player.display_notification("🤫 Sneaked formula from calculator slip safely! +10 Marks")
	else:
		if SoundManager: SoundManager.play_alert()
		if needs:
			needs.modify_faith(-20.0)
		if expo_stealth_btn:
			expo_stealth_btn.disabled = true
			expo_stealth_btn.text = "⚠️ Invigilator Eyed You! (Warning)"
		if current_player and current_player.has_method("display_notification"):
			current_player.display_notification("Dr. Adebayo glared at your desk! Put the expo away immediately!")


func _finish_exam_paper() -> void:
	if exam_paper_panel:
		exam_paper_panel.visible = false

	# Calculate written paper score (out of 30 marks)
	marks_exam_paper = float(exam_correct_count) * 10.0
	if expo_bonus_active:
		marks_exam_paper = minf(30.0, marks_exam_paper + 5.0)

	var total_score: float = marks_attendance + marks_coursework + marks_library + marks_exam_paper
	total_score = clampf(total_score, 0.0, 100.0)

	var grade_letter: String = _get_letter_grade(total_score)
	var grade_point: float = _get_grade_point(grade_letter)

	# Update student CGPA in NeedsManager
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager if current_player else null
	var new_cgpa: float = 3.50
	if needs:
		# Smooth cumulative average with semester grade point
		new_cgpa = clampf((needs.cgpa * 0.7) + (grade_point * 0.3), 1.0, 5.0)
		needs.cgpa = new_cgpa
		needs.stat_changed.emit(&"cgpa", needs.cgpa, 5.0)
		needs.modify_energy(-25.0)

	# 3D player animations
	if current_player:
		if total_score >= 70.0 and current_player.has_method("play_celebrate_animation"):
			current_player.play_celebrate_animation("🎉 FIRST CLASS DISTINCTION! %d/100" % int(total_score))
		elif current_player.has_method("play_study_animation"):
			current_player.play_study_animation()

	if SoundManager:
		SoundManager.play_bell()

	# Render Official University Transcript
	if results_panel and results_transcript_text:
		results_panel.visible = true
		var dept: String = StudentProfile.admitted_department
		var sem_str: String = "Semester %d" % StudentProfile.current_semester
		var lvl_str: String = "%d Level" % StudentProfile.current_level

		results_transcript_text.text = """═══════════════════════════════════════════════════════
   OFFICIAL UNIVERSITY SENATE STATEMENT OF RESULTS
═══════════════════════════════════════════════════════
Candidate: %s  |  Matric No: %s
Faculty: %s  |  Dept: %s  |  %s, %s
Course: %s - %s

ASSESSMENT COMPONENT BREAKDOWN:
• Lecture Attendance & Roll Call (20%%):  %.1f / 20.0 Marks
• Continuous Assessment & Coursework (30%%): %.1f / 30.0 Marks
• Library Revision & Past Questions (20%%): %.1f / 20.0 Marks
• Final Written Examination Paper (30%%):  %.1f / 30.0 Marks
───────────────────────────────────────────────────────
TOTAL COMPOSITE SCORE:  %d / 100 MARKS
OFFICIAL LETTER GRADE:  GRADE '%s' (Points: %.1f / 5.00)
SEMESTER CUMULATIVE GPA: %.2f / 5.00 [%s]

SENATE ENDORSEMENT:
[SEAL] Cleared & Approved by University Examination Board.
═══════════════════════════════════════════════════════""" % [
			StudentProfile.student_name,
			StudentProfile.matric_no,
			StudentProfile.admitted_faculty,
			dept,
			lvl_str, sem_str,
			current_course_data.get("code", "GST 101"),
			current_course_data.get("title", ""),
			marks_attendance,
			marks_coursework,
			marks_library,
			marks_exam_paper,
			int(total_score),
			grade_letter,
			grade_point,
			new_cgpa,
			_get_classification_title(new_cgpa)
		]

	exam_completed.emit(total_score, grade_letter, new_cgpa)


func _on_advance_semester_pressed() -> void:
	close_exam()
	if SemesterManager:
		var adv_res: Dictionary = SemesterManager.advance_academic_period()
		var notice: String = adv_res.get("notice", "Advanced to next period!")
		if current_player and current_player.has_method("display_notification"):
			current_player.display_notification(notice)


func _get_letter_grade(score: float) -> String:
	if score >= 70.0: return "A"
	elif score >= 60.0: return "B"
	elif score >= 50.0: return "C"
	elif score >= 45.0: return "D"
	elif score >= 40.0: return "E"
	return "F"


func _get_grade_point(letter: String) -> float:
	match letter:
		"A": return 5.00
		"B": return 4.00
		"C": return 3.00
		"D": return 2.00
		"E": return 1.00
		_: return 0.00


func _get_classification_title(cgpa: float) -> String:
	if cgpa >= 4.50: return "First Class Honours"
	elif cgpa >= 3.50: return "Second Class Upper (2:1)"
	elif cgpa >= 2.40: return "Second Class Lower (2:2)"
	elif cgpa >= 1.50: return "Third Class"
	return "Academic Probation"


func close_exam() -> void:
	visible = false
	current_player = null
	menu_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_exam()

