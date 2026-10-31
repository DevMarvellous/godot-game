class_name ChapelPraiseGame
extends Control

## Campus Fellowship Praise & Worship Concert Mini-Game.
## Interactive Christian rhythm mini-game featuring authentic Nigerian fellowship praises:
## - 4 harmonic chord tracks (Keys: A, S, D, F / on-screen interactive buttons)
## - Dynamic moving praise notes and lyric prompts
## - Real-time praise streak multipliers and choir harmony effects
## - Spiritual rewards: +Faith, +Energy, +Love Offering stipend, and "Fellowship Choir Lead" title!
## 100% wholesome, clean, and faith-building.

signal concert_finished(faith_earned: float, money_earned: int)
signal concert_closed

const HymnData = preload("res://scripts/data/hymn_praise_data.gd")

var current_player: CharacterBody3D = null
var current_song_idx: int = 0
var current_song: Dictionary = {}
var is_playing: bool = false
var song_time: float = 0.0
var score: int = 0
var streak: int = 0
var max_streak: int = 0

# Active falling notes: Array of Dictionary {lane: int, target_time: float, lyric: String, node: Control, hit: bool}
var active_notes: Array[Dictionary] = []

# UI references
var header_label: Label = null
var scripture_label: Label = null
var streak_label: Label = null
var score_label: Label = null
var lyric_display_label: Label = null
var tracks_container: HBoxContainer = null
var track_lanes: Array[Control] = []
var key_buttons: Array[Button] = []
var hit_zone_line: ColorRect = null
var results_panel: PanelContainer = null
var results_title_label: Label = null
var results_stats_label: Label = null
var results_verse_label: Label = null
var next_song_btn: Button = null

const TRACK_COLORS: Array[Color] = [
	Color(0.20, 0.75, 1.0),   # Track 0: Sky Blue
	Color(0.35, 0.90, 0.50),  # Track 1: Emerald Green
	Color(1.0, 0.82, 0.24),   # Track 2: Golden Joy
	Color(0.95, 0.45, 0.85)   # Track 3: Royal Praise Purple
]

const TRACK_NAMES: Array[String] = [
	"🎵 C (Do)",
	"🎶 E (Mi)",
	"🎹 G (Sol)",
	"🎼 B (Ti)"
]

const KEY_LABELS: Array[String] = ["A", "S", "D", "F"]


func _ready() -> void:
	visible = false
	_build_ui()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if not is_visible_in_tree():
			is_playing = false


func _input(event: InputEvent) -> void:
	if not visible or not is_playing:
		return

	if event is InputEventKey and event.pressed and not event.is_echo():
		match event.keycode:
			KEY_A, KEY_LEFT:
				_on_lane_hit(0)
				get_viewport().set_input_as_handled()
			KEY_S, KEY_DOWN:
				_on_lane_hit(1)
				get_viewport().set_input_as_handled()
			KEY_D, KEY_UP:
				_on_lane_hit(2)
				get_viewport().set_input_as_handled()
			KEY_F, KEY_RIGHT:
				_on_lane_hit(3)
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				close_concert()
				get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if not visible or not is_playing:
		return

	song_time += delta
	_update_falling_notes(delta)

	var duration: float = float(current_song.get("duration", 14.0))
	if song_time >= duration:
		_finish_song()


func open_concert(player: CharacterBody3D, song_idx: int = 0) -> void:
	current_player = player
	current_song_idx = song_idx
	visible = true
	if results_panel:
		results_panel.visible = false
	_start_song(song_idx)


func close_concert() -> void:
	is_playing = false
	visible = false
	_clear_all_notes()
	concert_closed.emit()


