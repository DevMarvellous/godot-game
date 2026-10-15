class_name FoodData
extends RefCounted

## Modular Campus Food Menu Catalog (Mama Put & Canteen).
## Defines dishes, portion prices, hunger restoration, and stamina boosts.
## Easily editable: tweak prices or add new dishes here.

const DISHES: Array[Dictionary] = [
	{
		"id": "jollof_chicken",
		"name": "Firewood Jollof Rice & Fried Chicken",
		"price": 1200,
		"hunger_restore": 55.0,
		"energy_boost": 25.0,
		"icon": "🍗",
		"description": "Smoky party jollof with spicy peppered chicken and fried plantain (dodo)."
	},
	{
		"id": "amala_ewedu",
		"name": "Hot Amala, Ewedu, Gbegiri & Goat Meat",
		"price": 1000,
		"hunger_restore": 65.0,
		"energy_boost": 20.0,
		"icon": "🍲",
		"description": "Authentic steaming black amala from Iya Basira's clay pot."
	},
	{
		"id": "indomie_egg",
		"name": "Mallam Danladi's Double Indomie & Fried Egg",
		"price": 700,
		"hunger_restore": 45.0,
		"energy_boost": 30.0,
		"icon": "🍳",
		"description": "Spicy stir-fried instant noodles with onions, pepper, and runny fried egg."
	},
	{
		"id": "suya_special",
		"name": "Evening Beef Suya with Fresh Onions & Pepper",
		"price": 800,
		"hunger_restore": 35.0,
		"energy_boost": 15.0,
		"icon": "🥩",
		"description": "Charcoal grilled skewered beef wrapped in old newspaper."
	},
	{
		"id": "malta_drink",
		"name": "Chilled Bottle of Malta Guinness",
		"price": 400,
		"hunger_restore": 15.0,
		"energy_boost": 35.0,
		"icon": "🥤",
		"description": "Ice-cold malt drink to beat the hot university afternoon heat."
	},
	{
		"id": "pure_water_bag",
		"name": "Bag of Pure Water (20 Sachets)",
		"price": 300,
		"hunger_restore": 5.0,
		"energy_boost": 10.0,
		"icon": "💧",
		"description": "Chilled sachet water for your hostel room jerrycan."
	},
	{
		"id": "boli_groundnut",
		"name": "Roasted Boli & Crunchy Groundnuts",
		"price": 500,
		"hunger_restore": 40.0,
		"energy_boost": 20.0,
		"icon": "🍌",
		"description": "Charcoal roasted sweet plantain with roasted groundnuts. Authentic campus afternoon snack!"
	},
	{
		"id": "fried_yam_sauce",
		"name": "Fried Yam (Dundun) & Pepper Sauce",
		"price": 650,
		"hunger_restore": 45.0,
		"energy_boost": 22.0,
		"icon": "🍠",
		"description": "Crispy golden yam slices dipped in spicy peppered tomato sauce."
	}
]

static func get_dish_by_id(dish_id: String) -> Dictionary:
	for dish in DISHES:
		if dish["id"] == dish_id:
			return dish
	return {}

