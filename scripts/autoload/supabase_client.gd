extends Node

## Cloud Database & Supabase Connector for My Campus Life.
## Features:
## 1. Dual-Layer Persistence: Offline IndexedDB first + Supabase PostgreSQL cloud sync.
## 2. GoTrue Student Authentication (Signup, Login, Token management).
## 3. Dean's List Global Leaderboard (Highest CGPA across all faculties).
## 4. CampusPay Wealth Leaderboard (Richest Student Hustlers).
## 5. Seamless Offline Fallback: If offline or free-tier rate limited, game plays locally with 0 errors.

signal auth_state_changed(is_logged_in: bool, student_email: String)
signal profile_synced(success: bool, msg: String)
signal leaderboard_received(leaderboard_type: String, entries: Array)
signal live_config_received(config_data: Dictionary)

const DatabaseConfig = preload("res://scripts/data/database_config.gd")

var is_authenticated: bool = false
var auth_token: String = ""
var auth_user_id: String = ""
var student_email: String = ""
var live_config: Dictionary = {
	"announcement": {
		"title": "🚀 SILICON LAGOON TECH HUB & CLINIC OPEN!",
		"body": "Visit the new Campus Tech Hub & Wellness Clinic via the Map [M] or Danfo Shuttle!"
	},
	"economy": {
		"gig_payout_multiplier": 1.0,
		"food_price_multiplier": 1.0,
		"fresher_allowance": 30000,
		"scholarship_reward": 25000
	}
}

# HTTP Request node for async REST calls
var http_request: HTTPRequest = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	http_request = HTTPRequest.new()
	add_child(http_request)
	_load_cached_session()
	call_deferred("fetch_live_game_config")


func _load_cached_session() -> void:
	var local: Dictionary = DatabaseConfig.load_local_profile()
	if local.has("auth_token") and String(local["auth_token"]) != "":
		auth_token = String(local["auth_token"])
		auth_user_id = String(local.get("auth_user_id", ""))
		student_email = String(local.get("student_email", ""))
		is_authenticated = true
		auth_state_changed.emit(true, student_email)


## Register student with campus cloud database
func sign_up_student(email: String, pass_code: String, display_name: String) -> void:
	if not DatabaseConfig.is_cloud_configured():
		# Simulated local development auth (instant offline success)
		is_authenticated = true
		student_email = email
		auth_user_id = "local_dev_" + str(randi_range(1000, 9999))
		_cache_session()
		auth_state_changed.emit(true, email)
		profile_synced.emit(true, "Offline Profile Registered Successfully!")
		return

	var url: String = "%s/auth/v1/signup" % DatabaseConfig.get_supabase_url()
	var headers: PackedStringArray = [
		"Content-Type: application/json",
		"apikey: %s" % DatabaseConfig.get_supabase_anon_key()
	]
	var payload: Dictionary = {
		"email": email,
		"password": pass_code,
		"data": {"student_name": display_name}
	}

	http_request.request_completed.connect(_on_signup_completed, CONNECT_ONE_SHOT)
	var err: Error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		profile_synced.emit(false, "Network error during signup. Running in offline mode.")


func _on_signup_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200 or response_code == 201:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if parsed is Dictionary and parsed.has("access_token"):
			auth_token = parsed["access_token"]
			auth_user_id = parsed["user"]["id"]
			is_authenticated = true
			_cache_session()
			auth_state_changed.emit(true, student_email)
			profile_synced.emit(true, "Cloud Account Created!")
			return
	profile_synced.emit(false, "Saved to browser offline storage.")


## Sign in an existing student
func sign_in_student(email: String, pass_code: String) -> void:
	if not DatabaseConfig.is_cloud_configured():
		# Simulated local development auth (instant offline success)
		is_authenticated = true
		student_email = email
		auth_user_id = "local_dev_" + str(randi_range(1000, 9999))
		_cache_session()
		auth_state_changed.emit(true, email)
		profile_synced.emit(true, "Student Logged In (Offline Save Active)")
		return

	var url: String = "%s/auth/v1/token?grant_type=password" % DatabaseConfig.get_supabase_url()
	var headers: PackedStringArray = [
		"Content-Type: application/json",
		"apikey: %s" % DatabaseConfig.get_supabase_anon_key()
	]
	var payload: Dictionary = {
		"email": email,
		"password": pass_code
	}

	http_request.request_completed.connect(_on_signin_completed.bind(email), CONNECT_ONE_SHOT)
	var err: Error = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if err != OK:
		profile_synced.emit(false, "Network error during sign in.")


