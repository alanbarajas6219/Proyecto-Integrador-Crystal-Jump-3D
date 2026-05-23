extends Control

const LOADING_BG: Texture2D = preload("res://assets/ui/loading_background.png")

var _progress_bar: ProgressBar
var _progress: float = 0.0
var _min_time: float = 1.8

func _ready() -> void:
	AudioManager.stop_wind_ambience()
	_crear_ui()
	set_process(true)

func _crear_ui() -> void:
	var bg = TextureRect.new()
	bg.texture = LOADING_BG
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var veil = ColorRect.new()
	veil.color = Color(0.0, 0.0, 0.0, 0.18)
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(veil)

	var label = Label.new()
	label.text = "Cargando..."
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.anchor_top = 1.0
	label.anchor_bottom = 1.0
	label.offset_left = -220
	label.offset_right = 220
	label.offset_top = -150
	label.offset_bottom = -105
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(0.70, 0.95, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	add_child(label)

	_progress_bar = ProgressBar.new()
	_progress_bar.anchor_left = 0.5
	_progress_bar.anchor_right = 0.5
	_progress_bar.anchor_top = 1.0
	_progress_bar.anchor_bottom = 1.0
	_progress_bar.offset_left = -260
	_progress_bar.offset_right = 260
	_progress_bar.offset_top = -95
	_progress_bar.offset_bottom = -70
	_progress_bar.min_value = 0
	_progress_bar.max_value = 100
	_progress_bar.value = 0
	add_child(_progress_bar)

func _process(delta: float) -> void:
	_progress += delta
	if _progress_bar != null:
		_progress_bar.value = clampf((_progress / _min_time) * 100.0, 0.0, 100.0)
	if _progress >= _min_time:
		set_process(false)
		get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
