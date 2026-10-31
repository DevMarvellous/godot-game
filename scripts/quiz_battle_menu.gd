class_name QuizBattleMenu
extends Control

## Interactive TV Game-Show Academic Quiz Tournament Controller.
## "Who Wants to Be a First Class Scholar?"
## - 5 Rapid-Fire Rounds with a ticking 30-second timer
## - 3 Strategic Lifelines: 50/50, Ask Course Rep Emeka, Senior Scholar Tobi
## - Streak rewards: Up to ₦10,000 cash, +0.15 CGPA, and Faculty Academic Shield Trophy!

signal tournament_finished(rounds_won: int, total_cash: int, total_cgpa: float)
signal tournament_closed

const QuizBattle = preload("res://scripts/data/quiz_battle_data.gd")

var current_player: CharacterBody3D = null
var questions: Array[Dictionary] = []
var current_round_idx: int = 0
var total_cash_won: int = 0
var total_cgpa_won: float = 0.0
var time_left: float = 30.0
var timer_active: bool = false
var has_answered: bool = false

var lifeline_50_used: bool = false
var lifeline_emeka_used: bool = false
var lifeline_tobi_used: bool = false

# UI References created dynamically or connected
var header_label: Label = null
var round_badge_label: Label = null
var timer_bar: ProgressBar = null
var timer_label: Label = null
var question_card: Label = null
var option_buttons: Array[Button] = []
var lifeline_50_btn: Button = null
var lifeline_emeka_btn: Button = null
var lifeline_tobi_btn: Button = null
var hint_dialog_panel: PanelContainer = null
var hint_dialog_label: Label = null
var status_feedback_label: Label = null
var action_next_btn: Button = null
var close_btn: Button = null


func _ready() -> void:
	visible = false
	_build_ui()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if not is_visible_in_tree():
			timer_active = false



func _process(delta: float) -> void:
	if not visible or not timer_active:
		return

	time_left -= delta
	if time_left < 0.0:
		time_left = 0.0
		timer_active = false
		_on_time_expired()

	if timer_bar:
		timer_bar.value = time_left
	if timer_label:
		timer_label.text = "⏱️ %ds" % int(ceil(time_left))
		if time_left <= 5.0:
			timer_label.add_theme_color_override(&"font_color", Color(1.0, 0.25, 0.25))
		else:
			timer_label.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.35))


func open_tournament(player: CharacterBody3D) -> void:
	current_player = player
	questions = QuizBattle.get_round_questions(5)
	current_round_idx = 0
	total_cash_won = 0
	total_cgpa_won = 0.0
	lifeline_50_used = false
	lifeline_emeka_used = false
	lifeline_tobi_used = false

	if lifeline_50_btn:
		lifeline_50_btn.disabled = false
	if lifeline_emeka_btn:
		lifeline_emeka_btn.disabled = false
	if lifeline_tobi_btn:
		lifeline_tobi_btn.disabled = false
	if hint_dialog_panel:
		hint_dialog_panel.visible = false

	visible = true
	if SoundManager:
		SoundManager.play_bell()
	_load_round(0)


func close_tournament() -> void:
	timer_active = false
	visible = false
	tournament_closed.emit()


func _load_round(round_idx: int) -> void:
	if round_idx >= questions.size():
		_conclude_grand_victory()
		return

	current_round_idx = round_idx
	has_answered = false
	time_left = 30.0
	timer_active = true

	var q: Dictionary = questions[round_idx]
	var tier: Dictionary = QuizBattle.ROUND_TIERS[clampi(round_idx, 0, QuizBattle.ROUND_TIERS.size() - 1)]

	if round_badge_label:
		round_badge_label.text = "⭐ %s • Stake: ₦%s" % [tier["title"], String.num(tier["reward_money"])]

	if question_card:
		question_card.text = "Q%d: %s\n(%s)" % [round_idx + 1, q["question"], q["category"]]

	if hint_dialog_panel:
		hint_dialog_panel.visible = false
	if status_feedback_label:
		status_feedback_label.text = "Select your answer before the 30-second timer expires!"
		status_feedback_label.add_theme_color_override(&"font_color", Color(0.85, 0.9, 0.95))

	if action_next_btn:
		action_next_btn.visible = false

	var opts: Array = q.get("options", [])
	for i in range(option_buttons.size()):
		var btn: Button = option_buttons[i]
		if i < opts.size():
			btn.text = "%s. %s" % [["A", "B", "C", "D"][i], opts[i]]
			btn.visible = true
			btn.disabled = false
			_reset_button_style(btn)
		else:
			btn.visible = false


