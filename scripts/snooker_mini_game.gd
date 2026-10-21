class_name SnookerMiniGame
extends Control

## Interactive Top-Down 2D Snooker & Pool Mini-Game for the Student Union Building.
## Features realistic 2D ball physics, cue aiming line, charge power meter,
## pocket potting, scratch penalties, and Nigerian campus arcade betting.

signal game_closed(total_winnings: int)


# Table geometry (Vertical portrait pool table: 480 x 700 px)
const TABLE_RECT: Rect2 = Rect2(Vector2(120, 260), Vector2(480, 700))
const POCKET_RADIUS: float = 26.0
const BALL_RADIUS: float = 12.0
const FRICTION: float = 220.0 # Deceleration px/s^2

# Pocket centers (4 corners, 2 side pockets)
var pockets: Array[Vector2] = [
	Vector2(TABLE_RECT.position.x + 14, TABLE_RECT.position.y + 14), # Top-Left
	Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x - 14, TABLE_RECT.position.y + 14), # Top-Right
	Vector2(TABLE_RECT.position.x + 10, TABLE_RECT.position.y + TABLE_RECT.size.y * 0.5), # Mid-Left
	Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x - 10, TABLE_RECT.position.y + TABLE_RECT.size.y * 0.5), # Mid-Right
	Vector2(TABLE_RECT.position.x + 14, TABLE_RECT.position.y + TABLE_RECT.size.y - 14), # Bottom-Left
	Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x - 14, TABLE_RECT.position.y + TABLE_RECT.size.y - 14) # Bottom-Right
]

class Ball:
	var pos: Vector2 = Vector2.ZERO
	var vel: Vector2 = Vector2.ZERO
	var color: Color = Color.WHITE
	var number: int = 0
	var is_cue: bool = false
	var potted: bool = false

var balls: Array[Ball] = []
var cue_ball: Ball = null

var aim_angle: float = -PI * 0.5 # Aiming upwards initially
var power: float = 50.0 # 10 to 100%
var is_charging: bool = false
var charge_dir: float = 1.0
var balls_moving: bool = false
var current_player: CharacterBody3D = null
var session_winnings: int = 0
var score_balls_potted: int = 0

# UI elements
@onready var score_label: Label = %ScoreLabel if has_node("%ScoreLabel") else null
@onready var status_label: Label = %StatusLabel if has_node("%StatusLabel") else null
@onready var strike_btn: Button = %StrikeBtn if has_node("%StrikeBtn") else null
@onready var exit_btn: Button = %ExitBtn if has_node("%ExitBtn") else null
@onready var power_bar: ProgressBar = %PowerBar if has_node("%PowerBar") else null


func _ready() -> void:
	visible = false
	set_process_input(true)
	reset_table()


func open_game(player: CharacterBody3D = null) -> void:
	current_player = player
	session_winnings = 0
	score_balls_potted = 0
	reset_table()
	visible = true
	_update_ui()


func close_game() -> void:
	visible = false
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs and session_winnings > 0:
			needs.modify_money(session_winnings)
			needs.modify_energy(10.0)
		if current_player.has_method("display_notification"):
			if session_winnings > 0:
				current_player.display_notification("Snooker session ended! Won +₦%d and campus arcade respect!" % session_winnings)
			else:
				current_player.display_notification("Snooker session ended! Good practice.")
	game_closed.emit(session_winnings)


func reset_table() -> void:
	balls.clear()

	# Create White Cue Ball (at bottom D-spot)
	cue_ball = Ball.new()
	cue_ball.pos = Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x * 0.5, TABLE_RECT.position.y + TABLE_RECT.size.y * 0.78)
	cue_ball.color = Color(0.98, 0.98, 0.98)
	cue_ball.is_cue = true
	cue_ball.number = 0
	balls.append(cue_ball)

	# Rack 9 balls in a triangle pyramid near the top
	var apex = Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x * 0.5, TABLE_RECT.position.y + TABLE_RECT.size.y * 0.28)
	var ball_colors: Array[Color] = [
		Color(0.95, 0.85, 0.1), # 1 Yellow
		Color(0.2, 0.45, 0.9),  # 2 Blue
		Color(0.9, 0.25, 0.2),  # 3 Red
		Color(0.6, 0.25, 0.75), # 4 Purple
		Color(0.95, 0.55, 0.15),# 5 Orange
		Color(0.2, 0.75, 0.35), # 6 Green
		Color(0.6, 0.15, 0.15), # 7 Maroon
		Color(0.12, 0.12, 0.12),# 8 Black
		Color(0.95, 0.85, 0.3)  # 9 Yellow Stripe
	]

	var r: float = BALL_RADIUS * 2.05
	var rack_offsets: Array[Vector2] = [
		Vector2(0, 0),
		Vector2(-r * 0.5, -r * 0.866),
		Vector2(r * 0.5, -r * 0.866),
		Vector2(-r, -r * 1.732),
		Vector2(0, -r * 1.732), # 8-ball in center
		Vector2(r, -r * 1.732),
		Vector2(-r * 0.5, -r * 2.598),
		Vector2(r * 0.5, -r * 2.598),
		Vector2(0, -r * 3.464)
	]

	for i in range(mini(9, rack_offsets.size())):
		var b = Ball.new()
		b.pos = apex + rack_offsets[i]
		b.color = ball_colors[i]
		b.number = i + 1
		balls.append(b)

	balls_moving = false
	aim_angle = -PI * 0.5
	power = 40.0
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return

	# Tap or drag on table to aim cue stick
	if event is InputEventMouseButton and event.pressed:
		if cue_ball and not cue_ball.potted and not balls_moving:
			aim_angle = (event.position - cue_ball.pos).angle()
			queue_redraw()
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		if cue_ball and not cue_ball.potted and not balls_moving:
			aim_angle = (event.position - cue_ball.pos).angle()
			queue_redraw()


