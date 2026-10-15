class_name LectureContentData
extends RefCounted

## Academic Lecture Content, Blackboard Slides, and Classroom QTE Scenarios.
## Easily editable: Add new courses, lecture slides, and questions for any department.

const DEFAULT_COURSES: Dictionary = {
	"CSC": {
		"code": "CSC 101",
		"title": "Introduction to Computing & Data Structures",
		"lecturer": "Dr. Adebayo",
		"lecturer_role": "Senior Lecturer (Computer Science)",
		"slides": [
			"TOPIC: Algorithm Complexity & Tree Traversals\n• Time Complexity: Binary Search = O(log N)\n• Array vs Linked List: Cache locality vs dynamic sizing",
			"⚠️ CRITICAL EXAM FORMULA:\n• Hash Table Load Factor: α = n / k\n• Worst-case Quicksort: O(N²) occurs with sorted pivot!",
			"PRACTICAL LAB NOTICE:\n• Submit C++ Pointer implementation to course rep before 5:00 PM!\n• Plagiarism score > 15% means automatic zero."
		],
		"qte_jot": "Hash Table Load Factor: α = n / k",
		"pop_question": {
			"question": "What is the average time complexity of searching in a balanced Binary Search Tree?",
			"options": ["O(log N)", "O(N²)", "O(1)"],
			"correct": 0,
			"praise": "Excellent! O(log N) is correct. Keep that sharp focus!"
		}
	},
	"MEE": {
		"code": "MEE 101",
		"title": "Engineering Mechanics & Statics",
		"lecturer": "Prof. Okonjo",
		"lecturer_role": "Faculty Chair (Engineering)",
		"slides": [
			"TOPIC: Rigid Body Equilibrium & Free Body Diagrams\n• ΣFx = 0,  ΣFy = 0,  ΣM_o = 0\n• Tension and compression in planar trusses",
			"⚠️ HIGH-YIELD EXAM PRINCIPLE:\n• Method of Joints vs Method of Sections\n• Zero-force members carry no load under static conditions!",
			"WORKSHOP PRACTICAL NOTICE:\n• Safety boots mandatory in the fabrication workshop on Thursday!"
		],
		"qte_jot": "Static Equilibrium: ΣFx = 0, ΣFy = 0, ΣM = 0",
		"pop_question": {
			"question": "In a 2D static equilibrium system, how many independent equilibrium equations are available?",
			"options": ["3 (Fx, Fy, Moment)", "1 (Force only)", "6 (3D only)"],
			"correct": 0,
			"praise": "Precise engineering calculation! Three equations indeed."
		}
	},
	"MED": {
		"code": "MED 101",
		"title": "Gross Human Anatomy & Physiology",
		"lecturer": "Dr. Mrs. Adeyemi",
		"lecturer_role": "Consultant & Senior Lecturer",
		"slides": [
			"TOPIC: Cardiovascular System & Arterial Blood Flow\n• Cardiac Output = Stroke Volume × Heart Rate (CO = SV × HR)\n• Normal Resting Stroke Volume ~ 70 mL/beat",
			"⚠️ CLINICAL EXAM PEARL:\n• Sinoatrial (SA) node is the intrinsic pacemaker of the heart!\n• Conduction pathway: SA node ➔ AV node ➔ Bundle of His",
			"CADAVER LAB REQUIREMENT:\n• White lab coats and dissection kits inspected at the entrance."
		],
		"qte_jot": "Cardiac Output: CO = Stroke Volume × Heart Rate",
		"pop_question": {
			"question": "Which anatomical structure functions as the primary natural pacemaker of the heart?",
			"options": ["Sinoatrial (SA) Node", "Left Ventricle", "Tricuspid Valve"],
			"correct": 0,
			"praise": "Spot on doctor! The SA node drives cardiac pacing."
		}
	},
	"LAW": {
		"code": "LAW 101",
		"title": "Nigerian Legal System & Constitutional Law",
		"lecturer": "Mrs. Folashade",
		"lecturer_role": "Associate Professor of Law",
		"slides": [
			"TOPIC: Hierarchy of Courts & Judicial Precedent\n• Supreme Court of Nigeria > Court of Appeal > Federal/State High Court\n• Doctrine of Stare Decisis: Stand by things decided",
			"⚠️ MOOT COURT EXAM PRINCIPLE:\n• Ratio Decidendi (legal principle) vs Obiter Dictum (by the way remark)\n• Section 36(1) of 1999 Constitution: Right to Fair Hearing",
			"LEGAL RESEARCH ASSIGNMENT:\n• Case citations must reference Nigerian Weekly Law Reports (NWLR)."
		],
		"qte_jot": "Stare Decisis: Stand by precedents unless overruled",
		"pop_question": {
			"question": "What is the binding legal reason for a judicial decision called in common law jurisprudence?",
			"options": ["Ratio Decidendi", "Obiter Dictum", "Habeas Corpus"],
			"correct": 0,
			"praise": "Eminently argued counsel! Ratio decidendi binds lower courts."
		}
	},
	"ACC": {
		"code": "ACC 101",
		"title": "Principles of Financial Accounting",
		"lecturer": "Dr. Adebayo",
		"lecturer_role": "Faculty Examiner",
		"slides": [
			"TOPIC: Double-Entry Bookkeeping & Trial Balance\n• Fundamental Accounting Equation: Assets = Liabilities + Equity\n• Debit the receiver, Credit the giver",
			"⚠️ AUDIT EXAM TIP:\n• Depreciation Methods: Straight-line vs Reducing Balance\n• Bank Reconciliation Statement identifies unpresented cheques!",
			"BUSINESS LAB TASK:\n• Balance the semester trading ledger before the closing bell."
		],
		"qte_jot": "Accounting Equation: Assets = Liabilities + Equity",
		"pop_question": {
			"question": "According to the fundamental accounting equation, Assets are equal to what?",
			"options": ["Liabilities + Equity", "Gross Revenue - Tax", "Cash in Vault"],
			"correct": 0,
			"praise": "Accurate accounting balance! Assets = Liabilities + Equity."
		}
	},
	"GST": {
		"code": "GST 101",
		"title": "Use of English & Communication Skills",
		"lecturer": "Mrs. Folashade",
		"lecturer_role": "General Studies Coordinator",
		"slides": [
			"TOPIC: Expository Writing & Academic Diction\n• Cohesion and Coherence in essay composition\n• Avoiding colloquialisms and dangling modifiers in formal papers",
			"⚠️ SEMESTER EXAM REQUIREMENT:\n• Subject-Verb Agreement: Singular subjects take singular verbs!\n• APA 7th Edition referencing format for term papers",
			"CONTINUOUS ASSESSMENT NOTICE:\n• Impromptu presentation begins next lecture period at 9:00 AM."
		],
		"qte_jot": "Expository Writing: Coherence, logic & APA citation",
		"pop_question": {
			"question": "In formal academic writing, which element ensures sentences transition smoothly from one paragraph to the next?",
			"options": ["Cohesion & Coherence", "Excessive Slang", "Passive Voice Only"],
			"correct": 0,
			"praise": "Excellent diction! Clear cohesion makes an essay compelling."
		}
	}
}

## Returns the course lecture content matched to student department or default
static func get_lecture_for_department(dept_code: String) -> Dictionary:
	if DEFAULT_COURSES.has(dept_code):
		return DEFAULT_COURSES[dept_code]
	# Check faculty matching
	if dept_code in ["SWE", "CYB", "INF", "DSC"]:
		return DEFAULT_COURSES["CSC"]
	elif dept_code in ["EEE", "CVE", "CHE", "PET"]:
		return DEFAULT_COURSES["MEE"]
	elif dept_code in ["PHA", "MLS", "NUR", "DNT"]:
		return DEFAULT_COURSES["MED"]
	elif dept_code in ["JUR", "CML"]:
		return DEFAULT_COURSES["LAW"]
	elif dept_code in ["BAA", "ECN", "BFN", "MCX"]:
		return DEFAULT_COURSES["ACC"]
	return DEFAULT_COURSES["GST"]
