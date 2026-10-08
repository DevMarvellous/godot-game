class_name SummaryMenu
extends Control

## Daily Report Card & Semester Final Results Modal.
## Automatically displays at the end of each day when sleeping.

signal summary_closed

@onready var title_label: Label = %TitleLabel
@onready var grade_label: Label = %GradeLabel
@onready var attended_label: Label = %AttendedLabel
@onready var missed_label: Label = %MissedLabel
@onready var faith_label: Label = %FaithLabel
@onready var wallet_label: Label = %WalletLabel
@onready var comment_label: Label = %CommentLabel
@onready var action_button: Button = %ActionButton

var is_final: bool = false


func _ready() -> void:
	visible = false
	if action_button:
		action_button.pressed.connect(_on_action_pressed)


func show_day_summary(data: Dictionary) -> void:
	visible = true
	is_final = bool(data.get("is_final_day", false))

	var day: int = int(data.get("day", 1))
	var total_days: int = int(data.get("total_days", 14))
	var cgpa: float = float(data.get("cgpa", 3.50))
	var grade: String = String(data.get("grade", "Second Class Upper"))
	var attended: int = int(data.get("attended", 0))
	var missed: int = int(data.get("missed", 0))
	var faith: float = float(data.get("faith", 70.0))
	var money: int = int(data.get("money", 5000))

	if title_label:
		if is_final:
			title_label.text = "🎓 SEMESTER FINAL RESULTS"
		else:
			title_label.text = "📋 DAY %d OF %d REPORT CARD" % [day, total_days]

	if grade_label:
		grade_label.text = "CGPA: %.2f  •  %s" % [cgpa, grade]

	if attended_label:
		attended_label.text = "Classes Attended: %d" % attended

	if missed_label:
		missed_label.text = "Classes Missed: %d" % missed

	if faith_label:
		faith_label.text = "Faith & Devotion: %d%%" % int(faith)

	if wallet_label:
		wallet_label.text = "Wallet Balance: ₦%s" % _format_number(money)

	if comment_label:
		if is_final:
			comment_label.text = "The semester is officially concluded! Check your final degree standing above."
		elif missed > 0:
			comment_label.text = "⚠ You missed %d lecture(s) today. Your CGPA took a hit! Wake up earlier tomorrow." % missed
		elif cgpa >= 4.50:
			comment_label.text = "🔥 First Class standing maintained! Keep attending lectures and revising notes."
		elif faith < 30.0:
			comment_label.text = "⚠ Your spiritual devotion is dipping low. Don't forget fellowship by 5pm."
		else:
			comment_label.text = "✓ Good day on campus. Rest well tonight for tomorrow's classes."

	if action_button:
		if is_final:
			action_button.text = "Finish Semester"
		else:
			action_button.text = "Start Day %d" % (day + 1)


func show_semester_results(result: Dictionary) -> void:
	visible = true
	is_final = true

	var title: String = String(result.get("title", "Semester Over"))
	var desc: String = String(result.get("description", ""))
	var cgpa: float = float(result.get("cgpa", 3.50))

	if title_label:
		title_label.text = "🎓 FINAL DEGREE OUTCOME"

	if grade_label:
		grade_label.text = title

	if comment_label:
		comment_label.text = desc

	if action_button:
		action_button.text = "Restart Semester"


func _on_action_pressed() -> void:
	if is_final:
		# Restart current scene cleanly
		get_tree().reload_current_scene()
	else:
		visible = false
		summary_closed.emit()


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s

