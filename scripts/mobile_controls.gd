class_name MobileControls
extends CanvasLayer


## Mobile On-Screen Controls: Virtual Joystick + Action Button + Transit Map.
## Designed specifically for phone screens and mobile web browsers.

signal transit_requested(destination_name: StringName)
signal phone_requested
signal chat_requested
signal backpack_requested

@onready var joystick: TouchJoystick = %VirtualJoystick
@onready var interact_btn: Button = %InteractButton
@onready var map_btn: Button = %MapButton
@onready var phone_btn: Button = %PhoneButton
@onready var chat_btn: Button = %ChatButton if has_node("%ChatButton") else null
@onready var transit_sheet: PanelContainer = %TransitSheet
@onready var zoom_btn: Button = %ZoomButton if has_node("%ZoomButton") else null

var emote_btn: Button = null
var emote_sheet: PanelContainer = null
var desktop_hint_bar: PanelContainer = null
var bound_player: Player3D = null
var _js_cb_hud_action: Variant = null


func _ready() -> void:
	if joystick:
		joystick.joystick_moved.connect(_on_joystick_moved)
	if interact_btn:
		interact_btn.pressed.connect(_on_interact_pressed)
	if map_btn:
		map_btn.pressed.connect(_toggle_transit_sheet)
	if phone_btn:
		phone_btn.pressed.connect(_on_phone_pressed)
	if chat_btn:
		chat_btn.pressed.connect(_on_chat_pressed)
	if zoom_btn:
		zoom_btn.text = "▲ Top View"
		zoom_btn.pressed.connect(_on_zoom_pressed)
	if transit_sheet:
		transit_sheet.visible = false
	_create_emote_ui()
	_create_desktop_ui_bar()
	if OS.has_feature("web"):
		var buttons_row: HBoxContainer = get_node_or_null("TouchZone/ButtonsRow") as HBoxContainer
		if buttons_row:
			buttons_row.visible = false
		var win = JavaScriptBridge.get_interface("window")
		if win:
			_js_cb_hud_action = JavaScriptBridge.create_callback(_on_js_hud_action)
			win.godotOnHtmlHudAction = _js_cb_hud_action
	get_viewport().size_changed.connect(_adapt_desktop_vs_mobile_ui)
	_adapt_desktop_vs_mobile_ui()

	# Wire transit quick-travel buttons
	_wire_transit_btn(%HostelBtn, &"hostel")
	if has_node("%MamaPutBtn"):
		_wire_transit_btn(%MamaPutBtn, &"mama_put")
	elif has_node("%BukaBtn"):
		_wire_transit_btn(%BukaBtn, &"mama_put")
	_wire_transit_btn(%BistroBtn, &"bistro")
	_wire_transit_btn(%StadiumBtn, &"stadium")
	_wire_transit_btn(%ClassBtn, &"class")
	_wire_transit_btn(%Class2Btn, &"class2")
	_wire_transit_btn(%LibraryBtn, &"library")
	_wire_transit_btn(%ChapelBtn, &"chapel")
	_wire_transit_btn(%SUBBtn, &"sub")
	_wire_transit_btn(%GardenBtn, &"garden")
	_wire_transit_btn(%SalonBtn, &"salon")
	if has_node("%GateBtn"):
		_wire_transit_btn(%GateBtn, &"gate")
	if has_node("%SenateBtn"):
		_wire_transit_btn(%SenateBtn, &"senate")
	if has_node("%TechHubBtn"):
		_wire_transit_btn(%TechHubBtn, &"tech_hub")
	_wire_transit_btn(%ATMBtn, &"atm")
	_wire_transit_btn(%CloseMapBtn, &"close")


func _wire_transit_btn(btn: Button, dest: StringName) -> void:
	if btn:
		btn.pressed.connect(_on_transit_dest_pressed.bind(dest))


func bind_player(p: Player3D) -> void:
	bound_player = p