func _on_option_selected(option_idx: int) -> void:
	if has_answered or current_round_idx >= questions.size():
		return

	has_answered = true
	timer_active = false

	var q: Dictionary = questions[current_round_idx]
	var correct_idx: int = int(q.get("correct", 0))
	var tier: Dictionary = QuizBattle.ROUND_TIERS[clampi(current_round_idx, 0, QuizBattle.ROUND_TIERS.size() - 1)]

	# Disable all options
	for btn in option_buttons:
		btn.disabled = true

	if option_idx == correct_idx:
		# CORRECT ANSWER
		_set_button_color(option_buttons[option_idx], Color(0.12, 0.75, 0.35))
		if SoundManager:
			SoundManager.play_coin()

		var win_money: int = int(tier["reward_money"])
		var win_cgpa: float = float(tier["reward_cgpa"])
		var win_faith: float = float(tier["reward_faith"])
		total_cash_won += win_money
		total_cgpa_won += win_cgpa

		if current_player:
			var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
			if needs:
				needs.modify_money(win_money)
				needs.modify_cgpa(win_cgpa)
				needs.modify_faith(win_faith)

		if status_feedback_label:
			status_feedback_label.text = "🎉 CORRECT! +₦%s Awarded! CGPA boosted by +%.2f!" % [String.num(win_money), win_cgpa]
			status_feedback_label.add_theme_color_override(&"font_color", Color(0.3, 1.0, 0.45))

		if current_round_idx == 4:
			# Grand Champion Finish
			_conclude_grand_victory()
		else:
			if action_next_btn:
				action_next_btn.text = "PROCEED TO ROUND %d ➔" % (current_round_idx + 2)
				action_next_btn.visible = true
	else:
		# WRONG ANSWER
		_set_button_color(option_buttons[option_idx], Color(0.85, 0.20, 0.20))
		_set_button_color(option_buttons[correct_idx], Color(0.12, 0.75, 0.35))
		if SoundManager:
			SoundManager.play_alert()

		if status_feedback_label:
			status_feedback_label.text = "❌ Incorrect! The correct answer was %s. Better luck on the next tournament!" % option_buttons[correct_idx].text
			status_feedback_label.add_theme_color_override(&"font_color", Color(1.0, 0.35, 0.35))

		if action_next_btn:
			action_next_btn.text = "RETRY QUIZ TOURNAMENT 🔄"
			action_next_btn.visible = true


func _on_time_expired() -> void:
	has_answered = true
	if SoundManager:
		SoundManager.play_alert()

	for btn in option_buttons:
		btn.disabled = true

	var q: Dictionary = questions[current_round_idx]
	var correct_idx: int = int(q.get("correct", 0))
	_set_button_color(option_buttons[correct_idx], Color(0.12, 0.75, 0.35))

	if status_feedback_label:
		status_feedback_label.text = "⏱️ Time Expired! The correct answer was %s!" % option_buttons[correct_idx].text
		status_feedback_label.add_theme_color_override(&"font_color", Color(1.0, 0.4, 0.4))

	if action_next_btn:
		action_next_btn.text = "RETRY QUIZ TOURNAMENT 🔄"
		action_next_btn.visible = true


func _conclude_grand_victory() -> void:
	timer_active = false
	if SoundManager:
		SoundManager.play_cheer()

	if current_player and current_player.has_method("play_celebrate_animation"):
		current_player.play_celebrate_animation("🏆 DEAN'S QUIZ CHAMPION!")

	if status_feedback_label:
		status_feedback_label.text = "🏆 GRAND ACADEMIC CHAMPION! You cleared all 5 rounds! Total: +₦%s, CGPA: +%.2f, Faculty Academic Shield Awarded!" % [String.num(total_cash_won), total_cgpa_won]
		status_feedback_label.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.25))

	tournament_finished.emit(5, total_cash_won, total_cgpa_won)

	if action_next_btn:
		action_next_btn.text = "COLLECT PRIZE & RETURN TO CLASS 🎓"
		action_next_btn.visible = true


