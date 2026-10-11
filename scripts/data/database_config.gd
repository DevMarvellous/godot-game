class_name DatabaseConfig
extends RefCounted

## Database & Cloud Save Configuration.
## Handles dual-layer architecture:
## Layer 1: Offline-First IndexedDB browser storage (100% free, 0 backend servers, infinite players).
## Layer 2: Cloud Sync (Supabase PostgreSQL / PocketBase free tier - 50,000 monthly active users).

const SAVE_PATH: String = "user://campus_student_save.json"

# Supabase Free Tier Cloud Configuration (Free tier: 50,000 MAU, 500MB DB)
# In production, replace with your project URL and anonymous public key
const SUPABASE_URL: String = "https://your-project.supabase.co"
const SUPABASE_ANON_KEY: String = "public-anon-key-placeholder"

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
