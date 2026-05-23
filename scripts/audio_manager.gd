extends Node

const MENU_MUSIC: AudioStream = preload("res://assets/audio/menu_music.mp3")
const WIND_AMBIENCE: AudioStream = preload("res://assets/audio/wind_ambience.mp3")

var _menu_player: AudioStreamPlayer
var _wind_player: AudioStreamPlayer

func _ready() -> void:
	_menu_player = AudioStreamPlayer.new()
	_menu_player.name = "MenuMusicPlayer"
	_menu_player.stream = MENU_MUSIC
	if _menu_player.stream is AudioStreamMP3:
		(_menu_player.stream as AudioStreamMP3).loop = true
	_menu_player.bus = "Master"
	_menu_player.autoplay = false
	add_child(_menu_player)

	_wind_player = AudioStreamPlayer.new()
	_wind_player.name = "WindAmbiencePlayer"
	_wind_player.stream = WIND_AMBIENCE
	if _wind_player.stream is AudioStreamMP3:
		(_wind_player.stream as AudioStreamMP3).loop = true
	_wind_player.bus = "Master"
	_wind_player.autoplay = false
	add_child(_wind_player)

	apply_volumes()

func apply_volumes() -> void:
	if _menu_player != null:
		if Global.music_volume <= 0.01:
			_menu_player.volume_db = -80.0
		else:
			_menu_player.volume_db = linear_to_db(clampf(Global.music_volume, 0.0, 1.0))

	if _wind_player != null:
		if Global.sfx_volume <= 0.01:
			_wind_player.volume_db = -80.0
		else:
			# Ambiente bajo para que no tape efectos ni concentración del jugador.
			_wind_player.volume_db = linear_to_db(clampf(Global.sfx_volume, 0.0, 1.0)) - 18.0

func play_menu_music() -> void:
	stop_wind_ambience()
	if _menu_player == null:
		return
	apply_volumes()
	if Global.music_volume <= 0.01:
		_menu_player.stop()
		return
	if not _menu_player.playing:
		_menu_player.play()

func stop_menu_music() -> void:
	if _menu_player != null and _menu_player.playing:
		_menu_player.stop()

func play_wind_ambience() -> void:
	stop_menu_music()
	if _wind_player == null:
		return
	apply_volumes()
	if Global.sfx_volume <= 0.01:
		_wind_player.stop()
		return
	if not _wind_player.playing:
		_wind_player.play()

func stop_wind_ambience() -> void:
	if _wind_player != null and _wind_player.playing:
		_wind_player.stop()

func play_sfx(tipo: String) -> void:
	if Global.sfx_volume <= 0.01:
		return

	match tipo:
		"jump":
			_beep_sequence([620.0], 0.055)
		"double_jump":
			_beep_sequence([720.0, 920.0], 0.055)
		"crystal":
			_beep_sequence([880.0, 1120.0], 0.055)
		"powerup":
			_beep_sequence([600.0, 900.0, 1250.0], 0.065)
		"landing":
			_beep_sequence([180.0], 0.035)
		"fall":
			_beep_sequence([260.0, 160.0], 0.09)
		"damage":
			_beep_sequence([180.0, 120.0], 0.09)
		"button":
			_beep_sequence([520.0], 0.045)
		"success":
			_beep_sequence([760.0, 940.0], 0.075)
		"warning":
			_beep_sequence([240.0, 190.0], 0.075)
		"platform_break":
			_beep_sequence([320.0, 210.0, 130.0], 0.06)
		"milestone":
			_beep_sequence([640.0, 850.0, 1080.0], 0.08)
		"gameover":
			_beep_sequence([300.0, 220.0, 150.0], 0.10)
		_:
			_beep_sequence([440.0], 0.07)

func _beep_sequence(freqs: Array, duration: float) -> void:
	for freq in freqs:
		_beep(float(freq), duration)
		await get_tree().create_timer(duration * 0.45).timeout

func _beep(freq: float, duration: float) -> void:
	var player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = duration
	player.stream = stream
	player.volume_db = linear_to_db(clampf(Global.sfx_volume, 0.0, 1.0))
	add_child(player)
	player.play()

	var playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback != null:
		var frames: int = int(stream.mix_rate * duration)
		for i in range(frames):
			var t: float = float(i) / float(stream.mix_rate)
			var fade: float = 1.0 - (float(i) / float(maxi(frames, 1)))
			var amp: float = sin(TAU * freq * t) * 0.16 * fade
			playback.push_frame(Vector2(amp, amp))

	await get_tree().create_timer(duration + 0.03).timeout
	if is_instance_valid(player):
		player.queue_free()
