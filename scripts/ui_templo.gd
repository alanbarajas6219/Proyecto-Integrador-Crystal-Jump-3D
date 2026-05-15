extends RefCounted
class_name UITemplo

static func aplicar(root: Control) -> void:
	crear_fondo(root)
	estilizar_recursivo(root)

static func crear_fondo(root: Control) -> void:
	if root.has_node("FondoTemplo"):
		return

	var fondo := ColorRect.new()
	fondo.name = "FondoTemplo"
	fondo.color = Color(0.13, 0.08, 0.04)
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(fondo)
	root.move_child(fondo, 0)

	var brillo := ColorRect.new()
	brillo.name = "BrilloDorado"
	brillo.color = Color(0.95, 0.58, 0.22, 0.18)
	brillo.anchor_left = 0.18
	brillo.anchor_right = 0.82
	brillo.anchor_top = 0.0
	brillo.anchor_bottom = 1.0
	fondo.add_child(brillo)

	for i in range(9):
		var columna := ColorRect.new()
		columna.color = Color(0.42, 0.31, 0.18, 0.70)
		columna.size = Vector2(42, 540)
		columna.position = Vector2(40 + i * 155, 80 + (i % 2) * 35)
		fondo.add_child(columna)

	for i in range(22):
		var piedra := ColorRect.new()
		piedra.color = Color(0.58, 0.43, 0.24, 0.42)
		piedra.size = Vector2(85 + (i % 3) * 22, 24)
		piedra.position = Vector2(25 + (i * 79) % 1280, 35 + (i * 53) % 660)
		fondo.add_child(piedra)

	var sombra := ColorRect.new()
	sombra.name = "SombraGeneral"
	sombra.color = Color(0.02, 0.01, 0.005, 0.38)
	sombra.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(sombra)

static func estilizar_recursivo(node: Node) -> void:
	if node is Label:
		estilizar_label(node as Label)
	elif node is Button:
		estilizar_boton(node as Button)
	elif node is LineEdit:
		estilizar_line_edit(node as LineEdit)
	for child in node.get_children():
		if child.name != "FondoTemplo":
			estilizar_recursivo(child)

static func estilizar_label(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.66))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func estilizar_boton(boton: Button) -> void:
	boton.custom_minimum_size = Vector2(maxf(boton.custom_minimum_size.x, 260.0), maxf(boton.custom_minimum_size.y, 58.0))

	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.29, 0.18, 0.085, 0.96)
	normal.border_color = Color(1.0, 0.74, 0.28)
	normal.border_width_left = 3
	normal.border_width_right = 3
	normal.border_width_top = 3
	normal.border_width_bottom = 3
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.shadow_size = 8
	normal.shadow_color = Color(0.0, 0.0, 0.0, 0.35)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.48, 0.30, 0.12, 0.98)

	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.20, 0.12, 0.055, 0.98)

	boton.add_theme_stylebox_override("normal", normal)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", pressed)
	boton.add_theme_color_override("font_color", Color(1.0, 0.93, 0.72))
	boton.add_theme_font_size_override("font_size", 30)

static func estilizar_line_edit(edit: LineEdit) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.11, 0.07, 0.04, 0.95)
	normal.border_color = Color(1.0, 0.73, 0.28)
	normal.border_width_left = 3
	normal.border_width_right = 3
	normal.border_width_top = 3
	normal.border_width_bottom = 3
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12

	edit.add_theme_stylebox_override("normal", normal)
	edit.add_theme_stylebox_override("focus", normal)
	edit.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78))
	edit.add_theme_color_override("font_placeholder_color", Color(0.85, 0.70, 0.48))
	edit.add_theme_font_size_override("font_size", 30)

static func agregar_boton_volver(root: Control, callback: Callable) -> void:
	if root.has_node("VolverMenuPrincipal"):
		return

	var boton := Button.new()
	boton.name = "VolverMenuPrincipal"
	boton.text = "Volver al menú principal"
	boton.anchor_left = 0.5
	boton.anchor_right = 0.5
	boton.anchor_top = 1.0
	boton.anchor_bottom = 1.0
	boton.offset_left = -180
	boton.offset_right = 180
	boton.offset_top = -95
	boton.offset_bottom = -35
	root.add_child(boton)
	estilizar_boton(boton)
	boton.pressed.connect(callback)
