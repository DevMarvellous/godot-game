class_name QuizBattleData
extends RefCounted

## High-Energy Academic & Campus Culture Quiz Battle Data Store.
## "Who Wants to Be a First Class Scholar?"
## Wholesome, fast-paced trivia across 5 faculties & Nigerian campus life.

const QUESTIONS: Array[Dictionary] = [
	# --- ROUND 1: CAMPUS CULTURE & SURVIVAL TRIVIA ---
	{
		"category": "Campus Culture & Student Life",
		"question": "What is the legendary Nigerian student term for boiling water without an electric kettle in the hostel?",
		"options": ["Immersion Heater / Boiling Ring", "Thermal Inductor", "Solar Geyser", "Infrared Laser Coil"],
		"correct": 0,
		"emeka_hint": "Guy, any fresher who never use boiling ring for Hall 2 never start university o!",
		"tobi_hint": "It is colloquially called the Boiling Ring (an immersion resistor). Officially prohibited by hostel wardens!"
	},
	{
		"category": "Campus Culture & Student Life",
		"question": "Which canteen meal is officially crowned the #1 fuel for 3:00 AM exam night vigil across Nigerian campuses?",
		"options": ["Salad & Green Tea", "Indomie with Double Boiled Egg & Pepper", "Oatmeal with Almond Milk", "Plain Toast Bread"],
		"correct": 1,
		"emeka_hint": "Indomie and two eggs na the official student national anthem for midnight reading!",
		"tobi_hint": "Carbohydrates plus egg albumin proteins supply sustained glucose to cerebral neurons during night study."
	},
	{
		"category": "Campus Culture & Student Life",
		"question": "What is the official slogan of the Student Union Government (SUG) when students assemble for solidarity?",
		"options": ["Aluta Continua, Victoria Acerta!", "No Pain, No Gain!", "Knowledge is Power!", "Forward Ever, Backward Never!"],
		"correct": 0,
		"emeka_hint": "Aluta Continua! Victoria Acerta! The struggle continues, victory is certain!",
		"tobi_hint": "The motto 'Aluta Continua, Victoria Acerta' traces to Mozambican independence and symbolizes collective student solidarity."
	},
	{
		"category": "Campus Culture & Student Life",
		"question": "When students say 'Sapa is choking me', what does it mean in wholesome campus vocabulary?",
		"options": ["Extreme Cough or Cold", "Financial Stringency before Pocket Money arrives", "Exhaustion after Jogging", "Overstudying for Continuous Assessment"],
		"correct": 1,
		"emeka_hint": "When account balance show ₦14.50, my guy that is Sapa Pro Max!",
		"tobi_hint": "It signifies temporary liquidity deficit awaiting family pocket money allowance."
	},

	# --- ROUND 2: NIGERIAN HISTORY & SCHOLARLY GIANTS ---
	{
		"category": "Nigerian History & Giants",
		"question": "In what year was Nigeria's premier university institution, University of Ibadan (UI), founded?",
		"options": ["1948", "1960", "1975", "1932"],
		"correct": 0,
		"emeka_hint": "UI was founded before Independence, around late 1940s!",
		"tobi_hint": "University College Ibadan was established in 1948 as an affiliate college of the University of London."
	},
	{
		"category": "Nigerian History & Giants",
		"question": "Who was the first African to win the prestigious Nobel Prize in Literature in 1986?",
		"options": ["Professor Chinua Achebe", "Professor Wole Soyinka", "Cyprian Ekwensi", "Buch Emecheta"],
		"correct": 1,
		"emeka_hint": "The great man with the silver afro hair! He wrote Death and the King's Horseman!",
		"tobi_hint": "Professor Akinwande Oluwole Babatunde Soyinka won the Nobel Prize in Literature in 1986."
	},
	{
		"category": "Nigerian History & Giants",
		"question": "On what date did Nigeria officially achieve independence from British colonial rule?",
		"options": ["1st October 1960", "29th May 1999", "15th January 1966", "1st October 1963"],
		"correct": 0,
		"emeka_hint": "1st of October! That's our Independence Day public holiday every single year!",
		"tobi_hint": "Nigeria declared formal sovereignty and independence on 1st October 1960."
	},
	{
		"category": "Nigerian History & Giants",
		"question": "Which historic Nigerian queen was legendary for her military cavalry conquests and fortress mud walls in Zazzau (Zaria)?",
		"options": ["Queen Amina", "Queen Idia", "Moremi Ajasoro", "Madam Tinubu"],
		"correct": 0,
		"emeka_hint": "The great warrior Queen Amina of Zaria!",
		"tobi_hint": "Queen Amina of Zazzau (16th century) built defensive fortifications known across West Africa as Amina's walls."
	},

	# --- ROUND 3: SCIENCE, COMPUTING & TECHNOLOGY ---
	{
		"category": "Faculty of Computing & Science",
		"question": "In computer science data structures, what is the average Big-O search time for a balanced Binary Search Tree?",
		"options": ["O(1)", "O(log n)", "O(n²)", "O(n!)"],
		"correct": 1,
		"emeka_hint": "Dr. Adebayo wrote this on the blackboard today: search cuts in half every level!",
		"tobi_hint": "Because a balanced BST halves the search space at each depth level, the asymptotic complexity is O(log n)."
	},
	{
		"category": "Faculty of Computing & Science",
		"question": "What primary gas do green plants absorb from the atmosphere during photosynthetic carbohydrate synthesis?",
		"options": ["Carbon Dioxide (CO₂)", "Oxygen (O₂)", "Helium (He)", "Argon (Ar)"],
		"correct": 0,
		"emeka_hint": "Plants take in carbon dioxide and give us fresh oxygen to breathe!",
		"tobi_hint": "During the Calvin cycle of photosynthesis, plants fix Carbon Dioxide (CO₂) using the RuBisCO enzyme."
	},
	{
		"category": "Faculty of Computing & Science",
		"question": "What is the base numerical radix of the hexadecimal number system widely used in computer architecture?",
		"options": ["Base 2", "Base 8", "Base 10", "Base 16"],
		"correct": 3,
		"emeka_hint": "Hex means 6, Decimal means 10, so together it is 16!",
		"tobi_hint": "Hexadecimal operates in base 16, using digits 0–9 and letters A–F to represent nibble values 10–15."
	},
	{
		"category": "Faculty of Engineering",
		"question": "Which electrical engineering law states that the algebraic sum of currents entering any electrical node is zero (Σ I = 0)?",
		"options": ["Kirchhoff's Current Law (KCL)", "Newton's Third Law", "Boyle's Ideal Gas Law", "Faraday's Cage Principle"],
		"correct": 0,
		"emeka_hint": "Kirchhoff! Current in equals current out!",
		"tobi_hint": "Kirchhoff's Current Law (KCL) is a direct consequence of the physical conservation of electric charge."
	},

	# --- ROUND 4: LAW, HUMANITIES & GOVERNANCE ---
	{
		"category": "Faculty of Law & Governance",
		"question": "What does the Latin legal doctrine of 'Stare Decisis' mean in Nigerian jurisprudence?",
		"options": ["Let the decision stand (Judicial Precedent)", "Guilty until proven innocent", "The law of maritime waters", "Right of sovereign veto"],
		"correct": 0,
		"emeka_hint": "In Law 101, it means lower courts must follow the previous rulings of higher courts!",
		"tobi_hint": "'Stare decisis et non quieta movere': lower courts are bound by the ratio decidendi of higher appellate courts."
	},
	{
		"category": "Faculty of Law & Governance",
		"question": "Under the 1999 Constitution of the Federal Republic of Nigeria, which chapter enshrines Fundamental Human Rights?",
		"options": ["Chapter IV (Chapter 4)", "Chapter I (Chapter 1)", "Chapter VII (Chapter 7)", "Chapter X (Chapter 10)"],
		"correct": 0,
		"emeka_hint": "Chapter 4! Sections 33 to 46 protect life, dignity, and personal liberty!",
		"tobi_hint": "Chapter IV contains fundamental human rights including right to life (s.33), dignity (s.34), and fair hearing (s.36)."
	},
	{
		"category": "Faculty of Social Sciences",
		"question": "In economics, what term describes a market condition where a single enterprise is the sole supplier of a good or service?",
		"options": ["Monopoly", "Perfect Competition", "Oligopoly", "Monopsony"],
		"correct": 0,
		"emeka_hint": "Mono means single! When only one seller controls the entire market!",
		"tobi_hint": "A monopoly exists when a single seller dominates supply with high barriers to entry."
	},

	# --- ROUND 5: THE GRAND FINALE (DEAN'S GOLD SHIELD QUESTION) ---
	{
		"category": "Grand Academic Championship",
		"question": "Who was Nigeria's first Indigenous Governor-General and first ceremonial President, celebrated as the 'Zik of Africa'?",
		"options": ["Dr. Nnamdi Azikiwe", "Sir Ahmadu Bello", "Chief Obafemi Awolowo", "Sir Tafawa Balewa"],
		"correct": 0,
		"emeka_hint": "The Zik of Africa! The great statesman from Nsukka and father of Nigerian nationalism!",
		"tobi_hint": "Dr. Benjamin Nnamdi Azikiwe served as Governor-General (1960–1963) and first President of Nigeria (1963–1966)."
	},
	{
		"category": "Grand Academic Championship",
		"question": "What is the longest bone in the human skeleton, capable of supporting up to 30 times an adult's body weight?",
		"options": ["Femur (Thigh Bone)", "Tibia (Shin Bone)", "Humerus (Upper Arm)", "Fibula (Calf Bone)"],
		"correct": 0,
		"emeka_hint": "The big thigh bone! Medical students call it the femur!",
		"tobi_hint": "The femur is the longest, strongest, and densest bone in the human skeletal anatomy."
	},
	{
		"category": "Grand Academic Championship",
		"question": "What famous landmark natural monolith rises 725 meters above sea level just north of Abuja along the highway to Kaduna?",
		"options": ["Zuma Rock", "Olumo Rock", "Aso Rock", "Idanre Hills"],
		"correct": 0,
		"emeka_hint": "The giant monolith with the natural face carved on it, featured on the ₦100 bank note!",
		"tobi_hint": "Zuma Rock is a massive natural igneous intrusion monolith located in Niger State, near Abuja."
	}
]


