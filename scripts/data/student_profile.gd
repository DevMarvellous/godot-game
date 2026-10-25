class_name StudentProfile
extends RefCounted

## Global Persistent Student Identity & Academic Profile.
## Stores player personal details, physical avatar customized appearance,
## admission test evaluation result, admitted course, faculty, matric number, and email.

static var student_name: String = "Femi"
static var student_email: String = "femi.student@campus.edu.ng"
static var gender: String = "Male"
static var complexion_index: int = 1 # 0: Rich Cocoa, 1: Warm Chestnut, 2: Golden Bronze, 3: Honey Almond
static var hair_index: int = 0
static var shirt_index: int = 0
static var trouser_index: int = 0

# Academic placement & Admission details
static var first_choice_department: String = "CSC"
static var admitted_department: String = "CSC"
static var admitted_course_title: String = "Computer Science"
static var admitted_faculty: String = "Science & Computing"
static var matric_no: String = "CSC/2026/042"
static var utme_screening_score: int = 100 # percentage score from admission aptitude test
static var admission_remark: String = "Merit List Direct Admission"

# My Campus Life style asymmetric Matriculation Spawns
static var spawn_title: String = "Average Hustler (Indomie Sponsor)"
static var spawn_allowance: int = 30000
static var spawn_phone_model: String = "Tecno Spark 10"
static var spawn_tagline: String = "Standard fresher budget. Balance Mama Put meals with lecture CA tests."
static var spawn_badge: String = "🎒"

# Persistent Hostel Room Upgrades & Achievements
static var owned_upgrades: Array[String] = []
static var merit_scholarship_claimed: bool = false
static var cgpa: float = 3.50
static var money: int = 5000

# Persistent Backpack & Supplies Inventory
static var backpack_items: Array[Dictionary] = [
	{
		"id": "pure_water_cabin",
		"name": "Pure Water & Cabin Biscuit",
		"type": "food",
		"hunger": 18.0,
		"energy": 10.0,
		"desc": "Fresher emergency survival pack (Chilled water + crunchy biscuits).",
		"count": 2
	}
]

# Endless Sandbox Progression & Degree Status
static var current_level: int = 100 # 100, 200, 300, 400, 500 (Postgrad/Alumnus)
static var current_semester: int = 1 # 1 or 2
static var degree_awarded: String = "" # e.g. "B.Sc Computer Science (First Class Honours)"

const SAVE_PATH: String = "user://student_profile.json"

static func apply_admission(
	p_name: String,
	p_email: String,
	p_gender: String,
	p_complexion: int,
	p_hair: int,
	p_shirt: int,
	p_trouser: int,
	p_first_choice_dept: String,
	p_quiz_score: int
) -> Dictionary:
	student_name = p_name.strip_edges() if p_name.strip_edges() != "" else "Fresh Student"
	student_email = p_email.strip_edges() if p_email.strip_edges() != "" else "%s@campus.edu.ng" % student_name.to_lower().replace(" ", ".")
	gender = p_gender
	complexion_index = p_complexion
	hair_index = p_hair
	shirt_index = p_shirt
	trouser_index = p_trouser
	first_choice_department = p_first_choice_dept
	utme_screening_score = p_quiz_score

	# Realistic Nigerian University Admission Cut-off & Reassignment Matrix
	# If student passes aptitude screening (>= 67%), they get their primary dream course!
	# If below cut-off, University Admissions Board reassigns them to a related secondary course
	var placement: Dictionary = _calculate_placement(first_choice_department, utme_screening_score)
	admitted_department = placement["dept"]
	admitted_course_title = placement["title"]
	admitted_faculty = placement["faculty"]
	admission_remark = placement["remark"]

	# Generate realistic Nigerian matriculation number
	var random_matric_id: int = randi_range(101, 899)
	matric_no = "%s/2026/%03d" % [admitted_department, random_matric_id]

	# Roll asymmetric Matriculation Spawn Background (My Campus Life mechanic)
	var roll: int = randi_range(1, 100)
	if roll <= 10:
		spawn_title = "The Chief's Child / Scholarship Kid"
		spawn_allowance = 250000
		spawn_phone_model = "iPhone 15 Pro Max"
		spawn_tagline = "Heavy pockets & VIP Bistro dining! High family expectations: maintain 4.5+ CGPA or monthly allowance stops."
		spawn_badge = "👑"
	elif roll <= 70:
		spawn_title = "Average Hustler (Indomie Sponsor)"
		spawn_allowance = 30000
		spawn_phone_model = "Tecno Spark 10"
		spawn_tagline = "Standard fresher budget. Must balance Mama Put dining, hostel cooking, and handout purchases."
		spawn_badge = "🎒"
	else:
		spawn_title = "Sapa Fighter (Self-Sponsored Fresher)"
		spawn_allowance = 4000
		spawn_phone_model = "Cracked Android (Itel)"
		spawn_tagline = "Broke fresher! Must hustle campus odd jobs (POS attendant, assignments, styling) to survive the semester."
		spawn_badge = "🔥"

	money = spawn_allowance
	cgpa = 3.50
	save_to_disk()
	placement["spawn_title"] = spawn_title
	placement["spawn_allowance"] = spawn_allowance
	placement["spawn_phone_model"] = spawn_phone_model
	placement["spawn_tagline"] = spawn_tagline
	placement["spawn_badge"] = spawn_badge
	return placement


