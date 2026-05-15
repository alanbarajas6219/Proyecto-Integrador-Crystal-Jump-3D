extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.REGISTRO)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	UITemplo.agregar_boton_volver(self, _volver_menu)

func _on_iniciar_pressed() -> void:
	var nombre: String = $LineEdit.text.strip_edges()
	if nombre == "":
		nombre = "Jugador 1"

	Global.borrar_sesion_guardada()
	Global.setNombre(nombre, "")
	Global.es_multijugador = false
	Global.j1_vivo = true
	Global.j2_vivo = true
	Global.retomar_sesion = false
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/mundo_2.tscn")

func _volver_menu() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
