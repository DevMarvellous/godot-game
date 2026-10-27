class_name PhoneSystem
extends Control

## In-Game Modern Nigerian Student Smartphone (Campus Connect).
## Features:
## 1. Responsive mobile & widescreen dynamic viewport layout
## 2. Dynamic Island & live status bar (MTN 5G, clock, real battery tied to energy)
## 3. Glassmorphic home screen with live campus radar widget, squircle app grid & bottom dock
## 4. OPay / CampusPay student banking (interactive card, Urgent 2k request, airtime recharge)
## 5. CampusChat (WhatsApp group channels: CSC 100L, Hostel 112, Mama Put with chat bubbles & replies)
## 6. Live Timetable Radar with 1-tap Danfo shuttle jump to active lecture
## 7. CGPA & Senate academic portal with visual progress & course breakdown
## 8. Campus Hustles marketplace (interactive gig cards with progress & instant payout)
## 9. Naija Campus Gist (Twitter / X feed with like counter & live tweet posting)
## 10. Backpack & provisions inventory with direct food consumption
## 11. Official Student ID pass with university verification
## 12. 4 AMOLED wallpapers & live theme switcher

signal phone_closed
signal hustle_performed(payout: int, message: String)
signal transit_requested(destination_name: StringName)

@onready var dark_backdrop: ColorRect = %DarkBackdrop if has_node("%DarkBackdrop") else null
@onready var phone_frame: PanelContainer = $CenterContainer/PhoneFrame if has_node("CenterContainer/PhoneFrame") else null
@onready var close_btn: Button = %ClosePhoneBtn
@onready var back_btn: Button = %BackBtn
@onready var action_btn: Button = %AppActionBtn
@onready var home_bar_btn: Button = %HomeBarBtn if has_node("%HomeBarBtn") else null

# Top Status Bar & Dynamic Island
@onready var phone_clock_label: Label = %PhoneClockLabel if has_node("%PhoneClockLabel") else null
@onready var phone_network_label: Label = %PhoneNetworkLabel if has_node("%PhoneNetworkLabel") else null
@onready var dynamic_island: Panel = %DynamicIsland if has_node("%DynamicIsland") else null
@onready var dynamic_island_label: Label = %DynamicIslandLabel if has_node("%DynamicIslandLabel") else null
@onready var app_title: Label = %AppTitleLabel

# Home Screen Containers
@onready var home_widgets: VBoxContainer = %HomeScreenWidgets if has_node("%HomeScreenWidgets") else null
@onready var big_clock_label: Label = %BigClockLabel if has_node("%BigClockLabel") else null
@onready var big_date_label: Label = %BigDateLabel if has_node("%BigDateLabel") else null
@onready var live_status_label: Label = %LiveStatusLabel if has_node("%LiveStatusLabel") else null
@onready var app_grid: GridContainer = %AppGrid
@onready var home_dock: PanelContainer = %HomeDock if has_node("%HomeDock") else null

# In-App Content Containers
@onready var app_content: PanelContainer = %AppContent
@onready var scroll_container: ScrollContainer = %ScrollContainer if has_node("%ScrollContainer") else null
@onready var dynamic_app_container: VBoxContainer = %DynamicAppContainer if has_node("%DynamicAppContainer") else null
@onready var content_label: Label = %ContentLabel

const WALLPAPERS: Array[Dictionary] = [
	{
		"name": "Deep Midnight AMOLED",
		"bg": Color(0.06, 0.08, 0.12, 0.98),
		"border": Color(0.24, 0.30, 0.40, 1.0)
	},
	{
		"name": "Golden Sunset Amber",
		"bg": Color(0.18, 0.08, 0.12, 0.98),
		"border": Color(0.85, 0.45, 0.20, 1.0)
	},
	{
		"name": "Emerald Quad Green",
		"bg": Color(0.04, 0.13, 0.08, 0.98),
		"border": Color(0.20, 0.70, 0.45, 1.0)
	},
	{
		"name": "Royal Campus Purple",
		"bg": Color(0.12, 0.06, 0.20, 0.98),
		"border": Color(0.65, 0.35, 0.90, 1.0)
	}
]

var current_wallpaper_idx: int = 0
var current_player: CharacterBody3D = null
var current_app_id: String = ""

# App-specific persistent states
var is_balance_hidden: bool = false
var active_chat_channel: String = "class" # "class", "hostel", "mamaput"
var chat_channels_data: Dictionary = {}
var campus_tweets_data: Array[Dictionary] = []


func _ready() -> void:
	visible = false

	if dark_backdrop:
		dark_backdrop.gui_input.connect(_on_backdrop_gui_input)

	if close_btn:
		close_btn.pressed.connect(close_phone)
	if back_btn:
		back_btn.pressed.connect(_show_home_screen)
	if action_btn:
		action_btn.pressed.connect(_on_app_action_pressed)

	if home_bar_btn:
		home_bar_btn.pressed.connect(func():
			if SoundManager: SoundManager.play_click()
			if app_content and app_content.visible:
				_show_home_screen()
			else:
				close_phone()
		)

	# App Grid Buttons
	_wire_app_btn(%IDCardAppBtn, "id_card")
	_wire_app_btn(%TimetableAppBtn, "timetable")
	_wire_app_btn(%ResultsAppBtn, "results")
	_wire_app_btn(%ChatAppBtn, "chat")
	_wire_app_btn(%BankAppBtn, "bank")
	_wire_app_btn(%HustleAppBtn, "hustle")
	if has_node("%GistAppBtn"):
		_wire_app_btn(%GistAppBtn, "gist")
	if has_node("%BackpackAppBtn"):
		_wire_app_btn(%BackpackAppBtn, "backpack")
	_wire_app_btn(%SettingsAppBtn, "settings")

	# Bottom Dock Buttons
	if has_node("%DockChatBtn"):
		%DockChatBtn.pressed.connect(func(): _open_app("chat"))
	if has_node("%DockBankBtn"):
		%DockBankBtn.pressed.connect(func(): _open_app("bank"))
	if has_node("%DockTimetableBtn"):
		%DockTimetableBtn.pressed.connect(func(): _open_app("timetable"))
	if has_node("%DockSettingsBtn"):
		%DockSettingsBtn.pressed.connect(func(): _open_app("settings"))

	# Responsive Viewport Resize
	get_viewport().size_changed.connect(_adjust_responsive_phone_layout)
	_adjust_responsive_phone_layout()

	_style_circular_app_logos()
	_init_chat_seed_data()
	_init_gist_seed_data()
	apply_wallpaper(0)


func _style_circular_app_logos() -> void:
	var app_configs: Array[Dictionary] = [
		{"node": "%IDCardAppBtn", "icon": "🪪", "title": "ID Pass", "bg": Color(0.14, 0.38, 0.82, 0.96), "border": Color(0.45, 0.72, 1.0, 0.95)},
		{"node": "%TimetableAppBtn", "icon": "📅", "title": "Classes", "bg": Color(0.85, 0.26, 0.22, 0.96), "border": Color(1.0, 0.62, 0.55, 0.95)},
		{"node": "%ResultsAppBtn", "icon": "📊", "title": "CGPA", "bg": Color(0.82, 0.54, 0.08, 0.96), "border": Color(1.0, 0.85, 0.35, 0.95)},
		{"node": "%ChatAppBtn", "icon": "💬", "title": "Chat", "bg": Color(0.08, 0.64, 0.38, 0.96), "border": Color(0.42, 0.95, 0.68, 0.95)},
		{"node": "%BankAppBtn", "icon": "💳", "title": "CampusPay", "bg": Color(0.06, 0.56, 0.52, 0.96), "border": Color(0.35, 0.95, 0.88, 0.95)},
		{"node": "%HustleAppBtn", "icon": "💼", "title": "Hustles", "bg": Color(0.48, 0.22, 0.78, 0.96), "border": Color(0.78, 0.55, 1.0, 0.95)},
		{"node": "%GistAppBtn", "icon": "🐦", "title": "CampusGist", "bg": Color(0.10, 0.55, 0.88, 0.96), "border": Color(0.50, 0.82, 1.0, 0.95)},
		{"node": "%BackpackAppBtn", "icon": "🎒", "title": "Backpack", "bg": Color(0.78, 0.34, 0.16, 0.96), "border": Color(1.0, 0.68, 0.45, 0.95)},
		{"node": "%SettingsAppBtn", "icon": "⚙️", "title": "Cloud OS", "bg": Color(0.22, 0.28, 0.38, 0.96), "border": Color(0.62, 0.72, 0.88, 0.95)}
	]
	if app_grid:
		app_grid.add_theme_constant_override(&"h_separation", 14)
		app_grid.add_theme_constant_override(&"v_separation", 10)

	for cfg in app_configs:
		var node_path: String = String(cfg["node"])
		if not has_node(node_path):
			continue
		var btn: Button = get_node(node_path) as Button
		if not btn:
			continue

		var cell_vbox := VBoxContainer.new()
		cell_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cell_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		cell_vbox.add_theme_constant_override(&"separation", 4)

		var parent_grid: Node = btn.get_parent()
		var idx: int = btn.get_index()
		parent_grid.remove_child(btn)
		parent_grid.add_child(cell_vbox)
		parent_grid.move_child(cell_vbox, idx)

		btn.text = String(cfg["icon"])
		btn.custom_minimum_size = Vector2(58, 58)
		btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		btn.add_theme_font_size_override(&"font_size", 24)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.focus_mode = Control.FOCUS_NONE

		var c_style := StyleBoxFlat.new()
		c_style.bg_color = cfg["bg"]
		c_style.border_width_left = 2
		c_style.border_width_top = 2
		c_style.border_width_right = 2
		c_style.border_width_bottom = 2
		c_style.border_color = cfg["border"]
		c_style.corner_radius_top_left = 29
		c_style.corner_radius_top_right = 29
		c_style.corner_radius_bottom_left = 29
		c_style.corner_radius_bottom_right = 29
		c_style.shadow_color = Color(0, 0, 0, 0.42)
		c_style.shadow_size = 6

		var h_style: StyleBoxFlat = c_style.duplicate() as StyleBoxFlat
		h_style.bg_color = Color(cfg["bg"]).lightened(0.14)
		h_style.border_color = Color.WHITE

		btn.add_theme_stylebox_override(&"normal", c_style)
		btn.add_theme_stylebox_override(&"hover", h_style)
		btn.add_theme_stylebox_override(&"pressed", h_style)
		cell_vbox.add_child(btn)

		var lbl := Label.new()
		lbl.text = String(cfg["title"])
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override(&"font_size", 11)
		lbl.add_theme_color_override(&"font_color", Color(0.92, 0.96, 1.0, 0.96))
		cell_vbox.add_child(lbl)

	# Style Dock Buttons as Circular Logos too
	var dock_configs: Array[Dictionary] = [
		{"node": "%DockChatBtn", "bg": Color(0.08, 0.64, 0.38, 0.95), "border": Color(0.42, 0.95, 0.68, 0.9)},
		{"node": "%DockBankBtn", "bg": Color(0.06, 0.56, 0.52, 0.95), "border": Color(0.35, 0.95, 0.88, 0.9)},
		{"node": "%DockTimetableBtn", "bg": Color(0.85, 0.26, 0.22, 0.95), "border": Color(1.0, 0.62, 0.55, 0.9)},
		{"node": "%DockSettingsBtn", "bg": Color(0.22, 0.28, 0.38, 0.95), "border": Color(0.62, 0.72, 0.88, 0.9)}
	]
	for dcfg in dock_configs:
		var dpath: String = String(dcfg["node"])
		if not has_node(dpath):
			continue
		var dbtn: Button = get_node(dpath) as Button
		if not dbtn:
			continue
		dbtn.custom_minimum_size = Vector2(46, 46)
		dbtn.focus_mode = Control.FOCUS_NONE
		dbtn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var d_style := StyleBoxFlat.new()
		d_style.bg_color = dcfg["bg"]
		d_style.border_width_left = 2
		d_style.border_width_top = 2
		d_style.border_width_right = 2
		d_style.border_width_bottom = 2
		d_style.border_color = dcfg["border"]
		d_style.corner_radius_top_left = 23
		d_style.corner_radius_top_right = 23
		d_style.corner_radius_bottom_left = 23
		d_style.corner_radius_bottom_right = 23
		dbtn.add_theme_stylebox_override(&"normal", d_style)
		dbtn.add_theme_stylebox_override(&"hover", d_style)
		dbtn.add_theme_stylebox_override(&"pressed", d_style)


