class_name NPCInteractable
extends Interactable3D

## Interaction bridge for NPC conversations.

func _ready() -> void:
	super._ready()
	var npc: Node = get_parent()
	if npc:
		var n_name: String = String(npc.get("character_name")) if "character_name" in npc else "Student"
		prompt_message = "[E] Talk to %s" % n_name
		object_name = n_name


func interact(player: CharacterBody3D) -> void:
	super.interact(player)
	var npc: Node = get_parent()
	if npc and npc.has_method("talk"):
		npc.talk()
