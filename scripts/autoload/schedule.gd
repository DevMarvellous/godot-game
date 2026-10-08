extends Node

## Campus timetable (autoload name: Schedule).
## Knows when lectures and fellowship happen, and whether the player attended.

signal lecture_started(lecture_name: String)
signal lecture_attended(lecture_name: String)
signal lecture_missed(lecture_name: String)

## Lectures run Monday-Friday only. Times are minutes from midnight.
const LECTURES: Array = [
	{"name": "GST 101 Lecture", "start": 9 * 60, "end": 11 * 60},
	{"name": "Lab Practical", "start": 14 * 60, "end": 16 * 60},
]
const FELLOWSHIP_START: int = 17 * 60
const FELLOWSHIP_END: int = 19 * 60
const CURFEW_HOUR: int = 22

var _attended: Dictionary = {} # "day:index" -> true


func _ready() -> void:
	TimeSystem.minute_passed.connect(_on_minute_passed)


func _on_minute_passed() -> void:
	if TimeSystem.is_weekend():
		return
	var m: int = TimeSystem.minute_of_day
	for i: int in LECTURES.size():
		var lec: Dictionary = LECTURES[i]
		if m == int(lec["start"]):
			lecture_started.emit(String(lec["name"]))
		elif m == int(lec["end"]) and not _attended.has(_key(i)):
			lecture_missed.emit(String(lec["name"]))


## Returns the index of the lecture happening right now, or -1.
func get_current_lecture_index() -> int:
	if TimeSystem.is_weekend():
		return -1
	var m: int = TimeSystem.minute_of_day
	for i: int in LECTURES.size():
		var lec: Dictionary = LECTURES[i]
		if m >= int(lec["start"]) and m < int(lec["end"]):
			return i
	return -1


func get_lecture(index: int) -> Dictionary:
	return LECTURES[index]


func is_attended(index: int) -> bool:
	return _attended.has(_key(index))


func mark_attended(index: int) -> void:
	_attended[_key(index)] = true
	lecture_attended.emit(String(LECTURES[index]["name"]))


func is_fellowship_time() -> bool:
	var m: int = TimeSystem.minute_of_day
	return m >= FELLOWSHIP_START and m < FELLOWSHIP_END


## Short text for the HUD describing what is happening now or next.
func get_next_event_text() -> String:
	var m: int = TimeSystem.minute_of_day
	if not TimeSystem.is_weekend():
		for i: int in LECTURES.size():
			var lec: Dictionary = LECTURES[i]
			var start: int = int(lec["start"])
			var end: int = int(lec["end"])
			if m >= start and m < end:
				var status: String = "attended" if is_attended(i) else "GO NOW"
				return "NOW: %s until %s (%s)" % [lec["name"], _fmt(end), status]
			if m < start:
				return "Next: %s at %s" % [lec["name"], _fmt(start)]
	if m < FELLOWSHIP_START:
		return "Next: Fellowship at %s" % _fmt(FELLOWSHIP_START)
	if m < FELLOWSHIP_END:
		return "NOW: Fellowship until %s (bonus Faith)" % _fmt(FELLOWSHIP_END)
	if TimeSystem.get_hour() < CURFEW_HOUR:
		return "Curfew at %02d:00 - sleep to end the day" % CURFEW_HOUR
	return "Late! Sleep or you'll pass out at 02:00"


func _key(index: int) -> String:
	return "%d:%d" % [TimeSystem.day, index]


func _fmt(minutes: int) -> String:
	return "%02d:%02d" % [floori(float(minutes) / 60.0), minutes % 60]

