class_name DialogueSystem
extends RefCounted

## Branching Dialogue Trees & Relationship Dynamics for Campus NPCs.
## Fully editable: Add more character responses and consequences here.

const DIALOGUE_TREES: Dictionary = {
	"Emeka": {
		"greeting": "Guy! How far? The practical manual for tomorrow, you don get am?",
		"choices": [
			{
				"text": "Yes, I got it. Do you need a copy?",
				"response": "Omo, God bless you! Course rep work no easy at all. Let me mark you present in advance!",
				"cgpa_boost": 0.05,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "No, I haven't gotten it. Did the lecturer share it?",
				"response": "Dr. Adebayo gave only 10 copies. Go meet him in the office before he gets upset!",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "I was thinking of skipping tomorrow's lecture...",
				"response": "Don't try am o! That man takes attendance seriously. You fit carry carryover!",
				"cgpa_boost": -0.05,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Dr. Adebayo": {
		"greeting": "Yes? What is your matriculation number, and why are you not reading in the library?",
		"choices": [
			{
				"text": "Good afternoon sir, I came to ask clarification on the sorting algorithm.",
				"response": "Good! A serious student at last. Pay attention in the next lab session, I will explain quicksort again.",
				"cgpa_boost": 0.10,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Sir, can you please extend the assignment submission deadline?",
				"response": "Extend what?! University is not a secondary school. Submit tomorrow 8:00 AM sharp!",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Good day sir, just greeting you respectfully.",
				"response": "Greetings accepted. Now go and open your textbooks.",
				"cgpa_boost": 0.02,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Mr. Adepoju Marvellous": {
		"greeting": "Welcome to the Engineering Lab! Clean code, solid game architecture, and zero runtime crashes are what define an elite developer.",
		"choices": [
			{
				"text": "Sir, how do we optimize Godot WebAssembly exports for mobile low-latency?",
				"response": "Brilliant inquiry! Keep textures compressed, synthesize procedural audio in-memory, and use non-blocking web sockets. Here is a +0.15 CGPA bonus for engineering excellence!",
				"cgpa_boost": 0.15,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Can you review my software engineering project design document?",
				"response": "Modular architecture, clean OOP, and decoupled signal design. Excellent work! Keep pushing your boundaries.",
				"cgpa_boost": 0.10,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Mr. Marvellous, I was feeling overwhelmed by all these university exams.",
				"response": "Every master was once a beginner who refused to quit. Breathe, iterate step by step, and build with conviction!",
				"cgpa_boost": 0.05,
				"faith_boost": 15.0,
				"money_change": 0
			}
		]
	},
	"Prof. Okonjo": {
		"greeting": "Calculus requires mental discipline! If you don't master limits and integrals, engineering and computing will humble you.",
		"choices": [
			{
				"text": "Professor, I solved the differential equation assignment on page 42.",
				"response": "Excellent! That is the spirit of scholarship. You have earned bonus continuous assessment marks.",
				"cgpa_boost": 0.12,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Sir, can you recommend an extra textbook for revision?",
				"response": "Go to the Central Library and borrow Stroud Engineering Mathematics or Thomas Calculus.",
				"cgpa_boost": 0.05,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Mrs. Folashade": {
		"greeting": "Good day students! In GST 101, clarity of communication and proper diction are essential for future leaders.",
		"choices": [
			{
				"text": "Good day ma! I wanted to confirm if our term paper requires APA referencing.",
				"response": "Yes, strictly APA 7th edition! Plagiarism is a serious disciplinary offense in this university.",
				"cgpa_boost": 0.06,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Ma, can we form study groups for the upcoming presentation?",
				"response": "Highly encouraged! Peer learning sharpens your public speaking skills.",
				"cgpa_boost": 0.04,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Sister Blessing": {
		"greeting": "Praise the Lord, brother/sister! Hope your spirit is energized today?",
		"choices": [
			{
				"text": "Hallelujah! I will definitely attend the fellowship this evening.",
				"response": "Glory to God! The Lord will grant you supernatural wisdom for your exams!",
				"cgpa_boost": 0.05,
				"faith_boost": 25.0,
				"money_change": 0
			},
			{
				"text": "Academic stress is really weighing me down, Sister Blessing.",
				"response": "Cast your burdens upon Him! Let us say a quick prayer together right now.",
				"cgpa_boost": 0.0,
				"faith_boost": 20.0,
				"money_change": 0
			},
			{
				"text": "I need some urgent provisions money, can the fellowship assist?",
				"response": "The welfare unit has a student relief fund. Take ₦1,500 for emergency meals.",
				"cgpa_boost": 0.0,
				"faith_boost": 10.0,
				"money_change": 1500
			}
		]
	},
	"Brother Chinedu": {
		"greeting": "Sharp guy! Welcome to Chinedu Cyber & Print Hub. You need typing, project binding, or flyer design?",
		"choices": [
			{
				"text": "Brother Chinedu, do you have any typing gig for me to earn cash?",
				"response": "Sure! Type this 15-page SIWES report for a final year student. Here is ₦2,500 cash for quick delivery!",
				"cgpa_boost": 0.02,
				"faith_boost": 0.0,
				"money_change": 2500
			},
			{
				"text": "Please print 10 copies of our tutorial assignment handout.",
				"response": "Done! That will be ₦500 for quality laser prints on bond paper.",
				"cgpa_boost": 0.04,
				"faith_boost": 0.0,
				"money_change": -500
			},
			{
				"text": "Just looking around the SUB business centre, bro.",
				"response": "No wahala! Whenever your printer runs out of ink in the hostel, you know where to run to.",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Master Sunday": {
		"greeting": "Chairman! Welcome to Executive Cuts. Looking neat is good business on campus. What cut are you getting?",
		"choices": [
			{
				"text": "Give me a fresh low-cut with sharp line-up (₦1,000).",
				"response": "Sharp! You look like a First Class student ready for Senate defense now! Confidence boosted!",
				"cgpa_boost": 0.05,
				"faith_boost": 0.0,
				"money_change": -1000
			},
			{
				"text": "Just trimming and beard grooming, Master Sunday (₦600).",
				"response": "Clean work, boss! Go and pepper them in the lecture hall today!",
				"cgpa_boost": 0.02,
				"faith_boost": 0.0,
				"money_change": -600
			},
			{
				"text": "Just checking your price list, Chief.",
				"response": "Anytime, chairman. Pocket will be heavy soon, then come get that fresh cut!",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Mama Cashout": {
		"greeting": "My pikin! Welcome to Mama Cashout! Hot party jollof with spicy chicken, egusi soup, or late-night Indomie with double eggs... wetin you dey chop today?",
		"choices": [
			{
				"text": "Mama, please add extra fried plantain (dodo) on my jollof rice!",
				"response": "Aww, good student! Because you dey read well well, I put two extra pieces of dodo for you free of charge! Go make us proud!",
				"cgpa_boost": 0.02,
				"faith_boost": 5.0,
				"money_change": 0
			},
			{
				"text": "Mama, sapa dey hold me small today. Any student discount?",
				"response": "Ehya! No student will starve inside my cafeteria! Take this warm meat pie and pure water, pay me whenever your pocket soft.",
				"cgpa_boost": 0.0,
				"faith_boost": 10.0,
				"money_change": 0
			},
			{
				"text": "Mama, your food sweet die! The smell alone dey revive person energy.",
				"response": "Haha! God bless your mouth, my child! Eat well, food na fuel for brain during exam season!",
				"cgpa_boost": 0.03,
				"faith_boost": 5.0,
				"money_change": 0
			}
		]
	},
	"Iya Basira": {
		"greeting": "Bawo ni omo mi! Steaming hot Amala Lafun with fresh ewedu, gbegiri, and tender goat meat or ponmo! How many wraps?",
		"choices": [
			{
				"text": "Iya Basira, give me 2 wraps of Amala with correct goat meat!",
				"response": "O ti ya! Chop am while e hot, this local delicacy go give you heavy energy to tackle calculus!",
				"cgpa_boost": 0.03,
				"faith_boost": 0.0,
				"money_change": -800
			},
			{
				"text": "Ma, is the gbegiri and pepper soup fresh?",
				"response": "Straight from fire this morning! Pure authentic taste, no shortcuts!",
				"cgpa_boost": 0.01,
				"faith_boost": 5.0,
				"money_change": 0
			},
			{
				"text": "Just enjoying the canteen aroma, ma.",
				"response": "E ma wo o! Anytime hunger strikes, come straight to Iya Basira Amala corner!",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Mallam Danladi": {
		"greeting": "Sannu aboki! Special Indomie with double eggs and fried suya beef dey ready. Fast food for sharp brain!",
		"choices": [
			{
				"text": "Mallam, prepare one carton Indomie with suya pepper!",
				"response": "Sharp sharp! In 4 minutes flat, your meal is steaming hot! ₦650 only.",
				"cgpa_boost": 0.02,
				"faith_boost": 0.0,
				"money_change": -650
			},
			{
				"text": "Mallam, do you have cold malt or chilled Zobo drink?",
				"response": "Chilled inside ice bucket! Refresh your throat before your afternoon lecture.",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": -250
			},
			{
				"text": "Good day Mallam, just greeting.",
				"response": "Nagode aboki! More grace for your exams!",
				"cgpa_boost": 0.0,
				"faith_boost": 5.0,
				"money_change": 0
			}
		]
	},
	"Chef Pierre": {
		"greeting": "Bienvenue to The Senate Bistro & Grill! Air-conditioned dining, continental breakfast, gourmet burgers, and creamy iced coffee. Are you dining with us today?",
		"choices": [
			{
				"text": "Chef, what is today's executive special?",
				"response": "Prime cut grilled steak with potato wedges and fresh berry parfait (₦3,800). Complete luxury dining fit for a future CEO!",
				"cgpa_boost": 0.04,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Can I get an iced vanilla latte to boost my study focus?",
				"response": "Certainly! Our double-shot espresso iced latte gives +35% instant focus without sugar crash. ₦1,200 only.",
				"cgpa_boost": 0.06,
				"faith_boost": 0.0,
				"money_change": -1200
			},
			{
				"text": "Just checking the VIP ambience, chef. My pocket is on student budget today.",
				"response": "Haha! Sapa visits everyone on campus! Work hard, pass your exams, and come celebrate your First Class here!",
				"cgpa_boost": 0.02,
				"faith_boost": 5.0,
				"money_change": 0
			}
		]
	},
	"Tobi": {
		"greeting": "Fresher! How campus dey be? Final year project dey show me pepper, but we go conquer. You need any survival advice?",
		"choices": [
			{
				"text": "Senior Tobi, how do you manage 8:00 AM classes without collapsing?",
				"response": "Rule number one: Sleep by 10 PM in the hostel, and don't skip breakfast at Mama Cashout! Burnout is real.",
				"cgpa_boost": 0.04,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Do you have any past questions for CSC and MTH 101?",
				"response": "I get the full compiled booklet with marking schemes! Take this copy, revise all past years thoroughly.",
				"cgpa_boost": 0.08,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Just enjoying the canteen jollof rice, bro.",
				"response": "Chop well! You need all the energy you can get for this university life.",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Segun": {
		"greeting": "Roomie! You don wake up? NEPA just brought light, rush charge your phone before they take am again!",
		"choices": [
			{
				"text": "Thanks Segun! Are you heading to the 8 AM lecture today?",
				"response": "Yes o! You know Dr. Adebayo doesn't joke with 8:05 AM door lock. Let's move together!",
				"cgpa_boost": 0.04,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Did you understand yesterday's algorithms assignment?",
				"response": "I solved question 1 and 2, but number 3 was tough. We can revise it together on the study desk!",
				"cgpa_boost": 0.06,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Roomie, abeg do you have iron or hot water?",
				"response": "Hot plate dey under bed! Just boil your noodles quick before the hall porter comes on inspection.",
				"cgpa_boost": 0.0,
				"faith_boost": 5.0,
				"money_change": 0
			}
		]
	},
	"Chisom": {
		"greeting": "Roomie babe! Good morning! NEPA brought light o, I've plugged our rechargeable lamp and ironed our class clothes!",
		"choices": [
			{
				"text": "Good morning Chisom! What time is our first lecture?",
				"response": "8:00 AM sharp! Let's hurry so we can grab front seats before the backbenchers make noise.",
				"cgpa_boost": 0.05,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Chisom, did you finish summarizing the lecture slides?",
				"response": "Yes babe! I highlighted all the key definitions. Take my note to photocopy at Chinedu's hub!",
				"cgpa_boost": 0.08,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Do you want to split a pack of pasta for breakfast?",
				"response": "Aww sweet! I have eggs and pepper, let's cook quickly on my hot plate!",
				"cgpa_boost": 0.0,
				"faith_boost": 10.0,
				"money_change": 0
			}
		]
	},
	"Mrs. Janet": {
		"greeting": "Shhh! Keep your voice down, this is a quiet study sanctuary. What textbook or past questions volume are you looking for?",
		"choices": [
			{
				"text": "Ma, I need past questions and reference books for my department.",
				"response": "Check Shelf B on the right side. Make sure you sign the borrowing card before leaving!",
				"cgpa_boost": 0.08,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Can I leave my bag at the library security counter?",
				"response": "Yes, drop it in locker 14. Keep your library ID card with you at all times.",
				"cgpa_boost": 0.02,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Just finding a cool, quiet corner to read.",
				"response": "Very well. Remember, no phone calls or snacks inside the reading hall!",
				"cgpa_boost": 0.04,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	},
	"Coach Balogun": {
		"greeting": "Oya double up! Fitness is key for academic resilience! The Inter-Faculty Dean's Cup is starting soon. Are you ready to train or take penalty kicks?",
		"choices": [
			{
				"text": "Coach! Let me join the faculty 5-a-side football training drills!",
				"response": "Good stamina! Sweating out exam stress clears your brain. +35% Energy, +0.03 Athletic Reputation!",
				"cgpa_boost": 0.03,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Coach, who is the defending champion of the Vice-Chancellor's Cup?",
				"response": "Faculty of Engineering! But Computing and Social Sciences are bringing fire this season. Practice your shots!",
				"cgpa_boost": 0.01,
				"faith_boost": 0.0,
				"money_change": 0
			},
			{
				"text": "Can I rent a jersey and boots from the sports pavilion?",
				"response": "Sure thing. ₦300 maintenance fee, return them clean after match practice.",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": -300
			}
		]
	}
}

static func get_dialogue(npc_name: String) -> Dictionary:
	if DIALOGUE_TREES.has(npc_name):
		return DIALOGUE_TREES[npc_name]
	return {
		"greeting": "Hello! Campus is busy today.",
		"choices": [
			{
				"text": "Take care!",
				"response": "You too, good luck with lectures!",
				"cgpa_boost": 0.0,
				"faith_boost": 0.0,
				"money_change": 0
			}
		]
	}

