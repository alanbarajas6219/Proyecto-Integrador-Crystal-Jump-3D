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
	var titulo := Label.new()
	titulo.text = "Historial individual"
	titulo.anchor_left = 0.5
	titulo.anchor_right = 0.5
	titulo.offset_left = -300
	titulo.offset_right = 300
	titulo.offset_top = 55
	titulo.offset_bottom = 115
	titulo.add_theme_font_size_override("font_size", 48)
	add_child(titulo)
	UITemplo.estilizar_label(titulo)

	_line_edit = LineEdit.new()
	_line_edit.placeholder_text = "Nickname del jugador"
	_line_edit.anchor_left = 0.5
	_line_edit.anchor_right = 0.5
	_line_edit.offset_left = -260
	_line_edit.offset_right = 260
	_line_edit.offset_top = 145
	_line_edit.offset_bottom = 205
	add_child(_line_edit)
	UITemplo.estilizar_line_edit(_line_edit)

	var consultar := Button.new()
	consultar.text = "Consultar"
	consultar.anchor_left = 0.5
	consultar.anchor_right = 0.5
	consultar.offset_left = -180
	consultar.offset_right = 180
	consultar.offset_top = 225
	consultar.offset_bottom = 285
	add_child(consultar)
	UITemplo.estilizar_boton(consultar)
	consultar.pressed.connect(_consultar)

	_resultados = VBoxContainer.new()
	_resultados.anchor_left = 0.5
	_resultados.anchor_right = 0.5
	_resultados.anchor_top = 0.5
	_resultados.anchor_bottom = 0.5
	_resultados.offset_left = -470
	_resultados.offset_right = 470
	_resultados.offset_top = -70
	_resultados.offset_bottom = 280
	_resultados.add_theme_constant_override("separation", 8)
	add_child(_resultados)

	UITemplo.agregar_boton_volver(self, _volver_menu)

func _consultar() -> void:
	AudioManager.play_sfx("button")
	for child in _resultados.get_children():
		child.queue_free()

	var datos: Dictionary = Global.obtener_historial_jugador(_line_edit.text)

	if not bool(datos.get("found", false)):
		_agregar_linea(str(datos.get("message", "Sin información.")))
		return

	_agregar_linea("Jugador: %s" % str(datos["jugador"].get("nombre", "")))
	_agregar_linea("Partidas guardadas: %d | Mejor score: %d" % [int(datos.get("total", 0)), int(datos.get("mejor", 0))])
	_agregar_linea("Últimas partidas:")

	var partidas: Array = datos.get("partidas", [])
	if partidas.is_empty():
		_agregar_linea("No hay partidas registradas.")
	else:
		for p in partidas:
			var row: Dictionary = Dictionary(p)
			_agregar_linea("%s | %s | %s pts | %s seg | %s" % [
				str(row.get("fecha", "")),
				str(row.get("modo", "")),
				str(row.get("score", 0)),
				str(row.get("tiempo", 0)),
				str(row.get("resultado", ""))
			])

func _agregar_linea(texto: String) -> void:
	var label := Label.new()
	label.text = texto
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 23)
	_resultados.add_child(label)
	UITemplo.estilizar_label(label)

func _volver_menu() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
