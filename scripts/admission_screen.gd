class_name AdmissionScreen
extends Control

## University Admissions & Student Onboarding Portal.
## Multi-step authentic admission journey:
## Step 1: JAMB / Student Biodata (Name, Email, Gender)
## Step 2: Physical Character Styling (Complexion, Hairstyle, Clothes with Live 3D Drip & Animation)
## Step 3: Choice of Faculty & Primary Academic Department
## Step 4: Post-UTME Screening Aptitude Quiz (3 Questions with Real-time Interactive Feedback)
## Step 5: Official University Admission Letter Presentation & Matriculation Number

signal onboarding_completed(profile_data: Dictionary)

const FACULTY_ORDER: Array[String] = [
	"CMP_FAC", "ENG_FAC", "LAW_FAC", "SMS_FAC", "NAS_FAC", "MED_FAC", "HUM_FAC"
]

# Wizard Steps
enum Step { BIODATA, AVATAR, DEPARTMENT, SCREENING, ADMISSION_LETTER }
var current_step: Step = Step.BIODATA

# Screening Questions Bank per Faculty (Eng, Computing, Law, Social Sciences, Natural Sciences, Medicine, Humanities)
const SCREENING_QUESTIONS: Dictionary = {
	"CMP_FAC": [
		{
			"q": "What is the primary role of the Central Processing Unit (CPU)?",
			"options": ["Execute program instructions and arithmetic operations", "Store power during NEPA outage", "Clean dust from motherboard circuits", "Transmit FM radio frequencies"],
			"correct": 0
		},
		{
			"q": "Which programming language is predominantly known for data science and machine learning?",
			"options": ["Python", "HTML", "JPEG", "MP3"],
			"correct": 0
		},
		{
			"q": "What does RAM stand for in personal computing?",
			"options": ["Random Access Memory", "Rapid Audio Module", "Read Always Machine", "Remote Algorithm Matrix"],
			"correct": 0
		}
	],
	"ENG_FAC": [
		{
			"q": "Which electromechanical machine transforms kinetic motion into electrical power?",
			"options": ["Electric Generator / Dynamo", "Thermometer", "Plastic ruler", "Resistance capacitor"],
			"correct": 0
		},
		{
			"q": "If a campus workshop motor uses 1,000 Watts for 2 hours, what energy is consumed?",
			"options": ["2 Kilowatt-hours (kWh)", "0.5 kWh", "20 kWh", "500 Watts"],
			"correct": 0
		},
		{
			"q": "Which material is used in civil engineering to reinforce concrete structural columns?",
			"options": ["High-yield Steel Rebar", "Pure Aluminium foil", "Rubber tubing", "Pressed cardboard"],
			"correct": 0
		}
	],
	"LAW_FAC": [
		{
			"q": "What is the supreme law of Nigeria to which all other statutes must conform?",
			"options": ["The 1999 Constitution of Nigeria", "Hostel Hall Rulebook", "Lagos Traffic Code", "Company Bylaws"],
			"correct": 0
		},
		{
			"q": "Under Nigerian criminal jurisprudence, an accused person is presumed:",
			"options": ["Innocent until proven guilty", "Guilty until fine is paid", "Detained without bail indefinitely", "Discharged on hearsay"],
			"correct": 0
		},
		{
			"q": "Which organ of government is constitutionally vested with legislative power?",
			"options": ["The National Assembly (Senate & House of Reps)", "Nigerian Bar Association", "Federal Road Safety Corps", "Academic Staff Union"],
			"correct": 0
		}
	],
	"SMS_FAC": [
		{
			"q": "When consumer demand for goods surges while supply is scarce, what occurs to market price?",
			"options": ["Equilibrium price tends to rise", "Price plummets to zero", "Supply doubles instantaneously", "Prices remain frozen perpetually"],
			"correct": 0
		},
		{
			"q": "Which apex institution holds sole constitutional authority to issue Nigerian Naira notes?",
			"options": ["Central Bank of Nigeria (CBN)", "Ministry of Interior", "EFCC", "Lagos Chamber of Commerce"],
			"correct": 0
		},
		{
			"q": "What financial accounting term describes net revenue remaining after deducting all business expenses?",
			"options": ["Net Profit", "Gross Deficit", "Bank Overdraft", "Accrued Amortization"],
			"correct": 0
		}
	],
	"NAS_FAC": [
		{
			"q": "Which natural gravitational force accelerates falling objects toward the center of the Earth?",
			"options": ["Gravity", "Centrifugal repulsion", "Electrostatic friction", "Surface buoyancy"],
			"correct": 0
		},
		{
			"q": "What is the standard chemical formula for pure drinking water?",
			"options": ["H2O", "CO2", "NaCl", "CH4"],
			"correct": 0
		},
		{
			"q": "Which vital gas do green plants release as a byproduct of photosynthesis?",
			"options": ["Oxygen (O2)", "Carbon Monoxide", "Helium", "Chlorine"],
			"correct": 0
		}
	],
	"MED_FAC": [
		{
			"q": "Which muscular organ pumps oxygenated blood throughout the human body?",
			"options": ["The Heart", "The Gallbladder", "The Pancreas", "The Spleen"],
			"correct": 0
		},
		{
			"q": "Which insect vector transmits the Plasmodium parasite responsible for campus malaria?",
			"options": ["Female Anopheles mosquito", "Housefly", "Soldier termite", "Honeybee"],
			"correct": 0
		},
		{
			"q": "What is the primary function of white blood cells (leukocytes) in human immunology?",
			"options": ["Defend the body against infection & pathogens", "Distribute dietary glucose", "Absorb inhaled nitrogen", "Digest calcium in bone marrow"],
			"correct": 0
		}
	],
	"HUM_FAC": [
		{
			"q": "Who authored the classic Nigerian literary masterpiece 'Things Fall Apart'?",
			"options": ["Prof. Chinua Achebe", "Wole Soyinka", "Chimamanda Ngozi Adichie", "Ola Rotimi"],
			"correct": 0
		},
		{
			"q": "In Christian Religious Studies (CRS), where was Jesus Christ born according to the New Testament?",
			"options": ["Bethlehem of Judea", "Jerusalem Temple", "Nazareth of Galilee", "Rome"],
			"correct": 0
		},
		{
			"q": "Which historic Nigerian civilization is world-celebrated for its terracotta sculptures?",
			"options": ["The Nok Culture", "The Oyo Cavalry", "The Sokoto Caliphate", "The Borgu Kingdom"],
			"correct": 0
		}
	]
}

