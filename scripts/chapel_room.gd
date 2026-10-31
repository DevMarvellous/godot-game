class_name ChapelRoom
extends "res://scripts/base_room.gd"

## University Chapel & Fellowship Auditorium (Room 9) Controller.
## Spiritual sanctuary & mental wellness hub:
## - Sister Blessing (Fellowship Executive), Brother Austin
## - Prayer pews, golden altar cross, worship piano & hymn keyboard
## - Peace of mind restoration & exam anxiety relief
## - Spiritual exhaustion rescue

@onready var ceiling_fan_1: MeshInstance3D = get_node_or_null("ChapelFixtures/CeilingFan1") as MeshInstance3D
@onready var ceiling_fan_2: MeshInstance3D = get_node_or_null("ChapelFixtures/CeilingFan2") as MeshInstance3D
@onready var praise_game: Control = get_node_or_null("MenusLayer/ChapelPraiseGame") as Control


func _ready() -> void:
	room_name = "Campus Chapel / Fellowship Auditorium"
	room_id = &"chapel"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)

	if praise_game and praise_game.has_signal("concert_closed"):
		praise_game.concert_closed.connect(_on_menu_closed)


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if menu_type == &"chapel_praise":
		_open_praise_game(p)
		return

	super._on_fixture_menu_requested(menu_type, p)


func _open_praise_game(p: CharacterBody3D) -> void:
	if not praise_game:
		praise_game = get_node_or_null("MenusLayer/ChapelPraiseGame") as Control
	if not praise_game:
		var ml: CanvasLayer = get_node_or_null("MenusLayer") as CanvasLayer
		if ml:
			const PraiseScene = preload("res://scenes/chapel_praise_game.tscn")
			praise_game = PraiseScene.instantiate() as Control
			ml.add_child(praise_game)
			if praise_game.has_signal("concert_closed"):
				praise_game.concert_closed.connect(_on_menu_closed)
	if praise_game:
		_close_all_active_modals(praise_game)
		if p:
			p.set_physics_process(false)
			p.velocity = Vector3.ZERO
		if praise_game.has_method("open_concert"):
			praise_game.open_concert(p)


func _on_player_passed_out(_reason: String) -> void:
	# If student faints from academic anxiety, Sister Blessing ministers prayer and cold water
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_faith(50.0)
			needs.modify_energy(40.0)
		TimeSystem.advance_minutes(30)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🕊️ Sister Blessing prays with you: 'Peace be still! Receive divine strength for your exams!' Faith +50, Energy +40!")
		player.global_position = Vector3(0, 0.1, 0)

