extends RefCounted
class_name UITemplo

const MenuBackgroundTexture: Texture2D = preload("res://assets/ui/menu_background_main.png")

const COLOR_AZUL_CRISTAL = Color(0.08, 0.62, 1.0, 0.95)
const COLOR_CYAN = Color(0.25, 0.95, 1.0, 1.0)
const COLOR_MORADO = Color(0.40, 0.16, 0.82, 0.95)
const COLOR_DORADO = Color(1.0, 0.72, 0.20, 1.0)
const COLOR_PIEDRA_OSCURA = Color(0.055, 0.065, 0.095, 0.82)
const COLOR_PANEL = Color(0.035, 0.045, 0.075, 0.78)
const COLOR_TEXTO = Color(0.96, 0.98, 1.0, 1.0)
const COLOR_TEXTO_DORADO = Color(1.0, 0.90, 0.56, 1.0)

static func aplicar(root: Control) -> void:
	crear_fondo(root)
	estilizar_recursivo(root)

static func crear_fondo(root: Control) -> void:
	if root.has_node("FondoTemplo"):
		return

	var fondo = Control.new()
	fondo.name = "FondoTemplo"
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(fondo)
	root.move_child(fondo, 0)

	var imagen = TextureRect.new()
	imagen.name = "ImagenMenuCristal"
	imagen.texture = MenuBackgroundTexture
	imagen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	imagen.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	imagen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	imagen.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(imagen)

	var velo = ColorRect.new()
	velo.name = "VeloAzul"
	velo.color = Color(0.02, 0.04, 0.10, 0.27)
	velo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	velo.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo.add_child(velo)

	var luz_centro = ColorRect.new()
	luz_centro.name = "LuzCentral"
	luz_centro.color = Color(0.30, 0.88, 1.0, 0.10)
	luz_centro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	luz_centro.anchor_left = 0.24
	luz_centro.anchor_right = 0.76
	luz_centro.anchor_top = 0.10
	luz_centro.anchor_bottom = 0.90
	fondo.add_child(luz_centro)

	var panel = PanelContainer.new()
	panel.name = "PanelCristalCentral"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.anchor_top = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -470
	panel.offset_right = 470
	panel.offset_top = -410
	panel.offset_bottom = 410
	panel.add_theme_stylebox_override("panel", _style_panel_cristal())
	fondo.add_child(panel)

	for i in range(10):
		var brillo = ColorRect.new()
		brillo.name = "BrilloCristal_%d" % i
		brillo.color = Color(0.18, 0.86, 1.0, 0.06 + float(i % 3) * 0.025)
		brillo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		brillo.size = Vector2(34 + (i % 4) * 18, 6)
		brillo.position = Vector2(360 + i * 126, 890 + (i % 2) * 36)
		fondo.add_child(brillo)

static func _style_panel_cristal() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.border_color = Color(0.24, 0.90, 1.0, 0.78)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.shadow_size = 24
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	style.content_margin_left = 34
	style.content_margin_right = 34
	style.content_margin_top = 26
	style.content_margin_bottom = 26
	return style

static func estilizar_recursivo(node: Node) -> void:
	if node is Label:
		estilizar_label(node as Label)
	elif node is Button:
		estilizar_boton(node as Button)
	elif node is LineEdit:
		estilizar_line_edit(node as LineEdit)
	elif node is HSlider:
		estilizar_slider(node as HSlider)
	elif node is PanelContainer:
		estilizar_panel(node as PanelContainer)

	for child in node.get_children():
		if child.name != "FondoTemplo":
			estilizar_recursivo(child)

static func estilizar_label(label: Label) -> void:
	var font_size = label.get_theme_font_size("font_size")
	label.add_theme_color_override("font_color", COLOR_TEXTO_DORADO if font_size >= 36 else COLOR_TEXTO)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)
	label.add_theme_color_override("font_outline_color", Color(0.03, 0.06, 0.11, 0.85))
	label.add_theme_constant_override("outline_size", 3 if font_size < 36 else 6)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func estilizar_panel(panel: PanelContainer) -> void:
	if panel.name == "PanelCristalCentral":
		return
	if panel.get_theme_stylebox("panel") == null:
		panel.add_theme_stylebox_override("panel", _style_panel_cristal())

