class_name DialogueMenu
extends Control

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")
const NpcDialogueSystem = preload("res://scripts/data/dialogue_system.gd")
const Relationship = preload("res://scripts/data/relationship_system.gd")

## Interactive Branching Dialogue Modal for NPC conversations.
## Features realistic character responses, relationship feedback, and stats impacts.

signal dialogue_ended

@onready var npc_name_label: Label = %NPCNameLabel
@onready var npc_role_label: Label = %NPCRoleLabel
@onready var rel_label: Label = %RelationshipLabel
@onready var speech_text: Label = %SpeechText
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var response_panel: PanelContainer = %ResponsePanel
@onready var response_text: Label = %ResponseText
@onready var close_btn: Button = %CloseBtn
@onready var finish_btn: Button = %FinishBtn

var current_player: CharacterBody3D = null
var current_npc: String = ""
var current_tree: Dictionary = {}


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_dialogue)
	if finish_btn:
		finish_btn.pressed.connect(close_dialogue)


func open_dialogue(player: CharacterBody3D, npc_name: String, npc_role: String) -> void:
	current_player = player
	current_npc = npc_name
	visible = true

	if npc_name_label:
		npc_name_label.text = npc_name
	if npc_role_label:
		npc_role_label.text = "[ %s ]" % npc_role

	if rel_label:
		var aff: int = Relationship.get_affinity(npc_name)
		var tier: String = Relationship.get_tier_name(aff)
		var perk: String = Relationship.get_perk_description(npc_name)
		rel_label.text = "Friendship: %d/100 (%s)\n%s" % [aff, tier, perk]

	if response_panel:
		response_panel.visible = false

	current_tree = NpcDialogueSystem.get_dialogue(npc_name)
	if speech_text:
		speech_text.text = "\"%s\"" % String(current_tree.get("greeting", "Hello!"))

	_populate_choices()


func _populate_choices() -> void:
	for child: Node in options_container.get_children():
		child.queue_free()

	var choices: Array = current_tree.get("choices", [])
	for i: int in choices.size():
		var choice: Dictionary = choices[i]
		var btn: Button = Button.new()
		btn.text = "💬 %s" % String(choice["text"])
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override(&"font_size", 16)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_choice_selected.bind(choice))
		options_container.add_child(btn)


func _on_choice_selected(choice: Dictionary) -> void:
	# Disable choice buttons
	for child: Node in options_container.get_children():
		if child is Button:
			child.disabled = true

	var reply: String = String(choice.get("response", "..."))
	if response_panel and response_text:
		response_panel.visible = true
		response_text.text = "\"%s\"" % reply

	# Apply stats boosts
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			var cgpa_gain: float = float(choice.get("cgpa_boost", 0.0))
			var faith_gain: float = float(choice.get("faith_boost", 0.0))
			var money_gain: int = int(choice.get("money_change", 0))

			if cgpa_gain != 0.0:
				needs.modify_cgpa(cgpa_gain)
			if faith_gain != 0.0:
				needs.modify_faith(faith_gain)
			if money_gain != 0:
				needs.modify_money(money_gain)
				if SoundManager:
					SoundManager.play_coin()

			TimeSystem.advance_minutes(10)

	# Boost relationship affinity
	var new_aff: int = Relationship.modify_affinity(current_npc, 8)
	var new_tier: String = Relationship.get_tier_name(new_aff)
	var new_perk: String = Relationship.get_perk_description(current_npc)
	if rel_label:
		rel_label.text = "Friendship: %d/100 (%s)  [+8]\n%s" % [new_aff, new_tier, new_perk]

	if SoundManager:
		SoundManager.play_click()


func close_dialogue() -> void:
	visible = false
	current_player = null
	dialogue_ended.emit()