func _on_next_action_pressed() -> void:
	if current_round_idx >= 4 or not has_answered:
		# Restart or close on completion
		if status_feedback_label.text.begins_with("🏆"):
			close_tournament()
		else:
			open_tournament(current_player)
	else:
		_load_round(current_round_idx + 1)


func _on_50_50_pressed() -> void:
	if lifeline_50_used or has_answered or current_round_idx >= questions.size():
		return
	lifeline_50_used = true
	if lifeline_50_btn:
		lifeline_50_btn.disabled = true
	if SoundManager:
		SoundManager.play_click()

	var q: Dictionary = questions[current_round_idx]
	var correct_idx: int = int(q.get("correct", 0))

	# Eliminate 2 wrong choices
	var wrong_indices: Array[int] = []
	for i in range(4):
		if i != correct_idx and i < option_buttons.size():
			wrong_indices.append(i)
	wrong_indices.shuffle()

	if wrong_indices.size() >= 2:
		option_buttons[wrong_indices[0]].disabled = true
		option_buttons[wrong_indices[0]].text = "--- ELIMINATED ---"
		option_buttons[wrong_indices[1]].disabled = true
		option_buttons[wrong_indices[1]].text = "--- ELIMINATED ---"

	if hint_dialog_panel and hint_dialog_label:
		hint_dialog_panel.visible = true
		hint_dialog_label.text = "💡 50/50 Lifeline Activated! Two incorrect choices have been eliminated!"


func _on_ask_emeka_pressed() -> void:
	if lifeline_emeka_used or has_answered or current_round_idx >= questions.size():
		return
	lifeline_emeka_used = true
	if lifeline_emeka_btn:
		lifeline_emeka_btn.disabled = true
	if SoundManager:
		SoundManager.play_click()

	var q: Dictionary = questions[current_round_idx]
	var emeka_advice: String = String(q.get("emeka_hint", "Guy, trust your instincts on this one!"))

	if hint_dialog_panel and hint_dialog_label:
		hint_dialog_panel.visible = true
		hint_dialog_label.text = "📞 Course Rep Emeka says:\n\"%s\"" % emeka_advice


func _on_ask_tobi_pressed() -> void:
	if lifeline_tobi_used or has_answered or current_round_idx >= questions.size():
		return
	lifeline_tobi_used = true
	if lifeline_tobi_btn:
		lifeline_tobi_btn.disabled = true
	if SoundManager:
		SoundManager.play_click()

	var q: Dictionary = questions[current_round_idx]
	var tobi_advice: String = String(q.get("tobi_hint", "According to university curriculum, option A is verified."))

	if hint_dialog_panel and hint_dialog_label:
		hint_dialog_panel.visible = true
		hint_dialog_label.text = "📚 400L Senior Scholar Tobi explains:\n\"%s\"" % tobi_advice


func _reset_button_style(btn: Button) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.16, 0.24, 0.95)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.45, 0.65, 0.8)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	btn.add_theme_stylebox_override(&"normal", style)
	btn.add_theme_stylebox_override(&"hover", style)
	btn.add_theme_stylebox_override(&"pressed", style)
	btn.add_theme_color_override(&"font_color", Color(0.95, 0.95, 0.98))


