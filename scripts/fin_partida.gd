extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
	AudioManager.stop_menu_music()
	GameState.cambiar_estado(GameState.Estado.GAME_OVER)
	UITemplo.aplicar(self)
	AudioManager.play_sfx("gameover")
	_crear_ui()

func _crear_ui() -> void:
	for child in get_children():
		if child.name != "FondoTemplo":
			child.visible = false

	var box = VBoxContainer.new()
	box.name = "PanelFinPartidaContenido"
	box.anchor_left = 0.5
	box.anchor_right = 0.5
	box.anchor_top = 0.5
	box.anchor_bottom = 0.5
	box.offset_left = -390
	box.offset_right = 390
	box.offset_top = -330
	box.offset_bottom = 330
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 11)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "FIN DE LA PARTIDA"
	titulo.custom_minimum_size = Vector2(760, 70)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 48)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	var resumen = Label.new()
	resumen.text = _texto_resumen()
	resumen.custom_minimum_size = Vector2(740, 245)
	resumen.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resumen.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	resumen.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	resumen.add_theme_font_size_override("font_size", 23)
	box.add_child(resumen)
	UITemplo.estilizar_label(resumen)

	box.add_child(_boton("Revancha rápida", _on_revancha_pressed))
	box.add_child(_boton("Cambiar dificultad", _on_cambiar_dificultad))
	box.add_child(_boton("Ranking global local", _on_puntajes_pressed))
	box.add_child(_boton("Volver al menú principal", _on_menu_pricipal_pressed))

func _texto_resumen() -> String:
	if Global.es_multijugador:
		var ganador = "Empate"
		if Global.scoreJ1 > Global.scoreJ2:
			ganador = Global.nombreJ1
		elif Global.scoreJ2 > Global.scoreJ1:
			ganador = Global.nombreJ2
		return "%s: %d pts | %s cristales | %s plataformas\n%s: %d pts | %s cristales | %s plataformas\nGanador: %s\nDificultad alcanzada: %s" % [
			Global.nombreJ1, Global.scoreJ1, Global.cristalesJ1, Global.plataformasJ1,
			Global.nombreJ2, Global.scoreJ2, Global.cristalesJ2, Global.plataformasJ2,
			ganador, Global.api_dificultad]
	return "Puntaje final: %d\nTiempo total: %d seg\nCristales recolectados: %d\nPlataformas superadas: %d\nCaídas: %d\nVidas restantes: %d\nDificultad alcanzada: %s\n¡Inténtalo de nuevo y supera tu récord!" % [Global.scoreJ1, Global.tiempoJ1, Global.cristalesJ1, Global.plataformasJ1, Global.caidasJ1, Global.vidasFinalJ1, Global.dificultad_maxima_j1]

func _boton(texto: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text = texto
	b.custom_minimum_size = Vector2(520, 52)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	UITemplo.estilizar_boton(b)
	b.add_theme_font_size_override("font_size", 25)
	b.pressed.connect(callback)
	return b

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
	Global.reiniciar_estadisticas_partida()
	if Global.es_multijugador:
		get_tree().change_scene_to_file("res://scenes/pantalla_dividida.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/mundo_2.tscn")

func _on_cambiar_dificultad() -> void:
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/seleccion_dificultad.tscn")

func _on_menu_pricipal_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _on_puntajes_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.RANKING)
	get_tree().change_scene_to_file("res://scenes/puntajes.tscn")
