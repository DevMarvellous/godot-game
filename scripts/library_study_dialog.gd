class_name LibraryStudyDialog
extends Control

## Interactive Library Past Questions & Revision Terminal.
## Allows students to choose study depth, revise past question archives,
## and boost their CGPA with realistic time and energy management.

signal revision_completed(mode_name: String, cgpa_gain: float)
signal dialog_closed

const ProfileStore = preload("res://scripts/data/student_profile.gd")
const AcademicCatalog = preload("res://scripts/data/academic_catalog.gd")

var current_player: CharacterBody3D = null

@onready var course_title_label: Label = %CourseTitleLabel if has_node("%CourseTitleLabel") else null
@onready var status_label: Label = %StatusLabel if has_node("%StatusLabel") else null
@onready var close_btn: Button = %CloseBtn if has_node("%CloseBtn") else null

const STUDY_MODES: Array[Dictionary] = [
	{
		"id": "flashcards",
		"title": "⚡ Quick Formula Flashcard Review",
		"duration": 15,
		"energy": 8.0,
		"cgpa_boost": 0.06,
		"desc": "Quickly review definitions, theorems, and key formulas before test."
	},
	{
		"id": "past_papers",
		"title": "📑 Intense Past Examination Papers (2023-2025)",
		"duration": 45,
		"energy": 18.0,
		"cgpa_boost": 0.16,
		"desc": "Solve 3 complete past exam papers and verify steps with official marking schemes."
	},
	{
		"id": "group_revision",
		"title": "🤝 Group Peer Revision with Senior Scholars",
		"duration": 60,
		"energy": 24.0,
		"cgpa_boost": 0.24,
		"desc": "Deep study session breaking down complex derivations and exam traps."
	}
]


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_dialog)

	if has_node("%Btn1"):
		%Btn1.pressed.connect(func(): _on_mode_selected(STUDY_MODES[0]))
	if has_node("%Btn2"):
		%Btn2.pressed.connect(func(): _on_mode_selected(STUDY_MODES[1]))
	if has_node("%Btn3"):
		%Btn3.pressed.connect(func(): _on_mode_selected(STUDY_MODES[2]))


func open_library_study(player: CharacterBody3D) -> void:
	current_player = player
	ProfileStore.load_from_disk()

	if course_title_label:
		var dept = AcademicCatalog.get_department(ProfileStore.admitted_department)
		var course_name = ProfileStore.admitted_course_title
		course_title_label.text = "📚 %s REVISION ARCHIVE" % course_name.to_upper()

	if status_label:
		status_label.text = "Mrs. Janet: \"Silence in the library. Choose your study material.\""
		status_label.add_theme_color_override(&"font_color", Color(0.8, 0.9, 1.0))

	visible = true


func close_dialog() -> void:
	visible = false
	current_player = null
	dialog_closed.emit()


func _on_mode_selected(mode: Dictionary) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var energy_cost: float = float(mode.get("energy", 10.0))
	if needs.energy < energy_cost:
		if status_label:
			status_label.text = "⚠️ You are falling asleep at the desk! Rest on your hostel bed first."
			status_label.add_theme_color_override(&"font_color", Color(1.0, 0.4, 0.3))
		if SoundManager:
			SoundManager.play_alert()
		return

	var duration: int = int(mode.get("duration", 30))
	var boost: float = float(mode.get("cgpa_boost", 0.10))

	needs.modify_energy(-energy_cost)
	needs.modify_cgpa(boost)
	TimeSystem.advance_minutes(duration)

	if current_player.has_method("play_study_animation"):
		current_player.play_study_animation()

	if SoundManager:
		SoundManager.play_bell()

	if current_player.has_method("display_notification"):
		current_player.display_notification("Library Study Finished! Exam Preparation +%.2f CGPA!" % boost)

	PropBuilder3D.advance_quest_if_matching(9, current_player)

	if status_label:
		status_label.text = "✓ %s completed! +%.2f CGPA preparation." % [mode.get("title"), boost]
		status_label.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.45))

	revision_completed.emit(mode.get("title", ""), boost)