# State selections
var selected_gender: String = "Male"
var selected_complexion: int = 1
var selected_hair: int = 0
var selected_shirt: int = 0
var selected_trouser: int = 0
var selected_faculty_id: String = "CMP_FAC"
var selected_department: String = "CSC"
var current_faculty_dept_codes: Array = []

# Screening state
var quiz_q_idx: int = 0
var quiz_score: int = 0
var active_quiz_questions: Array = []
var is_quiz_answering: bool = false

# Drip UI state
var active_drip_tab: String = "outfits"
var drip_cards_vbox: VBoxContainer = null
var floating_drip_badge: Label = null
var quick_status_btn: Button = null
var step_nav_buttons: Array[Button] = []
var tab_buttons_map: Dictionary = {}

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
@onready var faculty_options: OptionButton = %FacultyOptions
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
@onready var card_panel: PanelContainer = %CardPanel

const PlayerScene = preload("res://scenes/player_3d.tscn")
const Wardrobe = preload("res://scripts/data/wardrobe_data.gd")
var preview_player_instance: Player3D = null


func _ready() -> void:
	if next_button:
		next_button.pressed.connect(_on_next_pressed)
		var next_style := StyleBoxFlat.new()
		next_style.bg_color = Color(0.96, 0.76, 0.14, 1.0)
		next_style.border_width_left = 2
		next_style.border_width_top = 2
		next_style.border_width_right = 2
		next_style.border_width_bottom = 2
		next_style.border_color = Color(1.0, 0.92, 0.55, 1.0)
		next_style.corner_radius_top_left = 12
		next_style.corner_radius_top_right = 12
		next_style.corner_radius_bottom_left = 12
		next_style.corner_radius_bottom_right = 12
		next_button.add_theme_stylebox_override(&"normal", next_style)
		next_button.add_theme_stylebox_override(&"hover", next_style)
		next_button.add_theme_color_override(&"font_color", Color(0.06, 0.10, 0.14, 1.0))

	if name_input:
		name_input.text_submitted.connect(func(_text: String) -> void: _on_next_pressed())
	if email_input:
		email_input.text_submitted.connect(func(_text: String) -> void: _on_next_pressed())

	_build_step_indicator_bar()
	_build_easy_typing_helpers()
	_adjust_responsive_layout()
	get_viewport().size_changed.connect(_adjust_responsive_layout)

	_setup_preview_player()
	_setup_options()
	_build_visual_drip_station()
	_update_view()


func _build_step_indicator_bar() -> void:
	var header_vbox: VBoxContainer = get_node_or_null("SafeArea/CardCenter/CardPanel/CardVBox/HeaderPanel/HeaderVBox") as VBoxContainer
	if not header_vbox or header_vbox.has_node("StepNavBar"):
		return

	var nav_row := HBoxContainer.new()
	nav_row.name = "StepNavBar"
	nav_row.alignment = BoxContainer.ALIGNMENT_CENTER
	nav_row.add_theme_constant_override(&"separation", 6)

	var step_labels: Array[String] = [
		"1. Biodata 👤", "2. Drip 👔", "3. Course 🎓", "4. Screening 📝", "5. Letter 📜"
	]
	step_nav_buttons.clear()

	for i in step_labels.size():
		var btn := Button.new()
		btn.text = step_labels[i]
		btn.custom_minimum_size = Vector2(0, 26)
		btn.add_theme_font_size_override(&"font_size", 11)
		btn.focus_mode = Control.FOCUS_NONE
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nav_row.add_child(btn)
		step_nav_buttons.append(btn)

	header_vbox.add_child(nav_row)


func _update_step_navbar() -> void:
	var step_labels: Array[String] = [
		"1. Biodata 👤", "2. Drip 👔", "3. Course 🎓", "4. Screening 📝", "5. Letter 📜"
	]
	for i in step_nav_buttons.size():
		var btn: Button = step_nav_buttons[i]
		var st := StyleBoxFlat.new()
		st.corner_radius_top_left = 6
		st.corner_radius_top_right = 6
		st.corner_radius_bottom_left = 6
		st.corner_radius_bottom_right = 6
		st.content_margin_left = 8.0
		st.content_margin_right = 8.0

		if i < int(current_step):
			st.bg_color = Color(0.08, 0.40, 0.24, 0.95)
			st.border_color = Color(0.20, 0.85, 0.45, 0.8)
			st.border_width_left = 1
			st.border_width_top = 1
			st.border_width_right = 1
			st.border_width_bottom = 1
			btn.text = "✓ " + step_labels[i]
			btn.add_theme_color_override(&"font_color", Color(0.85, 0.98, 0.90, 1.0))
		elif i == int(current_step):
			st.bg_color = Color(0.96, 0.78, 0.16, 1.0)
			st.border_color = Color(1.0, 0.95, 0.70, 1.0)
			st.border_width_left = 2
			st.border_width_top = 2
			st.border_width_right = 2
			st.border_width_bottom = 2
			btn.text = "★ " + step_labels[i]
			btn.add_theme_color_override(&"font_color", Color(0.06, 0.10, 0.14, 1.0))
		else:
			st.bg_color = Color(0.09, 0.14, 0.20, 0.7)
			st.border_color = Color(0.20, 0.28, 0.38, 0.5)
			btn.text = step_labels[i]
			btn.add_theme_color_override(&"font_color", Color(0.55, 0.65, 0.75, 0.8))

		btn.add_theme_stylebox_override(&"normal", st)
		btn.add_theme_stylebox_override(&"disabled", st)


