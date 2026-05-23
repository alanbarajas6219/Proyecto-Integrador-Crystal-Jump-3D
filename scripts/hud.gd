extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")
const ICON_TIME: Texture2D = preload("res://assets/ui/icon_time.png")
const ICON_CRYSTAL: Texture2D = preload("res://assets/ui/icon_crystal.png")
const HEART_FULL: Texture2D = preload("res://assets/ui/heart_full.png")
const HEART_EMPTY: Texture2D = preload("res://assets/ui/heart_empty.png")

var time: int
var vidas: int
var score: int
var player_id: int = 1
var api_config: Dictionary = {}
var _pause_menu: Control = null
var _best_platform_index: int = 0
var _last_autosave_time: int = 0
var _loading_label: Label = null
var _feedback_platform_label: Label = null
var _feedback_score_label: Label = null
var _powerup_label: Label = null
var _cristales: int = 0
var _caidas: int = 0
var _confirmando_salida: bool = false
var _feedback_platform_version: int = 0
var _feedback_score_version: int = 0
var _powerup_remaining: float = 0.0
var _heart_icons: Array[TextureRect] = []
var _score_icon: TextureRect = null
var _time_icon: TextureRect = null

signal pausar

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	time = 0
	vidas = 3
	score = 0
	_best_platform_index = 0
	_last_autosave_time = 0
	_cristales = 0
	_caidas = 0
	add_to_group("HUD")
	_crear_iconos_hud()
	_actualizar_textos()
	_crear_label_carga()
	_crear_feedback_label()
	_crear_powerup_label()
	_crear_menu_pausa()

func _process(delta: float) -> void:
	if not get_tree().paused and _powerup_remaining > 0.0:
		_powerup_remaining = maxf(_powerup_remaining - delta, 0.0)
	_actualizar_powerup_label()

func _crear_iconos_hud() -> void:
	# Reacomodo de HUD con iconos para que se vea más profesional en itch.io.
	if has_node("Score"):
		$Score.offset_left = 74
		$Score.offset_top = 10
		$Score.offset_right = 360
		$Score.offset_bottom = 58
		$Score.add_theme_font_size_override("font_size", 30)
	if has_node("Tiempo"):
		$Tiempo.offset_left = 74
		$Tiempo.offset_top = 64
		$Tiempo.offset_right = 340
		$Tiempo.offset_bottom = 112
		$Tiempo.add_theme_font_size_override("font_size", 30)
	if has_node("Vidas"):
		$Vidas.text = ""
		$Vidas.visible = false
	if has_node("Dificultad"):
		$Dificultad.offset_left = 28
		$Dificultad.offset_top = 180
		$Dificultad.offset_right = 520
		$Dificultad.offset_bottom = 330
		$Dificultad.add_theme_font_size_override("font_size", 22)

	_score_icon = _crear_icono_hud(ICON_CRYSTAL, Vector2(24, 13), Vector2(42, 42))
	_time_icon = _crear_icono_hud(ICON_TIME, Vector2(24, 65), Vector2(42, 42))

	_heart_icons.clear()
	for i in range(3):
		var heart = _crear_icono_hud(HEART_FULL, Vector2(28 + i * 46, 123), Vector2(40, 40))
		_heart_icons.append(heart)


func _crear_icono_hud(texture: Texture2D, pos: Vector2, size: Vector2) -> TextureRect:
	var icon = TextureRect.new()
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = pos
	icon.size = size
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon)
	return icon

func _actualizar_iconos_hud() -> void:
	for i in range(_heart_icons.size()):
		_heart_icons[i].texture = HEART_FULL if i < vidas else HEART_EMPTY


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
	_sincronizar_global()
	_guardar_sesion()

func _unhandled_input(event: InputEvent) -> void:
	if Global.es_multijugador:
		return
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			_toggle_pausa()

func set_api_config(config: Dictionary) -> void:
	api_config = config
	_actualizar_textos()
	_sincronizar_global()

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
		await get_tree().create_timer(2.2).timeout
		if is_instance_valid(_loading_label):
			_loading_label.visible = false

func mostrar_feedback(texto: String, color: Color = Color(1.0, 0.92, 0.35), duration: float = 1.55, es_plataforma: bool = false) -> void:
	if es_plataforma:
		mostrar_feedback_plataforma(texto, color, duration)
	else:
		mostrar_feedback_puntaje(texto, color, duration)

func mostrar_feedback_plataforma(texto: String, color: Color = Color(0.45, 0.95, 1.0), duration: float = 1.60) -> void:
	await _mostrar_feedback_en_label(_feedback_platform_label, texto, color, duration, true)

func mostrar_feedback_puntaje(texto: String, color: Color = Color(1.0, 0.92, 0.35), duration: float = 1.95) -> void:
	await _mostrar_feedback_en_label(_feedback_score_label, texto, color, duration, false)

