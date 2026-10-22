class_name RelationshipSystem
extends RefCounted

## Nigerian Campus Student & Lecturer Relationship & Affinity Tracker.
## Tracks affinity (0-100) and unlocks campus perks (attendance covers, grade boosts, discounts).

static var character_affinity: Dictionary = {
	"Emeka": 20,
	"Segun": 35,
	"Chisom": 35,
	"Dr. Adebayo": 10,
	"Mr. Adepoju Marvellous": 20,
	"Mama Cashout": 25,
	"Iya Basira": 25,
	"Mallam Danladi": 20,
	"Chef Pierre": 10,
	"Tobi": 15,
	"Prof. Okonjo": 10,
	"Sister Blessing": 25,
	"Brother Chinedu": 15,
	"Comrade Aluta": 25,
	"Mama Nkechi": 20,
	"Master Sunday": 10,
	"Mrs. Janet": 15,
	"Coach Balogun": 20,
	"Baba Gani": 25,
	"Dr. Mrs. Adeyemi": 15,
	"Driver Rasheed": 20,
	"Officer Balogun": 15,
	"Kemi": 20
}

static func get_affinity(character_name: String) -> int:
	if character_affinity.has(character_name):
		return character_affinity[character_name]
	for key: String in character_affinity.keys():
		if character_name.begins_with(key) or key.begins_with(character_name):
			return character_affinity[key]
	return 0


static func modify_affinity(character_name: String, delta: int) -> int:
	var current: int = character_affinity.get(character_name, 0)
	var new_val: int = clampi(current + delta, 0, 100)
	character_affinity[character_name] = new_val
	return new_val


static func get_tier_name(affinity: int) -> String:
	if affinity >= 75:
		return "Bestie / Ride or Die"
	elif affinity >= 50:
		return "Close Friend"
	elif affinity >= 25:
		return "Coursemate"
	else:
		return "Just Met"


static func get_perk_description(character_name: String) -> String:
	var aff: int = get_affinity(character_name)
	match character_name:
		"Emeka":
			if aff >= 75:
				return "★ MAIN GUY: Signs lecture attendance for you if you are running late!"
			elif aff >= 50:
				return "✓ COURSE ALLY: Shares past question hints before CA tests."
			return "Coursemate: Friendly greeting in the hallway."
		"Dr. Adebayo":
			if aff >= 75:
				return "★ DEPARTMENTAL FAVORITE: Grade Mercy (+0.10 CGPA bonus on borderline scores)!"
			elif aff >= 50:
				return "✓ DILIGENT SCHOLAR: Explains complex lab algorithms after class."
			return "Lecturer: Strict attendance enforcer."
		"Mr. Adepoju Marvellous":
			if aff >= 75:
				return "★ CODE ARCHITECT MENTOR: Software Engineering Distinction (+0.25 CGPA boost & +₦2,000 gig stipend)!"
			elif aff >= 50:
				return "✓ LAB PROTÉGÉ: Early access to assignment hints and optimization techniques."
			return "Software Engineering Lecturer: Mentors aspiring programmers."
		"Mama Cashout":
			if aff >= 75:
				return "★ VIP CHOPPING: Free extra protein and 20% meal discount on every dish!"
			elif aff >= 50:
				return "✓ CANTEEN FAVORITE: Extra fried plantain (dodo) added to all orders."
			return "Canteen Caterer: Serves hot campus meals and survival rations."
		"Tobi":
			if aff >= 75:
				return "★ SENIOR BROTHER: Hands down his personal exam summary cheat-sheets (+0.20 CGPA boost)!"
			elif aff >= 50:
				return "✓ PROJECT MENTOR: Shares past exam questions with verified marking schemes."
			return "Final Year Senior: Experienced campus guide."
		"Sister Blessing":
			if aff >= 75:
				return "★ PRAYER PARTNER: Supernatural Peace (+25% Faith regeneration rate)."
			elif aff >= 50:
				return "✓ FELLOWSHIP SISTER: Emergency provisions relief fund during sapa."
			return "Fellowship Exec: Invites you to weekly prayer meetings."
		"Brother Chinedu":
			if aff >= 75:
				return "★ CYBER PARTNER: High-tier project typing gigs (+₦1,500 bonus payout)."
			elif aff >= 50:
				return "✓ REGULAR: 20% discount on laser printouts."
			return "Business Centre Guru: Types assignments and prints handouts."
		"Master Sunday":
			if aff >= 75:
				return "★ VIP CLIENT: 50% discount on all fresh cuts (₦500 instead of ₦1,000)!"
			elif aff >= 50:
				return "✓ CHAIRPERSON: Free beard grooming with every haircut."
			return "Campus Barber: Fresh low cuts and styling."
		"Baba Gani":
			if aff >= 75:
				return "★ SENATE INSIDER: VIP entry pass to the VC foyer & fast-track document stamps!"
			elif aff >= 50:
				return "✓ SENATE ELDER: Priority clearance guidance for matriculation and graduation files."
			return "Senate Porter: Watches over the executive building."
		"Dr. Mrs. Adeyemi":
			if aff >= 75:
				return "★ ACADEMIC DEAN PATRON: Error-free transcript clearance (+0.15 CGPA review bonus)!"
			elif aff >= 50:
				return "✓ REGISTRY EXPEDITOR: Resolves missing CA continuous assessment scores quickly."
			return "Deputy Registrar: Verifies official university credentials."
		"Driver Rasheed":
			if aff >= 75:
				return "★ CHAIRMAN OF THE PARK: Unlimited free Keke shuttle rides across campus!"
			elif aff >= 50:
				return "✓ REGULAR COMMUTER: Free Keke ride when you have less than ₦100 in wallet."
			return "Campus Keke Pilot: Drives students across campus hubs."
		"Officer Balogun":
			if aff >= 75:
				return "★ CHIEF SECURITY ALLY: Total immunity from curfew and gate checkpoint delays!"
			elif aff >= 50:
				return "✓ LAW-ABIDING SCHOLAR: Security waves you through without search during rush hours."
			return "Chief Campus Security: Guards university gates and perimeter."
		"Kemi":
			if aff >= 75:
				return "★ LEGAL SCHOLAR: Explains constitution case studies for exam prep (+0.12 CGPA boost)!"
			elif aff >= 50:
				return "✓ STUDY BUDDY: Shares concise course summaries and library revision timetables."
			return "Law Fresher: Focused 100L student studying at the canteen."
		_:
			return "Campus resident."

