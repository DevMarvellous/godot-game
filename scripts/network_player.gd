class_name NetworkPlayer
extends CharacterBody3D

## Network Puppet Avatar representing another online student in the room.
## Smoothly interpolates position & rotation to eliminate jitter over WebSockets.
## Displays student name, matric tag, and real-time 3D speech bubble for chat.

signal peer_interacted(puppet: NetworkPlayer, local_player: CharacterBody3D)

@export var student_name: String = "Coursemate"
@export var peer_id: int = 0

var target_position: Vector3 = Vector3.ZERO
var target_rotation_y: float = 0.0
var is_moving: bool = false
var walk_anim_time: float = 0.0

var is_sitting: bool = false
var is_emoting: bool = false
var _active_emote_tween: Tween = null

@onready var visual_root: Node3D = $Visuals
@onready var torso_mesh: MeshInstance3D = $Visuals/TorsoMesh
@onready var head_mesh: MeshInstance3D = $Visuals/HeadMesh
@onready var hair_mesh: MeshInstance3D = $Visuals/HairMesh
@onready var left_leg: MeshInstance3D = $Visuals/LeftLeg if has_node("Visuals/LeftLeg") else null
@onready var right_leg: MeshInstance3D = $Visuals/RightLeg if has_node("Visuals/RightLeg") else null
@onready var left_arm: MeshInstance3D = $Visuals/LeftArm
@onready var right_arm: MeshInstance3D = $Visuals/RightArm

@onready var name_label: Label3D = $NameLabel
@onready var chat_bubble: Label3D = $ChatBubble
@onready var chat_timer: Timer = $ChatTimer


func _ready() -> void:
	target_position = global_position
	if name_label:
		name_label.text = "%s\n🟢 [Online]" % student_name
	if chat_bubble:
		chat_bubble.visible = false
	if chat_timer:
		chat_timer.timeout.connect(_on_chat_timeout)
	_setup_peer_interactable()


func _setup_peer_interactable() -> void:
	var interact_area := Interactable3D.new()
	interact_area.name = "PeerInteractArea"
	interact_area.object_name = student_name
	interact_area.prompt_message = "[E] Link Up with %s" % student_name
	var col := CollisionShape3D.new()
	var sph := SphereShape3D.new()
	sph.radius = 1.15
	col.shape = sph
	col.position = Vector3(0, 1.0, 0)
	interact_area.add_child(col)
	interact_area.interacted.connect(func(p: CharacterBody3D):
		peer_interacted.emit(self, p)
	)
	add_child(interact_area)


func update_network_transform(new_pos: Vector3, new_rot_y: float, moving: bool) -> void:
	target_position = new_pos
	target_rotation_y = new_rot_y
	is_moving = moving
	if moving and (is_sitting or is_emoting):
		cancel_emote()
		is_sitting = false


func _process(delta: float) -> void:
	# Smoothly interpolate position and rotation
	global_position = global_position.lerp(target_position, clampf(14.0 * delta, 0.0, 1.0))
	if visual_root:
		visual_root.rotation.y = lerp_angle(visual_root.rotation.y, target_rotation_y, clampf(14.0 * delta, 0.0, 1.0))

	# Animate limb swinging when walking
	if is_moving:
		walk_anim_time += delta * 12.0
		if left_arm and right_arm:
			left_arm.rotation.x = sin(walk_anim_time) * 0.45
			right_arm.rotation.x = -sin(walk_anim_time) * 0.45
		if left_leg and right_leg:
			left_leg.rotation.x = -sin(walk_anim_time) * 0.48
			right_leg.rotation.x = sin(walk_anim_time) * 0.48
		if torso_mesh and head_mesh:
			var bob: float = abs(sin(walk_anim_time)) * 0.04
			torso_mesh.position.y = 0.95 + bob
			head_mesh.position.y = 1.45 + bob
	elif is_sitting:
		pass
	elif is_emoting:
		pass
	else:
		if left_arm and right_arm:
			left_arm.rotation.x = move_toward(left_arm.rotation.x, 0.0, 6.0 * delta)
			right_arm.rotation.x = move_toward(right_arm.rotation.x, 0.0, 6.0 * delta)
		if left_leg and right_leg:
			left_leg.rotation.x = move_toward(left_leg.rotation.x, 0.0, 7.0 * delta)
			right_leg.rotation.x = move_toward(right_leg.rotation.x, 0.0, 7.0 * delta)
		if torso_mesh and head_mesh:
			torso_mesh.position.y = move_toward(torso_mesh.position.y, 0.95, 0.4 * delta)
			head_mesh.position.y = move_toward(head_mesh.position.y, 1.45, 0.4 * delta)


