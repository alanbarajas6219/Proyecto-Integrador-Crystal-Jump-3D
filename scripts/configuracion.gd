extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var _music_slider: HSlider
var _sfx_slider: HSlider
var _api_url: LineEdit
var _mensaje: Label

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.CONFIGURACION)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_crear_ui()

func _crear_ui() -> void:
	var titulo := Label.new()
	titulo.text = "Configuración"
	titulo.anchor_left = 0.5
	titulo.anchor_right = 0.5
	titulo.offset_left = -260
	titulo.offset_right = 260
	titulo.offset_top = 55
	titulo.offset_bottom = 115
	titulo.add_theme_font_size_override("font_size", 50)
	add_child(titulo)
	UITemplo.estilizar_label(titulo)

	var y: float = 165.0

	_agregar_label("Volumen de música", y)
	y += 48
	_music_slider = _crear_slider(y, Global.music_volume)
	y += 86

	_agregar_label("Volumen de efectos", y)
	y += 48
	_sfx_slider = _crear_slider(y, Global.sfx_volume)
	y += 86

	_agregar_label("URL base de API externa", y)
	y += 48
	_api_url = LineEdit.new()
	_api_url.text = Global.api_base_url
	_api_url.anchor_left = 0.5
	_api_url.anchor_right = 0.5
	_api_url.offset_left = -370
	_api_url.offset_right = 370
	_api_url.offset_top = y
	_api_url.offset_bottom = y + 58
	add_child(_api_url)
	UITemplo.estilizar_line_edit(_api_url)
	y += 90

	var guardar := Button.new()
	guardar.text = "Guardar configuración"
	guardar.anchor_left = 0.5
	guardar.anchor_right = 0.5
	guardar.offset_left = -230
	guardar.offset_right = 230
	guardar.offset_top = y
	guardar.offset_bottom = y + 60
	add_child(guardar)
	UITemplo.estilizar_boton(guardar)
	guardar.pressed.connect(_guardar)

	_mensaje = Label.new()
	_mensaje.text = ""
	_mensaje.anchor_left = 0.5
	_mensaje.anchor_right = 0.5
	_mensaje.offset_left = -360
	_mensaje.offset_right = 360
	_mensaje.offset_top = y + 78
	_mensaje.offset_bottom = y + 128
	_mensaje.add_theme_font_size_override("font_size", 24)
	add_child(_mensaje)
	UITemplo.estilizar_label(_mensaje)

	UITemplo.agregar_boton_volver(self, _volver_menu)

func _agregar_label(texto: String, y: float) -> void:
	var label := Label.new()
	label.text = texto
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.offset_left = -300
	label.offset_right = 300
	label.offset_top = y
	label.offset_bottom = y + 42
	label.add_theme_font_size_override("font_size", 26)
	add_child(label)
	UITemplo.estilizar_label(label)

func _crear_slider(y: float, value: float) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.anchor_left = 0.5
	slider.anchor_right = 0.5
	slider.offset_left = -300
	slider.offset_right = 300
	slider.offset_top = y
	slider.offset_bottom = y + 42
	add_child(slider)
	return slider

func _guardar() -> void:
	# Se conserva internamente la calidad actual, pero ya no se muestra como opción del menú.
	var calidad_actual: String = Global.calidad_visual
	if calidad_actual == "":
		calidad_actual = "media"

	Global.guardar_configuracion(float(_music_slider.value), float(_sfx_slider.value), calidad_actual, _api_url.text)
	AudioManager.play_sfx("success")
	_mensaje.text = "Configuración guardada. La API usará: %s" % Global.api_base_url

func _volver_menu() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
