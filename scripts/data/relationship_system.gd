class_name RelationshipSystem
extends RefCounted

## Nigerian Campus Student & Lecturer Relationship & Affinity Tracker.
## Tracks affinity (0-100) and unlocks campus perks (attendance covers, grade boosts, discounts).

static var character_affinity: Dictionary = {
	"Emeka": 20,
	"Dr. Adebayo": 10,
	"Mr. Adepoju Marvellous": 20,
	"Prof. Okonjo": 10,
	"Sister Blessing": 25,
	"Brother Chinedu": 15,
	"Master Sunday": 10
}

static func get_affinity(character_name: String) -> int:
	return character_affinity.get(character_name, 0)


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
		_:
			return "Campus resident."

