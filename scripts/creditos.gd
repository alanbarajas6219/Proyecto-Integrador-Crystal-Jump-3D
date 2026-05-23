extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

func _ready() -> void:
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
	box.offset_top = -315
	box.offset_bottom = 250
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "Créditos"
	titulo.add_theme_font_size_override("font_size", 48)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	var texto = Label.new()
	texto.text = "Crystal Jump Challenge 3D\n\nDesarrollado por:\nAlan Ernesto Barajas Estrada\nJuan Gerardo Vazquez Rodriguez\nOmar Fernando Lopez Maravilla\n\nMotor: Godot Engine 4.6.2\nPlataforma: Web / itch.io\n\nMúsica del menú: https://www.youtube.com/watch?v=BzkJnL96Lhk\nUso académico y demostrativo."
	texto.custom_minimum_size = Vector2(760, 0)
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.add_theme_font_size_override("font_size", 23)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(texto)
	UITemplo.estilizar_label(texto)

	var volver = Button.new()
	volver.text = "Volver al menú"
	volver.custom_minimum_size = Vector2(360, 54)
	box.add_child(volver)
	UITemplo.estilizar_boton(volver)
	volver.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/menu_principal.tscn"))
