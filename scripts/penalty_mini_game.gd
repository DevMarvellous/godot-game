class_name PenaltyMiniGame
extends Control

## Interactive 3D Stadium Penalty Shootout Mini-Game for the Dean's Cup.
## Players select tactical strike corners, adjust power, choose match stakes,
## and battle the Faculty Goalkeeper with realistic goal/save outcomes.

signal penalty_taken(corner: String, power: float, stake: int, is_goal: bool, payout: int)
signal dialog_closed

var current_player: CharacterBody3D = null
var selected_corner: String = "top_left"
var selected_stake: int = 0
var power: float = 60.0
var is_charging: bool = true
var charge_dir: float = 1.0
var is_striking: bool = false

# UI references
@onready var status_label: Label = %StatusLabel if has_node("%StatusLabel") else null
@onready var power_bar: ProgressBar = %PowerBar if has_node("%PowerBar") else null
@onready var strike_btn: Button = %StrikeBtn if has_node("%StrikeBtn") else null
@onready var exit_btn: Button = %ExitBtn if has_node("%ExitBtn") else null
@onready var stake_info_label: Label = %StakeInfoLabel if has_node("%StakeInfoLabel") else null

# Corner buttons
@onready var btn_tl: Button = %BtnTopLeft if has_node("%BtnTopLeft") else null
@onready var btn_tr: Button = %BtnTopRight if has_node("%BtnTopRight") else null
@onready var btn_roof: Button = %BtnRoof if has_node("%BtnRoof") else null
@onready var btn_bl: Button = %BtnBottomLeft if has_node("%BtnBottomLeft") else null
@onready var btn_br: Button = %BtnBottomRight if has_node("%BtnBottomRight") else null
@onready var btn_panenka: Button = %BtnPanenka if has_node("%BtnPanenka") else null

# Stake buttons
@onready var btn_stake_0: Button = %BtnStake0 if has_node("%BtnStake0") else null
@onready var btn_stake_500: Button = %BtnStake500 if has_node("%BtnStake500") else null
@onready var btn_stake_1500: Button = %BtnStake1500 if has_node("%BtnStake1500") else null


func _ready() -> void:
	visible = false
	_bind_buttons()
	_update_corner_buttons_visuals()
	_update_stake_buttons_visuals()


func _bind_buttons() -> void:
	if btn_tl: btn_tl.pressed.connect(func(): _select_corner("top_left"))
	if btn_roof: btn_roof.pressed.connect(func(): _select_corner("roof_center"))
	if btn_tr: btn_tr.pressed.connect(func(): _select_corner("top_right"))
	if btn_bl: btn_bl.pressed.connect(func(): _select_corner("bottom_left"))
	if btn_panenka: btn_panenka.pressed.connect(func(): _select_corner("panenka_center"))
	if btn_br: btn_br.pressed.connect(func(): _select_corner("bottom_right"))

	if btn_stake_0: btn_stake_0.pressed.connect(func(): _select_stake(0))
	if btn_stake_500: btn_stake_500.pressed.connect(func(): _select_stake(500))
	if btn_stake_1500: btn_stake_1500.pressed.connect(func(): _select_stake(1500))

	if strike_btn: strike_btn.pressed.connect(strike)
	if exit_btn: exit_btn.pressed.connect(close_dialog)


func _process(delta: float) -> void:
	if not visible or is_striking:
		return

	# Oscillate shot power meter
	if is_charging:
		power += charge_dir * delta * 80.0
		if power >= 100.0:
			power = 100.0
			charge_dir = -1.0
		elif power <= 20.0:
			power = 20.0
			charge_dir = 1.0

		if power_bar:
			power_bar.value = power


func open_penalty(player: CharacterBody3D) -> void:
	current_player = player
	is_striking = false
	is_charging = true
	power = 60.0
	charge_dir = 1.0
	if status_label:
		status_label.text = "🎯 Pick your target corner, match stake, and time your strike power!"
		status_label.add_theme_color_override(&"font_color", Color(0.35, 0.95, 0.65))
	_update_corner_buttons_visuals()
	_update_stake_buttons_visuals()
	visible = true


func close_dialog() -> void:
	visible = false
	current_player = null
	dialog_closed.emit()


func _select_corner(corner: String) -> void:
	selected_corner = corner
	_update_corner_buttons_visuals()
	if SoundManager:
		SoundManager.play_click()


func _select_stake(stake: int) -> void:
	selected_stake = stake
	_update_stake_buttons_visuals()
	if SoundManager:
		SoundManager.play_click()


func _update_corner_buttons_visuals() -> void:
	var buttons = {
		"top_left": btn_tl,
		"roof_center": btn_roof,
		"top_right": btn_tr,
		"bottom_left": btn_bl,
		"panenka_center": btn_panenka,
		"bottom_right": btn_br
	}
	for key in buttons.keys():
		var btn: Button = buttons[key]
		if btn:
			if key == selected_corner:
				btn.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.2))
				btn.text = "★ " + _get_corner_label(key)
			else:
				btn.remove_theme_color_override(&"font_color")
				btn.text = _get_corner_label(key)