func _set_button_color(btn: Button, col: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = col
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	btn.add_theme_stylebox_override(&"normal", style)
	btn.add_theme_stylebox_override(&"hover", style)
	btn.add_theme_stylebox_override(&"pressed", style)
	btn.add_theme_stylebox_override(&"disabled", style)
	btn.add_theme_color_override(&"font_color", Color.WHITE)


func _build_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Dim background
	var bg := ColorRect.new()
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.color = Color(0.04, 0.06, 0.10, 0.85)
	add_child(bg)

	var center := CenterContainer.new()
	center.anchors_preset = Control.PRESET_FULL_RECT
	add_child(center)

	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(580, 560)
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.08, 0.11, 0.17, 0.98)
	frame_style.border_width_left = 3
	frame_style.border_width_top = 3
	frame_style.border_width_right = 3
	frame_style.border_width_bottom = 3
	frame_style.border_color = Color(1.0, 0.82, 0.24, 0.95)
	frame_style.corner_radius_top_left = 16
	frame_style.corner_radius_top_right = 16
	frame_style.corner_radius_bottom_right = 16
	frame_style.corner_radius_bottom_left = 16
	frame_style.content_margin_left = 24.0
	frame_style.content_margin_right = 24.0
	frame_style.content_margin_top = 18.0
	frame_style.content_margin_bottom = 20.0
	frame.add_theme_stylebox_override(&"panel", frame_style)
	center.add_child(frame)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 10)
	frame.add_child(vbox)

	# 1. Header Bar
	var top_bar := HBoxContainer.new()
	header_label = Label.new()
	header_label.text = "🏆 INTER-DEPARTMENT QUIZ BATTLE ARENA"
	header_label.add_theme_font_size_override(&"font_size", 16)
	header_label.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.35))
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(header_label)

	close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(36, 32)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(close_tournament)
	top_bar.add_child(close_btn)
	vbox.add_child(top_bar)

	round_badge_label = Label.new()
	round_badge_label.text = "⭐ Round 1 of 5 • Stake: ₦1,000"
	round_badge_label.add_theme_font_size_override(&"font_size", 13)
	round_badge_label.add_theme_color_override(&"font_color", Color(0.4, 0.85, 1.0))
	vbox.add_child(round_badge_label)

	# 2. Timer Bar & Label
	var timer_hbox := HBoxContainer.new()
	timer_hbox.add_theme_constant_override(&"separation", 10)

	timer_bar = ProgressBar.new()
	timer_bar.max_value = 30.0
	timer_bar.value = 30.0
	timer_bar.show_percentage = false
	timer_bar.custom_minimum_size = Vector2(0, 14)
	timer_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var p_style := StyleBoxFlat.new()
	p_style.bg_color = Color(0.15, 0.75, 0.35)
	p_style.corner_radius_top_left = 6
	p_style.corner_radius_top_right = 6
	p_style.corner_radius_bottom_right = 6
	p_style.corner_radius_bottom_left = 6
	timer_bar.add_theme_stylebox_override(&"fill", p_style)
	timer_hbox.add_child(timer_bar)

	timer_label = Label.new()
	timer_label.text = "⏱️ 30s"
	timer_label.add_theme_font_size_override(&"font_size", 14)
	timer_label.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.35))
	timer_hbox.add_child(timer_label)
	vbox.add_child(timer_hbox)

	# 3. Lifelines Row
	var lifelines_hbox := HBoxContainer.new()
	lifelines_hbox.add_theme_constant_override(&"separation", 8)

	lifeline_50_btn = Button.new()
	lifeline_50_btn.text = "💡 50 / 50"
	lifeline_50_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lifeline_50_btn.custom_minimum_size = Vector2(0, 32)
	lifeline_50_btn.focus_mode = Control.FOCUS_NONE
	lifeline_50_btn.pressed.connect(_on_50_50_pressed)
	lifelines_hbox.add_child(lifeline_50_btn)

	lifeline_emeka_btn = Button.new()
	lifeline_emeka_btn.text = "📞 Ask Emeka (Course Rep)"
	lifeline_emeka_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lifeline_emeka_btn.custom_minimum_size = Vector2(0, 32)
	lifeline_emeka_btn.focus_mode = Control.FOCUS_NONE
	lifeline_emeka_btn.pressed.connect(_on_ask_emeka_pressed)
	lifelines_hbox.add_child(lifeline_emeka_btn)

	lifeline_tobi_btn = Button.new()
	lifeline_tobi_btn.text = "📚 Senior Scholar Tobi"
	lifeline_tobi_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lifeline_tobi_btn.custom_minimum_size = Vector2(0, 32)
	lifeline_tobi_btn.focus_mode = Control.FOCUS_NONE
	lifeline_tobi_btn.pressed.connect(_on_ask_tobi_pressed)
	lifelines_hbox.add_child(lifeline_tobi_btn)
	vbox.add_child(lifelines_hbox)

	# 4. Hint Dialog Panel
	hint_dialog_panel = PanelContainer.new()
	var h_style := StyleBoxFlat.new()
	h_style.bg_color = Color(0.10, 0.18, 0.28, 0.95)
	h_style.border_width_left = 2
	h_style.border_color = Color(0.3, 0.8, 1.0)
	h_style.corner_radius_top_left = 8
	h_style.corner_radius_top_right = 8
	h_style.corner_radius_bottom_right = 8
	h_style.corner_radius_bottom_left = 8
	h_style.content_margin_left = 12.0
	h_style.content_margin_right = 12.0
	h_style.content_margin_top = 8.0
	h_style.content_margin_bottom = 8.0
	hint_dialog_panel.add_theme_stylebox_override(&"panel", h_style)
	hint_dialog_label = Label.new()
	hint_dialog_label.text = "Lifeline suggestion..."
	hint_dialog_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_dialog_label.add_theme_font_size_override(&"font_size", 12)
	hint_dialog_label.add_theme_color_override(&"font_color", Color(0.9, 0.95, 1.0))
	hint_dialog_panel.add_child(hint_dialog_label)
	hint_dialog_panel.visible = false
	vbox.add_child(hint_dialog_panel)

	# 5. Question Card
	var q_panel := PanelContainer.new()
	var q_style := StyleBoxFlat.new()
	q_style.bg_color = Color(0.11, 0.15, 0.22, 0.95)
	q_style.border_width_left = 3
	q_style.border_color = Color(1.0, 0.82, 0.24)
	q_style.corner_radius_top_left = 10
	q_style.corner_radius_top_right = 10
	q_style.corner_radius_bottom_right = 10
	q_style.corner_radius_bottom_left = 10
	q_style.content_margin_left = 14.0
	q_style.content_margin_right = 14.0
	q_style.content_margin_top = 12.0
	q_style.content_margin_bottom = 12.0
	q_panel.add_theme_stylebox_override(&"panel", q_style)

	question_card = Label.new()
	question_card.text = "Question text goes here..."
	question_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	question_card.add_theme_font_size_override(&"font_size", 14)
	question_card.add_theme_color_override(&"font_color", Color(1.0, 1.0, 1.0))
	q_panel.add_child(question_card)
	vbox.add_child(q_panel)

	# 6. Options Grid / VBox
	option_buttons.clear()
	for i in range(4):
		var opt_btn := Button.new()
		opt_btn.text = "Option %d" % (i + 1)
		opt_btn.custom_minimum_size = Vector2(0, 38)
		opt_btn.focus_mode = Control.FOCUS_NONE
		opt_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		opt_btn.add_theme_font_size_override(&"font_size", 13)
		var idx := i
		opt_btn.pressed.connect(func(): _on_option_selected(idx))
		_reset_button_style(opt_btn)
		option_buttons.append(opt_btn)
		vbox.add_child(opt_btn)

	# 7. Status Feedback & Action Next Button
	status_feedback_label = Label.new()
	status_feedback_label.text = "Select your answer!"
	status_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_feedback_label.add_theme_font_size_override(&"font_size", 13)
	vbox.add_child(status_feedback_label)

	action_next_btn = Button.new()
	action_next_btn.text = "PROCEED TO NEXT ROUND ➔"
	action_next_btn.custom_minimum_size = Vector2(0, 40)
	action_next_btn.focus_mode = Control.FOCUS_NONE
	var a_style := StyleBoxFlat.new()
	a_style.bg_color = Color(0.15, 0.65, 0.35)
	a_style.corner_radius_top_left = 10
	a_style.corner_radius_top_right = 10
	a_style.corner_radius_bottom_right = 10
	a_style.corner_radius_bottom_left = 10
	action_next_btn.add_theme_stylebox_override(&"normal", a_style)
	action_next_btn.add_theme_stylebox_override(&"hover", a_style)
	action_next_btn.add_theme_stylebox_override(&"pressed", a_style)
	action_next_btn.pressed.connect(_on_next_action_pressed)
	action_next_btn.visible = false
	vbox.add_child(action_next_btn)
