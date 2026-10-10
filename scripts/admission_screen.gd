class_name AdmissionScreen
extends Control

## University Admissions & Student Onboarding Portal.
## Multi-step authentic admission journey:
## Step 1: JAMB / Student Biodata (Name, Email, Gender)
## Step 2: Physical Character Styling (Complexion, Hairstyle, Clothes)
## Step 3: Choice of Faculty & Primary Academic Department
## Step 4: Post-UTME Screening Aptitude Quiz (3 Questions)
## Step 5: Official University Admission Letter Presentation & Matriculation Number

signal onboarding_completed(profile_data: Dictionary)

const Customizer = preload("res://scripts/data/character_customizer.gd")
const StudentProfile = preload("res://scripts/data/student_profile.gd")

# Wizard Steps
enum Step { BIODATA, AVATAR, DEPARTMENT, SCREENING, ADMISSION_LETTER }
var current_step: Step = Step.BIODATA

# Screening Questions Bank per Faculty
const SCREENING_QUESTIONS: Dictionary = {
	"CSC": [
		{
			"q": "What is the binary representation of the decimal number 5?",
			"options": ["101", "110", "011", "111"],
			"correct": 0
		},
		{
			"q": "Which of these is NOT an operating system?",
			"options": ["Linux", "Windows", "Google Chrome", "macOS"],
			"correct": 2
		},
		{
			"q": "What does CPU stand for in computer hardware?",
			"options": ["Central Processing Unit", "Control Program Utility", "Core Power Unit", "Common Peripheral Unit"],
			"correct": 0
		}
	],
	"MAC": [
		{
			"q": "Who coined the phrase 'The medium is the message'?",
			"options": ["Marshall McLuhan", "Harold Lasswell", "Wole Soyinka", "Chinua Achebe"],
			"correct": 0
		},
		{
			"q": "Which form of journalism relies heavily on sensationalism and scandals?",
			"options": ["Investigative Journalism", "Yellow Journalism", "Civic Journalism", "Financial Journalism"],
			"correct": 1
		},
		{
			"q": "Which organ in Nigeria regulates broadcast radio and television stations?",
			"options": ["NBC", "NCC", "NUJ", "NAN"],
			"correct": 0
		}
	],
	"ECN": [
		{
			"q": "What is considered the basic economic problem facing every society?",
			"options": ["Inflation", "Scarcity of resources", "High taxes", "Lack of banks"],
			"correct": 1
		},
		{
			"q": "When supply exceeds demand in a competitive market, prices tend to:",
			"options": ["Rise", "Fall", "Stay exactly the same", "Double"],
			"correct": 1
		},
		{
			"q": "Which apex institution issues legal tender banknotes in Nigeria?",
			"options": ["EFCC", "Ministry of Finance", "Central Bank of Nigeria (CBN)", "NDIC"],
			"correct": 2
		}
	]
}

# State selections
var selected_gender: String = "Male"
var selected_complexion: int = 1
var selected_hair: int = 0
var selected_shirt: int = 0
var selected_trouser: int = 0
var selected_department: String = "CSC"

# Screening state
var quiz_q_idx: int = 0
var quiz_score: int = 0
var active_quiz_questions: Array = []

# UI references
@onready var step_title_label: Label = %StepTitle
@onready var step_subtitle_label: Label = %StepSubtitle

# Panels
@onready var biodata_panel: VBoxContainer = %BiodataPanel
@onready var avatar_panel: VBoxContainer = %AvatarPanel
@onready var dept_panel: VBoxContainer = %DeptPanel
@onready var screening_panel: VBoxContainer = %ScreeningPanel
@onready var letter_panel: VBoxContainer = %LetterPanel

# Step 1 inputs
@onready var name_input: LineEdit = %NameInput
@onready var email_input: LineEdit = %EmailInput
@onready var gender_options: OptionButton = %GenderOptions

# Step 2 inputs
@onready var complexion_options: OptionButton = %ComplexionOptions
@onready var hair_options: OptionButton = %HairOptions
@onready var shirt_options: OptionButton = %ShirtOptions
@onready var trouser_options: OptionButton = %TrouserOptions
@onready var avatar_preview_label: Label = %AvatarPreviewLabel

# Step 3 inputs
@onready var dept_options: OptionButton = %DeptOptions
@onready var dept_desc_label: Label = %DeptDescLabel

# Step 4 inputs
@onready var question_label: Label = %QuestionLabel
@onready var options_container: VBoxContainer = %OptionsContainer
@onready var screening_progress_label: Label = %ScreeningProgressLabel

# Step 5 inputs
@onready var letter_text_label: RichTextLabel = %LetterTextLabel

# Navigation
@onready var next_button: Button = %NextButton


func _ready() -> void:
	if next_button:
		next_button.pressed.connect(_on_next_pressed)

	_setup_options()
	_update_view()