func _mostrar_feedback_en_label(label: Label, texto: String, color: Color, duration: float, es_plataforma: bool) -> void:
	if label == null:
		return
	if es_plataforma:
		_feedback_platform_version += 1
	else:
		_feedback_score_version += 1
	var version_local: int = _feedback_platform_version if es_plataforma else _feedback_score_version
	label.text = texto
	label.add_theme_color_override("font_color", color)
	label.visible = true
	label.modulate = Color(1, 1, 1, 1)
	label.position.y = 54.0 if es_plataforma else 112.0
	var tween = create_tween()
	tween.tween_property(label, "position:y", 44.0 if es_plataforma else 102.0, 0.20)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 0.10)
	await get_tree().create_timer(duration).timeout
	if not is_instance_valid(label):
		return
	if es_plataforma and version_local != _feedback_platform_version:
		return
	if not es_plataforma and version_local != _feedback_score_version:
		return
	var fade = create_tween()
	fade.tween_property(label, "modulate:a", 0.0, 0.38)
	await fade.finished
	if not is_instance_valid(label):
		return
	if es_plataforma and version_local == _feedback_platform_version:
		label.visible = false
	elif not es_plataforma and version_local == _feedback_score_version:
		label.visible = false

func _crear_label_carga() -> void:
	_loading_label = Label.new()
	_loading_label.name = "IndicadorCarga"
	_loading_label.text = ""
	_loading_label.visible = false
	_loading_label.anchor_left = 0.5
	_loading_label.anchor_right = 0.5
	_loading_label.offset_left = -420
	_loading_label.offset_right = 420
	_loading_label.offset_top = 16
	_loading_label.offset_bottom = 54
	_loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loading_label.add_theme_font_size_override("font_size", 22)
	_loading_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	_loading_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.82))
	_loading_label.add_theme_constant_override("shadow_offset_x", 2)
	_loading_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(_loading_label)

func _crear_feedback_label() -> void:
	_feedback_platform_label = _crear_feedback_label_unico("AvisoPlataforma", 54.0, 39)
	_feedback_score_label = _crear_feedback_label_unico("AvisoPuntaje", 112.0, 35)
	add_child(_feedback_platform_label)
	add_child(_feedback_score_label)

func _crear_feedback_label_unico(nombre: String, y: float, font_size: int) -> Label:
	var label = Label.new()
	label.name = nombre
	label.visible = false
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.offset_left = -560
	label.offset_right = 560
	label.offset_top = y
	label.offset_bottom = y + 56
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.92))
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.08, 0.96))
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	return label

func _crear_powerup_label() -> void:
	_powerup_label = Label.new()
	_powerup_label.name = "PowerupTimer"
	_powerup_label.visible = false
	_powerup_label.anchor_left = 1.0
	_powerup_label.anchor_right = 1.0
	_powerup_label.offset_left = -350
	_powerup_label.offset_right = -22
	_powerup_label.offset_top = 22
	_powerup_label.offset_bottom = 68
	_powerup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_powerup_label.add_theme_font_size_override("font_size", 26)
	_powerup_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.35))
	_powerup_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.88))
	_powerup_label.add_theme_color_override("font_outline_color", Color(0.07, 0.02, 0.02, 0.95))
	_powerup_label.add_theme_constant_override("outline_size", 4)
	_powerup_label.add_theme_constant_override("shadow_offset_x", 2)
	_powerup_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(_powerup_label)

func _actualizar_powerup_label() -> void:
	if _powerup_label == null:
		return
	if _powerup_remaining <= 0.0:
		_powerup_label.visible = false
		return
	_powerup_label.visible = true
	_powerup_label.text = "Doble salto: %.1f s" % _powerup_remaining

func _on_timer_timeout() -> void:
	if get_tree().paused:
		return
	time += 1
	_actualizar_textos()
	_sincronizar_global()
	if time - _last_autosave_time >= 30:
		_guardar_sesion()
		_last_autosave_time = time
		mostrar_mensaje("Guardando progreso...")

func restarVidas() -> void:
	if get_tree().paused:
		return
	_caidas += 1
	if vidas <= 0:
		vidas = 0
		_actualizar_textos()
		_desactivar_player()
		return
	vidas -= 1
	if vidas < 0:
		vidas = 0
	AudioManager.play_sfx("damage")
	mostrar_feedback_puntaje("Caída -1 vida", Color(1.0, 0.25, 0.20), 1.80)
	_actualizar_textos()
	_sincronizar_global()
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
	var mundo = get_parent()
	if mundo != null and mundo.has_node("player"):
		var player = mundo.get_node("player")
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
		mostrar_feedback_plataforma("Plataforma %d  •  +2 puntos" % _best_platform_index, Color(0.45, 0.95, 1.0), 1.45)
		if _best_platform_index > 0 and _best_platform_index % 50 == 0 and _best_platform_index <= 500000:
			score += 15
			AudioManager.play_sfx("milestone")
			mostrar_feedback_plataforma("¡Llegaste a la plataforma %d!" % _best_platform_index, Color(1.0, 0.90, 0.28), 1.95)
			mostrar_feedback_puntaje("Bono de plataforma  +15 puntos", Color(1.0, 0.35, 0.95), 2.15)
		_actualizar_textos()
		_sincronizar_global()
		_guardar_sesion()

