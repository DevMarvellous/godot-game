class_name LectureTheatre2Room
extends "res://scripts/base_room.gd"

## Faculty Lecture Theatre 2 (LT2 - Room 6) Controller.
## Grand Auditorium for Mathematics, Sciences, and Software Engineering:
## - Prof. Okonjo (Mathematics), Mr. Adepoju Marvellous (Software Engineering), Mrs. Folashade (GST)
## - Tiered amphitheatre risers with dual rotating ceiling fans
## - Dynamic dry-erase whiteboard notes for MTH 101, SWE 101, and GST 101
## - Interactive Engineering Coding Terminal & Project Desk
## - In-class exhaustion rescue

@onready var ceiling_fan_1: MeshInstance3D = get_node_or_null("LectureFixtures/CeilingFan1") as MeshInstance3D
@onready var ceiling_fan_2: MeshInstance3D = get_node_or_null("LectureFixtures/CeilingFan2") as MeshInstance3D
@onready var calculus_notes: Label3D = get_node_or_null("LectureFixtures/CalculusNotes") as Label3D

var has_consulted_swe: bool = false


func _ready() -> void:
	room_name = "Mathematics & Sciences Auditorium (LT2)"
	room_id = &"lecture2"
	super._ready()

	if ceiling_fan_1:
		active_ceiling_fans.append(ceiling_fan_1)
	if ceiling_fan_2:
		active_ceiling_fans.append(ceiling_fan_2)


func _on_fixture_menu_requested(menu_type: StringName, p: CharacterBody3D) -> void:
	if menu_type == &"swe_terminal":
		_consult_swe_lecturer(p)
		return

	super._on_fixture_menu_requested(menu_type, p)


func _consult_swe_lecturer(p: CharacterBody3D) -> void:
	if not p:
		return
	var needs: NeedsManager = p.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if not has_consulted_swe:
		has_consulted_swe = true
		needs.modify_cgpa(0.08)
		needs.modify_faith(15.0)
		TimeSystem.advance_minutes(10)
		if SoundManager:
			SoundManager.play_click()
		if p.has_method("display_notification"):
			p.display_notification("💻 Mr. Marvellous: 'Clean OOP, modular state machines, and decoupled signals make software bulletproof!' (+0.08 CGPA Bonus, +15 Faith)!")
	else:
		if p.has_method("display_notification"):
			p.display_notification("Mr. Marvellous: 'Keep coding with conviction, scholar! Test your algorithms thoroughly.'")


func _on_player_passed_out(_reason: String) -> void:
	if player:
		var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			needs.modify_energy(40.0)
			needs.modify_hunger(30.0)
			needs.modify_faith(15.0)
		TimeSystem.advance_minutes(20)
		if SoundManager:
			SoundManager.play_cheer()
		if player.has_method("display_notification"):
			player.display_notification("🏥 In-Auditorium Rescue: Mr. Marvellous & Prof. Okonjo: 'Take a breather! Drink this cold water and rest!' Restored +40 Energy!")
		player.global_position = Vector3(0, 0.45, -2.5)