func _setup_options() -> void:
	if gender_options:
		gender_options.clear()
		gender_options.add_item("Male Student")
		gender_options.add_item("Female Student")
		gender_options.item_selected.connect(func(idx: int):
			selected_gender = "Male" if idx == 0 else "Female"
			_refresh_avatar_preview()
		)

	if complexion_options:
		complexion_options.clear()
		for item in Customizer.SKIN_TONES:
			complexion_options.add_item(item["name"])
		complexion_options.select(selected_complexion)
		complexion_options.item_selected.connect(func(idx: int):
			selected_complexion = idx
			_refresh_avatar_preview()
		)

	if hair_options:
		hair_options.clear()
		for item in Customizer.HAIR_STYLES:
			hair_options.add_item(item["name"])
		hair_options.select(selected_hair)
		hair_options.item_selected.connect(func(idx: int):
			selected_hair = idx
			_refresh_avatar_preview()
		)

	if shirt_options:
		shirt_options.clear()
		for item in Customizer.SHIRT_STYLES:
			shirt_options.add_item(item["name"])
		shirt_options.select(selected_shirt)
		shirt_options.item_selected.connect(func(idx: int):
			selected_shirt = idx
			_refresh_avatar_preview()
		)

	if trouser_options:
		trouser_options.clear()
		for item in Customizer.TROUSER_STYLES:
			trouser_options.add_item(item["name"])
		trouser_options.select(selected_trouser)
		trouser_options.item_selected.connect(func(idx: int):
			selected_trouser = idx
			_refresh_avatar_preview()
		)

	if dept_options:
		dept_options.clear()
		dept_options.add_item("Computer Science (Science & Computing)")
		dept_options.add_item("Mass Communication (Social Sciences)")
		dept_options.add_item("Economics (Social & Management Sciences)")
		dept_options.item_selected.connect(_on_dept_selected)

	_on_dept_selected(0)
	_refresh_avatar_preview()


func _refresh_avatar_preview() -> void:
	if avatar_preview_label:
		var tone_name: String = Customizer.SKIN_TONES[selected_complexion]["name"]
		var hair_name: String = Customizer.HAIR_STYLES[selected_hair]["name"]
		var shirt_name: String = Customizer.SHIRT_STYLES[selected_shirt]["name"]
		var trouser_name: String = Customizer.TROUSER_STYLES[selected_trouser]["name"]
		avatar_preview_label.text = "👤 PREVIEW: %s | %s Tone\n💈 Hair: %s | 👕 %s | 👖 %s" % [
			selected_gender, tone_name, hair_name, shirt_name, trouser_name
		]


func _on_dept_selected(idx: int) -> void:
	match idx:
		0:
			selected_department = "CSC"
			if dept_desc_label:
				dept_desc_label.text = "💻 Faculty of Science & Computing\nHigh cut-off merit requirement. Courses include Intro to Computing, Discrete Maths, and Data Structures."
		1:
			selected_department = "MAC"
			if dept_desc_label:
				dept_desc_label.text = "🎙️ Faculty of Social Sciences\nJournalism, Broadcasting, Media ethics, and Public Relations."
		2:
			selected_department = "ECN"
			if dept_desc_label:
				dept_desc_label.text = "📊 Faculty of Social & Management Sciences\nMicroeconomics, Macroeconomics, Monetary Banking, and Finance."


func _update_view() -> void:
	if biodata_panel: biodata_panel.visible = (current_step == Step.BIODATA)
	if avatar_panel: avatar_panel.visible = (current_step == Step.AVATAR)
	if dept_panel: dept_panel.visible = (current_step == Step.DEPARTMENT)
	if screening_panel: screening_panel.visible = (current_step == Step.SCREENING)
	if letter_panel: letter_panel.visible = (current_step == Step.ADMISSION_LETTER)

	match current_step:
		Step.BIODATA:
			step_title_label.text = "🏛️ STUDENT ADMISSIONS PORTAL"
			step_subtitle_label.text = "Step 1 of 5: Candidate Biodata & Registration"
			next_button.text = "Next: Character Customization ➡️"
		Step.AVATAR:
			step_title_label.text = "🎨 STUDENT AVATAR STYLING"
			step_subtitle_label.text = "Step 2 of 5: Melanin Complexion, Hairstyle & Wardrobe"
			next_button.text = "Next: Select Academic Course ➡️"
		Step.DEPARTMENT:
			step_title_label.text = "📚 FACULTY & COURSE SELECTION"
			step_subtitle_label.text = "Step 3 of 5: Choose Your First Choice Degree Program"
			next_button.text = "Begin Post-UTME Screening Quiz 📝"
		Step.SCREENING:
			step_title_label.text = "📝 POST-UTME SCREENING TEST"
			step_subtitle_label.text = "Step 4 of 5: University Aptitude Screening Test"
			next_button.text = "Submit Test Answer ➡️"
		Step.ADMISSION_LETTER:
			step_title_label.text = "📜 PROVISIONAL ADMISSION LETTER"
			step_subtitle_label.text = "Step 5 of 5: Official University Senate Determination"
			next_button.text = "Accept Admission & Enter Campus! 🎒🎓"


