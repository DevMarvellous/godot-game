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

