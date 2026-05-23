extends AnimatableBody3D

var type: int = 0
# 0 = Estática, 1 = Lado a lado X, 2 = Desaparece al tocar, 3 = Arriba y abajo Y

var start_pos_x: float = 0.0
var start_pos_y: float = 0.0
var time_passed: float = 0.0
var move_speed: float = 2.0
var move_distance: float = 3.0
var difficulty_multiplier: float = 1.0
var platform_index: int = 0

var _standing_body: CharacterBody3D = null
var _standing_time: float = 0.0
var _warning_applied: bool = false
var _mesh_nodes: Array[MeshInstance3D] = []
var _base_materials: Array = []
var _score_reported: bool = false

var max_stand_time: float = 10.0
var warning_time: float = 7.0

func configure_from_api(config: Dictionary, index: int) -> void:
	platform_index = index
	difficulty_multiplier = float(config.get("platform_speed_multiplier", 1.0))
	move_distance = float(config.get("platform_move_distance", 2.4))
	max_stand_time = float(config.get("stand_time", 10.0))
	warning_time = max_stand_time * 0.70
	move_speed = randf_range(1.2, 2.3) * difficulty_multiplier

	if index == 0:
		type = 0
	elif index < 4:
		type = 0 if randf() < 0.70 else 1
	else:
		var roll = randf()
		if roll < 0.45:
			type = 1
		elif roll < 0.65:
			type = 0
		elif roll < 0.82:
			type = 3
		else:
			type = 2

func _ready() -> void:
	start_pos_x = global_position.x
	start_pos_y = global_position.y

	if platform_index == 0:
		type = 0

	_mesh_nodes = _obtener_meshes(self)
	_base_materials.clear()
	for mesh in _mesh_nodes:
		_base_materials.append(mesh.material_override)

	$Area3D.body_entered.connect(_on_area_3d_body_entered)
	$Area3D.body_exited.connect(_on_area_3d_body_exited)

func _physics_process(delta: float) -> void:
	if type == 1 or type == 3:
		time_passed += delta
		if type == 1:
			global_position.x = start_pos_x + sin(time_passed * move_speed) * move_distance
		elif type == 3:
			global_position.y = start_pos_y + sin(time_passed * move_speed) * (move_distance * 0.45)

	_actualizar_temporizador_plataforma(delta)

func _actualizar_temporizador_plataforma(delta: float) -> void:
	if _standing_body == null or not is_instance_valid(_standing_body):
		_standing_body = null
		_standing_time = 0.0
		_warning_applied = false
		_restaurar_material()
		return

	_standing_time += delta

	if _standing_time >= warning_time and not _warning_applied:
		_aplicar_material_advertencia()
		AudioManager.play_sfx("warning")
		_warning_applied = true

	if _standing_time >= max_stand_time:
		if is_instance_valid(self):
			AudioManager.play_sfx("platform_break")
			queue_free()

func _reportar_avance_a_hud() -> void:
	if _score_reported:
		return
	_score_reported = true

	var mundo = get_parent()
	if mundo != null and mundo.has_node("HUD"):
		var hud = mundo.get_node("HUD")
		if hud != null and hud.has_method("plataformaAvanzada"):
			hud.plataformaAvanzada(platform_index)

func _on_area_3d_body_entered(body: Node) -> void:
	if body.name == "player":
		_standing_body = body as CharacterBody3D
		_standing_time = 0.0
		_warning_applied = false

		body.plataforma_segura = self
		_reportar_avance_a_hud()

		if type == 2:
			await get_tree().create_timer(1.2).timeout
			if is_instance_valid(self):
				queue_free()

func _on_area_3d_body_exited(body: Node) -> void:
	if body == _standing_body:
		_standing_body = null
		_standing_time = 0.0
		_warning_applied = false
		_restaurar_material()

func _aplicar_material_advertencia() -> void:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.42, 0.16)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.18, 0.05)
	mat.emission_energy_multiplier = 0.7
	for mesh in _mesh_nodes:
		if is_instance_valid(mesh):
			mesh.material_override = mat

func _restaurar_material() -> void:
	for i in range(_mesh_nodes.size()):
		var mesh = _mesh_nodes[i]
		if is_instance_valid(mesh):
			mesh.material_override = _base_materials[i]

func _obtener_meshes(node: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_obtener_meshes(child))
	return result
