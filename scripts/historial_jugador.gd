extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var _line_edit: LineEdit
var _resultados: VBoxContainer

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.HISTORIAL)
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
	box.offset_top = -305
	box.offset_bottom = 255
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "Historial individual"
	titulo.add_theme_font_size_override("font_size", 46)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	_line_edit = LineEdit.new()
	_line_edit.placeholder_text = "Nickname del jugador"
	_line_edit.custom_minimum_size = Vector2(520, 52)
	box.add_child(_line_edit)
	UITemplo.estilizar_line_edit(_line_edit)

	var consultar = Button.new()
	consultar.text = "Consultar"
	consultar.custom_minimum_size = Vector2(300, 54)
	box.add_child(consultar)
	UITemplo.estilizar_boton(consultar)
	consultar.pressed.connect(_consultar)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(760, 290)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.clip_contents = true
	box.add_child(scroll)

	_resultados = VBoxContainer.new()
	_resultados.custom_minimum_size = Vector2(740, 0)
	_resultados.add_theme_constant_override("separation", 10)
	scroll.add_child(_resultados)

	UITemplo.agregar_boton_volver(self, _volver_menu)

func _consultar() -> void:
	AudioManager.play_sfx("button")
	for child in _resultados.get_children():
		child.queue_free()

	var datos: Dictionary = Global.obtener_historial_jugador(_line_edit.text)

	if not bool(datos.get("found", false)):
		_agregar_linea(str(datos.get("message", "Sin información.")), true)
		return

	_agregar_linea("Jugador: %s" % str(datos["jugador"].get("nombre", "")), true)
	_agregar_linea("Partidas guardadas: %d | Mejor puntaje: %d" % [int(datos.get("total", 0)), int(datos.get("mejor", 0))], true)
	_agregar_linea("Últimas partidas:", true)

	var partidas: Array = datos.get("partidas", [])
	if partidas.is_empty():
		_agregar_linea("No hay partidas registradas.")
	else:
		for p in partidas:
			var row: Dictionary = Dictionary(p)
			_agregar_linea("%s | %s | %s pts | %s seg | cristales: %s | plataformas: %s | %s" % [
				str(row.get("fecha", "")),
				str(row.get("modo", "")),
				str(row.get("score", 0)),
				str(row.get("tiempo", 0)),
				str(row.get("cristales", 0)),
				str(row.get("plataformas", 0)),
				str(row.get("resultado", ""))
			])

func _agregar_linea(texto: String, destacado: bool = false) -> void:
	var label = Label.new()
	label.text = texto
	label.custom_minimum_size = Vector2(730, 36)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 24 if destacado else 20)
	_resultados.add_child(label)
	UITemplo.estilizar_label(label)

func _volver_menu() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
