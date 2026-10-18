class_name FridgeDialog
extends Control

## Interactive Hostel Mini-Fridge Food & Beverage Storage System.
## Lets students store, chill, and retrieve takeaway food and drinks to replenish needs.

signal fridge_closed

var current_player: CharacterBody3D = null

# Persistent fridge inventory (saved to disk or maintained in session)
static var stored_items: Dictionary = {
	"chilled_water": 3,
	"cold_malt": 2,
	"takeaway_jollof": 1,
	"suya_pack": 1,
	"chilled_zobo": 2
}

const ITEM_DEFS: Dictionary = {
	"chilled_water": {
		"name": "Chilled Swan Spring Water",
		"icon": "💧",
		"desc": "Crisp cold bottle water from the dorm mini-fridge.",
		"hunger": 5.0,
		"energy": 20.0,
		"restock_cost": 150
	},
	"cold_malt": {
		"name": "Ice-Cold Malta Drink",
		"icon": "🥤",
		"desc": "Rich nutritious malt with condensation on the can.",
		"hunger": 20.0,
		"energy": 30.0,
		"restock_cost": 450
	},
	"takeaway_jollof": {
		"name": "Leftover Mama Put Jollof & Chicken",
		"icon": "🍲",
		"desc": "Delicious seasoned campus party jollof in takeaway pack.",
		"hunger": 60.0,
		"energy": 25.0,
		"restock_cost": 1200
	},
	"suya_pack": {
		"name": "Cold Beef Suya & Roasted Onions",
		"icon": "🥩",
		"desc": "Spicy peppered beef slices wrapped in campus newspaper.",
		"hunger": 45.0,
		"energy": 20.0,
		"restock_cost": 800
	},
	"chilled_zobo": {
		"name": "Chilled Hibiscus Zobo with Ginger",
		"icon": "🧃",
		"desc": "Homemade sweet spicy chilled campus zobo.",
		"hunger": 15.0,
		"energy": 25.0,
		"restock_cost": 300
	}
}

@onready var items_container: VBoxContainer = %ItemsContainer
@onready var close_btn: Button = %CloseBtn
@onready var restock_all_btn: Button = %RestockAllBtn
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_fridge)
	if restock_all_btn:
		restock_all_btn.pressed.connect(_on_restock_all_pressed)


func open_fridge(p: CharacterBody3D) -> void:
	current_player = p
	visible = true
	_refresh_items_list()
	if status_label:
		status_label.text = "🧊 Mini-Fridge Temperature: 4°C • Compressor Hum Running smoothly"


func close_fridge() -> void:
	visible = false
	current_player = null
	fridge_closed.emit()


func _refresh_items_list() -> void:
	if not items_container:
		return

	for child in items_container.get_children():
		child.queue_free()

	for item_key in ITEM_DEFS.keys():
		var def: Dictionary = ITEM_DEFS[item_key]
		var count: int = stored_items.get(item_key, 0)

		var card = PanelContainer.new()
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.12, 0.16, 0.22, 0.95)
		card_style.set_corner_radius_all(8)
		card_style.content_margin_left = 12
		card_style.content_margin_top = 8
		card_style.content_margin_right = 12
		card_style.content_margin_bottom = 8
		card.add_theme_stylebox_override(&"panel", card_style)

		var hbox = HBoxContainer.new()
		hbox.theme_override_constants/separation = 12

		var icon_lbl = Label.new()
		icon_lbl.text = def.get("icon", "🍱")
		icon_lbl.add_theme_font_size_override(&"font_size", 28)
		hbox.add_child(icon_lbl)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var title_lbl = Label.new()
		title_lbl.text = "%s (Qty: %d)" % [def.get("name"), count]
		title_lbl.add_theme_font_size_override(&"font_size", 15)
		info_vbox.add_child(title_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = "%s [Hunger +%d | Energy +%d]" % [def.get("desc"), int(def.get("hunger")), int(def.get("energy"))]
		desc_lbl.add_theme_font_size_override(&"font_size", 12)
		desc_lbl.add_theme_color_override(&"font_color", Color(0.7, 0.82, 0.92, 1))
		info_vbox.add_child(desc_lbl)

		hbox.add_child(info_vbox)

		# Action buttons
		var btn_vbox = VBoxContainer.new()
		btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		var eat_btn = Button.new()
		eat_btn.text = "Eat / Drink 🍽️"
		eat_btn.custom_minimum_size = Vector2(110, 34)
		eat_btn.disabled = (count <= 0)
		eat_btn.pressed.connect(_on_consume_item.bind(item_key))
		btn_vbox.add_child(eat_btn)

		var restock_btn = Button.new()
		restock_btn.text = "+ Restock (₦%d)" % int(def.get("restock_cost", 200))
		restock_btn.custom_minimum_size = Vector2(110, 28)
		restock_btn.add_theme_font_size_override(&"font_size", 11)
		restock_btn.pressed.connect(_on_restock_single_item.bind(item_key))
		btn_vbox.add_child(restock_btn)

		hbox.add_child(btn_vbox)
		card.add_child(hbox)
		items_container.add_child(card)


func _on_consume_item(item_key: String) -> void:
	if not current_player:
		return
	var count: int = stored_items.get(item_key, 0)
	if count <= 0:
		return

	var def: Dictionary = ITEM_DEFS[item_key]
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	stored_items[item_key] = count - 1
	needs.modify_hunger(float(def.get("hunger", 20.0)))
	needs.modify_energy(float(def.get("energy", 15.0)))
	TimeSystem.advance_minutes(10)

	SoundManager.play_click()

	if current_player.has_method("display_notification"):
		current_player.display_notification("Consumed %s from mini-fridge! (+%d Hunger, +%d Energy)" % [
			def.get("name"), int(def.get("hunger")), int(def.get("energy"))
		])

	if status_label:
		status_label.text = "😋 Finished %s! Chilled and refreshing." % def.get("name")

	_refresh_items_list()


func _on_restock_single_item(item_key: String) -> void:
	if not current_player:
		return
	var def: Dictionary = ITEM_DEFS[item_key]
	var cost: int = int(def.get("restock_cost", 200))

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if not needs.modify_money(-cost):
		if status_label:
			status_label.text = "⚠️ You do not have ₦%d to restock %s!" % [cost, def.get("name")]
		SoundManager.play_alert()
		return

	stored_items[item_key] = stored_items.get(item_key, 0) + 1
	SoundManager.play_coin()

	if status_label:
		status_label.text = "✅ Restocked %s (+1) into mini-fridge (-₦%d)" % [def.get("name"), cost]

	_refresh_items_list()


func _on_restock_all_pressed() -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var total_cost: int = 1500
	if not needs.modify_money(-total_cost):
		if status_label:
			status_label.text = "⚠️ Full fridge restocking bundle requires ₦%d!" % total_cost
		SoundManager.play_alert()
		return

	for key in stored_items.keys():
		stored_items[key] = stored_items.get(key, 0) + 1

	SoundManager.play_coin()
	if status_label:
		status_label.text = "🎉 Full Mini-Fridge Bundle Restocked! (+1 of all items, -₦%d)" % total_cost

	_refresh_items_list()

