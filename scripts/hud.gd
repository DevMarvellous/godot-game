class_name HUD
extends CanvasLayer

## Displays player life-sim stats in real-time, plus clock and timetable schedule.

@onready var energy_bar: ProgressBar = %EnergyBar
@onready var hunger_bar: ProgressBar = %HungerBar
@onready var faith_bar: ProgressBar = %FaithBar
@onready var cgpa_label: Label = %CGPALabel
@onready var money_label: Label = %MoneyLabel
@onready var time_label: Label = %TimeLabel
@onready var schedule_banner: Label = %ScheduleBanner


func _ready() -> void:
	TimeSystem.minute_passed.connect(_update_time_display)
	_update_time_display()


func _update_time_display() -> void:
	if time_label:
		time_label.text = "%s  •  %s" % [TimeSystem.get_time_string(), TimeSystem.get_day_string()]
	if schedule_banner:
		schedule_banner.text = Schedule.get_next_event_text()


func connect_player_needs(needs: NeedsManager) -> void:
	needs.stat_changed.connect(_on_stat_changed)
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
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s
