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

	save_to_disk()
	return placement


static func _calculate_placement(first_dept: String, score: int) -> Dictionary:
	# Cut-off is 66% (2 out of 3 screening questions)
	var passed_merit: bool = score >= 66

	match first_dept:
		"CSC": # Computer Science (High Cut-off)
			if passed_merit:
				return {
					"dept": "CSC",
					"title": "Computer Science (B.Sc)",
					"faculty": "Science & Computing",
					"remark": "🎉 Merit List! Qualified for First Choice Computer Science!"
				}
			else:
				# Reassigned to Library Information Science or Computer Education
				return {
					"dept": "LIS",
					"title": "Library & Information Science (B.Sc)",
					"faculty": "Education & Information Tech",
					"remark": "⚠️ Transferred! Cut-off missed for CSC. Reassigned to Library & Information Science."
				}
		"MAC": # Mass Communication
			if passed_merit:
				return {
					"dept": "MAC",
					"title": "Mass Communication (B.Sc)",
					"faculty": "Social Sciences",
					"remark": "🎉 Merit List! Admitted to Mass Communication!"
				}
			else:
				return {
					"dept": "LIN",
					"title": "Linguistics & African Languages (B.A)",
					"faculty": "Faculty of Arts",
					"remark": "⚠️ Transferred! Cut-off missed for Mass Comm. Reassigned to Linguistics & Languages."
				}
		"ECN": # Economics
			if passed_merit:
				return {
					"dept": "ECN",
					"title": "Economics (B.Sc)",
					"faculty": "Social & Management Sciences",
					"remark": "🎉 Merit List! Admitted to Economics!"
				}
			else:
				return {
					"dept": "PUB",
					"title": "Public Administration (B.Sc)",
					"faculty": "Management Sciences",
					"remark": "⚠️ Transferred! Cut-off missed for Economics. Reassigned to Public Administration."
				}
		_:
			return {
				"dept": first_dept,
				"title": "General Studies (B.Sc)",
				"faculty": "Basic Sciences",
				"remark": "Admitted via Supplementary List."
			}


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
		"admission_remark": admission_remark
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
	return true

