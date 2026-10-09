class_name CampusObject3D
extends Interactable3D

## 3D campus fixtures: Bed, Study Desk, Cafeteria Counter, Chapel Altar, ATM.
## Tied to TimeSystem and Schedule for time-based actions and menus.

signal menu_requested(menu_type: StringName, player: CharacterBody3D)

enum ObjectType { BED, DESK, CAFETERIA, FELLOWSHIP, ATM, HUSTLE_DESK, SALON_CHAIR }

@export var object_type: ObjectType = ObjectType.BED

@onready var label_3d: Label3D = $Label3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	super._ready()
	update_object_display()
	TimeSystem.minute_passed.connect(_on_minute_passed)


func _on_minute_passed() -> void:
	if object_type == ObjectType.DESK:
		var lec_idx: int = Schedule.get_current_lecture_index()
		if lec_idx != -1 and not Schedule.is_attended(lec_idx):
			var lec: Dictionary = Schedule.get_lecture(lec_idx)
			prompt_message = "[E] CLASS NOW: %s" % String(lec["name"])
		else:
			prompt_message = "[E] Study & Lecture Options"
	elif object_type == ObjectType.FELLOWSHIP:
		if Schedule.is_fellowship_time():
			prompt_message = "[E] Join Fellowship (+40 Faith, 30m)"
		else:
			prompt_message = "[E] Personal Prayer (+15 Faith, 15m)"


func update_object_display() -> void:
	match object_type:
		ObjectType.BED:
			prompt_message = "[E] Sleep until 07:00 (End Day)"
			object_name = "Hostel Bed"
		ObjectType.DESK:
			prompt_message = "[E] Study & Lecture Options"
			object_name = "Lecture & Study Desk"
		ObjectType.CAFETERIA:
			prompt_message = "[E] Open Buka Food Menu"
			object_name = "Campus Buka / Cafe"
		ObjectType.FELLOWSHIP:
			prompt_message = "[E] Fellowship Chapel"
			object_name = "Chapel Altar"
		ObjectType.ATM:
			prompt_message = "[E] Withdraw Allowance (+₦2,000)"
			object_name = "Campus ATM"
		ObjectType.HUSTLE_DESK:
			prompt_message = "[E] Freelance Typing & Design Work"
			object_name = "Hustle Workstation"
		ObjectType.SALON_CHAIR:
			prompt_message = "[E] Get Fresh Haircut (₦1,000)"
			object_name = "Barber Styling Chair"

	if label_3d:
		label_3d.text = object_name


func interact(player: CharacterBody3D) -> void:
	super.interact(player)
	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	match object_type:
		ObjectType.BED:
			TimeSystem.sleep_until(7)
			needs.energy = needs.max_energy
			needs.stat_changed.emit(&"energy", needs.energy, needs.max_energy)
			_show_feedback(player, "Slept well until 07:00! Full Energy restored.")

		ObjectType.DESK:
			menu_requested.emit(&"study", player)

		ObjectType.CAFETERIA:
			menu_requested.emit(&"food", player)

		ObjectType.FELLOWSHIP:
			if Schedule.is_fellowship_time():
				needs.modify_faith(40.0)
				needs.modify_energy(10.0)
				TimeSystem.advance_minutes(30)
				_show_feedback(player, "Blessed fellowship hour! Faith +40, Energy +10")
			else:
				needs.modify_faith(15.0)
				TimeSystem.advance_minutes(15)
				_show_feedback(player, "Quiet time & prayer! Faith +15")

		ObjectType.ATM:
			needs.modify_money(2000)
			TimeSystem.advance_minutes(5)
			_show_feedback(player, "Allowance received! +₦2,000")

		ObjectType.HUSTLE_DESK:
			if needs.energy >= 18.0:
				needs.modify_energy(-18.0)
				needs.modify_money(2500)
				TimeSystem.advance_minutes(45)
				_show_feedback(player, "Completed student typing hustle! +₦2,500, Energy -18%")
			else:
				_show_feedback(player, "Too exhausted to work! Rest on your bed first.")

		ObjectType.SALON_CHAIR:
			if needs.money >= 1000:
				needs.modify_money(-1000)
				TimeSystem.advance_minutes(20)
				const Customizer = preload("res://scripts/data/character_customizer.gd")
				var new_hair_color: Color = Customizer.HAIR_STYLES[randi() % Customizer.HAIR_STYLES.size()].color
				if player.has_method("apply_appearance"):
					player.apply_appearance(Color(0.32, 0.20, 0.14), Color(0.12, 0.55, 0.32), Color(0.15, 0.22, 0.32), new_hair_color)
				_show_feedback(player, "Fresh haircut from Master Sunday! Looking sharp! -₦1,000")
			else:
				_show_feedback(player, "Insufficient funds! Master Sunday charges ₦1,000.")


func _show_feedback(player: CharacterBody3D, msg: String) -> void:
	if player.has_method("display_notification"):
		player.display_notification(msg)