func _on_backdrop_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_phone()


func _adjust_responsive_phone_layout() -> void:
	if not phone_frame:
		return
	var vp_size: Vector2 = get_viewport_rect().size
	var target_w: float = clampf(vp_size.x - 28.0, 320.0, 410.0)
	var target_h: float = clampf(vp_size.y - 44.0, 520.0, 680.0)
	phone_frame.custom_minimum_size = Vector2(target_w, target_h)


func apply_wallpaper(idx: int) -> void:
	current_wallpaper_idx = idx % WALLPAPERS.size()
	var wp: Dictionary = WALLPAPERS[current_wallpaper_idx]
	if phone_frame:
		var style: StyleBox = phone_frame.get_theme_stylebox("panel")
		if style is StyleBoxFlat:
			var new_style: StyleBoxFlat = style.duplicate() as StyleBoxFlat
			new_style.bg_color = wp.bg
			new_style.border_color = wp.border
			phone_frame.add_theme_stylebox_override("panel", new_style)


func _wire_app_btn(btn: Button, app_id: String) -> void:
	if btn:
		btn.pressed.connect(_open_app.bind(app_id))


func open_phone(p: CharacterBody3D) -> void:
	current_player = p
	_adjust_responsive_phone_layout()
	_update_phone_status_bar()
	visible = true
	_show_home_screen()
	if phone_frame:
		phone_frame.pivot_offset = phone_frame.size * 0.5
		phone_frame.scale = Vector2(0.92, 0.92)
		phone_frame.modulate.a = 0.0
		var tw: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(phone_frame, "scale", Vector2.ONE, 0.22)
		tw.tween_property(phone_frame, "modulate:a", 1.0, 0.16)


func close_phone() -> void:
	visible = false
	current_player = null
	if SoundManager:
		SoundManager.play_click()
	phone_closed.emit()


func _update_phone_status_bar() -> void:
	if phone_clock_label:
		var time_str: String = TimeSystem.get_time_string() if TimeSystem else "08:30 AM"
		var day_str: String = TimeSystem.get_weekday_name() if TimeSystem else "Mon"
		phone_clock_label.text = "%s • %s" % [time_str, day_str]

	if phone_network_label:
		var battery_pct: int = 100
		if current_player:
			var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
			if needs:
				battery_pct = int(clampf(needs.energy, 5.0, 100.0))

		var bat_color: Color = Color(0.35, 0.95, 0.55)
		if battery_pct < 25:
			bat_color = Color(0.95, 0.35, 0.35)
		elif battery_pct < 55:
			bat_color = Color(0.95, 0.85, 0.35)

		phone_network_label.add_theme_color_override("font_color", bat_color)
		phone_network_label.text = "📶 5G MTN  🔋 %d%%" % battery_pct

	if dynamic_island_label:
		dynamic_island_label.text = "• 🟢 •"


func _pulse_dynamic_island(text: String, alert_color: Color = Color(0.4, 0.9, 0.6)) -> void:
	if not dynamic_island_label or not dynamic_island:
		return
	dynamic_island_label.text = text
	dynamic_island_label.add_theme_color_override("font_color", alert_color)
	var tw: Tween = create_tween()
	tw.tween_property(dynamic_island, "custom_minimum_size:x", 120.0, 0.2)
	tw.tween_interval(1.5)
	tw.tween_property(dynamic_island, "custom_minimum_size:x", 96.0, 0.2)
	tw.tween_callback(func():
		if dynamic_island_label:
			dynamic_island_label.text = "• 🟢 •"
			dynamic_island_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.8))
	)


func _show_home_screen() -> void:
	current_app_id = ""
	if home_widgets:
		home_widgets.visible = true
	if app_grid:
		app_grid.visible = true
	if home_dock:
		home_dock.visible = true
	if app_content:
		app_content.visible = false
	if back_btn:
		back_btn.visible = false
	if action_btn:
		action_btn.visible = false
	if app_title:
		app_title.text = "📱 CAMPUS CONNECT"

	_update_phone_status_bar()

	if big_clock_label:
		big_clock_label.text = TimeSystem.get_time_string() if TimeSystem else "08:30"
	if big_date_label:
		var day_name: String = TimeSystem.get_weekday_name() if TimeSystem else "Monday"
		var day_num: int = TimeSystem.current_day if TimeSystem else 1
		big_date_label.text = "%s, Day %d • 29°C Campus" % [day_name, day_num]

	if live_status_label:
		var hour: int = TimeSystem.current_hour if TimeSystem else 8
		if hour >= 9 and hour < 11:
			live_status_label.text = "🔴 LIVE: GST 101 Lecture in LT1 (09:00 - 11:00)"
		elif hour >= 11 and hour < 13:
			live_status_label.text = "🍲 Lunch Break: Jollof & Dodo at Mama Put"
		elif hour >= 14 and hour < 16:
			live_status_label.text = "🔴 LIVE: CSC 101 Lecture in LT2 (14:00 - 16:00)"
		elif hour >= 17 and hour < 19:
			live_status_label.text = "⛪ Youth Fellowship: Campus Chapel (17:00)"
		elif hour >= 22 or hour < 6:
			live_status_label.text = "🌙 Curfew: Hostel Dormitory Quiet Hours"
		else:
			live_status_label.text = "📚 Study Break: Central Library & Quad Open"


func _open_app(app_id: String) -> void:
	current_app_id = app_id
	if SoundManager:
		SoundManager.play_click()

	if home_widgets:
		home_widgets.visible = false
	if app_grid:
		app_grid.visible = false
	if home_dock:
		home_dock.visible = false
	if app_content:
		app_content.visible = true
		app_content.modulate.a = 0.0
		var app_tw: Tween = create_tween()
		app_tw.tween_property(app_content, "modulate:a", 1.0, 0.14)
	if back_btn:
		back_btn.visible = true
	if action_btn:
		action_btn.visible = false

	_clear_dynamic_app_container()

	match app_id:
		"bank":
			_render_bank_app()
		"chat":
			_render_chat_app()
		"timetable":
			_render_timetable_app()
		"results":
			_render_results_app()
		"hustle":
			_render_hustle_app()
		"gist":
			_render_gist_app()
		"backpack":
			_render_backpack_app()
		"id_card":
			_render_id_card_app()
		"settings":
			_render_settings_app()
		_:
			app_title.text = "📱 APP"
			content_label.visible = true
			content_label.text = "Loading application..."


func _clear_dynamic_app_container() -> void:
	if not dynamic_app_container:
		return
	content_label.visible = false
	for child: Node in dynamic_app_container.get_children():
		if child != content_label:
			child.queue_free()


# ==============================================================================
# UI HELPER GENERATORS
# ==============================================================================

func _create_card(bg: Color = Color(0.11, 0.15, 0.22, 0.95), border: Color = Color(0.25, 0.35, 0.50, 0.7), radius: int = 14) -> PanelContainer:
	var pc: PanelContainer = PanelContainer.new()
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(1)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 12.0
	s.content_margin_top = 10.0
	s.content_margin_right = 12.0
	s.content_margin_bottom = 10.0
	pc.add_theme_stylebox_override("panel", s)
	return pc


