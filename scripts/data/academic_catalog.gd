class_name AcademicCatalog
extends RefCounted

## Academic Catalog for Campus Life Simulator.
## Contains editable faculties, departments, courses, credit units, and grading standards.
## 100% Data-Driven: You can add, edit, or remove departments/courses here without touching any scene files.

const FACULTIES: Dictionary = {
	"ENG_FAC": {
		"name": "Faculty of Engineering",
		"departments": ["MEE", "EEE", "CVE", "PET", "CPE", "ASE"]
	},
	"CMP_FAC": {
		"name": "Faculty of Computing",
		"departments": ["CSC", "SWE", "CYS", "IFT", "DSC"]
	},
	"LAW_FAC": {
		"name": "Faculty of Law",
		"departments": ["LAW", "CCL"]
	},
	"SMS_FAC": {
		"name": "Faculty of Social & Management Sciences",
		"departments": ["ECN", "ACC", "MAC", "BUS", "POL", "PSY"]
	},
	"NAS_FAC": {
		"name": "Faculty of Natural & Applied Sciences",
		"departments": ["MTH", "PHY", "BCH", "MCB", "ICH", "GLY"]
	},
	"MED_FAC": {
		"name": "Faculty of Health & Medical Sciences",
		"departments": ["MBBS", "NSC", "PHM", "MLS", "PBH"]
	},
	"HUM_FAC": {
		"name": "Faculty of Humanities & Arts",
		"departments": ["ENG", "HIS", "PHL", "CRS"]
	}
}

