extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
	GameState.cambiar_estado(GameState.Estado.MENU)
	UITemplo.aplicar(self)
	AudioManager.play_menu_music()
	_crear_menu()

func _crear_menu() -> void:
	for child in get_children():
		if child.name != "FondoTemplo":
			child.visible = false

	# En el menú principal usamos el logo integrado en la nueva imagen de fondo.
	var panel_fondo = get_node_or_null("FondoTemplo/PanelCristalCentral")
	if panel_fondo != null:
		panel_fondo.visible = false

	var panel = VBoxContainer.new()
	panel.name = "PanelMenuPrincipal"
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -290
	panel.offset_right = 290
	panel.offset_top = 80
	panel.offset_bottom = 410
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 16)
	add_child(panel)

	panel.add_child(_crear_boton("JUGAR", _on_jugar_pressed, true))
	panel.add_child(_crear_boton("Ranking global local", _on_puntajes_pressed, false))
	panel.add_child(_crear_boton("Historial individual", _on_historial_pressed, false))
	panel.add_child(_crear_boton("Configuración", _on_configuracion_pressed, false))
	panel.add_child(_crear_boton("Créditos", _on_creditos_pressed, false))

func _crear_boton(texto: String, callback: Callable, principal: bool) -> Button:
	var button = Button.new()
	button.text = texto
	button.custom_minimum_size = Vector2(390 if principal else 335, 68 if principal else 58)
	button.pressed.connect(callback)
	UITemplo.estilizar_boton(button)
	if principal:
		var st = button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
		st.bg_color = Color(0.04, 0.56, 1.0, 0.98)
		st.border_color = Color(1.0, 0.82, 0.25, 1.0)
		st.shadow_size = 20
		st.shadow_color = Color(0.0, 0.9, 1.0, 0.48)
		button.add_theme_stylebox_override("normal", st)
		button.add_theme_font_size_override("font_size", 38)
	return button

func _on_jugar_pressed() -> void:
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/seleccion_modo.tscn")

func _on_puntajes_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.RANKING)
	get_tree().change_scene_to_file("res://scenes/puntajes.tscn")

func _on_historial_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.HISTORIAL)
	get_tree().change_scene_to_file("res://scenes/historial_jugador.tscn")

func _on_configuracion_pressed() -> void:
	AudioManager.play_sfx("button")
	GameState.cambiar_estado(GameState.Estado.CONFIGURACION)
	get_tree().change_scene_to_file("res://scenes/configuracion.tscn")

func _on_creditos_pressed() -> void:
	AudioManager.play_sfx("button")
	get_tree().change_scene_to_file("res://scenes/creditos.tscn")