func _build_easy_typing_helpers() -> void:
	if not biodata_panel or not name_input:
		return
	var input_style := StyleBoxFlat.new()
	input_style.bg_color = Color(0.96, 0.98, 1.0, 1.0)
	input_style.border_width_left = 2
	input_style.border_width_top = 2
	input_style.border_width_right = 2
	input_style.border_width_bottom = 2
	input_style.border_color = Color(0.15, 0.68, 0.42, 1.0)
	input_style.corner_radius_top_left = 10
	input_style.corner_radius_top_right = 10
	input_style.corner_radius_bottom_left = 10
	input_style.corner_radius_bottom_right = 10
	input_style.content_margin_left = 14.0
	input_style.content_margin_right = 14.0
	for le: LineEdit in [name_input, email_input]:
		if le:
			le.add_theme_stylebox_override(&"normal", input_style)
			le.add_theme_stylebox_override(&"focus", input_style)
			le.add_theme_color_override(&"font_color", Color(0.06, 0.10, 0.16, 1.0))
			le.add_theme_color_override(&"font_placeholder_color", Color(0.42, 0.48, 0.56, 1.0))
			le.add_theme_color_override(&"caret_color", Color(0.08, 0.55, 0.32, 1.0))
			le.add_theme_font_size_override(&"font_size", 16)

	# Quick-tap Nigerian name chips + Native mobile keyboard button right below NameInput
	var chip_row := HFlowContainer.new()
	chip_row.name = "QuickNameChips"
	chip_row.add_theme_constant_override(&"h_separation", 6)
	chip_row.add_theme_constant_override(&"v_separation", 6)

	var preset_names: Array[String] = [
		"🎲 Lucky Dip Name", "Tunde 'Tech Bro' Adeleke", "Chisom 'First Class' Okafor",
		"Femi 'Party Starter' Bakare", "Zainab 'Big Brain' Bello", "Kelechi 'Danfo Pilot' Nwosu"
	]
	const RANDOM_POOL: Array[String] = [
		"Adebayo Ogunlesi", "Ngozi Eze", "Damilola Balogun", "Ibrahim Danjuma",
		"Bolanle Coker", "Emeka Obi", "Ayomide Williams", "Halima Lawal", "Segun Alabi", "Tolani Davies"
	]
	for label_txt in preset_names:
		var b := Button.new()
		b.text = label_txt
		b.custom_minimum_size = Vector2(0, 36)
		b.add_theme_font_size_override(&"font_size", 13)
		b.pressed.connect(func():
			SoundManager.play_click()
			var chosen: String = RANDOM_POOL.pick_random() if label_txt.begins_with("🎲") else label_txt.split("'")[0].strip_edges() + " " + label_txt.split("'")[-1].strip_edges()
			if label_txt.begins_with("🎲"):
				chosen = RANDOM_POOL.pick_random()
			name_input.text = chosen
			if email_input:
				var slug: String = chosen.to_lower().replace(" ", ".")
				email_input.text = "%s@campus.edu.ng" % slug
		)
		chip_row.add_child(b)

	if OS.has_feature("web"):
		var kb_btn := Button.new()
		kb_btn.text = "⌨️ Tap to Type Name"
		kb_btn.custom_minimum_size = Vector2(0, 36)
		kb_btn.add_theme_font_size_override(&"font_size", 13)
		kb_btn.pressed.connect(func():
			var res = JavaScriptBridge.eval("window.prompt('Enter your Student Full Name:', '%s') || ''" % name_input.text.replace("'", ""))
			if res is String and not String(res).strip_edges().is_empty():
				name_input.text = String(res).strip_edges()
				if email_input and email_input.text.is_empty():
					email_input.text = "%s@campus.edu.ng" % name_input.text.to_lower().replace(" ", ".")
		)
		chip_row.add_child(kb_btn)

	biodata_panel.add_child(chip_row)
	biodata_panel.move_child(chip_row, name_input.get_index() + 1)


func _adjust_responsive_layout() -> void:
	if not is_instance_valid(card_panel):
		return
	var vp_size: Vector2 = get_viewport_rect().size
	var target_w: float = minf(vp_size.x - 24.0, 580.0)
	card_panel.custom_minimum_size.x = maxf(target_w, 280.0)


func _setup_preview_player() -> void:
	if not has_node("%PreviewViewport"):
		return
	var vp: SubViewport = %PreviewViewport

	# Environment for vivid bright Lagos daylight from all angles
	if not vp.has_node("PreviewEnv"):
		var env_node := WorldEnvironment.new()
		env_node.name = "PreviewEnv"
		var env := Environment.new()
		env.background_mode = Environment.BG_CLEAR_COLOR
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.85, 0.90, 0.98, 1.0)
		env.ambient_light_energy = 1.25
		env_node.environment = env
		vp.add_child(env_node)

	# Key Light (warm Lagos sunshine)
	var dlight: DirectionalLight3D = vp.get_node_or_null("PreviewLight") as DirectionalLight3D
	if dlight:
		dlight.position = Vector3(2.0, 3.5, 3.0)
		dlight.rotation_degrees = Vector3(-30, 30, 0)
		dlight.light_energy = 1.45
		dlight.light_color = Color(1.0, 0.97, 0.92, 1.0)

	# Fill Light (prevents pitch black shadows)
	if not vp.has_node("PreviewFillLight"):
		var fill_light := DirectionalLight3D.new()
		fill_light.name = "PreviewFillLight"
		fill_light.position = Vector3(-2.5, 2.0, 1.5)
		fill_light.rotation_degrees = Vector3(-20, -45, 0)
		fill_light.light_energy = 0.85
		fill_light.light_color = Color(0.85, 0.92, 1.0, 1.0)
		vp.add_child(fill_light)

	var pcam: Camera3D = vp.get_node_or_null("PreviewCamera") as Camera3D
	if pcam:
		pcam.position = Vector3(0, 0.98, 2.30)
		pcam.rotation_degrees = Vector3(-5, 0, 0)
		pcam.fov = 42.0

	preview_player_instance = PlayerScene.instantiate() as Player3D
	preview_player_instance.set_physics_process(false)
	preview_player_instance.set_process_unhandled_input(false)
	vp.add_child(preview_player_instance)

	for child_name in ["Camera3D", "CollisionShape3D", "NotifLabel", "PromptLabel"]:
		var n = preview_player_instance.get_node_or_null(child_name)
		if n:
			n.queue_free()


