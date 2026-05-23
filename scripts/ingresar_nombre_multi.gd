extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var listo: int = 0
var j1: String = ""
var j2: String = ""

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.REGISTRO)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_ajustar_layout()
	UITemplo.agregar_boton_volver(self, _volver_menu)

func _ajustar_layout() -> void:
	$Label.offset_left = -320
	$Label.offset_right = 320
	$Label.offset_top = -280
	$Label.offset_bottom = -220
	$Label.add_theme_font_size_override("font_size", 44)
	UITemplo.estilizar_label($Label)

	$Label2.offset_left = -160
	$Label2.offset_right = 160
	$Label2.offset_top = -190
	$Label2.offset_bottom = -146
	$Label2.add_theme_font_size_override("font_size", 30)
	UITemplo.estilizar_label($Label2)

	$LineEdit2.offset_left = -250
	$LineEdit2.offset_right = 120
	$LineEdit2.offset_top = -128
	$LineEdit2.offset_bottom = -76
	UITemplo.estilizar_line_edit($LineEdit2)

	$Button.anchor_left = 0.5
	$Button.anchor_right = 0.5
	$Button.offset_left = 150
	$Button.offset_right = 360
	$Button.offset_top = -128
	$Button.offset_bottom = -74
	$Button.custom_minimum_size = Vector2(210, 52)
	UITemplo.estilizar_boton($Button)

	$Label3.offset_left = -160
	$Label3.offset_right = 160
	$Label3.offset_top = -12
	$Label3.offset_bottom = 32
	$Label3.add_theme_font_size_override("font_size", 30)
	UITemplo.estilizar_label($Label3)

	$LineEdit3.offset_left = -250
	$LineEdit3.offset_right = 120
	$LineEdit3.offset_top = 48
	$LineEdit3.offset_bottom = 100
	UITemplo.estilizar_line_edit($LineEdit3)

	$Button2.anchor_left = 0.5
	$Button2.anchor_right = 0.5
	$Button2.offset_left = 150
	$Button2.offset_right = 360
	$Button2.offset_top = 48
	$Button2.offset_bottom = 102
	$Button2.custom_minimum_size = Vector2(210, 52)
	UITemplo.estilizar_boton($Button2)

func _on_button_pressed() -> void:
	if listo < 2:
		listo += 1
	j1 = $LineEdit2.text.strip_edges()
	if j1 == "":
		j1 = "Jugador 1"
	$LineEdit2.process_mode = Node.PROCESS_MODE_DISABLED
	$Button.process_mode = Node.PROCESS_MODE_DISABLED
	AudioManager.play_sfx("button")
	if listo == 2:
		empezar()

func _on_button_2_pressed() -> void:
	if listo < 2:
		listo += 1
	j2 = $LineEdit3.text.strip_edges()
	if j2 == "":
		j2 = "Jugador 2"
	$LineEdit3.process_mode = Node.PROCESS_MODE_DISABLED
	$Button2.process_mode = Node.PROCESS_MODE_DISABLED
	AudioManager.play_sfx("button")
	if listo == 2:
		empezar()

func empezar() -> void:
	Global.borrar_sesion_guardada()
	Global.reiniciar_estadisticas_partida()
	Global.setNombre(j1, j2)
	Global.es_multijugador = true
	Global.j1_vivo = true
	Global.j2_vivo = true
	Global.retomar_sesion = false
	get_tree().change_scene_to_file("res://scenes/pantalla_dividida.tscn")

func _volver_menu() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