func play_emote(emote_name: String) -> void:
	cancel_emote()
	match emote_name.to_lower():
		"shaku", "dance", "gbese":
			_play_puppet_shaku()
		"wave":
			_play_puppet_wave()
		"sit":
			_play_puppet_sit()
		"stand":
			_play_puppet_stand()
		"celebrate":
			_play_puppet_celebrate()
		"study":
			_play_puppet_study()
		"eat":
			_play_puppet_eat()
		"pray":
			_play_puppet_pray()
		_:
			_play_puppet_wave()


func cancel_emote() -> void:
	is_emoting = false
	if _active_emote_tween and _active_emote_tween.is_valid():
		_active_emote_tween.kill()
		_active_emote_tween = null
	if left_arm: left_arm.rotation = Vector3.ZERO
	if right_arm: right_arm.rotation = Vector3.ZERO
	if left_leg: left_leg.rotation = Vector3.ZERO
	if right_leg: right_leg.rotation = Vector3.ZERO
	if head_mesh:
		head_mesh.rotation = Vector3.ZERO
		head_mesh.position = Vector3(0, 1.45, 0)
	if torso_mesh:
		torso_mesh.rotation = Vector3.ZERO
		torso_mesh.position = Vector3(0, 0.95, 0)


func _play_puppet_wave() -> void:
	is_emoting = true
	var wave_tw: Tween = create_tween()
	_active_emote_tween = wave_tw
	wave_tw.tween_callback(func():
		if right_arm:
			right_arm.rotation.x = -2.4
			right_arm.rotation.z = 0.4
	)
	wave_tw.tween_interval(0.15)
	for i in range(3):
		wave_tw.tween_callback(func():
			if right_arm: right_arm.rotation.z = -0.2
		)
		wave_tw.tween_interval(0.12)
		wave_tw.tween_callback(func():
			if right_arm: right_arm.rotation.z = 0.4
		)
		wave_tw.tween_interval(0.12)
	wave_tw.tween_callback(func():
		cancel_emote()
	)


func _play_puppet_shaku() -> void:
	is_emoting = true
	var dance_tw: Tween = create_tween()
	_active_emote_tween = dance_tw
	for i in range(2):
		dance_tw.tween_callback(func():
			if left_leg: left_leg.rotation.x = -0.75
			if right_leg: right_leg.rotation.x = 0.35
			if right_arm: right_arm.rotation.x = -1.1
			if left_arm: left_arm.rotation.z = -0.6
			if torso_mesh:
				torso_mesh.rotation.y = 0.25
				torso_mesh.position.y = 1.05
		)
		dance_tw.tween_interval(0.18)
		dance_tw.tween_callback(func():
			if left_leg: left_leg.rotation.x = 0.35
			if right_leg: right_leg.rotation.x = -0.75
			if left_arm: left_arm.rotation.x = -1.1
			if right_arm: right_arm.rotation.z = 0.6
			if torso_mesh:
				torso_mesh.rotation.y = -0.25
				torso_mesh.position.y = 1.05
		)
		dance_tw.tween_interval(0.18)
	dance_tw.tween_callback(func():
		cancel_emote()
	)


func _play_puppet_sit() -> void:
	is_sitting = true
	is_emoting = false
	var sit_tw: Tween = create_tween().set_parallel(true)
	_active_emote_tween = sit_tw
	if torso_mesh:
		sit_tw.tween_property(torso_mesh, "position:y", 0.62, 0.25)
	if head_mesh:
		sit_tw.tween_property(head_mesh, "position:y", 1.12, 0.25)
	if left_leg and right_leg:
		sit_tw.tween_property(left_leg, "rotation:x", -PI * 0.45, 0.25)
		sit_tw.tween_property(right_leg, "rotation:x", -PI * 0.45, 0.25)
	if left_arm and right_arm:
		sit_tw.tween_property(left_arm, "rotation:x", -0.4, 0.25)
		sit_tw.tween_property(right_arm, "rotation:x", -0.4, 0.25)


func _play_puppet_stand() -> void:
	is_sitting = false
	cancel_emote()