func _start_song(song_idx: int) -> void:
	current_song_idx = clampi(song_idx, 0, HymnData.get_song_count() - 1)
	current_song = HymnData.get_song_by_index(current_song_idx)
	song_time = 0.0
	score = 0
	streak = 0
	max_streak = 0
	is_playing = true

	_clear_all_notes()

	if header_label:
		header_label.text = "🕊️ PRAISE CONCERT: %s" % current_song.get("title", "Fellowship Praise")
	if scripture_label:
		scripture_label.text = "📖 %s • Led by: %s" % [current_song.get("scripture", ""), current_song.get("lead_singer", "Choir")]
	if lyric_display_label:
		lyric_display_label.text = "\"%s\"" % current_song.get("lyrics", "")
	if streak_label:
		streak_label.text = "🔥 Praise Streak: 0"
	if score_label:
		score_label.text = "⭐ Harmony: 0 pts"
	if results_panel:
		results_panel.visible = false

	# Spawn all notes for the song
	var raw_notes: Array = current_song.get("notes", [])
	for n_dict in raw_notes:
		var lane_idx: int = int(n_dict.get("lane", 0))
		var target_t: float = float(n_dict.get("time", 0.0))
		var lyr: String = String(n_dict.get("lyric", ""))

		if lane_idx >= 0 and lane_idx < track_lanes.size():
			var note_badge := PanelContainer.new()
			var n_style := StyleBoxFlat.new()
			n_style.bg_color = TRACK_COLORS[lane_idx]
			n_style.corner_radius_top_left = 8
			n_style.corner_radius_top_right = 8
			n_style.corner_radius_bottom_right = 8
			n_style.corner_radius_bottom_left = 8
			note_badge.add_theme_stylebox_override(&"panel", n_style)
			note_badge.custom_minimum_size = Vector2(70, 32)

			var n_lbl := Label.new()
			n_lbl.text = lyr if lyr != "" else "♪"
			n_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			n_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			n_lbl.add_theme_font_size_override(&"font_size", 12)
			n_lbl.add_theme_color_override(&"font_color", Color(0.06, 0.08, 0.12))
			note_badge.add_child(n_lbl)

			track_lanes[lane_idx].add_child(note_badge)
			note_badge.position = Vector2(5, -50)

			active_notes.append({
				"lane": lane_idx,
				"target_time": target_t,
				"lyric": lyr,
				"node": note_badge,
				"hit": false
			})

	if SoundManager:
		SoundManager.play_bell()


func _update_falling_notes(_delta: float) -> void:
	const TRACK_HEIGHT: float = 240.0
	const HIT_Y: float = 195.0
	const NOTE_SPEED_PIXELS_PER_SEC: float = 120.0

	for item in active_notes:
		if item["hit"]:
			continue
		var target_t: float = float(item["target_time"])
		var time_diff: float = target_t - song_time
		var node: Control = item["node"] as Control
		if is_instance_valid(node):
			var current_y: float = HIT_Y - (time_diff * NOTE_SPEED_PIXELS_PER_SEC)
			node.position.y = current_y

			# Fade out if missed past the hit line
			if current_y > TRACK_HEIGHT + 20.0:
				item["hit"] = true
				node.visible = false
				streak = 0
				if streak_label:
					streak_label.text = "🔥 Praise Streak: 0"


func _on_lane_hit(lane_idx: int) -> void:
	if not is_playing:
		return

	# Flash key button
	if lane_idx >= 0 and lane_idx < key_buttons.size():
		var btn: Button = key_buttons[lane_idx]
		_flash_button(btn)

	# Check closest unhit note in this lane
	var best_note: Dictionary = {}
	var min_diff: float = 999.0

	for item in active_notes:
		if item["hit"] or int(item["lane"]) != lane_idx:
			continue
		var diff: float = absf(float(item["target_time"]) - song_time)
		if diff < min_diff:
			min_diff = diff
			best_note = item

	const HIT_THRESHOLD: float = 0.55

	if best_note.size() > 0 and min_diff <= HIT_THRESHOLD:
		best_note["hit"] = true
		var node: Control = best_note["node"] as Control
		if is_instance_valid(node):
			node.visible = false

		streak += 1
		if streak > max_streak:
			max_streak = streak

		var multiplier: int = clampi(1 + (streak / 3), 1, 4)
		var pts: int = 100 * multiplier
		score += pts

		if score_label:
			score_label.text = "⭐ Harmony: %d pts (+%d)" % [score, pts]
		if streak_label:
			streak_label.text = "🔥 Praise Streak: %d (x%d Anointing!)" % [streak, multiplier]

		if SoundManager:
			SoundManager.play_coin()

		# Trigger joyous praise bounce on player character
		if current_player and current_player.has_method("play_praise_jump_animation"):
			if streak % 3 == 0:
				current_player.play_praise_jump_animation()

	else:
		# Tap without note - still play pleasant harmonic chord
		if SoundManager:
			SoundManager.play_click()