static func estilizar_boton(boton: Button) -> void:
	boton.custom_minimum_size = Vector2(maxf(boton.custom_minimum_size.x, 250.0), maxf(boton.custom_minimum_size.y, 52.0))

	var es_principal = _es_boton_principal(boton.text)
	var es_peligro = _es_boton_peligro(boton.text)

	var normal = StyleBoxFlat.new()
	if es_principal:
		normal.bg_color = Color(0.04, 0.53, 0.96, 0.96)
		normal.border_color = COLOR_CYAN
	elif es_peligro:
		normal.bg_color = Color(0.42, 0.10, 0.12, 0.92)
		normal.border_color = COLOR_DORADO
	else:
		normal.bg_color = Color(0.18, 0.10, 0.44, 0.92)
		normal.border_color = Color(0.54, 0.36, 1.0, 0.95)

	normal.border_width_left = 3
	normal.border_width_right = 3
	normal.border_width_top = 3
	normal.border_width_bottom = 3
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.shadow_size = 12 if es_principal else 8
	normal.shadow_color = Color(0.0, 0.72, 1.0, 0.35) if es_principal else Color(0.0, 0.0, 0.0, 0.42)
	normal.anti_aliasing = true

	var hover = normal.duplicate() as StyleBoxFlat
	if es_principal:
		hover.bg_color = Color(0.12, 0.72, 1.0, 0.98)
		hover.border_color = Color(1.0, 0.92, 0.48, 1.0)
		hover.shadow_color = Color(0.0, 0.95, 1.0, 0.58)
	else:
		hover.bg_color = Color(0.30, 0.16, 0.70, 0.98) if not es_peligro else Color(0.60, 0.18, 0.14, 0.98)
		hover.border_color = COLOR_CYAN if not es_peligro else Color(1.0, 0.80, 0.30, 1.0)

	var pressed = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.03, 0.25, 0.55, 0.98) if es_principal else Color(0.11, 0.06, 0.28, 0.98)
	pressed.border_color = COLOR_DORADO

	var disabled = normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.09, 0.09, 0.10, 0.65)
	disabled.border_color = Color(0.35, 0.35, 0.38, 0.75)

	boton.add_theme_stylebox_override("normal", normal)
	boton.add_theme_stylebox_override("hover", hover)
	boton.add_theme_stylebox_override("pressed", pressed)
	boton.add_theme_stylebox_override("disabled", disabled)
	boton.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	boton.add_theme_color_override("font_hover_color", Color(1.0, 0.94, 0.62, 1.0))
	boton.add_theme_color_override("font_pressed_color", Color(0.88, 1.0, 1.0, 1.0))
	boton.add_theme_color_override("font_disabled_color", Color(0.70, 0.70, 0.76, 0.7))
	boton.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.10, 0.88))
	boton.add_theme_constant_override("outline_size", 4)
	boton.add_theme_font_size_override("font_size", 30 if es_principal else 24)

static func _es_boton_principal(texto: String) -> bool:
	var t = texto.to_upper()
	return t == "JUGAR" or t.begins_with("INICIAR") or t == "CONFIRMAR" or t == "REVANCHA" or t == "JUGAR DE NUEVO" or t == "CONTINUAR"

static func _es_boton_peligro(texto: String) -> bool:
	var t = texto.to_upper()
	return t.contains("SALIR") or t.contains("VOLVER") or t.contains("CANCELAR")

static func estilizar_line_edit(edit: LineEdit) -> void:
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.05, 0.085, 0.92)
	normal.border_color = COLOR_CYAN
	normal.border_width_left = 3
	normal.border_width_right = 3
	normal.border_width_top = 3
	normal.border_width_bottom = 3
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.shadow_size = 8
	normal.shadow_color = Color(0.0, 0.0, 0.0, 0.36)

	var focus = normal.duplicate() as StyleBoxFlat
	focus.border_color = COLOR_DORADO
	focus.shadow_color = Color(0.0, 0.82, 1.0, 0.34)

	edit.add_theme_stylebox_override("normal", normal)
	edit.add_theme_stylebox_override("focus", focus)
	edit.add_theme_color_override("font_color", Color(1.0, 0.98, 0.83, 1.0))
	edit.add_theme_color_override("font_placeholder_color", Color(0.66, 0.88, 1.0, 0.80))
	edit.add_theme_font_size_override("font_size", 26)

static func estilizar_slider(slider: HSlider) -> void:
	var grabber = StyleBoxFlat.new()
	grabber.bg_color = COLOR_CYAN
	grabber.corner_radius_top_left = 8
	grabber.corner_radius_top_right = 8
	grabber.corner_radius_bottom_left = 8
	grabber.corner_radius_bottom_right = 8
	var fill = StyleBoxFlat.new()
	fill.bg_color = Color(0.05, 0.62, 1.0, 0.86)
	fill.corner_radius_top_left = 6
	fill.corner_radius_top_right = 6
	fill.corner_radius_bottom_left = 6
	fill.corner_radius_bottom_right = 6
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.04, 0.045, 0.07, 0.85)
	bg.corner_radius_top_left = 6
	bg.corner_radius_top_right = 6
	bg.corner_radius_bottom_left = 6
	bg.corner_radius_bottom_right = 6
	slider.add_theme_stylebox_override("slider", bg)
	slider.add_theme_stylebox_override("grabber_area", fill)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill)
	slider.add_theme_stylebox_override("grabber", grabber)
	slider.add_theme_stylebox_override("grabber_highlight", grabber)

static func agregar_boton_volver(root: Control, callback: Callable) -> void:
	if root.has_node("VolverMenuPrincipal"):
		return

	var boton = Button.new()
	boton.name = "VolverMenuPrincipal"
	boton.text = "Volver al menú principal"
	boton.anchor_left = 0.5
	boton.anchor_right = 0.5
	boton.anchor_top = 1.0
	boton.anchor_bottom = 1.0
	boton.offset_left = -200
	boton.offset_right = 200
	boton.offset_top = -170
	boton.offset_bottom = -112
	root.add_child(boton)
	estilizar_boton(boton)
	boton.pressed.connect(callback)
