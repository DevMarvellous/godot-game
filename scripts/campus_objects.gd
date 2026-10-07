class_name CampusObject
extends Interactable

## Implements interactions for specific campus fixtures:
## Bed, Desk, Cafeteria, Fellowship Chapel, ATM Allowance.

enum ObjectType { BED, DESK, CAFETERIA, FELLOWSHIP, ATM }

@export var object_type: ObjectType = ObjectType.BED
@export var sound_feedback: String = ""


func _ready() -> void:
	super._ready()
	_update_prompt_from_type()


func _update_prompt_from_type() -> void:
	match object_type:
		ObjectType.BED:
			prompt_message = "[E] Sleep (Restores Energy)"
			object_name = "Hostel Bed"
		ObjectType.DESK:
			prompt_message = "[E] Study (Boosts CGPA, costs Energy)"
			object_name = "Study Desk"
		ObjectType.CAFETERIA:
			prompt_message = "[E] Buy Rice & Chicken (-₦500, +Hunger)"
			object_name = "Campus Cafeteria"
		ObjectType.FELLOWSHIP:
			prompt_message = "[E] Fellowship & Prayer (+Faith)"
			object_name = "Chapel Fellowship"
		ObjectType.ATM:
			prompt_message = "[E] Withdraw Weekly Allowance (+₦2,000)"
			object_name = "Campus ATM"


func interact(player: CharacterBody2D) -> void:
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
				_show_feedback(player, "Delicious meal! Hunger +40, Paid ₦500")
			else:
				_show_feedback(player, "Sapa! Not enough money to buy food.")

		ObjectType.FELLOWSHIP:
			needs.modify_faith(25.0)
			needs.modify_energy(5.0)
			_show_feedback(player, "Felt refreshed in spirit! Faith +25")

		ObjectType.ATM:
			needs.modify_money(2000)
			_show_feedback(player, "Allowance received! +₦2,000")


func _show_feedback(player: CharacterBody2D, msg: String) -> void:
	if player.has_method("display_notification"):
		player.display_notification(msg)