func _get_corner_label(corner: String) -> String:
	match corner:
		"top_left": return "↖ Top Bins (Left)"
		"roof_center": return "⬆ Roof Power (Center)"
		"top_right": return "↗ Postage Stamp (Right)"
		"bottom_left": return "↙ Low Driver (Left)"
		"panenka_center": return "⬇ Panenka Chip"
		"bottom_right": return "↘ Inside Post (Right)"
		_: return corner


func _update_stake_buttons_visuals() -> void:
	if btn_stake_0:
		btn_stake_0.add_theme_color_override(&"font_color", Color(0.4, 1.0, 0.5) if selected_stake == 0 else Color(0.8, 0.8, 0.8))
	if btn_stake_500:
		btn_stake_500.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2) if selected_stake == 500 else Color(0.8, 0.8, 0.8))
	if btn_stake_1500:
		btn_stake_1500.add_theme_color_override(&"font_color", Color(1.0, 0.45, 0.45) if selected_stake == 1500 else Color(0.8, 0.8, 0.8))

	if stake_info_label:
		if selected_stake == 0:
			stake_info_label.text = "Stake: Free Practice • Payout: ₦500 Athletic Bonus on Goal"
		elif selected_stake == 500:
			stake_info_label.text = "Stake: ₦500 Campus League • Payout: ₦1,000 Cash on Goal"
		else:
			stake_info_label.text = "Stake: ₦1,500 Dean's Cup Final • Payout: ₦3,000 Cash + Championship Glory!"


func strike() -> void:
	if is_striking:
		return

	# Validate funds if stake > 0
	if current_player and selected_stake > 0:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs and needs.money < selected_stake:
			if status_label:
				status_label.text = "⚠️ Sapa Alert! You need ₦%d to enter this match stake!" % selected_stake
				status_label.add_theme_color_override(&"font_color", Color(1.0, 0.35, 0.35))
			if SoundManager:
				SoundManager.play_alert()
			return

	is_striking = true
	is_charging = false

	# Deduct stake if applicable
	if current_player and selected_stake > 0:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_money(-selected_stake)

	TimeSystem.advance_minutes(15)

	# Trigger player animation & sound
	if current_player and current_player.has_method("play_penalty_kick_animation"):
		current_player.play_penalty_kick_animation()
	if SoundManager:
		SoundManager.play_whistle()

	# Evaluate Goalkeeper AI & Shot Physics
	var shot_power = power
	var target_corner = selected_corner

	# Goalkeeper dive possibilities
	var dive_options = ["top_left", "roof_center", "top_right", "bottom_left", "panenka_center", "bottom_right"]
	# Random dive choice
	var gk_dive = dive_options[randi() % dive_options.size()]

	var is_goal: bool = false
	var outcome_msg: String = ""
	var payout: int = 0

	if shot_power > 92.0:
		# Overhit! Blasted into the stands
		is_goal = false
		outcome_msg = "💨 OVER THE CROSSBAR! Shot power was %.0f%% — ball sailed high into the hostel fence!" % shot_power
		if SoundManager:
			SoundManager.play_alert()
	elif shot_power < 30.0:
		# Weak scuffed shot
		is_goal = false
		outcome_msg = "🧤 WEAK EFFORT! Scuffed at %.0f%% power. Goalkeeper easily scooped it up." % shot_power
		if SoundManager:
			SoundManager.play_alert()
	elif gk_dive == target_corner:
		# Saved by Goalkeeper!
		is_goal = false
		outcome_msg = "🧤 WORLD-CLASS SAVE! Goalkeeper dived right into %s and tipped it wide!" % _get_corner_label(target_corner)
		if SoundManager:
			SoundManager.play_alert()
	else:
		# GOAL!
		is_goal = true
		if selected_stake == 0:
			payout = 500
		elif selected_stake == 500:
			payout = 1000
		else:
			payout = 3000

		outcome_msg = "⚽ GOOOAAAL! Curled cleanly into %s! Keeper dived %s! Won +₦%d!" % [
			_get_corner_label(target_corner),
			_get_corner_label(gk_dive),
			payout
		]

		if SoundManager:
			SoundManager.play_cheer()
			SoundManager.play_coin()

	# Apply rewards
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			if is_goal:
				needs.modify_money(payout)
				needs.modify_faith(20.0)
				needs.modify_energy(15.0)
			else:
				needs.modify_energy(10.0)

		if is_goal and current_player.has_method("play_celebrate_animation"):
			current_player.play_celebrate_animation("⚽ GOAL! +₦%d" % payout)

		# Advance Task 6 (Penalty Goal) if quest active
		PropBuilder3D.advance_quest_if_matching(5, current_player)

	if status_label:
		status_label.text = outcome_msg
		status_label.add_theme_color_override(&"font_color", Color(0.3, 0.98, 0.5) if is_goal else Color(1.0, 0.7, 0.3))

	penalty_taken.emit(target_corner, shot_power, selected_stake, is_goal, payout)

	# Re-enable striking after brief timeout
	get_tree().create_timer(1.8).timeout.connect(func():
		is_striking = false
		is_charging = true
	)

