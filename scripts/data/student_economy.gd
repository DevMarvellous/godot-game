class_name StudentEconomySystem
extends RefCounted

## Nigerian Campus Student Hustle & Side Income System.
## Fully editable: Add more student jobs, investment gigs, or parental allowance mechanics.

const HUSTLE_ACTIVITIES: Array[Dictionary] = [
	{
		"id": "typing",
		"name": "Typing & Assignment Proofreading",
		"desc": "Type past questions and final year project chapters for coursemates.",
		"time_minutes": 60,
		"energy_cost": 18.0,
		"payout": 2500,
		"cgpa_boost": 0.02,
		"location": "sub"
	},
	{
		"id": "graphics",
		"name": "Campus Graphic Design (Flyers)",
		"desc": "Design church fellowship flyers or departmental political campaign posters.",
		"time_minutes": 90,
		"energy_cost": 25.0,
		"payout": 4500,
		"cgpa_boost": 0.0,
		"location": "hostel"
	},
	{
		"id": "hostel_kiosk",
		"name": "Hostel Room Provision Sales",
		"desc": "Sell chilled bottled water, biscuit, and emergency late-night noodles.",
		"time_minutes": 30,
		"energy_cost": 10.0,
		"payout": 1800,
		"cgpa_boost": 0.0,
		"location": "hostel"
	},
	{
		"id": "urgent_2k",
		"name": "Urgent 2k Request to Parents",
		"desc": "Call family back home for financial relief. Chance of success tied to current CGPA!",
		"time_minutes": 15,
		"energy_cost": 5.0,
		"payout": 5000,
		"cgpa_boost": 0.0,
		"location": "any"
	},
	{
		"id": "coding_gig",
		"name": "Web & Software Development Freelance",
		"desc": "Build a departmental portal or Godot web mini-game mentored by Mr. Adepoju Marvellous.",
		"time_minutes": 120,
		"energy_cost": 30.0,
		"payout": 8500,
		"cgpa_boost": 0.08,
		"location": "hostel"
	},
	{
		"id": "sponsored_airtime",
		"name": "Brand Ambassador & Sponsored Campus Ad",
		"desc": "Watch a quick sponsored campus brand clip / billboard partner ad to receive ₦1,500 emergency airtime & +20 Energy!",
		"time_minutes": 5,
		"energy_cost": -20.0, # Energy boost
		"payout": 1500,
		"cgpa_boost": 0.0,
		"location": "any"
	}
]
