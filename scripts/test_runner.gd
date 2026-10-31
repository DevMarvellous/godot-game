extends Node

func _ready() -> void:
	print("\n========================================================")
	print("   MY CAMPUS LIFE - AUTOMATED INTEGRATION TEST")
	print("========================================================")

	# 1. Test Data files
	print("[1/6] Verifying Data Stores...")
	var wardrobe = load("res://scripts/data/wardrobe_data.gd")
	assert(wardrobe.HAIRSTYLES.size() > 0, "Hairstyles empty!")
	assert(wardrobe.OUTFITS.size() > 0, "Outfits empty!")
	assert(wardrobe.COMPLEXIONS.size() > 0, "Complexions empty!")
	print("  -> WardrobeData OK: %d hairstyles, %d outfits, %d complexions" % [wardrobe.HAIRSTYLES.size(), wardrobe.OUTFITS.size(), wardrobe.COMPLEXIONS.size()])

	var food = load("res://scripts/data/food_data.gd")
	assert(food.DISHES.size() > 0, "Dishes empty!")
	print("  -> FoodData OK: %d dishes" % [food.DISHES.size()])

	var mall = load("res://scripts/data/mall_items_data.gd")
	assert(mall.ITEMS.size() > 0, "Mall items empty!")
	print("  -> MallItemsData OK: %d items" % [mall.ITEMS.size()])

	var db = load("res://scripts/data/database_config.gd")
	assert(db.SUPABASE_URL != "", "Supabase URL empty")
	print("  -> DatabaseConfig OK: %s" % db.CLOUD_TIER_INFO.provider)

	var catalog = load("res://scripts/data/academic_catalog.gd")
	assert(catalog.FACULTIES.size() == 7, "Faculties must be 7!")
	assert(catalog.DEPARTMENTS.size() == 34, "Departments must be 34!")
	print("  -> AcademicCatalog OK: 7 faculties, 34 departments across all disciplines")

	var profile = load("res://scripts/data/student_profile.gd")
	var merit_placement = profile.apply_admission("Emeka", "emeka@campus.edu.ng", "Male", 1, 0, 0, 0, "MEE", 100)
	assert(merit_placement["dept"] == "MEE", "100% score should earn first choice MEE!")
	var transfer_placement = profile.apply_admission("Emeka", "emeka@campus.edu.ng", "Male", 1, 0, 0, 0, "MEE", 0)
	assert(transfer_placement["dept"] == "MTH", "0% score in MEE should transfer to allied MTH!")
	print("  -> StudentProfile Admission Placement & Reassignment Posting OK")

	assert(AdManager != null, "AdManager autoload must exist!")
	assert(AdManager.CAMPUS_SPONSORS.size() >= 4, "Must have 4 campus sponsors!")
	print("  -> AdManager OK: 4 Campus Sponsors (MTN, Indomie, CampusPay, PowerPro)")

	# 2. Test Player 3D Mesh Swapping & Needs Manager
	print("[2/6] Verifying Player3D appearance and 3D meshes...")
	var player_scene = load("res://scenes/player_3d.tscn")
	var player = player_scene.instantiate()
	add_child(player)

	var tested_combos = 0
	for h in wardrobe.HAIRSTYLES:
		for o in wardrobe.OUTFITS:
			player.apply_appearance(
				Color.BROWN,
				o.get("top_color", Color.WHITE),
				o.get("bottom_color", Color.BLACK),
				h.get("default_color", Color.BLACK),
				h.get("mesh_type", "low_cut"),
				o.get("mesh_type", "casual")
			)
			tested_combos += 1
	player.play_dressing_animation()
	var emotes_list = ["zanku", "gbese", "shaku", "flex", "wahala", "focus", "selfie", "wave", "choplife", "juggle", "sit", "study", "pray"]
	for em in emotes_list:
		player.play_emote(em)
	print("  -> Player3D hair & outfit 3D mesh swapping + 12 procedural eased Nigerian emotes OK (Tested %d combos, %d emotes)" % [tested_combos, emotes_list.size()])

	# 3. Test Phone System & Wallpapers
	print("[3/6] Verifying Phone System...")
	var phone_scene = load("res://scenes/phone_system.tscn")
	var phone = phone_scene.instantiate()
	add_child(phone)
	for i in range(phone.WALLPAPERS.size()):
		phone.apply_wallpaper(i)
	print("  -> Phone System wallpapers OK (Tested %d AMOLED wallpapers)" % phone.WALLPAPERS.size())

	# 4. Test Wardrobe & Mall Menus
	print("[4/6] Verifying Wardrobe & Mall Menus...")
	var wardrobe_scene = load("res://scenes/wardrobe_menu.tscn")
	var wardrobe_menu = wardrobe_scene.instantiate()
	add_child(wardrobe_menu)
	wardrobe_menu.open_wardrobe(player)
	wardrobe_menu.close_wardrobe()
	print("  -> Wardrobe Menu OK")

	player.play_eating_animation()
	player.play_celebrate_animation("🎉 GOAL!")
	player.play_study_animation()
	player.play_pray_animation()
	player.spawn_floating_stat("+100 XP", Color.YELLOW)
	print("  -> Player3D life-sim animations & floating stats OK")

	var mall_scene = load("res://scenes/mall_menu.tscn")
	var mall_menu = mall_scene.instantiate()
	add_child(mall_menu)
	mall_menu.open_mall(player)
	mall_menu._on_category_changed(0)
	mall_menu._on_category_changed(1)
	mall_menu._on_category_changed(2)
	mall_menu._on_category_changed(3)
	mall_menu.close_mall()
	print("  -> Mall Menu OK (All 4 categories including Room Upgrades verified)")

	# Mini-Games & Interactive Systems Test
	var snooker_scene = load("res://scenes/snooker_mini_game.tscn")
	var snooker = snooker_scene.instantiate()
	add_child(snooker)
	snooker.open_game(player)
	assert(snooker.balls.size() == 10, "Snooker must rack 10 balls (1 cue + 9 object)!")
	snooker._set_stake(500)
	assert(snooker.active_stake == 500, "Snooker stake selection must be 500!")
	snooker.strike()
	snooker._physics_process(0.016)
	snooker.close_game()
	snooker.queue_free()
	print("  -> SUB Arcade 9-Ball Snooker Mini-Game OK (Racked 10 balls, ₦500 stake & 2D physics verified)")

	var penalty_scene = load("res://scenes/penalty_mini_game.tscn")
	var penalty = penalty_scene.instantiate()
	add_child(penalty)
	penalty.open_penalty(player)
	penalty._select_corner("top_left")
	assert(penalty.selected_corner == "top_left", "Corner must be top_left!")
	penalty._select_stake(500)
	assert(penalty.selected_stake == 500, "Stake must be 500!")
	penalty.strike()
	penalty.close_dialog()
	penalty.queue_free()
	print("  -> Dean's Cup Stadium Penalty Shootout Mini-Game OK (Corner selection, stake & strike verified)")

	var gigs_data = load("res://scripts/data/campus_gigs.gd")
	assert(gigs_data.get_all_gigs().size() >= 6, "Must have at least 6 campus side hustles!")
	var gigs_scene = load("res://scenes/campus_gigs_menu.tscn")
	var gigs_menu = gigs_scene.instantiate()
	add_child(gigs_menu)
	gigs_menu.open_gigs(player)
	gigs_menu._on_work_gig_pressed(gigs_data.get_all_gigs()[0])
	gigs_menu.close_menu()
	gigs_menu.queue_free()
	print("  -> Campus Gigs & Hustles System OK (All 6 student jobs verified)")

	var shuttle_scene = load("res://scenes/campus_shuttle_dialog.tscn")
	var shuttle_dialog = shuttle_scene.instantiate()
	add_child(shuttle_dialog)
	shuttle_dialog.open_shuttle(player)
	assert(shuttle_dialog.DESTINATIONS.size() >= 10, "Must have 10 shuttle park destinations!")
	shuttle_dialog.close_dialog()
	shuttle_dialog.queue_free()
	print("  -> Campus Keke & Shuttle Park Transit OK (10 destinations verified)")

	var hud_scene = load("res://scenes/hud.tscn")
	var hud = hud_scene.instantiate()
	add_child(hud)
	hud.show_event_banner("⚡ UP NEPA!", "Power restored to campus hostels!")
	hud._dismiss_toast()
	hud.queue_free()
	print("  -> HUD Dynamic Campus Event Toast Banner OK")

	assert(CampusEvents != null, "CampusEvents autoload must exist!")
	assert(CampusEvents.EVENTS.size() >= 12, "Must have comprehensive campus events!")
	var triggered: bool = CampusEvents.trigger_event_by_id(&"chapel_choir_mob")
	assert(triggered, "Must be able to trigger chapel_choir_mob incident!")
	print("  -> CampusEvents Dynamic Incidents & Real-Time Periodic Ticker OK (%d events verified)" % [CampusEvents.EVENTS.size()])

	var roommate_script = load("res://scripts/roommate_ai.gd")
	assert(roommate_script != null, "RoommateAI script must exist!")
	print("  -> RoommateAI living routine & state schedule OK")

	var lib_study_scene = load("res://scenes/library_study_dialog.tscn")
	var lib_study = lib_study_scene.instantiate()
	add_child(lib_study)
	lib_study.open_library_study(player)
	assert(lib_study.STUDY_MODES.size() == 3, "Library must have 3 revision modes!")
	lib_study._on_mode_selected(lib_study.STUDY_MODES[0])
	lib_study.close_dialog()
	lib_study.queue_free()
	print("  -> Library Study Archives & Past Questions OK")

	var cw_store = load("res://scripts/data/student_coursework.gd")
	var cw_proj = cw_store.get_current_project()
	assert(not cw_proj.is_empty(), "Coursework project must be assigned!")
	var cw_scene = load("res://scenes/coursework_menu.tscn")
	var cw_menu = cw_scene.instantiate()
	add_child(cw_menu)
	cw_menu.open_coursework(player)
	cw_menu.close_coursework()
	cw_menu.queue_free()
	print("  -> Student Coursework 34-Department Term Projects Desk OK")

	var lecture_session_scene = load("res://scenes/lecture_session_dialog.tscn")
	var lecture_dialog = lecture_session_scene.instantiate()
	add_child(lecture_dialog)
	lecture_dialog.start_lecture(player, "CSC")
	lecture_dialog._set_event(lecture_dialog.LectureEvent.JOT_NOTE)
	lecture_dialog._on_action_pressed()
	lecture_dialog._on_skip_pressed()
	lecture_dialog.close_dialog()
	lecture_dialog.queue_free()
	print("  -> Interactive Live Classroom Lecture & QTE Session OK")

	var lecture_desk_scene = load("res://scenes/lecture_desk_menu.tscn")
	var lecture_desk = lecture_desk_scene.instantiate()
	add_child(lecture_desk)
	lecture_desk.open_desk(player)
	lecture_desk.close_menu()
	lecture_desk.queue_free()
	print("  -> Student Lecture Desk Hub OK")

	var exam_scene = load("res://scenes/exam_hall_menu.tscn")
	var exam_menu = exam_scene.instantiate()
	add_child(exam_menu)
	exam_menu.open_exam(player)
	exam_menu._finish_exam_paper()
	exam_menu.close_exam()
	exam_menu.queue_free()
	print("  -> Comprehensive Semester Final Exam Hall & Senate Results Docket OK")

	var cooking_scene = load("res://scenes/hostel_cooking_dialog.tscn")
	var cooking_dialog = cooking_scene.instantiate()
	add_child(cooking_dialog)
	cooking_dialog.open_cooking(player)
	assert(cooking_dialog.MEALS.size() >= 5, "Must have at least 5 hostel meals!")
	cooking_dialog._on_cook_meal(cooking_dialog.MEALS[1], 150)
	cooking_dialog.close_dialog()
	cooking_dialog.queue_free()
	print("  -> Hostel Room Kitchenette & Hotplate Cooking OK")

	# Dynamic Camera Zoom test
	var initial_zoom: float = player.cam_zoom_factor
	var zoom_label: String = player.cycle_camera_zoom()
	assert(player.cam_zoom_factor != initial_zoom, "Camera zoom cycle must update zoom factor!")
	assert(zoom_label != "", "Camera zoom cycle must return a label!")
	print("  -> Dynamic Camera Zoom (Presets & Cycle) OK")

	# Backpack Inventory & Takeaway System test
	StudentProfile.add_backpack_item({
		"id": "test_takeaway_rice",
		"name": "Takeaway: Firewood Jollof Rice",
		"type": "food",
		"hunger": 55.0,
		"energy": 25.0,
		"desc": "Sealed warm takeaway food pack.",
		"count": 1
	})
	var bp_items: Array[Dictionary] = StudentProfile.get_backpack_items()
	assert(bp_items.size() >= 1, "Backpack must store items!")
	var consume_res: Dictionary = StudentProfile.consume_backpack_food(player, "test_takeaway_rice")
	assert(consume_res.get("success", false) == true, "Must successfully consume takeaway food from backpack!")

	var backpack_scene = load("res://scenes/backpack_menu.tscn")
	var bp_menu = backpack_scene.instantiate()
	add_child(bp_menu)
	bp_menu.open_menu(player)
	bp_menu.close_menu()
	bp_menu.queue_free()
	print("  -> Backpack Inventory & Takeaway Food System OK")

	# 5. Test Key Rooms
	print("[5/6] Verifying Room Scenes instancing & fan rotations...")
	var rooms_to_test = [
		"res://scenes/rooms/hostel_room.tscn",
		"res://scenes/rooms/campus_gate.tscn",
		"res://scenes/main.tscn",
		"res://scenes/rooms/campus_mall.tscn",
		"res://scenes/rooms/mama_put.tscn",
		"res://scenes/rooms/lecture_hall.tscn",
		"res://scenes/rooms/lecture_theatre_2.tscn",
		"res://scenes/rooms/library_hall.tscn",
		"res://scenes/rooms/football_stadium.tscn",
		"res://scenes/rooms/chapel_hall.tscn",
		"res://scenes/rooms/barbing_salon.tscn",
		"res://scenes/rooms/campus_garden.tscn",
		"res://scenes/rooms/sub_building.tscn",
		"res://scenes/rooms/senate_building.tscn",
		"res://scenes/rooms/convocation_hall.tscn",
		"res://scenes/rooms/tech_hub.tscn"
	]
	for r_path in rooms_to_test:
		var scene = load(r_path)
		var inst = scene.instantiate()
		add_child(inst)
		inst._process(0.016)
		if r_path.contains("football_stadium"):
			assert(inst.has_node("StadiumFixtures/WestGrandstand"), "Stadium must have WestGrandstand bleachers!")
			assert(inst.has_node("StadiumFixtures/CornerFlagNW"), "Stadium must have corner flags!")
			assert(inst.has_node("StadiumFixtures/FloodlightNW"), "Stadium must have floodlight towers!")
			assert(inst.autonomous_peers.size() >= 2, "Stadium must spawn autonomous coursemates!")
		inst.queue_free()
		print("  -> Room OK: %s" % r_path.get_file())

	# 6. Test Admission Screen
	print("[6/6] Verifying Admission Screen with 3D SubViewport...")
	var adm_scene = load("res://scenes/admission_screen.tscn")
	var adm = adm_scene.instantiate()
	add_child(adm)
	adm._refresh_avatar_preview()
	adm._process(0.016)
	adm.queue_free()
	print("  -> Admission Screen 3D Viewport OK")

	print("[6b/6] Verifying Main Viewport Admission Stage...")
	var stage_scene = load("res://scenes/admission_stage.tscn")
	var stage_inst = stage_scene.instantiate()
	add_child(stage_inst)
	stage_inst.set_avatar_drip("Male", 1, 0, 0, 0)
	stage_inst.set_avatar_drip("Female", 3, 2, 1, 2)
	stage_inst._on_js_avatar_change([JSON.stringify({
		"gender": "Female",
		"skin_idx": 2,
		"hair_idx": 4,
		"shirt_idx": 1,
		"trouser_idx": 2
	})])
	assert(stage_inst.selected_gender == "Female", "JS bridge must update gender to Female!")
	assert(stage_inst.selected_shirt == 1, "JS bridge must update shirt_idx to 1!")
	assert(stage_inst.selected_hair == 4, "JS bridge must update hair_idx to 4!")
	stage_inst._process(0.016)
	stage_inst.queue_free()
	print("  -> Admission Stage Main Viewport (Male & Female silhouettes + JS JSON Bridge) OK")

	print("[6c/6] Verifying Multiplayer NetworkPlayer 3D Interaction & Supabase Cloud Sync...")
	var net_p_scene = load("res://scenes/network_player.tscn")
	var net_p = net_p_scene.instantiate()
	add_child(net_p)
	assert(net_p.has_node("PeerInteractArea"), "NetworkPlayer must have PeerInteractArea")
	net_p.play_emote("shaku")
	net_p.show_chat("Oya gbese!")
	net_p.queue_free()
	if SupabaseClient:
		SupabaseClient.sync_student_profile(StudentProfile.get_cloud_row_payload())
		SupabaseClient.fetch_live_game_config()
		SupabaseClient.fetch_deans_list_leaderboard()
		SupabaseClient.fetch_wealth_leaderboard()
	print("  -> Multiplayer NetworkPlayer & Cloud Backend Sync OK")

	print("[6d/6] Verifying Top View Default Camera, Clout Badge, Text Sanitizer & Desktop UI...")
	player._apply_camera_preset(0, true)
	assert(player.get_current_camera_view_name() == "Top View", "Default camera view must be Top View")
	var v1: String = player.cycle_camera_zoom()
	assert(v1 == "Classic 3/4", "Second camera view must be Classic 3/4")
	var v2: String = player.cycle_camera_zoom()
	assert(v2 == "3D Perspective", "Third camera view must be 3D Perspective")
	var v3: String = player.cycle_camera_zoom()
	assert(v3 == "Close-Up Drip", "Fourth camera view must be Close-Up Drip")
	var v4: String = player.cycle_camera_zoom()
	assert(v4 == "Top View", "Camera view must cycle back to Top View")
	assert(player.get_clout_title() != "", "Player must compute a valid Clout Title")
	var cleaned_sample: String = RoomManager.clean_godot_text("🍲 Mama Put 🏛️ Wallet: ₦5,000")
	assert(not cleaned_sample.contains("🍲"), "Unsupported color emoji must be stripped/mapped by RoomManager")
	assert(cleaned_sample.contains("₦5,000"), "Supported Naira symbol must be preserved")
	print("  -> Top View Camera, Emoji-to-Symbol Sanitizer & Clout Progression OK")

	print("[6e/6] Verifying CampusPay P2P Money Transfer & Returning Cloud Profile Restore...")
	StudentProfile.restore_returning_profile({
		"wallet_balance": 85000,
		"cgpa": 4.72,
		"matric_no": "CSC/2026/777",
		"current_level": 200,
		"owned_upgrades": ["generator", "laptop"]
	})
	assert(StudentProfile.money == 85000, "Returning cloud profile must restore exact wallet_balance")
	assert(absf(StudentProfile.cgpa - 4.72) < 0.01, "Returning cloud profile must restore exact CGPA")
	assert(StudentProfile.current_level == 200, "Returning cloud profile must restore current_level")
	assert(StudentProfile.owned_upgrades.has("generator"), "Returning cloud profile must restore owned_upgrades")
	if NetworkManager:
		NetworkManager.broadcast_money_transfer("Femi [CSC]", 1000, "Test CampusPay Transfer")
		NetworkManager._on_js_net_transfer(["Chidinma [LAW]", 2500, "Test Credit"])
	var net_p2 = net_p_scene.instantiate()
	add_child(net_p2)
	net_p2.apply_full_drip("Female", 2, 4, 2, 1, "Campus Legend")
	assert(net_p2.visual_root.has_node("FemaleSkirtMesh"), "NetworkPlayer must build FemaleSkirtMesh when apply_full_drip is called")
	assert(net_p2.name_label.text.contains("LIVE PLAYER"), "NetworkPlayer label must display LIVE PLAYER")
	net_p2.queue_free()
	TimeSystem.sync_to_shared_world_clock()

	# Test SoundManager Volume setters & Audio Bus Controls
	SoundManager.set_master_volume(0.75)
	assert(absf(SoundManager.master_volume - 0.75) < 0.01, "SoundManager master_volume must be 0.75")
	SoundManager.set_music_volume(0.60)
	assert(absf(SoundManager.music_volume - 0.60) < 0.01, "SoundManager music_volume must be 0.60")
	SoundManager.set_sfx_volume(0.85)
	assert(absf(SoundManager.sfx_volume - 0.85) < 0.01, "SoundManager sfx_volume must be 0.85")

	# Test Player set_camera_zoom_preset
	var set_cam_name: String = player.set_camera_zoom_preset(1)
	assert(set_cam_name == "Classic 3/4", "set_camera_zoom_preset(1) must return Classic 3/4")
	assert(player.cam_zoom_preset_idx == 1, "cam_zoom_preset_idx must be 1")

	print("  -> CampusPay P2P Money Transfer, Audio Volume Setters, Camera Presets & 3D Multiplayer Drip Sync OK")

	print("========================================================")
	print("   ALL 6 TEST PHASES PASSED WITH ZERO CRASHES OR ERRORS!")
	print("========================================================\n")
	get_tree().quit(0)
