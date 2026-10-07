class_name Interactable
extends Area2D

## Base class for objects the player can walk up to and interact with.

signal interacted(player: CharacterBody2D)

@export var prompt_message: String = "Press [E] to interact"
@export var object_name: String = "Interactable"

var is_player_nearby: bool = false
var current_player: CharacterBody2D = null


func _ready() -> void:
	collision_layer = 2 # Interaction Layer
	collision_mask = 1  # Player Layer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		is_player_nearby = true
		current_player = body as CharacterBody2D
		if current_player.has_method("set_interaction_target"):
			current_player.set_interaction_target(self)


func _on_body_exited(body: Node2D) -> void:
	if body == current_player:
		if current_player.has_method("clear_interaction_target"):
			current_player.clear_interaction_target(self)
		is_player_nearby = false
		current_player = null


func interact(player: CharacterBody2D) -> void:
	interacted.emit(player)

