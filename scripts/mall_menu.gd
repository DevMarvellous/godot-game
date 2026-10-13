class_name MallMenu
extends Control

## Interactive Campus Mall & Boutique Controller (Madam Kikelomo Boutique).
## Allows students to purchase outfits, hairstyles, gadgets, and provisions with Naira.
## Syncs with NeedsManager and StudentProfile.

signal mall_closed

@onready var title_label: Label = %TitleLabel if has_node("%TitleLabel") else null
@onready var wallet_label: Label = %WalletLabel if has_node("%WalletLabel") else null
@onready var banter_label: Label = %BanterLabel if has_node("%BanterLabel") else null
@onready var category_tab: OptionButton = %CategoryTab if has_node("%CategoryTab") else null
@onready var items_container: VBoxContainer = %ItemsContainer if has_node("%ItemsContainer") else null
@onready var close_btn: Button = %CloseBtn if has_node("%CloseBtn") else null

var current_player: CharacterBody3D = null
var current_category: int = 0 # 0: Outfits, 1: Hairstyles, 2: Gadgets & Provisions

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")
const Wardrobe = preload("res://scripts/data/wardrobe_data.gd")
const MallData = preload("res://scripts/data/mall_items_data.gd")
const ProfileStore = preload("res://scripts/data/student_profile.gd")

const MADAM_KIKELOMO_BANTER: Array[String] = [
	"\"Welcome my dear! Only top quality items straight from Balogun Market!\"",
	"\"Look sharp for your lectures o! A well-dressed student passes exams easily!\"",
	"\"Don't let blackouts catch you unprepared, get your heavy duty power bank!\"",
	"\"Indomie carton is moving fast, hostel boys buy 5 cartons every weekend!\"",
	"\"Ankara print and Senator native will make lecturers respect your presentation!\""
]


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_mall)

	if category_tab:
		category_tab.clear()
		category_tab.add_item("👗 Outfits & Native Wear")
		category_tab.add_item("💈 Hairstyles & Caps")
		category_tab.add_item("📦 Gadgets & Provisions")
		category_tab.item_selected.connect(_on_category_changed)

	_refresh_banter()


func open_mall(player: CharacterBody3D) -> void:
	current_player = player
	visible = true
	_refresh_banter()
	_update_wallet_display()
	_populate_items()


func close_mall() -> void:
	visible = false
	mall_closed.emit()


func _on_category_changed(idx: int) -> void:
	current_category = idx
	SoundManager.play_click()
	_populate_items()


func _refresh_banter() -> void:
	if banter_label:
		banter_label.text = MADAM_KIKELOMO_BANTER[randi() % MADAM_KIKELOMO_BANTER.size()]


func _update_wallet_display() -> void:
	var balance: int = 0
	if current_player:
		var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
		if needs:
			balance = needs.money
	if wallet_label:
		wallet_label.text = "💰 Student Wallet: ₦%s" % _format_number(balance)


func _populate_items() -> void:
	if not items_container:
		return

	for child in items_container.get_children():
		child.queue_free()

	ProfileStore.load_from_disk()

	var needs: NeedsManager = null
	if current_player:
		needs = current_player.get_node_or_null("NeedsManager") as NeedsManager

	var player_money: int = needs.money if needs else 0

	match current_category:
		0:
			# Outfits
			for i in range(Wardrobe.OUTFITS.size()):
				var item: Dictionary = Wardrobe.OUTFITS[i]
				var price: int = int(item.get("price", 0))
				var is_equipped: bool = (ProfileStore.shirt_index == i)
				_create_item_card(item["name"], price, item.get("description", ""), "👕", is_equipped, func():
					_buy_or_equip_outfit(i, price)
				)

		1:
			# Hairstyles
			for i in range(Wardrobe.HAIRSTYLES.size()):
				var item: Dictionary = Wardrobe.HAIRSTYLES[i]
				var price: int = int(item.get("price", 0))
				var is_equipped: bool = (ProfileStore.hair_index == i)
				_create_item_card(item["name"], price, item.get("description", ""), "💈", is_equipped, func():
					_buy_or_equip_hair(i, price)
				)

		2:
			# Gadgets & Provisions
			for item in MallData.ITEMS:
				var price: int = int(item.get("price", 0))
				var item_id: String = String(item.get("id", ""))
				_create_item_card(item["name"], price, item.get("description", ""), item.get("icon", "📦"), false, func():
					_buy_gadget(item)
				)