func _process(delta: float) -> void:
	if is_instance_valid(preview_player_instance) and preview_player_instance.visual_root:
		# Pause idle rotation while the 360 spin dressing animation is active
		if not preview_player_instance.is_dressing_animating:
			preview_player_instance.visual_root.rotate_y(delta * 0.8)


func _setup_options() -> void:
	if gender_options:
		gender_options.clear()
		gender_options.add_item("Male Student")
		gender_options.add_item("Female Student")
		gender_options.item_selected.connect(func(idx: int):
			selected_gender = "Male" if idx == 0 else "Female"
			_refresh_avatar_preview(true)
		)

	if complexion_options:
		complexion_options.clear()
		for item in Wardrobe.COMPLEXIONS:
			complexion_options.add_item(item["name"])
		complexion_options.select(selected_complexion)
		complexion_options.item_selected.connect(func(idx: int):
			selected_complexion = idx
			_refresh_avatar_preview(true)
		)

	if hair_options:
		hair_options.clear()
		for item in Wardrobe.HAIRSTYLES:
			hair_options.add_item(item["name"])
		hair_options.select(selected_hair)
		hair_options.item_selected.connect(func(idx: int):
			selected_hair = idx
			_refresh_avatar_preview(true)
		)

	if shirt_options:
		shirt_options.clear()
		for item in Wardrobe.OUTFITS:
			shirt_options.add_item(item["name"])
		shirt_options.select(selected_shirt)
		shirt_options.item_selected.connect(func(idx: int):
			selected_shirt = idx
			_refresh_avatar_preview(true)
		)

	if trouser_options:
		trouser_options.clear()
		for item in CharacterCustomizer.TROUSER_STYLES:
			trouser_options.add_item(item["name"])
		trouser_options.select(selected_trouser)
		trouser_options.item_selected.connect(func(idx: int):
			selected_trouser = idx
			_refresh_avatar_preview(true)
		)

	if faculty_options:
		faculty_options.clear()
		for fac_id in FACULTY_ORDER:
			var fac_data: Dictionary = AcademicCatalog.FACULTIES[fac_id]
			var dept_count: int = fac_data["departments"].size()
			faculty_options.add_item("%s (%d Courses)" % [fac_data["name"], dept_count])
		faculty_options.item_selected.connect(_on_faculty_selected)

	if dept_options:
		dept_options.item_selected.connect(_on_dept_selected)

	_on_faculty_selected(0)
	_refresh_avatar_preview(false)


