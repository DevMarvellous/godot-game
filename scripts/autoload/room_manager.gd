extends Node

## Manages room transitions across campus hubs without loading entire world at once.
## Includes cinematic Danfo / Keke Napep driving transition animation for seamless campus travel.

signal room_changing(from_room: StringName, to_room: StringName)
signal room_loaded(room_name: StringName)

const TransitScreenScene = preload("res://scenes/transit_screen.tscn")
var transit_screen_instance: TransitScreen = null

const ROOM_PATHS: Dictionary = {
	&"admission": "res://scenes/admission_screen.tscn",
	&"courtyard": "res://scenes/main.tscn",
	&"hostel": "res://scenes/rooms/hostel_room.tscn",
	&"lecture": "res://scenes/rooms/lecture_hall.tscn",
	&"class": "res://scenes/rooms/lecture_hall.tscn",
	&"class2": "res://scenes/rooms/lecture_theatre_2.tscn",
	&"library": "res://scenes/rooms/library_hall.tscn",
	&"mama_put": "res://scenes/rooms/mama_put.tscn",
	&"buka": "res://scenes/rooms/mama_put.tscn",
	&"mall": "res://scenes/rooms/campus_mall.tscn",
	&"bistro": "res://scenes/rooms/campus_mall.tscn",
	&"stadium": "res://scenes/rooms/football_stadium.tscn",
	&"chapel": "res://scenes/rooms/chapel_hall.tscn",
	&"sub": "res://scenes/rooms/sub_building.tscn",
	&"market": "res://scenes/rooms/sub_building.tscn",
	&"garden": "res://scenes/rooms/campus_garden.tscn",
	&"salon": "res://scenes/rooms/barbing_salon.tscn",
	&"gate": "res://scenes/rooms/campus_gate.tscn",
	&"senate": "res://scenes/rooms/senate_building.tscn",
	&"convocation": "res://scenes/rooms/convocation_hall.tscn",
	&"tech_hub": "res://scenes/rooms/tech_hub.tscn"
}

const ROOM_NAMES: Dictionary = {
	&"admission": "Admissions Portal",
	&"courtyard": "Main Campus Quad & Courtyard",
	&"hostel": "Student Hostel (Hall 2 / Moremi)",
	&"lecture": "Faculty Lecture Theatre 1",
	&"class": "Faculty Lecture Theatre 1",
	&"class2": "Faculty Lecture Theatre 2",
	&"library": "Central University Library",
	&"mama_put": "Mama Put Food Canteen",
	&"buka": "Mama Put Food Canteen",
	&"mall": "Madam Kikelomo Campus Mall",
	&"bistro": "Madam Kikelomo Campus Mall",
	&"stadium": "Sports Stadium & Arena",
	&"chapel": "University Chapel Hall",
	&"sub": "Student Union Building (SUB)",
	&"market": "Student Union Building (SUB)",
	&"garden": "Campus Botanical Garden & Park",
	&"salon": "Executive Barber & Hair Salon",
	&"gate": "Main Campus Security Gate",
	&"senate": "Senate Administrative Building",
	&"convocation": "Great Hall of Convocation & Alumni Arena",
	&"tech_hub": "Silicon Lagoon Tech Hub & Wellness Clinic"
}

var current_room: StringName = &"courtyard"
var is_transitioning: bool = false
var _sanitize_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if TransitScreenScene:
		transit_screen_instance = TransitScreenScene.instantiate() as TransitScreen
		add_child(transit_screen_instance)
	get_tree().node_added.connect(_on_node_added_clean_text)
	call_deferred("_sanitize_entire_tree")


func _process(delta: float) -> void:
	_sanitize_timer += delta
	if _sanitize_timer >= 0.45:
		_sanitize_timer = 0.0
		_sanitize_entire_tree()


