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


func _ready() -> void:
	room_name = "Campus Chapel / Fellowship Auditorium"
	room_id = &"chapel"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)


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
