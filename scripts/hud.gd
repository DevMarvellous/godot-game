class_name HUD
extends CanvasLayer

## Displays player life-sim stats in real-time, plus clock and timetable schedule.

@onready var energy_bar: ProgressBar = %EnergyBar
@onready var hunger_bar: ProgressBar = %HungerBar
@onready var faith_bar: ProgressBar = %FaithBar
@onready var cgpa_label: Label = %CGPALabel
@onready var money_label: Label = %MoneyLabel
@onready var time_label: Label = %TimeLabel
@onready var schedule_banner: Label = %ScheduleBanner


signal objective_clicked(dest: StringName)

var toast_panel: PanelContainer = null
var toast_title: Label = null
var toast_desc: Label = null
var toast_tween: Tween = null

var objective_btn: Button = null
var tasks_toggle_btn: Button = null
var tasks_sheet: PanelContainer = null
var clout_status_btn: Button = null
var _cached_energy: float = 100.0
var _cached_hunger: float = 100.0
var _cached_money: int = 5000
var _cached_cgpa: float = 3.5
var _current_obj_dest: StringName = &"class"


func _ready() -> void:
	TimeSystem.minute_passed.connect(_update_time_display)
	_create_objective_pill_ui()
	_update_time_display()
	_create_event_toast_ui()

	if CampusEvents:
		if not CampusEvents.event_triggered.is_connected(_on_campus_event_triggered):
			CampusEvents.event_triggered.connect(_on_campus_event_triggered)


func _create_objective_pill_ui() -> void:
	var container := HBoxContainer.new()
	container.name = "ObjectiveContainer"
	container.anchors_preset = Control.PRESET_TOP_LEFT
	container.offset_left = 12.0
	container.offset_top = 140.0
	container.offset_right = 440.0
	container.offset_bottom = 184.0
	container.add_theme_constant_override(&"separation", 6)

	objective_btn = Button.new()
	objective_btn.name = "ObjectivePillBtn"
	objective_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	objective_btn.custom_minimum_size = Vector2(280, 44)
	objective_btn.focus_mode = Control.FOCUS_NONE
	objective_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	objective_btn.add_theme_font_size_override(&"font_size", 14)
	objective_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var pill_style := StyleBoxFlat.new()
	pill_style.bg_color = Color(0.06, 0.11, 0.16, 0.92)
	pill_style.border_width_left = 3
	pill_style.border_width_top = 1
	pill_style.border_width_right = 1
	pill_style.border_width_bottom = 1
	pill_style.border_color = Color(1.0, 0.82, 0.24, 0.95)
	pill_style.corner_radius_top_left = 10
	pill_style.corner_radius_top_right = 10
	pill_style.corner_radius_bottom_left = 10
	pill_style.corner_radius_bottom_right = 10
	pill_style.content_margin_left = 12.0
	pill_style.content_margin_right = 12.0
	pill_style.content_margin_top = 6.0
	pill_style.content_margin_bottom = 6.0
	objective_btn.add_theme_stylebox_override(&"normal", pill_style)
	objective_btn.add_theme_stylebox_override(&"hover", pill_style)
	objective_btn.add_theme_stylebox_override(&"pressed", pill_style)

	objective_btn.pressed.connect(func():
		if SoundManager:
			SoundManager.play_click()
		objective_clicked.emit(_current_obj_dest)
	)
	container.add_child(objective_btn)

	tasks_toggle_btn = Button.new()
	tasks_toggle_btn.name = "TasksToggleBtn"
	tasks_toggle_btn.text = "📋 Tasks"
	tasks_toggle_btn.custom_minimum_size = Vector2(85, 44)
	tasks_toggle_btn.focus_mode = Control.FOCUS_NONE
	tasks_toggle_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tasks_toggle_btn.add_theme_font_size_override(&"font_size", 14)

	var t_style := StyleBoxFlat.new()
	t_style.bg_color = Color(0.10, 0.14, 0.22, 0.92)
	t_style.border_width_left = 2
	t_style.border_width_top = 1
	t_style.border_width_right = 1
	t_style.border_width_bottom = 1
	t_style.border_color = Color(0.4, 0.85, 0.6, 0.95)
	t_style.corner_radius_top_left = 10
	t_style.corner_radius_top_right = 10
	t_style.corner_radius_bottom_left = 10
	t_style.corner_radius_bottom_right = 10
	t_style.content_margin_left = 8.0
	t_style.content_margin_right = 8.0
	tasks_toggle_btn.add_theme_stylebox_override(&"normal", t_style)
	tasks_toggle_btn.add_theme_stylebox_override(&"hover", t_style)
	tasks_toggle_btn.add_theme_stylebox_override(&"pressed", t_style)
	tasks_toggle_btn.pressed.connect(_toggle_tasks_sheet)
	container.add_child(tasks_toggle_btn)

	add_child(container)

	# Clout & Multiplayer Online Status Pill beneath Objective Pill
	clout_status_btn = Button.new()
	clout_status_btn.name = "CloutStatusBtn"
	clout_status_btn.anchors_preset = Control.PRESET_TOP_LEFT
	clout_status_btn.offset_left = 12.0
	clout_status_btn.offset_top = 188.0
	clout_status_btn.offset_right = 345.0
	clout_status_btn.offset_bottom = 216.0
	clout_status_btn.focus_mode = Control.FOCUS_NONE
	clout_status_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	clout_status_btn.add_theme_font_size_override(&"font_size", 12)
	clout_status_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var c_style := StyleBoxFlat.new()
	c_style.bg_color = Color(0.06, 0.11, 0.17, 0.88)
	c_style.border_width_left = 3
	c_style.border_width_top = 1
	c_style.border_width_right = 1
	c_style.border_width_bottom = 1
	c_style.border_color = Color(0.25, 0.85, 0.65, 0.85)
	c_style.corner_radius_top_left = 8
	c_style.corner_radius_top_right = 8
	c_style.corner_radius_bottom_left = 8
	c_style.corner_radius_bottom_right = 8
	c_style.content_margin_left = 10.0
	c_style.content_margin_right = 10.0
	c_style.content_margin_top = 3.0
	c_style.content_margin_bottom = 3.0
	clout_status_btn.add_theme_stylebox_override(&"normal", c_style)
	clout_status_btn.add_theme_stylebox_override(&"hover", c_style)
	clout_status_btn.add_theme_stylebox_override(&"pressed", c_style)
	clout_status_btn.pressed.connect(_toggle_tasks_sheet)
	add_child(clout_status_btn)

	_refresh_objective_pill()
	_create_tasks_sheet_ui()