func _on_signin_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, email: String) -> void:
	if response_code == 200:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if parsed is Dictionary and parsed.has("access_token"):
			auth_token = parsed["access_token"]
			auth_user_id = parsed["user"]["id"]
			student_email = email
			is_authenticated = true
			_cache_session()
			auth_state_changed.emit(true, student_email)
			profile_synced.emit(true, "Welcome Back! Logged into Cloud.")
			load_profile_from_cloud()
			return
	profile_synced.emit(false, "Invalid email or password.")


## Sign out
func sign_out_student() -> void:
	auth_token = ""
	auth_user_id = ""
	student_email = ""
	is_authenticated = false
	var local: Dictionary = DatabaseConfig.load_local_profile()
	local.erase("auth_token")
	local.erase("auth_user_id")
	local.erase("student_email")
	DatabaseConfig.save_local_profile(local)
	auth_state_changed.emit(false, "")
	profile_synced.emit(true, "Signed out successfully.")


## Push student game state to Supabase PostgreSQL cloud table
func sync_student_profile(profile: Dictionary) -> void:
	sync_profile_to_cloud(profile)


func sync_profile_to_cloud(profile: Dictionary) -> void:
	# Always persist locally first (zero data loss guarantee)
	DatabaseConfig.save_local_profile(profile)

	if not DatabaseConfig.is_cloud_configured():
		profile_synced.emit(true, "Progress Saved to Browser Storage (Offline)")
		return

	var s_url: String = DatabaseConfig.get_supabase_url()
	var s_key: String = DatabaseConfig.get_supabase_anon_key()
	var bearer_tok: String = auth_token if auth_token != "" else s_key
	var url: String = "%s/rest/v1/student_profiles?on_conflict=matric_no" % s_url
	var headers: PackedStringArray = [
		"Content-Type: application/json",
		"apikey: %s" % s_key,
		"Authorization: Bearer %s" % bearer_tok,
		"Prefer: resolution=merge-duplicates"
	]

	var cloud_payload: Dictionary = StudentProfile.get_cloud_row_payload()
	http_request.request_completed.connect(_on_sync_completed, CONNECT_ONE_SHOT)
	http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(cloud_payload))


