class_name CampusObject3D
extends Interactable3D

## 3D campus fixtures: Bed, Study Desk, Cafeteria Counter, Chapel Altar, ATM.
## Tied to TimeSystem and Schedule for time-based actions and lectures.

enum ObjectType { BED, DESK, CAFETERIA, FELLOWSHIP, ATM }

@export var object_type: ObjectType = ObjectType.BED

@onready var label_3d: Label3D = $Label3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	super._ready()
	update_object_display()
	TimeSystem.minute_passed.connect(_on_minute_passed)


func _on_minute_passed() -> void:
	# Update prompt messages dynamically if a lecture or fellowship is happening
	if object_type == ObjectType.DESK:
		var lec_idx: int = Schedule.get_current_lecture_index()
		if lec_idx != -1 and not Schedule.is_attended(lec_idx):
			var lec: Dictionary = Schedule.get_lecture(lec_idx)
			prompt_message = "[E] Attend %s (CGPA +0.15)" % String(lec["name"])
		else:
			prompt_message = "[E] Revise Notes (CGPA +0.05, 30m)"
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
			prompt_message = "[E] Study / Attend Lecture"
			object_name = "Lecture & Study Desk"
		ObjectType.CAFETERIA:
			prompt_message = "[E] Buy Meal (-₦500, +Hunger, 15m)"
			object_name = "Campus Buka / Cafe"
		ObjectType.FELLOWSHIP:
			prompt_message = "[E] Fellowship Chapel"
			object_name = "Chapel Altar"
		ObjectType.ATM:
			prompt_message = "[E] Withdraw Allowance (+₦2,000)"
			object_name = "Campus ATM"

	if label_3d:
		label_3d.text = object_name


func interact(player: CharacterBody3D) -> void:
	super.interact(player)
	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	match object_type:
		ObjectType.BED:
			var prev_day: int = TimeSystem.day
			TimeSystem.sleep_until(7)
			needs.energy = needs.max_energy
			needs.stat_changed.emit(&"energy", needs.energy, needs.max_energy)
			_show_feedback(player, "Slept well until 07:00! Full Energy restored.")

		ObjectType.DESK:
			if needs.energy < 15.0:
				_show_feedback(player, "Too exhausted to study! Go sleep in your hostel.")
				return

			var lec_idx: int = Schedule.get_current_lecture_index()
			if lec_idx != -1:
				if not Schedule.is_attended(lec_idx):
					Schedule.mark_attended(lec_idx)
					needs.modify_energy(-15.0)
					needs.modify_cgpa(0.15)
					TimeSystem.advance_minutes(60)
					var lec_name: String = String(Schedule.get_lecture(lec_idx)["name"])
					_show_feedback(player, "Attended %s! CGPA +0.15" % lec_name)
				else:
					needs.modify_energy(-8.0)
					needs.modify_cgpa(0.04)
					TimeSystem.advance_minutes(30)
					_show_feedback(player, "Already attended class! Revised notes (+0.04 CGPA)")
			else:
				needs.modify_energy(-8.0)
				needs.modify_cgpa(0.05)
				TimeSystem.advance_minutes(30)
				_show_feedback(player, "Self-study complete! CGPA +0.05 (30m spent)")

		ObjectType.CAFETERIA:
			if needs.modify_money(-500):
				needs.modify_hunger(40.0)
				TimeSystem.advance_minutes(15)
				_show_feedback(player, "Enjoyed warm cafeteria meal! Hunger +40, Paid ₦500")
			else:
				_show_feedback(player, "Sapa! Not enough money to buy food. Go to the ATM.")

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


func _show_feedback(player: CharacterBody3D, msg: String) -> void:
	if player.has_method("display_notification"):
		player.display_notification(msg)