func _create_tasks_sheet_ui() -> void:
	tasks_sheet = PanelContainer.new()
	tasks_sheet.name = "TasksSheet"
	tasks_sheet.custom_minimum_size = Vector2(520, 580)
	tasks_sheet.anchors_preset = Control.PRESET_CENTER
	tasks_sheet.anchor_left = 0.5
	tasks_sheet.anchor_top = 0.5
	tasks_sheet.anchor_right = 0.5
	tasks_sheet.anchor_bottom = 0.5
	tasks_sheet.offset_left = -260.0
	tasks_sheet.offset_top = -290.0
	tasks_sheet.offset_right = 260.0
	tasks_sheet.offset_bottom = 290.0
	tasks_sheet.visible = false

	var sheet_style := StyleBoxFlat.new()
	sheet_style.bg_color = Color(0.07, 0.10, 0.15, 0.98)
	sheet_style.border_width_left = 2
	sheet_style.border_width_top = 2
	sheet_style.border_width_right = 2
	sheet_style.border_width_bottom = 2
	sheet_style.border_color = Color(1.0, 0.82, 0.24, 0.95)
	sheet_style.corner_radius_top_left = 14
	sheet_style.corner_radius_top_right = 14
	sheet_style.corner_radius_bottom_left = 14
	sheet_style.corner_radius_bottom_right = 14
	sheet_style.content_margin_left = 16.0
	sheet_style.content_margin_right = 16.0
	sheet_style.content_margin_top = 16.0
	sheet_style.content_margin_bottom = 14.0
	tasks_sheet.add_theme_stylebox_override(&"panel", sheet_style)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.add_theme_constant_override(&"separation", 8)
	tasks_sheet.add_child(outer_vbox)

	var title_lbl := Label.new()
	title_lbl.text = "📋 SEMESTER MISSIONS & TASKS"
	title_lbl.add_theme_font_size_override(&"font_size", 18)
	title_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.25))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "Complete campus milestones for cash, CGPA boosts & honor roll!"
	sub_lbl.add_theme_font_size_override(&"font_size", 13)
	sub_lbl.add_theme_color_override(&"font_color", Color(0.75, 0.85, 0.95))
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(sub_lbl)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll)

	var list_vbox := VBoxContainer.new()
	list_vbox.name = "TaskListVBox"
	list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_vbox.add_theme_constant_override(&"separation", 6)
	scroll.add_child(list_vbox)

	var close_btn := Button.new()
	close_btn.text = "✖ Close Missions"
	close_btn.custom_minimum_size = Vector2(0, 48)
	close_btn.add_theme_font_size_override(&"font_size", 15)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func():
		if SoundManager: SoundManager.play_click()
		tasks_sheet.visible = false
	)
	outer_vbox.add_child(close_btn)

	add_child(tasks_sheet)


func _toggle_tasks_sheet() -> void:
	if SoundManager:
		SoundManager.play_click()
	if not tasks_sheet:
		return
	tasks_sheet.visible = not tasks_sheet.visible
	if tasks_sheet.visible:
		_populate_tasks_sheet()


func compute_clout_rank() -> String:
	var has_gen: bool = StudentProfile.owned_upgrades.has("generator")
	var has_laptop: bool = StudentProfile.owned_upgrades.has("laptop")
	if _cached_money >= 25000 and _cached_cgpa >= 4.5:
		return "👑 Campus Legend"
	elif _cached_money >= 15000 or has_gen:
		return "💎 Campus Big Boy"
	elif _cached_cgpa >= 4.5:
		return "🏆 First Class Scholar"
	elif has_laptop:
		return "💻 Campus Tech Bro"
	elif _cached_cgpa >= 3.8:
		return "📚 Dean's List"
	return "🎒 100L Fresher"


func _populate_tasks_sheet() -> void:
	if not tasks_sheet:
		return
	var list_vbox: VBoxContainer = tasks_sheet.find_child("TaskListVBox", true, false) as VBoxContainer
	if not list_vbox:
		return

	for c in list_vbox.get_children():
		c.queue_free()

	var cur_step: int = PropBuilder3D.onboarding_quest_step
	var all_quests = PropBuilder3D.ONBOARDING_QUESTS

	# 1. Story Arc Chapter Header
	var story_panel := PanelContainer.new()
	var s_style := StyleBoxFlat.new()
	s_style.bg_color = Color(0.11, 0.16, 0.25, 0.96)
	s_style.border_width_left = 3
	s_style.border_width_top = 1
	s_style.border_width_right = 1
	s_style.border_width_bottom = 1
	s_style.border_color = Color(1.0, 0.82, 0.24, 0.95)
	s_style.corner_radius_top_left = 10
	s_style.corner_radius_top_right = 10
	s_style.corner_radius_bottom_left = 10
	s_style.corner_radius_bottom_right = 10
	s_style.content_margin_left = 12.0
	s_style.content_margin_right = 12.0
	s_style.content_margin_top = 8.0
	s_style.content_margin_bottom = 8.0
	story_panel.add_theme_stylebox_override(&"panel", s_style)

	var story_vbox := VBoxContainer.new()
	story_vbox.add_theme_constant_override(&"separation", 4)
	var chapter_title := "📖 CHAPTER 1: 100L FRESHER SURVIVAL"
	var chapter_desc := "Settle into Hall 1, attend Dr. Adebayo's CSC 101 lectures, eat hot Jollof at Mama Put, and survive NEPA blackouts!"
	if cur_step >= all_quests.size() and _cached_cgpa >= 4.4:
		chapter_title = "👑 CHAPTER 3: CAMPUS CLOUT & FIRST CLASS CONVOY"
		chapter_desc = "You're dominating academics and campus street credibility! Keep your CGPA above 4.50 and stack ₦25,000+ for Convocation Legend status."
	elif cur_step >= 5:
		chapter_title = "💻 CHAPTER 2: TECH HUSTLE, POP QUIZZES & SUG NIGHTS"
		chapter_desc = "Balance tough mid-semester tests with freelance gigs, SUB snooker tournaments, and evening chillouts at Love Garden."

	var ch_lbl := Label.new()
	ch_lbl.text = "%s  •  Rank: %s" % [chapter_title, compute_clout_rank()]
	ch_lbl.add_theme_font_size_override(&"font_size", 13)
	ch_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.32))
	story_vbox.add_child(ch_lbl)

	var ch_sub := Label.new()
	ch_sub.text = chapter_desc
	ch_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ch_sub.add_theme_font_size_override(&"font_size", 12)
	ch_sub.add_theme_color_override(&"font_color", Color(0.82, 0.90, 0.98))
	story_vbox.add_child(ch_sub)
	story_panel.add_child(story_vbox)
	list_vbox.add_child(story_panel)

	# 2. Fun Campus Loops Quick-Jump Row
	var fun_row := HBoxContainer.new()
	fun_row.add_theme_constant_override(&"separation", 6)
	var fun_spots: Array[Dictionary] = [
		{"label": "⚽ Stadium Penalty", "dest": &"stadium"},
		{"label": "🎱 SUB Snooker", "dest": &"sub"},
		{"label": "🍗 Mama Put", "dest": &"mama_put"},
		{"label": "💃 Love Garden", "dest": &"garden"}
	]
	for spot in fun_spots:
		var f_btn := Button.new()
		f_btn.text = String(spot["label"])
		f_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		f_btn.custom_minimum_size = Vector2(0, 32)
		f_btn.add_theme_font_size_override(&"font_size", 11)
		f_btn.focus_mode = Control.FOCUS_NONE
		var dest_id: StringName = spot["dest"]
		f_btn.pressed.connect(func():
			if SoundManager: SoundManager.play_click()
			tasks_sheet.visible = false
			objective_clicked.emit(dest_id)
		)
		fun_row.add_child(f_btn)
	list_vbox.add_child(fun_row)

	for i in range(all_quests.size()):
		var q: Dictionary = all_quests[i]
		var item_panel := PanelContainer.new()
		var p_style := StyleBoxFlat.new()
		p_style.corner_radius_top_left = 8
		p_style.corner_radius_top_right = 8
		p_style.corner_radius_bottom_right = 8
		p_style.corner_radius_bottom_left = 8
		p_style.content_margin_left = 10.0
		p_style.content_margin_right = 10.0
		p_style.content_margin_top = 8.0
		p_style.content_margin_bottom = 8.0

		var is_done: bool = i < cur_step
		var is_active: bool = (i == cur_step)

		if is_done:
			p_style.bg_color = Color(0.08, 0.14, 0.12, 0.85)
			p_style.border_color = Color(0.2, 0.6, 0.35, 0.6)
		elif is_active:
			p_style.bg_color = Color(0.15, 0.18, 0.28, 0.95)
			p_style.border_color = Color(1.0, 0.85, 0.25, 0.95)
		else:
			p_style.bg_color = Color(0.08, 0.10, 0.15, 0.75)
			p_style.border_color = Color(0.2, 0.25, 0.35, 0.5)

		p_style.border_width_left = 2 if (is_done or is_active) else 1
		p_style.border_width_top = 1
		p_style.border_width_right = 1
		p_style.border_width_bottom = 1
		item_panel.add_theme_stylebox_override(&"panel", p_style)

		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override(&"separation", 8)

		var text_lbl := Label.new()
		text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_lbl.add_theme_font_size_override(&"font_size", 14)

		if is_done:
			text_lbl.text = "✓ %s" % String(q.get("text", ""))
			text_lbl.add_theme_color_override(&"font_color", Color(0.45, 0.85, 0.55))
		elif is_active:
			text_lbl.text = "➔ %s" % String(q.get("text", ""))
			text_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.35))
		else:
			text_lbl.text = "🔒 %s" % String(q.get("text", ""))
			text_lbl.add_theme_color_override(&"font_color", Color(0.55, 0.60, 0.70))

		hbox.add_child(text_lbl)

		if is_active:
			var go_btn := Button.new()
			go_btn.text = "GO ➔"
			go_btn.custom_minimum_size = Vector2(56, 30)
			go_btn.add_theme_font_size_override(&"font_size", 11)
			go_btn.focus_mode = Control.FOCUS_NONE
			go_btn.pressed.connect(func():
				if SoundManager: SoundManager.play_click()
				tasks_sheet.visible = false
				objective_clicked.emit(q.get("dest", &"hostel"))
			)
			hbox.add_child(go_btn)

		item_panel.add_child(hbox)
		list_vbox.add_child(item_panel)


