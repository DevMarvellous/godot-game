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
@onready var phone_clock_label: Label = %PhoneClockLabel if has_node("%PhoneClockLabel") else null
@onready var phone_network_label: Label = %PhoneNetworkLabel if has_node("%PhoneNetworkLabel") else null

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
	_wire_app_btn(%OnlineAppBtn, "online")
	_wire_app_btn(%SettingsAppBtn, "settings")


func _wire_app_btn(btn: Button, app_id: String) -> void:
	if btn:
		btn.pressed.connect(_open_app.bind(app_id))


func open_phone(p: CharacterBody3D) -> void:
	current_player = p
	_update_phone_status_bar()
	visible = true
	_show_home_screen()


func _update_phone_status_bar() -> void:
	if phone_clock_label:
		var time_str: String = TimeSystem.get_time_string() if TimeSystem else "08:30 AM"
		var day_str: String = TimeSystem.get_weekday_name() if TimeSystem else "Mon"
		phone_clock_label.text = "%s • %s" % [time_str, day_str]

	if phone_network_label:
		var battery_pct: int = 100
		if current_player:
			var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
			if needs:
				battery_pct = int(clampf(needs.energy, 5.0, 100.0))
		phone_network_label.text = "📶 MTN 4G  🔋 %d%%" % battery_pct


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
			app_title.text = "💬 CAMPUS WHATSAPP & GIST HUB"
			_render_whatsapp_gist()
			action_btn.visible = true
			action_btn.text = "Send Message to Department Group 💬"

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
			app_title.text = "💼 STUDENT HUSTLE & BRAND ADS"
			content_label.text = """AVAILABLE GIGS & REWARD ADS:
1. SUB Typing & Proofreading (+₦2,500)
2. Graphic Design & Campaign Posters (+₦4,500)
3. Freelance Coding with Mr. Marvellous (+₦8,500)
4. 📺 WATCH SPONSORED REWARD AD (+₦1,500 Cash & +25% Energy Recharge!)

Need instant cash without draining energy? Watch a campus partner promo!"""
			action_btn.visible = true
			action_btn.text = "📺 Watch Sponsored Promo (+₦1,500 & +25 Energy)"

		"online":
			app_title.text = "🌐 CAMPUS MULTIPLAYER LOBBY"
			var is_conn: bool = NetworkManager.is_online() if NetworkManager else false
			var active_count: int = NetworkManager.remote_players.size() if NetworkManager else 0
			var status_str: String = "ONLINE (Connected)" if is_conn else "OFFLINE (Local Campus Mode)"
			content_label.text = "NETWORK STATUS: %s\nSTUDENTS IN ROOM: %d\nSERVER: ws://127.0.0.1:8910\n\nConnect to see real players walking around campus and chatting in real time!" % [
				status_str, active_count + 1
			]
			action_btn.visible = true
			action_btn.text = "Disconnect from Server" if is_conn else "Connect to Online Campus"

		"settings":
			app_title.text = "⚙️ GAME SETTINGS"
			var current_audio: String = "ACTIVE (Procedural In-Memory)"
			content_label.text = "SOUND FX: %s\nGRAPHICS: Mobile Performance (GL Compatibility)\nINPUT: Touchscreen / Mouse Raycast\nVERSION: 1.0.0 (Web & Mobile)" % current_audio
			action_btn.visible = true
			action_btn.text = "Test Sound Bell / Alert"


func _on_app_action_pressed() -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if current_app_id == "chat":
		# Send a relatable message to the group chat
		var replies: Array[String] = [
			"You: 'Who has the soft copy of Dr. Adebayo's slides?'\n• Emeka (Course Rep): 'Check WhatsApp doc link pinned at top!'",
			"You: 'Is there lecture by 2pm today?'\n• Segun: 'Man, lecturer just arrived at LT2. Rush now!'",
			"You: 'Please who has extra meal ticket at Mama Put?'\n• Mama Cashout: 'Come chop my pikin, discount dey for you!'",
			"You: 'Who is playing in the Dean's Cup match this evening?'\n• Coach Balogun: 'Inter-Faculty clash kicks off by 4:30 PM! Be there!'"
		]
		var chosen_reply: String = replies[randi() % replies.size()]
		if SoundManager:
			SoundManager.play_click()
		content_label.text = "%s\n\n💬 LIVE REPLY:\n%s" % [content_label.text, chosen_reply]
		action_btn.disabled = true
		if current_player and current_player.has_method("show_chat_bubble"):
			current_player.show_chat_bubble("Sent message on WhatsApp!")

	elif current_app_id == "bank":
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
		# Watch sponsored reward ad / campus brand clip
		needs.modify_money(1500)
		needs.modify_energy(25.0)
		TimeSystem.advance_minutes(5)
		if SoundManager:
			SoundManager.play_coin()
		content_label.text = """📺 SPONSORED AD REWARD CLAIMED!
--------------------------------------------------
Thank you for viewing our Campus Partner Brand Promo!
✓ +₦1,500 credited to your OPay / Campus Wallet!
✓ +25% Energy recharged (Drink promo can)!

Your wallet and stamina are replenished for next lecture!"""
		action_btn.disabled = true
		hustle_performed.emit(1500, "Watched Sponsored Campus Brand Ad! +₦1,500, +25 Energy")

	elif current_app_id == "online":
		if NetworkManager:
			if NetworkManager.is_online():
				NetworkManager.disconnect_from_campus()
				content_label.text = "Disconnected from campus server.\nRunning in offline single-player mode."
				action_btn.text = "Connect to Online Campus"
			else:
				NetworkManager.connect_to_campus()
				content_label.text = "Connecting to WebSocket campus server at ws://127.0.0.1:8910...\nIf server is active, other players will appear in your room."
				action_btn.text = "Disconnect from Server"

	elif current_app_id == "settings":
		if SoundManager:
			SoundManager.play_bell()
			content_label.text = "🔔 Audio Bell tested successfully!\nAll game systems running with zero lag."


func _render_whatsapp_gist() -> void:
	const StudentProfile = preload("res://scripts/data/student_profile.gd")
	StudentProfile.load_from_disk()
	var dept_name: String = StudentProfile.admitted_department
	var student_n: String = StudentProfile.student_name

	content_label.text = """🟢 %s 100L OFFICIAL CLASS GROUP (Active)
--------------------------------------------------
📌 Pinned by Course Rep Emeka: 'Submission deadline for Assignment 1 is Thursday 8:00 AM!'

• Emeka (Course Rep): 'Please check your portal, CA marks are being uploaded!'
• Chisom: 'Who is currently in the Central Library? Help me hold a reading seat!'
• Segun: 'Light just came on in Hall 2! Come charge your laptops and phones!'
• Coach Balogun: 'Inter-Faculty football training this evening at the stadium pitch!'
• Tobi (400L): 'I still have past questions booklet copies at SUB.'
• Sister Blessing: 'Youth fellowship starts 5:00 PM at the Chapel. Come and be blessed.'
""" % [dept_name]


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
