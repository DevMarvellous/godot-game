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
var _whistle_stream: AudioStreamWAV = null
var _sizzle_stream: AudioStreamWAV = null
var _knock_stream: AudioStreamWAV = null
var _power_cut_stream: AudioStreamWAV = null
var _cheer_stream: AudioStreamWAV = null
var _music_player: AudioStreamPlayer = null
var _boombox_active: bool = false

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


func play_click() -> void:
	_play(_click_stream, -6.0)


func play_coin() -> void:
	_play(_coin_stream, -3.0)


func play_transit_horn() -> void:
	_play(_horn_stream, -4.0)


func play_bell() -> void:
	_play(_bell_stream, -2.0)


func play_alert() -> void:
	_play(_alert_stream, -1.0)


func play_whistle() -> void:
	_play(_whistle_stream, -3.0)


func play_sizzle() -> void:
	_play(_sizzle_stream, -4.0)


func play_knock() -> void:
	_play(_knock_stream, -2.0)


func play_power_cut() -> void:
	_play(_power_cut_stream, -2.0)


func play_cheer() -> void:
	_play(_cheer_stream, -2.0)


func is_boombox_playing() -> bool:
	return _boombox_active


func toggle_boombox() -> bool:
	_boombox_active = not _boombox_active
	if not _music_player:
		_music_player = AudioStreamPlayer.new()
		_music_player.bus = &"Master"
		add_child(_music_player)
	if _boombox_active:
		var afrobeats_loop: AudioStreamWAV = _create_afrobeats_loop()
		_music_player.stream = afrobeats_loop
		_music_player.volume_db = -8.0
		_music_player.play()
	else:
		_music_player.stop()
	return _boombox_active


func _generate_sound_streams() -> void:
	_click_stream = _create_tone(800.0, 0.04, 0.3)
	_coin_stream = _create_coin_chime()
	_horn_stream = _create_horn_beep()
	_bell_stream = _create_bell_chime()
	_alert_stream = _create_tone(220.0, 0.35, 0.6)
	_whistle_stream = _create_whistle()
	_sizzle_stream = _create_sizzle()
	_knock_stream = _create_knock()
	_power_cut_stream = _create_power_cut()
	_cheer_stream = _create_cheer()


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


func _create_whistle() -> AudioStreamWAV:
	# High-pitched flutter referee whistle for sports, goals, and campus events
	var sample_rate: int = 22050
	var duration_sec: float = 0.35
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = 1.0 if t < 0.28 else (duration_sec - t) / 0.07
		var flutter: float = sin(TAU * 38.0 * t) * 110.0
		var sample: float = sin(TAU * (2350.0 + flutter) * t) * env * 0.65
		var val_16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_sizzle() -> AudioStreamWAV:
	# Gentle frying / sizzling sound for Mama Put and hostel cooking
	var sample_rate: int = 22050
	var duration_sec: float = 0.50
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = exp(-t / 0.22)
		var noise: float = randf_range(-1.0, 1.0) * 0.32
		var sample: float = noise * env
		var val_16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_knock() -> AudioStreamWAV:
	# Sharp double wooden knock on room door (140Hz thuds)
	var sample_rate: int = 22050
	var duration_sec: float = 0.35
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	var t_knock2: float = 0.16
	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var s: float = 0.0
		if t < t_knock2:
			var env: float = exp(-t / 0.025)
			s = (sin(TAU * 140.0 * t) + sin(TAU * 220.0 * t) * 0.5) * env
		else:
			var t2: float = t - t_knock2
			var env2: float = exp(-t2 / 0.025)
			s = (sin(TAU * 140.0 * t2) + sin(TAU * 220.0 * t2) * 0.5) * env2
		var val_16: int = int(clampf(s * 0.85 * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_power_cut() -> AudioStreamWAV:
	# Descending electrical power blackout pitch drop
	var sample_rate: int = 22050
	var duration_sec: float = 0.45
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var env: float = exp(-t / 0.20)
		var f: float = maxf(40.0, 480.0 * (1.0 - t / duration_sec))
		var s: float = sin(TAU * f * t) * env * 0.75
		var val_16: int = int(clampf(s * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_cheer() -> AudioStreamWAV:
	# Upbeat ascending 3-chord fanfare for UP NEPA!
	var sample_rate: int = 22050
	var duration_sec: float = 0.55
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	var chord_len: float = duration_sec / 3.0
	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var step: int = int(t / chord_len)
		var freq: float = 523.25 # C5
		if step == 1:
			freq = 659.25 # E5
		elif step >= 2:
			freq = 783.99 # G5
		var sub_t: float = fmod(t, chord_len)
		var env: float = exp(-sub_t / 0.12)
		var s: float = (sin(TAU * freq * sub_t) * 0.6 + sin(TAU * freq * 2.0 * sub_t) * 0.2) * env
		var val_16: int = int(clampf(s * 0.8 * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = bytes
	return stream


func _create_afrobeats_loop() -> AudioStreamWAV:
	# Procedural chill Afrobeats rhythm loop with shakers & syncopated bass
	var sample_rate: int = 22050
	var duration_sec: float = 2.4 # 2-bar loop at ~100 BPM
	var total_samples: int = int(sample_rate * duration_sec)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)

	var step_time: float = duration_sec / 8.0 # 8 eighth-notes
	for i in range(total_samples):
		var t: float = float(i) / float(sample_rate)
		var step: int = int(t / step_time)
		var sub_t: float = fmod(t, step_time)

		# Kick / Bass on steps 0, 3, 5 (syncopated Afro bounce)
		var kick: float = 0.0
		if step == 0 or step == 3 or step == 5:
			kick = sin(TAU * maxf(45.0, 110.0 - sub_t * 300.0) * sub_t) * exp(-sub_t / 0.08) * 0.6

		# Shaker / Hi-hat on every step
		var shaker: float = randf_range(-1.0, 1.0) * exp(-sub_t / 0.025) * 0.22

		# Warm marimba / keys chord on steps 0 and 4
		var keys: float = 0.0
		if step == 0 or step == 4:
			var f_chord: float = 329.63 if step == 0 else 392.0 # E4 / G4
			keys = sin(TAU * f_chord * sub_t) * exp(-sub_t / 0.18) * 0.35

		var sample: float = (kick + shaker + keys) * 0.7
		var val_16: int = int(clampf(sample * 32767.0, -32768.0, 32767.0))
		bytes.encode_s16(i * 2, val_16)

	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total_samples
	stream.data = bytes
	return stream