func _physics_process(delta: float) -> void:
	if not visible:
		return

	# Power meter oscillation if charging
	if is_charging:
		power += charge_dir * delta * 75.0
		if power >= 100.0:
			power = 100.0
			charge_dir = -1.0
		elif power <= 15.0:
			power = 15.0
			charge_dir = 1.0
		if power_bar:
			power_bar.value = power

	# Physics simulation of balls
	var any_moving: bool = false

	for b in balls:
		if b.potted:
			continue

		if b.vel.length_squared() > 1.0:
			any_moving = true
			b.pos += b.vel * delta
			b.vel = b.vel.move_toward(Vector2.ZERO, FRICTION * delta)

			# Cushion collisions
			var min_x = TABLE_RECT.position.x + BALL_RADIUS + 4.0
			var max_x = TABLE_RECT.position.x + TABLE_RECT.size.x - BALL_RADIUS - 4.0
			var min_y = TABLE_RECT.position.y + BALL_RADIUS + 4.0
			var max_y = TABLE_RECT.position.y + TABLE_RECT.size.y - BALL_RADIUS - 4.0

			if b.pos.x <= min_x:
				b.pos.x = min_x
				b.vel.x = -b.vel.x * 0.85
			elif b.pos.x >= max_x:
				b.pos.x = max_x
				b.vel.x = -b.vel.x * 0.85

			if b.pos.y <= min_y:
				b.pos.y = min_y
				b.vel.y = -b.vel.y * 0.85
			elif b.pos.y >= max_y:
				b.pos.y = max_y
				b.vel.y = -b.vel.y * 0.85

			# Check pocket sink
			for p in pockets:
				if b.pos.distance_to(p) <= POCKET_RADIUS:
					_pocket_ball(b)
					break
		else:
			b.vel = Vector2.ZERO

	# Ball-to-ball elastic collisions
	for i in range(balls.size()):
		var b1 = balls[i]
		if b1.potted:
			continue
		for j in range(i + 1, balls.size()):
			var b2 = balls[j]
			if b2.potted:
				continue

			var delta_pos = b2.pos - b1.pos
			var dist = delta_pos.length()
			var min_dist = BALL_RADIUS * 2.0

			if dist < min_dist and dist > 0.001:
				# Resolve overlap
				var normal = delta_pos / dist
				var overlap = (min_dist - dist) * 0.5
				b1.pos -= normal * overlap
				b2.pos += normal * overlap

				# Elastic impulse transfer
				var v_rel = b1.vel - b2.vel
				var speed_along_normal = v_rel.dot(normal)
				if speed_along_normal > 0.0:
					var impulse = normal * speed_along_normal * 0.92
					b1.vel -= impulse
					b2.vel += impulse
					if SoundManager and speed_along_normal > 40.0:
						SoundManager.play_click()

	balls_moving = any_moving
	queue_redraw()


