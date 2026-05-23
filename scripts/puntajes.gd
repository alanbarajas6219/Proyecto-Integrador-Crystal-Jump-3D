extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

@onready var titulo_principal: Label = $Label
@onready var contenedor: VBoxContainer = $ContenedorPuntajes
@onready var boton_volver: Button = $menuPrincipal

const COL_WIDTHS = [95.0, 110.0, 88.0, 90.0, 102.0, 102.0, 96.0, 150.0]

var _scroll: ScrollContainer
var _tabla_box: VBoxContainer

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.RANKING)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_preparar_layout()
	mostrar_tabla()

func _preparar_layout() -> void:
	titulo_principal.anchor_left = 0.5
	titulo_principal.anchor_right = 0.5
	titulo_principal.offset_left = -360
	titulo_principal.offset_right = 360
	titulo_principal.offset_top = 26
	titulo_principal.offset_bottom = 88
	titulo_principal.add_theme_font_size_override("font_size", 44)
	UITemplo.estilizar_label(titulo_principal)

	contenedor.anchor_left = 0.5
	contenedor.anchor_right = 0.5
	contenedor.anchor_top = 0.5
	contenedor.anchor_bottom = 0.5
	contenedor.offset_left = -430
	contenedor.offset_right = 430
	contenedor.offset_top = -300
	contenedor.offset_bottom = 300
	contenedor.alignment = BoxContainer.ALIGNMENT_BEGIN
	contenedor.add_theme_constant_override("separation", 10)

	for child in contenedor.get_children():
		child.queue_free()

	var subtitulo = Label.new()
	subtitulo.text = "Ranking global local"
	subtitulo.custom_minimum_size = Vector2(860, 44)
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_font_size_override("font_size", 32)
	contenedor.add_child(subtitulo)
	UITemplo.estilizar_label(subtitulo)

	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll.custom_minimum_size = Vector2(860, 470)
	_scroll.clip_contents = true
	contenedor.add_child(_scroll)

	_tabla_box = VBoxContainer.new()
	_tabla_box.custom_minimum_size = Vector2(860, 0)
	_tabla_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_tabla_box.add_theme_constant_override("separation", 6)
	_scroll.add_child(_tabla_box)

	boton_volver.anchor_left = 0.5
	boton_volver.anchor_right = 0.5
	boton_volver.anchor_top = 1.0
	boton_volver.anchor_bottom = 1.0
	boton_volver.offset_left = -180
	boton_volver.offset_right = 180
	boton_volver.offset_top = -150
	boton_volver.offset_bottom = -92
	boton_volver.custom_minimum_size = Vector2(320, 56)
	UITemplo.estilizar_boton(boton_volver)

func mostrar_tabla() -> void:
	for child in _tabla_box.get_children():
		child.queue_free()
	_agregar_fila(["Jugador", "Puntaje", "Tiempo", "Cristales", "Plataf.", "Dific.", "Modo", "Fecha"], true)
	var mejores = Global.obtener_mejores_puntajes()
	if mejores.is_empty():
		_agregar_linea_vacia("Aún no hay resultados guardados.")
		return
	for partida in mejores:
		var row = Dictionary(partida)
		_agregar_fila([
			str(row.get("nombre", "Jugador")),
			"%s pts" % str(row.get("score", 0)),
			"%s s" % str(row.get("tiempo", 0)),
			str(row.get("cristales", 0)),
			str(row.get("plataformas", 0)),
			str(row.get("dificultad_maxima", row.get("dificultad", "normal"))),
			str(row.get("modo", "individual")),
			str(row.get("fecha", ""))
		], false)

func _agregar_linea_vacia(texto: String) -> void:
	var fila_vacia = Label.new()
	fila_vacia.text = texto
	fila_vacia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fila_vacia.custom_minimum_size = Vector2(840, 50)
	fila_vacia.add_theme_font_size_override("font_size", 24)
	_tabla_box.add_child(fila_vacia)
	UITemplo.estilizar_label(fila_vacia)

func _agregar_fila(valores: Array, es_encabezado: bool) -> void:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(850, 48 if es_encabezado else 44)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.08, 0.04, 0.88) if es_encabezado else Color(0.07, 0.09, 0.14, 0.62)
	style.border_color = Color(1.0, 0.76, 0.26, 0.95) if es_encabezado else Color(0.28, 0.88, 1.0, 0.40)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	_tabla_box.add_child(panel)

	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 4)
	panel.add_child(row)

	for i in range(valores.size()):
		row.add_child(_crear_celda(str(valores[i]), COL_WIDTHS[i], es_encabezado))

func _crear_celda(texto: String, ancho: float, es_encabezado: bool) -> Label:
	var label = Label.new()
	label.text = texto
	label.custom_minimum_size = Vector2(ancho, 38)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.add_theme_font_size_override("font_size", 17 if es_encabezado else 16)
	label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.76) if es_encabezado else Color(0.93, 0.97, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.80))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	return label

func _on_menu_principal_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
