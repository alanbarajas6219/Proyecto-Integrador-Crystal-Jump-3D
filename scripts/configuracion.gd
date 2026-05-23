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
	var box = VBoxContainer.new()
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -380
	box.offset_right = 380
	box.offset_top = -315
	box.offset_bottom = 270
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "Configuración"
	titulo.add_theme_font_size_override("font_size", 48)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	box.add_child(_crear_label("Volumen de música"))
	_music_slider = _crear_slider(Global.music_volume)
	box.add_child(_music_slider)

	box.add_child(_crear_label("Volumen de efectos"))
	_sfx_slider = _crear_slider(Global.sfx_volume)
	box.add_child(_sfx_slider)

	box.add_child(_crear_label("URL base de API externa"))
	_api_url = LineEdit.new()
	_api_url.text = Global.api_base_url
	_api_url.custom_minimum_size = Vector2(620, 52)
	box.add_child(_api_url)
	UITemplo.estilizar_line_edit(_api_url)

	var remap = Button.new()
	remap.text = "Remapeo de controles"
	remap.custom_minimum_size = Vector2(380, 52)
	box.add_child(remap)
	UITemplo.estilizar_boton(remap)
	remap.pressed.connect(_abrir_remapeo)

	var guardar = Button.new()
	guardar.text = "Guardar configuración"
	guardar.custom_minimum_size = Vector2(380, 52)
	box.add_child(guardar)
	UITemplo.estilizar_boton(guardar)
	guardar.pressed.connect(_guardar)

	_mensaje = Label.new()
	_mensaje.text = ""
	_mensaje.custom_minimum_size = Vector2(700, 40)
	_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mensaje.add_theme_font_size_override("font_size", 21)
	box.add_child(_mensaje)
	UITemplo.estilizar_label(_mensaje)

	UITemplo.agregar_boton_volver(self, _volver_menu)

func _crear_label(texto: String) -> Label:
	var label = Label.new()
	label.text = texto
	label.custom_minimum_size = Vector2(500, 34)
	label.add_theme_font_size_override("font_size", 24)
	UITemplo.estilizar_label(label)
	return label

func _crear_slider(value: float) -> HSlider:
	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.custom_minimum_size = Vector2(560, 28)
	UITemplo.estilizar_slider(slider)
	return slider

func _guardar() -> void:
	var calidad_actual: String = Global.calidad_visual
	if calidad_actual == "":
		calidad_actual = "media"

	Global.guardar_configuracion(float(_music_slider.value), float(_sfx_slider.value), calidad_actual, _api_url.text)
	AudioManager.apply_volumes()
	AudioManager.play_sfx("success")
	_mensaje.text = "Configuración guardada. La API usará: %s" % Global.api_base_url

func _volver_menu() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _abrir_remapeo() -> void:
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/remapeo_controles.tscn")
