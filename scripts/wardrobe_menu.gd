class_name WardrobeMenu
extends Control

## Interactive Wardrobe & Fitting Room Controller.
## Lets students try on and equip hairstyles, native wears, hoodies, and gowns.
## Displays live 3D preview and saves equipped appearance directly to disk.

signal wardrobe_closed

@onready var hair_options: OptionButton = %HairOptions if has_node("%HairOptions") else null
@onready var outfit_options: OptionButton = %OutfitOptions if has_node("%OutfitOptions") else null
@onready var skin_options: OptionButton = %SkinOptions if has_node("%SkinOptions") else null
@onready var desc_label: Label = %ItemDescLabel if has_node("%ItemDescLabel") else null
@onready var equip_btn: Button = %EquipBtn if has_node("%EquipBtn") else null
@onready var close_btn: Button = %CloseBtn if has_node("%CloseBtn") else null

var current_player: CharacterBody3D = null
var selected_hair_idx: int = 0
var selected_outfit_idx: int = 0
var selected_skin_idx: int = 1

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")
const Wardrobe = preload("res://scripts/data/wardrobe_data.gd")
const ProfileStore = preload("res://scripts/data/student_profile.gd")


func _ready() -> void:
	visible = false
	if equip_btn:
		equip_btn.pressed.connect(_on_equip_pressed)
	if close_btn:
		close_btn.pressed.connect(close_wardrobe)

	_populate_selectors()


func _populate_selectors() -> void:
	if hair_options:
		hair_options.clear()
		for h in Wardrobe.HAIRSTYLES:
			hair_options.add_item(h["name"])
		hair_options.item_selected.connect(func(idx: int):
			selected_hair_idx = idx
			_update_preview()
		)

	if outfit_options:
		outfit_options.clear()
		for o in Wardrobe.OUTFITS:
			outfit_options.add_item(o["name"])
		outfit_options.item_selected.connect(func(idx: int):
			selected_outfit_idx = idx
			_update_preview()
		)

	if skin_options:
		skin_options.clear()
		for s in Wardrobe.COMPLEXIONS:
			skin_options.add_item(s["name"])
		skin_options.item_selected.connect(func(idx: int):
			selected_skin_idx = idx
			_update_preview()
		)


func open_wardrobe(player: CharacterBody3D) -> void:
	current_player = player
	ProfileStore.load_from_disk()

	selected_skin_idx = clampi(ProfileStore.complexion_index, 0, Wardrobe.COMPLEXIONS.size() - 1)
	selected_hair_idx = clampi(ProfileStore.hair_index, 0, Wardrobe.HAIRSTYLES.size() - 1)
	selected_outfit_idx = clampi(ProfileStore.shirt_index, 0, Wardrobe.OUTFITS.size() - 1)

	if skin_options:
		skin_options.select(selected_skin_idx)
	if hair_options:
		hair_options.select(selected_hair_idx)
	if outfit_options:
		outfit_options.select(selected_outfit_idx)

	visible = true
	_update_preview()


func close_wardrobe() -> void:
	visible = false
	wardrobe_closed.emit()


func _update_preview() -> void:
	var h: Dictionary = Wardrobe.HAIRSTYLES[selected_hair_idx]
	var o: Dictionary = Wardrobe.OUTFITS[selected_outfit_idx]
	var s: Dictionary = Wardrobe.COMPLEXIONS[selected_skin_idx]

	if desc_label:
		desc_label.text = "HAIRSTYLE: %s\n%s\n\nOUTFIT: %s\n%s" % [
			h["name"], h["description"],
			o["name"], o["description"]
		]

	if current_player and current_player.has_method("apply_appearance"):
		var top_col: Color = o.get("top_color", Color(0.12, 0.55, 0.32))
		var btm_col: Color = o.get("bottom_color", Color(0.15, 0.22, 0.32))
		var hair_col: Color = h.get("default_color", Color(0.08, 0.08, 0.08))
		current_player.apply_appearance(
			s["color"],
			top_col,
			btm_col,
			hair_col,
			h.get("mesh_type", "low_cut"),
			o.get("mesh_type", "casual")
		)


func _on_equip_pressed() -> void:
	ProfileStore.complexion_index = selected_skin_idx
	ProfileStore.hair_index = selected_hair_idx
	ProfileStore.shirt_index = selected_outfit_idx
	ProfileStore.save_to_disk()

	if SoundManager:
		SoundManager.play_bell()

	if current_player and current_player.has_method("display_notification"):
		current_player.display_notification("Equipped new campus outfit! Looking sharp ✨")

	close_wardrobe()