func _create_item_card(item_name: String, price: int, desc: String, icon: String, is_equipped: bool, buy_cb: Callable) -> void:
	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.18, 0.24, 0.95)
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

	# Icon
	var icon_label: Label = Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override(&"font_size", 28)
	hbox.add_child(icon_label)

	# Info
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label: Label = Label.new()
	name_label.text = item_name
	name_label.add_theme_font_size_override(&"font_size", 16)
	vbox.add_child(name_label)

	var desc_label: Label = Label.new()
	desc_label.text = desc
	desc_label.modulate = Color(0.75, 0.8, 0.85, 0.85)
	desc_label.add_theme_font_size_override(&"font_size", 12)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	hbox.add_child(vbox)

	# Action Button
	var action_btn: Button = Button.new()
	action_btn.custom_minimum_size = Vector2(130, 42)

	if is_equipped:
		action_btn.text = "✓ EQUIPPED"
		action_btn.disabled = true
	elif price == 0:
		action_btn.text = "Equip (Free)"
		action_btn.pressed.connect(buy_cb)
	else:
		action_btn.text = "Buy ₦%s" % _format_number(price)
		action_btn.pressed.connect(buy_cb)

	hbox.add_child(action_btn)
	panel.add_child(hbox)
	items_container.add_child(panel)


func _buy_or_equip_outfit(outfit_idx: int, price: int) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if price > 0 and needs.money < price:
		_show_sapa_notice(price - needs.money)
		return

	if price > 0:
		needs.modify_money(-price)
		_update_wallet_display()

	ProfileStore.shirt_index = outfit_idx
	ProfileStore.save_to_disk()

	var outfit_item: Dictionary = Wardrobe.OUTFITS[outfit_idx]
	if current_player.has_method("apply_appearance"):
		var skin_col = Wardrobe.COMPLEXIONS[clampi(ProfileStore.complexion_index, 0, Wardrobe.COMPLEXIONS.size() - 1)].color
		var hair_item = Wardrobe.HAIRSTYLES[clampi(ProfileStore.hair_index, 0, Wardrobe.HAIRSTYLES.size() - 1)]
		current_player.apply_appearance(
			skin_col,
			outfit_item.get("top_color", Color.WHITE),
			outfit_item.get("bottom_color", Color.BLACK),
			hair_item.get("default_color", Color.BLACK),
			hair_item.get("mesh_type", "low_cut"),
			outfit_item.get("mesh_type", "casual")
		)

	SoundManager.play_coin()
	_notify_player("Bought & equipped %s! Madam Kikelomo says: Looking sharp!" % outfit_item["name"])
	_populate_items()


func _buy_or_equip_hair(hair_idx: int, price: int) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	if price > 0 and needs.money < price:
		_show_sapa_notice(price - needs.money)
		return

	if price > 0:
		needs.modify_money(-price)
		_update_wallet_display()

	ProfileStore.hair_index = hair_idx
	ProfileStore.save_to_disk()

	var hair_item: Dictionary = Wardrobe.HAIRSTYLES[hair_idx]
	if current_player.has_method("apply_appearance"):
		var skin_col = Wardrobe.COMPLEXIONS[clampi(ProfileStore.complexion_index, 0, Wardrobe.COMPLEXIONS.size() - 1)].color
		var outfit_item = Wardrobe.OUTFITS[clampi(ProfileStore.shirt_index, 0, Wardrobe.OUTFITS.size() - 1)]
		current_player.apply_appearance(
			skin_col,
			outfit_item.get("top_color", Color.WHITE),
			outfit_item.get("bottom_color", Color.BLACK),
			hair_item.get("default_color", Color.BLACK),
			hair_item.get("mesh_type", "low_cut"),
			outfit_item.get("mesh_type", "casual")
		)

	SoundManager.play_coin()
	_notify_player("Styled %s! You're ready for campus!" % hair_item["name"])
	_populate_items()


func _buy_gadget(item: Dictionary) -> void:
	if not current_player:
		return
	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs:
		return

	var price: int = int(item.get("price", 0))
	if needs.money < price:
		_show_sapa_notice(price - needs.money)
		return

	needs.modify_money(-price)
	_update_wallet_display()

	# Give benefit
	var item_id: String = String(item.get("id", ""))
	if item_id == "power_bank":
		needs.modify_energy(30.0)
	elif item_id == "indomie_carton":
		needs.modify_hunger(45.0)
	elif item_id == "calc_fx991":
		needs.modify_cgpa(0.15)
	elif item_id == "perfume_oil":
		needs.modify_faith(10.0)

	SoundManager.play_coin()
	_notify_player("Purchased %s! %s" % [item["name"], item.get("description", "")])


func _show_sapa_notice(needed_amount: int) -> void:
	SoundManager.play_alert()
	_notify_player("Sapa is real! You need ₦%s more. Request Urgent 2k on your phone!" % _format_number(needed_amount))


func _notify_player(msg: String) -> void:
	if current_player and current_player.has_method("display_notification"):
		current_player.display_notification(msg)


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s
