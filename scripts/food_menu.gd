class_name FoodMenu
extends Control

## Interactive Nigerian Cafeteria / Buka Food Menu.
## Fully editable: You can add, remove, or modify dishes below in the inspector or in code.

signal meal_purchased(item_name: String, cost: int, hunger_boost: float, energy_boost: float)
signal menu_closed

## --- EDITABLE FOOD CATALOG ---
## To add a new meal, simply add a new Dictionary entry to this array.
@export var menu_items: Array[Dictionary] = [
	{
		"name": "Jollof Rice & Fried Chicken",
		"desc": "Smoky party jollof with spicy drumstick.",
		"cost": 1200,
		"hunger": 65.0,
		"energy": 15.0,
		"time_minutes": 20
	},
	{
		"name": "Indomie & 2 Fried Eggs",
		"desc": "Classic student late-night survival meal.",
		"cost": 650,
		"hunger": 40.0,
		"energy": 8.0,
		"time_minutes": 15
	},
	{
		"name": "Pounded Yam & Egusi Soup",
		"desc": "Heavy local delicacy. Leaves you very full.",
		"cost": 1500,
		"hunger": 85.0,
		"energy": 5.0,
		"time_minutes": 25
	},
	{
		"name": "Hot Meat Pie & Chilled Drink",
		"desc": "Quick snack between 9am and 2pm lectures.",
		"cost": 450,
		"hunger": 25.0,
		"energy": 5.0,
		"time_minutes": 10
	},
	{
		"name": "Pure Water & Cabin Biscuit",
		"desc": "The legendary 'Sapa Special' emergency kit.",
		"cost": 100,
		"hunger": 10.0,
		"energy": 2.0,
		"time_minutes": 5
	}
]

@onready var items_container: VBoxContainer = %ItemsContainer
@onready var wallet_label: Label = %WalletLabel
@onready var close_button: Button = %CloseButton

var current_player: CharacterBody3D = null


func _ready() -> void:
	visible = false
	if close_button:
		close_button.pressed.connect(close_menu)


func open_menu(player: CharacterBody3D) -> void:
	current_player = player
	visible = true
	_populate_items()


func close_menu() -> void:
	visible = false
	current_player = null
	menu_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func _populate_items() -> void:
	# Clear previous generated rows
	for child: Node in items_container.get_children():
		child.queue_free()

	if not current_player:
		return

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	var player_money: int = needs.money if needs else 0

	if wallet_label:
		wallet_label.text = "Your Wallet: ₦%s" % _format_number(player_money)

	for item: Dictionary in menu_items:
		var card: PanelContainer = _create_food_card(item, player_money)
		items_container.add_child(card)


func _create_food_card(item: Dictionary, player_money: int) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.17, 0.22, 0.95)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override(&"panel", style)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override(&"separation", 12)
	panel.add_child(hbox)

	# Info column (Name, description, stats)
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var title_lbl: Label = Label.new()
	title_lbl.text = String(item["name"])
	title_lbl.add_theme_font_size_override(&"font_size", 15)
	title_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.9, 0.4))
	vbox.add_child(title_lbl)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = "%s  •  (+%d Hunger, +%d Energy)" % [String(item["desc"]), int(item["hunger"]), int(item["energy"])]
	desc_lbl.add_theme_font_size_override(&"font_size", 12)
	desc_lbl.add_theme_color_override(&"font_color", Color(0.75, 0.8, 0.85))
	vbox.add_child(desc_lbl)

	# Price and Buy button
	var btn: Button = Button.new()
	var cost: int = int(item["cost"])
	btn.text = "Buy ₦%s" % _format_number(cost)
	btn.custom_minimum_size = Vector2(110, 36)

	if player_money < cost:
		btn.disabled = true
		btn.text = "₦%s (No Sapa)" % _format_number(cost)
	else:
		btn.pressed.connect(_on_buy_pressed.bind(item))

	hbox.add_child(btn)
	return panel


func _on_buy_pressed(item: Dictionary) -> void:
	if not current_player:
		return

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var cost: int = int(item["cost"])
	if needs.modify_money(-cost):
		needs.modify_hunger(float(item["hunger"]))
		needs.modify_energy(float(item["energy"]))
		TimeSystem.advance_minutes(int(item["time_minutes"]))

		if current_player.has_method("display_notification"):
			current_player.display_notification("Bought %s! Paid ₦%s" % [String(item["name"]), _format_number(cost)])

		# Refresh wallet & available dishes
		_populate_items()
		meal_purchased.emit(String(item["name"]), cost, float(item["hunger"]), float(item["energy"]))


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s
