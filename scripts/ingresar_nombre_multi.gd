extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var listo: int = 0
var j1: String = ""
var j2: String = ""

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.REGISTRO)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	UITemplo.agregar_boton_volver(self, _volver_menu)

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
