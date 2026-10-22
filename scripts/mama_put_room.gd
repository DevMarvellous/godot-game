class_name MamaPutRoom
extends "res://scripts/base_room.gd"

## Mama Put Buka Canteen (Room 4) Controller.
## Authentic campus cafeteria & student fueling station:
## - Mama Cashout, Iya Basira, Mallam Danladi, Senior Tobi, Fresher Kemi
## - Steaming Jollof, Egusi, Amala, Suya warmers
## - Dual rotating ceiling fans
## - Interactive Handwash Stand (+Hygiene, +Faith)
## - Interactive Dining Tables with Campus Gist & Eavesdropping
## - Passing-out rescue: Mama Cashout serves emergency jollof & glucose water

@onready var ceiling_fan_1: MeshInstance3D = get_node_or_null("MamaPutFixtures/CeilingFan") as MeshInstance3D
@onready var ceiling_fan_2: MeshInstance3D = get_node_or_null("MamaPutFixtures/CeilingFan2") as MeshInstance3D


func _ready() -> void:
	room_name = "Mama Put (Campus Food Joint)"
	room_id = &"mama_put"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if menu_type == &"handwash":
		_wash_hands(p)
		return
	elif menu_type == &"drinks":
		_buy_chilled_drink(p)
		return

	super._on_fixture_menu_requested(menu_type, p)


func _wash_hands(p: CharacterBody3D) -> void:
	if not p:
		return
	var needs: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager
	if needs:
		needs.modify_faith(15.0)
		needs.modify_energy(10.0)
	if SoundManager:
		SoundManager.play_click()
	TimeSystem.advance_minutes(5)
	if p.has_method("display_notification"):
		p.display_notification("🚰 Washed hands clean with carbolic soap! Mama Cashout nods: 'Good hygiene, student!' Faith +15!")


func _buy_chilled_drink(p: CharacterBody3D) -> void:
	if not p:
		return
	var needs: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if needs.modify_money(-200):
		needs.modify_energy(25.0)
		needs.modify_hunger(15.0)
		TimeSystem.advance_minutes(5)
		if SoundManager:
			SoundManager.play_click()
		if p.has_method("display_notification"):
			p.display_notification("🥤 Chilled Zobo with ginger & cloves (-₦200)! Brain refreshed! Energy +25%!")
	else:
		if p.has_method("display_notification"):
			p.display_notification("Sapa alert! You need ₦200 for chilled Zobo. Pure water is ₦50!")


func _on_player_passed_out(_reason: String) -> void:
	# If student collapses from hunger inside Mama Put, Mama Cashout rushes to the rescue
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_hunger(50.0)
			needs.modify_energy(35.0)
			needs.modify_faith(20.0)
		TimeSystem.advance_minutes(25)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🍲 Mama Cashout revived you: 'Ehya! Sapa wan kill my student?! Take this hot jollof rice free of charge!'")
		player.global_position = Vector3(0, 0.1, -3.5)
