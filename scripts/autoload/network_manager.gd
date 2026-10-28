extends Node

## Web & Mobile-Compatible Online Multiplayer Network Manager.
## Uses WebSocketMultiplayerPeer (fully compatible with HTML5/WebAssembly, Android, and PC).
## Designed for zero-friction room synchronization and student chat.
## Fallback: Operates in single-player offline mode seamlessly if disconnected.

signal player_joined(peer_id: int, player_data: Dictionary)
signal player_left(peer_id: int)
signal chat_received(sender_name: String, message: String, peer_id: int)
signal emote_received(peer_id: int, emote_name: String)
signal money_transfer_received(sender_name: String, amount: int, note: String)
signal connection_status_changed(is_connected: bool, info: String)

enum NetState { OFFLINE, CONNECTING, CONNECTED, SERVER }

var current_state: NetState = NetState.OFFLINE
var local_player_data: Dictionary = {
	"name": "Student",
	"room": "hostel",
	"pos": Vector3.ZERO,
	"rot_y": 0.0,
	"skin_idx": 1,
	"shirt_idx": 0,
	"trouser_idx": 0,
	"hair_idx": 0
}

# Stores connected players: peer_id -> Dictionary
var remote_players: Dictionary = {}

var _peer: WebSocketMultiplayerPeer = null
const DEFAULT_PORT: int = 8910
const DEFAULT_SERVER_URL: String = "ws://127.0.0.1:8910"