func _flash_button(btn: Button) -> void:
	var tw := create_tween()
	tw.tween_property(btn, "modulate", Color(1.8, 1.8, 1.8), 0.08)
	tw.tween_property(btn, "modulate", Color.WHITE, 0.12)


func _finish_song() -> void:
	is_playing = false
	var faith_gain: float = float(current_song.get("reward_faith", 40.0))
	var energy_gain: float = float(current_song.get("reward_energy", 25.0))
	var money_gain: int = int(current_song.get("reward_money", 2000))

	# Bonus for high praise streak
	if max_streak >= 5:
		faith_gain += 15.0
		money_gain += 1000

	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_faith(faith_gain)
			needs.modify_energy(energy_gain)
			needs.modify_money(money_gain)

	if SoundManager:
		SoundManager.play_cheer()

	if results_panel:
		results_panel.visible = true
		if results_title_label:
			results_title_label.text = "🕊️ PRAISE MINISTRATION COMPLETE! 🕊️"
		if results_stats_label:
			results_stats_label.text = (
				"⭐ Harmony Score: %d pts\n" +
				"🔥 Max Praise Streak: %d\n" +
				"✨ Faith Restored: +%.0f Faith (Peace of Mind 100%%!)\n" +
				"⚡ Energy Recharged: +%.0f%%\n" +
				"🎁 Fellowship Love Offering: +₦%s Cash!"
			) % [score, max_streak, faith_gain, energy_gain, String.num(money_gain)]
		if results_verse_label:
			results_verse_label.text = "Sister Blessing: 'Amen! The whole fellowship was blessed by your worship! Keep lifting Jesus high!'"

	concert_finished.emit(faith_gain, money_gain)


func _clear_all_notes() -> void:
	for item in active_notes:
		var node: Control = item.get("node") as Control
		if is_instance_valid(node):
			node.queue_free()
	active_notes.clear()


