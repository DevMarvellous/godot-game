class_name NeedsManager
extends Node

## Manages player life-sim stats: Energy, Hunger, Money, CGPA, Faith.
## Emits signals whenever any stat changes so the UI can update automatically.

signal stat_changed(stat_name: StringName, current_value: float, max_value: float)
signal need_depleted(stat_name: StringName)
signal player_passed_out(reason: String)

@export var max_energy: float = 100.0
@export var max_hunger: float = 100.0
@export var max_faith: float = 100.0
@export var max_cgpa: float = 5.0

var energy: float = 100.0
var hunger: float = 100.0
var faith: float = 70.0
var cgpa: float = 3.50
var money: int = 5000 # Starting allowance in Naira (₦)

# Decay per in-game minute. 16 waking hours ≈ -48 energy, -77 hunger.
@export var energy_decay_per_minute: float = 0.05
@export var hunger_decay_per_minute: float = 0.08
@export var faith_decay_per_minute: float = 0.01

var is_handling_passout: bool = false


func _ready() -> void:
	TimeSystem.minute_passed.connect(_on_minute_passed)
	Schedule.lecture_missed.connect(_on_lecture_missed)
	emit_all_stats()


func _on_minute_passed() -> void:
	if is_handling_passout:
		return

	# Hunger stat represents fullness, so it goes down over time.
	modify_energy(-energy_decay_per_minute)
	modify_hunger(-hunger_decay_per_minute)
	modify_faith(-faith_decay_per_minute)

	# Late night collapse: if awake at 02:00 AM or energy hits 0, collapse from exhaustion
	if TimeSystem.get_hour() == 2 and TimeSystem.get_minute() == 0:
		_trigger_passout("Stayed up past 02:00 AM! Passed out from exhaustion.")
	elif energy <= 0.0:
		_trigger_passout("Out of energy! Collapsed from burnout.")


func _on_lecture_missed(lecture_name: String) -> void:
	if is_handling_passout:
		return
	modify_cgpa(-0.10)
	var player: Node = get_parent()
	if player and player.is_inside_tree() and player.has_method("display_notification"):
		player.display_notification("MISSED %s! CGPA -0.10" % lecture_name)


func _trigger_passout(reason: String) -> void:
	if is_handling_passout:
		return
	is_handling_passout = true

	# Teleport / wake up at 08:00 AM in Hostel Bed with penalty
	TimeSystem.sleep_until(8)
	energy = 45.0
	modify_hunger(-20.0)
	emit_all_stats()
	is_handling_passout = false

	player_passed_out.emit(reason)

	var player: Node = get_parent()
	if player and player.is_inside_tree() and player.has_method("display_notification"):
		player.display_notification(reason)

	player_passed_out.emit(reason)


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