## Fetch Backend Live Game Config (Editable from Supabase game_live_config table or live_game_config.json)
func fetch_live_game_config() -> void:
	if OS.has_feature("web"):
		var raw_js = JavaScriptBridge.eval("window.MY_CAMPUS_LIVE_CONFIG ? JSON.stringify(window.MY_CAMPUS_LIVE_CONFIG) : ''")
		if raw_js is String and String(raw_js) != "":
			var parsed_js = JSON.parse_string(String(raw_js))
			if parsed_js is Dictionary:
				for k in parsed_js.keys():
					live_config[k] = parsed_js[k]
				live_config_received.emit(live_config)

	if not DatabaseConfig.is_cloud_configured():
		live_config_received.emit(live_config)
		return

	var cfg_req := HTTPRequest.new()
	add_child(cfg_req)
	var url: String = "%s/rest/v1/game_live_config?select=config_key,config_value" % DatabaseConfig.get_supabase_url()
	var headers: PackedStringArray = [
		"apikey: %s" % DatabaseConfig.get_supabase_anon_key()
	]
	cfg_req.request_completed.connect(func(_r: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		if code == 200:
			var rows = JSON.parse_string(body.get_string_from_utf8())
			if rows is Array:
				for row in rows:
					if row is Dictionary and row.has("config_key") and row.has("config_value"):
						live_config[String(row["config_key"])] = row["config_value"]
				live_config_received.emit(live_config)
		cfg_req.queue_free()
	)
	cfg_req.request(url, headers, HTTPClient.METHOD_GET)


func _on_sync_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code in [200, 201, 204]:
		profile_synced.emit(true, "Cloud Sync Complete (Supabase)")
	else:
		profile_synced.emit(true, "Local Save Active")


## Fetch Global Dean's List Leaderboard (Top 10 Highest CGPA)
func fetch_deans_list_leaderboard() -> void:
	if not DatabaseConfig.is_cloud_configured():
		# Simulated authentic Nigerian campus Dean's List
		var mock_deans_list: Array = [
			{"name": "Chidinma Okonjo", "dept": "MEE", "cgpa": 4.95, "title": "First Class Honours (Engineering)"},
			{"name": "Femi Adeleke", "dept": "CSC", "cgpa": 4.88, "title": "First Class Honours (Computing)"},
			{"name": "Tari Ebiye", "dept": "PET", "cgpa": 4.82, "title": "First Class Honours (Engineering)"},
			{"name": "Blessing Adeyemi", "dept": "MBBS", "cgpa": 4.79, "title": "Distinction (Medicine & Surgery)"},
			{"name": "Ibrahim Danjuma", "dept": "LAW", "cgpa": 4.75, "title": "First Class Honours (Law)"},
			{"name": "Kelechi Nwosu", "dept": "SWE", "cgpa": 4.71, "title": "First Class Honours (Computing)"},
			{"name": "Zainab Bello", "dept": "ACC", "cgpa": 4.65, "title": "First Class Honours (Social Sciences)"},
			{"name": "Emeka Balogun", "dept": "EEE", "cgpa": 4.58, "title": "First Class Honours (Engineering)"}
		]
		leaderboard_received.emit("deans_list", mock_deans_list)
		return

	var url: String = "%s/rest/v1/student_profiles?select=student_name,department,cgpa&order=cgpa.desc&limit=10" % DatabaseConfig.get_supabase_url()
	var headers: PackedStringArray = [
		"apikey: %s" % DatabaseConfig.get_supabase_anon_key()
	]
	http_request.request_completed.connect(func(_r: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		if code == 200:
			var data = JSON.parse_string(body.get_string_from_utf8())
			if data is Array:
				leaderboard_received.emit("deans_list", data)
	, CONNECT_ONE_SHOT)
	http_request.request(url, headers, HTTPClient.METHOD_GET)


## Fetch Campus Wealth Leaderboard (Richest Hustlers)
func fetch_wealth_leaderboard() -> void:
	if not DatabaseConfig.is_cloud_configured():
		var mock_wealth: Array = [
			{"name": "Emeka Tech O.", "dept": "CSC", "wallet_balance": 185000, "title": "Lead Software Contractor"},
			{"name": "Tolani Davies", "dept": "SMS", "wallet_balance": 142000, "title": "Madam Kikelomo Mall Partner"},
			{"name": "Damilola B.", "dept": "ENG", "wallet_balance": 98000, "title": "Campus Shuttle Logistics"},
			{"name": "Halima Lawal", "dept": "LAW", "wallet_balance": 87500, "title": "Chambers Legal Clerk"},
			{"name": "Segun Alabi", "dept": "CSC", "wallet_balance": 74000, "title": "SUB Snooker Champion"},
			{"name": "Kemi Adeleke", "dept": "NAS", "wallet_balance": 62000, "title": "Buka Food Supplies"}
		]
		leaderboard_received.emit("wealth", mock_wealth)
		return

	var url: String = "%s/rest/v1/student_profiles?select=student_name,department,wallet_balance&order=wallet_balance.desc&limit=10" % DatabaseConfig.get_supabase_url()
	var headers: PackedStringArray = [
		"apikey: %s" % DatabaseConfig.get_supabase_anon_key()
	]
	http_request.request_completed.connect(func(_r: int, code: int, _h: PackedStringArray, body: PackedByteArray):
		if code == 200:
			var data = JSON.parse_string(body.get_string_from_utf8())
			if data is Array:
				leaderboard_received.emit("wealth", data)
	, CONNECT_ONE_SHOT)
	http_request.request(url, headers, HTTPClient.METHOD_GET)


## Load full profile from Supabase PostgreSQL
func load_profile_from_cloud() -> void:
	if not is_authenticated or not DatabaseConfig.is_cloud_configured():
		return

	var url: String = "%s/rest/v1/student_profiles?id=eq.%s&select=*" % [DatabaseConfig.get_supabase_url(), auth_user_id]
	var headers: PackedStringArray = [
		"apikey: %s" % DatabaseConfig.get_supabase_anon_key(),
		"Authorization: Bearer %s" % auth_token
	]
	http_request.request_completed.connect(_on_cloud_profile_received, CONNECT_ONE_SHOT)
	http_request.request(url, headers, HTTPClient.METHOD_GET)


func _on_cloud_profile_received(_r: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if code == 200:
		var data = JSON.parse_string(body.get_string_from_utf8())
		if data is Array and data.size() > 0:
			var cloud_row: Dictionary = data[0]
			StudentProfile.load_from_disk()
			if cloud_row.has("student_name"):
				StudentProfile.student_name = String(cloud_row["student_name"])
			if cloud_row.has("matric_no"):
				StudentProfile.matric_no = String(cloud_row["matric_no"])
			if cloud_row.has("department"):
				StudentProfile.admitted_department = String(cloud_row["department"])
			if cloud_row.has("cgpa"):
				StudentProfile.cgpa = float(cloud_row["cgpa"])
			if cloud_row.has("wallet_balance"):
				StudentProfile.money = int(cloud_row["wallet_balance"])
			if cloud_row.has("owned_upgrades") and cloud_row["owned_upgrades"] is Array:
				StudentProfile.owned_upgrades = cloud_row["owned_upgrades"]
			StudentProfile.save_to_disk()
			profile_synced.emit(true, "Cloud Profile Loaded!")


func _cache_session() -> void:
	var local: Dictionary = DatabaseConfig.load_local_profile()
	local["auth_token"] = auth_token
	local["auth_user_id"] = auth_user_id
	local["student_email"] = student_email
	DatabaseConfig.save_local_profile(local)
