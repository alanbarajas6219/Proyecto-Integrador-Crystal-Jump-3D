extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

@onready var contenedor: VBoxContainer = $ContenedorPuntajes

const COL_WIDTHS := [230.0, 170.0, 230.0, 180.0, 210.0]

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.RANKING)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	mostrar_tabla()

func mostrar_tabla() -> void:
	for child in contenedor.get_children():
		child.queue_free()

	_agregar_encabezado()

	var mejores = Global.obtener_mejores_puntajes()
	if mejores.is_empty():
		var fila_vacia := Label.new()
		fila_vacia.text = "Aún no hay puntajes guardados."
		fila_vacia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fila_vacia.add_theme_font_size_override("font_size", 26)
		contenedor.add_child(fila_vacia)
		UITemplo.estilizar_label(fila_vacia)
		return

	for partida in mejores:
		var nombre := str(partida.get("nombre", "Jugador"))
		var puntos := "%s pts" % str(partida.get("score", 0))
		var tiempo := "%s seg" % str(partida.get("tiempo", 0))
		var dificultad := str(partida.get("dificultad", "normal"))
		var modo := str(partida.get("modo", "individual"))
		_agregar_fila([nombre, puntos, tiempo, dificultad, modo], false)

func _agregar_encabezado() -> void:
	var titulo := Label.new()
	titulo.text = "Resultados guardados"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 30)
	contenedor.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	_agregar_fila(["Jugador", "Puntuación", "Tiempo de partida", "Dificultad", "Modo de juego"], true)

func _agregar_fila(valores: Array, es_encabezado: bool) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(1030, 50)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.07, 0.035, 0.82) if es_encabezado else Color(0.10, 0.055, 0.025, 0.58)
	style.border_color = Color(1.0, 0.72, 0.24, 0.95) if es_encabezado else Color(1.0, 0.72, 0.24, 0.42)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	contenedor.add_child(panel)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)

	for i in range(valores.size()):
		row.add_child(_crear_celda(str(valores[i]), COL_WIDTHS[i], es_encabezado))

func _crear_celda(texto: String, ancho: float, es_encabezado: bool) -> Label:
	var label := Label.new()
	label.text = texto
	label.custom_minimum_size = Vector2(ancho, 42)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 23 if es_encabezado else 22)
	label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.66))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.80))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func _on_menu_principal_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