func _build_visual_drip_station() -> void:
	if not avatar_panel:
		return

	# Hide raw text dropdowns & labels to replace them with rich visual cards
	for raw_node in [complexion_options, hair_options, shirt_options, trouser_options]:
		if raw_node:
			raw_node.visible = false
	for lbl_name in ["SkinLabel", "HairLabel", "ShirtLabel", "TrouserLabel"]:
		var lbl = avatar_panel.get_node_or_null(lbl_name)
		if lbl:
			lbl.visible = false

	if avatar_panel.has_node("DripStationContainer"):
		return

	var station := VBoxContainer.new()
	station.name = "DripStationContainer"
	station.add_theme_constant_override(&"separation", 10)

	# 1. Quick Cycle Drip Bar (Placed directly under 3D Preview)
	var cycle_bar := HBoxContainer.new()
	cycle_bar.add_theme_constant_override(&"separation", 8)

	var prev_btn := Button.new()
	prev_btn.text = "◀ Prev Drip"
	prev_btn.custom_minimum_size = Vector2(100, 38)
	prev_btn.add_theme_font_size_override(&"font_size", 13)
	prev_btn.pressed.connect(func():
		SoundManager.play_click()
		if active_drip_tab == "hair":
			selected_hair = (selected_hair - 1 + Wardrobe.HAIRSTYLES.size()) % Wardrobe.HAIRSTYLES.size()
		elif active_drip_tab == "skin":
			selected_complexion = (selected_complexion - 1 + Wardrobe.COMPLEXIONS.size()) % Wardrobe.COMPLEXIONS.size()
		elif active_drip_tab == "trousers":
			selected_trouser = (selected_trouser - 1 + CharacterCustomizer.TROUSER_STYLES.size()) % CharacterCustomizer.TROUSER_STYLES.size()
		else:
			selected_shirt = (selected_shirt - 1 + Wardrobe.OUTFITS.size()) % Wardrobe.OUTFITS.size()
		_refresh_avatar_preview(true)
		_render_drip_cards()
	)
	cycle_bar.add_child(prev_btn)

	quick_status_btn = Button.new()
	quick_status_btn.text = "✨ Spin & Try On Drip 🔄 ✨"
	quick_status_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quick_status_btn.custom_minimum_size = Vector2(0, 38)
	quick_status_btn.add_theme_font_size_override(&"font_size", 13)
	quick_status_btn.pressed.connect(func():
		if preview_player_instance and preview_player_instance.has_method("play_dressing_animation"):
			preview_player_instance.play_dressing_animation()
	)
	cycle_bar.add_child(quick_status_btn)

	var next_btn := Button.new()
	next_btn.text = "Next Drip ▶"
	next_btn.custom_minimum_size = Vector2(100, 38)
	next_btn.add_theme_font_size_override(&"font_size", 13)
	next_btn.pressed.connect(func():
		SoundManager.play_click()
		if active_drip_tab == "hair":
			selected_hair = (selected_hair + 1) % Wardrobe.HAIRSTYLES.size()
		elif active_drip_tab == "skin":
			selected_complexion = (selected_complexion + 1) % Wardrobe.COMPLEXIONS.size()
		elif active_drip_tab == "trousers":
			selected_trouser = (selected_trouser + 1) % CharacterCustomizer.TROUSER_STYLES.size()
		else:
			selected_shirt = (selected_shirt + 1) % Wardrobe.OUTFITS.size()
		_refresh_avatar_preview(true)
		_render_drip_cards()
	)
	cycle_bar.add_child(next_btn)
	station.add_child(cycle_bar)

	# 2. Category Tabs (Outfits, Hairstyles, Complexion, Trousers)
	var tabs_bar := HBoxContainer.new()
	tabs_bar.add_theme_constant_override(&"separation", 6)

	var tabs_def: Array[Dictionary] = [
		{"id": "outfits", "label": "👔 Outfits (5)"},
		{"id": "hair", "label": "💈 Hair (5)"},
		{"id": "skin", "label": "🎨 Melanin (4)"},
		{"id": "trousers", "label": "👖 Pants (4)"}
	]
	tab_buttons_map.clear()

	for t in tabs_def:
		var tab_btn := Button.new()
		tab_btn.text = t["label"]
		tab_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab_btn.custom_minimum_size = Vector2(0, 36)
		tab_btn.add_theme_font_size_override(&"font_size", 13)
		var t_id: String = t["id"]
		tab_btn.pressed.connect(func():
			SoundManager.play_click()
			active_drip_tab = t_id
			_update_drip_tabs_ui()
			_render_drip_cards()
		)
		tabs_bar.add_child(tab_btn)
		tab_buttons_map[t_id] = tab_btn

	station.add_child(tabs_bar)

	# 3. Dynamic Visual Cards Container
	drip_cards_vbox = VBoxContainer.new()
	drip_cards_vbox.name = "DripCardsVBox"
	drip_cards_vbox.add_theme_constant_override(&"separation", 8)
	station.add_child(drip_cards_vbox)

	avatar_panel.add_child(station)
	_update_drip_tabs_ui()
	_render_drip_cards()


func _update_drip_tabs_ui() -> void:
	for t_id in tab_buttons_map.keys():
		var btn: Button = tab_buttons_map[t_id]
		var st := StyleBoxFlat.new()
		st.corner_radius_top_left = 8
		st.corner_radius_top_right = 8
		st.corner_radius_bottom_left = 8
		st.corner_radius_bottom_right = 8
		if t_id == active_drip_tab:
			st.bg_color = Color(0.96, 0.78, 0.16, 1.0)
			st.border_width_left = 2
			st.border_width_top = 2
			st.border_width_right = 2
			st.border_width_bottom = 2
			st.border_color = Color(1.0, 0.95, 0.70, 1.0)
			btn.add_theme_color_override(&"font_color", Color(0.06, 0.10, 0.14, 1.0))
		else:
			st.bg_color = Color(0.12, 0.18, 0.26, 0.9)
			st.border_width_left = 1
			st.border_width_top = 1
			st.border_width_right = 1
			st.border_width_bottom = 1
			st.border_color = Color(0.25, 0.35, 0.48, 0.6)
			btn.add_theme_color_override(&"font_color", Color(0.85, 0.92, 0.98, 1.0))
		btn.add_theme_stylebox_override(&"normal", st)
		btn.add_theme_stylebox_override(&"hover", st)


func _render_drip_cards() -> void:
	if not drip_cards_vbox:
		return

	for child in drip_cards_vbox.get_children():
		child.queue_free()

	match active_drip_tab:
		"outfits":
			var outfit_emojis: Array[String] = ["👕", "👔", "🧥", "💼", "👗"]
			for i in Wardrobe.OUTFITS.size():
				var o: Dictionary = Wardrobe.OUTFITS[i]
				var is_sel: bool = (i == selected_shirt)
				var card := _create_drip_card(
					outfit_emojis[clampi(i, 0, outfit_emojis.size() - 1)],
					o["name"],
					o["description"],
					o.get("top_color", Color(0.12, 0.55, 0.32)),
					o.get("bottom_color", Color(0.15, 0.22, 0.32)),
					is_sel,
					func():
						selected_shirt = i
						_refresh_avatar_preview(true)
						_render_drip_cards()
				)
				drip_cards_vbox.add_child(card)

		"hair":
			var hair_emojis: Array[String] = ["💈", "👑", "🪢", "🧢", "👒"]
			for i in Wardrobe.HAIRSTYLES.size():
				var h: Dictionary = Wardrobe.HAIRSTYLES[i]
				var is_sel: bool = (i == selected_hair)
				var card := _create_drip_card(
					hair_emojis[clampi(i, 0, hair_emojis.size() - 1)],
					h["name"],
					h["description"],
					h.get("default_color", Color(0.08, 0.08, 0.08)),
					h.get("default_color", Color(0.08, 0.08, 0.08)),
					is_sel,
					func():
						selected_hair = i
						_refresh_avatar_preview(true)
						_render_drip_cards()
				)
				drip_cards_vbox.add_child(card)

		"skin":
			var skin_emojis: Array[String] = ["🌰", "🍫", "🍯", "🥜"]
			for i in Wardrobe.COMPLEXIONS.size():
				var s: Dictionary = Wardrobe.COMPLEXIONS[i]
				var is_sel: bool = (i == selected_complexion)
				var card := _create_drip_card(
					skin_emojis[clampi(i, 0, skin_emojis.size() - 1)],
					s["name"],
					"Rich melanin campus complexion tone",
					s["color"],
					s["color"],
					is_sel,
					func():
						selected_complexion = i
						_refresh_avatar_preview(true)
						_render_drip_cards()
				)
				drip_cards_vbox.add_child(card)

		"trousers":
			var trouser_emojis: Array[String] = ["👖", "👖", "👖", "👖"]
			for i in CharacterCustomizer.TROUSER_STYLES.size():
				var tr: Dictionary = CharacterCustomizer.TROUSER_STYLES[i]
				var is_sel: bool = (i == selected_trouser)
				var card := _create_drip_card(
					trouser_emojis[clampi(i, 0, trouser_emojis.size() - 1)],
					tr["name"],
					"Campus lecture trousers and pants",
					tr["color"],
					tr["color"],
					is_sel,
					func():
						selected_trouser = i
						_refresh_avatar_preview(true)
						_render_drip_cards()
				)
				drip_cards_vbox.add_child(card)


