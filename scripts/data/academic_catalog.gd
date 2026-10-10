class_name AcademicCatalog
extends RefCounted

## Academic Catalog for Campus Life Simulator.
## Contains editable departments, courses, credit units, CA test questions, and grading standards.
## You can easily add more departments or courses here without touching any game engine code.

const DEPARTMENTS: Dictionary = {
	"CSC": {
		"name": "Computer Science",
		"faculty": "Science & Computing",
		"description": "Coding, algorithms, systems architecture, and relentless debugging.",
		"courses": [
			{
				"code": "CSC 101",
				"title": "Introduction to Computer Science",
				"units": 3,
				"lecturer": "Dr. Adebayo",
				"schedule_time": "09:00 - 11:00",
				"time_start": 9 * 60,
				"time_end": 11 * 60,
				"ca_weight": 30, # Continuous Assessment (out of 30)
				"exam_weight": 70 # Final Exam (out of 70)
			},
			{
				"code": "CSC 104",
				"title": "Algorithms & Software Engineering",
				"units": 3,
				"lecturer": "Mr. Adepoju Marvellous",
				"schedule_time": "11:30 - 13:00",
				"time_start": 11 * 60 + 30,
				"time_end": 13 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "MTH 101",
				"title": "Elementary Mathematics (Calculus)",
				"units": 4,
				"lecturer": "Prof. Okonjo",
				"schedule_time": "14:00 - 16:00",
				"time_start": 14 * 60,
				"time_end": 16 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "GST 101",
				"title": "Use of English & Communication Skills",
				"units": 2,
				"lecturer": "Mrs. Folashade",
				"schedule_time": "11:30 - 13:00",
				"time_start": 11 * 60 + 30,
				"time_end": 13 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "UNI 101",
				"title": "Campus Survival & Street Smarts",
				"units": 2,
				"lecturer": "Comrade Aluta & Hall Warden",
				"schedule_time": "16:30 - 18:00",
				"time_start": 16 * 60 + 30,
				"time_end": 18 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "GST 102",
				"title": "Nigerian Peoples & Culture",
				"units": 2,
				"lecturer": "Prof. Babatunde",
				"schedule_time": "14:00 - 15:30",
				"time_start": 14 * 60,
				"time_end": 15 * 60 + 30,
				"ca_weight": 30,
				"exam_weight": 70
			}
		]
	},
	"MAC": {
		"name": "Mass Communication",
		"faculty": "Social Sciences",
		"description": "Broadcasting, media ethics, campus journalism, and public speech.",
		"courses": [
			{
				"code": "MAC 101",
				"title": "Introduction to Mass Communication",
				"units": 3,
				"lecturer": "Dr. Chioma",
				"schedule_time": "09:00 - 11:00",
				"time_start": 9 * 60,
				"time_end": 11 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "MAC 103",
				"title": "Writing for the Media",
				"units": 3,
				"lecturer": "Mr. Bankole",
				"schedule_time": "14:00 - 16:00",
				"time_start": 14 * 60,
				"time_end": 16 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "GST 101",
				"title": "Use of English & Communication Skills",
				"units": 2,
				"lecturer": "Mrs. Folashade",
				"schedule_time": "11:30 - 13:00",
				"time_start": 11 * 60 + 30,
				"time_end": 13 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "UNI 101",
				"title": "Campus Survival & Street Smarts",
				"units": 2,
				"lecturer": "Comrade Aluta & Hall Warden",
				"schedule_time": "16:30 - 18:00",
				"time_start": 16 * 60 + 30,
				"time_end": 18 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "GST 102",
				"title": "Nigerian Peoples & Culture",
				"units": 2,
				"lecturer": "Prof. Babatunde",
				"schedule_time": "14:00 - 15:30",
				"time_start": 14 * 60,
				"time_end": 15 * 60 + 30,
				"ca_weight": 30,
				"exam_weight": 70
			}
		]
	},
	"ECN": {
		"name": "Economics",
		"faculty": "Social & Management Sciences",
		"description": "Microeconomics, macroeconomic theory, finance, and Nigerian fiscal policy.",
		"courses": [
			{
				"code": "ECN 101",
				"title": "Principles of Economics I",
				"units": 3,
				"lecturer": "Dr. Sanusi",
				"schedule_time": "09:00 - 11:00",
				"time_start": 9 * 60,
				"time_end": 11 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "ACC 101",
				"title": "Introduction to Financial Accounting",
				"units": 3,
				"lecturer": "Mrs. Alabi",
				"schedule_time": "14:00 - 16:00",
				"time_start": 14 * 60,
				"time_end": 16 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "GST 101",
				"title": "Use of English & Communication Skills",
				"units": 2,
				"lecturer": "Mrs. Folashade",
				"schedule_time": "11:30 - 13:00",
				"time_start": 11 * 60 + 30,
				"time_end": 13 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "UNI 101",
				"title": "Campus Survival & Street Smarts",
				"units": 2,
				"lecturer": "Comrade Aluta & Hall Warden",
				"schedule_time": "16:30 - 18:00",
				"time_start": 16 * 60 + 30,
				"time_end": 18 * 60,
				"ca_weight": 30,
				"exam_weight": 70
			},
			{
				"code": "GST 102",
				"title": "Nigerian Peoples & Culture",
				"units": 2,
				"lecturer": "Prof. Babatunde",
				"schedule_time": "14:00 - 15:30",
				"time_start": 14 * 60,
				"time_end": 15 * 60 + 30,
				"ca_weight": 30,
				"exam_weight": 70
			}
		]
	}
}

## Nigerian 5.0 CGPA Scale Standard
static func calculate_grade_point(score: float) -> Dictionary:
	if score >= 70.0:
		return {"grade": "A", "point": 5.0, "remark": "Excellent"}
	elif score >= 60.0:
		return {"grade": "B", "point": 4.0, "remark": "Very Good"}
	elif score >= 50.0:
		return {"grade": "C", "point": 3.0, "remark": "Good"}
	elif score >= 45.0:
		return {"grade": "D", "point": 2.0, "remark": "Fair"}
	elif score >= 40.0:
		return {"grade": "E", "point": 1.0, "remark": "Pass"}
	else:
		return {"grade": "F", "point": 0.0, "remark": "Fail"}

