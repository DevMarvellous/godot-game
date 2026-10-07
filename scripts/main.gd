class_name Main
extends Node3D

## Main 3D Campus World scene.
## Connects 3D Player and HUD, configures 3D campus fixtures.

@onready var player: Player3D = $Player3D
@onready var hud: HUD = $HUD

@onready var hostel_bed: CampusObject3D = $WorldObjects/HostelBed
@onready var study_desk: CampusObject3D = $WorldObjects/StudyDesk
@onready var cafeteria: CampusObject3D = $WorldObjects/Cafeteria
@onready var chapel: CampusObject3D = $WorldObjects/Chapel
@onready var atm: CampusObject3D = $WorldObjects/ATM


func _ready() -> void:
	if player and hud:
		hud.connect_player_needs(player.needs_manager)

	# Configure 3D world objects with distinct colors & types
	_setup_3d_object(hostel_bed, CampusObject3D.ObjectType.BED, "Hostel Bed", Color(0.2, 0.45, 0.85))
	_setup_3d_object(study_desk, CampusObject3D.ObjectType.DESK, "Study Desk", Color(0.65, 0.42, 0.22))
	_setup_3d_object(cafeteria, CampusObject3D.ObjectType.CAFETERIA, "Buka / Cafeteria", Color(0.9, 0.45, 0.15))
	_setup_3d_object(chapel, CampusObject3D.ObjectType.FELLOWSHIP, "Chapel Altar", Color(0.85, 0.75, 0.2))
	_setup_3d_object(atm, CampusObject3D.ObjectType.ATM, "Campus ATM", Color(0.18, 0.75, 0.35))


func _setup_3d_object(obj: CampusObject3D, type: CampusObject3D.ObjectType, title: String, col: Color) -> void:
	if not obj:
		return
	obj.object_type = type
	obj.object_name = title
	obj.update_object_display()

	var mesh_inst: MeshInstance3D = obj.get_node_or_null("MeshInstance3D") as MeshInstance3D
	if mesh_inst:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = col
		mat.roughness = 0.5
		mesh_inst.set_surface_override_material(0, mat)