func _create_styled_button(text: String, bg: Color = Color(0.15, 0.38, 0.65, 0.95), min_h: int = 38) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, min_h)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 13)
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = bg.lightened(0.2)
	s.set_border_width_all(1)
	s.set_corner_radius_all(10)
	s.content_margin_left = 10.0
	s.content_margin_right = 10.0
	btn.add_theme_stylebox_override("normal", s)
	var sh: StyleBoxFlat = s.duplicate() as StyleBoxFlat
	sh.bg_color = bg.lightened(0.12)
	btn.add_theme_stylebox_override("hover", sh)
	var sp: StyleBoxFlat = s.duplicate() as StyleBoxFlat
	sp.bg_color = bg.darkened(0.15)
	btn.add_theme_stylebox_override("pressed", sp)
	return btn


# ==============================================================================
# APP 1: 💳 CAMPUSPAY / OPAY MOBILE BANKING
# ==============================================================================

func _render_bank_app() -> void:
	app_title.text = "💳 CAMPUSPAY (MOBILE BANK)"

	var wallet: int = 5000
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			wallet = needs.money

	# Virtual Debit Card
	var card_panel: PanelContainer = _create_card(Color(0.04, 0.20, 0.12, 0.98), Color(0.10, 0.70, 0.35, 0.9), 16)
	var card_vbox: VBoxContainer = VBoxContainer.new()
	card_vbox.add_theme_constants_override("separation", 6)
	card_panel.add_child(card_vbox)

	var card_top: HBoxContainer = HBoxContainer.new()
	var bank_title: Label = Label.new()
	bank_title.text = "💳 CampusPay Debit • CBN Licensed"
	bank_title.add_theme_font_size_override("font_size", 12)
	bank_title.add_theme_color_override("font_color", Color(0.6, 0.95, 0.7))
	bank_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_top.add_child(bank_title)

	var eye_btn: Button = Button.new()
	eye_btn.text = "👁️ Show" if is_balance_hidden else "👁️ Hide"
	eye_btn.custom_minimum_size = Vector2(64, 26)
	eye_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	eye_btn.add_theme_font_size_override("font_size", 11)
	eye_btn.pressed.connect(func():
		is_balance_hidden = not is_balance_hidden
		if SoundManager: SoundManager.play_click()
		_open_app("bank")
	)
	card_top.add_child(eye_btn)
	card_vbox.add_child(card_top)

	var bal_lbl: Label = Label.new()
	bal_lbl.text = "₦ ••••••••" if is_balance_hidden else "₦ %s" % _format_number(wallet)
	bal_lbl.add_theme_font_size_override("font_size", 24)
	bal_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	card_vbox.add_child(bal_lbl)

	const StudentProfile = preload("res://scripts/data/student_profile.gd")
	var holder_lbl: Label = Label.new()
	holder_lbl.text = "%s • ACCT: 0812 345 6789" % StudentProfile.student_name.to_upper()
	holder_lbl.add_theme_font_size_override("font_size", 11)
	holder_lbl.add_theme_color_override("font_color", Color(0.75, 0.88, 0.80))
	card_vbox.add_child(holder_lbl)

	dynamic_app_container.add_child(card_panel)

	# Quick Banking Actions
	var act_title: Label = Label.new()
	act_title.text = "⚡ QUICK STUDENT SERVICES:"
	act_title.add_theme_font_size_override("font_size", 12)
	act_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	dynamic_app_container.add_child(act_title)

	# Urgent 2k Button
	var urgent_btn: Button = _create_styled_button("🆘 Request Urgent 2k from Parents", Color(0.18, 0.50, 0.28, 0.95))
	urgent_btn.pressed.connect(func():
		_handle_urgent_2k(urgent_btn)
	)
	dynamic_app_container.add_child(urgent_btn)

	# Watch Brand Sponsor Button
	var sponsor_btn: Button = _create_styled_button("📺 Watch Sponsor Ad on CampusPay (+₦2,000 Cash)", Color(0.12, 0.45, 0.65, 0.95))
	sponsor_btn.pressed.connect(func():
		if AdManager:
			AdManager.show_rewarded_ad("urgent_2k", current_player)
		sponsor_btn.text = "✓ Credited +₦2,000 Allowance!"
		sponsor_btn.disabled = true
		_update_phone_status_bar()
		_open_app("bank")
	)
	dynamic_app_container.add_child(sponsor_btn)

	# Buy 5G Airtime Button
	var airtime_btn: Button = _create_styled_button("📱 Buy MTN/Airtel Data (₦500 -> +25% Energy)", Color(0.15, 0.40, 0.55, 0.95))
	airtime_btn.pressed.connect(func():
		_handle_buy_airtime(airtime_btn)
	)
	dynamic_app_container.add_child(airtime_btn)

	# Instant Takeaway Meal Voucher Button
	var food_btn: Button = _create_styled_button("🍲 Order Mama Put Takeaway (-₦800)", Color(0.60, 0.35, 0.15, 0.95))
	food_btn.pressed.connect(func():
		_handle_buy_food_voucher(food_btn)
	)
	dynamic_app_container.add_child(food_btn)

	# Recent Transaction History
	var tx_title: Label = Label.new()
	tx_title.text = "📜 RECENT TRANSACTIONS:"
	tx_title.add_theme_font_size_override("font_size", 12)
	tx_title.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	dynamic_app_container.add_child(tx_title)

	var tx_card: PanelContainer = _create_card(Color(0.08, 0.10, 0.15, 0.9), Color(0.2, 0.25, 0.35, 0.6), 12)
	var tx_box: VBoxContainer = VBoxContainer.new()
	tx_card.add_child(tx_box)

	var tx_items: Array[Dictionary] = [
		{"title": "Allowance from Family", "amount": "+₦2,500", "is_credit": true, "time": "08:15 AM"},
		{"title": "Mama Put Canteen Lunch", "amount": "-₦800", "is_credit": false, "time": "Yesterday"},
		{"title": "Project Typing Gig", "amount": "+₦3,500", "is_credit": true, "time": "Yesterday"},
		{"title": "Danfo Campus Shuttle", "amount": "-₦200", "is_credit": false, "time": "Day 1"}
	]

	for tx: Dictionary in tx_items:
		var row: HBoxContainer = HBoxContainer.new()
		var l_desc: Label = Label.new()
		l_desc.text = "• %s (%s)" % [tx["title"], tx["time"]]
		l_desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_desc.add_theme_font_size_override("font_size", 12)
		row.add_child(l_desc)

		var l_amt: Label = Label.new()
		l_amt.text = tx["amount"]
		l_amt.add_theme_font_size_override("font_size", 12)
		l_amt.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5) if tx["is_credit"] else Color(0.95, 0.4, 0.4))
		row.add_child(l_amt)
		tx_box.add_child(row)

	dynamic_app_container.add_child(tx_card)


func _handle_urgent_2k(btn: Button) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if needs.cgpa >= 2.50:
		needs.modify_money(2500)
		TimeSystem.advance_minutes(15)
		if SoundManager: SoundManager.play_coin()
		_pulse_dynamic_island("💳 +₦2,500 Credited")
		btn.text = "✓ Dad Sent ₦2,500! 'Study hard!'"
		btn.disabled = true
		hustle_performed.emit(2500, "Received ₦2,500 family allowance via CampusPay!")
		if current_player.has_method("display_notification"):
			current_player.display_notification("Parents credited ₦2,500 into your CampusPay!")
	else:
		if SoundManager: SoundManager.play_alert()
		btn.text = "✗ Call Rejected: 'Improve your CGPA first!'"
		btn.disabled = true
		if current_player.has_method("display_notification"):
			current_player.display_notification("Parents: 'Your CGPA is too low! Read your books first!'")


func _handle_buy_airtime(btn: Button) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if needs.money >= 500:
		needs.modify_money(-500)
		needs.modify_energy(25.0)
		TimeSystem.advance_minutes(5)
		if SoundManager: SoundManager.play_coin()
		_pulse_dynamic_island("📶 Data Active (+25% Energy)")
		btn.text = "✓ Recharged ₦500 Data (+25% Energy)"
		btn.disabled = true
		_update_phone_status_bar()
		if current_player.has_method("display_notification"):
			current_player.display_notification("Recharged ₦500 5G Data! Stamina refreshed +25%.")
	else:
		if SoundManager: SoundManager.play_alert()
		btn.text = "✗ Insufficient Funds (Needs ₦500)"


func _handle_buy_food_voucher(btn: Button) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if needs.money >= 800:
		needs.modify_money(-800)
		const ProfileStore = preload("res://scripts/data/student_profile.gd")
		ProfileStore.load_from_disk()
		var items: Array[Dictionary] = ProfileStore.get_backpack_items()
		items.append({
			"id": "takeaway_jollof",
			"name": "Mama Put Takeaway Jollof & Dodo",
			"type": "food",
			"hunger": 50.0,
			"energy": 25.0,
			"desc": "Fresh hot firewood jollof rice with fried plantain in foil pack.",
			"count": 1
		})
		ProfileStore.save_to_disk()
		if SoundManager: SoundManager.play_coin()
		_pulse_dynamic_island("🍱 Takeaway In Bag")
		btn.text = "✓ Hot Jollof Added to Backpack 🎒"
		btn.disabled = true
		if current_player.has_method("display_notification"):
			current_player.display_notification("Purchased Jollof Takeaway! Stored in Backpack 🎒")
	else:
		if SoundManager: SoundManager.play_alert()
		btn.text = "✗ Insufficient Funds (Needs ₦800)"


# ==============================================================================
# APP 2: 💬 CAMPUSCHAT (WHATSAPP GROUPS & CHANNELS)
# ==============================================================================

func _init_chat_seed_data() -> void:
	chat_channels_data = {
		"class": [
			{"sender": "Emeka (Course Rep)", "msg": "📌 Lecture slides for CSC 101 have been pinned in Google Drive!", "time": "08:10", "is_me": false},
			{"sender": "Chisom", "msg": "Who is currently at LT1? Help me hold front row seat please!", "time": "08:14", "is_me": false},
			{"sender": "Segun", "msg": "Dr. Adebayo just walked into the department corridor with question papers!", "time": "08:20", "is_me": false}
		],
		"hostel": [
			{"sender": "Tolu (Room 112)", "msg": "NEPA light just restored! Bring your power banks and charge immediately!", "time": "07:45", "is_me": false},
			{"sender": "Kunle", "msg": "Hall Warden is doing boiling ring raid downstairs! Hide your heaters!", "time": "08:02", "is_me": false}
		],
		"mamaput": [
			{"sender": "Mama Cashout", "msg": "Hot firewood jollof, fried croaker fish, and soft dodo ready now! 🍲", "time": "08:00", "is_me": false},
			{"sender": "Mama Cashout", "msg": "Special 10% discount for 100L freshers before 12:00 PM!", "time": "08:05", "is_me": false}
		]
	}