var _cloud_lobby_active: bool = false
var _cloud_sim_timer: float = 0.0
var _last_broadcast_time: float = 0.0
var _js_cb_player: Variant = null
var _js_cb_remove: Variant = null
var _js_cb_chat: Variant = null
var _js_cb_emote: Variant = null
var _js_cb_transfer: Variant = null
const BROADCAST_INTERVAL: float = 0.10 # 10 Hz throttled network broadcast (optimized for lag)
const CLOUD_PEERS: Array[Dictionary] = [
	{"id": 901, "name": "Femi [CSC]", "gender": "Male", "skin_idx": 1, "hair_idx": 1, "shirt_idx": 0, "trouser_idx": 0, "clout_rank": "💻 Tech Bro", "shirt": Color(0.15, 0.65, 0.38), "trouser": Color(0.14, 0.18, 0.26)},
	{"id": 902, "name": "Chidinma [LAW]", "gender": "Female", "skin_idx": 2, "hair_idx": 4, "shirt_idx": 2, "trouser_idx": 1, "clout_rank": "📚 Dean's List", "shirt": Color(0.85, 0.28, 0.48), "trouser": Color(0.16, 0.16, 0.20)},
	{"id": 903, "name": "Tobi [MEE]", "gender": "Male", "skin_idx": 0, "hair_idx": 3, "shirt_idx": 3, "trouser_idx": 2, "clout_rank": "💎 Big Boy", "shirt": Color(0.95, 0.68, 0.14), "trouser": Color(0.18, 0.22, 0.28)}
]
const CLOUD_REPLIES: Array[String] = [
	"How far! You dey go lecture now?",
	"Omo this semester CGPA hustle no be joke o!",
	"Let's link up at Mama Put after class!",
	"Abeg who get GST past questions?",
	"No dulling! First Class is the goal 🔥",
	"Danfo shuttle driver nearly carry us pass gate 😂"
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sync_with_profile()
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	_setup_web_bridge()
	# Auto-activate lightweight Campus Cloud Lobby so rooms always have live online peers
	_activate_cloud_lobby()


func _setup_web_bridge() -> void:
	if not OS.has_feature("web"):
		return
	_js_cb_player = JavaScriptBridge.create_callback(_on_js_net_player_update)
	_js_cb_remove = JavaScriptBridge.create_callback(_on_js_net_player_remove)
	_js_cb_chat = JavaScriptBridge.create_callback(_on_js_net_chat)
	_js_cb_emote = JavaScriptBridge.create_callback(_on_js_net_emote)
	_js_cb_transfer = JavaScriptBridge.create_callback(_on_js_net_transfer)

	var js_win = JavaScriptBridge.get_interface("window")
	if js_win:
		js_win.godotReceiveNetPlayer = _js_cb_player
		js_win.godotRemoveNetPlayer = _js_cb_remove
		js_win.godotReceiveNetChat = _js_cb_chat
		js_win.godotReceiveNetEmote = _js_cb_emote
		js_win.godotReceiveNetTransfer = _js_cb_transfer


func _parse_net_payload(raw: Variant) -> Dictionary:
	if raw is Dictionary:
		return raw
	if raw is String:
		var parsed = JSON.parse_string(raw)
		if parsed is Dictionary:
			return parsed
	if OS.has_feature("web") and raw != null:
		var js_json = JavaScriptBridge.get_interface("JSON")
		if js_json:
			var s = js_json.stringify(raw)
			if s is String:
				var parsed2 = JSON.parse_string(s)
				if parsed2 is Dictionary:
					return parsed2
	return {}


func _on_js_net_player_update(args: Array) -> void:
	if args.size() < 2:
		return
	var peer_id: int = int(args[0])
	var d: Dictionary = _parse_net_payload(args[1])
	if d.is_empty():
		return

	# A real human peer has arrived over the network: retire the simulated AI buddies
	if _cloud_lobby_active:
		_retire_ai_buddies()

	# Defensive validation: clamp coordinates & trim strings from untrusted network packets
	var pos := Vector3(
		clampf(float(d.get("x", 0.0)), -60.0, 60.0),
		clampf(float(d.get("y", 0.1)), -2.0, 10.0),
		clampf(float(d.get("z", 0.0)), -60.0, 60.0)
	)
	var rot_y: float = float(d.get("rot_y", 0.0))
	var moving: bool = bool(d.get("moving", false))
	var p_name: String = _sanitize_text(String(d.get("name", "Coursemate")), 32)
	var p_room: String = _sanitize_text(String(d.get("room", "courtyard")), 40)

	var s_col: Color = Color.from_string(String(d.get("shirt_col", "#1e824c")), Color(0.2, 0.6, 0.4))
	var t_col: Color = Color.from_string(String(d.get("trouser_col", "#273746")), Color(0.15, 0.18, 0.24))

	remote_players[peer_id] = {
		"name": p_name,
		"room": p_room,
		"pos": pos,
		"rot_y": rot_y,
		"is_moving": moving,
		"shirt_col": s_col,
		"trouser_col": t_col,
		"gender": _sanitize_text(String(d.get("gender", "Male")), 10),
		"skin_idx": clampi(int(d.get("skin_idx", 1)), 0, 10),
		"hair_idx": clampi(int(d.get("hair_idx", 0)), 0, 20),
		"shirt_idx": clampi(int(d.get("shirt_idx", 0)), 0, 20),
		"trouser_idx": clampi(int(d.get("trouser_idx", 0)), 0, 20),
		"clout_rank": _sanitize_text(String(d.get("clout_rank", "100L Fresher")), 28),
		"is_ai": false
	}
	current_state = NetState.CONNECTED
	connection_status_changed.emit(true, "Campus Online (%d Students)" % remote_players.size())


func _on_js_net_player_remove(args: Array) -> void:
	if args.is_empty():
		return
	var peer_id: int = int(args[0])
	remote_players.erase(peer_id)
	player_left.emit(peer_id)
	if remote_players.is_empty():
		_activate_cloud_lobby()


func _on_js_net_chat(args: Array) -> void:
	if args.size() < 3:
		return
	var sender: String = _sanitize_text(String(args[0]), 32)
	var msg: String = _sanitize_text(String(args[1]), 120)
	var pid: int = int(args[2])
	if msg.is_empty():
		return
	chat_received.emit(sender, msg, pid)


func _on_js_net_emote(args: Array) -> void:
	if args.size() < 2:
		return
	var pid: int = int(args[0])
	var emote: String = _sanitize_text(String(args[1]), 16)
	emote_received.emit(pid, emote)


func _on_js_net_transfer(args: Array) -> void:
	if args.size() < 2:
		return
	var sender: String = _sanitize_text(String(args[0]), 36)
	var amt: int = clampi(int(args[1]), 100, 1000000)
	var note: String = _sanitize_text(String(args[2]), 60) if args.size() >= 3 else "CampusPay Transfer"
	money_transfer_received.emit(sender, amt, note)


func broadcast_money_transfer(target_name: String, amount: int, note: String = "CampusPay Transfer") -> void:
	var clean_target: String = _sanitize_text(target_name, 36)
	var clean_amt: int = clampi(amount, 100, 1000000)
	var clean_note: String = _sanitize_text(note, 60)
	if OS.has_feature("web"):
		_js_call("campusNetBroadcastTransfer", [clean_target, clean_amt, clean_note])
	if _cloud_lobby_active and not CLOUD_PEERS.is_empty():
		get_tree().create_timer(1.1).timeout.connect(func():
			if not _cloud_lobby_active or CLOUD_PEERS.is_empty():
				return
			var peer: Dictionary = CLOUD_PEERS[0]
			for cp in CLOUD_PEERS:
				if clean_target.to_lower() in String(cp["name"]).to_lower():
					peer = cp
					break
			var pid: int = int(peer["id"])
			emote_received.emit(pid, "celebrate")
			chat_received.emit(String(peer["name"]), "Omo! Alert don enter! +₦%d received via CampusPay! Respect! 🙌💸" % clean_amt, pid)
		)


## Strip control characters, BBCode/HTML brackets and clamp length for any untrusted text.
static func _sanitize_text(text: String, max_len: int) -> String:
	var cleaned: String = ""
	for ch in text:
		var code: int = ch.unicode_at(0)
		if code < 32 or ch == "<" or ch == ">" or ch == "[" or ch == "]":
			continue
		cleaned += ch
	return cleaned.strip_edges().substr(0, max_len)


## Safely call a window.* JS function with arguments encoded as JSON (no string-splicing injection).
static func _js_call(fn_name: String, call_args: Array) -> void:
	if not OS.has_feature("web"):
		return
	var encoded: Array[String] = []
	for a in call_args:
		encoded.append(JSON.stringify(a))
	JavaScriptBridge.eval("if (window.%s) window.%s(%s);" % [fn_name, fn_name, ", ".join(encoded)])


func _retire_ai_buddies() -> void:
	_cloud_lobby_active = false
	for cp in CLOUD_PEERS:
		var pid: int = int(cp["id"])
		if remote_players.has(pid):
			remote_players.erase(pid)
			player_left.emit(pid)


## Real + AI buddy players currently known (used by HUD & phone lobby).
func get_online_players() -> Dictionary:
	return remote_players


func get_real_player_count() -> int:
	var count: int = 0
	for pid in remote_players.keys():
		if not bool(remote_players[pid].get("is_ai", false)):
			count += 1
	return count


func _process(delta: float) -> void:
	if not _cloud_lobby_active:
		return
	_cloud_sim_timer += delta
	if _cloud_sim_timer < 0.25:
		return
	_cloud_sim_timer = 0.0

	var cur_room: String = String(local_player_data.get("room", "HostelRoom"))
	var t: float = float(Time.get_ticks_msec()) * 0.001
	for i in range(CLOUD_PEERS.size()):
		var cp: Dictionary = CLOUD_PEERS[i]
		var pid: int = int(cp["id"])
		# Keep 2 online peers in the player's current building and 1 roaming
		var peer_room: String = cur_room if (i < 2) else "Courtyard"
		var phase: float = t * (0.45 + float(i) * 0.15) + float(i) * 2.1
		var target_x: float = sin(phase) * (2.6 + float(i) * 0.8)
		var target_z: float = cos(phase * 0.85) * (2.2 + float(i) * 0.7)
		var moving: bool = sin(t * 0.7 + float(i)) > -0.4
		var prev_pos: Vector3 = remote_players.get(pid, {}).get("pos", Vector3(target_x, 0.1, target_z))
		var next_pos: Vector3 = prev_pos.lerp(Vector3(target_x, 0.1, target_z), 0.35 if moving else 0.05)
		var dir: Vector3 = next_pos - prev_pos
		var rot_y: float = atan2(-dir.x, -dir.z) if dir.length_squared() > 0.0005 else float(remote_players.get(pid, {}).get("rot_y", 0.0))

		remote_players[pid] = {
			"name": "🤖 " + String(cp["name"]),
			"room": peer_room,
			"pos": next_pos,
			"rot_y": rot_y,
			"is_moving": moving and dir.length() > 0.02,
			"shirt_col": cp["shirt"],
			"trouser_col": cp["trouser"],
			"gender": String(cp.get("gender", "Male")),
			"skin_idx": int(cp.get("skin_idx", 1)),
			"hair_idx": int(cp.get("hair_idx", 0)),
			"shirt_idx": int(cp.get("shirt_idx", 0)),
			"trouser_idx": int(cp.get("trouser_idx", 0)),
			"clout_rank": String(cp.get("clout_rank", "Coursemate")),
			"is_ai": true
		}


func _activate_cloud_lobby() -> void:
	_cloud_lobby_active = true
	current_state = NetState.CONNECTED
	connection_status_changed.emit(true, "Campus Lobby (AI buddies until real students join)")


func _sync_with_profile() -> void:
	const ProfileStore = preload("res://scripts/data/student_profile.gd")
	ProfileStore.load_from_disk()
	local_player_data["name"] = ProfileStore.student_name
	local_player_data["skin_idx"] = ProfileStore.complexion_index
	local_player_data["shirt_idx"] = ProfileStore.shirt_index
	local_player_data["trouser_idx"] = ProfileStore.trouser_index
	local_player_data["hair_idx"] = ProfileStore.hair_index


func is_online() -> bool:
	return current_state == NetState.CONNECTED or current_state == NetState.SERVER


## Connect to an online campus server / lobby via WebSockets
func connect_to_campus(url: String = DEFAULT_SERVER_URL) -> void:
	if OS.has_feature("web") and url.begins_with("ws://127.0.0.1"):
		_activate_cloud_lobby()
		return

	_cloud_lobby_active = false
	current_state = NetState.CONNECTING
	connection_status_changed.emit(false, "Connecting to Campus Server...")

	_peer = WebSocketMultiplayerPeer.new()
	var err: Error = _peer.create_client(url)
	if err != OK:
		_activate_cloud_lobby()
		return

	multiplayer.multiplayer_peer = _peer


## Host a local campus server (desktop / dedicated headless node)
func host_campus_server(port: int = DEFAULT_PORT) -> void:
	_peer = WebSocketMultiplayerPeer.new()
	var err: Error = _peer.create_server(port)
	if err != OK:
		current_state = NetState.OFFLINE
		connection_status_changed.emit(false, "Failed to host server")
		return

	multiplayer.multiplayer_peer = _peer
	current_state = NetState.SERVER
	connection_status_changed.emit(true, "Campus Server Running (Host)")


func disconnect_from_campus() -> void:
	if _peer:
		_peer.close()
		_peer = null
	multiplayer.multiplayer_peer = null
	current_state = NetState.OFFLINE
	remote_players.clear()
	connection_status_changed.emit(false, "Offline Mode")


func set_local_profile(profile: Dictionary) -> void:
	local_player_data["name"] = profile.get("student_name", "Student")
	local_player_data["skin_idx"] = profile.get("skin_index", 1)
	local_player_data["shirt_idx"] = profile.get("shirt_index", 0)
	local_player_data["trouser_idx"] = profile.get("trouser_index", 0)
	local_player_data["hair_idx"] = profile.get("hair_index", 0)


func broadcast_transform(room_name: String, pos: Vector3, rot_y: float, is_moving: bool) -> void:
	local_player_data["room"] = room_name
	local_player_data["pos"] = pos
	local_player_data["rot_y"] = rot_y
	local_player_data["is_moving"] = is_moving

	var now: float = float(Time.get_ticks_msec()) * 0.001
	if now - _last_broadcast_time < BROADCAST_INTERVAL:
		return
	_last_broadcast_time = now

	# 1. Web Realtime WebSocket bridge (optimized for lag, JSON-encoded args)
	if OS.has_feature("web"):
		_js_call("campusNetBroadcastTransform", [
			room_name, snappedf(pos.x, 0.01), snappedf(pos.y, 0.01), snappedf(pos.z, 0.01),
			snappedf(rot_y, 0.01), is_moving
		])

	# 2. Dedicated WebSocket Server RPC
	if is_online() and not _cloud_lobby_active and multiplayer.has_multiplayer_peer():
		rpc(&"_rpc_sync_transform", room_name, pos, rot_y, is_moving)


var _chat_timestamps: Array[float] = []
const CHAT_RATE_LIMIT: int = 5        # max messages...
const CHAT_RATE_WINDOW: float = 10.0  # ...per 10 seconds (anti-spam)


func broadcast_chat(message: String) -> void:
	message = _sanitize_text(message, 120)
	if message.is_empty():
		return
	var now_s: float = float(Time.get_ticks_msec()) * 0.001
	_chat_timestamps = _chat_timestamps.filter(func(t: float) -> bool: return now_s - t < CHAT_RATE_WINDOW)
	if _chat_timestamps.size() >= CHAT_RATE_LIMIT:
		chat_received.emit("📢 Campus System", "Slow down! Wait a few seconds before sending more messages.", -1)
		return
	_chat_timestamps.append(now_s)

	var sender: String = local_player_data.get("name", "Student")
	var local_id: int = 1 if _cloud_lobby_active else multiplayer.get_unique_id()
	chat_received.emit(sender, message, local_id)

	_js_call("campusNetBroadcastChat", [message])

	if _cloud_lobby_active:
		# Trigger an authentic coursemate reply after 1.4 seconds
		get_tree().create_timer(1.4).timeout.connect(func():
			if not _cloud_lobby_active or CLOUD_PEERS.is_empty():
				return
			var responder: Dictionary = CLOUD_PEERS.pick_random()
			var reply: String = CLOUD_REPLIES.pick_random()
			chat_received.emit(String(responder["name"]), reply, int(responder["id"]))
		)
	elif is_online() and multiplayer.has_multiplayer_peer():
		rpc(&"_rpc_sync_chat", sender, message)


func broadcast_emote(emote_name: String) -> void:
	var local_id: int = 1 if _cloud_lobby_active else multiplayer.get_unique_id()
	emote_received.emit(local_id, emote_name)

	if OS.has_feature("web"):
		_js_call("campusNetBroadcastEmote", [_sanitize_text(emote_name, 16)])

	if _cloud_lobby_active:
		# Coursemate reacts after 1.2 seconds!
		get_tree().create_timer(1.2).timeout.connect(func():
			if not _cloud_lobby_active or CLOUD_PEERS.is_empty():
				return
			var peer: Dictionary = CLOUD_PEERS.pick_random()
			var pid: int = int(peer["id"])
			match emote_name:
				"shaku", "dance", "gbese":
					emote_received.emit(pid, "shaku")
					chat_received.emit(String(peer["name"]), "Oya gbese! Gbe body e! 🔥", pid)
				"wave":
					emote_received.emit(pid, "wave")
					chat_received.emit(String(peer["name"]), "How far my guy! 👋", pid)
				"sit":
					emote_received.emit(pid, "sit")
				"celebrate":
					emote_received.emit(pid, "celebrate")
					chat_received.emit(String(peer["name"]), "Congratulations o! 🎉", pid)
				_:
					emote_received.emit(pid, "wave")
		)
	elif is_online() and multiplayer.has_multiplayer_peer():
		rpc(&"_rpc_sync_emote", emote_name)


@rpc("any_peer", "reliable")
func _rpc_sync_emote(emote_name: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	emote_received.emit(sender_id, emote_name)


@rpc("any_peer", "unreliable")
func _rpc_sync_transform(room_name: String, pos: Vector3, rot_y: float, is_moving: bool) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	if not remote_players.has(sender_id):
		remote_players[sender_id] = {}

	var data: Dictionary = remote_players[sender_id]
	data["room"] = room_name
	data["pos"] = pos
	data["rot_y"] = rot_y
	data["is_moving"] = is_moving


@rpc("any_peer", "reliable")
func _rpc_sync_chat(sender_name: String, message: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	chat_received.emit(_sanitize_text(sender_name, 32), _sanitize_text(message, 120), sender_id)


func _on_peer_connected(id: int) -> void:
	if id != 1:
		player_joined.emit(id, {})


func _on_peer_disconnected(id: int) -> void:
	remote_players.erase(id)
	player_left.emit(id)


func _on_connected_to_server() -> void:
	current_state = NetState.CONNECTED
	connection_status_changed.emit(true, "Connected to Campus Online!")


func _on_connection_failed() -> void:
	current_state = NetState.OFFLINE
	connection_status_changed.emit(false, "Offline Mode (Single Player)")


func _on_server_disconnected() -> void:
	current_state = NetState.OFFLINE
	remote_players.clear()
	connection_status_changed.emit(false, "Server Disconnected. Running Offline.")

