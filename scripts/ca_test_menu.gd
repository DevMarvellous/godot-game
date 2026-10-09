class_name CATestMenu
extends Control

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")
const QuizSystem = preload("res://scripts/data/quiz_test_system.gd")
const ExamMalpractice = preload("res://scripts/data/exam_malpractice_system.gd")

## Interactive In-Class Continuous Assessment (CA) Test Paper.
## Simulates real Nigerian university impromptu tests with Dr. Adebayo and lecturers.
## Your real answers determine your CA marks out of 30, feeding directly into your final semester grade!

signal test_submitted(course_code: String, score: int, max_score: int, marks_obtained: float)
signal test_closed

@onready var title_label: Label = %TitleLabel
@onready var course_label: Label = %CourseLabel
@onready var question_label: Label = %QuestionLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var progress_label: Label = %ProgressLabel
@onready var feedback_panel: PanelContainer = %FeedbackPanel
@onready var feedback_text: Label = %FeedbackText
@onready var next_btn: Button = %NextBtn
@onready var close_btn: Button = %CloseBtn
@onready var expo_btn: Button = %ExpoBtn
@onready var hint_btn: Button = %HintBtn if has_node("%HintBtn") else null
@onready var hint_label: Label = %HintLabel if has_node("%HintLabel") else null

var current_course: String = "CSC 101"
var questions: Array = []
var current_q_idx: int = 0
var total_correct: int = 0
var current_player: CharacterBody3D = null

var expo_used: bool = false
var expo_bonus_marks: float = 0.0
var is_disqualified: bool = false


func _ready() -> void:
	visible = false
	if next_btn:
		next_btn.pressed.connect(_on_next_pressed)
	if close_btn:
		close_btn.pressed.connect(close_test)
	if expo_btn:
		expo_btn.pressed.connect(_on_expo_pressed)
	if hint_btn:
		hint_btn.pressed.connect(_on_hint_pressed)


func start_test(player: CharacterBody3D, course_code: String = "CSC 101") -> void:
	current_player = player
	current_course = course_code
	questions = QuizSystem.get_test_for_course(course_code)
	current_q_idx = 0
	total_correct = 0
	expo_used = false
	expo_bonus_marks = 0.0
	is_disqualified = false
	if expo_btn:
		expo_btn.disabled = false
		expo_btn.text = "🤫 Sneak Out 'Expo' (+12 Marks, 35% Risk!)"
	if hint_label:
		hint_label.visible = false
	visible = true

	if course_label:
		course_label.text = "%s CONTINUOUS ASSESSMENT (30 MARKS)" % course_code

	_load_current_question()


func _load_current_question() -> void:
	if feedback_panel:
		feedback_panel.visible = false
	if hint_label:
		hint_label.visible = false

	if current_q_idx >= questions.size():
		_finish_test()
		return

	var q_data: Dictionary = questions[current_q_idx]

	if progress_label:
		progress_label.text = "Question %d of %d" % [current_q_idx + 1, questions.size()]

	if question_label:
		question_label.text = String(q_data["q"])

	# Populate options
	for child: Node in options_container.get_children():
		child.queue_free()

	var opts: Array = q_data["options"]
	for i: int in opts.size():
		var btn: Button = Button.new()
		btn.text = "%s) %s" % [_get_letter(i), String(opts[i])]
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override(&"font_size", 16)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_option_selected.bind(i))
		options_container.add_child(btn)


func _on_option_selected(selected_idx: int) -> void:
	# Disable all option buttons once an answer is chosen
	for child: Node in options_container.get_children():
		if child is Button:
			child.disabled = true

	var q_data: Dictionary = questions[current_q_idx]
	var correct_idx: int = int(q_data["correct"])
	var is_correct: bool = (selected_idx == correct_idx)

	if is_correct:
		total_correct += 1

	# Show explanation and feedback
	if feedback_panel and feedback_text:
		feedback_panel.visible = true
		if is_correct:
			feedback_text.text = "✓ CORRECT!\n%s" % String(q_data["explanation"])
			feedback_text.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.45))
		else:
			feedback_text.text = "✗ WRONG!\nCorrect answer was (%s).\n%s" % [_get_letter(correct_idx), String(q_data["explanation"])]
			feedback_text.add_theme_color_override(&"font_color", Color(1.0, 0.4, 0.35))


func _on_hint_pressed() -> void:
	if hint_label:
		var hint_str: String = QuizSystem.get_hint(current_course, current_q_idx)
		hint_label.text = "💡 Book Hint: %s" % hint_str
		hint_label.visible = true
	if SoundManager:
		SoundManager.play_click()


func _on_expo_pressed() -> void:
	if expo_used or is_disqualified:
		return
	expo_used = true
	if expo_btn:
		expo_btn.disabled = true

	var cgpa: float = 3.50
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager if current_player else null
	if needs:
		cgpa = needs.cgpa

	var res: Dictionary = ExamMalpractice.attempt_expo(cgpa)
	if int(res["result"]) == ExamMalpractice.DilemmaResult.CAUGHT_BY_INVIGILATOR:
		is_disqualified = true
		if SoundManager:
			SoundManager.play_alert()
		if needs:
			needs.modify_cgpa(float(res["cgpa_penalty"]))
			needs.modify_faith(float(res["faith_penalty"]))
		if feedback_panel and feedback_text:
			feedback_panel.visible = true
			feedback_text.text = "%s\n\n%s" % [String(res["title"]), String(res["message"])]
			feedback_text.add_theme_color_override(&"font_color", Color(1.0, 0.25, 0.25))
		if next_btn:
			next_btn.text = "Face Disciplinary Panel (Exit) ➔"
		for child: Node in options_container.get_children():
			if child is Button:
				child.disabled = true
	else:
		expo_bonus_marks = float(res["bonus_marks"])
		if SoundManager:
			SoundManager.play_coin()
		if needs:
			needs.modify_faith(float(res["faith_penalty"]))
		if feedback_panel and feedback_text:
			feedback_panel.visible = true
			feedback_text.text = "%s\n\n%s" % [String(res["title"]), String(res["message"])]
			feedback_text.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.3))


func _on_next_pressed() -> void:
	if is_disqualified:
		close_test()
		return
	current_q_idx += 1
	_load_current_question()


func _finish_test() -> void:
	var total_q: int = questions.size()
	var percentage: float = float(total_correct) / float(max(total_q, 1))
	var marks_earned: float = minf(percentage * 30.0 + expo_bonus_marks, 30.0) # Out of 30 marks

	# Apply to student CGPA and energy
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_energy(-20.0) # Tests are mentally draining
			var cgpa_boost: float = (percentage - 0.5) * 0.40 # High test scores raise CGPA; poor scores hurt
			needs.modify_cgpa(cgpa_boost)

		if current_player.has_method("display_notification"):
			current_player.display_notification("Test Finished! Score: %d/%d (%.1f/30 Marks)" % [total_correct, total_q, marks_earned])

	if SoundManager:
		SoundManager.play_bell()

	TimeSystem.advance_minutes(45)
	test_submitted.emit(current_course, total_correct, total_q, marks_earned)
	close_test()


func close_test() -> void:
	visible = false
	current_player = null
	test_closed.emit()


func _get_letter(idx: int) -> String:
	match idx:
		0: return "A"
		1: return "B"
		2: return "C"
		3: return "D"
		_: return "?"
