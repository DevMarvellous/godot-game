class_name BackpackMenu
extends Control

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")
const ProfileStore = preload("res://scripts/data/student_profile.gd")

## Student Backpack & Supplies Inventory Menu.
## Shows all carried items (food, supplies, tools).
## Player can eat stored food on-the-go or discard items to free up space.

signal menu_closed

@onready var items_container: VBoxContainer = %ItemsContainer
@onready var close_button: Button = %CloseButton
@onready var empty_label: Label = %EmptyLabel
@onready var title_label: Label = %TitleLabel

var current_player: CharacterBody3D = null


func _ready() -> void:
	visible = false
	if close_button:
		close_button.pressed.connect(close_menu)


func open_menu(player: CharacterBody3D) -> void:
	current_player = player
	ProfileStore.load_from_disk()
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
	for child: Node in items_container.get_children():
		child.queue_free()

	var items: Array[Dictionary] = ProfileStore.get_backpack_items()

	if title_label:
		title_label.text = "🎒 MY BACKPACK (%d item%s)" % [items.size(), "s" if items.size() != 1 else ""]

	if empty_label:
		empty_label.visible = items.is_empty()
		if items.is_empty():
			empty_label.text = "Your backpack is empty!\nBuy supplies from the Campus Mall or Provisions Kiosk."

	for item: Dictionary in items:
		var card: PanelContainer = _create_item_card(item)
		items_container.add_child(card)


func _create_item_card(item: Dictionary) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.22, 0.95)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override(&"panel", style)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override(&"separation", 14)
	panel.add_child(hbox)

	# Item info column
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var item_name: String = String(item.get("name", "Item"))
	var item_count: int = int(item.get("count", 1))
	var item_type: String = String(item.get("type", "misc"))
	var item_desc: String = String(item.get("desc", ""))

	var name_lbl: Label = Label.new()
	name_lbl.text = "%s (x%d)" % [item_name, item_count]
	name_lbl.add_theme_font_size_override(&"font_size", 15)
	name_lbl.add_theme_color_override(&"font_color", Color(1.0, 0.92, 0.45))
	vbox.add_child(name_lbl)

	var desc_lbl: Label = Label.new()
	if item_type == "food":
		desc_lbl.text = "%s  •  +%d Hunger, +%d Energy" % [item_desc, int(item.get("hunger", 0)), int(item.get("energy", 0))]
	else:
		desc_lbl.text = item_desc
	desc_lbl.add_theme_font_size_override(&"font_size", 12)
	desc_lbl.add_theme_color_override(&"font_color", Color(0.72, 0.78, 0.85))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_lbl)

	# Action buttons
	var btn_col: VBoxContainer = VBoxContainer.new()
	btn_col.add_theme_constant_override(&"separation", 4)
	hbox.add_child(btn_col)

	if item_type == "food":
		var eat_btn: Button = Button.new()
		eat_btn.text = "🍽️ Eat"
		eat_btn.custom_minimum_size = Vector2(90, 32)
		eat_btn.pressed.connect(_on_eat_pressed.bind(String(item.get("id", ""))))
		btn_col.add_child(eat_btn)

	var discard_btn: Button = Button.new()
	discard_btn.text = "🗑️ Drop"
	discard_btn.custom_minimum_size = Vector2(90, 32)
	discard_btn.pressed.connect(_on_discard_pressed.bind(String(item.get("id", "")), item_name))
	btn_col.add_child(discard_btn)

	return panel


func _on_eat_pressed(item_id: String) -> void:
	if not current_player:
		return

	var result: Dictionary = ProfileStore.consume_backpack_food(current_player, item_id)
	if result.get("success", false):
		if SoundManager:
			SoundManager.play_coin()
		if current_player.has_method("display_notification"):
			current_player.display_notification("Ate %s from backpack! +%d Hunger, +%d Energy" % [
				String(result.get("name", "food")),
				int(result.get("hunger", 0)),
				int(result.get("energy", 0))
			])
		TimeSystem.advance_minutes(5)
		_populate_items()
	else:
		if current_player.has_method("display_notification"):
			current_player.display_notification("That item is gone from your backpack!")
		_populate_items()


func _on_discard_pressed(item_id: String, item_name: String) -> void:
	ProfileStore.remove_backpack_item(item_id, 1)
	if SoundManager:
		SoundManager.play_click()
	if current_player and current_player.has_method("display_notification"):
		current_player.display_notification("Dropped 1x %s from backpack." % item_name)
	_populate_items()

