class_name StudentCoursework
extends RefCounted

## Manages practical semester coursework, lab reports, and term projects.
## In Nigerian universities, practical coursework provides 30 marks of the student's grade.
## Completing projects through practical activities eliminates boring written trivia tests!

const SAVE_PATH: String = "user://student_coursework.json"

static var project_title: String = "Coursework Term Paper"
static var department: String = "CSC"
static var progress: float = 0.0 # 0.0 to 100.0
static var milestone_step: int = 0
static var is_submitted: bool = false
static var score_awarded: float = 0.0 # Up to 30.0 Continuous Assessment marks

const MILESTONES: Array[String] = [
	"1. Literature Review & Proposal Drafting",
	"2. Practical Lab Work / Prototype Building",
	"3. Final Report Proofreading & Spiral Binding"
]

const DEPARTMENT_PROJECTS: Dictionary = {
	"CSC": "Design & Build Campus Emergency Response Web App",
	"SEN": "Full-Stack Microservices Architecture for Student Records",
	"CYB": "Penetration Testing & Network Security Audit of Campus Wi-Fi",
	"IFT": "Campus Fibre Optic Backbone & Server Infrastructure Plan",
	"DAT": "Predictive Machine Learning Model for Student Academic Performance",
	"MEE": "Design & CAD Simulation of Solar-Powered Farm Tractor",
	"EEE": "Smart IoT Energy Inverter with Automatic NEPA Phase Selector",
	"CVE": "Structural Concrete Analysis for Multi-Story Lecture Auditorium",
	"PET": "Reservoir Simulation & Offshore Drilling Efficiency Model",
	"AEE": "Aerodynamic Wind Tunnel Testing of Autonomous Drone Wing",
	"LAW": "Moot Court Appellate Legal Brief & Constitutional Precedents",
	"MED": "Epidemiological Fieldwork Study on Malaria Prevention in Hostels",
	"NUR": "Clinical Patient Triage Protocols in Rural University Clinics",
	"PBL": "Community Clean Water Assessment & Borehole Sanitation Audit",
	"MLS": "Hematology Laboratory Analysis of Blood Film Pathologies",
	"ANA": "3D Neurological Mapping of Cranial Nerve Pathways",
	"BCH": "Enzymatic Hydrolysis Assay of Fermented Cassava Tubers",
	"MCB": "Isolation of Antibiotic-Resistant Bacteria in Hospital Waste",
	"CHM": "Spectrophotometric Chemical Assay of Industrial Effluents",
	"PHY": "Quantum Semiconductor Fabrication Simulation for Solar Cells",
	"MTH": "Numerical Solutions to Non-Linear Navier-Stokes Equations",
	"ECO": "Econometric Assessment of Inflation on Student Purchasing Power",
	"ACC": "Forensic Financial Audit & Taxation Ledger Simulation",
	"BUS": "Feasibility Study & Venture Capital Pitch for Student Campus Brand",
	"POL": "Comparative Electoral Systems & Democratic Governance in West Africa",
	"SOC": "Urban Sociological Study of Student Migration & Living Conditions",
	"PSY": "Cognitive Behavioral Analysis of Exam Anxiety in Undergraduates",
	"ENG": "Post-Colonial Narrative Structures in Contemporary Nigerian Fiction",
	"HIS": "Documentary Archival History of Trade Routes along the River Niger",
	"PHL": "Epistemological Ethics in Artificial Intelligence & Autonomous Agents",
	"REL": "Comparative Theological Ethics & Inter-Faith Peacemaking in Africa",
	"CRS": "Biblical Ethics of Justice and Integrity in Public Service",
	"ISL": "Principles of Islamic Jurisprudence in Modern Commercial Contracts",
	"MUS": "Afrobeats Rhythmic Polyphony and Contemporary Highlife Fusion"
}

static func initialize_for_department(dept_code: String) -> void:
	load_from_disk()
	department = dept_code
	if DEPARTMENT_PROJECTS.has(dept_code):
		project_title = DEPARTMENT_PROJECTS[dept_code]
	else:
		project_title = "Departmental Practical Research & Term Paper"
	save_to_disk()

static func get_current_project() -> Dictionary:
	load_from_disk()
	return {
		"title": project_title,
		"department": department,
		"progress": progress,
		"milestone_index": milestone_step,
		"is_submitted": is_submitted,
		"score_awarded": score_awarded,
		"milestones": [
			{"title": MILESTONES[0]},
			{"title": MILESTONES[1]},
			{"title": MILESTONES[2]}
		]
	}

static func get_project_progress() -> float:
	load_from_disk()
	return progress

static func work_on_milestone(work_amount: float = 35.0) -> Dictionary:
	load_from_disk()
	if is_submitted:
		return {"progress": 100.0, "is_submitted": true, "score": score_awarded, "message": "Already submitted to Department Pigeonhole!"}

	progress = minf(100.0, progress + work_amount)
	if progress >= 33.3 and milestone_step == 0:
		milestone_step = 1
	elif progress >= 66.6 and milestone_step == 1:
		milestone_step = 2

	var just_finished: bool = false
	if progress >= 100.0:
		is_submitted = true
		score_awarded = 30.0 # Maximum 30 marks Continuous Assessment
		just_finished = true

	save_to_disk()
	return {
		"progress": progress,
		"milestone_step": milestone_step,
		"is_submitted": is_submitted,
		"just_finished": just_finished,
		"score": score_awarded
	}

static func save_to_disk() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return
	var data = {
		"project_title": project_title,
		"department": department,
		"progress": progress,
		"milestone_step": milestone_step,
		"is_submitted": is_submitted,
		"score_awarded": score_awarded
	}
	file.store_string(JSON.stringify(data))
	file.close()

static func load_from_disk() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var txt = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(txt) != OK:
		return false
	var d = json.data as Dictionary
	if not d:
		return false
	project_title = String(d.get("project_title", project_title))
	department = String(d.get("department", department))
	progress = float(d.get("progress", progress))
	milestone_step = int(d.get("milestone_step", milestone_step))
	is_submitted = bool(d.get("is_submitted", is_submitted))
	score_awarded = float(d.get("score_awarded", score_awarded))
	return true