const ROUND_TIERS: Array[Dictionary] = [
	{
		"round": 1,
		"title": "Round 1: Freshers Orientation & Campus Slang",
		"reward_money": 1000,
		"reward_cgpa": 0.03,
		"reward_faith": 10.0,
		"pass_score": 1
	},
	{
		"round": 2,
		"title": "Round 2: Nigerian History & Scholarly Giants",
		"reward_money": 2000,
		"reward_cgpa": 0.04,
		"reward_faith": 15.0,
		"pass_score": 2
	},
	{
		"round": 3,
		"title": "Round 3: Faculty Science, Tech & Math",
		"reward_money": 3500,
		"reward_cgpa": 0.06,
		"reward_faith": 20.0,
		"pass_score": 3
	},
	{
		"round": 4,
		"title": "Round 4: Law, Governance & Philosophy",
		"reward_money": 5000,
		"reward_cgpa": 0.08,
		"reward_faith": 25.0,
		"pass_score": 4
	},
	{
		"round": 5,
		"title": "Grand Finale: Dean's Golden Academic Cup!",
		"reward_money": 10000,
		"reward_cgpa": 0.15,
		"reward_faith": 50.0,
		"pass_score": 5
	}
]


static func get_round_questions(total_rounds: int = 5) -> Array[Dictionary]:
	var selected: Array[Dictionary] = []
	var pool: Array[Dictionary] = QUESTIONS.duplicate()
	pool.shuffle()

	# Pick 1 question per round up to total_rounds
	for i in range(mini(total_rounds, pool.size())):
		selected.append(pool[i])
	return selected