func _render_chat_app() -> void:
	app_title.text = "💬 CAMPUSCHAT (WHATSAPP)"

	# Channel Navigation Tabs
	var tab_row: HBoxContainer = HBoxContainer.new()
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_row.add_theme_constants_override("separation", 6)

	var tabs: Array[Dictionary] = [
		{"id": "class", "title": "🟢 CSC 100L"},
		{"id": "hostel", "title": "🟡 Hostel 112"},
		{"id": "mamaput", "title": "🔴 Mama Put"}
	]

	for t: Dictionary in tabs:
		var tab_btn: Button = Button.new()
		tab_btn.text = t["title"]
		tab_btn.custom_minimum_size = Vector2(88, 30)
		tab_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tab_btn.add_theme_font_size_override("font_size", 11)

		var is_active: bool = (t["id"] == active_chat_channel)
		var st: StyleBoxFlat = StyleBoxFlat.new()
		st.bg_color = Color(0.12, 0.45, 0.30, 0.95) if is_active else Color(0.12, 0.16, 0.22, 0.8)
		st.set_border_width_all(1)
		st.border_color = Color(0.3, 0.8, 0.5) if is_active else Color(0.25, 0.35, 0.45, 0.5)
		st.set_corner_radius_all(10)
		tab_btn.add_theme_stylebox_override("normal", st)

		tab_btn.pressed.connect(func():
			active_chat_channel = t["id"]
			if SoundManager: SoundManager.play_click()
			_open_app("chat")
		)
		tab_row.add_child(tab_btn)

	dynamic_app_container.add_child(tab_row)

	# Message Feed Container
	var feed_card: PanelContainer = _create_card(Color(0.06, 0.09, 0.14, 0.95), Color(0.18, 0.26, 0.38, 0.6), 14)
	var feed_box: VBoxContainer = VBoxContainer.new()
	feed_box.add_theme_constants_override("separation", 8)
	feed_card.add_child(feed_box)

	var msgs: Array = chat_channels_data.get(active_chat_channel, [])
	for m: Dictionary in msgs:
		var bubble: PanelContainer = PanelContainer.new()
		var b_style: StyleBoxFlat = StyleBoxFlat.new()
		var is_me: bool = m.get("is_me", false)

		b_style.bg_color = Color(0.08, 0.32, 0.20, 0.95) if is_me else Color(0.12, 0.17, 0.25, 0.9)
		b_style.border_color = Color(0.2, 0.6, 0.35, 0.8) if is_me else Color(0.25, 0.35, 0.48, 0.5)
		b_style.set_border_width_all(1)
		b_style.set_corner_radius_all(10)
		b_style.content_margin_left = 10.0
		b_style.content_margin_top = 6.0
		b_style.content_margin_right = 10.0
		b_style.content_margin_bottom = 6.0
		bubble.add_theme_stylebox_override("panel", b_style)

		var b_vbox: VBoxContainer = VBoxContainer.new()
		b_vbox.add_theme_constants_override("separation", 2)
		bubble.add_child(b_vbox)

		var sender_lbl: Label = Label.new()
		sender_lbl.text = "You" if is_me else m.get("sender", "Contact")
		sender_lbl.add_theme_font_size_override("font_size", 11)
		sender_lbl.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65) if is_me else Color(0.95, 0.75, 0.3))
		b_vbox.add_child(sender_lbl)

		var text_lbl: Label = Label.new()
		text_lbl.text = m.get("msg", "")
		text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		text_lbl.add_theme_font_size_override("font_size", 12)
		b_vbox.add_child(text_lbl)

		var meta_lbl: Label = Label.new()
		meta_lbl.text = "%s ✓✓" % m.get("time", "Now") if is_me else m.get("time", "Now")
		meta_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		meta_lbl.add_theme_font_size_override("font_size", 10)
		meta_lbl.add_theme_color_override("font_color", Color(0.6, 0.75, 0.85, 0.8))
		b_vbox.add_child(meta_lbl)

		feed_box.add_child(bubble)

	dynamic_app_container.add_child(feed_card)

	# Interactive Quick Replies
	var rep_title: Label = Label.new()
	rep_title.text = "💬 SEND RELATABLE CAMPUS REPLY:"
	rep_title.add_theme_font_size_override("font_size", 11)
	rep_title.add_theme_color_override("font_color", Color(0.85, 0.90, 0.40))
	dynamic_app_container.add_child(rep_title)

	var replies: Array[String] = []
	match active_chat_channel:
		"class":
			replies = [
				"Who has Dr. Adebayo's soft copy lecture slides?",
				"Is attendance compulsory for today's lecture?",
				"Assignment submission deadline is Thursday right?"
			]
		"hostel":
			replies = [
				"Light don enter hostel? Coming back to charge!",
				"Who has extra boiling ring for morning water?",
				"Thanks for the tip! Hiding my electrical gadgets now."
			]
		"mamaput":
			replies = [
				"Mama Put, is hot jollof and fried fish ready?",
				"Please keep two takeaway packs for me, rushing down!"
			]

	for r_text: String in replies:
		var reply_btn: Button = _create_styled_button(r_text, Color(0.12, 0.30, 0.45, 0.9), 34)
		reply_btn.pressed.connect(func():
			_send_chat_message(r_text)
		)
		dynamic_app_container.add_child(reply_btn)


func _send_chat_message(text: String) -> void:
	var time_str: String = TimeSystem.get_time_string() if TimeSystem else "08:35"
	var my_msg: Dictionary = {"sender": "You", "msg": text, "time": time_str, "is_me": true}

	var msgs: Array = chat_channels_data.get(active_chat_channel, [])
	msgs.append(my_msg)

	if SoundManager: SoundManager.play_click()
	_pulse_dynamic_island("💬 Message Sent", Color(0.3, 0.9, 0.5))

	if current_player and current_player.has_method("show_chat_bubble"):
		current_player.show_chat_bubble("Sent on WhatsApp! 💬")

	# Realistic Instant Response from Coursemate
	var reply_data: Dictionary = {}
	match active_chat_channel:
		"class":
			reply_data = {"sender": "Emeka (Course Rep)", "msg": "Check the pinned Google Drive link! Slides uploaded! 📚", "time": time_str, "is_me": false}
		"hostel":
			reply_data = {"sender": "Kunle", "msg": "Yes bro, light is full! Bring your laptop and extensions! ⚡", "time": time_str, "is_me": false}
		"mamaput":
			reply_data = {"sender": "Mama Cashout", "msg": "Hot and spicy! Come chop my pikin! 🍲", "time": time_str, "is_me": false}

	msgs.append(reply_data)
	_open_app("chat")


# ==============================================================================
# APP 3: 📅 LECTURE TIMETABLE & LIVE RADAR
# ==============================================================================

func _render_timetable_app() -> void:
	app_title.text = "📅 LECTURE TIMETABLE & RADAR"

	# Live Lecture Radar Card
	var hour: int = TimeSystem.current_hour if TimeSystem else 9
	var radar_card: PanelContainer = _create_card(Color(0.15, 0.08, 0.08, 0.95), Color(0.85, 0.30, 0.25, 0.9), 14)
	var r_box: VBoxContainer = VBoxContainer.new()
	radar_card.add_child(r_box)

	var r_head: Label = Label.new()
	var dest_room: StringName = &"class"
	var r_btn_text: String = "🚌 Board Danfo Shuttle to LT1 Now"

	if hour >= 9 and hour < 11:
		r_head.text = "🔴 LIVE NOW: GST 101 Lecture in LT1"
		dest_room = &"class"
		r_btn_text = "🚌 Board Danfo Shuttle to LT1"
	elif hour >= 14 and hour < 16:
		r_head.text = "🔴 LIVE NOW: CSC 101 Lecture in LT2"
		dest_room = &"class2"
		r_btn_text = "🚌 Board Danfo Shuttle to LT2"
	elif hour >= 17 and hour < 19:
		r_head.text = "⛪ YOUTH FELLOWSHIP: Campus Chapel"
		dest_room = &"chapel"
		r_btn_text = "⛪ Walk to Fellowship at Chapel"
	elif hour >= 22 or hour < 6:
		r_head.text = "🌙 HOSTEL CURFEW: Night Dormitory Quiet"
		dest_room = &"hostel"
		r_btn_text = "🛏️ Return to Hostel Room 112"
	else:
		r_head.text = "☕ FREE STUDY PERIOD: Central Library Open"
		dest_room = &"library"
		r_btn_text = "📖 Walk to Central Library Hall"

	r_head.add_theme_font_size_override("font_size", 13)
	r_head.add_theme_color_override("font_color", Color(1.0, 0.4, 0.35))
	r_box.add_child(r_head)

	var transit_btn: Button = _create_styled_button(r_btn_text, Color(0.75, 0.25, 0.20, 0.95), 36)
	transit_btn.pressed.connect(func():
		if SoundManager: SoundManager.play_click()
		close_phone()
		transit_requested.emit(dest_room)
	)
	r_box.add_child(transit_btn)

	dynamic_app_container.add_child(radar_card)

	# Full Semester Schedule Cards
	var sched_title: Label = Label.new()
	sched_title.text = "📋 WEEKLY LECTURE SCHEDULE:"
	sched_title.add_theme_font_size_override("font_size", 12)
	sched_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	dynamic_app_container.add_child(sched_title)

	var lecs: Array[Dictionary] = [
		{"code": "GST 101", "name": "Use of English & Communication", "time": "09:00 - 11:00", "hall": "Lecture Theatre 1 (LT1)", "unit": "2 Units"},
		{"code": "CSC 101", "name": "Introduction to Computer Science", "time": "14:00 - 16:00", "hall": "Lecture Theatre 2 (LT2)", "unit": "3 Units"},
		{"code": "MTH 101", "name": "General Mathematics & Calculus", "time": "11:30 - 13:00", "hall": "Science Block Hall A", "unit": "4 Units"},
		{"code": "PHY 101", "name": "General Physics Practical Lab", "time": "16:30 - 18:00", "hall": "Physics Lab Complex", "unit": "3 Units"}
	]

	for l: Dictionary in lecs:
		var c_panel: PanelContainer = _create_card(Color(0.09, 0.12, 0.18, 0.9), Color(0.22, 0.30, 0.45, 0.6), 12)
		var c_vbox: VBoxContainer = VBoxContainer.new()
		c_vbox.add_theme_constants_override("separation", 2)
		c_panel.add_child(c_vbox)

		var top_h: HBoxContainer = HBoxContainer.new()
		var code_l: Label = Label.new()
		code_l.text = "%s • %s" % [l["code"], l["name"]]
		code_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		code_l.add_theme_font_size_override("font_size", 12)
		code_l.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		top_h.add_child(code_l)

		var u_l: Label = Label.new()
		u_l.text = l["unit"]
		u_l.add_theme_font_size_override("font_size", 11)
		u_l.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
		top_h.add_child(u_l)
		c_vbox.add_child(top_h)

		var sub_l: Label = Label.new()
		sub_l.text = "🕒 %s  |  📍 %s" % [l["time"], l["hall"]]
		sub_l.add_theme_font_size_override("font_size", 11)
		sub_l.add_theme_color_override("font_color", Color(0.75, 0.85, 0.90))
		c_vbox.add_child(sub_l)

		dynamic_app_container.add_child(c_panel)


