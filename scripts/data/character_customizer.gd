class_name CharacterCustomizer
extends RefCounted

## Character customizer adapter that points directly to modular WardrobeData.
## Maintains backward compatibility while keeping wardrobe items in one central file.

const GENDERS: Array[String] = ["Male", "Female"]

const SKIN_TONES: Array[Dictionary] = WardrobeData.COMPLEXIONS
const HAIR_STYLES: Array[Dictionary] = WardrobeData.HAIRSTYLES
const SHIRT_STYLES: Array[Dictionary] = WardrobeData.OUTFITS

const TROUSER_STYLES: Array[Dictionary] = [
	{"name": "Matching Attire Slacks", "color": Color(0.15, 0.22, 0.32)},
	{"name": "Dark Denim Jeans", "color": Color(0.12, 0.16, 0.24)},
	{"name": "Khaki Chinos", "color": Color(0.62, 0.54, 0.42)},
	{"name": "Formal Black Slacks", "color": Color(0.10, 0.10, 0.12)}
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
