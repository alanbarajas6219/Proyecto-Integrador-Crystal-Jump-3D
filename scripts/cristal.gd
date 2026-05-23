extends Area3D

var tipo: String = "morado"
var puntos: int = 8
var _visual: Node3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_aplicar_visual()

func configurar_tipo(nuevo_tipo: String) -> void:
	tipo = nuevo_tipo
	match tipo:
		"verde":
			puntos = 4
		"rojo":
			puntos = 0
		_:
			puntos = 8
	if is_inside_tree():
		_aplicar_visual()

func _aplicar_visual() -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.queue_free()
	_visual = Node3D.new()
	_visual.name = "CrystalVisual"
	add_child(_visual)

	var color = _color_por_tipo()
	var mat = _crear_material_cristal(color)
	_crear_cristal_principal(_visual, Vector3(0.0, 0.0, 0.0), 0.95, 0.36, mat)
	_crear_cristal_principal(_visual, Vector3(-0.28, -0.12, 0.08), 0.68, 0.25, mat)
	_crear_cristal_principal(_visual, Vector3(0.30, -0.10, -0.05), 0.62, 0.22, mat)
	_crear_cristal_principal(_visual, Vector3(0.06, -0.20, 0.30), 0.46, 0.18, mat)

	var luz = OmniLight3D.new()
	luz.name = "CrystalGlow"
	luz.light_color = color
	luz.light_energy = 0.85 if tipo != "rojo" else 1.1
	luz.omni_range = 2.8
	luz.position = Vector3(0.0, 0.12, 0.0)
	_visual.add_child(luz)

func _crear_cristal_principal(parent: Node3D, local_pos: Vector3, altura: float, radio: float, mat: Material) -> void:
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radio
	mesh.height = altura
	mesh.radial_segments = 6
	var node = MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = mat
	node.position = local_pos + Vector3(0.0, altura * 0.5, 0.0)
	node.rotation_degrees = Vector3(0.0, randf_range(0.0, 360.0), randf_range(-7.0, 7.0))
	parent.add_child(node)

func _crear_material_cristal(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 1.65
	mat.roughness = 0.18
	mat.metallic = 0.10
	return mat

func _color_por_tipo() -> Color:
	match tipo:
		"verde":
			return Color(0.38, 1.0, 0.25, 0.96)
		"rojo":
			return Color(1.0, 0.16, 0.12, 0.96)
		_:
			return Color(0.63, 0.16, 1.0, 0.96)

func _process(delta: float) -> void:
	rotate_y(delta * 2.8)
	if _visual != null:
		_visual.position.y = sin(Time.get_ticks_msec() / 260.0) * 0.055

func _on_body_entered(body: Node) -> void:
	if body.name == "player":
		_sumar_cristal_al_hud(body)
		queue_free()

func _sumar_cristal_al_hud(body: Node) -> void:
	var mundo = body.get_parent()
	if mundo != null and mundo.has_node("HUD"):
		var hud = mundo.get_node("HUD")
		if hud != null and hud.has_method("cristalTomado"):
			hud.cristalTomado(tipo, puntos, body)