const AcademicCatalog = preload("res://scripts/data/academic_catalog.gd")

static func _calculate_placement(first_dept: String, score_pct: int) -> Dictionary:
	var dept_data: Dictionary = AcademicCatalog.get_department(first_dept)
	var dept_name: String = String(dept_data.get("name", "General Studies"))
	var dept_fac: String = String(dept_data.get("faculty", "Academic Faculty"))
	var required_cut_off: int = int(dept_data.get("cut_off_score", 2))
	
	# Determine if student passed merit cut-off (assuming 3 questions total)
	# cut_off 3 -> 100%, cut_off 2 -> 66%, cut_off 1 -> 33%
	var required_pct: int = int((float(required_cut_off) / 3.0) * 100.0)
	var passed_merit: bool = score_pct >= (required_pct - 5)

	if passed_merit:
		return {
			"dept": first_dept,
			"title": "%s (First Choice)" % dept_name,
			"faculty": dept_fac,
			"remark": "🎉 Merit List Direct Admission! Qualified for first choice %s!" % dept_name
		}
	else:
		# University Admissions Board reassignment to allied fallback program
		var redirect_code: String = String(dept_data.get("redirect_dept", "CSC"))
		var redirect_data: Dictionary = AcademicCatalog.get_department(redirect_code)
		var redirect_name: String = String(redirect_data.get("name", "Allied Studies"))
		var redirect_fac: String = String(redirect_data.get("faculty", "Academic Faculty"))
		return {
			"dept": redirect_code,
			"title": "%s (Allied Transfer)" % redirect_name,
			"faculty": redirect_fac,
			"remark": "⚠️ University Senate Posting: Merit cut-off missed for %s (%d%% required). Transferred & posted to allied degree: %s." % [dept_name, required_pct, redirect_name]
		}


static func add_backpack_item(item: Dictionary) -> void:
	var item_id: String = String(item.get("id", ""))
	for existing: Dictionary in backpack_items:
		if String(existing.get("id", "")) == item_id:
			existing["count"] = int(existing.get("count", 1)) + int(item.get("count", 1))
			save_to_disk()
			return
	var new_entry: Dictionary = item.duplicate()
	if not new_entry.has("count"):
		new_entry["count"] = 1
	backpack_items.append(new_entry)
	save_to_disk()


static func remove_backpack_item(item_id: String, amount: int = 1) -> bool:
	for i in range(backpack_items.size() - 1, -1, -1):
		if String(backpack_items[i].get("id", "")) == item_id:
			var cnt: int = int(backpack_items[i].get("count", 1)) - amount
			if cnt <= 0:
				backpack_items.remove_at(i)
			else:
				backpack_items[i]["count"] = cnt
			save_to_disk()
			return true
	return false


static func get_backpack_items() -> Array[Dictionary]:
	return backpack_items


static func consume_backpack_food(player: CharacterBody3D, item_id: String) -> Dictionary:
	for i in range(backpack_items.size() - 1, -1, -1):
		var it: Dictionary = backpack_items[i]
		if String(it.get("id", "")) == item_id:
			var hunger: float = float(it.get("hunger", 30.0))
			var energy: float = float(it.get("energy", 10.0))
			var item_name: String = String(it.get("name", "Snack"))

			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_hunger(hunger)
					needs.modify_energy(energy)
				if player.has_method("play_eating_animation"):
					player.play_eating_animation()

			var cnt: int = int(it.get("count", 1)) - 1
			if cnt <= 0:
				backpack_items.remove_at(i)
			else:
				it["count"] = cnt
			save_to_disk()
			return { "success": true, "name": item_name, "hunger": hunger, "energy": energy }
	return { "success": false }


