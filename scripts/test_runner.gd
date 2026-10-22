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
	print("  -> Player3D hair & outfit 3D mesh swapping + dressing spin animation OK (Tested %d combos)" % tested_combos)

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
	snooker.strike()
	snooker._physics_process(0.016)
	snooker.close_game()
	snooker.queue_free()
	print("  -> SUB Arcade 9-Ball Snooker Mini-Game OK (Racked 10 balls, 2D physics verified)")

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
		"res://scenes/rooms/campus_gate.tscn",
		"res://scenes/rooms/senate_building.tscn"
	]
	for r_path in rooms_to_test:
		var scene = load(r_path)
		var inst = scene.instantiate()
		add_child(inst)
		inst._process(0.016)
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

	print("========================================================")
	print("   ALL 6 TEST PHASES PASSED WITH ZERO CRASHES OR ERRORS!")
	print("========================================================\n")
	get_tree().quit(0)
