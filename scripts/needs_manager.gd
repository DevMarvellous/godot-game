class_name NeedsManager
extends Node

## Manages player life-sim stats: Energy, Hunger, Money, CGPA, Faith.
## Emits signals whenever any stat changes so the UI can update automatically.

signal stat_changed(stat_name: StringName, current_value: float, max_value: float)
signal need_depleted(stat_name: StringName)

@export var max_energy: float = 100.0
@export var max_hunger: float = 100.0
@export var max_faith: float = 100.0
@export var max_cgpa: float = 5.0

var energy: float = 100.0
var hunger: float = 100.0
var faith: float = 70.0
var cgpa: float = 3.50
var money: int = 5000 # Starting allowance in Naira (₦)

# Passive decay timer
var decay_timer: float = 0.0
@export var decay_interval: float = 3.0 # Every 3 seconds stats decay slightly


func _ready() -> void:
	emit_all_stats()


func _process(delta: float) -> void:
	decay_timer += delta
	if decay_timer >= decay_interval:
		decay_timer = 0.0
		# Energy slowly drains, hunger increases (hunger stat represents fullness)
		modify_energy(-0.5)
		modify_hunger(-1.0)


func emit_all_stats() -> void:
	stat_changed.emit(&"energy", energy, max_energy)
	stat_changed.emit(&"hunger", hunger, max_hunger)
	stat_changed.emit(&"faith", faith, max_faith)
	stat_changed.emit(&"cgpa", cgpa, max_cgpa)
	stat_changed.emit(&"money", float(money), 0.0)


func modify_energy(amount: float) -> void:
	energy = clampf(energy + amount, 0.0, max_energy)
	stat_changed.emit(&"energy", energy, max_energy)
	if energy <= 0.0:
		need_depleted.emit(&"energy")


func modify_hunger(amount: float) -> void:
	hunger = clampf(hunger + amount, 0.0, max_hunger)
	stat_changed.emit(&"hunger", hunger, max_hunger)
	if hunger <= 0.0:
		need_depleted.emit(&"hunger")


func modify_faith(amount: float) -> void:
	faith = clampf(faith + amount, 0.0, max_faith)
	stat_changed.emit(&"faith", faith, max_faith)


func modify_cgpa(amount: float) -> void:
	cgpa = clampf(cgpa + amount, 0.0, max_cgpa)
	stat_changed.emit(&"cgpa", cgpa, max_cgpa)


func modify_money(amount: int) -> bool:
	if amount < 0 and money + amount < 0:
		return false # Cannot afford
	money += amount
	stat_changed.emit(&"money", float(money), 0.0)
	return true

