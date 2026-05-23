extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.MENU)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_crear_ui()

func _crear_ui() -> void:
	var box = VBoxContainer.new()
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -260
	box.offset_right = 260
	box.offset_top = -210
	box.offset_bottom = 210
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "Selecciona modo de juego"
	titulo.add_theme_font_size_override("font_size", 44)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	box.add_child(_boton("Modo individual", func(): _elegir("individual")))
	box.add_child(_boton("Modo 2 jugadores", func(): _elegir("multijugador")))
	box.add_child(_boton("Volver al menú", _volver))

func _boton(texto: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(390, 62)
	UITemplo.estilizar_boton(b)
	b.pressed.connect(callback)
	return b

func _elegir(modo: String) -> void:
	AudioManager.play_sfx("button")
	Global.set_modo_pendiente(modo)
	get_tree().change_scene_to_file("res://scenes/seleccion_dificultad.tscn")

func _volver() -> void:
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
