extends Node

## Procedural Sound & Audio FX Manager for Campus Life Simulator.
## Generates lightweight synthetic chimes, dings, and audio feedback in memory.
## 100% self-contained: No bulky external audio files required, zero latency on mobile.

static var instance: Node = null

var _click_stream: AudioStreamWAV = null
var _coin_stream: AudioStreamWAV = null
var _horn_stream: AudioStreamWAV = null
var _bell_stream: AudioStreamWAV = null
var _alert_stream: AudioStreamWAV = null

var _audio_players: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 5


func _ready() -> void:
	instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	_generate_sound_streams()
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		p.bus = &"Master"
		add_child(p)
		_audio_players.append(p)


func _play(stream: AudioStreamWAV, volume_db: float = 0.0) -> void:
	if not stream:
		return
	for player in _audio_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	# If all busy, reuse first player
	var fallback = _audio_players[0]
	fallback.stream = stream
	fallback.volume_db = volume_db
	fallback.play()


static func play_click() -> void:
	if instance and instance.has_method("_play"):
		instance._play(instance._click_stream, -6.0)


static func play_coin() -> void:
	if instance and instance.has_method("_play"):
		instance._play(instance._coin_stream, -3.0)


static func play_transit_horn() -> void:
	if instance and instance.has_method("_play"):
		instance._play(instance._horn_stream, -4.0)


static func play_bell() -> void:
	if instance and instance.has_method("_play"):
		instance._play(instance._bell_stream, -2.0)


static func play_alert() -> void:
	if instance and instance.has_method("_play"):
		instance._play(instance._alert_stream, -1.0)


func _generate_sound_streams() -> void:
	_click_stream = _create_tone(800.0, 0.04, 0.3)
	_coin_stream = _create_coin_chime()
	_horn_stream = _create_horn_beep()
	_bell_stream = _create_bell_chime()
	_alert_stream = _create_tone(220.0, 0.35, 0.6)


func _create_tone(freq: float, duration_sec: float, decay_rate: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2) # 16-bit mono

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = exp(-t / (duration_sec * decay_rate))
		var sample: float = sin(TAU * freq * t) * env * 0.7
		var val_16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_coin_chime() -> AudioStreamWAV:
	# Two-tone cheerful coin ding (987Hz -> 1318Hz)
	var sample_rate: int = 22050
	var duration_sec: float = 0.22
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	var mid_sample: int = int(float(total_samples) / 2.0)
	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var freq: float = 987.0 if i < mid_sample else 1318.0
		var note_t: float = t if i < mid_sample else (t - (float(mid_sample) / float(sample_rate)))
		var env: float = exp(-note_t / 0.08)
		var sample: float = sin(TAU * freq * note_t) * env * 0.75
		var val_16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_horn_beep() -> AudioStreamWAV:
	# Campus Keke NAPEP horn sound (dual tone ~380Hz & ~440Hz)
	var sample_rate: int = 22050
	var duration_sec: float = 0.28
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = 1.0 if t < (duration_sec - 0.05) else (duration_sec - t) / 0.05
		var sample: float = (sin(TAU * 380.0 * t) * 0.5 + sin(TAU * 440.0 * t) * 0.5) * env * 0.65
		var val_16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_bell_chime() -> AudioStreamWAV:
	# Harmonic bell sound for exams and lecture periods
	var sample_rate: int = 22050
	var duration_sec: float = 0.6
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = exp(-t / 0.25)
		var sample: float = (sin(TAU * 660.0 * t) * 0.5 + sin(TAU * 1320.0 * t) * 0.3 + sin(TAU * 1980.0 * t) * 0.2) * env * 0.7
		var val_16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream

