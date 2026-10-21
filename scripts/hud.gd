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
	objective_btn = Button.new()
	objective_btn.name = "ObjectivePillBtn"
	objective_btn.custom_minimum_size = Vector2(280, 34)
	objective_btn.anchors_preset = Control.PRESET_TOP_LEFT
	objective_btn.offset_left = 16.0
	objective_btn.offset_top = 86.0
	objective_btn.offset_right = 430.0
	objective_btn.offset_bottom = 122.0
	objective_btn.focus_mode = Control.FOCUS_NONE
	objective_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	objective_btn.add_theme_font_size_override(&"font_size", 13)
	objective_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var pill_style := StyleBoxFlat.new()
	pill_style.bg_color = Color(0.06, 0.11, 0.16, 0.88)
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
	pill_style.content_margin_top = 5.0
	pill_style.content_margin_bottom = 5.0
	objective_btn.add_theme_stylebox_override(&"normal", pill_style)
	objective_btn.add_theme_stylebox_override(&"hover", pill_style)
	objective_btn.add_theme_stylebox_override(&"pressed", pill_style)

	objective_btn.pressed.connect(func():
		if SoundManager:
			SoundManager.play_click()
		objective_clicked.emit(_current_obj_dest)
	)
	add_child(objective_btn)
	_refresh_objective_pill()


func _refresh_objective_pill() -> void:
	if not objective_btn:
		return
	var info: Dictionary = PropBuilder3D.get_smart_objective(_cached_energy, _cached_hunger, _cached_money, _cached_cgpa)
	objective_btn.text = "%s  [TAP]" % String(info.get("text", "🎯 Explore Campus"))
	objective_btn.add_theme_color_override(&"font_color", info.get("color", Color.WHITE))
	_current_obj_dest = info.get("dest", &"sub")


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

