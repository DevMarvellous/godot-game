class_name LibraryRoom
extends "res://scripts/base_room.gd"

## Central University Library (Room 7) Controller.
## High-focus academic haven:
## - Mrs. Janet (Chief Librarian), Tobi (First Class Scholar)
## - Deep study carrels, past question archives, department project stations
## - Strict silence enforcement and TDB (Till Day Break) study bonus
## - Overhead ceiling fans and warm brass reading lamps

@onready var ceiling_fan_1: MeshInstance3D = get_node_or_null("LibraryFixtures/CeilingFan1") as MeshInstance3D
@onready var ceiling_fan_2: MeshInstance3D = get_node_or_null("LibraryFixtures/CeilingFan2") as MeshInstance3D

var has_borrowed_textbook: bool = false


func _ready() -> void:
	room_name = "Kashim Ibrahim University Library"
	room_id = &"library"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if menu_type == &"borrow_book":
		_borrow_reference_textbook(p)
		return

	super._on_fixture_menu_requested(menu_type, p)


func _borrow_reference_textbook(p: CharacterBody3D) -> void:
	if not p:
		return
	var needs: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if not has_borrowed_textbook:
		has_borrowed_textbook = true
		needs.modify_cgpa(0.06)
		needs.modify_faith(15.0)
		TimeSystem.advance_minutes(10)
		if SoundManager:
			SoundManager.play_click()
		if p.has_method("display_notification"):
			p.display_notification("📚 Mrs. Janet stamped your library card: 'Reference Textbook issued! Return within 14 days.' (+0.06 CGPA, +15 Faith)!")
	else:
		if p.has_method("display_notification"):
			p.display_notification("Mrs. Janet: 'You have a textbook on loan, scholar! Study diligently and return on time.'")


func _on_player_passed_out(_reason: String) -> void:
	# If student collapses from TDB (Till Day Break) study fatigue, Mrs. Janet offers gentle assistance
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_energy(40.0)
			needs.modify_faith(20.0)
		TimeSystem.advance_minutes(30)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("📖 Mrs. Janet wakes you gently: 'TDB reading burnout! Rest your eyes on the carrel desk, scholar!' Restored +40 Energy!")
		player.global_position = Vector3(0, 0.1, -2.5)
