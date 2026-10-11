class_name WardrobeData
extends RefCounted

## Modular Wardrobe Data Store.
## Centralizes hairstyles, outfits, and skin complexions.
## Easily editable by any team member: add new clothes or hairstyles in one place.

const COMPLEXIONS: Array[Dictionary] = [
	{"id": "cocoa", "name": "Rich Cocoa", "color": Color(0.24, 0.15, 0.11)},
	{"id": "chestnut", "name": "Warm Chestnut", "color": Color(0.38, 0.24, 0.18)},
	{"id": "bronze", "name": "Golden Bronze", "color": Color(0.52, 0.35, 0.25)},
	{"id": "almond", "name": "Honey Almond", "color": Color(0.68, 0.48, 0.35)}
]

const HAIRSTYLES: Array[Dictionary] = [
	{
		"id": "low_cut",
		"name": "Clean Low Cut & Waves",
		"mesh_type": "low_cut",
		"price": 0,
		"default_color": Color(0.08, 0.08, 0.08),
		"description": "Sharp campus fade, fresh from Master Sunday's barbing salon."
	},
	{
		"id": "afro",
		"name": "Classic Round Afro",
		"mesh_type": "afro",
		"price": 0,
		"default_color": Color(0.08, 0.08, 0.08),
		"description": "Full, well-combed afro with retro 70s campus vibes."
	},
	{
		"id": "braids",
		"name": "Box Braids & Dreads",
		"mesh_type": "braids",
		"price": 0,
		"default_color": Color(0.06, 0.06, 0.06),
		"description": "Neat dreadlock strands and salon-crafted braids."
	},
	{
		"id": "cap",
		"name": "Campus Baseball Cap",
		"mesh_type": "cap",
		"price": 1200,
		"default_color": Color(0.15, 0.20, 0.35),
		"description": "Casual campus snapback cap for sunny days on the quad."
	},
	{
		"id": "headwrap",
		"name": "Traditional Headwrap / Gele",
		"mesh_type": "headwrap",
		"price": 1500,
		"default_color": Color(0.85, 0.45, 0.15),
		"description": "Regal cultural headwrap perfect for Sunday fellowship and matriculation."
	}
]

const OUTFITS: Array[Dictionary] = [
	{
		"id": "casual",
		"name": "Casual Polo & Denim Jeans",
		"mesh_type": "casual",
		"price": 0,
		"top_color": Color(0.12, 0.55, 0.32),
		"bottom_color": Color(0.15, 0.22, 0.32),
		"description": "Everyday university lecture wear with comfortable jeans."
	},
	{
		"id": "senator",
		"name": "Senator Native Attire",
		"mesh_type": "senator",
		"price": 4500,
		"top_color": Color(0.15, 0.18, 0.22),
		"bottom_color": Color(0.15, 0.18, 0.22),
		"description": "Crisp modern Nigerian native wear. Respected by lecturers and course reps."
	},
	{
		"id": "hoodie",
		"name": "Tech Bro Campus Hoodie",
		"mesh_type": "hoodie",
		"price": 3200,
		"top_color": Color(0.65, 0.15, 0.22),
		"bottom_color": Color(0.20, 0.22, 0.25),
		"description": "Heavy oversized hoodie for chilly library AC and midnight coding."
	},
	{
		"id": "corporate",
		"name": "Corporate Shirt & Silk Tie",
		"mesh_type": "corporate",
		"price": 2800,
		"top_color": Color(0.92, 0.94, 0.96),
		"bottom_color": Color(0.12, 0.12, 0.14),
		"description": "Formal business presentation attire for defense and seminar days."
	},
	{
		"id": "ankara_gown",
		"name": "Ankara Print Flare Gown",
		"mesh_type": "gown",
		"price": 5000,
		"top_color": Color(0.92, 0.48, 0.12),
		"bottom_color": Color(0.92, 0.48, 0.12),
		"description": "Vibrant West African wax-print gown tailored to stand out."
	}
]

static func get_hairstyle_by_id(hair_id: String) -> Dictionary:
	for h in HAIRSTYLES:
		if h["id"] == hair_id:
			return h
	return HAIRSTYLES[0]

static func get_outfit_by_id(outfit_id: String) -> Dictionary:
	for o in OUTFITS:
		if o["id"] == outfit_id:
			return o
	return OUTFITS[0]