func _process(_delta: float) -> void:
	# Contextual My Campus Life action button: only show when near an interactable object!
	if not interact_btn or not bound_player:
		return

	if bound_player.current_interactable != null:
		interact_btn.visible = true
		interact_btn.modulate = Color(1.0, 0.95, 0.75, 1.0)
		var obj_title: String = bound_player.current_interactable.object_name
		if obj_title.length() > 14:
			obj_title = obj_title.substr(0, 14) + "…"
		interact_btn.text = "USE [E]\n%s" % obj_title
	else:
		interact_btn.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_P:
				_on_phone_pressed()
				get_viewport().set_input_as_handled()
			KEY_C:
				_on_chat_pressed()
				get_viewport().set_input_as_handled()
			KEY_M:
				_toggle_transit_sheet()
				get_viewport().set_input_as_handled()
			KEY_E:
				_on_interact_pressed()
				get_viewport().set_input_as_handled()
			KEY_Z, KEY_V:
				_on_zoom_pressed()
				get_viewport().set_input_as_handled()
			KEY_B:
				_on_backpack_pressed()
				get_viewport().set_input_as_handled()
			KEY_X, KEY_G:
				_toggle_emote_sheet()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				if emote_sheet and emote_sheet.visible:
					emote_sheet.visible = false
					get_viewport().set_input_as_handled()
				elif transit_sheet and transit_sheet.visible:
					transit_sheet.visible = false
					get_viewport().set_input_as_handled()


func _on_joystick_moved(vec: Vector2) -> void:
	if joystick and vec != Vector2.ZERO:
		joystick.modulate.a = 1.0
	if bound_player:
		bound_player.set_mobile_movement(vec)


func _on_interact_pressed() -> void:
	if SoundManager:
		SoundManager.play_click()
	if bound_player:
		bound_player.trigger_interaction()


func _toggle_transit_sheet() -> void:
	if SoundManager:
		SoundManager.play_click()
	if OS.has_feature("web"):
		var win = JavaScriptBridge.get_interface("window")
		if win and win.openNativeCampusMap:
			win.openNativeCampusMap()
		return
	if transit_sheet:
		transit_sheet.visible = not transit_sheet.visible
		if transit_sheet.visible and emote_sheet:
			emote_sheet.visible = false


func _on_phone_pressed() -> void:
	if SoundManager:
		SoundManager.play_click()
	phone_requested.emit()


func _on_chat_pressed() -> void:
	if SoundManager:
		SoundManager.play_click()
	chat_requested.emit()


func _on_backpack_pressed() -> void:
	if SoundManager:
		SoundManager.play_click()
	backpack_requested.emit()


func _on_zoom_pressed() -> void:
	if SoundManager:
		SoundManager.play_click()
	if bound_player and bound_player.has_method("cycle_camera_zoom"):
		var label: String = bound_player.cycle_camera_zoom()
		if zoom_btn:
			zoom_btn.text = "▲ %s" % label
		if OS.has_feature("web"):
			var win = JavaScriptBridge.get_interface("window")
			if win:
				win.updateCampusHtmlHud(JSON.stringify({"view_label": "🎥 %s" % label}))