# ==============================================================================
# APP 4: 📊 CGPA & SENATE RESULTS PORTAL
# ==============================================================================

func _render_results_app() -> void:
	app_title.text = "📊 RESULTS & CGPA PORTAL"

	var cgpa: float = 3.85
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			cgpa = needs.cgpa

	# GPA Metric Card
	var gpa_card: PanelContainer = _create_card(Color(0.12, 0.10, 0.04, 0.95), Color(0.85, 0.65, 0.15, 0.9), 16)
	var g_vbox: VBoxContainer = VBoxContainer.new()
	g_vbox.add_theme_constants_override("separation", 4)
	gpa_card.add_child(g_vbox)

	var g_title: Label = Label.new()
	g_title.text = "CUMULATIVE GRADE POINT AVERAGE (CGPA)"
	g_title.add_theme_font_size_override("font_size", 11)
	g_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.5))
	g_vbox.add_child(g_title)

	var g_num: Label = Label.new()
	g_num.text = "%.2f / 5.00" % cgpa
	g_num.add_theme_font_size_override("font_size", 26)
	g_num.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	g_vbox.add_child(g_num)

	var class_str: String = _get_class_text(cgpa)
	var badge_str: String = "🏆 %s" % class_str if cgpa >= 4.50 else "🎖️ %s" % class_str
	var g_class: Label = Label.new()
	g_class.text = "%s • Academic Standing: CLEAR" % badge_str
	g_class.add_theme_font_size_override("font_size", 12)
	g_class.add_theme_color_override("font_color", Color(0.4, 0.95, 0.65))
	g_vbox.add_child(g_class)

	dynamic_app_container.add_child(gpa_card)

	# Course Breakdown
	var c_head: Label = Label.new()
	c_head.text = "📝 100 LEVEL 1ST SEMESTER GRADES:"
	c_head.add_theme_font_size_override("font_size", 12)
	c_head.add_theme_color_override("font_color", Color(0.7, 0.85, 0.95))
	dynamic_app_container.add_child(c_head)

	var courses: Array[Dictionary] = [
		{"code": "CSC 101", "name": "Intro to Computing", "ca": 28, "exam": 62, "grade": "A", "gp": 5.0},
		{"code": "MTH 101", "name": "General Mathematics", "ca": 24, "exam": 54, "grade": "A", "gp": 5.0},
		{"code": "GST 101", "name": "Use of English", "ca": 26, "exam": 48, "grade": "B", "gp": 4.0},
		{"code": "PHY 101", "name": "General Physics", "ca": 22, "exam": 50, "grade": "B", "gp": 4.0},
		{"code": "CHM 101", "name": "General Chemistry", "ca": 25, "exam": 56, "grade": "A", "gp": 5.0}
	]

	for c: Dictionary in courses:
		var row_card: PanelContainer = _create_card(Color(0.08, 0.11, 0.16, 0.9), Color(0.20, 0.28, 0.40, 0.6), 10)
		var r_h: HBoxContainer = HBoxContainer.new()
		row_card.add_child(r_h)

		var info_l: Label = Label.new()
		info_l.text = "%s: %s (CA %d/30 | Exam %d/70)" % [c["code"], c["name"], c["ca"], c["exam"]]
		info_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_l.add_theme_font_size_override("font_size", 11)
		r_h.add_child(info_l)

		var g_badge: Label = Label.new()
		g_badge.text = "[ %s ]" % c["grade"]
		g_badge.add_theme_font_size_override("font_size", 13)
		g_badge.add_theme_color_override("font_color", Color(0.3, 0.95, 0.6) if c["grade"] == "A" else Color(0.4, 0.8, 1.0))
		r_h.add_child(g_badge)

		dynamic_app_container.add_child(row_card)

	# Cloud Sync & Global Dean's List Hub
	var cloud_card: PanelContainer = _create_card(Color(0.06, 0.12, 0.18, 0.95), Color(0.20, 0.65, 0.90, 0.8), 12)
	var cl_vbox: VBoxContainer = VBoxContainer.new()
	cl_vbox.add_theme_constant_override("separation", 6)
	cloud_card.add_child(cl_vbox)

	var cl_header: HBoxContainer = HBoxContainer.new()
	var cl_title: Label = Label.new()
	var is_cloud: bool = SupabaseClient.is_authenticated if SupabaseClient else false
	cl_title.text = "☁️ CLOUD DATABASE & LEADERBOARD"
	cl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cl_title.add_theme_font_size_override("font_size", 12)
	cl_title.add_theme_color_override("font_color", Color(0.40, 0.85, 1.0))
	cl_header.add_child(cl_title)

	var status_tag: Label = Label.new()
	status_tag.text = "🟢 ONLINE" if is_cloud else "🟡 LOCAL SAVE"
	status_tag.add_theme_font_size_override("font_size", 11)
	status_tag.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55) if is_cloud else Color(1.0, 0.85, 0.35))
	cl_header.add_child(status_tag)
	cl_vbox.add_child(cl_header)

	var sync_btn: Button = _create_styled_button("☁️ Sync Semester State to Cloud (Supabase)", Color(0.12, 0.35, 0.55, 0.95), 36)
	sync_btn.pressed.connect(func():
		StudentProfile.load_from_disk()
		if SupabaseClient:
			SupabaseClient.sync_profile_to_cloud(StudentProfile.get_profile_data())
		if SoundManager: SoundManager.play_bell()
		_pulse_dynamic_island("☁️ Cloud Synced!", Color(0.35, 0.85, 1.0))
	)
	cl_vbox.add_child(sync_btn)

	var deans_btn: Button = _create_styled_button("🏆 View University Dean's List (Top Scholars)", Color(0.15, 0.28, 0.40, 0.9), 34)
	deans_btn.pressed.connect(func():
		_open_deans_list_view()
	)
	cl_vbox.add_child(deans_btn)

	var wealth_btn: Button = _create_styled_button("💰 View CampusPay Wealth Leaderboard (Top Hustlers)", Color(0.14, 0.36, 0.24, 0.9), 34)
	wealth_btn.pressed.connect(func():
		_open_wealth_leaderboard_view()
	)
	cl_vbox.add_child(wealth_btn)

	var lobby_btn: Button = _create_styled_button("🌐 Live Online Multiplayer Lobby & Room Radar", Color(0.24, 0.16, 0.42, 0.95), 34)
	lobby_btn.pressed.connect(func():
		_open_multiplayer_lobby_view()
	)
	cl_vbox.add_child(lobby_btn)

	dynamic_app_container.add_child(cloud_card)


