extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.REGISTRO)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_ajustar_layout()
	UITemplo.agregar_boton_volver(self, _volver_menu)

func _ajustar_layout() -> void:
	$Label.anchor_left = 0.5
	$Label.anchor_right = 0.5
	$Label.anchor_top = 0.5
	$Label.anchor_bottom = 0.5
	$Label.offset_left = -320
	$Label.offset_right = 320
	$Label.offset_top = -230
	$Label.offset_bottom = -170
	$Label.add_theme_font_size_override("font_size", 46)
	UITemplo.estilizar_label($Label)

	$LineEdit.anchor_left = 0.5
	$LineEdit.anchor_right = 0.5
	$LineEdit.anchor_top = 0.5
	$LineEdit.anchor_bottom = 0.5
	$LineEdit.offset_left = -250
	$LineEdit.offset_right = 250
	$LineEdit.offset_top = -70
	$LineEdit.offset_bottom = -18
	UITemplo.estilizar_line_edit($LineEdit)

	$Iniciar.anchor_left = 0.5
	$Iniciar.anchor_right = 0.5
	$Iniciar.anchor_top = 0.5
	$Iniciar.anchor_bottom = 0.5
	$Iniciar.offset_left = -170
	$Iniciar.offset_right = 170
	$Iniciar.offset_top = 135
	$Iniciar.offset_bottom = 190
	$Iniciar.custom_minimum_size = Vector2(340, 54)
	UITemplo.estilizar_boton($Iniciar)

func _on_iniciar_pressed() -> void:
	var nombre: String = $LineEdit.text.strip_edges()
	if nombre == "":
		nombre = "Jugador 1"

	Global.borrar_sesion_guardada()
	Global.reiniciar_estadisticas_partida()
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