func _on_js_hud_action(args: Array) -> void:
	if args.is_empty():
		return
	var act: String = str(args[0])
	if act.begins_with("travel:"):
		var dest_str: String = act.substr(7)
		if dest_str != "":
			_on_transit_dest_pressed(StringName(dest_str))
		return
	if act.begins_with("emote:"):
		var emote_id: String = act.substr(6)
		if emote_id != "":
			_on_emote_selected(emote_id)
		return
	if act.begins_with("quality:"):
		var tier: String = act.substr(8)
		match tier:
			"low":
				get_viewport().scaling_3d_scale = 0.75
				get_viewport().positional_shadow_atlas_size = 512
			"balanced":
				get_viewport().scaling_3d_scale = 1.0
				get_viewport().positional_shadow_atlas_size = 1024
			"high":
				get_viewport().scaling_3d_scale = 1.0
				get_viewport().positional_shadow_atlas_size = 2048
		return
	if act.begins_with("vol_"):
		var parts: PackedStringArray = act.substr(4).split(":")
		if parts.size() == 2:
			var bus: String = parts[0]
			var val: float = float(parts[1])
			if SoundManager:
				match bus:
					"master":
						SoundManager.set_master_volume(val)
					"music":
						SoundManager.set_music_volume(val)
					"sfx":
						SoundManager.set_sfx_volume(val)
		return
	if act.begins_with("camera:"):
		var cam_idx: int = int(act.substr(7))
		if bound_player and bound_player.has_method("set_camera_zoom_preset"):
			var mode_name: String = bound_player.set_camera_zoom_preset(cam_idx, false)
			if zoom_btn:
				zoom_btn.text = "▲ %s" % mode_name
			if OS.has_feature("web"):
				var win = JavaScriptBridge.get_interface("window")
				if win:
					win.updateCampusHtmlHud(JSON.stringify({"view_label": "🎥 %s" % mode_name}))
		return
	match act:
		"emote":
			_toggle_emote_sheet()
		"chat":
			_on_chat_pressed()
		"phone":
			_on_phone_pressed()
		"map":
			_toggle_transit_sheet()
		"view":
			_on_zoom_pressed()
		"settings":
			if OS.has_feature("web"):
				var win = JavaScriptBridge.get_interface("window")
				if win and win.openNativeCampusSettings:
					win.openNativeCampusSettings()
			else:
				_on_phone_pressed()
		"feedback":
			if OS.has_feature("web"):
				var win = JavaScriptBridge.get_interface("window")
				if win and win.openNativeCampusFeedback:
					win.openNativeCampusFeedback()
		"tasks":
			var hud_node: HUD = get_parent().get_node_or_null("HUD") as HUD if get_parent() else null
			if hud_node:
				hud_node.trigger_tasks_sheet()
		"objective":
			var hud_node2: HUD = get_parent().get_node_or_null("HUD") as HUD if get_parent() else null
			if hud_node2:
				hud_node2.trigger_objective_click()


func _create_desktop_ui_bar() -> void:
	var touch_zone: Control = get_node_or_null("TouchZone") as Control
	if not touch_zone:
		return
	desktop_hint_bar = PanelContainer.new()
	desktop_hint_bar.name = "DesktopHintBar"
	desktop_hint_bar.anchors_preset = Control.PRESET_CENTER_BOTTOM
	desktop_hint_bar.anchor_left = 0.5
	desktop_hint_bar.anchor_right = 0.5
	desktop_hint_bar.anchor_top = 1.0
	desktop_hint_bar.anchor_bottom = 1.0
	desktop_hint_bar.offset_left = -350.0
	desktop_hint_bar.offset_right = 350.0
	desktop_hint_bar.offset_top = -34.0
	desktop_hint_bar.offset_bottom = -6.0
	desktop_hint_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bar_style := StyleBoxFlat.new()
	bar_style.bg_color = Color(0.05, 0.09, 0.14, 0.82)
	bar_style.border_width_top = 1
	bar_style.border_width_bottom = 1
	bar_style.border_width_left = 1
	bar_style.border_width_right = 1
	bar_style.border_color = Color(1.0, 0.82, 0.24, 0.45)
	bar_style.corner_radius_top_left = 12
	bar_style.corner_radius_top_right = 12
	bar_style.corner_radius_bottom_left = 12
	bar_style.corner_radius_bottom_right = 12
	bar_style.content_margin_left = 14.0
	bar_style.content_margin_right = 14.0
	bar_style.content_margin_top = 4.0
	bar_style.content_margin_bottom = 4.0
	desktop_hint_bar.add_theme_stylebox_override(&"panel", bar_style)

	var hint_lbl := Label.new()
	hint_lbl.text = "[WASD / Click] Move  •  [E] Interact  •  [V / Scroll] 3D Perspective  •  [P] Phone  •  [C] Chat  •  [M] Map  •  [G] Emote"
	hint_lbl.add_theme_font_size_override(&"font_size", 11)
	hint_lbl.add_theme_color_override(&"font_color", Color(0.88, 0.94, 1.0, 0.92))
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desktop_hint_bar.add_child(hint_lbl)
	touch_zone.add_child(desktop_hint_bar)


