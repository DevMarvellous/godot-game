class_name GardenRoom
extends "res://scripts/base_room.gd"

## Campus Botanical Gardens & Nature Sanctuary (Room 11) Controller.
## Scenic outdoor relaxation, meditation & street food haven:
## - Iya Boli (Sweet Roasted Plantain & Pepper Fish Vendor)
## - Final Year Senior Tobi
## - Charcoal smoke particles, park benches, nature canopy trees
## - Stress relief, prayer walk, and passing out rescue

func _ready() -> void:
	room_name = "Campus Botanical Gardens & Quiet Park"
	room_id = &"garden"
	super._ready()


func _on_player_passed_out(_reason: String) -> void:
	# If student collapses in the garden, Iya Boli revives them with chilled zobo and roasted boli
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_hunger(45.0)
			needs.modify_energy(40.0)
			needs.modify_faith(25.0)
		TimeSystem.advance_minutes(25)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🌿 Iya Boli revives you: 'Pikin, sit down under the tree shade! Chop this hot sweet boli and drink zobo!' Restored +45 Hunger, +40 Energy!")
		player.global_position = Vector3(0, 0.1, 0)