static func to_dictionary() -> Dictionary:
	return get_profile_data()


static func get_profile_data() -> Dictionary:
	return {
		"student_name": student_name,
		"student_email": student_email,
		"gender": gender,
		"complexion_index": complexion_index,
		"hair_index": hair_index,
		"shirt_index": shirt_index,
		"trouser_index": trouser_index,
		"first_choice_dept": first_choice_department,
		"admitted_dept": admitted_department,
		"admitted_course_title": admitted_course_title,
		"admitted_faculty": admitted_faculty,
		"matric_no": matric_no,
		"utme_screening_score": utme_screening_score,
		"admission_remark": admission_remark,
		"spawn_title": spawn_title,
		"spawn_allowance": spawn_allowance,
		"spawn_phone_model": spawn_phone_model,
		"spawn_tagline": spawn_tagline,
		"spawn_badge": spawn_badge,
		"cgpa": cgpa,
		"money": money,
		"owned_upgrades": owned_upgrades,
		"merit_scholarship_claimed": merit_scholarship_claimed,
		"backpack_items": backpack_items,
		"current_level": current_level,
		"current_semester": current_semester,
		"degree_awarded": degree_awarded
	}


static func save_to_disk() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_str: String = JSON.stringify(get_profile_data(), "\t")
		file.store_string(json_str)
		file.close()


static func load_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var json_str: String = file.get_as_text()
	file.close()
	var test_json: JSON = JSON.new()
	var err: Error = test_json.parse(json_str)
	if err != OK or not (test_json.data is Dictionary):
		return false

	var d: Dictionary = test_json.data
	student_name = String(d.get("student_name", "Femi"))
	student_email = String(d.get("student_email", "femi@campus.edu.ng"))
	gender = String(d.get("gender", "Male"))
	complexion_index = int(d.get("complexion_index", 1))
	hair_index = int(d.get("hair_index", 0))
	shirt_index = int(d.get("shirt_index", 0))
	trouser_index = int(d.get("trouser_index", 0))
	first_choice_department = String(d.get("first_choice_dept", "CSC"))
	admitted_department = String(d.get("admitted_dept", "CSC"))
	admitted_course_title = String(d.get("admitted_course_title", "Computer Science"))
	admitted_faculty = String(d.get("admitted_faculty", "Science & Computing"))
	matric_no = String(d.get("matric_no", "CSC/2026/042"))
	utme_screening_score = int(d.get("utme_screening_score", 100))
	admission_remark = String(d.get("admission_remark", "Merit List Direct Admission"))
	spawn_title = String(d.get("spawn_title", "Average Hustler (Indomie Sponsor)"))
	spawn_allowance = int(d.get("spawn_allowance", 30000))
	spawn_phone_model = String(d.get("spawn_phone_model", "Tecno Spark 10"))
	spawn_tagline = String(d.get("spawn_tagline", "Standard fresher budget. Balance Mama Put meals with lecture CA tests."))
	spawn_badge = String(d.get("spawn_badge", "🎒"))
	cgpa = float(d.get("cgpa", 3.50))
	money = int(d.get("money", 5000))

	owned_upgrades.clear()
	var raw_upgrades = d.get("owned_upgrades", [])
	if raw_upgrades is Array:
		for up in raw_upgrades:
			owned_upgrades.append(String(up))
	merit_scholarship_claimed = bool(d.get("merit_scholarship_claimed", false))

	backpack_items.clear()
	var raw_items = d.get("backpack_items", [])
	if raw_items is Array:
		for it in raw_items:
			if it is Dictionary:
				backpack_items.append(it)
	if backpack_items.is_empty():
		backpack_items.append({
			"id": "pure_water_cabin",
			"name": "Pure Water & Cabin Biscuit",
			"type": "food",
			"hunger": 18.0,
			"energy": 10.0,
			"desc": "Fresher emergency survival pack (Chilled water + crunchy biscuits).",
			"count": 2
		})

	current_level = int(d.get("current_level", 100))
	current_semester = int(d.get("current_semester", 1))
	degree_awarded = String(d.get("degree_awarded", ""))
	return true


