extends Node

## Global game clock (autoload name: TimeSystem).
## 1 real second = `game_minutes_per_second` in-game minutes.
## Everything time-based (stat decay, lectures, day/night) listens to these signals.

signal minute_passed
signal hour_changed(hour: int)
signal day_started(day: int)
signal slept(hours_slept: int)

const MINUTES_PER_DAY: int = 1440
const WEEKDAY_NAMES: PackedStringArray = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

## 2.0 means a full 24-hour day takes 12 real minutes.
@export var game_minutes_per_second: float = 2.0

var day: int = 1
var minute_of_day: int = 7 * 60 # Game starts at 07:00 on Day 1 (Monday)
var paused: bool = false

var _accumulator: float = 0.0


func _process(delta: float) -> void:
	if paused:
		return
	_accumulator += delta * game_minutes_per_second
	while _accumulator >= 1.0:
		_accumulator -= 1.0
		_tick_minute()


func _tick_minute() -> void:
	var old_hour: int = get_hour()
	minute_of_day += 1
	if minute_of_day >= MINUTES_PER_DAY:
		minute_of_day = 0
		day += 1
		day_started.emit(day)
	minute_passed.emit()
	if get_hour() != old_hour:
		hour_changed.emit(get_hour())


## Skips time forward minute by minute, so decay and missed-lecture checks still fire.
func advance_minutes(amount: int) -> void:
	for i: int in amount:
		_tick_minute()


## Skips to the next occurrence of `target_hour`:00.
func sleep_until(target_hour: int) -> void:
	var target: int = target_hour * 60
	var diff: int = target - minute_of_day
	if diff <= 0:
		diff += MINUTES_PER_DAY
	advance_minutes(diff)
	slept.emit(diff / 60)


func get_hour() -> int:
	return minute_of_day / 60


func get_minute() -> int:
	return minute_of_day % 60


func get_hour_float() -> float:
	return float(minute_of_day) / 60.0


func get_weekday_index() -> int:
	return (day - 1) % 7


func get_week_index() -> int:
	return (day - 1) / 7


func is_weekend() -> bool:
	return get_weekday_index() >= 5


func is_night() -> bool:
	var h: int = get_hour()
	return h >= 21 or h < 6


func get_time_string() -> String:
	return "%02d:%02d" % [get_hour(), get_minute()]


func get_day_string() -> String:
	return "Day %d (%s)" % [day, WEEKDAY_NAMES[get_weekday_index()]]