func _refresh_objective_pill() -> void:
	if not objective_btn:
		return
	var info: Dictionary = PropBuilder3D.get_smart_objective(_cached_energy, _cached_hunger, _cached_money, _cached_cgpa)
	objective_btn.text = "%s  [TAP]" % String(info.get("text", "🎯 Explore Campus"))
	objective_btn.add_theme_color_override(&"font_color", info.get("color", Color.WHITE))
	_current_obj_dest = info.get("dest", &"sub")
	if clout_status_btn:
		var online_cnt: int = 1
		if NetworkManager and NetworkManager.has_method("get_online_players"):
			online_cnt = maxi(1, NetworkManager.get_online_players().size())
		clout_status_btn.text = "%s  •  🟢 %d Online  •  📖 Story" % [compute_clout_rank(), online_cnt]
		clout_status_btn.add_theme_color_override(&"font_color", Color(0.85, 0.96, 0.90))
	if tasks_sheet and tasks_sheet.visible:
		_populate_tasks_sheet()


func _create_event_toast_ui() -> void:
	toast_panel = PanelContainer.new()
	toast_panel.name = "EventToastPanel"
	toast_panel.custom_minimum_size = Vector2(360, 64)
	toast_panel.anchors_preset = Control.PRESET_CENTER_TOP
	toast_panel.anchor_left = 0.5
	toast_panel.anchor_right = 0.5
	toast_panel.offset_left = -260.0
	toast_panel.offset_right = 260.0
	toast_panel.offset_top = -120.0 # Hidden above screen initially
	toast_panel.offset_bottom = -30.0
	toast_panel.modulate.a = 0.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.09, 0.14, 0.96)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 0.78, 0.28, 0.9) # Gold campus accent
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	toast_panel.add_theme_stylebox_override(&"panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 2)

	toast_title = Label.new()
	toast_title.name = "ToastTitle"
	toast_title.text = "⚡ CAMPUS NEWS"
	toast_title.add_theme_font_size_override(&"font_size", 15)
	toast_title.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.35))
	toast_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	toast_desc = Label.new()
	toast_desc.name = "ToastDesc"
	toast_desc.text = "Campus life update..."
	toast_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_desc.add_theme_font_size_override(&"font_size", 13)
	toast_desc.add_theme_color_override(&"font_color", Color(0.92, 0.94, 0.98))
	toast_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	vbox.add_child(toast_title)
	vbox.add_child(toast_desc)
	toast_panel.add_child(vbox)

	toast_panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_dismiss_toast()
	)

	add_child(toast_panel)