func _open_wealth_leaderboard_view() -> void:
	app_title.text = "💰 WEALTH LEADERBOARD"
	for c in dynamic_app_container.get_children():
		c.queue_free()

	var banner := _create_card(Color(0.06, 0.18, 0.12, 0.95), Color(0.25, 0.90, 0.55, 0.9), 14)
	var b_box := VBoxContainer.new()
	banner.add_child(b_box)

	var t_lbl := Label.new()
	t_lbl.text = "CAMPUSPAY RICHEST STUDENT HUSTLERS"
	t_lbl.add_theme_font_size_override("font_size", 13)
	t_lbl.add_theme_color_override("font_color", Color(0.35, 0.98, 0.62))
	b_box.add_child(t_lbl)

	var sub := Label.new()
	sub.text = "Top Verified Student Entrepreneurs & Freelancers Across Campus"
	sub.add_theme_font_size_override("font_size", 11)
	sub.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	b_box.add_child(sub)
	dynamic_app_container.add_child(banner)

	const TOP_HUSTLERS: Array[Dictionary] = [
		{"rank": "1st", "name": "Emeka Tech O.", "dept": "CSC", "bal": 185000, "role": "💻 Lead Software Contractor"},
		{"rank": "2nd", "name": "Tolani Davies", "dept": "SMS", "bal": 142000, "role": "🛍️ Campus Mall Fashion Partner"},
		{"rank": "3rd", "name": "Damilola B.", "dept": "ENG", "bal": 98000, "role": "🚐 Shuttle Fleet Logistics"},
		{"rank": "4th", "name": "Halima Lawal", "dept": "LAW", "bal": 87500, "role": "⚖️ Chambers Research Clerk"},
		{"rank": "5th", "name": "Segun Alabi", "dept": "CSC", "bal": 74000, "role": "🎱 SUB 9-Ball Snooker Pro"},
		{"rank": "6th", "name": "Kemi Adeleke", "dept": "NAS", "bal": 62000, "role": "🍲 Buka Catering Supplier"}
	]

	for h_data in TOP_HUSTLERS:
		var s_card := _create_card(Color(0.08, 0.12, 0.16, 0.9), Color(0.20, 0.45, 0.35, 0.7), 10)
		var h := HBoxContainer.new()
		s_card.add_child(h)

		var rank_lbl := Label.new()
		rank_lbl.text = h_data["rank"]
		rank_lbl.custom_minimum_size = Vector2(36, 0)
		rank_lbl.add_theme_font_size_override("font_size", 13)
		rank_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
		h.add_child(rank_lbl)

		var name_box := VBoxContainer.new()
		name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var n_lbl := Label.new()
		n_lbl.text = "%s (%s)" % [h_data["name"], h_data["dept"]]
		n_lbl.add_theme_font_size_override("font_size", 12)
		name_box.add_child(n_lbl)

		var b_lbl := Label.new()
		b_lbl.text = h_data["role"]
		b_lbl.add_theme_font_size_override("font_size", 10)
		b_lbl.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0))
		name_box.add_child(b_lbl)
		h.add_child(name_box)

		var bal_lbl := Label.new()
		bal_lbl.text = "₦%s" % _format_number(int(h_data["bal"]))
		bal_lbl.add_theme_font_size_override("font_size", 13)
		bal_lbl.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55))
		h.add_child(bal_lbl)

		dynamic_app_container.add_child(s_card)

	var back_btn_w := _create_styled_button("◀ Back to Academic & Cloud Portal", Color(0.18, 0.25, 0.35, 0.95), 36)
	back_btn_w.pressed.connect(func():
		_render_results_app()
	)
	dynamic_app_container.add_child(back_btn_w)


func _open_multiplayer_lobby_view() -> void:
	app_title.text = "🌐 LIVE ONLINE LOBBY"
	for c in dynamic_app_container.get_children():
		c.queue_free()

	var peer_count: int = NetworkManager.remote_players.size() if NetworkManager else 3
	var status_card := _create_card(Color(0.08, 0.16, 0.24, 0.95), Color(0.35, 0.85, 1.0, 0.9), 14)
	var s_box := VBoxContainer.new()
	status_card.add_child(s_box)

	var st_title := Label.new()
	st_title.text = "🟢 CAMPUS REALTIME SERVER: ONLINE (%d PEERS)" % (peer_count + 1)
	st_title.add_theme_font_size_override("font_size", 13)
	st_title.add_theme_color_override("font_color", Color(0.35, 0.98, 0.62))
	s_box.add_child(st_title)

	var st_sub := Label.new()
	st_sub.text = "Walk up to any online student in 3D and tap them to Wave, Dance Gbese, or Study Together!"
	st_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	st_sub.add_theme_font_size_override("font_size", 11)
	st_sub.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	s_box.add_child(st_sub)
	dynamic_app_container.add_child(status_card)

	if NetworkManager:
		for pid in NetworkManager.remote_players.keys():
			var pdata: Dictionary = NetworkManager.remote_players[pid]
			var p_card := _create_card(Color(0.08, 0.11, 0.16, 0.9), Color(0.25, 0.40, 0.55, 0.7), 10)
			var h := HBoxContainer.new()
			p_card.add_child(h)

			var info_v := VBoxContainer.new()
			info_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var nl := Label.new()
			nl.text = "🟢 %s" % String(pdata.get("name", "Student"))
			nl.add_theme_font_size_override("font_size", 12)
			info_v.add_child(nl)

			var rl := Label.new()
			rl.text = "📍 Location: %s" % String(pdata.get("room", "Courtyard"))
			rl.add_theme_font_size_override("font_size", 10)
			rl.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0))
			info_v.add_child(rl)
			h.add_child(info_v)

			var wave_b := Button.new()
			wave_b.text = "👋 Ping"
			wave_b.custom_minimum_size = Vector2(68, 30)
			wave_b.add_theme_font_size_override("font_size", 11)
			wave_b.pressed.connect(func():
				NetworkManager.broadcast_chat("How far %s! Where you dey?" % String(pdata.get("name", "guy")))
				_pulse_dynamic_island("💬 Ping Sent!", Color(0.35, 0.95, 0.6))
			)
			h.add_child(wave_b)
			dynamic_app_container.add_child(p_card)

	var back_btn_l := _create_styled_button("◀ Back to Academic & Cloud Portal", Color(0.18, 0.25, 0.35, 0.95), 36)
	back_btn_l.pressed.connect(func():
		_render_results_app()
	)
	dynamic_app_container.add_child(back_btn_l)


func _open_deans_list_view() -> void:
	app_title.text = "🏆 GLOBAL DEAN'S LIST"
	for c in dynamic_app_container.get_children():
		c.queue_free()

	var banner := _create_card(Color(0.14, 0.12, 0.04, 0.95), Color(0.95, 0.80, 0.20, 0.9), 14)
	var b_box := VBoxContainer.new()
	banner.add_child(b_box)

	var t_lbl := Label.new()
	t_lbl.text = "FEDERAL UNIVERSITY DEAN'S HONOUR ROLL"
	t_lbl.add_theme_font_size_override("font_size", 13)
	t_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.35))
	b_box.add_child(t_lbl)

	var sub := Label.new()
	sub.text = "Highest Academic Distinctions Across All Faculties (Minimum 4.50 CGPA)"
	sub.add_theme_font_size_override("font_size", 11)
	sub.add_theme_color_override("font_color", Color(0.85, 0.90, 0.95))
	b_box.add_child(sub)
	dynamic_app_container.add_child(banner)

	const MOCK_SCHOLARS: Array[Dictionary] = [
		{"rank": "1st", "name": "Chidinma Okonjo", "dept": "MEE", "cgpa": "4.95", "badge": "👑 Dean's Scholar"},
		{"rank": "2nd", "name": "Femi Adeleke", "dept": "CSC", "cgpa": "4.88", "badge": "⭐ First Class"},
		{"rank": "3rd", "name": "Tari Ebiye", "dept": "PET", "cgpa": "4.82", "badge": "⭐ First Class"},
		{"rank": "4th", "name": "Blessing Adeyemi", "dept": "MBBS", "cgpa": "4.79", "badge": "🩺 Distinction"},
		{"rank": "5th", "name": "Ibrahim Danjuma", "dept": "LAW", "cgpa": "4.75", "badge": "⚖️ First Class"},
		{"rank": "6th", "name": "Kelechi Nwosu", "dept": "SWE", "cgpa": "4.71", "badge": "💻 First Class"},
		{"rank": "7th", "name": "Zainab Bello", "dept": "ACC", "cgpa": "4.65", "badge": "📊 First Class"}
	]

	for s in MOCK_SCHOLARS:
		var s_card := _create_card(Color(0.08, 0.11, 0.16, 0.9), Color(0.25, 0.35, 0.50, 0.7), 10)
		var h := HBoxContainer.new()
		s_card.add_child(h)

		var rank_lbl := Label.new()
		rank_lbl.text = s["rank"]
		rank_lbl.custom_minimum_size = Vector2(36, 0)
		rank_lbl.add_theme_font_size_override("font_size", 13)
		rank_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
		h.add_child(rank_lbl)

		var name_box := VBoxContainer.new()
		name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var n_lbl := Label.new()
		n_lbl.text = "%s (%s)" % [s["name"], s["dept"]]
		n_lbl.add_theme_font_size_override("font_size", 12)
		name_box.add_child(n_lbl)

		var b_lbl := Label.new()
		b_lbl.text = s["badge"]
		b_lbl.add_theme_font_size_override("font_size", 10)
		b_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6))
		name_box.add_child(b_lbl)
		h.add_child(name_box)

		var gpa_lbl := Label.new()
		gpa_lbl.text = s["cgpa"]
		gpa_lbl.add_theme_font_size_override("font_size", 14)
		gpa_lbl.add_theme_color_override("font_color", Color(0.35, 0.95, 0.55))
		h.add_child(gpa_lbl)

		dynamic_app_container.add_child(s_card)

	var back_to_portal_btn := _create_styled_button("◀ Back to Academic Portal", Color(0.18, 0.25, 0.35, 0.95), 36)
	back_to_portal_btn.pressed.connect(func():
		_render_results_app()
	)
	dynamic_app_container.add_child(back_to_portal_btn)


# ==============================================================================
# APP 5: 💼 STUDENT HUSTLE & FREELANCE GIGS
# ==============================================================================