func _play_puppet_celebrate() -> void:
	is_emoting = true
	var tw: Tween = create_tween().set_parallel(true)
	_active_emote_tween = tw
	if torso_mesh: tw.tween_property(torso_mesh, "position:y", 1.35, 0.25)
	if left_arm and right_arm:
		tw.tween_property(left_arm, "rotation:x", -2.4, 0.25)
		tw.tween_property(right_arm, "rotation:x", -2.4, 0.25)
	tw.chain().tween_interval(0.3)
	tw.chain().tween_callback(func():
		cancel_emote()
	)


func _play_puppet_study() -> void:
	is_emoting = true
	var tw: Tween = create_tween()
	_active_emote_tween = tw
	if torso_mesh: tw.tween_property(torso_mesh, "rotation:x", 0.2, 0.2)
	if right_arm:
		for i in range(3):
			tw.tween_property(right_arm, "rotation:x", -0.35, 0.12)
			tw.tween_property(right_arm, "rotation:x", -0.15, 0.12)
	tw.tween_callback(func():
		cancel_emote()
	)


func _play_puppet_eat() -> void:
	is_emoting = true
	var tw: Tween = create_tween()
	_active_emote_tween = tw
	if head_mesh:
		for i in range(3):
			tw.tween_property(head_mesh, "rotation:x", 0.2, 0.12)
			tw.tween_property(head_mesh, "rotation:x", -0.05, 0.12)
	tw.tween_callback(func():
		cancel_emote()
	)


func _play_puppet_pray() -> void:
	is_emoting = true
	var tw: Tween = create_tween().set_parallel(true)
	_active_emote_tween = tw
	if head_mesh: tw.tween_property(head_mesh, "rotation:x", 0.35, 0.25)
	if left_arm and right_arm:
		tw.tween_property(left_arm, "rotation:z", -0.3, 0.25)
		tw.tween_property(right_arm, "rotation:z", 0.3, 0.25)
	tw.chain().tween_interval(0.6)
	tw.chain().tween_callback(func():
		cancel_emote()
	)


func show_chat(msg: String) -> void:
	if chat_bubble:
		chat_bubble.text = "\"%s\"" % msg
		chat_bubble.visible = true
	if chat_timer:
		chat_timer.start(4.5)


func _on_chat_timeout() -> void:
	if chat_bubble:
		chat_bubble.visible = false


func apply_appearance(skin_col: Color, shirt_col: Color, trouser_col: Color, hair_col: Color) -> void:
	if head_mesh:
		var skin_mat = StandardMaterial3D.new()
		skin_mat.albedo_color = skin_col
		skin_mat.roughness = 0.7
		head_mesh.set_surface_override_material(0, skin_mat)
	if hair_mesh:
		var hair_mat = StandardMaterial3D.new()
		hair_mat.albedo_color = hair_col
		hair_mat.roughness = 0.85
		hair_mesh.set_surface_override_material(0, hair_mat)
	if torso_mesh:
		var shirt_mat = StandardMaterial3D.new()
		shirt_mat.albedo_color = shirt_col
		shirt_mat.roughness = 0.6
		torso_mesh.set_surface_override_material(0, shirt_mat)
		if left_arm: left_arm.set_surface_override_material(0, shirt_mat)
		if right_arm: right_arm.set_surface_override_material(0, shirt_mat)
	var leg_mat = StandardMaterial3D.new()
	leg_mat.albedo_color = trouser_col
	leg_mat.roughness = 0.75
	if left_leg:
		left_leg.set_surface_override_material(0, leg_mat)
	if right_leg:
		right_leg.set_surface_override_material(0, leg_mat)


