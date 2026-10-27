class_name AdmissionStage
extends Node3D

## 3D Admission & Character Customization Stage for My Campus Life.
## Renders the student avatar directly in the MAIN 3D VIEWPORT.
## Eliminates mobile WebGL SubViewport blackouts, ensuring 100% crisp 3D visuals.
## Interacts with both the native HTML Admissions Portal on Web and the in-engine Control UI.

@onready var preview_player: Player3D = $StagePodium/PreviewPlayer
@onready var stage_podium: MeshInstance3D = $StagePodium
@onready var stage_camera: Camera3D = $StageCamera
@onready var key_light: DirectionalLight3D = $KeyLight
@onready var fill_light: DirectionalLight3D = $FillLight
@onready var world_env: WorldEnvironment = $WorldEnvironment

const Wardrobe = preload("res://scripts/data/wardrobe_data.gd")
const ProfileStore = preload("res://scripts/data/student_profile.gd")

var selected_gender: String = "Male"
var selected_complexion: int = 1
var selected_hair: int = 0
var selected_shirt: int = 0
var selected_trouser: int = 0
var selected_faculty: String = "CMP_FAC"
var selected_dept: String = "CSC"

var _turntable_rotation: float = 0.0
var _is_spinning: bool = false
var _spin_timer: float = 0.0
var _js_cb_drip: Variant = null
var _js_cb_submit: Variant = null


func _ready() -> void:
	# Configure camera and lighting for rich, lag-free mobile rendering
	if stage_camera:
		stage_camera.make_current()

	if is_instance_valid(preview_player):
		preview_player.set_physics_process(false)
		preview_player.set_process_unhandled_input(false)
		for child_name in ["Camera3D", "CollisionShape3D", "NotifLabel", "PromptLabel", "ChatBubble"]:
			var n = preview_player.get_node_or_null(child_name)
			if n:
				preview_player.remove_child(n)
				n.free()

	# If running on Web, hide in-engine fallback UI so the native HTML Admissions Portal takes over
	var native_ui: CanvasLayer = get_node_or_null("NativeUIFallback") as CanvasLayer
	if native_ui:
		if OS.has_feature("web"):
			native_ui.visible = false
		else:
			native_ui.visible = true
			var screen = native_ui.get_node_or_null("AdmissionScreen")
			if screen and screen.has_signal("onboarding_completed"):
				screen.onboarding_completed.connect(finalize_admission)

	_setup_js_bridge()
	apply_appearance_from_selections(false)

	# If on Web, notify the HTML shell that Godot engine has loaded and the 3D stage is ready!
	if OS.has_feature("web"):
		_notify_web_stage_ready()


func _process(delta: float) -> void:
	if not is_instance_valid(preview_player) or not preview_player.visual_root:
		return

	# Smooth gentle idle turntable rotation when not performing a quick outfit spin
	if not _is_spinning:
		_turntable_rotation += delta * 0.45
		preview_player.visual_root.rotation.y = _turntable_rotation
	else:
		_spin_timer -= delta
		if _spin_timer <= 0.0:
			_is_spinning = false


## Apply physical styling to the 3D player on the matriculation podium
func apply_appearance_from_selections(animate_spin: bool = true) -> void:
	if not is_instance_valid(preview_player):
		return

	var hair_item: Dictionary = Wardrobe.HAIRSTYLES[clampi(selected_hair, 0, Wardrobe.HAIRSTYLES.size() - 1)]
	var outfit_item: Dictionary = Wardrobe.OUTFITS[clampi(selected_shirt, 0, Wardrobe.OUTFITS.size() - 1)]
	var skin_item: Dictionary = Wardrobe.COMPLEXIONS[clampi(selected_complexion, 0, Wardrobe.COMPLEXIONS.size() - 1)]
	var tr_item: Dictionary = CharacterCustomizer.TROUSER_STYLES[clampi(selected_trouser, 0, CharacterCustomizer.TROUSER_STYLES.size() - 1)]

	var skin_col: Color = skin_item.get("color", Color(0.35, 0.22, 0.14))
	var top_col: Color = outfit_item.get("top_color", Color(0.12, 0.55, 0.32))
	var btm_col: Color = tr_item.get("color", outfit_item.get("bottom_color", Color(0.15, 0.22, 0.32)))
	var hair_col: Color = hair_item.get("default_color", Color(0.08, 0.08, 0.08))

	var hair_mesh_type: String = String(hair_item.get("mesh_type", "low_cut"))
	var outfit_mesh_type: String = String(outfit_item.get("mesh_type", "casual"))

	var apply_fn := func():
		if is_instance_valid(preview_player):
			ProfileStore.gender = selected_gender
			preview_player.apply_appearance(
				skin_col, top_col, btm_col, hair_col,
				hair_mesh_type, outfit_mesh_type
			)

	if animate_spin and preview_player.has_method("play_dressing_animation"):
		_is_spinning = true
		_spin_timer = 0.55
		preview_player.play_dressing_animation(apply_fn)
	else:
		apply_fn.call()