## Replaces unsupported multi-color emojis (U+1F000..U+1FAFF) that render as missing-glyph
## tofu boxes (□) in Godot WebAssembly's built-in OpenSans font with 100%-supported symbols.
static func clean_godot_text(raw: String) -> String:
	if raw.is_empty():
		return raw
	var has_unsupported: bool = false
	for i in range(raw.length()):
		var cp: int = raw.unicode_at(i)
		if cp >= 0x1F000 or cp == 0xFE0F or (cp >= 0x2600 and cp <= 0x27BF and cp != 0x2713 and cp != 0x2714 and cp != 0x2715 and cp != 0x2716 and cp != 0x2605 and cp != 0x2606 and cp != 0x2665 and cp != 0x266A and cp != 0x266B and cp != 0x2794):
			has_unsupported = true
			break
	if not has_unsupported:
		return raw

	var out: String = ""
	var prev_space: bool = false
	for i in range(raw.length()):
		var cp: int = raw.unicode_at(i)
		if cp == 0xFE0F or cp == 0x200D:
			continue
		if cp >= 0x1F000 or (cp >= 0x2600 and cp <= 0x27BF and cp != 0x2713 and cp != 0x2714 and cp != 0x2715 and cp != 0x2716 and cp != 0x2605 and cp != 0x2606 and cp != 0x2665 and cp != 0x266A and cp != 0x266B and cp != 0x2794):
			# Map key semantic emojis to crisp built-in symbols
			var rep: String = ""
			match cp:
				0x1F393, 0x1F3C6, 0x1F451, 0x1F48E, 0x26A1, 0x1F525, 0x2728: rep = "★"
				0x1F4CD, 0x1F3AF, 0x1F68C, 0x1F695, 0x1F690: rep = "➔"
				0x1F4F1, 0x1F4BB, 0x1F3E6, 0x1F4B3: rep = "■"
				0x1F7E2, 0x1F534, 0x1F7E1, 0x1F4AC: rep = "●"
				0x1F3DB, 0x1F3EB, 0x1F3E0, 0x1F3E5, 0x26EA: rep = "◆"
				0x2705: rep = "✓"
				0x274C, 0x2716: rep = "✕"
			if not rep.is_empty():
				out += rep
				prev_space = false
			continue
		var ch: String = raw[i]
		if ch == " " and prev_space:
			continue
		prev_space = (ch == " ")
		out += ch
	return out.strip_edges() if out.begins_with(" ") else out


func _on_node_added_clean_text(node: Node) -> void:
	_clean_single_node(node)


func _sanitize_entire_tree() -> void:
	var root: Node = get_tree().current_scene
	if root:
		_clean_node_recursive(root)


func _clean_node_recursive(node: Node) -> void:
	_clean_single_node(node)
	for child in node.get_children():
		_clean_node_recursive(child)


func _clean_single_node(node: Node) -> void:
	if node is Label:
		var lbl := node as Label
		var cleaned := clean_godot_text(lbl.text)
		if cleaned != lbl.text:
			lbl.text = cleaned
	elif node is Button:
		var btn := node as Button
		var cleaned := clean_godot_text(btn.text)
		if cleaned != btn.text:
			btn.text = cleaned
		if btn is OptionButton:
			var opt := btn as OptionButton
			for idx in range(opt.item_count):
				var it_txt := opt.get_item_text(idx)
				var it_clean := clean_godot_text(it_txt)
				if it_clean != it_txt:
					opt.set_item_text(idx, it_clean)
	elif node is RichTextLabel:
		var rtl := node as RichTextLabel
		var cleaned := clean_godot_text(rtl.text)
		if cleaned != rtl.text:
			rtl.text = cleaned
	elif node is Label3D:
		var l3d := node as Label3D
		var cleaned := clean_godot_text(l3d.text)
		if cleaned != l3d.text:
			l3d.text = cleaned


func change_room(target_room: StringName, play_drive: bool = true) -> void:
	if is_transitioning or not ROOM_PATHS.has(target_room):
		return

	if current_room == target_room:
		return

	var target_path: String = ROOM_PATHS[target_room]
	var dest_name: String = ROOM_NAMES.get(target_room, String(target_room).capitalize())
	change_room_to_path(target_path, dest_name, target_room, play_drive)


func change_room_to_path(target_path: String, dest_name: String = "", target_room_id: StringName = &"", play_drive: bool = true) -> void:
	if is_transitioning:
		return

	# Deduce name if empty
	if dest_name.is_empty():
		for r_id in ROOM_PATHS.keys():
			if ROOM_PATHS[r_id] == target_path:
				dest_name = ROOM_NAMES.get(r_id, String(r_id).capitalize())
				if target_room_id == &"":
					target_room_id = r_id
				break
	if dest_name.is_empty():
		dest_name = "Campus Zone"

	is_transitioning = true
	var prev_room: StringName = current_room
	if target_room_id != &"":
		room_changing.emit(prev_room, target_room_id)

	if play_drive and is_instance_valid(transit_screen_instance):
		transit_screen_instance.play_drive_transition(
			dest_name,
			target_path,
			func() -> void:
				var err: Error = get_tree().change_scene_to_file(target_path)
				if err == OK:
					if target_room_id != &"":
						current_room = target_room_id
					room_loaded.emit(current_room)
				else:
					push_error("Failed to load room scene: %s (Error %d)" % [target_path, err])
		)
		await transit_screen_instance.transit_finished
		is_transitioning = false
	else:
		var err: Error = get_tree().change_scene_to_file(target_path)
		if err == OK:
			if target_room_id != &"":
				current_room = target_room_id
			room_loaded.emit(current_room)
		else:
			push_error("Failed to load room scene: %s (Error %d)" % [target_path, err])
		is_transitioning = false
