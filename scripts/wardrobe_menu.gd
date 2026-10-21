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

const Wardrobe = preload("res://scripts/data/wardrobe_data.gd")
const ProfileStore = preload("res://scripts/data/student_profile.gd")
const PlayerScene = preload("res://scenes/player_3d.tscn")

var mirror_player: Player3D = null


func _ready() -> void:
	visible = false
	if equip_btn:
		equip_btn.pressed.connect(_on_equip_pressed)
	if close_btn:
		close_btn.pressed.connect(close_wardrobe)

	_build_3d_mirror_preview()
	_populate_selectors()


func _build_3d_mirror_preview() -> void:
	var vbox: VBoxContainer = get_node_or_null("CenterContainer/WardrobeFrame/VBox") as VBoxContainer
	if not vbox or vbox.has_node("MirrorCard"):
		return
	var card := PanelContainer.new()
	card.name = "MirrorCard"
	card.custom_minimum_size = Vector2(0, 155)
	var st := StyleBoxFlat.new()
	st.bg_color = Color(0.14, 0.22, 0.32, 1.0)
	st.border_width_left = 2
	st.border_width_top = 2
	st.border_width_right = 2
	st.border_width_bottom = 2
	st.border_color = Color(1.0, 0.82, 0.28, 0.9)
	st.corner_radius_top_left = 12
	st.corner_radius_top_right = 12
	st.corner_radius_bottom_left = 12
	st.corner_radius_bottom_right = 12
	card.add_theme_stylebox_override(&"panel", st)

	var svc := SubViewportContainer.new()
	svc.custom_minimum_size = Vector2(0, 150)
	svc.stretch = true
	card.add_child(svc)

	var vp := SubViewport.new()
	vp.own_world_3d = true
	vp.transparent_bg = true
	vp.size = Vector2i(320, 150)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	svc.add_child(vp)

	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.02, 2.35)
	cam.rotation_degrees = Vector3(-8, 0, 0)
	cam.fov = 44.0
	cam.current = true
	vp.add_child(cam)

	var dlight := DirectionalLight3D.new()
	dlight.position = Vector3(2, 4, 3)
	dlight.rotation_degrees = Vector3(-30, 30, 0)
	dlight.light_energy = 1.65
	vp.add_child(dlight)

	mirror_player = PlayerScene.instantiate() as Player3D
	mirror_player.set_physics_process(false)
	mirror_player.set_process_unhandled_input(false)
	vp.add_child(mirror_player)
	for child_name in ["Camera3D", "CollisionShape3D", "NotifLabel", "PromptLabel"]:
		var n = mirror_player.get_node_or_null(child_name)
		if n:
			n.queue_free()

	vbox.add_child(card)
	vbox.move_child(card, 2)


func _process(delta: float) -> void:
	if visible and is_instance_valid(mirror_player) and mirror_player.visual_root:
		mirror_player.visual_root.rotate_y(delta * 0.9)


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


func _update_preview(animate_spin: bool = true) -> void:
	var h: Dictionary = Wardrobe.HAIRSTYLES[selected_hair_idx]
	var o: Dictionary = Wardrobe.OUTFITS[selected_outfit_idx]
	var s: Dictionary = Wardrobe.COMPLEXIONS[selected_skin_idx]

	if desc_label:
		desc_label.text = "💈 %s — %s\n👕 %s — %s" % [
			h["name"], h["description"],
			o["name"], o["description"]
		]

	var top_col: Color = o.get("top_color", Color(0.12, 0.55, 0.32))
	var btm_col: Color = o.get("bottom_color", Color(0.15, 0.22, 0.32))
	var hair_col: Color = h.get("default_color", Color(0.08, 0.08, 0.08))

	for target_avatar in [mirror_player, current_player]:
		if is_instance_valid(target_avatar) and target_avatar.has_method("apply_appearance"):
			var avatar_ref: Player3D = target_avatar as Player3D
			var apply_fn := func():
				if is_instance_valid(avatar_ref):
					avatar_ref.apply_appearance(
						s["color"],
						top_col,
						btm_col,
						hair_col,
						h.get("mesh_type", "low_cut"),
						o.get("mesh_type", "casual")
					)
			if animate_spin and avatar_ref.has_method("play_dressing_animation"):
				avatar_ref.play_dressing_animation(apply_fn)
			else:
				apply_fn.call()


func _on_equip_pressed() -> void:
	ProfileStore.complexion_index = selected_skin_idx
	ProfileStore.hair_index = selected_hair_idx
	ProfileStore.shirt_index = selected_outfit_idx
	ProfileStore.save_to_disk()

	if current_player and current_player.has_method("play_dressing_animation"):
		current_player.play_dressing_animation()
	else:
		if SoundManager:
			SoundManager.play_bell()
		if current_player and current_player.has_method("display_notification"):
			current_player.display_notification("Equipped new campus outfit! Looking sharp ✨")

	close_wardrobe()

