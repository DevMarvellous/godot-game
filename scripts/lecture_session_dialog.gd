class_name LectureSessionDialog
extends Control

## Interactive Live Classroom Lecture & Engagement Micro-Game.
## Replaces boring passive stat clicks with an authentic, fast Nigerian university lecture experience.
## Features Blackboard presentation, dynamic Attention Meter, and quick-time classroom moments:
## - Jotting blackboard formulas before lecturer wipes board
## - Snapping awake from heavy afternoon drowsiness
## - Signing the official circulating attendance sheet
## - Answering impromptu lecturer pop-questions

signal lecture_completed(course_code: String, attention_rating: float, cgpa_earned: float)
signal dialog_closed

const LectureContent = preload("res://scripts/data/lecture_content_data.gd")
const StudentProfile = preload("res://scripts/data/student_profile.gd")

@onready var lecturer_label: Label = %LecturerLabel
@onready var course_title_label: Label = %CourseTitleLabel
@onready var blackboard_text: Label = %BlackboardText
@onready var attention_bar: ProgressBar = %AttentionBar
@onready var attention_label: Label = %AttentionLabel
@onready var lecture_progress_bar: ProgressBar = %LectureProgressBar
@onready var timer_label: Label = %TimerLabel
@onready var event_box: VBoxContainer = %EventBox
@onready var event_title: Label = %EventTitle
@onready var event_desc: Label = %EventDesc
@onready var action_btn: Button = %ActionBtn
@onready var pop_question_container: VBoxContainer = %PopQuestionContainer
@onready var skip_btn: Button = %SkipBtn
@onready var exit_btn: Button = %ExitBtn
@onready var report_panel: PanelContainer = %ReportPanel
@onready var report_text: Label = %ReportText
@onready var finish_btn: Button = %FinishBtn

var current_player: CharacterBody3D = null
var current_course_data: Dictionary = {}
var lecture_duration: float = 24.0 # Seconds for full lecture session
var elapsed_time: float = 0.0
var is_active: bool = false

# Player performance tracking
var attention_score: float = 100.0
var notes_taken: int = 0
var max_notes: int = 1
var attendance_signed: bool = false
var answered_question: bool = false
var question_correct: bool = false

# QTE state machine
enum LectureEvent { NONE, JOT_NOTE, SLEEP_ATTACK, ATTENDANCE_SHEET, POP_QUESTION }
var current_event: LectureEvent = LectureEvent.NONE
var event_timer: float = 0.0
var slide_index: int = 0


func _ready() -> void:
	visible = false
	if skip_btn:
		skip_btn.pressed.connect(_on_skip_pressed)
	if exit_btn:
		exit_btn.pressed.connect(close_dialog)
	if action_btn:
		action_btn.pressed.connect(_on_action_pressed)
	if finish_btn:
		finish_btn.pressed.connect(_on_finish_pressed)


func start_lecture(player: CharacterBody3D, custom_dept: String = "") -> void:
	current_player = player
	StudentProfile.load_from_disk()

	var dept: String = custom_dept
	if dept.is_empty():
		dept = StudentProfile.admitted_department
	current_course_data = LectureContent.get_lecture_for_department(dept)

	elapsed_time = 0.0
	attention_score = 100.0
	notes_taken = 0
	attendance_signed = false
	answered_question = false
	question_correct = false
	current_event = LectureEvent.NONE
	event_timer = 0.0
	slide_index = 0
	is_active = true

	if report_panel:
		report_panel.visible = false
	if pop_question_container:
		pop_question_container.visible = false

	# Setup UI labels
	if lecturer_label:
		lecturer_label.text = "👨‍🏫 %s • %s" % [
			current_course_data.get("lecturer", "Dr. Adebayo"),
			current_course_data.get("lecturer_role", "Senior Lecturer")
		]
	if course_title_label:
		course_title_label.text = "%s: %s" % [
			current_course_data.get("code", "GST 101"),
			current_course_data.get("title", "General Studies")
		]

	_update_blackboard()
	_update_attention_display()
	_set_event(LectureEvent.NONE)
	visible = true

	if SoundManager:
		SoundManager.play_bell()