func _on_next_pressed() -> void:
	SoundManager.play_click()

	match current_step:
		Step.BIODATA:
			var p_name: String = name_input.text.strip_edges() if name_input else ""
			if p_name.is_empty():
				name_input.text = "Femi Adeleke"
			current_step = Step.AVATAR
			_update_view()
		Step.AVATAR:
			current_step = Step.DEPARTMENT
			_update_view()
		Step.DEPARTMENT:
			# Start screening quiz
			quiz_q_idx = 0
			quiz_score = 0
			active_quiz_questions = SCREENING_QUESTIONS.get(selected_department, SCREENING_QUESTIONS["CSC"])
			current_step = Step.SCREENING
			_update_view()
			_load_screening_question()
		Step.SCREENING:
			# Handled by option selection or advancement
			pass
		Step.ADMISSION_LETTER:
			_complete_onboarding_and_start_game()


func _load_screening_question() -> void:
	if quiz_q_idx >= active_quiz_questions.size():
		# Quiz finished! Determine placement
		var pct_score: int = int((float(quiz_score) / float(active_quiz_questions.size())) * 100.0)
		var p_name: String = name_input.text.strip_edges() if name_input else "Femi Adeleke"
		var p_email: String = email_input.text.strip_edges() if email_input else "femi@campus.edu.ng"

		var placement: Dictionary = StudentProfile.apply_admission(
			p_name,
			p_email,
			selected_gender,
			selected_complexion,
			selected_hair,
			selected_shirt,
			selected_trouser,
			selected_department,
			pct_score
		)

		_show_admission_letter(placement, pct_score)
		current_step = Step.ADMISSION_LETTER
		_update_view()
		return

	var q: Dictionary = active_quiz_questions[quiz_q_idx]
	if screening_progress_label:
		screening_progress_label.text = "Screening Question %d of %d (Passing Score: 67%%)" % [
			quiz_q_idx + 1, active_quiz_questions.size()
		]
	if question_label:
		question_label.text = String(q["q"])

	# Populate options
	for child in options_container.get_children():
		child.queue_free()

	var opts: Array = q["options"]
	for i in opts.size():
		var btn: Button = Button.new()
		btn.text = "%c)  %s" % [65 + i, String(opts[i])]
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override(&"font_size", 16)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_quiz_option_chosen.bind(i))
		options_container.add_child(btn)


func _on_quiz_option_chosen(opt_idx: int) -> void:
	SoundManager.play_click()
	var q: Dictionary = active_quiz_questions[quiz_q_idx]
	if opt_idx == int(q["correct"]):
		quiz_score += 1

	quiz_q_idx += 1
	_load_screening_question()


func _show_admission_letter(placement: Dictionary, score_pct: int) -> void:
	SoundManager.play_bell()
	if letter_text_label:
		var admitted_title: String = String(placement.get("title", "Course"))
		var admitted_fac: String = String(placement.get("faculty", "Faculty"))
		var remark: String = String(placement.get("remark", ""))
		var student_n: String = StudentProfile.student_name
		var matric: String = StudentProfile.matric_no
		var spawn_t: String = StudentProfile.spawn_title
		var spawn_badge: String = StudentProfile.spawn_badge
		var spawn_phone: String = StudentProfile.spawn_phone_model
		var spawn_tag: String = StudentProfile.spawn_tagline
		var formatted_allowance: String = str(StudentProfile.spawn_allowance)
		var idx: int = formatted_allowance.length() - 3
		while idx > 0:
			formatted_allowance = formatted_allowance.insert(idx, ",")
			idx -= 3

		var letter_content: String = """[center][b]FEDERAL UNIVERSITY OF CAMPUS LIFE[/b]
[b]OFFICE OF THE REGISTRAR & ACADEMIC BOARD[/b][/center]
---------------------------------------------------------------
[b]CANDIDATE:[/b] %s
[b]MATRIC NUMBER:[/b] %s
[b]SCREENING SCORE:[/b] %d%%

[b]ADMISSION STATUS:[/b]
%s

[b]ADMITTED PROGRAM:[/b]
🎓 %s
🏛️ %s

[b]MATRICULATION BACKGROUND & SPONSOR TIER:[/b]
%s [b]%s[/b]
💰 Initial Pocket Money: ₦%s
📱 Phone Device: %s
💡 [i]%s[/i]

[i]"Report to the Student Hostel immediately for room allocation and clearance."[/i]
""" % [student_n, matric, score_pct, remark, admitted_title, admitted_fac, spawn_badge, spawn_t, formatted_allowance, spawn_phone, spawn_tag]

		letter_text_label.text = letter_content


func _complete_onboarding_and_start_game() -> void:
	SoundManager.play_transit_horn()
	onboarding_completed.emit(StudentProfile.get_profile_data())

	# Transition to the student hostel room
	var err: Error = get_tree().change_scene_to_file("res://scenes/rooms/hostel_room.tscn")
	if err != OK:
		push_error("Failed to load hostel room: %d" % err)