func cristalTomado(tipo: String = "verde", puntos: int = 4, body: Node = null) -> void:
	if get_tree().paused:
		return
	if tipo == "rojo":
		if body != null and body.has_method("activar_doble_salto"):
			body.activar_doble_salto(15.0)
		_powerup_remaining = 15.0
		mostrar_feedback_puntaje("Power-up rojo: doble salto por 15 s", Color(1.0, 0.18, 0.18), 2.10)
		AudioManager.play_sfx("powerup")
	else:
		_cristales += 1
		score += puntos
		var color = Color(0.5, 1.0, 0.35) if tipo == "verde" else Color(0.85, 0.35, 1.0)
		mostrar_feedback_puntaje("Cristal %s  •  +%d puntos" % [tipo, puntos], color, 2.00)
		AudioManager.play_sfx("crystal")
	_actualizar_textos()
	_sincronizar_global()
	_guardar_sesion()

func _guardar_sesion() -> void:
	Global.guardar_estado_sesion(player_id, score, time, vidas, _best_platform_index)

func _sincronizar_global() -> void:
	Global.actualizar_stats_jugador(player_id, _cristales, _best_platform_index, _caidas, vidas, str(api_config.get("dificultad", Global.api_dificultad)))
	if player_id == 1:
		Global.scoreJ1 = score
		Global.tiempoJ1 = time
	else:
		Global.scoreJ2 = score
		Global.tiempoJ2 = time

func _actualizar_textos() -> void:
	if has_node("Tiempo"):
		$Tiempo.text = "Tiempo: " + str(time)
	if has_node("Score"):
		$Score.text = "Puntaje: " + str(score)
	if has_node("Vidas"):
		$Vidas.text = ""
		$Vidas.visible = false
	if has_node("Dificultad"):
		$Dificultad.text = "Dificultad: %s\nPlataformas: %d\nCristales: %d" % [str(api_config.get("dificultad", Global.api_dificultad)), _best_platform_index, _cristales]
	_actualizar_iconos_hud()

func _crear_menu_pausa() -> void:
	if _pause_menu != null:
		return
	_pause_menu = Control.new()
	_pause_menu.name = "MenuPausa"
	_pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_menu.visible = false
	_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_menu)
	var fondo = ColorRect.new()
	fondo.color = Color(0.02, 0.01, 0.005, 0.78)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_menu.add_child(fondo)
	var panel = PanelContainer.new()
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -310
	panel.offset_right = 310
	panel.offset_top = -230
	panel.offset_bottom = 230
	_pause_menu.add_child(panel)
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var titulo = Label.new()
	titulo.text = "PAUSA"
	titulo.add_theme_font_size_override("font_size", 44)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)
	box.add_child(_crear_boton_pausa("Continuar", _reanudar))
	box.add_child(_crear_boton_pausa("Reiniciar partida", _reiniciar_partida))
	box.add_child(_crear_boton_pausa("Controles", _mostrar_controles))
	box.add_child(_crear_boton_pausa("Volver al menú principal", _volver_menu_confirmar))
	box.add_child(_crear_boton_pausa("Salir a itch.io", _salir_itchio))

func _crear_boton_pausa(texto: String, callback: Callable) -> Button:
	var b = Button.new()
	b.text = texto
	b.process_mode = Node.PROCESS_MODE_ALWAYS
	UITemplo.estilizar_boton(b)
	b.pressed.connect(callback)
	return b

func _toggle_pausa() -> void:
	if _pause_menu == null:
		_crear_menu_pausa()
	if get_tree().paused:
		_reanudar()
	else:
		get_tree().paused = true
		_confirmando_salida = false
		_pause_menu.visible = true
		GameState.cambiar_estado(GameState.Estado.PAUSA)

func _reanudar() -> void:
	get_tree().paused = false
	if _pause_menu != null:
		_pause_menu.visible = false
	GameState.cambiar_estado(GameState.Estado.JUGANDO)

func _reiniciar_partida() -> void:
	get_tree().paused = false
	Global.borrar_sesion_guardada()
	Global.reiniciar_estadisticas_partida()
	get_tree().reload_current_scene()

func _mostrar_controles() -> void:
	mostrar_mensaje("Controles: WASD + Espacio. En 2 jugadores: flechas + Enter.")

func _volver_menu_confirmar() -> void:
	if not _confirmando_salida:
		_confirmando_salida = true
		mostrar_mensaje("Presiona otra vez para confirmar salida. Se perderá el progreso.")
		return
	_volver_menu()

func _volver_menu() -> void:
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