func _render_hustle_app() -> void:
	app_title.text = "💼 STUDENT HUSTLES & GIGS"

	# Featured Promo Card
	var promo_card: PanelContainer = _create_card(Color(0.18, 0.10, 0.25, 0.95), Color(0.70, 0.35, 0.90, 0.9), 14)
	var p_box: VBoxContainer = VBoxContainer.new()
	promo_card.add_child(p_box)

	var p_title: Label = Label.new()
	p_title.text = "📺 SPONSORED CAMPUS BRAND PROMO"
	p_title.add_theme_font_size_override("font_size", 12)
	p_title.add_theme_color_override("font_color", Color(0.9, 0.7, 1.0))
	p_box.add_child(p_title)

	var p_sub: Label = Label.new()
	p_sub.text = "+₦1,500 Cash credited & +25% Energy stamina boost!"
	p_sub.add_theme_font_size_override("font_size", 11)
	p_sub.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95))
	p_box.add_child(p_sub)

	var ad_btn: Button = _create_styled_button("Claim Promo (+₦1,500 & +25% Energy)", Color(0.55, 0.20, 0.75, 0.95), 34)
	ad_btn.pressed.connect(func():
		_handle_promo_ad(ad_btn)
	)
	p_box.add_child(ad_btn)

	dynamic_app_container.add_child(promo_card)

	# Gigs Marketplace
	const CampusGigsData = preload("res://scripts/data/campus_gigs.gd")
	var gigs: Array[Dictionary] = CampusGigsData.get_all_gigs()

	var g_title: Label = Label.new()
	g_title.text = "🛠️ AVAILABLE CAMPUS SIDE HUSTLES:"
	g_title.add_theme_font_size_override("font_size", 12)
	g_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	dynamic_app_container.add_child(g_title)

	for g: Dictionary in gigs:
		var g_card: PanelContainer = _create_card(Color(0.08, 0.11, 0.16, 0.9), Color(0.20, 0.30, 0.45, 0.6), 12)
		var g_vbox: VBoxContainer = VBoxContainer.new()
		g_vbox.add_theme_constants_override("separation", 4)
		g_card.add_child(g_vbox)

		var g_head: HBoxContainer = HBoxContainer.new()
		var name_l: Label = Label.new()
		name_l.text = "%s %s" % [g.get("icon", "💼"), g.get("title", "Gig")]
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.add_theme_font_size_override("font_size", 12)
		name_l.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		g_head.add_child(name_l)

		var pay_l: Label = Label.new()
		pay_l.text = "+₦%s" % _format_number(int(g.get("payout", 1000)))
		pay_l.add_theme_font_size_override("font_size", 12)
		pay_l.add_theme_color_override("font_color", Color(0.3, 0.95, 0.55))
		g_head.add_child(pay_l)
		g_vbox.add_child(g_head)

		var desc_l: Label = Label.new()
		desc_l.text = "%s\n📍 %s • ⚡ -%d%% Energy" % [g.get("desc", ""), g.get("location", "Campus"), int(g.get("energy_cost", 20))]
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_l.add_theme_font_size_override("font_size", 11)
		desc_l.add_theme_color_override("font_color", Color(0.75, 0.85, 0.90))
		g_vbox.add_child(desc_l)

		var start_btn: Button = _create_styled_button("Start Gig ⚡ (+₦%s)" % _format_number(int(g.get("payout", 1000))), Color(0.18, 0.42, 0.30, 0.95), 32)
		start_btn.pressed.connect(func():
			_perform_gig(g, start_btn)
		)
		g_vbox.add_child(start_btn)

		dynamic_app_container.add_child(g_card)


func _handle_promo_ad(btn: Button) -> void:
	if not current_player:
		return
	if AdManager:
		AdManager.show_rewarded_ad("urgent_2k", current_player)
	else:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_money(2000)
			needs.modify_energy(25.0)

	TimeSystem.advance_minutes(5)
	if SoundManager: SoundManager.play_coin()
	_pulse_dynamic_island("+₦2,000 & +50% Energy")
	btn.text = "✓ Reward Claimed (+₦2,000, +50% Energy)"
	btn.disabled = true
	_update_phone_status_bar()
	hustle_performed.emit(2000, "Watched Sponsored Campus Brand Ad! +₦2,000, +50 Energy")
	if current_player.has_method("display_notification"):
		current_player.display_notification("Claimed Sponsor Reward! +₦1,500 Cash, +25% Energy.")


func _perform_gig(gig: Dictionary, btn: Button) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var cost: float = float(gig.get("energy_cost", 20.0))
	var payout: int = int(gig.get("payout", 1500))

	if needs.energy < cost:
		if SoundManager: SoundManager.play_alert()
		btn.text = "⚠️ Sapa Alert: Low Energy! Rest or Eat First"
		return

	needs.modify_energy(-cost)
	needs.modify_money(payout)
	TimeSystem.advance_minutes(int(gig.get("duration_minutes", 30)))
	if SoundManager: SoundManager.play_coin()
	_pulse_dynamic_island("+₦%s Earned!" % _format_number(payout))
	btn.text = "✓ Gig Done! (+₦%s)" % _format_number(payout)
	btn.disabled = true
	_update_phone_status_bar()

	hustle_performed.emit(payout, "Completed %s (+₦%s)" % [gig.get("title", "Gig"), _format_number(payout)])
	if current_player.has_method("display_notification"):
		current_player.display_notification("Completed %s! Earned ₦%s." % [gig.get("title", "Gig"), _format_number(payout)])


# ==============================================================================
# APP 6: 🐦 NAIJA CAMPUS GIST (TWITTER / X FEED)
# ==============================================================================

func _init_gist_seed_data() -> void:
	campus_tweets_data = [
		{"handle": "@UnilagAproko", "name": "Campus Aproko (Verified)", "text": "Why is Hall Warden raiding rooms for boiling rings by 6:00 AM abeg? 😭 Somebody's Indomie got seized!", "likes": 342, "time": "15m ago"},
		{"handle": "@SapaSurvivoor", "name": "Fresher On Budget", "text": "Whoever invented 2-for-1 Indomie and boiled egg at SUB, God will bless your entire lineage! 🙏", "likes": 218, "time": "45m ago"},
		{"handle": "@SUG_President", "name": "Comrade Ojo", "text": "Official Notice: No student should pay unauthorized departmental dues without official stamped receipts!", "likes": 405, "time": "1h ago"},
		{"handle": "@TechBro_100L", "name": "Code Boy", "text": "First Class is good, but make sure you learn Godot and GDScript before graduation! 🚀", "likes": 560, "time": "2h ago"},
		{"handle": "@MamaCashoutOfficial", "name": "Mama Put Joint", "text": "Fresh firewood jollof, soft dodo, and peppered chicken ready right now! 🍲", "likes": 190, "time": "3h ago"}
	]


func _render_gist_app() -> void:
	app_title.text = "🐦 NAIJA CAMPUS GIST (X)"

	# Compose Tweet Option Card
	var comp_card: PanelContainer = _create_card(Color(0.08, 0.16, 0.25, 0.95), Color(0.20, 0.55, 0.85, 0.9), 14)
	var comp_box: VBoxContainer = VBoxContainer.new()
	comp_card.add_child(comp_box)

	var c_head: Label = Label.new()
	c_head.text = "✍️ POST CAMPUS TWEET (+10 CLOUT):"
	c_head.add_theme_font_size_override("font_size", 12)
	c_head.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
	comp_box.add_child(c_head)

	var topics: Array[String] = [
		"Just finished morning lecture! May our CGPA not fall into temptation 🙏",
		"Mama Put jollof rice is the only reason I wake up for 8 AM classes 🍲",
		"Dean's Cup football final this evening! Who is coming to support? ⚽"
	]

	for t_text: String in topics:
		var tweet_btn: Button = _create_styled_button(t_text, Color(0.10, 0.35, 0.55, 0.9), 32)
		tweet_btn.pressed.connect(func():
			_post_campus_tweet(t_text)
		)
		comp_box.add_child(tweet_btn)

	dynamic_app_container.add_child(comp_card)

	# Tweets Feed
	var feed_title: Label = Label.new()
	feed_title.text = "🔥 TRENDING ON CAMPUS:"
	feed_title.add_theme_font_size_override("font_size", 12)
	feed_title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	dynamic_app_container.add_child(feed_title)

	for tw: Dictionary in campus_tweets_data:
		var tw_card: PanelContainer = _create_card(Color(0.07, 0.10, 0.16, 0.9), Color(0.20, 0.28, 0.40, 0.6), 12)
		var t_vbox: VBoxContainer = VBoxContainer.new()
		t_vbox.add_theme_constants_override("separation", 3)
		tw_card.add_child(t_vbox)

		var top_row: HBoxContainer = HBoxContainer.new()
		var author_lbl: Label = Label.new()
		author_lbl.text = "%s  %s" % [tw.get("name", "Student"), tw.get("handle", "@student")]
		author_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		author_lbl.add_theme_font_size_override("font_size", 12)
		author_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
		top_row.add_child(author_lbl)

		var t_time: Label = Label.new()
		t_time.text = tw.get("time", "Now")
		t_time.add_theme_font_size_override("font_size", 10)
		t_time.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
		top_row.add_child(t_time)
		t_vbox.add_child(top_row)

		var body_lbl: Label = Label.new()
		body_lbl.text = tw.get("text", "")
		body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body_lbl.add_theme_font_size_override("font_size", 12)
		t_vbox.add_child(body_lbl)

		var btm_row: HBoxContainer = HBoxContainer.new()
		var like_btn: Button = Button.new()
		like_btn.text = "❤️ %d" % int(tw.get("likes", 0))
		like_btn.custom_minimum_size = Vector2(70, 24)
		like_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		like_btn.add_theme_font_size_override("font_size", 11)
		like_btn.pressed.connect(func():
			tw["likes"] = int(tw.get("likes", 0)) + 1
			like_btn.text = "❤️ %d" % int(tw["likes"])
			if SoundManager: SoundManager.play_click()
		)
		btm_row.add_child(like_btn)
		t_vbox.add_child(btm_row)

		dynamic_app_container.add_child(tw_card)


func _post_campus_tweet(text: String) -> void:
	const StudentProfile = preload("res://scripts/data/student_profile.gd")
	var my_handle: String = "@%s" % StudentProfile.student_name.to_lower().replace(" ", "")
	var new_tw: Dictionary = {
		"handle": my_handle,
		"name": "%s (You)" % StudentProfile.student_name,
		"text": text,
		"likes": 12,
		"time": "Just now"
	}
	campus_tweets_data.push_front(new_tw)

	if SoundManager: SoundManager.play_bell()
	_pulse_dynamic_island("🐦 Tweet Live! +10 Clout")

	if current_player and current_player.has_method("show_chat_bubble"):
		current_player.show_chat_bubble("Posted on Campus Gist! 🐦")

	_open_app("gist")


# ==============================================================================
# APP 7: 🎒 BACKPACK & FOOD SUPPLIES INVENTORY
# ==============================================================================