## Applies full Male/Female 3D silhouette, hairstyle/cap mesh, melanin complexion, and clout title to a multiplayer puppet!
func apply_full_drip(gender_str: String, skin_idx: int, hair_idx: int, shirt_idx: int, trouser_idx: int, clout_rank: String = "") -> void:
	const WardrobeStore = preload("res://scripts/data/wardrobe_data.gd")
	var skin_item: Dictionary = WardrobeStore.COMPLEXIONS[clampi(skin_idx, 0, WardrobeStore.COMPLEXIONS.size() - 1)]
	var outfit_item: Dictionary = WardrobeStore.OUTFITS[clampi(shirt_idx, 0, WardrobeStore.OUTFITS.size() - 1)]
	var hair_item: Dictionary = WardrobeStore.HAIRSTYLES[clampi(hair_idx, 0, WardrobeStore.HAIRSTYLES.size() - 1)]
	var tr_item: Dictionary = CharacterCustomizer.TROUSER_STYLES[clampi(trouser_idx, 0, CharacterCustomizer.TROUSER_STYLES.size() - 1)]
	var skin_col: Color = skin_item.get("color", Color(0.35, 0.22, 0.14))
	var shirt_col: Color = outfit_item.get("top_color", Color(0.12, 0.55, 0.32))
	var trouser_col: Color = tr_item.get("color", outfit_item.get("bottom_color", Color(0.15, 0.22, 0.32)))
	var hair_col: Color = hair_item.get("default_color", Color(0.08, 0.08, 0.08))
	apply_appearance(skin_col, shirt_col, trouser_col, hair_col)

	if name_label:
		var rank_tag: String = (" • " + RoomManager.clean_godot_text(clout_rank)) if clout_rank != "" else ""
		name_label.text = "%s\n● [LIVE PLAYER%s]" % [student_name, rank_tag]
		name_label.modulate = Color(0.35, 1.0, 0.68)

	if not visual_root:
		return

	# Female vs Male 3D Silhouette (Skirt / Bust / Proportions)
	var is_female: bool = (gender_str.to_lower() == "female")
	var fem_skirt: MeshInstance3D = visual_root.get_node_or_null("FemaleSkirtMesh") as MeshInstance3D
	if not fem_skirt:
		fem_skirt = MeshInstance3D.new()
		fem_skirt.name = "FemaleSkirtMesh"
		var cyl := CylinderMesh.new()
		cyl.top_radius = 0.22
		cyl.bottom_radius = 0.35
		cyl.height = 0.44
		fem_skirt.mesh = cyl
		fem_skirt.position = Vector3(0, 0.56, 0)
		visual_root.add_child(fem_skirt)
	fem_skirt.visible = is_female and (trouser_idx != 0)
	if fem_skirt.visible:
		var sk_mat := StandardMaterial3D.new()
		sk_mat.albedo_color = shirt_col if shirt_idx == 2 else trouser_col
		sk_mat.roughness = 0.55
		fem_skirt.material_override = sk_mat

	if torso_mesh:
		torso_mesh.scale = Vector3(0.86, 0.96, 0.88) if is_female else Vector3(1.0, 1.0, 1.0)

	# 3D Hairstyle / Cap Mesh shape
	if hair_mesh:
		var h_mat := StandardMaterial3D.new()
		h_mat.albedo_color = hair_col
		h_mat.roughness = 0.8
		match hair_idx:
			0:
				var m0 := BoxMesh.new()
				m0.size = Vector3(0.37, 0.12, 0.37)
				hair_mesh.mesh = m0
				hair_mesh.position = Vector3(0, 1.63, 0)
			1:
				var m1 := BoxMesh.new()
				m1.size = Vector3(0.38, 0.28, 0.38)
				hair_mesh.mesh = m1
				hair_mesh.position = Vector3(0, 1.70, 0)
			2:
				var m2 := SphereMesh.new()
				m2.radius = 0.28
				m2.height = 0.52
				hair_mesh.mesh = m2
				hair_mesh.position = Vector3(0, 1.68, 0)
			3:
				var m3 := CylinderMesh.new()
				m3.top_radius = 0.18
				m3.bottom_radius = 0.21
				m3.height = 0.22
				hair_mesh.mesh = m3
				hair_mesh.position = Vector3(0, 1.70, 0)
			4:
				# 4. Royal Gele (Tiered Pleated Avant-Garde Headwrap)
				var m4 := BoxMesh.new()
				m4.size = Vector3(0.66, 0.24, 0.32)
				hair_mesh.mesh = m4
				hair_mesh.position = Vector3(0, 1.66, -0.02)
				h_mat.metallic = 0.35
				h_mat.roughness = 0.40
			5:
				# 5. Fulani Braids & Cornrows
				var m5 := BoxMesh.new()
				m5.size = Vector3(0.44, 0.18, 0.44)
				hair_mesh.mesh = m5
				hair_mesh.position = Vector3(0, 1.64, 0)
			6:
				# 6. Twin Afro Puffs
				var m6 := SphereMesh.new()
				m6.radius = 0.18
				m6.height = 0.30
				hair_mesh.mesh = m6
				hair_mesh.position = Vector3(0, 1.68, 0)
			7, _:
				# 7. Traditional Fila / Ozo Cap
				var m7 := CylinderMesh.new()
				m7.top_radius = 0.22
				m7.bottom_radius = 0.24
				m7.height = 0.22
				hair_mesh.mesh = m7
				hair_mesh.position = Vector3(0, 1.68, 0)
		hair_mesh.set_surface_override_material(0, h_mat)

