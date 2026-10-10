class_name QuizTestSystem
extends RefCounted

## Continuous Assessment (CA) Test & Exam Question Bank.
## Engaging, culturally authentic, and relatable Nigerian campus questions.
## Scores directly feed into the student's Course Continuous Assessment & CGPA.

const QUESTIONS: Dictionary = {
	"UNI 101": [
		{
			"q": "Lecturer arrives at 8:05 AM and locks the lecture hall door with a padlock. What is your sharpest move?",
			"options": [
				"Throw stones at the window",
				"Beg 'Daddy please, traffic held us at Campus Gate'",
				"Send SOS on WhatsApp departmental group",
				"Go straight to Mama Put joint for morning jollof"
			],
			"correct": 1,
			"hint": "Humility and respect open doors faster than arguing with a tenured Nigerian professor.",
			"explanation": "Respectful diplomacy ('Daddy please') is the classic Nigerian university survival tactic."
		},
		{
			"q": "What is the unofficial hostel legal tender at 1:30 AM when sapa hits?",
			"options": [
				"Cryptocurrency tokens",
				"A sachet of Indomie noodles and 1 boiled egg",
				"Library clearance card",
				"US Dollars"
			],
			"correct": 1,
			"hint": "Check what students boil on hot plates late at night.",
			"explanation": "Late-night hostel barter economy runs on raw noodles, eggs, and bread."
		},
		{
			"q": "The lecturer says: 'My A is with God, B is for me, and the best student gets C.' What is your best strategy?",
			"options": [
				"Drop out and become a social media influencer",
				"Sit front row, buy his recommended handout, and never miss 8 AM roll-call",
				"Report him to Student Union President Comrade Aluta",
				"Argue with him during class"
			],
			"correct": 1,
			"hint": "Consistency, front-row visibility, and attendance protect your grades.",
			"explanation": "Strict lecturers award marks to visible, punctual, and respectful students."
		},
		{
			"q": "NEPA takes light in the hostel at 11:00 PM the night before your CA test. What do you do?",
			"options": [
				"Cry under the bed and give up",
				"Head to Chapel of Grace or Faculty lobby for generator light",
				"Go to sleep and accept carryover",
				"Call the Vice Chancellor on phone"
			],
			"correct": 1,
			"hint": "The chapel and faculty generator corridors are always packed during exam periods.",
			"explanation": "Students migrate to lit public faculty corridors for Till Daybreak (TDB) studying."
		}
	],
	"GST 101": [
		{
			"q": "If your coursemate whispers: 'Omo, Sapa is holding my throat!', what does he mean?",
			"options": [
				"He has a medical throat infection",
				"He is completely broke and needs food/money",
				"He was choked by an athlete",
				"He is singing high-pitch Afrobeats"
			],
			"correct": 1,
			"hint": "Sapa is the iconic Nigerian slang for financial drought.",
			"explanation": "'Sapa' is contemporary Nigerian slang describing severe financial hardship."
		},
		{
			"q": "What does 'TDB' stand for during semester exam week?",
			"options": [
				"Total Daily Balance",
				"Till Daybreak (all-night reading marathon)",
				"The Daily Bread",
				"Time Delivery Bus"
			],
			"correct": 1,
			"hint": "Your roommate Segun mentions this whenever he brews midnight black coffee.",
			"explanation": "TDB ('Till Daybreak') refers to overnight study sessions before exams."
		},
		{
			"q": "Which sentence is grammatically appropriate when greeting a strict Nigerian professor?",
			"options": [
				"How far now Prof, what's good?",
				"Good morning, Professor Adebayo. Please, I came for assignment clearance.",
				"Chief, give me my continuous assessment marks sharp.",
				"Oga Adebayo, do transfer."
			],
			"correct": 1,
			"hint": "Academic communication requires formal politeness and proper titles.",
			"explanation": "Formal register and academic titles are mandatory in Nigerian university settings."
		},
		{
			"q": "What does getting an 'F' in a 3-unit course mean in university regulations?",
			"options": [
				"Automatic First Class honors",
				"Carryover (you must retake the course next academic session)",
				"Free lunch voucher at the Bistro",
				"Immediate graduation with praise"
			],
			"correct": 1,
			"hint": "F grade means zero points and a repeat requirement.",
			"explanation": "An 'F' grade is a failure that requires retaking (carrying over) the course."
		}
	],
	"GST 102": [
		{
			"q": "In what year did Nigeria officially gain independence?",
			"options": [
				"1957",
				"1960",
				"1979",
				"1999"
			],
			"correct": 1,
			"hint": "October 1st, 1960 — the birth of the sovereign Federation.",
			"explanation": "Nigeria gained independence from Britain on October 1, 1960."
		},
		{
			"q": "Which city is the Federal Capital Territory (FCT) of Nigeria?",
			"options": [
				"Lagos",
				"Abuja",
				"Ibadan",
				"Port Harcourt"
			],
			"correct": 1,
			"hint": "The purpose-built federal capital situated in the geographic center of the country.",
			"explanation": "Abuja replaced Lagos as Nigeria's Federal Capital Territory in December 1991."
		},
		{
			"q": "Which Afrobeats superstar released the global anthem 'Unavailable'?",
			"options": [
				"Davido (OBO)",
				"Burna Boy",
				"Wizkid",
				"Asake"
			],
			"correct": 0,
			"hint": "The 'Timeless' album frontliner and DMW boss.",
			"explanation": "Davido released 'Unavailable' as the lead smash hit on his 2023 'Timeless' album."
		},
		{
			"q": "In the West African cultural debate, which Jollof rice is supreme?",
			"options": [
				"Nigerian Party Jollof (with firewood bottom-pot aroma)",
				"Plain white rice without stew",
				"Cold rice from yesterday",
				"Microwave instant porridge"
			],
			"correct": 0,
			"hint": "The smoky party firewood aroma is unmatched.",
			"explanation": "Nigerian party Jollof rice cooked over firewood is culturally celebrated across the diaspora."
		}
	],
	"CSC 101": [
		{
			"q": "Why do tech students drink coffee and stay awake all night?",
			"options": [
				"It makes the keyboard type faster",
				"To debug syntax errors and missing semicolons in their code",
				"It charges laptop battery wirelessly",
				"It boosts campus Wi-Fi signals"
			],
			"correct": 1,
			"hint": "Hunting bugs in code takes patience and sleepless dedication.",
			"explanation": "Software debugging and algorithmic problem solving often require late-night sessions."
		},
		{
			"q": "What is the primary hardware brain of a computer that executes calculations?",
			"options": [
				"CPU (Central Processing Unit)",
				"The mouse pad",
				"The laptop charging brick",
				"The desktop wallpaper"
			],
			"correct": 0,
			"hint": "It coordinates memory, registers, and arithmetic logic units.",
			"explanation": "The Central Processing Unit (CPU) is the primary engine executing software instructions."
		},
		{
			"q": "Which open-source file format is widely used for 3D game models and animated characters?",
			"options": [
				".mp3",
				".gltf / .glb",
				".txt",
				".pdf"
			],
			"correct": 1,
			"hint": "GL Transmission Format is the standard 3D web asset format.",
			"explanation": "glTF (GL Transmission Format) is the modern JPEG of 3D games and web applications."
		}
	],
	"MAC 101": [
		{
			"q": "What is 'the medium' in communication studies according to Marshall McLuhan?",
			"options": [
				"A supernatural fortune teller",
				"The channel carrying the message (radio, TV, web, print)",
				"A moderate food portion at Mama Put",
				"An average score on a test"
			],
			"correct": 1,
			"hint": "The vehicle that delivers ideas from sender to audience.",
			"explanation": "The medium is the technological channel that transmits and shapes the message."
		},
		{
			"q": "What is 'Yellow Journalism'?",
			"options": [
				"Writing articles on yellow paper",
				"Sensationalized, exaggerated, or clickbait reporting",
				"Reporting agricultural news about bananas",
				"Drawing editorial cartoons"
			],
			"correct": 1,
			"hint": "Focuses on shock value and scandal over verifiable truth.",
			"explanation": "Yellow journalism relies on sensationalism and dramatic headlines to attract readers."
		}
	],
	"ECN 101": [
		{
			"q": "When campus food prices jump from ₦600 to ₦1,400 during a semester, what is happening?",
			"options": [
				"Deflation",
				"Campus Inflation",
				"Free gift distribution",
				"Global cooling"
			],
			"correct": 1,
			"hint": "The sustained increase in the general price level of goods.",
			"explanation": "Inflation is the general rise in prices reducing the purchasing power of your allowance."
		},
		{
			"q": "If you spend your last ₦2,000 on suya beef instead of your semester exam handout, what is the handout?",
			"options": [
				"Opportunity Cost (the value of the forgone alternative)",
				"Free bonus",
				"Hostel dues",
				"Bank alert"
			],
			"correct": 0,
			"hint": "What you give up to get something else.",
			"explanation": "Opportunity cost represents the potential benefits an individual misses out on when choosing one alternative."
		}
	],
	"MTH 101": [
		{
			"q": "If campus Keke shuttle fare is ₦100 per ride, how much do 10 rides cost in total?",
			"options": [
				"₦500",
				"₦1,000",
				"₦10,000",
				"₦0 (you trekked)"
			],
			"correct": 1,
			"hint": "Simple multiplication: 10 rides × ₦100 = ?",
			"explanation": "10 rides at ₦100 per trip equals ₦1,000."
		},
		{
			"q": "What is the mathematical slope (derivative) of a constant flat horizontal line?",
			"options": [
				"10",
				"0 (zero change)",
				"100",
				"Infinity"
			],
			"correct": 1,
			"hint": "A flat surface has zero tilt or rate of change.",
			"explanation": "The derivative of any constant value is 0 because there is no change."
		}
	]
}

static func get_test_for_course(course_code: String) -> Array:
	if QUESTIONS.has(course_code):
		return QUESTIONS[course_code]
	# Fallback to general campus survival questions
	if QUESTIONS.has("UNI 101"):
		return QUESTIONS["UNI 101"]
	return QUESTIONS["GST 101"]


static func get_hint(course_code: String, question_idx: int) -> String:
	var list: Array = get_test_for_course(course_code)
	if question_idx >= 0 and question_idx < list.size():
		var q: Dictionary = list[question_idx]
		return String(q.get("hint", "Review your lecture notebook and hostel study desk handouts."))
	return "Review your lecture notebook and hostel study desk handouts."
