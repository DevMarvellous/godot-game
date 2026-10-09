class_name QuizTestSystem
extends RefCounted

## Continuous Assessment (CA) Test & Exam Question Bank.
## Real multiple choice questions with Nigerian university context.
## Scores directly feed into the student's Course Continuous Assessment & CGPA.

const QUESTIONS: Dictionary = {
	"CSC 101": [
		{
			"q": "What is the primary function of an Operating System?",
			"options": [
				"Compile GDScript games",
				"Manage hardware resources and coordinate apps",
				"Browse social media feeds",
				"Fast charge phone battery"
			],
			"correct": 1,
			"hint": "Check Chapter 1 in 'Introduction to Computing Handout' on your hostel reading desk.",
			"explanation": "The OS manages hardware resources (CPU, RAM, storage) and coordinates application tasks."
		},
		{
			"q": "Which data structure works like a cafeteria food tray stack (LIFO)?",
			"options": [
				"Queue (first come first served)",
				"Stack (last in first out)",
				"Array",
				"Folder"
			],
			"correct": 1,
			"hint": "Think of trays at Mama Cashout's canteen — the last tray placed is the first one picked!",
			"explanation": "A Stack works on Last-In, First-Out (LIFO)."
		},
		{
			"q": "In Python and Godot GDScript, which keyword starts a function?",
			"options": [
				"procedure",
				"def / func",
				"program",
				"action"
			],
			"correct": 1,
			"hint": "Look at the project scripts or your laptop code editor notes.",
			"explanation": "Python uses 'def' and Godot uses 'func'."
		}
	],
	"CSC 104": [
		{
			"q": "Why do games and software use signals instead of hard-linking everything?",
			"options": [
				"To make code slower",
				"To keep components clean and independent (decoupled)",
				"Because laptops overheat",
				"To confuse new students"
			],
			"correct": 1,
			"hint": "Mr. Marvellous talked about modular architecture in his lecture notes.",
			"explanation": "Signals keep components decoupled so changing one part does not break the entire game."
		},
		{
			"q": "When binary searching an ordered list of 100 items, how many steps does it take roughly?",
			"options": [
				"100 steps",
				"About 7 steps (dividing in half)",
				"1,000 steps",
				"Zero steps"
			],
			"correct": 1,
			"hint": "Each step cuts the book pages in half (log2 of 128 is 7).",
			"explanation": "Binary search divides the remaining choices by two each time, taking around log2(n) steps."
		}
	],
	"GST 101": [
		{
			"q": "Which of these sentences is grammatically correct?",
			"options": [
				"Neither the lecturer nor the students was present.",
				"Neither the lecturer nor the students were present.",
				"None of them are not here.",
				"All students is in hall."
			],
			"correct": 1,
			"hint": "In Mrs. Folashade's GST handout, 'neither... nor' matches the closest noun (students = were).",
			"explanation": "In 'neither... nor', the verb agrees with the closer subject ('students' -> plural 'were')."
		},
		{
			"q": "What does 'burning the midnight oil' mean in Nigerian campus slang?",
			"options": [
				"Cooking night Indomie with kerosene",
				"Reading late into the night for exams",
				"Hostel generator fuel shortage",
				"Burning waste behind the faculty"
			],
			"correct": 1,
			"hint": "Your roommate Segun uses this phrase whenever he stays up on the reading desk.",
			"explanation": "Burning the midnight oil means studying or working late into the night."
		},
		{
			"q": "What is the proper way to cite a reference in academic APA style?",
			"options": [
				"Just paste the web link",
				"Author surname and year of publication, e.g. (Adebayo, 2024)",
				"Write 'source: trust me bro'",
				"Leave it blank"
			],
			"correct": 1,
			"hint": "Mrs. Folashade emphasized Author (Year) format in the GST 101 syllabus.",
			"explanation": "APA 7th edition uses Author and Year in-text citations."
		}
	],
	"MTH 101": [
		{
			"q": "What is the slope (derivative) of a flat horizontal line like f(x) = 5?",
			"options": [
				"5",
				"0 (zero change)",
				"1",
				"Infinity"
			],
			"correct": 1,
			"hint": "Prof. Okonjo's calculus notes say the derivative of any constant is zero.",
			"explanation": "A horizontal line has zero steepness, so its rate of change (derivative) is 0."
		},
		{
			"q": "If speed is 60 km/h, how far do you travel in 2 hours?",
			"options": [
				"30 km",
				"120 km",
				"60 km",
				"200 km"
			],
			"correct": 1,
			"hint": "Distance = Speed × Time (elementary school formula).",
			"explanation": "60 km/h × 2 hours = 120 km."
		}
	],
	"MAC 101": [
		{
			"q": "What is the main purpose of the headline in a campus newspaper?",
			"options": [
				"Fill empty space on the page",
				"Grab the reader's attention and summarize the story",
				"Hide the author's identity",
				"Test printer ink"
			],
			"correct": 1,
			"hint": "Dr. Chioma's media handbook highlights that headlines serve as story entry points.",
			"explanation": "Headlines capture attention and convey the essence of the news immediately."
		},
		{
			"q": "In mass communication, what is 'the medium'?",
			"options": [
				"A spiritual fortune teller",
				"The channel used to send a message (radio, TV, web, paper)",
				"A moderate food portion at Buka",
				"An average exam score"
			],
			"correct": 1,
			"hint": "Remember Marshall McLuhan's famous phrase 'The medium is the message'.",
			"explanation": "The medium is the communication channel carrying the message from sender to receiver."
		}
	],
	"MAC 103": [
		{
			"q": "What is the 'Inverted Pyramid' writing style used by news journalists?",
			"options": [
				"Writing from bottom to top",
				"Putting the most critical facts first, followed by supporting details",
				"Writing in ancient Egyptian symbols",
				"Leaving the climax for the final sentence"
			],
			"correct": 1,
			"hint": "Mr. Bankole's media writing slide 3: The 5 Ws and H go right at the lead paragraph.",
			"explanation": "The inverted pyramid leads with the most crucial facts (Who, What, Where, When, Why)."
		}
	],
	"ECN 101": [
		{
			"q": "When student demand for campus snacks is high but supply is low, what happens to price?",
			"options": [
				"Price drops to zero",
				"Price tends to increase",
				"Nothing changes",
				"Lecturers cancel exams"
			],
			"correct": 1,
			"hint": "Check the basic Law of Supply and Demand in Dr. Sanusi's economics handout.",
			"explanation": "High demand with scarcity drives market prices upward."
		},
		{
			"q": "What is 'opportunity cost' in everyday student life?",
			"options": [
				"The price of transport to campus",
				"The value of the next best alternative you sacrificed",
				"The bank charges on your mobile app",
				"Getting free lunch at the chapel"
			],
			"correct": 1,
			"hint": "If you choose playing video games over studying, your sacrificed CGPA is the opportunity cost.",
			"explanation": "Opportunity cost is the lost benefit of the next best option given up."
		}
	],
	"ACC 101": [
		{
			"q": "In basic accounting, which fundamental equation must always balance?",
			"options": [
				"Assets = Liabilities + Equity",
				"Money = Cash + Pocket",
				"Profit = Zero",
				"Expenses = Indomie + Data"
			],
			"correct": 0,
			"hint": "Mrs. Alabi's Golden Rule on the accounting lecture whiteboard.",
			"explanation": "The accounting equation states that Assets = Liabilities + Owner's Equity."
		}
	]
}

static func get_test_for_course(course_code: String) -> Array:
	if QUESTIONS.has(course_code):
		return QUESTIONS[course_code]
	# Fallback to general GST questions
	return QUESTIONS["GST 101"]


static func get_hint(course_code: String, question_idx: int) -> String:
	var list: Array = get_test_for_course(course_code)
	if question_idx >= 0 and question_idx < list.size():
		var q: Dictionary = list[question_idx]
		return String(q.get("hint", "Review your lecture notebook and hostel study desk handouts."))
	return "Review your lecture notebook and hostel study desk handouts."


