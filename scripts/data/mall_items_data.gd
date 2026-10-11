class_name MallItemsData
extends RefCounted

## Modular Campus Mall Catalog.
## Lists all equipment, study gear, snacks, and gadgets available for sale.
## Easily editable by changing items in this array.

const ITEMS: Array[Dictionary] = [
	{
		"id": "power_bank",
		"name": "20,000mAh Heavy Duty Power Bank",
		"price": 6500,
		"category": "gadget",
		"icon": "🔋",
		"description": "Never get stranded when Hall 2 experiences a blackout! Keeps phone at 100%."
	},
	{
		"id": "calc_fx991",
		"name": "Scientific Calculator (Casio fx-991)",
		"price": 4500,
		"category": "academic",
		"icon": "🧮",
		"description": "Essential tool for MTH 101 Calculus and PHY tests. +15% Exam Performance."
	},
	{
		"id": "oxford_set",
		"name": "Oxford Mathematical Drawing Set",
		"price": 1800,
		"category": "academic",
		"icon": "📐",
		"description": "Tin box with metal compass, divider, and ruler. Needed for lab diagrams."
	},
	{
		"id": "designer_shades",
		"name": "Dark Campus Sunglasses",
		"price": 2500,
		"category": "fashion",
		"icon": "🕶️",
		"description": "High swagger points. Walk through the quad looking like a final year boss (+15 Clout)."
	},
	{
		"id": "perfume_oil",
		"name": "6ml Arabian Oud Perfume Oil",
		"price": 1500,
		"category": "fashion",
		"icon": "✨",
		"description": "Smell fresh throughout long 4-hour lectures (+10 Social Confidence)."
	},
	{
		"id": "indomie_carton",
		"name": "Carton of Indomie Noodles (40 Packs)",
		"price": 8500,
		"category": "provisions",
		"icon": "📦",
		"description": "The ultimate campus lifesaver. Keeps you fed for an entire month without stepping out."
	},
	{
		"id": "white_sneakers",
		"name": "Clean White Campus Sneakers",
		"price": 7500,
		"category": "fashion",
		"icon": "👟",
		"description": "Fresh white kicks that match both denim jeans and sweatpants."
	}
]

static func get_item_by_id(item_id: String) -> Dictionary:
	for item in ITEMS:
		if item["id"] == item_id:
			return item
	return {}