func _render_backpack_app() -> void:
	app_title.text = "🎒 MY BACKPACK & SUPPLIES"

	const ProfileStore = preload("res://scripts/data/student_profile.gd")
	ProfileStore.load_from_disk()
	var items: Array[Dictionary] = ProfileStore.get_backpack_items()

	var head_lbl: Label = Label.new()
	head_lbl.text = "SUPPLIES IN BACKPACK (%d Items):" % items.size()
	head_lbl.add_theme_font_size_override("font_size", 12)
	head_lbl.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	dynamic_app_container.add_child(head_lbl)

	if items.is_empty():
		var empty_card: PanelContainer = _create_card(Color(0.10, 0.12, 0.16, 0.9), Color(0.25, 0.35, 0.45, 0.6), 12)
		var el: Label = Label.new()
		el.text = "Your backpack is currently empty.\nVisit Mama Put or Campus Kiosk to purchase food takeaway packs and provisions."
		el.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		el.add_theme_font_size_override("font_size", 12)
		empty_card.add_child(el)
		dynamic_app_container.add_child(empty_card)
		return

	for it: Dictionary in items:
		var i_card: PanelContainer = _create_card(Color(0.09, 0.12, 0.18, 0.9), Color(0.22, 0.32, 0.48, 0.6), 12)
		var i_vbox: VBoxContainer = VBoxContainer.new()
		i_vbox.add_theme_constants_override("separation", 3)
		i_card.add_child(i_vbox)

		var i_name: String = String(it.get("name", "Item"))
		var cnt: int = int(it.get("count", 1))
		var it_type: String = String(it.get("type", "misc"))
		var hunger_val: int = int(it.get("hunger", 0))
		var energy_val: int = int(it.get("energy", 0))

		var top_row: HBoxContainer = HBoxContainer.new()
		var title_l: Label = Label.new()
		title_l.text = "🍱 %s (x%d)" % [i_name, cnt] if it_type == "food" else "📦 %s (x%d)" % [i_name, cnt]
		title_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_l.add_theme_font_size_override("font_size", 12)
		title_l.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0))
		top_row.add_child(title_l)

		if it_type == "food":
			var stats_l: Label = Label.new()
			stats_l.text = "+%d Hunger, +%d Energy" % [hunger_val, energy_val]
			stats_l.add_theme_font_size_override("font_size", 11)
			stats_l.add_theme_color_override("font_color", Color(0.35, 0.95, 0.6))
			top_row.add_child(stats_l)
		i_vbox.add_child(top_row)

		var desc_l: Label = Label.new()
		desc_l.text = String(it.get("desc", ""))
		desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_l.add_theme_font_size_override("font_size", 11)
		desc_l.add_theme_color_override("font_color", Color(0.75, 0.85, 0.90))
		i_vbox.add_child(desc_l)

		if it_type == "food":
			var eat_btn: Button = _create_styled_button("Eat Takeaway Now 🍱 (+%d Hunger, +%d Energy)" % [hunger_val, energy_val], Color(0.18, 0.45, 0.30, 0.95), 32)
			var it_id: String = String(it.get("id", ""))
			eat_btn.pressed.connect(func():
				_consume_food_item(it_id)
			)
			i_vbox.add_child(eat_btn)

		dynamic_app_container.add_child(i_card)


func _consume_food_item(item_id: String) -> void:
	if not current_player:
		return
	const ProfileStore = preload("res://scripts/data/student_profile.gd")
	var res: Dictionary = ProfileStore.consume_backpack_food(current_player, item_id)
	if res.get("success", false):
		if SoundManager: SoundManager.play_coin()
		_pulse_dynamic_island("🍱 Meal Consumed", Color(0.3, 0.95, 0.55))
		TimeSystem.advance_minutes(5)
		_update_phone_status_bar()
		if current_player.has_method("display_notification"):
			current_player.display_notification("Ate %s! Restored hunger and energy." % String(res.get("name", "food")))
		_open_app("backpack")


# ==============================================================================
# APP 8: 🪪 STUDENT DIGITAL ID CARD
# ==============================================================================

func _render_id_card_app() -> void:
	app_title.text = "🪪 STUDENT DIGITAL ID PASS"

	StudentProfile.load_from_disk()

	var id_card: PanelContainer = _create_card(Color(0.06, 0.12, 0.22, 0.98), Color(0.85, 0.65, 0.20, 0.9), 16)
	var v_box: VBoxContainer = VBoxContainer.new()
	v_box.add_theme_constants_override("separation", 6)
	id_card.add_child(v_box)

	var univ_head: Label = Label.new()
	univ_head.text = "FEDERAL CAMPUS UNIVERSITY\nOFFICIAL STUDENT PASS"
	univ_head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	univ_head.add_theme_font_size_override("font_size", 13)
	univ_head.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	v_box.add_child(univ_head)

	var h_sep: HSeparator = HSeparator.new()
	v_box.add_child(h_sep)

	var fields: Array[Dictionary] = [
		{"label": "NAME", "val": StudentProfile.student_name.to_upper()},
		{"label": "HANDLE", "val": "@" + StudentProfile.username if not StudentProfile.username.is_empty() else "@fresher_01"},
		{"label": "MATRIC NO", "val": StudentProfile.matric_no},
		{"label": "DEPARTMENT", "val": StudentProfile.admitted_department},
		{"label": "PROGRAM", "val": StudentProfile.admitted_course_title},
		{"label": "FACULTY", "val": StudentProfile.admitted_faculty},
		{"label": "LEVEL", "val": "100 Level (Fresher)"},
		{"label": "SESSION", "val": "2025/2026 Academic Session"},
		{"label": "SPONSOR", "val": "%s %s" % [StudentProfile.spawn_badge, StudentProfile.spawn_title]},
		{"label": "STATUS", "val": "🟢 VALID ENROLLED UNDERGRADUATE"}
	]

	for f: Dictionary in fields:
		var row: HBoxContainer = HBoxContainer.new()
		var l_name: Label = Label.new()
		l_name.text = f["label"]
		l_name.custom_minimum_size = Vector2(100, 0)
		l_name.add_theme_font_size_override("font_size", 11)
		l_name.add_theme_color_override("font_color", Color(0.65, 0.80, 0.95))
		row.add_child(l_name)

		var l_val: Label = Label.new()
		l_val.text = f["val"]
		l_val.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		l_val.add_theme_font_size_override("font_size", 11)
		l_val.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0) if f["label"] != "STATUS" else Color(0.3, 0.95, 0.55))
		row.add_child(l_val)
		v_box.add_child(row)

	var barcode: Label = Label.new()
	barcode.text = "||||| ||| ||||||| |||| |||||| ||| ||||"
	barcode.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	barcode.add_theme_font_size_override("font_size", 16)
	barcode.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 0.7))
	v_box.add_child(barcode)

	dynamic_app_container.add_child(id_card)


# ==============================================================================
# APP 9: ⚙️ SETTINGS & WALLPAPERS
# ==============================================================================

func _render_settings_app() -> void:
	app_title.text = "⚙️ PHONE & GAME SETTINGS"

	var wp_head: Label = Label.new()
	wp_head.text = "🎨 SELECT AMOLED WALLPAPER:"
	wp_head.add_theme_font_size_override("font_size", 12)
	wp_head.add_theme_color_override("font_color", Color(0.9, 0.85, 0.4))
	dynamic_app_container.add_child(wp_head)

	for i in range(WALLPAPERS.size()):
		var wp: Dictionary = WALLPAPERS[i]
		var is_active: bool = (i == current_wallpaper_idx)

		var wp_card: PanelContainer = _create_card(wp["bg"], wp["border"], 12)
		var w_h: HBoxContainer = HBoxContainer.new()
		wp_card.add_child(w_h)

		var name_l: Label = Label.new()
		name_l.text = "%s %s" % ["✓ Active •" if is_active else "•", wp["name"]]
		name_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_l.add_theme_font_size_override("font_size", 12)
		name_l.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4) if is_active else Color(0.85, 0.90, 0.95))
		w_h.add_child(name_l)

		var apply_btn: Button = Button.new()
		apply_btn.text = "Applied" if is_active else "Apply"
		apply_btn.disabled = is_active
		apply_btn.custom_minimum_size = Vector2(70, 28)
		apply_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		apply_btn.add_theme_font_size_override("font_size", 11)
		apply_btn.pressed.connect(func():
			apply_wallpaper(i)
			if SoundManager: SoundManager.play_click()
			_open_app("settings")
		)
		w_h.add_child(apply_btn)

		dynamic_app_container.add_child(wp_card)

	# Sound & System Diagnostics
	var info_card: PanelContainer = _create_card(Color(0.08, 0.11, 0.16, 0.9), Color(0.20, 0.30, 0.45, 0.6), 12)
	var i_vbox: VBoxContainer = VBoxContainer.new()
	info_card.add_child(i_vbox)

	var info_text: Label = Label.new()
	var motd_txt: String = str(SupabaseClient.live_config.get("motd", "Welcome to My Campus Life!")) if SupabaseClient else "Welcome to My Campus Life!"
	var cloud_mode: String = "🟢 Live Supabase Cloud" if (SupabaseClient and SupabaseClient.is_configured()) else "🟡 Local Browser Cloud (Link in Top-Right)"
	info_text.text = """☁️ CLOUD DB: %s
📢 LIVE MOTD: %s
🔊 CAMPUS AUDIO: Procedural In-Memory Synthesizer
📱 RESOLUTION: Adaptive Mobile & Desktop Layout
🔄 LIVE CONFIG: Editable via live_game_config.json / Supabase""" % [cloud_mode, motd_txt]
	info_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_text.add_theme_font_size_override("font_size", 11)
	info_text.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	i_vbox.add_child(info_text)

	dynamic_app_container.add_child(info_card)


func _on_app_action_pressed() -> void:
	# Fallback legacy handler if action button is visible
	if SoundManager: SoundManager.play_click()


func _get_class_text(cgpa: float) -> String:
	if cgpa >= 4.50: return "First Class Honours"
	if cgpa >= 3.50: return "Second Class Upper (2:1)"
	if cgpa >= 2.40: return "Second Class Lower (2:2)"
	return "Third Class Standing"


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s