func _adapt_desktop_vs_mobile_ui() -> void:
	if not is_inside_tree():
		return
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	var is_desktop_landscape: bool = vp_size.x >= 900.0 and vp_size.x > vp_size.y * 1.15
	if desktop_hint_bar:
		desktop_hint_bar.visible = is_desktop_landscape and not OS.has_feature("web")
	if joystick:
		joystick.modulate.a = 0.35 if is_desktop_landscape else 0.92
	var buttons_row: HBoxContainer = get_node_or_null("TouchZone/ButtonsRow") as HBoxContainer
	if buttons_row:
		if OS.has_feature("web"):
			buttons_row.visible = false
		elif vp_size.x < 700.0:
			buttons_row.offset_top = 132.0
			buttons_row.offset_bottom = 168.0
		else:
			buttons_row.offset_top = 92.0
			buttons_row.offset_bottom = 128.0


func _on_transit_dest_pressed(dest: StringName) -> void:
	if SoundManager:
		SoundManager.play_click()
	if transit_sheet:
		transit_sheet.visible = false
	if dest != &"close":
		transit_requested.emit(dest)


func _create_emote_ui() -> void:
	var buttons_row: HBoxContainer = get_node_or_null("TouchZone/ButtonsRow") as HBoxContainer
	if buttons_row:
		emote_btn = Button.new()
		emote_btn.name = "EmoteButton"
		emote_btn.text = "★ Emote"
		emote_btn.custom_minimum_size = Vector2(66, 36)
		emote_btn.focus_mode = Control.FOCUS_NONE
		emote_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		emote_btn.add_theme_font_size_override(&"font_size", 12)

		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = Color(0.1, 0.14, 0.2, 0.85)
		btn_style.border_width_left = 2
		btn_style.border_width_top = 2
		btn_style.border_width_right = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = Color(0.85, 0.65, 0.2, 0.9)
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn_style.corner_radius_bottom_right = 8
		btn_style.content_margin_left = 8.0
		btn_style.content_margin_right = 8.0
		emote_btn.add_theme_stylebox_override(&"normal", btn_style)
		emote_btn.add_theme_stylebox_override(&"hover", btn_style)
		emote_btn.add_theme_stylebox_override(&"pressed", btn_style)

		emote_btn.pressed.connect(_toggle_emote_sheet)
		buttons_row.add_child(emote_btn)
		buttons_row.move_child(emote_btn, 0)
		buttons_row.offset_left = -368.0

	var touch_zone: Control = get_node_or_null("TouchZone") as Control
	if not touch_zone:
		return

	emote_sheet = PanelContainer.new()
	emote_sheet.name = "EmoteSheet"
	emote_sheet.custom_minimum_size = Vector2(350, 360)
	emote_sheet.anchors_preset = Control.PRESET_CENTER
	emote_sheet.anchor_left = 0.5
	emote_sheet.anchor_top = 0.5
	emote_sheet.anchor_right = 0.5
	emote_sheet.anchor_bottom = 0.5
	emote_sheet.offset_left = -175.0
	emote_sheet.offset_top = -180.0
	emote_sheet.offset_right = 175.0
	emote_sheet.offset_bottom = 180.0
	emote_sheet.visible = false

	var sheet_style := StyleBoxFlat.new()
	sheet_style.bg_color = Color(0.07, 0.10, 0.15, 0.96)
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
	sheet_style.content_margin_bottom = 16.0
	emote_sheet.add_theme_stylebox_override(&"panel", sheet_style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 8)
	emote_sheet.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "★ CAMPUS EMOTES & VIBES"
	title_lbl.add_theme_font_size_override(&"font_size", 16)
	title_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.25))
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "Tap to express yourself to coursemates & online peers"
	sub_lbl.add_theme_font_size_override(&"font_size", 11)
	sub_lbl.add_theme_color_override(&"font_color", Color(0.75, 0.82, 0.9))
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub_lbl)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override(&"h_separation", 8)
	grid.add_theme_constant_override(&"v_separation", 8)
	vbox.add_child(grid)

	var emote_options: Array[Dictionary] = [
		{"id": "shaku", "label": "★ Legwork / Shaku", "color": Color(0.95, 0.65, 0.15)},
		{"id": "zanku", "label": "★ Zanku / Gbese!", "color": Color(1.0, 0.35, 0.25)},
		{"id": "wave", "label": "● Wave Coursemate", "color": Color(0.3, 0.75, 1.0)},
		{"id": "selfie", "label": "◆ Drip Check / Pose", "color": Color(0.95, 0.45, 0.85)},
		{"id": "sit", "label": "■ Sit & Rest (+Energy)", "color": Color(0.4, 0.85, 0.5)},
		{"id": "study", "label": "■ Focused Study", "color": Color(0.65, 0.55, 1.0)},
		{"id": "celebrate", "label": "★ Victory Cheer", "color": Color(1.0, 0.45, 0.65)},
		{"id": "eat", "label": "● Quick Snack", "color": Color(0.9, 0.75, 0.3)},
		{"id": "pray", "label": "✦ Faith & Prayer", "color": Color(0.85, 0.9, 1.0)}
	]

	for opt in emote_options:
		var opt_btn := Button.new()
		opt_btn.text = opt["label"]
		opt_btn.custom_minimum_size = Vector2(150, 42)
		opt_btn.add_theme_font_size_override(&"font_size", 12)
		opt_btn.focus_mode = Control.FOCUS_NONE
		opt_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var opt_style := StyleBoxFlat.new()
		opt_style.bg_color = Color(0.12, 0.16, 0.24, 0.85)
		opt_style.border_width_left = 2
		opt_style.border_width_top = 1
		opt_style.border_width_right = 1
		opt_style.border_width_bottom = 1
		opt_style.border_color = opt["color"]
		opt_style.corner_radius_top_left = 8
		opt_style.corner_radius_top_right = 8
		opt_style.corner_radius_bottom_left = 8
		opt_style.corner_radius_bottom_right = 8
		opt_btn.add_theme_stylebox_override(&"normal", opt_style)
		opt_btn.add_theme_stylebox_override(&"hover", opt_style)
		opt_btn.add_theme_stylebox_override(&"pressed", opt_style)

		var emote_id: String = String(opt["id"])
		opt_btn.pressed.connect(func():
			_on_emote_selected(emote_id)
		)
		grid.add_child(opt_btn)

	var close_btn := Button.new()
	close_btn.text = "✖ Close"
	close_btn.custom_minimum_size = Vector2(0, 36)
	close_btn.add_theme_font_size_override(&"font_size", 12)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(func():
		if SoundManager:
			SoundManager.play_click()
		emote_sheet.visible = false
	)
	vbox.add_child(close_btn)

	touch_zone.add_child(emote_sheet)


func _toggle_emote_sheet() -> void:
	if SoundManager:
		SoundManager.play_click()
	if OS.has_feature("web"):
		var win = JavaScriptBridge.get_interface("window")
		if win and win.openNativeCampusEmote:
			win.openNativeCampusEmote()
		return
	if emote_sheet:
		emote_sheet.visible = not emote_sheet.visible
		if emote_sheet.visible and transit_sheet:
			transit_sheet.visible = false


func _on_emote_selected(emote_id: String) -> void:
	if SoundManager:
		SoundManager.play_click()
	if emote_sheet:
		emote_sheet.visible = false
	if bound_player and bound_player.has_method("play_emote"):
		bound_player.play_emote(emote_id)
