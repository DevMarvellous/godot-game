extends Node

## Manages semester progression, academic grading, and win/loss conditions.
## Fully editable: You can change semester length, grade cutoffs, and target requirements.

signal day_ended(summary_data: Dictionary)
signal semester_finished(final_results: Dictionary)

@export var total_semester_days: int = 14
@export var min_cgpa_probation: float = 1.50
@export var first_class_cutoff: float = 4.50
@export var second_upper_cutoff: float = 3.50
@export var second_lower_cutoff: float = 2.40

# Daily tracking records
var daily_classes_attended: int = 0
var daily_classes_missed: int = 0


func _ready() -> void:
	if Schedule:
		Schedule.lecture_attended.connect(_on_lecture_attended)
		Schedule.lecture_missed.connect(_on_lecture_missed)
	if TimeSystem:
		TimeSystem.day_started.connect(_on_day_started)


func _on_lecture_attended(_name: String) -> void:
	daily_classes_attended += 1


func _on_lecture_missed(_name: String) -> void:
	daily_classes_missed += 1


func _on_day_started(new_day: int) -> void:
	# Trigger daily summary for the day that just concluded
	var completed_day: int = new_day - 1
	if completed_day >= 1:
		trigger_day_summary(completed_day)

	# Reset daily counters
	daily_classes_attended = 0
	daily_classes_missed = 0


func trigger_day_summary(day_number: int) -> void:
	var needs: NeedsManager = _get_player_needs()
	var cgpa: float = needs.cgpa if needs else 3.50
	var faith: float = needs.faith if needs else 70.0
	var money: int = needs.money if needs else 5000
	var _energy: float = needs.energy if needs else 100.0

	var grade_title: String = get_grade_classification(cgpa)

	var summary: Dictionary = {
		"day": day_number,
		"total_days": total_semester_days,
		"cgpa": cgpa,
		"grade": grade_title,
		"faith": faith,
		"money": money,
		"attended": daily_classes_attended,
		"missed": daily_classes_missed,
		"is_final_day": day_number >= total_semester_days
	}

	day_ended.emit(summary)

	if day_number >= total_semester_days:
		_evaluate_semester_outcome(summary)


func _evaluate_semester_outcome(summary: Dictionary) -> void:
	var cgpa: float = float(summary["cgpa"])
	var faith: float = float(summary["faith"])
	var money: int = int(summary["money"])

	var title: String = ""
	var status: String = "" # "VICTORY", "PASS", "DEFEAT"
	var description: String = ""

	if cgpa >= first_class_cutoff and faith >= 60.0:
		status = "VICTORY"
		title = "FIRST CLASS HONOURS & SPIRITUAL GIANT"
		description = "You conquered the semester with academic brilliance and unwavering devotion! Your name is on the Vice Chancellor's Honours Roll."
	elif cgpa >= second_upper_cutoff:
		status = "VICTORY"
		title = "SECOND CLASS UPPER (2:1) GRADUATE"
		description = "Solid achievement! You balanced tests, fellowship, and campus life with excellence."
	elif cgpa >= second_lower_cutoff:
		status = "PASS"
		title = "SECOND CLASS LOWER (2:2) - YOU SURVIVED"
		description = "Campus wasn't easy, but you crossed the finish line intact. More reading required next semester!"
	elif cgpa < min_cgpa_probation:
		status = "DEFEAT"
		title = "ACADEMIC PROBATION / ADVICE TO WITHDRAW"
		description = "Your CGPA plunged below the required standard. Skipping classes and late-night cramming caught up with you."
	else:
		status = "PASS"
		title = "THIRD CLASS COMPLETION"
		description = "You scraped through by the whiskers. Time to buckle down!"

	var result: Dictionary = {
		"status": status,
		"title": title,
		"description": description,
		"cgpa": cgpa,
		"faith": faith,
		"money": money
	}

	semester_finished.emit(result)


func get_grade_classification(cgpa: float) -> String:
	if cgpa >= first_class_cutoff:
		return "First Class (1st)"
	elif cgpa >= second_upper_cutoff:
		return "Second Class Upper (2:1)"
	elif cgpa >= second_lower_cutoff:
		return "Second Class Lower (2:2)"
	elif cgpa >= min_cgpa_probation:
		return "Third Class (3rd)"
	else:
		return "Probation Risk (< 1.50)"


func _get_player_needs() -> NeedsManager:
	var tree: SceneTree = get_tree()
	if not tree or not tree.current_scene:
		return null
	var player: Node = tree.current_scene.get_node_or_null("Player3D")
	if player:
		return player.get_node_or_null("NeedsManager") as NeedsManager
	return null