func _pocket_ball(b: Ball) -> void:
	b.potted = true
	b.vel = Vector2.ZERO

	if b.is_cue:
		# Scratch! Penalty
		session_winnings = maxi(0, session_winnings - 200)
		if status_label:
			status_label.text = "⚠️ FOUL! Cue Ball Pocketed! -₦200 Penalty"
			status_label.add_theme_color_override(&"font_color", Color(1.0, 0.3, 0.3))
		if SoundManager:
			SoundManager.play_alert()
		# Re-spot cue ball
		get_tree().create_timer(0.6).timeout.connect(func():
			cue_ball.potted = false
			cue_ball.pos = Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x * 0.5, TABLE_RECT.position.y + TABLE_RECT.size.y * 0.78)
			cue_ball.vel = Vector2.ZERO
		)
	else:
		score_balls_potted += 1
		var reward: int = 500
		if b.number == 8:
			reward = 2500
			if status_label:
				status_label.text = "🏆 8-BALL POTTED! BIG JACKPOT! +₦2,500!"
				status_label.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
		else:
			if status_label:
				status_label.text = "🎯 NICE SHOT! Ball #%d Potted! +₦%d" % [b.number, reward]
				status_label.add_theme_color_override(&"font_color", Color(0.3, 0.95, 0.5))

		session_winnings += reward
		if SoundManager:
			SoundManager.play_coin()
		if current_player:
			PropBuilder3D.advance_quest_if_matching(8, current_player)

	_update_ui()


func strike() -> void:
	if balls_moving or not cue_ball or cue_ball.potted:
		return

	if current_player and current_player.has_method("play_snooker_shot_animation"):
		current_player.play_snooker_shot_animation()

	var impulse_speed: float = (power / 100.0) * 850.0
	cue_ball.vel = Vector2(cos(aim_angle), sin(aim_angle)) * impulse_speed
	balls_moving = true
	if SoundManager:
		SoundManager.play_click()


func _update_ui() -> void:
	if score_label:
		score_label.text = "Balls Potted: %d  |  Winnings: ₦%d" % [score_balls_potted, session_winnings]


func _draw() -> void:
	if not visible:
		return

	# Draw Table Outer Wood Border
	var outer_border = Rect2(TABLE_RECT.position - Vector2(22, 22), TABLE_RECT.size + Vector2(44, 44))
	draw_rect(outer_border, Color(0.32, 0.18, 0.08), true) # Dark mahogany wood
	draw_rect(outer_border, Color(0.18, 0.10, 0.04), false, 4.0)

	# Draw Green Baize Cloth
	draw_rect(TABLE_RECT, Color(0.12, 0.48, 0.22), true) # Snooker green felt
	draw_rect(TABLE_RECT, Color(0.08, 0.32, 0.15), false, 3.0)

	# Draw Head String (D-Line)
	var d_line_y = TABLE_RECT.position.y + TABLE_RECT.size.y * 0.78
	draw_line(Vector2(TABLE_RECT.position.x + 8, d_line_y), Vector2(TABLE_RECT.position.x + TABLE_RECT.size.x - 8, d_line_y), Color(0.2, 0.6, 0.3, 0.6), 2.0)

	# Draw Pockets
	for p in pockets:
		draw_circle(p, POCKET_RADIUS, Color(0.06, 0.06, 0.06)) # Deep black hole
		draw_arc(p, POCKET_RADIUS, 0, TAU, 32, Color(0.4, 0.35, 0.2), 3.0) # Brass pocket rim

	# Draw Aiming Line from Cue Ball
	if cue_ball and not cue_ball.potted and not balls_moving:
		var aim_dir = Vector2(cos(aim_angle), sin(aim_angle))
		var line_start = cue_ball.pos + aim_dir * (BALL_RADIUS + 4.0)
		var line_end = cue_ball.pos + aim_dir * 180.0
		draw_line(line_start, line_end, Color(1.0, 1.0, 1.0, 0.75), 2.0)
		# Cue stick behind white ball
		var cue_start = cue_ball.pos - aim_dir * (BALL_RADIUS + 12.0 + (power * 0.3))
		var cue_end = cue_ball.pos - aim_dir * (BALL_RADIUS + 140.0 + (power * 0.3))
		draw_line(cue_start, cue_end, Color(0.85, 0.65, 0.35), 6.0) # Wooden cue stick
		draw_line(cue_start, cue_start - aim_dir * 8.0, Color(0.2, 0.6, 0.9), 6.0) # Blue chalk tip

	# Draw Balls
	for b in balls:
		if b.potted:
			continue
		# Drop shadow
		draw_circle(b.pos + Vector2(2, 3), BALL_RADIUS, Color(0, 0, 0, 0.35))
		# Ball body
		draw_circle(b.pos, BALL_RADIUS, b.color)
		# Specular shine
		draw_circle(b.pos - Vector2(3, 3), BALL_RADIUS * 0.35, Color(1, 1, 1, 0.45))
		# Ball number ring
		if not b.is_cue:
			draw_circle(b.pos, BALL_RADIUS * 0.45, Color.WHITE)
			draw_circle(b.pos, BALL_RADIUS * 0.22, b.color)

