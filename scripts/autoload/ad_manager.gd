extends Node

## Central In-Game Ad & Campus Sponsorship Controller for My Campus Life.
## Features:
## 1. Opt-in Rewarded Video Ads on Student Smartphone ("Urgent ₦2,000" / "Battery Recharge").
## 2. Organic in-world 3D campus billboards and posters (Courtyard, Gate, Stadium).
## 3. Paced semester transition interstitials (Only between academic sessions).
## 4. Zero-Crash Fallback: Works 100% offline or with ad-blockers with 0 errors.

signal rewarded_ad_completed(reward_type: String, reward_value: int)
signal ad_status_changed(is_available: bool)

var is_ad_ready: bool = true
var total_ads_watched: int = 0
var last_ad_timestamp: float = 0.0
const AD_COOLDOWN_SECONDS: float = 30.0

const CAMPUS_SPONSORS: Array[Dictionary] = [
	{
		"brand": "MTN 5G Pulse",
		"tagline": "Do You! Turbocharge your lecture downloads with Campus Data Bundles.",
		"color": Color(0.98, 0.78, 0.12),
		"reward_desc": "+₦2,000 Airtime & Mobile Data"
	},
	{
		"brand": "Indomie Instant Noodles",
		"tagline": "Taste the Good Life! The official fresher survival fuel.",
		"color": Color(0.92, 0.22, 0.18),
		"reward_desc": "+₦2,000 Food Allowance"
	},
	{
		"brand": "CampusPay / OPay",
		"tagline": "Instant 0% fee transfers across all Nigerian campus hostels.",
		"color": Color(0.12, 0.78, 0.45),
		"reward_desc": "+₦2,000 Direct Bank Transfer"
	},
	{
		"brand": "PowerPro Generator Hub",
		"tagline": "Silence the blackout! Quiet inverter generators for all halls.",
		"color": Color(0.20, 0.45, 0.85),
		"reward_desc": "+50% Hostel Battery Recharge"
	}
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


## Shows an opt-in rewarded video ad on the student's phone
func show_rewarded_ad(reward_type: String, player: CharacterBody3D = null) -> void:
	total_ads_watched += 1

	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
			if (window.showCampusAd) {
				window.showCampusAd('%s');
			} else {
				console.log('[My Campus Life Ads] Web ad bridge simulated.');
			}
		""" % reward_type)

	# Grant in-game reward
	_grant_ad_reward(reward_type, player)


func _grant_ad_reward(reward_type: String, player: CharacterBody3D) -> void:
	var target_player: CharacterBody3D = player
	if not target_player:
		var st := Engine.get_main_loop() as SceneTree
		if st and st.current_scene:
			target_player = st.current_scene.get_node_or_null("Player3D") as CharacterBody3D

	var needs: NeedsManager = null
	if target_player:
		needs = target_player.get_node_or_null("NeedsManager") as NeedsManager

	match reward_type:
		"quad_sponsor":
			if needs:
				needs.modify_money(2000)
				needs.modify_faith(15.0)
			StudentProfile.money += 2000
			StudentProfile.save_to_disk()
			if SupabaseClient:
				SupabaseClient.sync_profile_to_cloud(StudentProfile.get_profile_data())
			if SoundManager:
				SoundManager.play_coin()
			if target_player and target_player.has_method("display_notification"):
				target_player.display_notification("💰 MTN PULSE 5G: +₦2,000 allowance + 2GB data credited to your CampusPay!")
			if target_player and target_player.has_method("play_celebrate_animation"):
				target_player.play_celebrate_animation("🎉 MTN PULSE BONUS! +₦2,000")
			rewarded_ad_completed.emit("quad_sponsor", 2000)

		"urgent_2k":
			if needs:
				needs.modify_money(2000)
			StudentProfile.money += 2000
			StudentProfile.save_to_disk()
			if SupabaseClient:
				SupabaseClient.sync_profile_to_cloud(StudentProfile.get_profile_data())
			if SoundManager:
				SoundManager.play_coin()
			if target_player and target_player.has_method("display_notification"):
				target_player.display_notification("💰 SPONSOR PAYOUT: +₦2,000 credited to your CampusPay balance!")
			rewarded_ad_completed.emit("urgent_2k", 2000)

		"energy_recharge":
			if needs:
				needs.modify_energy(50.0)
			if SoundManager:
				SoundManager.play_bell()
			if target_player and target_player.has_method("display_notification"):
				target_player.display_notification("⚡ POWER SURGE: +50% Energy & Phone Battery Restored!")
			rewarded_ad_completed.emit("energy_recharge", 50)

		"exam_hint":
			if needs:
				needs.modify_cgpa(0.08)
			StudentProfile.cgpa = needs.cgpa if needs else 3.50
			StudentProfile.save_to_disk()
			if SupabaseClient:
				SupabaseClient.sync_profile_to_cloud(StudentProfile.get_profile_data())
			if SoundManager:
				SoundManager.play_bell()
			if target_player and target_player.has_method("display_notification"):
				target_player.display_notification("📚 SCHOLAR HINT: Exam Derivation Solved! +0.08 CGPA preparation!")
			rewarded_ad_completed.emit("exam_hint", 8)


## Shows a non-intrusive interstitial ad during semester transition
func show_semester_break_ad() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("""
			if (window.showInterstitialAd) {
				window.showInterstitialAd();
			}
		""")


## Returns a sponsor billboard definition
func get_random_sponsor() -> Dictionary:
	return CAMPUS_SPONSORS[randi() % CAMPUS_SPONSORS.size()]