## Update appearance from external payload (called by HTML Portal or in-engine UI)
func set_avatar_drip(gender: String, skin_idx: int, hair_idx: int, shirt_idx: int, trouser_idx: int) -> void:
	selected_gender = gender
	selected_complexion = skin_idx
	selected_hair = hair_idx
	selected_shirt = shirt_idx
	selected_trouser = trouser_idx
	apply_appearance_from_selections(true)


## Complete the admission process, commit to student profile, and transition to campus
func finalize_admission(profile_data: Dictionary) -> void:
	var s_name: String = String(profile_data.get("name", "Student")).strip_edges()
	if s_name.is_empty():
		s_name = "Tunde Adeleke"

	var s_email: String = String(profile_data.get("email", "student@campus.edu.ng")).strip_edges()
	var s_username: String = String(profile_data.get("username", "")).strip_edges()
	var s_gender: String = String(profile_data.get("gender", selected_gender))
	var s_skin: int = int(profile_data.get("skin_idx", selected_complexion))
	var s_hair: int = int(profile_data.get("hair_idx", selected_hair))
	var s_shirt: int = int(profile_data.get("shirt_idx", selected_shirt))
	var s_trouser: int = int(profile_data.get("trouser_idx", selected_trouser))
	var s_dept: String = String(profile_data.get("dept", selected_dept))
	var s_score: int = int(profile_data.get("quiz_score", 100))

	if s_username.is_empty():
		s_username = "@" + s_name.split(" ")[0].to_lower() + "_26"
	ProfileStore.username = s_username

	# Save to persistent ProfileStore
	ProfileStore.apply_admission(
		s_name, s_email, s_gender,
		s_skin, s_hair, s_shirt, s_trouser,
		s_dept, s_score
	)

	# Update NetworkManager with local student identity
	if NetworkManager:
		NetworkManager.set_local_profile({
			"student_name": s_name,
			"skin_index": s_skin,
			"shirt_index": s_shirt,
			"trouser_index": s_trouser,
			"hair_index": s_hair
		})

	# Sync to Supabase Cloud if available
	if SupabaseClient:
		SupabaseClient.sync_student_profile(ProfileStore.to_dictionary())

	# Transition smoothly to Central Academic Quad
	if SoundManager:
		SoundManager.play_bell()

	if RoomManager:
		RoomManager.change_room(&"courtyard")
	else:
		get_tree().change_scene_to_file("res://scenes/main.tscn")


## Bridge between JavaScript HTML overlay and Godot GDScript
func _setup_js_bridge() -> void:
	if not OS.has_feature("web"):
		return

	# Store callbacks in member variables so Godot RefCounted doesn't free them!
	_js_cb_drip = JavaScriptBridge.create_callback(_on_js_avatar_change)
	_js_cb_submit = JavaScriptBridge.create_callback(_on_js_admission_submit)

	var js_window = JavaScriptBridge.get_interface("window")
	if js_window:
		js_window.godotOnAvatarChange = _js_cb_drip
		js_window.godotOnAdmissionSubmit = _js_cb_submit


func _on_js_avatar_change(args: Array) -> void:
	if args.is_empty():
		return
	var raw = args[0]
	if raw == null:
		return

	# Parse JavaScript object properties
	var g: String = String(raw.gender) if "gender" in raw else selected_gender
	var skin: int = int(raw.skin_idx) if "skin_idx" in raw else selected_complexion
	var hair: int = int(raw.hair_idx) if "hair_idx" in raw else selected_hair
	var shirt: int = int(raw.shirt_idx) if "shirt_idx" in raw else selected_shirt
	var trouser: int = int(raw.trouser_idx) if "trouser_idx" in raw else selected_trouser

	set_avatar_drip(g, skin, hair, shirt, trouser)


func _on_js_admission_submit(args: Array) -> void:
	if args.is_empty():
		return
	var raw = args[0]
	if raw == null:
		return

	var data: Dictionary = {
		"name": String(raw.name) if "name" in raw else "Tunde Adeleke",
		"username": String(raw.username) if "username" in raw else "@tunde_csc",
		"email": String(raw.email) if "email" in raw else "student@campus.edu.ng",
		"gender": String(raw.gender) if "gender" in raw else selected_gender,
		"skin_idx": int(raw.skin_idx) if "skin_idx" in raw else selected_complexion,
		"hair_idx": int(raw.hair_idx) if "hair_idx" in raw else selected_hair,
		"shirt_idx": int(raw.shirt_idx) if "shirt_idx" in raw else selected_shirt,
		"trouser_idx": int(raw.trouser_idx) if "trouser_idx" in raw else selected_trouser,
		"dept": String(raw.dept) if "dept" in raw else selected_dept,
		"quiz_score": int(raw.quiz_score) if "quiz_score" in raw else 100
	}
	finalize_admission(data)


func _notify_web_stage_ready() -> void:
	JavaScriptBridge.eval("""
		if (window.onCampusStageReady) {
			window.onCampusStageReady();
		}
	""")
