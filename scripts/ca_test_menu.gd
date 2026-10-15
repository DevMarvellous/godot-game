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


# Stealth Exam Tension Mini-Game state
enum LecturerState { SAFE, WARNING, SCANNING }
var stealth_active: bool = false
var is_holding_copy: bool = false
var lecturer_state: LecturerState = LecturerState.SAFE
var lecturer_timer: float = 0.0
var copy_progress: float = 0.0
var suspicion_level: float = 0.0

var stealth_modal: PanelContainer = null
var lecturer_status_label: Label = null
var copy_bar: ProgressBar = null
var suspicion_bar: ProgressBar = null
var stealth_hold_btn: Button = null


func _process(delta: float) -> void:
	if not stealth_active:
		return

	# Invigilator awareness cycle
	lecturer_timer -= delta
	if lecturer_timer <= 0.0:
		match lecturer_state:
			LecturerState.SAFE:
				lecturer_state = LecturerState.WARNING
				lecturer_timer = randf_range(0.8, 1.2)
			LecturerState.WARNING:
				lecturer_state = LecturerState.SCANNING
				lecturer_timer = randf_range(1.8, 2.8)
			LecturerState.SCANNING:
				lecturer_state = LecturerState.SAFE
				lecturer_timer = randf_range(2.5, 4.0)
		_update_stealth_ui()

	# Process copying & suspicion
	if is_holding_copy:
		copy_progress += delta * 32.0 # ~3.1 seconds of safe copying to fill
		if copy_bar:
			copy_bar.value = copy_progress

		match lecturer_state:
			LecturerState.SAFE:
				suspicion_level = maxf(0.0, suspicion_level - delta * 15.0)
			LecturerState.WARNING:
				suspicion_level += delta * 25.0
			LecturerState.SCANNING:
				suspicion_level += delta * 95.0 # Caught very fast if holding while looking!
				if SoundManager and randf() < 0.2:
					SoundManager.play_alert()

		if suspicion_bar:
			suspicion_bar.value = suspicion_level

		if suspicion_level >= 100.0:
			_on_stealth_caught()
			return

		if copy_progress >= 100.0:
			_on_stealth_success()
			return
	else:
		# Cool down suspicion when sitting upright innocent
		suspicion_level = maxf(0.0, suspicion_level - delta * 45.0)
		if suspicion_bar:
			suspicion_bar.value = suspicion_level


func _on_expo_pressed() -> void:
	if expo_used or is_disqualified:
		return
	_open_stealth_modal()


func _open_stealth_modal() -> void:
	if not stealth_modal:
		_create_stealth_modal_ui()

	stealth_active = true
	is_holding_copy = false
	copy_progress = 0.0
	suspicion_level = 0.0
	lecturer_state = LecturerState.SAFE
	lecturer_timer = randf_range(2.5, 3.5)
	if copy_bar:
		copy_bar.value = 0.0
	if suspicion_bar:
		suspicion_bar.value = 0.0

	_update_stealth_ui()
	stealth_modal.visible = true