func _process(delta: float) -> void:
	if not is_active:
		return

	elapsed_time += delta
	var progress_pct: float = clampf(elapsed_time / lecture_duration, 0.0, 1.0)

	if lecture_progress_bar:
		lecture_progress_bar.value = progress_pct * 100.0
	if timer_label:
		var rem: int = int(ceil(lecture_duration - elapsed_time))
		timer_label.text = "%ds remaining" % rem

	# Smooth attention decay over lecture (faster if student energy is low)
	var decay_rate: float = 2.0
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs and needs.energy < 40.0:
			decay_rate = 4.5
	attention_score = maxf(20.0, attention_score - delta * decay_rate)
	_update_attention_display()

	# Periodic slide change
	var new_slide: int = int(progress_pct * float(current_course_data.get("slides", []).size()))
	if new_slide != slide_index and new_slide < current_course_data.get("slides", []).size():
		slide_index = new_slide
		_update_blackboard()

	# Handle QTE triggers based on progress checkpoints
	if current_event == LectureEvent.NONE:
		if progress_pct >= 0.20 and progress_pct < 0.38 and notes_taken == 0:
			_set_event(LectureEvent.JOT_NOTE)
		elif progress_pct >= 0.45 and progress_pct < 0.65 and not attendance_signed:
			_set_event(LectureEvent.ATTENDANCE_SHEET)
		elif progress_pct >= 0.68 and progress_pct < 0.82 and event_timer <= 0.0:
			_set_event(LectureEvent.SLEEP_ATTACK)
		elif progress_pct >= 0.85 and progress_pct < 0.98 and not answered_question:
			_set_event(LectureEvent.POP_QUESTION)
	else:
		event_timer -= delta
		if event_timer <= 0.0:
			_on_event_timed_out()

	# Complete lecture
	if elapsed_time >= lecture_duration:
		_finish_lecture_session()


func _update_blackboard() -> void:
	var slides: Array = current_course_data.get("slides", [])
	if slides.size() > 0 and blackboard_text:
		var idx: int = clampi(slide_index, 0, slides.size() - 1)
		blackboard_text.text = String(slides[idx])


func _update_attention_display() -> void:
	if attention_bar:
		attention_bar.value = attention_score
	if attention_label:
		var grade: String = "A (High)" if attention_score >= 80.0 else ("B (Good)" if attention_score >= 50.0 else "C (Dozing)")
		attention_label.text = "Alertness: %d%% [%s]" % [int(attention_score), grade]


func _set_event(evt: LectureEvent) -> void:
	current_event = evt
	if pop_question_container:
		pop_question_container.visible = false

	match evt:
		LectureEvent.NONE:
			event_box.visible = false
			action_btn.visible = false

		LectureEvent.JOT_NOTE:
			event_timer = 5.0
			event_box.visible = true
			action_btn.visible = true
			event_title.text = "✍️ BLACKBOARD FORMULA ALERT!"
			event_title.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.3))
			var formula: String = current_course_data.get("qte_jot", "Key formula")
			event_desc.text = "Lecturer is writing: '%s' before wiping the board!" % formula
			action_btn.text = "✍️ Tap to Jot Down Formula! (+15% Alertness)"

		LectureEvent.ATTENDANCE_SHEET:
			event_timer = 6.0
			event_box.visible = true
			action_btn.visible = true
			event_title.text = "📋 ATTENDANCE SHEET PASSING BY!"
			event_title.add_theme_color_override(&"font_color", Color(0.3, 0.9, 0.5))
			event_desc.text = "The course rep passed the official register to your desk row. Sign now!"
			action_btn.text = "📋 Sign Matriculation Number & Signature"

		LectureEvent.SLEEP_ATTACK:
			event_timer = 4.5
			event_box.visible = true
			action_btn.visible = true
			event_title.text = "🥱 HEAVY EYELIDS (AFTERNOON DROWSINESS)"
			event_title.add_theme_color_override(&"font_color", Color(0.9, 0.4, 0.3))
			event_desc.text = "The afternoon ceiling fan is slow and sleep is catching you! Shake it off!"
			action_btn.text = "🥱 Snap Upright & Blink Rapidly! (+20% Alertness)"

		LectureEvent.POP_QUESTION:
			event_timer = 7.0
			event_box.visible = true
			action_btn.visible = false
			event_title.text = "🙋 SURPRISE LECTURER QUESTION!"
			event_title.add_theme_color_override(&"font_color", Color(0.4, 0.8, 1.0))
			var pq: Dictionary = current_course_data.get("pop_question", {})
			event_desc.text = String(pq.get("question", "Who knows the answer?"))
			_build_pop_question_options(pq)


func _build_pop_question_options(pq: Dictionary) -> void:
	if not pop_question_container:
		return
	pop_question_container.visible = true
	for child: Node in pop_question_container.get_children():
		child.queue_free()

	var opts: Array = pq.get("options", ["A", "B", "C"])
	var correct_idx: int = int(pq.get("correct", 0))

	for i in range(opts.size()):
		var btn: Button = Button.new()
		btn.text = "%c) %s" % [65 + i, String(opts[i])]
		btn.custom_minimum_size = Vector2(0, 42)
		btn.add_theme_font_size_override(&"font_size", 13)
		btn.pressed.connect(_on_pop_option_selected.bind(i == correct_idx, pq.get("praise", "Good!")))
		pop_question_container.add_child(btn)


