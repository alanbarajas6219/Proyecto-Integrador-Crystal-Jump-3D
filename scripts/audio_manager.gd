extends Node

const MENU_MUSIC: AudioStream = preload("res://assets/audio/menu_music.mp3")

var _menu_player: AudioStreamPlayer

func _ready() -> void:
	_menu_player = AudioStreamPlayer.new()
	_menu_player.name = "MenuMusicPlayer"
	_menu_player.stream = MENU_MUSIC
	if _menu_player.stream is AudioStreamMP3:
		(_menu_player.stream as AudioStreamMP3).loop = true
	_menu_player.bus = "Master"
	_menu_player.autoplay = false
	add_child(_menu_player)
	apply_volumes()

func apply_volumes() -> void:
	if _menu_player == null:
		return
	if Global.music_volume <= 0.01:
		_menu_player.volume_db = -80.0
	else:
		_menu_player.volume_db = linear_to_db(clampf(Global.music_volume, 0.0, 1.0))

func play_menu_music() -> void:
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

func play_sfx(tipo: String) -> void:
	if Global.sfx_volume <= 0.01:
		return

	var freq: float = 440.0
	var duration: float = 0.08

	match tipo:
		"jump":
			freq = 620.0
			duration = 0.06
		"crystal":
			freq = 920.0
			duration = 0.08
		"damage":
			freq = 180.0
			duration = 0.16
		"button":
			freq = 520.0
			duration = 0.05
		"success":
			freq = 760.0
			duration = 0.12
		"warning":
			freq = 240.0
			duration = 0.18
		_:
			freq = 440.0
			duration = 0.08

	_beep(freq, duration)

func _beep(freq: float, duration: float) -> void:
	var player := AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = 22050
	stream.buffer_length = duration
	player.stream = stream
	player.volume_db = linear_to_db(clampf(Global.sfx_volume, 0.0, 1.0))
	add_child(player)
	player.play()

	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback != null:
		var frames: int = int(stream.mix_rate * duration)
		for i in range(frames):
			var t: float = float(i) / float(stream.mix_rate)
			var amp: float = sin(TAU * freq * t) * 0.18
			playback.push_frame(Vector2(amp, amp))

	await get_tree().create_timer(duration + 0.05).timeout
	if is_instance_valid(player):
		player.queue_free()
