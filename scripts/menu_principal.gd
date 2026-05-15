extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var _extra_buttons: Array[Button] = []

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.MENU)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_configurar_menu()

func _configurar_menu() -> void:
	# Reacomoda botones existentes y agrega opciones que pide la rúbrica:
	# continuar sesión, historial individual y configuración.
	var botones: Array[Button] = []

	if Global.existe_sesion_guardada():
		var continuar := _crear_boton_extra("Continuar sesión guardada", _on_continuar_sesion_pressed)
		botones.append(continuar)

	if has_node("1jugador"):
		botones.append(get_node("1jugador") as Button)
	if has_node("2jugador"):
		botones.append(get_node("2jugador") as Button)
	if has_node("Puntajes"):
		botones.append(get_node("Puntajes") as Button)

	var historial := _crear_boton_extra("Historial individual", _on_historial_pressed)
	var config := _crear_boton_extra("Configuración", _on_configuracion_pressed)
	botones.append(historial)
	botones.append(config)

	for i in range(botones.size()):
		var b: Button = botones[i]
		b.anchor_left = 0.5
		b.anchor_right = 0.5
		b.anchor_top = 0.5
		b.anchor_bottom = 0.5
		b.offset_left = -185
		b.offset_right = 185
		b.offset_top = -95 + i * 70
		b.offset_bottom = -37 + i * 70
		b.grow_horizontal = Control.GROW_DIRECTION_BOTH
		b.grow_vertical = Control.GROW_DIRECTION_BOTH
		UITemplo.estilizar_boton(b)

func _crear_boton_extra(texto: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = texto
	button.name = texto.replace(" ", "_")
	add_child(button)
	button.pressed.connect(callback)
	_extra_buttons.append(button)
	return button

func _on_jugador_pressed() -> void:
	AudioManager.play_sfx("button")
	Global.borrar_sesion_guardada()
	Global.es_multijugador = false
	Global.j1_vivo = true
	Global.j2_vivo = true
	Global.retomar_sesion = false
	GameState.cambiar_estado(GameState.Estado.REGISTRO)
	get_tree().change_scene_to_file("res://scenes/ingresar_nombre.tscn")

func _on_puntajes_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.RANKING)
	get_tree().change_scene_to_file("res://scenes/puntajes.tscn")

func _on_2jugador_pressed() -> void:
	AudioManager.play_sfx("button")
	Global.borrar_sesion_guardada()
	Global.es_multijugador = true
	Global.j1_vivo = true
	Global.j2_vivo = true
	Global.retomar_sesion = false
	GameState.cambiar_estado(GameState.Estado.REGISTRO)
	get_tree().change_scene_to_file("res://scenes/ingresar_nombre_multi.tscn")

func _on_historial_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.HISTORIAL)
	get_tree().change_scene_to_file("res://scenes/historial_jugador.tscn")

func _on_configuracion_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.CONFIGURACION)
	get_tree().change_scene_to_file("res://scenes/configuracion.tscn")

func _on_continuar_sesion_pressed() -> void:
	AudioManager.play_sfx("button")
	if not Global.cargar_sesion_en_memoria():
		return

	GameState.cambiar_estado(GameState.Estado.CARGANDO_API)

	if Global.es_multijugador:
		get_tree().change_scene_to_file("res://scenes/pantalla_dividida.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/mundo_2.tscn")
