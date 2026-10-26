class_name DatabaseConfig
extends RefCounted

## Database & Cloud Save Configuration.
## Handles dual-layer architecture:
## Layer 1: Offline-First IndexedDB browser storage (100% free, 0 backend servers, infinite players).
## Layer 2: Cloud Sync (Supabase PostgreSQL / PocketBase free tier - 50,000 monthly active users).

const SAVE_PATH: String = "user://campus_student_save.json"

# Supabase Free Tier Cloud Configuration (Free tier: 50,000 MAU, 500MB DB)
# Can be set here OR pasted live in the web portal's "☁️ Cloud DB" settings without rebuilding!
const SUPABASE_URL: String = "https://your-project.supabase.co"
const SUPABASE_ANON_KEY: String = "public-anon-key-placeholder"

static var custom_supabase_url: String = ""
static var custom_supabase_key: String = ""

static func get_supabase_url() -> String:
	if custom_supabase_url.strip_edges() != "":
		return custom_supabase_url.strip_edges().trim_suffix("/")
	if OS.has_feature("web"):
		var js_url = JavaScriptBridge.eval("window.getCampusSupabaseUrl ? window.getCampusSupabaseUrl() : ''")
		if js_url is String and String(js_url).strip_edges() != "":
			return String(js_url).strip_edges().trim_suffix("/")
	var local: Dictionary = load_local_profile()
	if local.has("supabase_url") and String(local["supabase_url"]).strip_edges() != "":
		return String(local["supabase_url"]).strip_edges().trim_suffix("/")
	return SUPABASE_URL

static func get_supabase_anon_key() -> String:
	if custom_supabase_key.strip_edges() != "":
		return custom_supabase_key.strip_edges()
	if OS.has_feature("web"):
		var js_key = JavaScriptBridge.eval("window.getCampusSupabaseKey ? window.getCampusSupabaseKey() : ''")
		if js_key is String and String(js_key).strip_edges() != "":
			return String(js_key).strip_edges()
	var local: Dictionary = load_local_profile()
	if local.has("supabase_anon_key") and String(local["supabase_anon_key"]).strip_edges() != "":
		return String(local["supabase_anon_key"]).strip_edges()
	return SUPABASE_ANON_KEY

static func set_cloud_credentials(url: String, anon_key: String) -> void:
	custom_supabase_url = url.strip_edges().trim_suffix("/")
	custom_supabase_key = anon_key.strip_edges()
	var local: Dictionary = load_local_profile()
	local["supabase_url"] = custom_supabase_url
	local["supabase_anon_key"] = custom_supabase_key
	save_local_profile(local)

static func is_cloud_configured() -> bool:
	var u: String = get_supabase_url()
	var k: String = get_supabase_anon_key()
	return u != "" and u != "https://your-project.supabase.co" and k != "" and k != "public-anon-key-placeholder"

# Free tier limits documentation:
const CLOUD_TIER_INFO: Dictionary = {
	"provider": "Supabase (PostgreSQL + GoTrue Auth)",
	"cost_per_month": "$0.00 (Free Tier)",
	"max_active_users_monthly": 50000,
	"database_storage_mb": 500,
	"file_storage_gb": 5,
	"bandwidth_included": "Unlimited API Requests",
	"local_fallback": "Browser IndexedDB (Zero server cost)"
}

static func save_local_profile(data: Dictionary) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open local save file for writing: %s" % SAVE_PATH)
		return false
	var json_str := JSON.stringify(data, "\t")
	file.store_string(json_str)
	file.close()
	return true

static func load_local_profile() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var content := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(content)
	if parsed is Dictionary:
		return parsed
	return {}

static func is_save_present() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