func _create_drip_card(
	icon_emoji: String,
	item_title: String,
	item_desc: String,
	top_col: Color,
	bottom_col: Color,
	is_selected: bool,
	on_click: Callable
) -> PanelContainer:
	var card := PanelContainer.new()
	var st := StyleBoxFlat.new()
	st.corner_radius_top_left = 10
	st.corner_radius_top_right = 10
	st.corner_radius_bottom_left = 10
	st.corner_radius_bottom_right = 10
	st.content_margin_left = 12.0
	st.content_margin_top = 8.0
	st.content_margin_right = 12.0
	st.content_margin_bottom = 8.0

	if is_selected:
		st.bg_color = Color(0.18, 0.28, 0.40, 1.0)
		st.border_width_left = 3
		st.border_width_top = 3
		st.border_width_right = 3
		st.border_width_bottom = 3
		st.border_color = Color(1.0, 0.84, 0.22, 1.0)
	else:
		st.bg_color = Color(0.11, 0.17, 0.24, 0.95)
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1
		st.border_color = Color(0.24, 0.34, 0.46, 0.6)

	card.add_theme_stylebox_override(&"panel", st)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override(&"separation", 10)

	# Left Icon Emoji Badge
	var icon_lbl := Label.new()
	icon_lbl.text = icon_emoji
	icon_lbl.add_theme_font_size_override(&"font_size", 24)
	icon_lbl.custom_minimum_size = Vector2(36, 0)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)

	# Center text
	var text_vbox := VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title_lbl := Label.new()
	title_lbl.text = item_title + ("  [✓ EQUIPPED]" if is_selected else "")
	title_lbl.add_theme_font_size_override(&"font_size", 14)
	if is_selected:
		title_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.86, 0.32, 1.0))
	else:
		title_lbl.add_theme_color_override(&"font_color", Color(0.92, 0.96, 1.0, 1.0))
	text_vbox.add_child(title_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = item_desc
	desc_lbl.add_theme_font_size_override(&"font_size", 11)
	desc_lbl.add_theme_color_override(&"font_color", Color(0.72, 0.82, 0.92, 0.85))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(desc_lbl)
	hbox.add_child(text_vbox)

	# Right Color Swatch Indicator (split dual-color pill)
	var swatch_panel := PanelContainer.new()
	swatch_panel.custom_minimum_size = Vector2(28, 28)
	var sw_st := StyleBoxFlat.new()
	sw_st.corner_radius_top_left = 14
	sw_st.corner_radius_top_right = 14
	sw_st.corner_radius_bottom_left = 14
	sw_st.corner_radius_bottom_right = 14
	sw_st.bg_color = top_col
	sw_st.border_width_left = 2
	sw_st.border_width_top = 2
	sw_st.border_width_right = 2
	sw_st.border_width_bottom = 2
	sw_st.border_color = bottom_col
	swatch_panel.add_theme_stylebox_override(&"panel", sw_st)
	hbox.add_child(swatch_panel)

	card.add_child(hbox)

	# Invisible overlay button for easy touch/mouse tapping
	var overlay_btn := Button.new()
	overlay_btn.flat = true
	overlay_btn.focus_mode = Control.FOCUS_NONE
	overlay_btn.anchors_preset = Control.PRESET_FULL_RECT
	overlay_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	overlay_btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	overlay_btn.pressed.connect(on_click)
	card.add_child(overlay_btn)

	return card


func _refresh_avatar_preview(animate_spin: bool = false) -> void:
	var hair_item: Dictionary = Wardrobe.HAIRSTYLES[clampi(selected_hair, 0, Wardrobe.HAIRSTYLES.size() - 1)]
	var outfit_item: Dictionary = Wardrobe.OUTFITS[clampi(selected_shirt, 0, Wardrobe.OUTFITS.size() - 1)]
	var skin_item: Dictionary = Wardrobe.COMPLEXIONS[clampi(selected_complexion, 0, Wardrobe.COMPLEXIONS.size() - 1)]
	var tr_item: Dictionary = CharacterCustomizer.TROUSER_STYLES[clampi(selected_trouser, 0, CharacterCustomizer.TROUSER_STYLES.size() - 1)]

	if avatar_preview_label:
		avatar_preview_label.text = "✨ %s | %s Tone | 💈 %s\n👕 %s  •  👖 %s" % [
			selected_gender, skin_item["name"], hair_item["name"], outfit_item["name"], tr_item["name"]
		]

	if preview_player_instance and preview_player_instance.has_method("apply_appearance"):
		var top_col: Color = outfit_item.get("top_color", Color(0.12, 0.55, 0.32))
		var btm_col: Color = tr_item.get("color", outfit_item.get("bottom_color", Color(0.15, 0.22, 0.32)))
		var hair_col: Color = hair_item.get("default_color", Color(0.08, 0.08, 0.08))
		var apply_fn := func():
			if is_instance_valid(preview_player_instance):
				preview_player_instance.apply_appearance(
					skin_item["color"],
					top_col,
					btm_col,
					hair_col,
					hair_item.get("mesh_type", "low_cut"),
					outfit_item.get("mesh_type", "casual")
				)
		if animate_spin and preview_player_instance.has_method("play_dressing_animation"):
			preview_player_instance.play_dressing_animation(apply_fn)
		else:
			apply_fn.call()


func _on_faculty_selected(idx: int) -> void:
	if idx < 0 or idx >= FACULTY_ORDER.size():
		return
	selected_faculty_id = FACULTY_ORDER[idx]
	var fac_data: Dictionary = AcademicCatalog.FACULTIES[selected_faculty_id]
	current_faculty_dept_codes = fac_data["departments"].duplicate()

	if dept_options:
		dept_options.clear()
		for code in current_faculty_dept_codes:
			var dept_info: Dictionary = AcademicCatalog.get_department(code)
			dept_options.add_item("%s (%s)" % [dept_info["name"], code])
		dept_options.select(0)

	_on_dept_selected(0)


func _on_dept_selected(idx: int) -> void:
	if idx < 0 or idx >= current_faculty_dept_codes.size():
		return
	selected_department = current_faculty_dept_codes[idx]
	var dept_info: Dictionary = AcademicCatalog.get_department(selected_department)
	var redirect_code: String = String(dept_info.get("redirect_dept", "CSC"))
	var redirect_info: Dictionary = AcademicCatalog.get_department(redirect_code)
	var cut_off: int = int(dept_info.get("cut_off_score", 2))

	if dept_desc_label:
		dept_desc_label.text = "🏛️ %s\n📘 Degree: %s\n🎯 Merit Cut-off: %d / 3 Screening Score\n💡 Focus: %s\n🔄 University Board Fallback: If score is below cut-off, posted to %s." % [
			dept_info.get("faculty", "Academic Faculty"),
			dept_info.get("name", "Degree Program"),
			cut_off,
			dept_info.get("description", ""),
			redirect_info.get("name", "Allied Field")
		]


func _update_view() -> void:
	if biodata_panel: biodata_panel.visible = (current_step == Step.BIODATA)
	if avatar_panel: avatar_panel.visible = (current_step == Step.AVATAR)
	if dept_panel: dept_panel.visible = (current_step == Step.DEPARTMENT)
	if screening_panel: screening_panel.visible = (current_step == Step.SCREENING)
	if letter_panel: letter_panel.visible = (current_step == Step.ADMISSION_LETTER)

	if has_node("%PreviewViewport"):
		var vp: SubViewport = %PreviewViewport
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS if (current_step == Step.AVATAR) else SubViewport.UPDATE_DISABLED

	_update_step_navbar()

	match current_step:
		Step.BIODATA:
			step_title_label.text = "🏛️ STUDENT ADMISSIONS PORTAL"
			step_subtitle_label.text = "Step 1 of 5: Candidate Biodata & Registration"
			next_button.visible = true
			next_button.text = "Next: Character Customization ➡️"
		Step.AVATAR:
			step_title_label.text = "🎨 STUDENT AVATAR STYLING"
			step_subtitle_label.text = "Step 2 of 5: Melanin Complexion, Hairstyle & Wardrobe"
			next_button.visible = true
			next_button.text = "Next: Select Academic Course ➡️"
		Step.DEPARTMENT:
			step_title_label.text = "📚 FACULTY & COURSE SELECTION"
			step_subtitle_label.text = "Step 3 of 5: Choose Your First Choice Degree Program"
			next_button.visible = true
			next_button.text = "Begin Post-UTME Screening Quiz 📝"
		Step.SCREENING:
			step_title_label.text = "📝 POST-UTME SCREENING TEST"
			step_subtitle_label.text = "Step 4 of 5: University Aptitude Screening Test"
			next_button.visible = false
		Step.ADMISSION_LETTER:
			step_title_label.text = "📜 PROVISIONAL ADMISSION LETTER"
			step_subtitle_label.text = "Step 5 of 5: Official University Senate Determination"
			next_button.visible = true
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
			# Start screening quiz tailored to candidate's chosen faculty discipline
			quiz_q_idx = 0
			quiz_score = 0
			if SCREENING_QUESTIONS.has(selected_faculty_id):
				active_quiz_questions = SCREENING_QUESTIONS[selected_faculty_id]
			elif SCREENING_QUESTIONS.has(selected_department):
				active_quiz_questions = SCREENING_QUESTIONS[selected_department]
			else:
				active_quiz_questions = SCREENING_QUESTIONS["CMP_FAC"]
			current_step = Step.SCREENING
			_update_view()
			_load_screening_question()
		Step.SCREENING:
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
		screening_progress_label.text = "Screening Question %d of %d  •  Current Score: %d / %d" % [
			quiz_q_idx + 1, active_quiz_questions.size(), quiz_score, quiz_q_idx
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
		btn.custom_minimum_size = Vector2(0, 54)
		btn.add_theme_font_size_override(&"font_size", 15)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.focus_mode = Control.FOCUS_NONE

		var btn_st := StyleBoxFlat.new()
		btn_st.bg_color = Color(0.12, 0.19, 0.28, 0.95)
		btn_st.border_width_left = 2
		btn_st.border_width_top = 2
		btn_st.border_width_right = 2
		btn_st.border_width_bottom = 2
		btn_st.border_color = Color(0.25, 0.38, 0.52, 0.8)
		btn_st.corner_radius_top_left = 10
		btn_st.corner_radius_top_right = 10
		btn_st.corner_radius_bottom_left = 10
		btn_st.corner_radius_bottom_right = 10
		btn_st.content_margin_left = 16.0
		btn_st.content_margin_right = 16.0
		btn.add_theme_stylebox_override(&"normal", btn_st)
		btn.add_theme_stylebox_override(&"hover", btn_st)

		btn.pressed.connect(_on_quiz_option_chosen.bind(i))
		options_container.add_child(btn)


func _on_quiz_option_chosen(opt_idx: int) -> void:
	if is_quiz_answering:
		return
	is_quiz_answering = true

	var q: Dictionary = active_quiz_questions[quiz_q_idx]
	var correct_idx: int = int(q.get("correct", 0))
	var is_correct: bool = (opt_idx == correct_idx)

	# Disable all option buttons to avoid spam
	var option_buttons := options_container.get_children()
	for btn_node in option_buttons:
		if btn_node is Button:
			btn_node.disabled = true

	# Style the chosen button and correct button
	if opt_idx < option_buttons.size() and option_buttons[opt_idx] is Button:
		var chosen_btn: Button = option_buttons[opt_idx] as Button
		if is_correct:
			var success_style := StyleBoxFlat.new()
			success_style.bg_color = Color(0.10, 0.62, 0.32, 1.0)
			success_style.border_width_left = 3
			success_style.border_width_top = 3
			success_style.border_width_right = 3
			success_style.border_width_bottom = 3
			success_style.border_color = Color(1.0, 0.84, 0.25, 1.0)
			success_style.corner_radius_top_left = 10
			success_style.corner_radius_top_right = 10
			success_style.corner_radius_bottom_left = 10
			success_style.corner_radius_bottom_right = 10
			chosen_btn.add_theme_stylebox_override(&"disabled", success_style)
			chosen_btn.text = "✅  %s  (+1 MARK!)" % chosen_btn.text
			quiz_score += 1
			if SoundManager:
				SoundManager.play_bell()
		else:
			var wrong_style := StyleBoxFlat.new()
			wrong_style.bg_color = Color(0.78, 0.18, 0.18, 1.0)
			wrong_style.border_width_left = 2
			wrong_style.border_width_top = 2
			wrong_style.border_width_right = 2
			wrong_style.border_width_bottom = 2
			wrong_style.border_color = Color(1.0, 0.5, 0.5, 1.0)
			wrong_style.corner_radius_top_left = 10
			wrong_style.corner_radius_top_right = 10
			wrong_style.corner_radius_bottom_left = 10
			wrong_style.corner_radius_bottom_right = 10
			chosen_btn.add_theme_stylebox_override(&"disabled", wrong_style)
			chosen_btn.text = "❌  %s  (INCORRECT)" % chosen_btn.text
			if SoundManager:
				SoundManager.play_click()

			# Highlight the correct answer for student learning
			if correct_idx < option_buttons.size() and option_buttons[correct_idx] is Button:
				var correct_btn: Button = option_buttons[correct_idx] as Button
				var hint_style := StyleBoxFlat.new()
				hint_style.bg_color = Color(0.12, 0.44, 0.28, 0.95)
				hint_style.border_width_left = 2
				hint_style.border_width_top = 2
				hint_style.border_width_right = 2
				hint_style.border_width_bottom = 2
				hint_style.border_color = Color(0.3, 0.9, 0.5, 1.0)
				hint_style.corner_radius_top_left = 10
				hint_style.corner_radius_top_right = 10
				hint_style.corner_radius_bottom_left = 10
				hint_style.corner_radius_bottom_right = 10
				correct_btn.add_theme_stylebox_override(&"disabled", hint_style)
				correct_btn.text = "✓ Correct Answer: %s" % correct_btn.text

	if screening_progress_label:
		screening_progress_label.text = "Screening Question %d of %d  •  Current Score: %d / %d" % [
			quiz_q_idx + 1, active_quiz_questions.size(), quiz_score, quiz_q_idx + 1
		]

	await get_tree().create_timer(0.75).timeout
	is_quiz_answering = false
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

		var letter_content: String = """[center][color=#ffd54f][font_size=18][b]🎉 CONGRATULATIONS, %s! 🎉[/b][/font_size][/color]
[color=#7ef29d][b]MATRIC NO: %s  •  SCREENING SCORE: %d%%[/b][/color][/center]

[color=#ffd54f][b]🏛️ ADMITTED DEGREE PROGRAM:[/b][/color]
[b]🎓 %s[/b] (%s)
[color=#b8d4e8]%s[/color]

[color=#ffd54f][b]💳 STUDENT LIFESTYLE & SPONSOR PACK:[/b][/color]
%s [b]%s[/b]
💰 [color=#69f0ae][b]Starting Wallet: ₦%s[/b][/color]   •   📱 [b]%s[/b]
[color=#b8d4e8][i]"%s"[/i][/color]

[color=#ffd54f][b]🚀 YOUR FIRST 3 CAMPUS GOALS:[/b][/color]
1️⃣ Try on a fresh outfit at your [b]Hostel Wardrobe[/b] (+₦500 Bonus)
2️⃣ Greet your [b]Hostel Roommate[/b] (+₦500 Bonus)
3️⃣ Catch the [b]Danfo Shuttle[/b] to Faculty Hall LT1 (+₦500 Bonus)""" % [student_n.to_upper(), matric, score_pct, admitted_title, admitted_fac, remark, spawn_badge, spawn_t, formatted_allowance, spawn_phone, spawn_tag]

		letter_text_label.text = letter_content


func _complete_onboarding_and_start_game() -> void:
	SoundManager.play_transit_horn()
	onboarding_completed.emit(StudentProfile.get_profile_data())

	# Transition to the student hostel room
	var err: Error = get_tree().change_scene_to_file("res://scenes/rooms/hostel_room.tscn")
	if err != OK:
		push_error("Failed to load hostel room: %d" % err)
