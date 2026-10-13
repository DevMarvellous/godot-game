extends Node

## Campus Life Dynamic Events & Random Encounters.
## Simulates authentic Nigerian university experiences:
## - "NEPA took light!" (Power outages & generator hustle)
## - "UP NEPA!" (Power returns with cheers)
## - "Surprise test announced by Course Rep"
## - "Bank Alert: Family sent Urgent 2k"
## - "Roommate cooked Indomie & eggs"
## - "Water shortage in the hostel"

signal event_triggered(event_id: StringName, event_title: String, event_description: String)
signal power_state_changed(has_power: bool)

var has_electricity: bool = true
var event_cooldown_minutes: int = 45
var last_event_time_minutes: int = 0

const EVENTS: Array[Dictionary] = [
	{
		"id": &"nepa_outage",
		"title": "⚡ NEPA TOOK LIGHT!",
		"desc": "Hall 2 suddenly plunges into total blackout! Phone charging stopped. Time to hustle for generator spots at the library!",
		"effect": "nepa"
	},
	{
		"id": &"up_nepa",
		"title": "💡 \"UP NEPA!\" POWER RESTORED!",
		"desc": "Wild shouts of 'UP NEPA!' erupt across the entire campus hostel! Everyone is rushing to plug their chargers and boiling rings!",
		"effect": "light_back"
	},
	{
		"id": &"urgent_2k",
		"title": "📱 OPAY CREDIT ALERT: +₦5,000",
		"desc": "Your Uncle in Lagos just responded to your WhatsApp message: 'Manage this for biscuits and handouts.' Wallet credited!",
		"effect": "money"
	},
	{
		"id": &"roommate_indomie",
		"title": "🍜 ROOMMATE COOKED INDOMIE!",
		"desc": "Your roommate boiled two packs of Indomie with boiled eggs and pepper, and left a warm portion on your reading desk! Hunger restored.",
		"effect": "food"
	},
	{
		"id": &"past_questions",
		"title": "📚 400L SENIOR SHARED EXAM EXPO / PAST QUESTIONS!",
		"desc": "A helpful 400L final year student just shared the past 5 years of exam questions and marking guides for your 100L courses! Exam confidence boosted.",
		"effect": "study"
	},
	{
		"id": &"water_shortage",
		"title": "💧 WATER SHORTAGE IN HOSTEL!",
		"desc": "The central overhead water tank is dry! You must fetch water from the ground borehole using your yellow 25L jerrycan.",
		"effect": "water"
	}
]


func _ready() -> void:
	if TimeSystem:
		TimeSystem.minute_passed.connect(_on_minute_passed)


func _on_minute_passed() -> void:
	var current_total_minutes: int = TimeSystem.get_total_minutes()
	if current_total_minutes - last_event_time_minutes < event_cooldown_minutes:
		return

	# Roll 6% chance each in-game hour
	if randf() < 0.08:
		_trigger_random_event(current_total_minutes)


func _trigger_random_event(current_time: int) -> void:
	last_event_time_minutes = current_time

	# Filter valid events based on power state
	var candidate_events: Array[Dictionary] = []
	for ev in EVENTS:
		if ev["id"] == &"up_nepa" and has_electricity:
			continue
		if ev["id"] == &"nepa_outage" and not has_electricity:
			continue
		candidate_events.append(ev)

	if candidate_events.is_empty():
		return

	var chosen: Dictionary = candidate_events[randi() % candidate_events.size()]
	_apply_event_effect(chosen)


func _apply_event_effect(ev: Dictionary) -> void:
	var effect_type: String = ev.get("effect", "")
	var sound_to_play: String = "alert"

	match effect_type:
		"nepa":
			has_electricity = false
			power_state_changed.emit(false)
			sound_to_play = "alert"

		"light_back":
			has_electricity = true
			power_state_changed.emit(true)
			sound_to_play = "bell"

		"money":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_money(5000)
			sound_to_play = "coin"

		"food":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_hunger(40.0)
			sound_to_play = "bell"

		"study":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_cgpa(0.08)
			sound_to_play = "bell"

		"water":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_energy(-12.0)
			sound_to_play = "alert"

	var sm = get_node_or_null("/root/SoundManager")
	if sm:
		match sound_to_play:
			"coin": sm.play_coin()
			"bell": sm.play_bell()
			"alert": sm.play_alert()

	event_triggered.emit(ev["id"], ev["title"], ev["desc"])

	# Show floating notification on active player
	var player = _get_active_player()
	if player and player.has_method("display_notification"):
		player.display_notification("%s: %s" % [ev["title"], ev["desc"]])


func _get_active_player() -> CharacterBody3D:
	var tree = get_tree()
	if not tree or not tree.current_scene:
		return null
	return tree.current_scene.get_node_or_null("Player3D") as CharacterBody3D
