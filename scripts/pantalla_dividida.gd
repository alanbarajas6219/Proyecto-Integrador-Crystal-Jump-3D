extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var _pause_overlay: Control = null
var _pause_debounce: float = 0.0

func _ready() -> void:
	AudioManager.stop_menu_music()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_crear_menu_pausa_global()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			_toggle_pausa_global()
			get_viewport().set_input_as_handled()

func _crear_menu_pausa_global() -> void:
	if _pause_overlay != null:
		return

	_pause_overlay = Control.new()
	_pause_overlay.name = "PausaGlobal"
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.visible = false
	_pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_overlay)

	var fondo := ColorRect.new()
	fondo.name = "FondoOscuro"
	fondo.color = Color(0.02, 0.01, 0.005, 0.78)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_overlay.add_child(fondo)

	var panel := PanelContainer.new()
	panel.name = "PanelPausa"
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -330.0
	panel.offset_right = 330.0
	panel.offset_top = -205.0
	panel.offset_bottom = 205.0
	_pause_overlay.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.08, 0.04, 0.96)
	style.border_color = Color(1.0, 0.74, 0.28)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	style.shadow_size = 18
	style.shadow_color = Color(0, 0, 0, 0.55)
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.process_mode = Node.PROCESS_MODE_ALWAYS
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.process_mode = Node.PROCESS_MODE_ALWAYS
	box.add_theme_constant_override("separation", 20)
	margin.add_child(box)

	var titulo := Label.new()
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.process_mode = Node.PROCESS_MODE_ALWAYS
	titulo.add_theme_font_size_override("font_size", 58)
	titulo.add_theme_color_override("font_color", Color(1.0, 0.91, 0.66))
	box.add_child(titulo)

	var subtitulo := Label.new()
	subtitulo.text = "Modo 1 vs 1 pausado"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.process_mode = Node.PROCESS_MODE_ALWAYS
	subtitulo.add_theme_font_size_override("font_size", 24)
	subtitulo.add_theme_color_override("font_color", Color(1.0, 0.82, 0.48))
	box.add_child(subtitulo)

	var continuar := Button.new()
	continuar.text = "Continuar"
	continuar.process_mode = Node.PROCESS_MODE_ALWAYS
	box.add_child(continuar)
	UITemplo.estilizar_boton(continuar)
	continuar.pressed.connect(_continuar)

	var menu := Button.new()
	menu.text = "Volver al menú principal"
	menu.process_mode = Node.PROCESS_MODE_ALWAYS
	box.add_child(menu)
	UITemplo.estilizar_boton(menu)
	menu.pressed.connect(_volver_menu_principal)

func _toggle_pausa_global() -> void:
	var now := float(Time.get_ticks_msec()) / 1000.0
	if now - _pause_debounce < 0.25:
		return
	_pause_debounce = now

	if get_tree().paused:
		_continuar()
	else:
		get_tree().paused = true
		GameState.cambiar_estado(GameState.Estado.PAUSA)
		if _pause_overlay != null:
			_pause_overlay.visible = true

func _continuar() -> void:
	get_tree().paused = false
	GameState.cambiar_estado(GameState.Estado.JUGANDO)
	if _pause_overlay != null:
		_pause_overlay.visible = false

func _volver_menu_principal() -> void:
	get_tree().paused = false
	Global.borrar_sesion_guardada()
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
