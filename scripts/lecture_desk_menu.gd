class_name LectureDeskMenu
extends Control

## Versatile Student Classroom Desk Hub.
## Replaces repetitive test pop-ups with full academic agency:
## 1. Attend Live Interactive Lecture (QTEs, blackboard notes, attendance sheet)
## 2. Work on Department Practical Term Project (Coursework system)
## 3. Take Continuous Assessment (CA) Test Paper
## 4. Open Revision Handout & Study Options
## 5. Sit for Final Semester Examination

signal action_chosen(action_name: StringName)
signal menu_closed

const StudentProfile = preload("res://scripts/data/student_profile.gd")
const StudentCoursework = preload("res://scripts/data/student_coursework.gd")

@onready var close_btn: Button = %CloseBtn
@onready var desk_title_label: Label = %DeskTitleLabel
@onready var status_badge: Label = %StatusBadge
@onready var student_info_label: Label = %StudentInfoLabel
@onready var coursework_summary_label: Label = %CourseworkSummaryLabel
@onready var attend_lecture_btn: Button = %AttendLectureBtn
@onready var coursework_btn: Button = %CourseworkBtn
@onready var ca_test_btn: Button = %CATestBtn
@onready var study_options_btn: Button = %StudyOptionsBtn
@onready var final_exam_btn: Button = %FinalExamBtn

var current_player: CharacterBody3D = null


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_menu)
	if attend_lecture_btn:
		attend_lecture_btn.pressed.connect(func(): _choose_action(&"live_lecture"))
	if coursework_btn:
		coursework_btn.pressed.connect(func(): _choose_action(&"coursework"))
	if ca_test_btn:
		ca_test_btn.pressed.connect(func(): _choose_action(&"ca_test"))
	if study_options_btn:
		study_options_btn.pressed.connect(func(): _choose_action(&"study_options"))
	if final_exam_btn:
		final_exam_btn.pressed.connect(func(): _choose_action(&"final_exam"))


func open_desk(player: CharacterBody3D) -> void:
	current_player = player
	StudentProfile.load_from_disk()

	var dept: String = StudentProfile.admitted_department
	var course_title: String = StudentProfile.admitted_course_title
	var level_str: String = "%d Level" % StudentProfile.current_level
	var sem_str: String = "Semester %d" % StudentProfile.current_semester

	if desk_title_label:
		desk_title_label.text = "🎓 %s LECTURE DESK" % dept
	if student_info_label:
		student_info_label.text = "%s (%s) • %s • %s\nMatric No: %s" % [
			StudentProfile.student_name,
			dept,
			course_title,
			"%s, %s" % [level_str, sem_str],
			StudentProfile.matric_no
		]

	# Timetable attendance status
	var lec_idx: int = Schedule.get_current_lecture_index()
	if status_badge:
		if lec_idx != -1:
			var lec_name: String = String(Schedule.get_lecture(lec_idx)["name"])
			if Schedule.is_attended(lec_idx):
				status_badge.text = "✓ %s Attended for today" % lec_name
				status_badge.add_theme_color_override(&"font_color", Color(0.3, 0.9, 0.5))
			else:
				status_badge.text = "🔔 LECTURE IN PROGRESS: %s" % lec_name
				status_badge.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
		else:
			status_badge.text = "Free Period • Available for Coursework & Revision"
			status_badge.add_theme_color_override(&"font_color", Color(0.7, 0.8, 0.9))

	# Coursework project status
	var cw_proj: Dictionary = StudentCoursework.get_current_project()
	var progress_pct: float = StudentCoursework.get_project_progress()
	if coursework_summary_label:
		if cw_proj.is_empty():
			coursework_summary_label.text = "Practical Project: None assigned"
		else:
			var m_idx: int = int(cw_proj.get("milestone_index", 0))
			var m_title: String = "All Submitted" if m_idx >= 3 else String(cw_proj.get("milestones", [])[m_idx].get("title", ""))
			coursework_summary_label.text = "Practical Term Project: %s (Progress: %d%% • Milestone: %s)" % [
				cw_proj.get("title", "Project"),
				int(progress_pct),
				m_title
			]

	visible = true
	if SoundManager:
		SoundManager.play_click()


func _choose_action(action: StringName) -> void:
	if SoundManager:
		SoundManager.play_click()
	close_menu()
	action_chosen.emit(action)


func close_menu() -> void:
	visible = false
	current_player = null
	menu_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_menu()

