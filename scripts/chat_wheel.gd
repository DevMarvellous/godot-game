class_name ChatWheel
extends Control


## Quick Campus Slang & Chat Popup for Mobile and Web.
## 1-tap instant campus phrases + custom text input.
## Broadcasts to 3D player speech bubble and online room network.

signal message_sent(text: String)
signal chat_closed

const QUICK_SLANGS: Array[String] = [
	"How far guy! 👋",
	"Up NEPA!! 💡🔥",
	"Oya gbese! Let's dance! 💃",
	"Lecturer dey come o! 🏃",
	"Sapa dey catch me! Need Urgent 2k 💸",
	"Who get GST past questions? 📚",
	"See you at Mama Put canteen! 🍲",
	"First Class loading! 🎓",
	"Warden dey come! Hide boiling ring! 🚨"
]

@onready var slang_container: VBoxContainer = %SlangContainer
@onready var custom_input: LineEdit = %CustomInput
@onready var send_btn: Button = %SendBtn
@onready var close_btn: Button = %CloseBtn


func _ready() -> void:
	visible = false
	if close_btn:
		close_btn.pressed.connect(close_chat)
	if send_btn:
		send_btn.pressed.connect(_on_send_custom)
	if custom_input:
		custom_input.text_submitted.connect(_on_text_submitted)
		if OS.has_feature("web"):
			custom_input.focus_entered.connect(_open_web_native_chat)

	_setup_web_chat_bridge()
	_populate_quick_slangs()


func _setup_web_chat_bridge() -> void:
	if not OS.has_feature("web"):
		return
	var cb := JavaScriptBridge.create_callback(func(args: Array):
		if args.size() > 0:
			var msg: String = String(args[0]).strip_edges()
			if not msg.is_empty():
				_send(msg)
	)
	var js_win = JavaScriptBridge.get_interface("window")
	if js_win:
		js_win.godotSendLocalChat = cb


func _open_web_native_chat() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("if (window.openNativeCampusChat) window.openNativeCampusChat();")


func _populate_quick_slangs() -> void:
	if not slang_container:
		return
	if OS.has_feature("web"):
		var kbd_btn := Button.new()
		kbd_btn.text = "⌨️ Type Custom Message (Mobile Keyboard)"
		kbd_btn.custom_minimum_size = Vector2(0, 48)
		kbd_btn.add_theme_font_size_override(&"font_size", 15)
		kbd_btn.pressed.connect(_open_web_native_chat)
		slang_container.add_child(kbd_btn)

	for slang in QUICK_SLANGS:
		var btn = Button.new()
		btn.text = "💬  \"%s\"" % slang
		btn.custom_minimum_size = Vector2(0, 44)
		btn.add_theme_font_size_override(&"font_size", 15)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_slang_pressed.bind(slang))
		slang_container.add_child(btn)


func open_chat() -> void:
	visible = true
	if custom_input:
		custom_input.text = ""


func close_chat() -> void:
	visible = false
	chat_closed.emit()


func _on_slang_pressed(slang_text: String) -> void:
	_send(slang_text)


func _on_send_custom() -> void:
	if custom_input and custom_input.text.strip_edges() != "":
		_send(custom_input.text.strip_edges())


func _on_text_submitted(text: String) -> void:
	if text.strip_edges() != "":
		_send(text.strip_edges())


func _send(msg: String) -> void:
	if SoundManager:
		SoundManager.play_click()
	if NetworkManager:
		NetworkManager.broadcast_chat(msg)
	message_sent.emit(msg)
	close_chat()