func _on_campus_event_triggered(_event_id: StringName, title: String, description: String) -> void:
	show_event_banner(title, description)


## Shows an animated banner at the top of the screen
func show_event_banner(title: String, description: String) -> void:
	if not toast_panel or not toast_title or not toast_desc:
		return

	toast_title.text = title
	toast_desc.text = description

	if toast_tween and toast_tween.is_valid():
		toast_tween.kill()

	toast_panel.offset_top = -120.0
	toast_panel.offset_bottom = -30.0
	toast_panel.modulate.a = 0.0

	toast_tween = create_tween()
	toast_tween.set_parallel(true)
	toast_tween.tween_property(toast_panel, "offset_top", 92.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	toast_tween.tween_property(toast_panel, "offset_bottom", 175.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.35)

	# Auto dismiss after 4.5 seconds
	toast_tween.chain().tween_interval(4.5)
	toast_tween.chain().tween_callback(_dismiss_toast)


func _dismiss_toast() -> void:
	if not toast_panel:
		return
	if toast_tween and toast_tween.is_valid():
		toast_tween.kill()

	toast_tween = create_tween()
	toast_tween.set_parallel(true)
	toast_tween.tween_property(toast_panel, "offset_top", -120.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	toast_tween.tween_property(toast_panel, "offset_bottom", -30.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.3)


func _update_time_display() -> void:
	if time_label:
		time_label.text = "%s  •  %s" % [TimeSystem.get_time_string(), TimeSystem.get_day_string()]
	if schedule_banner:
		schedule_banner.text = Schedule.get_next_event_text()
	_refresh_objective_pill()


func connect_player_needs(needs: NeedsManager) -> void:
	needs.stat_changed.connect(_on_stat_changed)
	needs.emit_all_stats()


func _on_stat_changed(stat_name: StringName, current_value: float, max_value: float) -> void:
	match stat_name:
		&"energy":
			_cached_energy = current_value
			if energy_bar:
				energy_bar.max_value = max_value
				energy_bar.value = current_value
		&"hunger":
			_cached_hunger = current_value
			if hunger_bar:
				hunger_bar.max_value = max_value
				hunger_bar.value = current_value
		&"faith":
			if faith_bar:
				faith_bar.max_value = max_value
				faith_bar.value = current_value
		&"cgpa":
			_cached_cgpa = current_value
			if cgpa_label:
				cgpa_label.text = "CGPA: %.2f / 5.0" % current_value
		&"money":
			_cached_money = int(current_value)
			if money_label:
				money_label.text = "Wallet: ₦%s" % _format_number(int(current_value))
	_refresh_objective_pill()


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s

