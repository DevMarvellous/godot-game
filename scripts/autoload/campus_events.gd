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
var event_cooldown_minutes: int = 50
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
		"id": &"dr_adebayo_pop_quiz",
		"title": "📚 DR. ADEBAYO SURPRISE QUIZ!",
		"desc": "Course Rep pings the group: 'Dr. Adebayo just entered LT1 with surprise attendance sheets!' Bonus CGPA awarded if you are on campus!",
		"effect": "pop_quiz"
	},
	{
		"id": &"urgent_2k_req",
		"title": "📱 WHATSAPP: COURSEMATE URGENT 2K",
		"desc": "Emeka pings you: 'Guy abeg borrow me ₦1,500 for handouts, I will return ₦2,000 on Friday!' Sapa solidarity (+15 Faith)!",
		"effect": "urgent_req"
	},
	{
		"id": &"mama_put_promo",
		"title": "🍲 MAMA CASHOUT PROMO HOUR!",
		"desc": "Mama Put announces Firewood Jollof & Dodo discount hour! All meals 50% off and double energy recovery!",
		"effect": "buka_promo"
	},
	{
		"id": &"water_shortage",
		"title": "💧 WATER SHORTAGE IN HOSTEL!",
		"desc": "The central overhead water tank is dry! You must fetch water from the ground borehole using your yellow 25L jerrycan.",
		"effect": "water"
	},
	{
		"id": &"rainstorm_surge",
		"title": "🌧️ HEAVY DOWNPOUR OVER CAMPUS!",
		"desc": "A heavy tropical rainstorm breaks out over campus gate! Keke shuttle queues grow longer. Cool breezes sweep through the hostels.",
		"effect": "rain"
	},
	{
		"id": &"deans_cup_win",
		"title": "🏆 DEAN'S CUP FOOTBALL TRIUMPH!",
		"desc": "Wild celebration at the stadium! Your faculty just scored a 90th-minute header to advance to the finals! Campus morale boosted!",
		"effect": "cheer"
	},
	{
		"id": &"warden_inspection",
		"title": "📋 SURPRISE HOSTEL ROOM INSPECTION!",
		"desc": "Hall warden checked your bunk bed and reading desk! Good hygiene and tidy room confirmed. Commendation given!",
		"effect": "warden"
	},
	{
		"id": &"boiling_ring_panic",
		"title": "⚠️ HALL WARDEN BOILING RING INSPECTION!",
		"desc": "KPA KPA KPA! Hall Warden is knocking at your door! Hide the boiling ring and hotplate inside the wardrobe before you get caught!",
		"effect": "boiling_ring"
	},
	{
		"id": &"chapel_choir_mob",
		"title": "🎶 CAMPUS PRAISE & WORSHIP FLASH MOB!",
		"desc": "The Joint Campus Fellowship choir erupts into an acoustic praise chorus across the academic quad! Faith and joy overflow (+35 Faith, +20 Energy)!",
		"effect": "praise_mob"
	},
	{
		"id": &"family_alert",
		"title": "📱 OPAY CREDIT ALERT: +₦6,000 BLESSING!",
		"desc": "Uncle in Ibadan pings: 'God bless your studies, buy good food and handouts.' Wallet credited +₦6,000!",
		"effect": "family_blessing"
	},
	{
		"id": &"fellowship_bread",
		"title": "🥖 BROTHER EMMANUEL FELLOWSHIP GIFTS!",
		"desc": "Coursemates gifted you freshly baked oven bread and chilled fruit juice for revision night! Hunger restored (+35 Hunger, +20 Faith).",
		"effect": "fellowship_snack"
	}
]

var real_time_elapsed: float = 0.0
var next_event_interval: float = 160.0 # 2.5 to 3.5 minutes real time


func _ready() -> void:
	if TimeSystem:
		TimeSystem.minute_passed.connect(_on_minute_passed)
	next_event_interval = randf_range(150.0, 210.0)


func _process(delta: float) -> void:
	real_time_elapsed += delta
	if real_time_elapsed >= next_event_interval:
		real_time_elapsed = 0.0
		next_event_interval = randf_range(160.0, 240.0)
		var total_mins: int = TimeSystem.get_total_minutes() if TimeSystem else 0
		_trigger_random_event(total_mins)


func _on_minute_passed() -> void:
	var current_total_minutes: int = TimeSystem.get_total_minutes()
	if current_total_minutes - last_event_time_minutes < event_cooldown_minutes:
		return

	# Dynamic chance after cooldown so events pop regularly and campus feels alive!
	if randf() < 0.12:
		_trigger_random_event(current_total_minutes)


func trigger_event_by_id(target_id: StringName) -> bool:
	for ev in EVENTS:
		if ev["id"] == target_id:
			_apply_event_effect(ev)
			return true
	return false


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

		"pop_quiz":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_cgpa(0.06)
			sound_to_play = "bell"

		"urgent_req":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_faith(20.0)
			sound_to_play = "coin"

		"buka_promo":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_hunger(30.0)
					needs.modify_energy(20.0)
			sound_to_play = "bell"

		"water":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_energy(-12.0)
			sound_to_play = "alert"

		"rain":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_energy(10.0) # Cool weather relaxes student
			sound_to_play = "bell"

		"cheer":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_faith(25.0)
			sound_to_play = "bell"

		"warden":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_faith(20.0)
			sound_to_play = "coin"

		"boiling_ring":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_faith(10.0)
			sound_to_play = "alert"

		"praise_mob":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_faith(35.0)
					needs.modify_energy(20.0)
			sound_to_play = "bell"

		"family_blessing":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_money(6000)
					needs.modify_faith(20.0)
			sound_to_play = "coin"

		"fellowship_snack":
			var player = _get_active_player()
			if player:
				var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
				if needs:
					needs.modify_hunger(35.0)
					needs.modify_faith(20.0)
			sound_to_play = "bell"

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
