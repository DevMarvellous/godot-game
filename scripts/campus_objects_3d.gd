class_name CampusObject3D
extends Interactable3D

## 3D campus fixtures: Bed, Study Desk, Cafeteria Counter, Chapel Altar, ATM.

enum ObjectType { BED, DESK, CAFETERIA, FELLOWSHIP, ATM }

@export var object_type: ObjectType = ObjectType.BED

@onready var label_3d: Label3D = $Label3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	super._ready()
	update_object_display()


func update_object_display() -> void:
	match object_type:
		ObjectType.BED:
			prompt_message = "[E] Sleep (Restores Energy)"
			object_name = "Hostel Bed"
		ObjectType.DESK:
			prompt_message = "[E] Study (Boosts CGPA, costs Energy)"
			object_name = "Study Desk"
		ObjectType.CAFETERIA:
			prompt_message = "[E] Buy Meal (-₦500, +Hunger)"
			object_name = "Campus Buka / Cafe"
		ObjectType.FELLOWSHIP:
			prompt_message = "[E] Pray & Fellowship (+Faith)"
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
			needs.modify_energy(35.0)
			_show_feedback(player, "Rested well! Energy +35")

		ObjectType.DESK:
			if needs.energy < 10.0:
				_show_feedback(player, "Too exhausted to read! Go sleep first.")
			else:
				needs.modify_energy(-10.0)
				needs.modify_cgpa(0.08)
				_show_feedback(player, "Studied hard! CGPA +0.08, Energy -10")

		ObjectType.CAFETERIA:
			if needs.modify_money(-500):
				needs.modify_hunger(40.0)
				_show_feedback(player, "Delicious food! Hunger +40, Paid ₦500")
			else:
				_show_feedback(player, "Sapa! Not enough money to buy food.")

		ObjectType.FELLOWSHIP:
			needs.modify_faith(25.0)
			needs.modify_energy(5.0)
			_show_feedback(player, "Refreshed in spirit! Faith +25")

		ObjectType.ATM:
			needs.modify_money(2000)
			_show_feedback(player, "Allowance received! +₦2,000")


func _show_feedback(player: CharacterBody3D, msg: String) -> void:
	if player.has_method("display_notification"):
		player.display_notification(msg)