func _build_ui() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Backdrop
	var bg := ColorRect.new()
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.color = Color(0.04, 0.08, 0.14, 0.90)
	add_child(bg)

	var center := CenterContainer.new()
	center.anchors_preset = Control.PRESET_FULL_RECT
	add_child(center)

	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(560, 520)
	var f_style := StyleBoxFlat.new()
	f_style.bg_color = Color(0.08, 0.13, 0.22, 0.98)
	f_style.border_width_left = 3
	f_style.border_width_top = 3
	f_style.border_width_right = 3
	f_style.border_width_bottom = 3
	f_style.border_color = Color(0.35, 0.85, 1.0, 0.95)
	f_style.corner_radius_top_left = 16
	f_style.corner_radius_top_right = 16
	f_style.corner_radius_bottom_right = 16
	f_style.corner_radius_bottom_left = 16
	f_style.content_margin_left = 20.0
	f_style.content_margin_right = 20.0
	f_style.content_margin_top = 16.0
	f_style.content_margin_bottom = 18.0
	frame.add_theme_stylebox_override(&"panel", f_style)
	center.add_child(frame)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 10)
	frame.add_child(vbox)

	# 1. Header Bar
	var top_bar := HBoxContainer.new()
	header_label = Label.new()
	header_label.text = "🕊️ CAMPUS FELLOWSHIP PRAISE CONCERT"
	header_label.add_theme_font_size_override(&"font_size", 16)
	header_label.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.35))
	header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(header_label)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(36, 32)
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.pressed.connect(close_concert)
	top_bar.add_child(close_btn)
	vbox.add_child(top_bar)

	scripture_label = Label.new()
	scripture_label.text = "📖 Psalm 100:1 - 'Make a joyful noise unto the Lord!'"
	scripture_label.add_theme_font_size_override(&"font_size", 12)
	scripture_label.add_theme_color_override(&"font_color", Color(0.65, 0.85, 1.0))
	vbox.add_child(scripture_label)

	# 2. Stats bar
	var stats_hbox := HBoxContainer.new()
	streak_label = Label.new()
	streak_label.text = "🔥 Praise Streak: 0"
	streak_label.add_theme_font_size_override(&"font_size", 13)
	streak_label.add_theme_color_override(&"font_color", Color(1.0, 0.65, 0.25))
	streak_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_hbox.add_child(streak_label)

	score_label = Label.new()
	score_label.text = "⭐ Harmony: 0 pts"
	score_label.add_theme_font_size_override(&"font_size", 13)
	score_label.add_theme_color_override(&"font_color", Color(0.4, 0.95, 0.65))
	stats_hbox.add_child(score_label)
	vbox.add_child(stats_hbox)

	# 3. Main 4-Track Rhythm Stage
	var stage_panel := PanelContainer.new()
	stage_panel.custom_minimum_size = Vector2(500, 240)
	var st_style := StyleBoxFlat.new()
	st_style.bg_color = Color(0.04, 0.07, 0.12, 0.95)
	st_style.border_width_left = 2
	st_style.border_width_top = 2
	st_style.border_width_right = 2
	st_style.border_width_bottom = 2
	st_style.border_color = Color(0.2, 0.35, 0.55, 0.8)
	st_style.corner_radius_top_left = 10
	st_style.corner_radius_top_right = 10
	st_style.corner_radius_bottom_right = 10
	st_style.corner_radius_bottom_left = 10
	stage_panel.add_theme_stylebox_override(&"panel", st_style)
	vbox.add_child(stage_panel)

	# Inside stage: 4 vertical lanes
	tracks_container = HBoxContainer.new()
	tracks_container.anchors_preset = Control.PRESET_FULL_RECT
	tracks_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tracks_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tracks_container.add_theme_constant_override(&"separation", 6)
	stage_panel.add_child(tracks_container)

	track_lanes.clear()
	for i in range(4):
		var lane := Control.new()
		lane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lane.size_flags_vertical = Control.SIZE_EXPAND_FILL
		lane.clip_contents = true

		var lane_bg := ColorRect.new()
		lane_bg.anchors_preset = Control.PRESET_FULL_RECT
		lane_bg.color = Color(TRACK_COLORS[i].r, TRACK_COLORS[i].g, TRACK_COLORS[i].b, 0.08)
		lane.add_child(lane_bg)

		tracks_container.add_child(lane)
		track_lanes.append(lane)

	# Target hit zone line
	hit_zone_line = ColorRect.new()
	hit_zone_line.color = Color(1.0, 0.88, 0.35, 0.45)
	hit_zone_line.custom_minimum_size = Vector2(0, 4)
	hit_zone_line.anchors_preset = Control.PRESET_BOTTOM_WIDE
	hit_zone_line.position.y = 195.0
	stage_panel.add_child(hit_zone_line)

	# 4. Interactive 4-Key Button Row (Mobile Touch & PC Click)
	var keys_row := HBoxContainer.new()
	keys_row.add_theme_constant_override(&"separation", 6)
	key_buttons.clear()

	for i in range(4):
		var btn := Button.new()
		btn.text = "%s\n[%s]" % [TRACK_NAMES[i], KEY_LABELS[i]]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size = Vector2(0, 48)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = Color(TRACK_COLORS[i].r * 0.4, TRACK_COLORS[i].g * 0.4, TRACK_COLORS[i].b * 0.4, 0.95)
		btn_style.border_width_left = 2
		btn_style.border_width_top = 2
		btn_style.border_width_right = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = TRACK_COLORS[i]
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn.add_theme_stylebox_override(&"normal", btn_style)
		btn.add_theme_stylebox_override(&"hover", btn_style)
		btn.add_theme_stylebox_override(&"pressed", btn_style)

		var lane_idx: int = i
		btn.pressed.connect(func(): _on_lane_hit(lane_idx))
		keys_row.add_child(btn)
		key_buttons.append(btn)

	vbox.add_child(keys_row)

	# 5. Singing Lyrics Prompter
	lyric_display_label = Label.new()
	lyric_display_label.text = "\"What shall I render to Jehovah? For He has done so very much for me!\""
	lyric_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lyric_display_label.add_theme_font_size_override(&"font_size", 13)
	lyric_display_label.add_theme_color_override(&"font_color", Color(1.0, 0.95, 0.75))
	lyric_display_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(lyric_display_label)

	# 6. Song Switcher Row
	var songs_row := HBoxContainer.new()
	songs_row.add_theme_constant_override(&"separation", 6)

	for s_idx in range(HymnData.get_song_count()):
		var s_data: Dictionary = HymnData.get_song_by_index(s_idx)
		var s_btn := Button.new()
		s_btn.text = "Song %d: %s" % [s_idx + 1, s_data.get("title", "").left(14)]
		s_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s_btn.custom_minimum_size = Vector2(0, 32)
		s_btn.add_theme_font_size_override(&"font_size", 10)
		s_btn.focus_mode = Control.FOCUS_NONE
		var chosen_idx: int = s_idx
		s_btn.pressed.connect(func(): _start_song(chosen_idx))
		songs_row.add_child(s_btn)

	vbox.add_child(songs_row)

	# 7. Concert Results Overlay
	results_panel = PanelContainer.new()
	results_panel.anchors_preset = Control.PRESET_FULL_RECT
	results_panel.visible = false
	var res_style := StyleBoxFlat.new()
	res_style.bg_color = Color(0.06, 0.10, 0.18, 0.98)
	res_style.border_width_left = 3
	res_style.border_width_top = 3
	res_style.border_width_right = 3
	res_style.border_width_bottom = 3
	res_style.border_color = Color(1.0, 0.85, 0.3, 0.95)
	res_style.corner_radius_top_left = 14
	res_style.corner_radius_top_right = 14
	res_style.corner_radius_bottom_right = 14
	res_style.corner_radius_bottom_left = 14
	res_style.content_margin_left = 24.0
	res_style.content_margin_right = 24.0
	res_style.content_margin_top = 20.0
	res_style.content_margin_bottom = 20.0
	results_panel.add_theme_stylebox_override(&"panel", res_style)
	frame.add_child(results_panel)

	var res_vbox := VBoxContainer.new()
	res_vbox.add_theme_constant_override(&"separation", 12)
	results_panel.add_child(res_vbox)

	results_title_label = Label.new()
	results_title_label.text = "🕊️ PRAISE MINISTRATION COMPLETE! 🕊️"
	results_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	results_title_label.add_theme_font_size_override(&"font_size", 16)
	results_title_label.add_theme_color_override(&"font_color", Color(1.0, 0.88, 0.35))
	res_vbox.add_child(results_title_label)

	results_stats_label = Label.new()
	results_stats_label.text = "Stats..."
	results_stats_label.add_theme_font_size_override(&"font_size", 13)
	results_stats_label.add_theme_color_override(&"font_color", Color(0.9, 0.95, 1.0))
	res_vbox.add_child(results_stats_label)

	results_verse_label = Label.new()
	results_verse_label.text = "Sister Blessing: 'Amen! The whole fellowship was blessed by your worship!'"
	results_verse_label.add_theme_font_size_override(&"font_size", 12)
	results_verse_label.add_theme_color_override(&"font_color", Color(0.4, 0.85, 1.0))
	results_verse_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	res_vbox.add_child(results_verse_label)

	var res_btns := HBoxContainer.new()
	res_btns.add_theme_constant_override(&"separation", 10)

	next_song_btn = Button.new()
	next_song_btn.text = "🎵 Sing Next Praise Song"
	next_song_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	next_song_btn.custom_minimum_size = Vector2(0, 40)
	next_song_btn.pressed.connect(func():
		var next_idx: int = (current_song_idx + 1) % HymnData.get_song_count()
		_start_song(next_idx)
	)
	res_btns.add_child(next_song_btn)

	var res_close_btn := Button.new()
	res_close_btn.text = "🕊️ Return to Chapel"
	res_close_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	res_close_btn.custom_minimum_size = Vector2(0, 40)
	res_close_btn.pressed.connect(close_concert)
	res_btns.add_child(res_close_btn)

	res_vbox.add_child(res_btns)
