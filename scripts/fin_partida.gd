extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
	AudioManager.stop_menu_music()
	GameState.cambiar_estado(GameState.Estado.GAME_OVER)
	UITemplo.aplicar(self)

	if Global.es_multijugador:
		$Score.text = "%s: %d pts | %s: %d pts" % [Global.nombreJ1, Global.scoreJ1, Global.nombreJ2, Global.scoreJ2]
		var ganador := "Empate"
		if Global.scoreJ1 > Global.scoreJ2:
			ganador = Global.nombreJ1
		elif Global.scoreJ2 > Global.scoreJ1:
			ganador = Global.nombreJ2
		$Tiempo.text = "Ganador: " + ganador
	else:
		$Score.text = "Score final: " + str(Global.scoreJ1)
		$Tiempo.text = "Tiempo total: " + str(Global.tiempoJ1)

	_agregar_boton_revancha()
	AudioManager.play_sfx("success")

func _agregar_boton_revancha() -> void:
	if has_node("Revancha"):
		return

	var revancha := Button.new()
	revancha.name = "Revancha"
	revancha.text = "Revancha / Jugar de nuevo"
	revancha.anchor_left = 0.5
	revancha.anchor_right = 0.5
	revancha.anchor_top = 0.5
	revancha.anchor_bottom = 0.5
	revancha.offset_left = -220
	revancha.offset_right = 220
	revancha.offset_top = 215
	revancha.offset_bottom = 275
	add_child(revancha)
	UITemplo.estilizar_boton(revancha)
	revancha.pressed.connect(_on_revancha_pressed)

func _on_revancha_pressed() -> void:
	AudioManager.play_sfx("button")
	Global.borrar_sesion_guardada()
	Global.j1_vivo = true
	Global.j2_vivo = true
	Global.scoreJ1 = 0
	Global.scoreJ2 = 0
	Global.tiempoJ1 = 0
	Global.tiempoJ2 = 0
	Global.retomar_sesion = false

	if Global.es_multijugador:
		get_tree().change_scene_to_file("res://scenes/pantalla_dividida.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/mundo_2.tscn")

func _on_menu_pricipal_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_puntajes_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.RANKING)
	get_tree().change_scene_to_file("res://scenes/puntajes.tscn")
