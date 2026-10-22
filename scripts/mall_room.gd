class_name MallRoom
extends "res://scripts/base_room.gd"

## Madam Kikelomo Boutique & Campus Mall (Room 14) Controller.
## High-end campus boutique, wardrobe upgrades, and student retail hub:
## - Madam Kikelomo (Campus Boutique & Mall Proprietress)
## - Bro Segun (Electronics & Gadget Merchant)
## - Boutique Checkout Counter & Fitting Room Mirror
## - Rotating ceiling fan
## - Campus shopping relief & passing out recovery

@onready var ceiling_fan: MeshInstance3D = get_node_or_null("MallFixtures/CeilingFan") as MeshInstance3D
@onready var mall_counter: CampusObject3D = get_node_or_null("WorldObjects/MallCounter") as CampusObject3D
@onready var fitting_mirror: CampusObject3D = get_node_or_null("WorldObjects/FittingRoomMirror") as CampusObject3D


func _ready() -> void:
	room_name = "Campus Mall & Student Boutique"
	room_id = &"mall"
	super._ready()

	if ceiling_fan:
		active_ceiling_fans.append(ceiling_fan)

	if fitting_mirror:
		fitting_mirror.interacted.connect(_on_fitting_mirror_interacted)
	if mall_counter:
		mall_counter.interacted.connect(_on_mall_counter_interacted)


func _on_fitting_mirror_interacted() -> void:
	if not player:
		return
	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	if needs:
		needs.modify_faith(15.0)
	if SoundManager:
		SoundManager.play_click()
	if player.has_method("display_notification"):
		player.display_notification("🪞 Madam Kikelomo's Mirror: 'Ah, fresh scholar! Your posture and outfit look 100%% ready for matriculation!' (+15 Faith)")


func _on_mall_counter_interacted() -> void:
	if not player:
		return
	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	if needs:
		needs.modify_faith(10.0)
	if SoundManager:
		SoundManager.play_click()
	if player.has_method("display_notification"):
		player.display_notification("🛍️ Madam Kikelomo welcomes you: 'Special student discount today! Original native wears, hoodies, power banks and sneakers in stock!'")


func _on_player_passed_out(_reason: String) -> void:
	# If student collapses in the boutique from exhaustion, Madam Kikelomo gives VIP assistance
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_hunger(40.0)
			needs.modify_energy(45.0)
			needs.modify_faith(25.0)
		TimeSystem.advance_minutes(25)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🛍️ Madam Kikelomo rushes over: 'Ehya my fine student! Sit down on this velvet couch, drink this cold malt!' (+45 Energy, +40 Hunger)")
		player.global_position = Vector3(0, 0.1, 1.0)

