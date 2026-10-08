class_name CATestMenu
extends Control

const QuizTestSystem = preload("res://scripts/data/quiz_test_system.gd")

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

var current_course: String = "CSC 101"
var questions: Array = []
var current_q_idx: int = 0
var total_correct: int = 0
var current_player: CharacterBody3D = null


func _ready() -> void:
	visible = false
	if next_btn:
		next_btn.pressed.connect(_on_next_pressed)
	if close_btn:
		close_btn.pressed.connect(close_test)


func start_test(player: CharacterBody3D, course_code: String = "CSC 101") -> void:
	current_player = player
	current_course = course_code
	questions = QuizTestSystem.get_test_for_course(course_code)
	current_q_idx = 0
	total_correct = 0
	visible = true

	if course_label:
		course_label.text = "%s CONTINUOUS ASSESSMENT (30 MARKS)" % course_code

	_load_current_question()


func _load_current_question() -> void:
	if feedback_panel:
		feedback_panel.visible = false

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


func _on_next_pressed() -> void:
	current_q_idx += 1
	_load_current_question()


func _finish_test() -> void:
	var total_q: int = questions.size()
	var percentage: float = float(total_correct) / float(max(total_q, 1))
	var marks_earned: float = percentage * 30.0 # CA is out of 30 marks

	# Apply to student CGPA and energy
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_energy(-20.0) # Tests are mentally draining
			var cgpa_boost: float = (percentage - 0.5) * 0.40 # High test scores raise CGPA; poor scores hurt
			needs.modify_cgpa(cgpa_boost)

		if current_player.has_method("display_notification"):
			current_player.display_notification("Test Finished! Score: %d/%d (%.1f/30 Marks)" % [total_correct, total_q, marks_earned])

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

