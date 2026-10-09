class_name SalonMenu
extends Control

## Interactive Haircut & Styling Menu for the Barbing Salon.
## Lets the player choose hairstyles, skin tones, shirts, and trousers.

signal salon_closed

const Customizer = preload("res://scripts/data/character_customizer.gd")

const CUT_FEE: int = 1000

var current_player: CharacterBody3D = null

var selected_hair_idx: int = 0
var selected_skin_idx: int = 1
var selected_shirt_idx: int = 0
var selected_trouser_idx: int = 0

@onready var wallet_label: Label = %WalletLabel
@onready var hair_options: OptionButton = %HairOptions
@onready var skin_options: OptionButton = %SkinOptions
@onready var shirt_options: OptionButton = %ShirtOptions
@onready var trouser_options: OptionButton = %TrouserOptions
@onready var confirm_btn: Button = %ConfirmBtn
@onready var close_btn: Button = %CloseBtn


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_menu)
	if confirm_btn:
		confirm_btn.pressed.connect(_on_confirm_pressed)

	_populate_dropdowns()


func _populate_dropdowns() -> void:
	if hair_options:
		hair_options.clear()
		for item in Customizer.HAIR_STYLES:
			hair_options.add_item(item["name"])

	if skin_options:
		skin_options.clear()
		for item in Customizer.SKIN_TONES:
			skin_options.add_item(item["name"])

	if shirt_options:
		shirt_options.clear()
		for item in Customizer.SHIRT_STYLES:
			shirt_options.add_item(item["name"])

	if trouser_options:
		trouser_options.clear()
		for item in Customizer.TROUSER_STYLES:
			trouser_options.add_item(item["name"])


func open_salon(player: CharacterBody3D) -> void:
	current_player = player
	visible = true

	var needs: NeedsManager = player.get_node_or_null("NeedsManager") as NeedsManager
	var money: int = needs.money if needs else 0
	if wallet_label:
		wallet_label.text = "Your Wallet: ₦%s  •  Haircut Fee: ₦%s" % [_format_number(money), _format_number(CUT_FEE)]

	if confirm_btn:
		confirm_btn.disabled = (money < CUT_FEE)
		confirm_btn.text = "CONFIRM NEW LOOK (₦1,000)" if money >= CUT_FEE else "INSUFFICIENT FUNDS (SAPA)"


func close_menu() -> void:
	visible = false
	current_player = null
	salon_closed.emit()


func _on_confirm_pressed() -> void:
	if not current_player:
		return

	var needs: NeedsManager = current_player.get_node_or_null("NeedsManager") as NeedsManager
	if not needs or needs.money < CUT_FEE:
		if SoundManager:
			SoundManager.play_alert()
		return

	needs.modify_money(-CUT_FEE)
	TimeSystem.advance_minutes(25)

	# Get chosen indices
	selected_hair_idx = hair_options.selected if hair_options else 0
	selected_skin_idx = skin_options.selected if skin_options else 1
	selected_shirt_idx = shirt_options.selected if shirt_options else 0
	selected_trouser_idx = trouser_options.selected if trouser_options else 0

	var hair_col: Color = Customizer.HAIR_STYLES[selected_hair_idx].color
	var skin_col: Color = Customizer.SKIN_TONES[selected_skin_idx].color
	var shirt_col: Color = Customizer.SHIRT_STYLES[selected_shirt_idx].color
	var trouser_col: Color = Customizer.TROUSER_STYLES[selected_trouser_idx].color

	if current_player.has_method("apply_appearance"):
		current_player.apply_appearance(skin_col, shirt_col, trouser_col, hair_col)

	if SoundManager:
		SoundManager.play_coin()

	if current_player.has_method("display_notification"):
		current_player.display_notification("Looking fresh! Paid Master Sunday ₦1,000.")

	close_menu()


func _format_number(n: int) -> String:
	var s: String = str(n)
	var idx: int = s.length() - 3
	while idx > 0:
		s = s.insert(idx, ",")
		idx -= 3
	return s
