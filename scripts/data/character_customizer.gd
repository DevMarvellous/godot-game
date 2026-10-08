class_name CharacterCustomizer
extends RefCounted

## Editable character appearance presets and inventory.
## Optimized for low draw calls: swaps materials and tint colors on low-poly meshes.

const GENDERS: Array[String] = ["Male", "Female"]

const SKIN_TONES: Array[Dictionary] = [
	{"name": "Rich Cocoa", "color": Color(0.24, 0.15, 0.11)},
	{"name": "Warm Chestnut", "color": Color(0.38, 0.24, 0.18)},
	{"name": "Golden Bronze", "color": Color(0.52, 0.35, 0.25)},
	{"name": "Honey Almond", "color": Color(0.68, 0.48, 0.35)}
]

const SHIRT_STYLES: Array[Dictionary] = [
	{"name": "Emerald Faculty Polo", "color": Color(0.12, 0.55, 0.32)},
	{"name": "Royal Blue Tee", "color": Color(0.15, 0.35, 0.82)},
	{"name": "Ankara Print Orange", "color": Color(0.92, 0.48, 0.12)},
	{"name": "Bordeaux Red Hoodie", "color": Color(0.65, 0.15, 0.22)},
	{"name": "Chapel White Shirt", "color": Color(0.92, 0.94, 0.96)}
]

const TROUSER_STYLES: Array[Dictionary] = [
	{"name": "Dark Denim Jeans", "color": Color(0.15, 0.22, 0.32)},
	{"name": "Khaki Chinos", "color": Color(0.62, 0.54, 0.42)},
	{"name": "Black Formal Slacks", "color": Color(0.12, 0.12, 0.14)},
	{"name": "Track Joggers Grey", "color": Color(0.35, 0.37, 0.40)}
]

const HAIR_STYLES: Array[Dictionary] = [
	{"name": "Fade & Waves", "color": Color(0.08, 0.08, 0.08)},
	{"name": "Short Afro", "color": Color(0.1, 0.09, 0.08)},
	{"name": "Braids / Locs", "color": Color(0.06, 0.06, 0.06)},
	{"name": "Clean Low Cut", "color": Color(0.12, 0.1, 0.09)}
]

static func get_default_profile() -> Dictionary:
	return {
		"student_name": "Femi",
		"matric_no": "CSC/2026/042",
		"department": "CSC",
		"skin_index": 1,
		"shirt_index": 0,
		"trouser_index": 0,
		"hair_index": 0
	}

