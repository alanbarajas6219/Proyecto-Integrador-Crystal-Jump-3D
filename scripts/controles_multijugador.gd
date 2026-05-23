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
	box.offset_left = -390
	box.offset_right = 390
	box.offset_top = -240
	box.offset_bottom = 180
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "Controles modo 2 jugadores"
	titulo.add_theme_font_size_override("font_size", 42)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	var info = Label.new()
	info.text = "Jugador 1: WASD para moverse + Espacio para saltar\nJugador 2: Flechas para moverse + Enter para saltar\nESC pausa la partida para ambos jugadores"
	info.custom_minimum_size = Vector2(740, 0)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 25)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(info)
	UITemplo.estilizar_label(info)

	var continuar = Button.new()
	continuar.text = "Continuar"
	continuar.custom_minimum_size = Vector2(360, 54)
	box.add_child(continuar)
	UITemplo.estilizar_boton(continuar)
	continuar.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ingresar_nombre_multi.tscn"))

	var volver = Button.new()
	volver.text = "Volver"
	volver.custom_minimum_size = Vector2(300, 52)
	box.add_child(volver)
	UITemplo.estilizar_boton(volver)
	volver.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/seleccion_dificultad.tscn"))
