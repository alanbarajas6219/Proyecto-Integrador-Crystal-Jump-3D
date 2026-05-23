extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_crear_ui()

func _crear_ui() -> void:
	var box = VBoxContainer.new()
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -310
	box.offset_right = 310
	box.offset_top = -290
	box.offset_bottom = 290
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "Selecciona dificultad"
	titulo.add_theme_font_size_override("font_size", 46)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	box.add_child(_boton("Fácil - ayuda visual activa", "facil"))
	box.add_child(_boton("Normal", "normal"))
	box.add_child(_boton("Difícil", "dificil"))
	box.add_child(_boton("Extremo", "extremo"))
	box.add_child(_volver_boton())

func _boton(texto: String, dificultad: String) -> Button:
	var b = Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(450, 58)
	UITemplo.estilizar_boton(b)
	b.pressed.connect(func(): _elegir(dificultad))
	return b

func _volver_boton() -> Button:
	var b = Button.new()
	b.text = "Volver"
	b.custom_minimum_size = Vector2(300, 52)
	UITemplo.estilizar_boton(b)
	b.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/seleccion_modo.tscn"))
	return b

func _elegir(dificultad: String) -> void:
	AudioManager.play_sfx("button")
	Global.set_dificultad_elegida(dificultad)
	Global.reiniciar_estadisticas_partida()
	if Global.modo_pendiente == "multijugador":
		get_tree().change_scene_to_file("res://scenes/controles_multijugador.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ingresar_nombre.tscn")