func _on_action_pressed() -> void:
	match current_event:
		LectureEvent.JOT_NOTE:
			notes_taken += 1
			attention_score = minf(100.0, attention_score + 18.0)
			if SoundManager: SoundManager.play_coin()
			_show_temp_feedback("✓ Note copied into notebook! +18% Alertness")
			_set_event(LectureEvent.NONE)

		LectureEvent.ATTENDANCE_SHEET:
			attendance_signed = true
			attention_score = minf(100.0, attention_score + 15.0)
			if SoundManager: SoundManager.play_coin()
			_show_temp_feedback("✓ Matric signed! Continuous Assessment attendance secured.")
			_set_event(LectureEvent.NONE)

		LectureEvent.SLEEP_ATTACK:
			attention_score = minf(100.0, attention_score + 25.0)
			if SoundManager: SoundManager.play_coin()
			_show_temp_feedback("✓ Shook off the drowsiness! Sits upright with sharp focus.")
			_set_event(LectureEvent.NONE)


func _on_pop_option_selected(is_correct: bool, praise: String) -> void:
	answered_question = true
	question_correct = is_correct
	if is_correct:
		attention_score = minf(100.0, attention_score + 20.0)
		if SoundManager: SoundManager.play_coin()
		_show_temp_feedback("🎯 %s (+0.10 CGPA Merit)" % praise)
	else:
		attention_score = maxf(20.0, attention_score - 10.0)
		if SoundManager: SoundManager.play_alert()
		_show_temp_feedback("Lecturer: 'Incorrect! Open your handouts and read!'")
	_set_event(LectureEvent.NONE)


func _on_event_timed_out() -> void:
	match current_event:
		LectureEvent.SLEEP_ATTACK:
			attention_score = maxf(15.0, attention_score - 25.0)
			_show_temp_feedback("You dozed off momentarily! Attention dropped.")
		LectureEvent.JOT_NOTE:
			_show_temp_feedback("The lecturer wiped the board before you finished copying.")
		LectureEvent.ATTENDANCE_SHEET:
			_show_temp_feedback("The sheet passed to the next row without your signature!")
		LectureEvent.POP_QUESTION:
			_show_temp_feedback("Lecturer called on another student.")
	_set_event(LectureEvent.NONE)


func _show_temp_feedback(msg: String) -> void:
	if current_player and current_player.has_method("display_notification"):
		current_player.display_notification(msg)


func _on_skip_pressed() -> void:
	# Fast-forward for players in a rush
	elapsed_time = lecture_duration
	if not attendance_signed:
		attendance_signed = true
	_finish_lecture_session()


func _finish_lecture_session() -> void:
	is_active = false
	var final_rating: float = attention_score / 100.0

	# Calculate CGPA boost based on engagement
	var base_cgpa: float = 0.15
	var bonus_cgpa: float = final_rating * 0.10
	if question_correct:
		bonus_cgpa += 0.05
	var total_cgpa_earned: float = base_cgpa + bonus_cgpa

	# Apply stats to student
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_cgpa(total_cgpa_earned)
			needs.modify_energy(-15.0)

	# Mark timetable attendance in Schedule
	var lec_idx: int = Schedule.get_current_lecture_index()
	if lec_idx != -1 and not Schedule.is_attended(lec_idx):
		Schedule.mark_attended(lec_idx)

	# Advance game time by 60 minutes
	TimeSystem.advance_minutes(60)

	# 3D player animations
	if current_player:
		if total_cgpa_earned >= 0.22 and current_player.has_method("play_celebrate_animation"):
			current_player.play_celebrate_animation("🎓 LECTURE MASTERED! +%.2f CGPA" % total_cgpa_earned)
		elif current_player.has_method("play_study_animation"):
			current_player.play_study_animation()

	if SoundManager:
		SoundManager.play_bell()

	# Show Concluded Report Panel
	if report_panel and report_text:
		report_panel.visible = true
		var code: String = current_course_data.get("code", "GST 101")
		var grade_letter: String = "A" if attention_score >= 80.0 else ("B" if attention_score >= 60.0 else "C")
		report_text.text = """★ OFFICIAL LECTURE SESSION REPORT ★
Course: %s - %s
Lecturer: %s

• Attendance Register: %s
• Lecture Notes Copied: %d / %d
• Question Response: %s
• Focus & Retention Score: %d%% (Grade: %s)

ACADEMIC REWARD: +%.2f CGPA | Energy Used: -15
Timetable clearance updated for the semester.""" % [
			code,
			current_course_data.get("title", ""),
			current_course_data.get("lecturer", ""),
			"✓ SIGNED & RECORDED" if attendance_signed else "⚠️ MISSED ROLL CALL",
			notes_taken, max_notes,
			"✓ CORRECT (+Bonus Merit)" if question_correct else ("Participated" if answered_question else "Silent"),
			int(attention_score),
			grade_letter,
			total_cgpa_earned
		]

	var course_code: String = String(current_course_data.get("code", "GST 101"))
	lecture_completed.emit(course_code, final_rating, total_cgpa_earned)


func _on_finish_pressed() -> void:
	close_dialog()


func close_dialog() -> void:
	is_active = false
	visible = false
	current_player = null
	dialog_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close_dialog()
		elif event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if action_btn and action_btn.visible and not action_btn.disabled:
				_on_action_pressed()
			elif finish_btn and report_panel and report_panel.visible:
				_on_finish_pressed()

