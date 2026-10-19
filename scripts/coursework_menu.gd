class_name CourseworkMenu
extends Control

## Interactive Departmental Practical Project & Coursework Assignment Desk.
## Gives students active, engaging progress toward their 30-mark Continuous Assessment grade.

signal coursework_updated(new_progress: float, is_submitted: bool)
signal menu_closed

const ProfileStore = preload("res://scripts/data/student_profile.gd")
const Coursework = preload("res://scripts/data/student_coursework.gd")

var current_player: CharacterBody3D = null

@onready var title_label: Label = %ProjectTitleLabel if has_node("%ProjectTitleLabel") else null
@onready var dept_label: Label = %DeptLabel if has_node("%DeptLabel") else null
@onready var progress_bar: ProgressBar = %ProgressBar if has_node("%ProgressBar") else null
@onready var milestone_label: Label = %MilestoneLabel if has_node("%MilestoneLabel") else null
@onready var status_label: Label = %StatusLabel if has_node("%StatusLabel") else null
@onready var work_btn: Button = %WorkBtn if has_node("%WorkBtn") else null
@onready var close_btn: Button = %CloseBtn if has_node("%CloseBtn") else null


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_menu)
	if work_btn:
		work_btn.pressed.connect(_on_work_pressed)


func open_coursework(player: CharacterBody3D) -> void:
	current_player = player
	ProfileStore.load_from_disk()
	Coursework.initialize_for_department(ProfileStore.admitted_department)
	_refresh_ui()
	visible = true


func close_menu() -> void:
	visible = false
	current_player = null
	menu_closed.emit()


func close_coursework() -> void:
	close_menu()


func _refresh_ui() -> void:
	Coursework.load_from_disk()

	if title_label:
		title_label.text = Coursework.project_title

	if dept_label:
		dept_label.text = "Department of %s  •  Continuous Assessment (30 Marks)" % ProfileStore.admitted_course_title

	if progress_bar:
		progress_bar.value = Coursework.progress

	if milestone_label:
		if Coursework.is_submitted:
			milestone_label.text = "🏆 Status: Submitted to Department Pigeonhole! (30/30 Marks Awarded)"
			milestone_label.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.45))
		else:
			var m_idx = clampi(Coursework.milestone_step, 0, Coursework.MILESTONES.size() - 1)
			milestone_label.text = "Active Milestone: %s" % Coursework.MILESTONES[m_idx]
			milestone_label.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.35))

	if work_btn:
		if Coursework.is_submitted:
			work_btn.disabled = true
			work_btn.text = "✓ Term Project Completed & Graded"
		else:
			work_btn.disabled = false
			work_btn.text = "💻 Work on Coursework (45 mins, 15% Energy)"


func _on_work_pressed() -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if needs.energy < 15.0:
		if status_label:
			status_label.text = "⚠️ You are too exhausted to write code and notes! Rest on your bed first."
			status_label.add_theme_color_override(&"font_color", Color(1.0, 0.4, 0.3))
		if SoundManager:
			SoundManager.play_alert()
		return

	needs.modify_energy(-15.0)
	TimeSystem.advance_minutes(45)

	var res: Dictionary = Coursework.work_on_milestone(35.0)

	if current_player.has_method("play_study_animation"):
		current_player.play_study_animation()

	if res.get("just_finished", false):
		needs.modify_cgpa(0.25)
		if SoundManager:
			SoundManager.play_bell()
		if current_player.has_method("play_celebrate_animation"):
			current_player.play_celebrate_animation("🎓 PROJECT SUBMITTED! +30 MARKS!")
		if status_label:
			status_label.text = "🎉 CONGRATULATIONS! Project submitted to Head of Department! +30 Marks secured!"
			status_label.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.45))
	else:
		if SoundManager:
			SoundManager.play_click()
		if status_label:
			status_label.text = "✓ Research session completed! Project progress now %.1f%%" % float(res.get("progress", 0.0))
			status_label.add_theme_color_override(&"font_color", Color(0.85, 0.9, 1.0))

	_refresh_ui()
	coursework_updated.emit(float(res.get("progress", 0.0)), bool(res.get("is_submitted", false)))
