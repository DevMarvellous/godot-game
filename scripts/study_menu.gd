class_name StudyMenu
extends Control

## Interactive Study & Lecture Choices Modal.
## Fully editable options for revision, group study, and lecture attendance.

signal study_completed(activity_name: String, cgpa_gain: float, energy_cost: float)
signal menu_closed

@export var study_options: Array[Dictionary] = [
	{
		"name": "Quick Notes Revision",
		"desc": "Glance over course slides and handouts.",
		"time_minutes": 30,
		"energy_cost": 8.0,
		"cgpa_gain": 0.05
	},
	{
		"name": "Past Questions Practice",
		"desc": "Solve 5 years of exam past questions with course mates.",
		"time_minutes": 60,
		"energy_cost": 16.0,
		"cgpa_gain": 0.12
	},
	{
		"name": "Overnight Reading Marathon",
		"desc": "Intense library focus session. Requires serious stamina.",
		"time_minutes": 120,
		"energy_cost": 28.0,
		"cgpa_gain": 0.22
	}
]

@onready var options_container: VBoxContainer = %OptionsContainer
@onready var lecture_box: PanelContainer = %LectureBox
@onready var lecture_title: Label = %LectureTitle
@onready var lecture_btn: Button = %LectureBtn
@onready var status_label: Label = %StatusLabel
@onready var close_button: Button = %CloseButton

var current_player: CharacterBody3D = null


func _ready() -> void:
	visible = false
	if close_button:
		close_button.pressed.connect(close_menu)
	if lecture_btn:
		lecture_btn.pressed.connect(_on_attend_lecture_pressed)


func open_menu(player: CharacterBody3D) -> void:
	current_player = player
	visible = true
	_refresh_display()


func close_menu() -> void:
	visible = false
	current_player = null
	menu_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func _refresh_display() -> void:
	if not current_player:
		return

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	var cgpa: float = needs.cgpa if needs else 0.0
	var energy: float = needs.energy if needs else 0.0

	if status_label:
		status_label.text = "Current CGPA: %.2f / 5.0  •  Energy: %d%%" % [cgpa, int(energy)]

	# Handle scheduled lecture section
	var lec_idx: int = Schedule.get_current_lecture_index()
	if lec_idx != -1:
		var lec: Dictionary = Schedule.get_lecture(lec_idx)
		var lec_name: String = String(lec["name"])
		lecture_box.visible = true

		if Schedule.is_attended(lec_idx):
			lecture_title.text = "✓ %s (Already Attended)" % lec_name
			lecture_btn.disabled = true
			lecture_btn.text = "Attended"
		elif energy < 15.0:
			lecture_title.text = "⚠ %s (Too exhausted!)" % lec_name
			lecture_btn.disabled = true
			lecture_btn.text = "Need Energy"
		else:
			lecture_title.text = "CLASS IN SESSION: %s" % lec_name
			lecture_btn.disabled = false
			lecture_btn.text = "Attend Class (CGPA +0.15)"
	else:
		lecture_box.visible = false

	# Populate self-study options
	for child: Node in options_container.get_children():
		child.queue_free()

	for opt: Dictionary in study_options:
		var card: PanelContainer = _create_study_card(opt, energy)
		options_container.add_child(card)


func _create_study_card(opt: Dictionary, player_energy: float) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.17, 0.22, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override(&"panel", style)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.theme_override_constants.separation = 12
	panel.add_child(hbox)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var name_lbl: Label = Label.new()
	name_lbl.text = String(opt["name"])
	name_lbl.add_theme_font_size_override(&"font_size", 15)
	name_lbl.add_theme_color_override(&"font_color", Color(0.4, 0.8, 1.0))
	vbox.add_child(name_lbl)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = "%s  •  (+%.2f CGPA, %dm, -%d Energy)" % [String(opt["desc"]), float(opt["cgpa_gain"]), int(opt["time_minutes"]), int(opt["energy_cost"])]
	desc_lbl.add_theme_font_size_override(&"font_size", 12)
	desc_lbl.add_theme_color_override(&"font_color", Color(0.75, 0.8, 0.85))
	vbox.add_child(desc_lbl)

	var btn: Button = Button.new()
	var energy_needed: float = float(opt["energy_cost"])
	btn.text = "Study"
	btn.custom_minimum_size = Vector2(95, 36)

	if player_energy < energy_needed:
		btn.disabled = true
		btn.text = "Tired"
	else:
		btn.pressed.connect(_on_study_selected.bind(opt))

	hbox.add_child(btn)
	return panel


func _on_attend_lecture_pressed() -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var lec_idx: int = Schedule.get_current_lecture_index()
	if lec_idx != -1 and not Schedule.is_attended(lec_idx):
		Schedule.mark_attended(lec_idx)
		needs.modify_energy(-15.0)
		needs.modify_cgpa(0.15)
		TimeSystem.advance_minutes(60)

		var lec_name: String = String(Schedule.get_lecture(lec_idx)["name"])
		if current_player.has_method("display_notification"):
			current_player.display_notification("Attended %s! CGPA +0.15" % lec_name)

		_refresh_display()
		study_completed.emit(lec_name, 0.15, 15.0)


func _on_study_selected(opt: Dictionary) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var energy_cost: float = float(opt["energy_cost"])
	var cgpa_gain: float = float(opt["cgpa_gain"])
	var minutes: int = int(opt["time_minutes"])

	needs.modify_energy(-energy_cost)
	needs.modify_cgpa(cgpa_gain)
	TimeSystem.advance_minutes(minutes)

	if current_player.has_method("display_notification"):
		current_player.display_notification("Completed %s! CGPA +%.2f" % [String(opt["name"]), cgpa_gain])

	_refresh_display()
	study_completed.emit(String(opt["name"]), cgpa_gain, energy_cost)

