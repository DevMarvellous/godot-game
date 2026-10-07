class_name HUD
extends CanvasLayer

## Displays player life-sim stats in real-time.

@onready var energy_bar: ProgressBar = %EnergyBar
@onready var hunger_bar: ProgressBar = %HungerBar
@onready var faith_bar: ProgressBar = %FaithBar
@onready var cgpa_label: Label = %CGPALabel
@onready var money_label: Label = %MoneyLabel


func connect_player_needs(needs: NeedsManager) -> void:
	needs.stat_changed.connect(_on_stat_changed)
	# Trigger initial refresh
	needs.emit_all_stats()


func _on_stat_changed(stat_name: StringName, current_value: float, max_value: float) -> void:
	match stat_name:
		&"energy":
			if energy_bar:
				energy_bar.max_value = max_value
				energy_bar.value = current_value
		&"hunger":
			if hunger_bar:
				hunger_bar.max_value = max_value
				hunger_bar.value = current_value
		&"faith":
			if faith_bar:
				faith_bar.max_value = max_value
				faith_bar.value = current_value
		&"cgpa":
			if cgpa_label:
				cgpa_label.text = "CGPA: %.2f / 5.0" % current_value
		&"money":
			if money_label:
				money_label.text = "Wallet: ₦%s" % _format_number(int(current_value))


func _format_number(n: int) -> String:
	# Format thousands separator e.g. 5,000
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s

