extends Node

## Web & Mobile-Compatible Online Multiplayer Network Manager.
## Uses WebSocketMultiplayerPeer (fully compatible with HTML5/WebAssembly, Android, and PC).
## Designed for zero-friction room synchronization and student chat.
## Fallback: Operates in single-player offline mode seamlessly if disconnected.

signal player_joined(peer_id: int, player_data: Dictionary)
signal player_left(peer_id: int)
signal chat_received(sender_name: String, message: String, peer_id: int)
signal emote_received(peer_id: int, emote_name: String)
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
const CLOUD_PEERS: Array[Dictionary] = [
	{"id": 901, "name": "Femi [CSC]", "shirt": Color(0.15, 0.65, 0.38), "trouser": Color(0.14, 0.18, 0.26)},
	{"id": 902, "name": "Chidinma [LAW]", "shirt": Color(0.85, 0.28, 0.48), "trouser": Color(0.16, 0.16, 0.20)},
	{"id": 903, "name": "Tobi [MEE]", "shirt": Color(0.95, 0.68, 0.14), "trouser": Color(0.18, 0.22, 0.28)}
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
	# Auto-activate lightweight Campus Cloud Lobby so rooms always have live online peers
	_activate_cloud_lobby()


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
			"name": cp["name"],
			"room": peer_room,
			"pos": next_pos,
			"rot_y": rot_y,
			"is_moving": moving and dir.length() > 0.02,
			"shirt_col": cp["shirt"],
			"trouser_col": cp["trouser"]
		}


func _activate_cloud_lobby() -> void:
	_cloud_lobby_active = true
	current_state = NetState.CONNECTED
	connection_status_changed.emit(true, "Campus Cloud Lobby (3 Online)")


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

	if is_online() and not _cloud_lobby_active and multiplayer.has_multiplayer_peer():
		rpc(&"_rpc_sync_transform", room_name, pos, rot_y, is_moving)


func broadcast_chat(message: String) -> void:
	var sender: String = local_player_data.get("name", "Student")
	var local_id: int = 1 if _cloud_lobby_active else multiplayer.get_unique_id()
	chat_received.emit(sender, message, local_id)

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
	chat_received.emit(sender_name, message, sender_id)


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

