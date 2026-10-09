class_name ChatWheel
extends Control

const SoundManager = preload("res://scripts/autoload/sound_manager.gd")

## Quick Campus Slang & Chat Popup for Mobile and Web.
## 1-tap instant campus phrases + custom text input.
## Broadcasts to 3D player speech bubble and online room network.

signal message_sent(text: String)
signal chat_closed

const QUICK_SLANGS: Array[String] = [
	"How far guy!",
	"Lecturer dey come o!",
	"Sapa dey catch me!",
	"Who get past questions?",
	"Fellowship time, let's pray!",
	"See you at the Canteen!",
	"Class don start?",
	"Omo, this semester no easy!"
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

	_populate_quick_slangs()


func _populate_quick_slangs() -> void:
	if not slang_container:
		return
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

