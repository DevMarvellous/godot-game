class_name HostelCookingDialog
extends Control

## Interactive Hostel Room Kitchenette & Provisions Cooking Desk.
## Gives students affordable, quick food options right inside their hostel room:
## - Boiling spicy Indomie noodles on electric coil hotplate
## - Soaking chilled Garri with milk & groundnuts
## - Brewing Bournvita / Milo for late-night study alertness
## - Chilled beverages from bedside Mini-Fridge

signal meal_cooked(meal_name: String, hunger_gain: float, energy_gain: float)
signal dialog_closed

const StudentProfile = preload("res://scripts/data/student_profile.gd")

@onready var close_btn: Button = %CloseBtn
@onready var wallet_label: Label = %WalletLabel
@onready var provision_status_label: Label = %ProvisionStatusLabel
@onready var meals_container: VBoxContainer = %MealsContainer

var current_player: CharacterBody3D = null

const MEALS: Array[Dictionary] = [
	{
		"id": "indomie",
		"name": "🍜 Double Spicy Indomie & Boiled Egg",
		"desc": "Stir-fried on electric hotplate with pepper and a boiled egg.",
		"base_cost": 350,
		"hunger": 55.0,
		"energy": 25.0,
		"time_mins": 15,
		"uses_carton": true
	},
	{
		"id": "garri",
		"name": "🥣 Ice-Water Garri, Milk & Groundnuts",
		"desc": "Crunchy Ijebu garri soaked in cold water with Peak milk, sugar & groundnuts.",
		"base_cost": 150,
		"hunger": 40.0,
		"energy": 18.0,
		"time_mins": 5,
		"uses_carton": false
	},
	{
		"id": "bournvita",
		"name": "☕ Hot Mug of Bournvita & Evaporated Milk",
		"desc": "Creamy chocolate malt to fuel late-night exam revision & focus.",
		"base_cost": 200,
		"hunger": 15.0,
		"energy": 28.0,
		"time_mins": 8,
		"uses_carton": false
	},
	{
		"id": "agege_bread",
		"name": "🍞 Agege Bread & Margarine Spread",
		"desc": "Soft, stretchy fresh campus bread with sweet butter spread.",
		"base_cost": 300,
		"hunger": 45.0,
		"energy": 20.0,
		"time_mins": 10,
		"uses_carton": false
	},
	{
		"id": "chilled_water",
		"name": "🧊 Chilled Pure Water / Zobo Drink",
		"desc": "Ice-cold drink straight from your bedside mini-fridge chiller.",
		"base_cost": 0,
		"hunger": 10.0,
		"energy": 20.0,
		"time_mins": 3,
		"requires_fridge": true
	}
]


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_dialog)


func open_cooking(player: CharacterBody3D) -> void:
	current_player = player
	StudentProfile.load_from_disk()
	_refresh_ui()
	visible = true
	if SoundManager:
		SoundManager.play_click()


func _refresh_ui() -> void:
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager if current_player else null
	var wallet: int = needs.money if needs else 5000

	if wallet_label:
		wallet_label.text = "CampusPay Wallet: ₦%s" % _format_number(wallet)

	var has_carton: bool = StudentProfile.owned_upgrades.has("indomie_carton")
	var has_fridge: bool = StudentProfile.owned_upgrades.has("mini_fridge")

	if provision_status_label:
		var status_str: String = ""
		if has_carton:
			status_str += "📦 Indomie Carton: IN STOCK (Free Noodles!)  •  "
		else:
			status_str += "📦 Provisions: Buying per pack  •  "
		if has_fridge:
			status_str += "🧊 Mini-Fridge: CHILLING"
		else:
			status_str += "🧊 Room Temp"
		provision_status_label.text = status_str

	# Populate meals
	if meals_container:
		for child: Node in meals_container.get_children():
			child.queue_free()

		for meal: Dictionary in MEALS:
			var card: PanelContainer = _build_meal_card(meal, wallet, has_carton, has_fridge)
			meals_container.add_child(card)


