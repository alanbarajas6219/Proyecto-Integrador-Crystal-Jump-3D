extends Control

const UITemplo = preload("res://scripts/ui_templo.gd")

var _esperando_accion: String = ""
var _mensaje: Label

var acciones = {
	"move_forward_1": "J1 Avanzar",
	"move_back_1": "J1 Retroceder",
	"move_left_1": "J1 Izquierda",
	"move_right_1": "J1 Derecha",
	"jump_1": "J1 Saltar",
	"move_forward_2": "J2 Avanzar",
	"move_back_2": "J2 Retroceder",
	"move_left_2": "J2 Izquierda",
	"move_right_2": "J2 Derecha",
	"jump_2": "J2 Saltar"
}

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
	box.offset_left = -400
	box.offset_right = 400
	box.offset_top = -340
	box.offset_bottom = 300
	box.add_theme_constant_override("separation", 8)
	add_child(box)

	var titulo = Label.new()
	titulo.text = "Remapeo de controles"
	titulo.add_theme_font_size_override("font_size", 40)
	box.add_child(titulo)
	UITemplo.estilizar_label(titulo)

	_mensaje = Label.new()
	_mensaje.text = "Selecciona una acción y presiona una tecla. ESC está bloqueada porque se usa para pausa."
	_mensaje.custom_minimum_size = Vector2(760, 0)
	_mensaje.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mensaje.add_theme_font_size_override("font_size", 20)
	box.add_child(_mensaje)
	UITemplo.estilizar_label(_mensaje)

	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(780, 430)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	box.add_child(scroll)

	var acciones_box = VBoxContainer.new()
	acciones_box.custom_minimum_size = Vector2(760, 0)
	acciones_box.add_theme_constant_override("separation", 8)
	scroll.add_child(acciones_box)

	for action in acciones.keys():
		var b = Button.new()
		b.text = "%s: %s" % [acciones[action], _tecla_actual(action)]
		b.custom_minimum_size = Vector2(720, 42)
		acciones_box.add_child(b)
		UITemplo.estilizar_boton(b)
		b.pressed.connect(func(a=action, btn=b): _esperar(a, btn))

	var volver = Button.new()
	volver.text = "Volver a configuración"
	volver.custom_minimum_size = Vector2(360, 52)
	box.add_child(volver)
	UITemplo.estilizar_boton(volver)
	volver.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/configuracion.tscn"))

func _tecla_actual(action: String) -> String:
	var events = InputMap.action_get_events(action)
	if events.size() > 0 and events[0] is InputEventKey:
		return OS.get_keycode_string((events[0] as InputEventKey).physical_keycode)
	return "Sin asignar"

func _esperar(action: String, btn: Button) -> void:
	_esperando_accion = action
	_mensaje.text = "Presiona nueva tecla para: %s" % acciones[action]

func _input(event: InputEvent) -> void:
	if _esperando_accion == "":
		return
	if event is InputEventKey:
		var key = event as InputEventKey
		if not key.pressed or key.echo:
			return
		if key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE:
			_mensaje.text = "ESC no se puede remapear porque abre la pausa."
			_esperando_accion = ""
			return
		var new_event = InputEventKey.new()
		new_event.physical_keycode = key.physical_keycode
		InputMap.action_erase_events(_esperando_accion)
		InputMap.action_add_event(_esperando_accion, new_event)
		_mensaje.text = "Control actualizado correctamente."
		AudioManager.play_sfx("success")
		_esperando_accion = ""
		get_tree().reload_current_scene()
