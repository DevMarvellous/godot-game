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
				"Manage hardware resources and provide services for programs",
				"Browse social media apps",
				"Charge phone battery faster"
			],
			"correct": 1,
			"explanation": "The OS manages hardware resources (CPU, RAM, storage) and coordinates application tasks."
		},
		{
			"q": "Which data structure operates on a Last-In, First-Out (LIFO) principle?",
			"options": [
				"Queue",
				"Stack",
				"Array",
				"Linked List"
			],
			"correct": 1,
			"explanation": "A Stack works on LIFO (like a stack of cafeteria food trays)."
		},
		{
			"q": "In Python and GDScript, what keyword is used to define a function?",
			"options": [
				"function",
				"define",
				"def / func",
				"method"
			],
			"correct": 2,
			"explanation": "Python uses 'def' and Godot's GDScript uses 'func'."
		}
	],
	"GST 101": [
		{
			"q": "Choose the grammatically correct sentence:",
			"options": [
				"Neither the lecturer nor the students was present.",
				"Neither the lecturer nor the students were present.",
				"Neither the lecturer or students is present.",
				"None of them are not present."
			],
			"correct": 1,
			"explanation": "When using 'neither... nor', the verb agrees with the closer subject ('students' -> plural 'were')."
		},
		{
			"q": "What is the meaning of the idiom 'burning the midnight oil'?",
			"options": [
				"Cooking late night Indomie",
				"Reading or working late into the night",
				"Generator fuel scarcity in the hostel",
				"Setting fire to campus bushes"
			],
			"correct": 1,
			"explanation": "Burning the midnight oil means studying or working late into the night."
		}
	],
	"MTH 101": [
		{
			"q": "What is the derivative of f(x) = 3x² + 5x - 7 with respect to x?",
			"options": [
				"6x + 5",
				"3x + 5",
				"6x² + 5",
				"x³ + 5x"
			],
			"correct": 0,
			"explanation": "Power rule: d/dx(3x²) = 6x, and d/dx(5x) = 5. So 6x + 5."
		}
	]
}

static func get_test_for_course(course_code: String) -> Array:
	if QUESTIONS.has(course_code):
		return QUESTIONS[course_code]
	# Fallback to general questions
	return QUESTIONS["GST 101"]