func _build_meal_card(meal: Dictionary, wallet: int, has_carton: bool, has_fridge: bool) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.16, 0.22, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.25, 0.38, 0.52, 0.7)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 14.0
	style.content_margin_top = 10.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override(&"panel", style)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override(&"separation", 12)
	panel.add_child(hbox)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override(&"separation", 3)
	hbox.add_child(vbox)

	var name_lbl: Label = Label.new()
	name_lbl.text = String(meal.get("name", "Meal"))
	name_lbl.add_theme_font_size_override(&"font_size", 14)
	name_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.4))
	vbox.add_child(name_lbl)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = String(meal.get("desc", ""))
	desc_lbl.add_theme_font_size_override(&"font_size", 11)
	desc_lbl.add_theme_color_override(&"font_color", Color(0.8, 0.85, 0.9))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	var stats_lbl: Label = Label.new()
	stats_lbl.text = "+%d%% Hunger  •  +%d%% Energy  •  %dm prep" % [
		int(meal.get("hunger", 30)),
		int(meal.get("energy", 15)),
		int(meal.get("time_mins", 10))
	]
	stats_lbl.add_theme_font_size_override(&"font_size", 11)
	stats_lbl.add_theme_color_override(&"font_color", Color(0.35, 0.95, 0.55))
	vbox.add_child(stats_lbl)

	# Calculate actual cost
	var cost: int = int(meal.get("base_cost", 0))
	var is_free: bool = false
	if meal.get("uses_carton", false) and has_carton:
		cost = 0
		is_free = true
	elif meal.get("requires_fridge", false):
		cost = 0
		is_free = true

	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(110, 44)
	btn.add_theme_font_size_override(&"font_size", 13)

	if meal.get("requires_fridge", false) and not has_fridge:
		btn.text = "Needs Fridge"
		btn.disabled = true
	elif is_free:
		btn.text = "Prepare (Free)"
		btn.pressed.connect(_on_cook_meal.bind(meal, 0))
	elif wallet >= cost:
		btn.text = "Cook (₦%d)" % cost
		btn.pressed.connect(_on_cook_meal.bind(meal, cost))
	else:
		btn.text = "₦%d (Broke)" % cost
		btn.disabled = true

	hbox.add_child(btn)
	return panel


func _on_cook_meal(meal: Dictionary, cost: int) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if cost > 0:
		if not needs.modify_money(-cost):
			return
		if SoundManager: SoundManager.play_coin()
	else:
		if SoundManager: SoundManager.play_click()

	var hunger_boost: float = float(meal.get("hunger", 35.0))
	var energy_boost: float = float(meal.get("energy", 20.0))
	var mins: int = int(meal.get("time_mins", 10))

	needs.modify_hunger(hunger_boost)
	needs.modify_energy(energy_boost)
	TimeSystem.advance_minutes(mins)

	if current_player.has_method("play_cooking_animation"):
		current_player.play_cooking_animation()
	elif current_player.has_method("play_eating_animation"):
		current_player.play_eating_animation()

	var meal_title: String = String(meal.get("name", "Meal"))
	PropBuilder3D.advance_quest_if_matching(12, current_player)
	if current_player.has_method("display_notification"):
		current_player.display_notification("Enjoyed %s! Hunger +%d%%, Energy +%d%%" % [
			meal_title,
			int(hunger_boost),
			int(energy_boost)
		])

	_refresh_ui()
	meal_cooked.emit(meal_title, hunger_boost, energy_boost)


func close_dialog() -> void:
	visible = false
	current_player = null
	dialog_closed.emit()


func _format_number(val: int) -> String:
	var s: String = str(val)
	var result: String = ""
	var count: int = 0
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		count += 1
		if count % 3 == 0 and i > 0:
			result = "," + result
	return result


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close_dialog()