func _create_stealth_modal_ui() -> void:
	stealth_modal = PanelContainer.new()
	stealth_modal.name = "StealthExpoModal"
	stealth_modal.anchors_preset = Control.PRESET_CENTER
	stealth_modal.anchor_left = 0.5
	stealth_modal.anchor_top = 0.5
	stealth_modal.anchor_right = 0.5
	stealth_modal.anchor_bottom = 0.5
	stealth_modal.offset_left = -220.0
	stealth_modal.offset_top = -180.0
	stealth_modal.offset_right = 220.0
	stealth_modal.offset_bottom = 180.0
	stealth_modal.custom_minimum_size = Vector2(440, 360)

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.07, 0.09, 0.13, 0.98)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.85, 0.25, 0.25, 0.9)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.content_margin_left = 18.0
	panel_style.content_margin_right = 18.0
	panel_style.content_margin_top = 16.0
	panel_style.content_margin_bottom = 16.0
	stealth_modal.add_theme_stylebox_override(&"panel", panel_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 12)

	var header = Label.new()
	header.text = "🤫 SNEAK EXPO (IN-CLASS EXAM TENSION)"
	header.add_theme_font_size_override(&"font_size", 16)
	header.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.3))
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(header)

	var instructions = Label.new()
	instructions.text = "Hold button to copy when lecturer turns away!\nRELEASE IMMEDIATELY when the lecturer looks back!"
	instructions.add_theme_font_size_override(&"font_size", 13)
	instructions.add_theme_color_override(&"font_color", Color(0.85, 0.88, 0.92))
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(instructions)

	lecturer_status_label = Label.new()
	lecturer_status_label.text = "✍️ Dr. Adebayo: Writing on Blackboard [SAFE]"
	lecturer_status_label.add_theme_font_size_override(&"font_size", 14)
	lecturer_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lecturer_status_label)

	# Copy Progress Bar
	var copy_lbl = Label.new()
	copy_lbl.text = "Formula Notes Copied:"
	copy_lbl.add_theme_font_size_override(&"font_size", 12)
	vbox.add_child(copy_lbl)

	copy_bar = ProgressBar.new()
	copy_bar.custom_minimum_size = Vector2(0, 22)
	copy_bar.max_value = 100.0
	vbox.add_child(copy_bar)

	# Suspicion Bar
	var sus_lbl = Label.new()
	sus_lbl.text = "Lecturer Suspicion Alert:"
	sus_lbl.add_theme_font_size_override(&"font_size", 12)
	vbox.add_child(sus_lbl)

	suspicion_bar = ProgressBar.new()
	suspicion_bar.custom_minimum_size = Vector2(0, 22)
	suspicion_bar.max_value = 100.0
	vbox.add_child(suspicion_bar)

	# Action Buttons
	stealth_hold_btn = Button.new()
	stealth_hold_btn.text = "👇 PRESS & HOLD TO COPY FORMULAS"
	stealth_hold_btn.custom_minimum_size = Vector2(0, 48)
	stealth_hold_btn.button_down.connect(func(): is_holding_copy = true)
	stealth_hold_btn.button_up.connect(func(): is_holding_copy = false)
	vbox.add_child(stealth_hold_btn)

	var abort_btn = Button.new()
	abort_btn.text = "Conceal Notes & Return to Paper"
	abort_btn.custom_minimum_size = Vector2(0, 36)
	abort_btn.pressed.connect(_close_stealth_modal)
	vbox.add_child(abort_btn)

	stealth_modal.add_child(vbox)
	add_child(stealth_modal)


func _update_stealth_ui() -> void:
	if not lecturer_status_label:
		return
	match lecturer_state:
		LecturerState.SAFE:
			lecturer_status_label.text = "✍️ Dr. Adebayo: Chalking Blackboard [SAFE TO COPY]"
			lecturer_status_label.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.45))
		LecturerState.WARNING:
			lecturer_status_label.text = "⚠️ Dr. Adebayo: Pausing & Turning Around..."
			lecturer_status_label.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
		LecturerState.SCANNING:
			lecturer_status_label.text = "👀 DR. ADEBAYO IS SCANNING YOUR ROW! RELEASE!"
			lecturer_status_label.add_theme_color_override(&"font_color", Color(1.0, 0.25, 0.25))


func _close_stealth_modal() -> void:
	stealth_active = false
	is_holding_copy = false
	if stealth_modal:
		stealth_modal.visible = false


func _on_stealth_success() -> void:
	_close_stealth_modal()
	expo_used = true
	expo_bonus_marks = 12.0 # Guaranteed bonus for completing stealth tension!
	if expo_btn:
		expo_btn.disabled = true
		expo_btn.text = "✓ Notes Copied (+12 Marks)"

	if SoundManager:
		SoundManager.play_coin()

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager if current_player else null
	if needs:
		needs.modify_faith(-10.0)

	if feedback_panel and feedback_text:
		feedback_panel.visible = true
		feedback_text.text = "🎯 STEALTH EXPO SUCCESS!\nYou quietly slipped your notes back into your calculator case without Dr. Adebayo noticing. +12 Marks earned!"
		feedback_text.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.3))


func _on_stealth_caught() -> void:
	_close_stealth_modal()
	expo_used = true
	is_disqualified = true
	if expo_btn:
		expo_btn.disabled = true
		expo_btn.text = "❌ DISQUALIFIED"

	if SoundManager:
		SoundManager.play_alert()

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager if current_player else null
	if needs:
		needs.modify_cgpa(-0.50)
		needs.modify_faith(-25.0)

	if feedback_panel and feedback_text:
		feedback_panel.visible = true
		feedback_text.text = "🚨 CAUGHT RED-HANDED BY DR. ADEBAYO!\n'You there in the 3rd row! Pack your papers and follow me to the HOD office!'\nPenalty: CGPA -0.50, Faith -25, Test Terminated."
		feedback_text.add_theme_color_override(&"font_color", Color(1.0, 0.25, 0.25))

	if next_btn:
		next_btn.text = "Face Disciplinary Panel (Exit) ➔"
	for child: Node in options_container.get_children():
		if child is Button:
			child.disabled = true


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