const DEPARTMENTS: Dictionary = {
	# --- 1. FACULTY OF ENGINEERING ---
	"MEE": {
		"name": "Mechanical Engineering",
		"faculty": "Faculty of Engineering",
		"faculty_id": "ENG_FAC",
		"description": "Engines, thermodynamics, machine design, and workshop fabrication.",
		"cut_off_score": 2,
		"redirect_dept": "MTH",
		"courses": [
			{"code": "MEE 101", "title": "Applied Mechanics & Statics", "units": 3, "lecturer": "Engr. Balogun", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MEE 102", "title": "Engineering Drawing & CAD", "units": 2, "lecturer": "Engr. Okafor", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"EEE": {
		"name": "Electrical & Electronics Engineering",
		"faculty": "Faculty of Engineering",
		"faculty_id": "ENG_FAC",
		"description": "Circuit theory, electromagnetism, power grids, and digital electronics.",
		"cut_off_score": 2,
		"redirect_dept": "PHY",
		"courses": [
			{"code": "EEE 101", "title": "Circuit Analysis I", "units": 3, "lecturer": "Dr. Adeleke", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "PHY 101", "title": "General Physics (Mechanics & Heat)", "units": 3, "lecturer": "Dr. Nnamdi", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"CVE": {
		"name": "Civil Engineering",
		"faculty": "Faculty of Engineering",
		"faculty_id": "ENG_FAC",
		"description": "Structures, bridge design, surveying, and building materials.",
		"cut_off_score": 2,
		"redirect_dept": "GLY",
		"courses": [
			{"code": "CVE 101", "title": "Strength of Materials", "units": 3, "lecturer": "Engr. Bello", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MEE 102", "title": "Engineering Drawing & Surveying", "units": 2, "lecturer": "Engr. Okafor", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"PET": {
		"name": "Petroleum Engineering",
		"faculty": "Faculty of Engineering",
		"faculty_id": "ENG_FAC",
		"description": "Drilling technology, oil reservoir simulations, and Niger Delta geology.",
		"cut_off_score": 2,
		"redirect_dept": "ICH",
		"courses": [
			{"code": "PET 101", "title": "Introduction to Petroleum Operations", "units": 3, "lecturer": "Dr. Tari", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "General Physical Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"CPE": {
		"name": "Computer Engineering",
		"faculty": "Faculty of Engineering",
		"faculty_id": "ENG_FAC",
		"description": "Hardware architecture, logic circuits, microprocessors, and robotics.",
		"cut_off_score": 2,
		"redirect_dept": "CSC",
		"courses": [
			{"code": "CPE 101", "title": "Digital Logic & Computer Systems", "units": 3, "lecturer": "Engr. Segun", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CSC 104", "title": "Programming & Algorithm Design", "units": 3, "lecturer": "Mr. Adepoju Marvellous", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"ASE": {
		"name": "Aerospace Engineering",
		"faculty": "Faculty of Engineering",
		"faculty_id": "ENG_FAC",
		"description": "Aerodynamics, aircraft structures, propulsion, and avionics.",
		"cut_off_score": 3,
		"redirect_dept": "MEE",
		"courses": [
			{"code": "ASE 101", "title": "Principles of Flight & Avionics", "units": 3, "lecturer": "Capt. Ibrahim", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MEE 101", "title": "Applied Mechanics & Statics", "units": 3, "lecturer": "Engr. Balogun", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},

	# --- 2. FACULTY OF COMPUTING ---
	"CSC": {
		"name": "Computer Science",
		"faculty": "Faculty of Computing",
		"faculty_id": "CMP_FAC",
		"description": "Coding, data structures, algorithms, and relentless debugging.",
		"cut_off_score": 2,
		"redirect_dept": "IFT",
		"courses": [
			{"code": "CSC 101", "title": "Introduction to Computer Science", "units": 3, "lecturer": "Dr. Adebayo", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CSC 104", "title": "Algorithms & Software Engineering", "units": 3, "lecturer": "Mr. Adepoju Marvellous", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"SWE": {
		"name": "Software Engineering",
		"faculty": "Faculty of Computing",
		"faculty_id": "CMP_FAC",
		"description": "Clean code architecture, OOP, web & mobile app development, and testing.",
		"cut_off_score": 2,
		"redirect_dept": "IFT",
		"courses": [
			{"code": "SWE 101", "title": "Fundamentals of Software Engineering", "units": 3, "lecturer": "Mr. Adepoju Marvellous", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CSC 104", "title": "Object-Oriented Programming (OOP)", "units": 3, "lecturer": "Dr. Adebayo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Discrete Mathematics for Computing", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"CYS": {
		"name": "Cyber Security",
		"faculty": "Faculty of Computing",
		"faculty_id": "CMP_FAC",
		"description": "Network defence, ethical hacking, digital forensics, and cryptography.",
		"cut_off_score": 2,
		"redirect_dept": "IFT",
		"courses": [
			{"code": "CYS 101", "title": "Introduction to Cyber Defence", "units": 3, "lecturer": "Dr. Babatunde", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CSC 101", "title": "Computer Networks & Security", "units": 3, "lecturer": "Dr. Adebayo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Discrete Mathematics & Cryptography", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"IFT": {
		"name": "Information Technology",
		"faculty": "Faculty of Computing",
		"faculty_id": "CMP_FAC",
		"description": "Cloud systems, web applications, databases, and enterprise IT management.",
		"cut_off_score": 1,
		"redirect_dept": "MAC",
		"courses": [
			{"code": "IFT 101", "title": "Database Systems & Web Tech", "units": 3, "lecturer": "Mrs. Alabi", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CSC 101", "title": "Introduction to Computing", "units": 3, "lecturer": "Dr. Adebayo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Applied Business Mathematics", "units": 3, "lecturer": "Prof. Okonjo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"DSC": {
		"name": "Data Science",
		"faculty": "Faculty of Computing",
		"faculty_id": "CMP_FAC",
		"description": "Python data analytics, machine learning, probability, and big data visualization.",
		"cut_off_score": 2,
		"redirect_dept": "MTH",
		"courses": [
			{"code": "DSC 101", "title": "Data Analytics & Visualization", "units": 3, "lecturer": "Dr. Osagie", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Probability & Calculus", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CSC 104", "title": "Python Programming", "units": 3, "lecturer": "Mr. Adepoju Marvellous", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},

	# --- 3. FACULTY OF LAW (Strictly 2 Courses per user request) ---
	"LAW": {
		"name": "Common & Civil Law",
		"faculty": "Faculty of Law",
		"faculty_id": "LAW_FAC",
		"description": "Constitutional law, legal methods, torts, and courtroom advocacy.",
		"cut_off_score": 3,
		"redirect_dept": "POL",
		"courses": [
			{"code": "LAW 101", "title": "Nigerian Legal Methods & Ethics", "units": 4, "lecturer": "Prof. Mrs. Odunbaku (SAN)", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "LAW 102", "title": "Constitutional Law of Nigeria", "units": 4, "lecturer": "Barrister Fashola", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Legal Drafting", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"CCL": {
		"name": "Commercial & Corporate Law",
		"faculty": "Faculty of Law",
		"faculty_id": "LAW_FAC",
		"description": "Law of contract, corporate governance, banking law, and business transactions.",
		"cut_off_score": 3,
		"redirect_dept": "BUS",
		"courses": [
			{"code": "CCL 101", "title": "Law of Contract & Transactions", "units": 4, "lecturer": "Dr. Oladipo", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "LAW 101", "title": "Nigerian Legal Systems", "units": 4, "lecturer": "Prof. Mrs. Odunbaku (SAN)", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Legal Drafting", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},

	# --- 4. FACULTY OF SOCIAL & MANAGEMENT SCIENCES ---
	"ECN": {
		"name": "Economics",
		"faculty": "Faculty of Social & Management Sciences",
		"faculty_id": "SMS_FAC",
		"description": "Microeconomics, macroeconomic fiscal policies, inflation, and CBN monetary systems.",
		"cut_off_score": 2,
		"redirect_dept": "BUS",
		"courses": [
			{"code": "ECN 101", "title": "Principles of Economics I", "units": 3, "lecturer": "Dr. Sanusi", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "ACC 101", "title": "Introduction to Financial Accounting", "units": 3, "lecturer": "Mrs. Alabi", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"ACC": {
		"name": "Accounting & Finance",
		"faculty": "Faculty of Social & Management Sciences",
		"faculty_id": "SMS_FAC",
		"description": "Ledger balancing, taxation, auditing, and corporate finance accounting.",
		"cut_off_score": 2,
		"redirect_dept": "BUS",
		"courses": [
			{"code": "ACC 101", "title": "Introduction to Financial Accounting", "units": 3, "lecturer": "Mrs. Alabi", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "ECN 101", "title": "Principles of Economics I", "units": 3, "lecturer": "Dr. Sanusi", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"MAC": {
		"name": "Mass Communication & Media",
		"faculty": "Faculty of Social & Management Sciences",
		"faculty_id": "SMS_FAC",
		"description": "Campus journalism, TV broadcasting, advertising, and public relations.",
		"cut_off_score": 2,
		"redirect_dept": "ENG",
		"courses": [
			{"code": "MAC 101", "title": "Introduction to Mass Communication", "units": 3, "lecturer": "Dr. Chioma", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MAC 103", "title": "Writing for the Mass Media", "units": 3, "lecturer": "Mr. Bankole", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"BUS": {
		"name": "Business Administration",
		"faculty": "Faculty of Social & Management Sciences",
		"faculty_id": "SMS_FAC",
		"description": "Entrepreneurship, organizational leadership, marketing, and business strategy.",
		"cut_off_score": 1,
		"redirect_dept": "POL",
		"courses": [
			{"code": "BUS 101", "title": "Introduction to Business Management", "units": 3, "lecturer": "Dr. Adele", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "ECN 101", "title": "Principles of Economics", "units": 3, "lecturer": "Dr. Sanusi", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"POL": {
		"name": "Political Science & International Relations",
		"faculty": "Faculty of Social & Management Sciences",
		"faculty_id": "SMS_FAC",
		"description": "Government systems, African politics, diplomacy, and student union activism.",
		"cut_off_score": 1,
		"redirect_dept": "HIS",
		"courses": [
			{"code": "POL 101", "title": "Introduction to Political Science", "units": 3, "lecturer": "Comrade Dr. Yakubu", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "HIS 101", "title": "Nigerian History Since 1800", "units": 3, "lecturer": "Prof. Adeleye", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"PSY": {
		"name": "Psychology",
		"faculty": "Faculty of Social & Management Sciences",
		"faculty_id": "SMS_FAC",
		"description": "Human behaviour, mental processes, cognitive psychology, and social dynamics.",
		"cut_off_score": 2,
		"redirect_dept": "POL",
		"courses": [
			{"code": "PSY 101", "title": "Basic Concepts in Psychology", "units": 3, "lecturer": "Dr. Mrs. Kalu", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "PSY 102", "title": "Biological Basis of Behaviour", "units": 3, "lecturer": "Dr. Ejembi", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},

	# --- 5. FACULTY OF NATURAL & APPLIED SCIENCES ---
	"MTH": {
		"name": "Mathematics & Statistics",
		"faculty": "Faculty of Natural & Applied Sciences",
		"faculty_id": "NAS_FAC",
		"description": "Differential equations, abstract algebra, probability, and mathematical proofs.",
		"cut_off_score": 2,
		"redirect_dept": "PHY",
		"courses": [
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 102", "title": "Elementary Algebra & Trigonometry", "units": 3, "lecturer": "Dr. Ojo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "PHY 101", "title": "General Physics (Mechanics)", "units": 3, "lecturer": "Dr. Nnamdi", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"PHY": {
		"name": "Physics & Electronics",
		"faculty": "Faculty of Natural & Applied Sciences",
		"faculty_id": "NAS_FAC",
		"description": "Quantum mechanics, thermodynamics, semiconductors, and electromagnetic fields.",
		"cut_off_score": 2,
		"redirect_dept": "MTH",
		"courses": [
			{"code": "PHY 101", "title": "General Physics (Mechanics & Heat)", "units": 3, "lecturer": "Dr. Nnamdi", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics (Calculus)", "units": 4, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "General Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"BCH": {
		"name": "Biochemistry",
		"faculty": "Faculty of Natural & Applied Sciences",
		"faculty_id": "NAS_FAC",
		"description": "Proteins, enzyme kinetics, molecular genetics, and cellular metabolism.",
		"cut_off_score": 2,
		"redirect_dept": "MCB",
		"courses": [
			{"code": "BCH 101", "title": "General Biochemistry I", "units": 3, "lecturer": "Prof. Akindele", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "General Organic & Inorganic Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "BIO 101", "title": "General Biology", "units": 3, "lecturer": "Dr. Eze", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"MCB": {
		"name": "Microbiology",
		"faculty": "Faculty of Natural & Applied Sciences",
		"faculty_id": "NAS_FAC",
		"description": "Bacteriology, virology, immunology, and fungal biotechnology.",
		"cut_off_score": 2,
		"redirect_dept": "ICH",
		"courses": [
			{"code": "MCB 101", "title": "Introduction to Microbiology", "units": 3, "lecturer": "Dr. Bello", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "BIO 101", "title": "General Biology", "units": 3, "lecturer": "Dr. Eze", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "General Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"ICH": {
		"name": "Industrial Chemistry",
		"faculty": "Faculty of Natural & Applied Sciences",
		"faculty_id": "NAS_FAC",
		"description": "Polymer chemistry, cosmetics manufacturing, pharmaceuticals, and chemical plant processes.",
		"cut_off_score": 2,
		"redirect_dept": "GLY",
		"courses": [
			{"code": "ICH 101", "title": "Introduction to Chemical Processes", "units": 3, "lecturer": "Dr. Olayiwola", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "General Physical Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MTH 101", "title": "Elementary Mathematics", "units": 3, "lecturer": "Prof. Okonjo", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"GLY": {
		"name": "Geology & Earth Sciences",
		"faculty": "Faculty of Natural & Applied Sciences",
		"faculty_id": "NAS_FAC",
		"description": "Mineral exploration, rock formations, groundwater hydrology, and petroleum basin analysis.",
		"cut_off_score": 1,
		"redirect_dept": "PHY",
		"courses": [
			{"code": "GLY 101", "title": "Physical Geology & Earth Materials", "units": 3, "lecturer": "Prof. Momoh", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "PHY 101", "title": "General Physics", "units": 3, "lecturer": "Dr. Nnamdi", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "General Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},

	# --- 6. FACULTY OF HEALTH & MEDICAL SCIENCES ---
	"MBBS": {
		"name": "Medicine & Surgery",
		"faculty": "Faculty of Health & Medical Sciences",
		"faculty_id": "MED_FAC",
		"description": "Clinical diagnosis, human anatomy, medical physiology, and pathology.",
		"cut_off_score": 3,
		"redirect_dept": "PBH",
		"courses": [
			{"code": "ANA 101", "title": "General Human Gross Anatomy", "units": 4, "lecturer": "Dr. Prof. Williams", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "PIO 101", "title": "Medical Physiology & Body Systems", "units": 4, "lecturer": "Dr. Alonge", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "BCH 101", "title": "Medical Biochemistry", "units": 3, "lecturer": "Prof. Akindele", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Medical Ethics", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"NSC": {
		"name": "Nursing Science",
		"faculty": "Faculty of Health & Medical Sciences",
		"faculty_id": "MED_FAC",
		"description": "Patient care ethics, community healthcare, pharmacology, and clinical procedures.",
		"cut_off_score": 2,
		"redirect_dept": "PBH",
		"courses": [
			{"code": "NSC 101", "title": "Fundamentals of Nursing Practice", "units": 3, "lecturer": "Matron Mrs. Ajayi", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "ANA 101", "title": "Basic Human Anatomy", "units": 3, "lecturer": "Dr. Prof. Williams", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "BIO 101", "title": "General Biology", "units": 3, "lecturer": "Dr. Eze", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"PHM": {
		"name": "Pharmacy",
		"faculty": "Faculty of Health & Medical Sciences",
		"faculty_id": "MED_FAC",
		"description": "Drug formulations, pharmacognosy, medicinal chemistry, and pharmaceutical compounding.",
		"cut_off_score": 3,
		"redirect_dept": "BCH",
		"courses": [
			{"code": "PHM 101", "title": "Introduction to Pharmaceutical Science", "units": 3, "lecturer": "Pharm. Dr. Okeke", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "General Organic Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "BIO 101", "title": "General Biology & Plant Taxonomy", "units": 3, "lecturer": "Dr. Eze", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"MLS": {
		"name": "Medical Laboratory Science",
		"faculty": "Faculty of Health & Medical Sciences",
		"faculty_id": "MED_FAC",
		"description": "Clinical haematology, histopathology, medical diagnostics, and parasite analysis.",
		"cut_off_score": 2,
		"redirect_dept": "MCB",
		"courses": [
			{"code": "MLS 101", "title": "Basic Medical Lab Techniques", "units": 3, "lecturer": "Dr. Chidi", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CHM 101", "title": "Clinical Chemistry", "units": 3, "lecturer": "Dr. Mrs. Ogundimu", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "MCB 101", "title": "Medical Parasitology", "units": 3, "lecturer": "Dr. Bello", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"PBH": {
		"name": "Public Health",
		"faculty": "Faculty of Health & Medical Sciences",
		"faculty_id": "MED_FAC",
		"description": "Epidemiology, disease prevention, health education, and environmental sanitation.",
		"cut_off_score": 1,
		"redirect_dept": "MCB",
		"courses": [
			{"code": "PBH 101", "title": "Introduction to Public Health & Hygiene", "units": 3, "lecturer": "Dr. Mrs. Fashanu", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "BIO 101", "title": "General Biology", "units": 3, "lecturer": "Dr. Eze", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},

	# --- 7. FACULTY OF HUMANITIES & ARTS ---
	"ENG": {
		"name": "English & Literary Studies",
		"faculty": "Faculty of Humanities & Arts",
		"faculty_id": "HUM_FAC",
		"description": "African literature, English grammar, syntax, poetry, and creative prose.",
		"cut_off_score": 2,
		"redirect_dept": "HIS",
		"courses": [
			{"code": "ENG 101", "title": "English Phonetics & Grammar", "units": 3, "lecturer": "Prof. Mrs. Akpan", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "LIT 101", "title": "Introduction to African Literature", "units": 3, "lecturer": "Dr. Soyemi", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"HIS": {
		"name": "History & International Studies",
		"faculty": "Faculty of Humanities & Arts",
		"faculty_id": "HUM_FAC",
		"description": "Pre-colonial Nigerian kingdoms, colonial era, modern African diplomacy, and world history.",
		"cut_off_score": 1,
		"redirect_dept": "PHL",
		"courses": [
			{"code": "HIS 101", "title": "Nigerian History Since 1800", "units": 3, "lecturer": "Prof. Adeleye", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "HIS 102", "title": "Africa & the World Powers", "units": 3, "lecturer": "Dr. Oladipo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"PHL": {
		"name": "Philosophy & Logic",
		"faculty": "Faculty of Humanities & Arts",
		"faculty_id": "HUM_FAC",
		"description": "Critical thinking, formal logic, ethics, African philosophy, and metaphysics.",
		"cut_off_score": 1,
		"redirect_dept": "CRS",
		"courses": [
			{"code": "PHL 101", "title": "Introduction to Logic & Argumentation", "units": 3, "lecturer": "Dr. Ekanem", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "PHL 102", "title": "African Philosophy & Ethics", "units": 3, "lecturer": "Prof. Omotosho", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	},
	"CRS": {
		"name": "Christian Religious Studies",
		"faculty": "Faculty of Humanities & Arts",
		"faculty_id": "HUM_FAC",
		"description": "Biblical theology, Old & New Testament history, ethics, and early Church history.",
		"cut_off_score": 1,
		"redirect_dept": "HIS",
		"courses": [
			{"code": "CRS 101", "title": "Old Testament Survey & Covenant History", "units": 3, "lecturer": "Pastor Dr. Adelaja", "schedule_time": "09:00 - 11:00", "time_start": 9 * 60, "time_end": 11 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "CRS 102", "title": "New Testament Literature & Church History", "units": 3, "lecturer": "Dr. Mrs. Nwankwo", "schedule_time": "14:00 - 16:00", "time_start": 14 * 60, "time_end": 16 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 101", "title": "Use of English & Communication Skills", "units": 2, "lecturer": "Mrs. Folashade", "schedule_time": "11:30 - 13:00", "time_start": 11 * 60 + 30, "time_end": 13 * 60, "ca_weight": 30, "exam_weight": 70},
			{"code": "GST 102", "title": "Nigerian Peoples & Culture", "units": 2, "lecturer": "Prof. Babatunde", "schedule_time": "16:30 - 18:00", "time_start": 16 * 60 + 30, "time_end": 18 * 60, "ca_weight": 30, "exam_weight": 70}
		]
	}
}

static func get_department(dept_code: String) -> Dictionary:
	if DEPARTMENTS.has(dept_code):
		return DEPARTMENTS[dept_code]
	return DEPARTMENTS["CSC"]

static func get_all_department_codes() -> Array:
	return DEPARTMENTS.keys()

static func get_departments_by_faculty(faculty_id: String) -> Array:
	var result: Array = []
	for code: String in DEPARTMENTS.keys():
		if DEPARTMENTS[code].get("faculty_id", "") == faculty_id:
			result.append(code)
	return result

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
