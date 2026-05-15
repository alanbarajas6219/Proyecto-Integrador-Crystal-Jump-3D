extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var time: int
var vidas: int
var score: int
var player_id: int = 1
var api_config: Dictionary = {}
var _pause_menu: Control = null
var _best_platform_index: int = 0
var _last_autosave_time: int = 0
var _loading_label: Label = null

signal pausar

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	time = 0
	vidas = 3
	score = 0
	_best_platform_index = 0
	_last_autosave_time = 0
	add_to_group("HUD")
	_actualizar_textos()
	_crear_label_carga()
	_crear_menu_pausa()

func configurar_jugador(id_jugador: int) -> void:
	player_id = id_jugador

	if Global.retomar_sesion and not Global.sesion_cargada.is_empty():
		if player_id == 1:
			score = int(Global.sesion_cargada.get("score_j1", 0))
			time = int(Global.sesion_cargada.get("tiempo_j1", 0))
			vidas = int(Global.sesion_cargada.get("vidas_j1", 3))
			_best_platform_index = int(Global.sesion_cargada.get("plataformas_j1", 0))
		else:
			score = int(Global.sesion_cargada.get("score_j2", 0))
			time = int(Global.sesion_cargada.get("tiempo_j2", 0))
			vidas = int(Global.sesion_cargada.get("vidas_j2", 3))
			_best_platform_index = int(Global.sesion_cargada.get("plataformas_j2", 0))

	_actualizar_textos()
	_guardar_sesion()

func _unhandled_input(event: InputEvent) -> void:
	if Global.es_multijugador:
		return

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			_toggle_pausa()

func set_api_config(config: Dictionary) -> void:
	api_config = config
	_actualizar_textos()

func mostrar_carga(texto: String) -> void:
	if _loading_label != null:
		_loading_label.text = texto
		_loading_label.visible = true

func ocultar_carga() -> void:
	if _loading_label != null:
		_loading_label.visible = false

func mostrar_mensaje(texto: String) -> void:
	if _loading_label != null:
		_loading_label.text = texto
		_loading_label.visible = true
		await get_tree().create_timer(1.5).timeout
		if is_instance_valid(_loading_label):
			_loading_label.visible = false

func _crear_label_carga() -> void:
	if _loading_label != null:
		return
	_loading_label = Label.new()
	_loading_label.name = "IndicadorCarga"
	_loading_label.text = ""
	_loading_label.visible = false
	_loading_label.position = Vector2(30, 268)
	_loading_label.add_theme_font_size_override("font_size", 22)
	_loading_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	add_child(_loading_label)

func _on_timer_timeout() -> void:
	if get_tree().paused:
		return
	time += 1
	_actualizar_textos()

	if time - _last_autosave_time >= 30:
		_guardar_sesion()
		_last_autosave_time = time
		mostrar_mensaje("Guardando progreso...")

func restarVidas() -> void:
	if get_tree().paused:
		return

	if vidas <= 0:
		vidas = 0
		_actualizar_textos()
		_desactivar_player()
		return

	vidas -= 1
	if vidas < 0:
		vidas = 0

	AudioManager.play_sfx("damage")
	_actualizar_textos()
	_guardar_sesion()

	if vidas > 0:
		return

	_desactivar_player()

	if Global.es_multijugador == false:
		Global.setScoreTiempo(score, time, 0, 0)
		Global.finalizar_partida()
		GameState.cambiar_estado(GameState.Estado.GAME_OVER)
		get_tree().change_scene_to_file("res://scenes/fin_partida.tscn")
	else:
		if player_id == 1:
			Global.j1_vivo = false
			Global.scoreJ1 = score
			Global.tiempoJ1 = time
		else:
			Global.j2_vivo = false
			Global.scoreJ2 = score
			Global.tiempoJ2 = time

		pausar.emit()
		process_mode = PROCESS_MODE_DISABLED
		comprobar_final_total()

func _desactivar_player() -> void:
	var mundo := get_parent()
	if mundo != null and mundo.has_node("player"):
		var player := mundo.get_node("player")
		if player is CharacterBody3D:
			player.velocity = Vector3.ZERO
			player.set_physics_process(false)
			player.set_process(false)

func comprobar_final_total() -> void:
	if Global.es_multijugador:
		if not Global.j1_vivo and not Global.j2_vivo:
			Global.finalizar_partida()
			GameState.cambiar_estado(GameState.Estado.GAME_OVER)
			get_tree().change_scene_to_file("res://scenes/fin_partida.tscn")

func plataformaAvanzada(platform_index: int) -> void:
	if get_tree().paused:
		return

	if platform_index > _best_platform_index:
		_best_platform_index = platform_index
		score += 2
		_actualizar_textos()
		_guardar_sesion()

func cristalTomado() -> void:
	if get_tree().paused:
		return
	score += 4
	AudioManager.play_sfx("crystal")
	_actualizar_textos()
	_guardar_sesion()

func _guardar_sesion() -> void:
	Global.guardar_estado_sesion(player_id, score, time, vidas, _best_platform_index)

func _actualizar_textos() -> void:
	if has_node("Tiempo"):
		$Tiempo.text = "Tiempo: " + str(time)
	if has_node("Score"):
		$Score.text = "Score: " + str(score)
	if has_node("Vidas"):
		$Vidas.text = "Vidas: " + str(vidas)
	if has_node("Dificultad"):
		$Dificultad.text = "Dificultad: " + str(api_config.get("dificultad", Global.api_dificultad))

func _crear_menu_pausa() -> void:
	if _pause_menu != null:
		return

	_pause_menu = Control.new()
	_pause_menu.name = "MenuPausa"
	_pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_menu.visible = false
	_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_menu)

	var fondo := ColorRect.new()
	fondo.color = Color(0.02, 0.01, 0.005, 0.72)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_menu.add_child(fondo)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 320)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -260
	panel.offset_right = 260
	panel.offset_top = -160
	panel.offset_bottom = 160
	_pause_menu.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.08, 0.04, 0.96)
	style.border_color = Color(1.0, 0.74, 0.28)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.shadow_size = 14
	style.shadow_color = Color(0, 0, 0, 0.45)
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	var titulo := Label.new()
	titulo.text = "PAUSA"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 44)
	titulo.add_theme_color_override("font_color", Color(1.0, 0.91, 0.66))
	box.add_child(titulo)

	var continuar := Button.new()
	continuar.text = "Continuar"
	box.add_child(continuar)
	UITemplo.estilizar_boton(continuar)
	continuar.pressed.connect(_reanudar)

	var menu := Button.new()
	menu.text = "Volver al menú principal"
	box.add_child(menu)
	UITemplo.estilizar_boton(menu)
	menu.pressed.connect(_volver_menu)

func _toggle_pausa() -> void:
	if _pause_menu == null:
		_crear_menu_pausa()
	if get_tree().paused:
		_reanudar()
	else:
		get_tree().paused = true
		_pause_menu.visible = true
		GameState.cambiar_estado(GameState.Estado.PAUSA)

func _reanudar() -> void:
	get_tree().paused = false
	if _pause_menu != null:
		_pause_menu.visible = false
	GameState.cambiar_estado(GameState.Estado.JUGANDO)

func _volver_menu() -> void:
	get_tree().paused = false
	Global.borrar_sesion_guardada()
	GameState.cambiar_estado(GameState.Estado.MENU)
	get_tree().change_scene_to_file("res://scenes/menu_principal.tscn")
