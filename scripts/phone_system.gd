class_name PhoneSystem
extends Control

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")

## In-Game Smartphone (Campus Connect).
## 6 Essential Apps:
## 1. Profile / ID (Matric No, Department, Level, Avatar)
## 2. Timetable (Daily lectures & fellowship schedule)
## 3. Results Portal (Semester CGPA, Course CA + Exam breakdown)
## 4. WhatsApp Hostel Gist (Chat with coursemates & lecturers)
## 5. Bank / OPay App (Wallet, transfers, Urgent 2k home)
## 6. Campus Hustle (Typing gigs, design jobs, provision sales)

signal phone_closed
signal hustle_performed(payout: int, message: String)

@onready var close_btn: Button = %ClosePhoneBtn
@onready var app_grid: GridContainer = %AppGrid
@onready var app_content: PanelContainer = %AppContent
@onready var app_title: Label = %AppTitleLabel
@onready var back_btn: Button = %BackBtn
@onready var content_label: Label = %ContentLabel
@onready var action_btn: Button = %AppActionBtn

var current_player: CharacterBody3D = null
var current_app_id: String = ""


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_phone)
	if back_btn:
		back_btn.pressed.connect(_show_home_screen)
	if action_btn:
		action_btn.pressed.connect(_on_app_action_pressed)

	_wire_app_btn(%IDCardAppBtn, "id_card")
	_wire_app_btn(%TimetableAppBtn, "timetable")
	_wire_app_btn(%ResultsAppBtn, "results")
	_wire_app_btn(%ChatAppBtn, "chat")
	_wire_app_btn(%BankAppBtn, "bank")
	_wire_app_btn(%HustleAppBtn, "hustle")


func _wire_app_btn(btn: Button, app_id: String) -> void:
	if btn:
		btn.pressed.connect(_open_app.bind(app_id))


func open_phone(p: CharacterBody3D) -> void:
	current_player = p
	visible = true
	_show_home_screen()


func close_phone() -> void:
	visible = false
	current_player = null
	phone_closed.emit()


func _show_home_screen() -> void:
	if app_grid:
		app_grid.visible = true
	if app_content:
		app_content.visible = false
	if back_btn:
		back_btn.visible = false
	if app_title:
		app_title.text = "📱 CAMPUS CONNECT"


func _open_app(app_id: String) -> void:
	current_app_id = app_id
	if app_grid:
		app_grid.visible = false
	if app_content:
		app_content.visible = true
	if back_btn:
		back_btn.visible = true

	match app_id:
		"id_card":
			app_title.text = "🪪 STUDENT ID CARD"
			const StudentProfile = preload("res://scripts/data/student_profile.gd")
			StudentProfile.load_from_disk()
			content_label.text = "NAME: %s\nEMAIL: %s\nMATRIC: %s\nPROGRAM: %s\nFACULTY: %s\nLEVEL: 100 Level (Fresher)\nADMISSION: %s\nSTATUS: Registered Undergraduate" % [
				StudentProfile.student_name,
				StudentProfile.student_email,
				StudentProfile.matric_no,
				StudentProfile.admitted_course_title,
				StudentProfile.admitted_faculty,
				StudentProfile.admission_remark
			]
			action_btn.visible = false

		"timetable":
			app_title.text = "📅 LECTURE TIMETABLE"
			content_label.text = "MONDAY - FRIDAY:\n• 09:00 - 11:00: GST 101 Lecture (LT1)\n• 11:30 - 13:00: CSC 101 Lecture & Lab\n• 14:00 - 16:00: MTH 101 Calculus (LT2)\n• 17:00 - 19:00: Fellowship (Chapel)\n• 22:00: Hostel Curfew"
			action_btn.visible = false

		"results":
			app_title.text = "📊 RESULTS & CGPA PORTAL"
			var cgpa: float = 3.50
			if current_player:
				var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					cgpa = needs.cgpa
			content_label.text = "CUMULATIVE GPA: %.2f / 5.00\nCLASS: %s\nTOTAL UNITS ENROLLED: 18\nPROBATION STATUS: CLEAR (GOOD STANDING)\nEXAM CLEARANCE: APPROVED" % [cgpa, _get_class_text(cgpa)]
			action_btn.visible = false

		"chat":
			app_title.text = "💬 CAMPUS WHATSAPP GIST"
			content_label.text = "DEPARTMENTAL GROUP CHAT:\n• Emeka (Course Rep): 'Assignment due 8am tomorrow!'\n• Tobi (400L): 'Anyone selling past questions?'\n• Sister Blessing: 'Fellowship choir practice at 5pm.'\n• Dr. Adebayo: 'Read chapter 4 before next lecture.'"
			action_btn.visible = false

		"bank":
			app_title.text = "🏦 OPAY / CAMPUS WALLET"
			var wallet: int = 5000
			if current_player:
				var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					wallet = needs.money
			content_label.text = "ACCOUNT BALANCE: ₦%s\nACCOUNT NUMBER: 0812345678\nBANK: Campus Microfinance Bank\n\nNeed pocket money? Request Urgent 2k from family!" % _format_number(wallet)
			action_btn.visible = true
			action_btn.text = "Request Urgent 2k from Home"

		"hustle":
			app_title.text = "💼 STUDENT HUSTLE HUB"
			content_label.text = "AVAILABLE CAMPUS GIGS:\n1. SUB Business Centre Typing (+₦2,500)\n2. Fellowship Flyer Design (+₦4,500)\n3. Hostel Provision Sales (+₦1,800)\n\nEarn money between lectures to survive sapa!"
			action_btn.visible = true
			action_btn.text = "Work Assignment Typing (+₦2,500)"


func _on_app_action_pressed() -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if current_app_id == "bank":
		# Urgent 2k call home
		if needs.cgpa >= 2.50:
			needs.modify_money(2500)
			TimeSystem.advance_minutes(15)
			if SoundManager:
				SoundManager.play_coin()
			content_label.text = "✓ SUCCESS! Parents credited your account with ₦2,500!\n'Read your books and make us proud!'"
			action_btn.disabled = true
			hustle_performed.emit(2500, "Received ₦2,500 allowance from home!")
		else:
			if SoundManager:
				SoundManager.play_alert()
			content_label.text = "✗ CALL REJECTED!\n'Your results are too low! Read your books first before asking for money!'"
			action_btn.disabled = true

	elif current_app_id == "hustle":
		# Perform typing hustle
		if needs.energy >= 20.0:
			needs.modify_energy(-20.0)
			needs.modify_money(2500)
			TimeSystem.advance_minutes(60)
			if SoundManager:
				SoundManager.play_coin()
			content_label.text = "✓ GIG FINISHED! You typed 25 pages of past questions.\nEarned ₦2,500! Energy -20%"
			action_btn.disabled = true
			hustle_performed.emit(2500, "Typed assignments in SUB! Earned ₦2,500")
		else:
			if SoundManager:
				SoundManager.play_alert()
			content_label.text = "⚠ Too exhausted to work! Go to the hostel bed and sleep first."


func _get_class_text(cgpa: float) -> String:
	if cgpa >= 4.50: return "First Class Honours"
	if cgpa >= 3.50: return "Second Class Upper (2:1)"
	if cgpa >= 2.40: return "Second Class Lower (2:2)"
	return "Third Class Standing"


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s
