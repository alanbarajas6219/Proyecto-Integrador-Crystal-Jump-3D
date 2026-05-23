extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var _pause_overlay: Control = null
var _pause_debounce: float = 0.0
var _confirmando_salida: bool = false
var _mensaje: Label = null

func _ready() -> void:
	AudioManager.stop_menu_music()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_crear_menu_pausa_global()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			_toggle_pausa_global()
			get_viewport().set_input_as_handled()

func _crear_menu_pausa_global() -> void:
	_pause_overlay = Control.new()
	_pause_overlay.name = "PausaGlobal"
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.visible = false
	_pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_overlay)
	var fondo = ColorRect.new()
	fondo.color = Color(0.02, 0.01, 0.005, 0.82)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.add_child(fondo)
	var panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -340
	panel.offset_right = 340
	panel.offset_top = -260
	panel.offset_bottom = 260
	_pause_overlay.add_child(panel)
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	var titulo = Label.new()
	titulo.text = "PAUSA"
	titulo.add_theme_font_size_override("font_size", 58)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)
	var subtitulo = Label.new()
	subtitulo.text = "Modo 1 vs 1 pausado"
	subtitulo.add_theme_font_size_override("font_size", 24)
	box.add_child(subtitulo)
	UITemplo.estilizar_label(subtitulo)
	box.add_child(_boton("Continuar", _continuar))
	box.add_child(_boton("Reiniciar partida", _reiniciar))
	box.add_child(_boton("Controles", _controles))
	box.add_child(_boton("Volver al menú principal", _volver_menu_confirmar))
	box.add_child(_boton("Salir a itch.io", _salir_itchio))
	_mensaje = Label.new()
	_mensaje.text = ""
	_mensaje.add_theme_font_size_override("font_size", 22)
	box.add_child(_mensaje)
	UITemplo.estilizar_label(_mensaje)

func _boton(texto: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text = texto
	b.process_mode = Node.PROCESS_MODE_ALWAYS
	UITemplo.estilizar_boton(b)
	b.pressed.connect(callback)
	return b

func _toggle_pausa_global() -> void:
	var now = float(Time.get_ticks_msec()) / 1000.0
	if now - _pause_debounce < 0.25:
		return
	_pause_debounce = now
	if get_tree().paused:
		_continuar()
	else:
		get_tree().paused = true
		_confirmando_salida = false
		GameState.cambiar_estado(GameState.Estado.PAUSA)
		_pause_overlay.visible = true

func _continuar() -> void:
	get_tree().paused = false
	GameState.cambiar_estado(GameState.Estado.JUGANDO)
	_pause_overlay.visible = false

func _reiniciar() -> void:
	get_tree().paused = false
	Global.borrar_sesion_guardada()
	Global.reiniciar_estadisticas_partida()
	get_tree().reload_current_scene()

func _controles() -> void:
	_mensaje.text = "J1: WASD + Espacio | J2: Flechas + Enter | ESC: pausa"

func _volver_menu_confirmar() -> void:
	if not _confirmando_salida:
		_confirmando_salida = true
		_mensaje.text = "Presiona otra vez para confirmar salida. Se perderá el progreso."
		return
	_volver_menu_principal()

func _volver_menu_principal() -> void:
	get_tree().paused = false
	Global.borrar_sesion_guardada()
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")

func _salir_itchio() -> void:
	get_tree().paused = false
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.top.location.href='https://alanbe13.itch.io/crystal-jump-3d';")
	else:
		get_tree().quit()
