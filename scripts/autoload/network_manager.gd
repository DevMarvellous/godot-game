extends Node

## Web & Mobile-Compatible Online Multiplayer Network Manager.
## Uses WebSocketMultiplayerPeer (fully compatible with HTML5/WebAssembly, Android, and PC).
## Designed for zero-friction room synchronization and student chat.
## Fallback: Operates in single-player offline mode seamlessly if disconnected.

signal player_joined(peer_id: int, player_data: Dictionary)
signal player_left(peer_id: int)
signal chat_received(sender_name: String, message: String, peer_id: int)
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


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func is_online() -> bool:
	return current_state == NetState.CONNECTED or current_state == NetState.SERVER


## Connect to an online campus server / lobby via WebSockets
func connect_to_campus(url: String = DEFAULT_SERVER_URL) -> void:
	current_state = NetState.CONNECTING
	connection_status_changed.emit(false, "Connecting to Campus Server...")

	_peer = WebSocketMultiplayerPeer.new()
	var err: Error = _peer.create_client(url)
	if err != OK:
		current_state = NetState.OFFLINE
		connection_status_changed.emit(false, "Offline (Single-player mode)")
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

	if is_online():
		rpc(&"_rpc_sync_transform", room_name, pos, rot_y, is_moving)


func broadcast_chat(message: String) -> void:
	var sender: String = local_player_data.get("name", "Student")
	chat_received.emit(sender, message, multiplayer.get_unique_id())

	if is_online():
		rpc(&"_rpc_sync_chat", sender, message)


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

