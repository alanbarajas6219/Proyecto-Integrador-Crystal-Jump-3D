extends CharacterBody3D

const SPEED: float = 6.4
const JUMP_VELOCITY: float = 7.0
const GRAVITY_MULTIPLIER: float = 1.45
const AIR_CONTROL: float = 0.68
const MAX_JUMPS: int = 2

const CharacterSceneP1: PackedScene = preload("res://assets/characters/Player1.glb")
const CharacterSceneP2: PackedScene = preload("res://assets/characters/Player2.glb")

@export var altura_muerte: float = -10.0
@export var model_target_height: float = 1.75
@export var model_yaw_degrees: float = 180.0

var posicion_inicial: Vector3 = Vector3(0, 2, 0)
signal perder_vida
var plataforma_segura: Node3D
var player_id: int = 1

var _gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))
var _jump_count: int = 0
var _visual_root: Node3D
var _visual_model: Node3D
var _loaded_model_player_id: int = 0
var _loading_visual: bool = false
var _visual_time: float = 0.0
var _base_visual_y: float = 0.0
var _enter_was_down: bool = false

func _get_target_height_for_player() -> float:
	return model_target_height

@onready var fallback_mesh: MeshInstance3D = get_node_or_null("MeshInstance3D") as MeshInstance3D

func _ready() -> void:
	posicion_inicial = global_position
	_crear_visual_root()
	_cargar_personaje_visual()

func _crear_visual_root() -> void:
	if _visual_root != null:
		return
	_visual_root = Node3D.new()
	_visual_root.name = "VisualRoot"
	add_child(_visual_root)

func _physics_process(delta: float) -> void:
	_cargar_personaje_visual()

	if is_on_floor():
		_jump_count = 0

	if not is_on_floor():
		velocity.y -= _gravity * GRAVITY_MULTIPLIER * delta

	var izq := "move_left_" + str(player_id)
	var der := "move_right_" + str(player_id)
	var ade := "move_forward_" + str(player_id)
	var atr := "move_back_" + str(player_id)
	var salto := "jump_" + str(player_id)

	var jump_pressed: bool = Input.is_action_just_pressed(salto)
	if player_id == 2:
		jump_pressed = jump_pressed or _enter_just_pressed()

	if jump_pressed and _jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		_jump_count += 1
		AudioManager.play_sfx("jump")

	var input_dir := Input.get_vector(izq, der, ade, atr)

	# Movimiento lineal en el mundo. El CharacterBody NO gira, así la cámara no se tuerce.
	# W/Arriba = -Z, S/Abajo = +Z, A/Izq = -X, D/Der = +X.
	var direction := Vector3(input_dir.x, 0.0, input_dir.y)
	if direction.length() > 1.0:
		direction = direction.normalized()

	var control := 1.0 if is_on_floor() else AIR_CONTROL

	if direction.length() > 0.05:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, SPEED * 10.0 * control * delta)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, SPEED * 10.0 * control * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * 8.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, SPEED * 8.0 * delta)

	move_and_slide()
	_animar_visual(delta, input_dir)
	revisar_caida()


func _enter_just_pressed() -> bool:
	var enter_down: bool = Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_KP_ENTER)
	var just_pressed: bool = enter_down and not _enter_was_down
	_enter_was_down = enter_down
	return just_pressed

func revisar_caida() -> void:
	if global_position.y < altura_muerte:
		perder_vida.emit()
		velocity = Vector3.ZERO
		_jump_count = 0
		if is_instance_valid(plataforma_segura):
			global_position = plataforma_segura.global_position + Vector3(0, 2.0, 0)
		else:
			global_position = Vector3(0, 2.0, 0)

func _cargar_personaje_visual() -> void:
	if _visual_root == null:
		return
	if _loading_visual:
		return
	if _loaded_model_player_id == player_id and _visual_root.get_child_count() > 0:
		return

	var requested_player_id: int = player_id
	_loading_visual = true

	for child in _visual_root.get_children():
		child.queue_free()

	var scene: PackedScene = CharacterSceneP1 if requested_player_id == 1 else CharacterSceneP2
	var model_node := scene.instantiate() as Node3D
	if model_node == null:
		if fallback_mesh != null:
			fallback_mesh.visible = true
		_loading_visual = false
		return

	model_node.name = "ModeloPlayer%d" % requested_player_id
	_visual_root.add_child(model_node)
	_visual_model = model_node
	_visual_model.rotation_degrees = Vector3(0.0, model_yaw_degrees, 0.0)

	if fallback_mesh != null:
		fallback_mesh.visible = false

	await get_tree().process_frame

	# Si el padre cambió player_id mientras se importaba/cargaba el modelo,
	# recargamos para evitar que el Player 2 se quede con el diseño del Player 1.
	if requested_player_id != player_id:
		_loading_visual = false
		_loaded_model_player_id = 0
		call_deferred("_cargar_personaje_visual")
		return

	_ajustar_modelo_a_capsula()
	_loaded_model_player_id = requested_player_id
	_loading_visual = false

func _ajustar_modelo_a_capsula() -> void:
	if _visual_model == null:
		return

	_visual_model.scale = Vector3.ONE
	_visual_model.position = Vector3.ZERO

	var aabb := _calcular_aabb_modelo(_visual_model)
	if aabb.size.y <= 0.01:
		_visual_model.scale = Vector3.ONE * 0.02
		_visual_model.position = Vector3(0, -0.9, 0)
		return

	var scale_factor: float = model_target_height / aabb.size.y
	_visual_model.scale = Vector3.ONE * scale_factor

	await get_tree().process_frame
	var adjusted := _calcular_aabb_modelo(_visual_model)
	_visual_model.position.y -= adjusted.position.y + 0.90
	_base_visual_y = _visual_root.position.y

func _calcular_aabb_modelo(root: Node3D) -> AABB:
	var has_aabb := false
	var min_v := Vector3(INF, INF, INF)
	var max_v := Vector3(-INF, -INF, -INF)

	for mesh_instance in _obtener_meshes(root):
		var mi := mesh_instance as MeshInstance3D
		var local_aabb := mi.get_aabb()
		for corner in _aabb_corners(local_aabb):
			var global_corner := mi.to_global(corner)
			var local_to_player := _visual_root.to_local(global_corner)
			min_v.x = minf(min_v.x, local_to_player.x)
			min_v.y = minf(min_v.y, local_to_player.y)
			min_v.z = minf(min_v.z, local_to_player.z)
			max_v.x = maxf(max_v.x, local_to_player.x)
			max_v.y = maxf(max_v.y, local_to_player.y)
			max_v.z = maxf(max_v.z, local_to_player.z)
			has_aabb = true

	if not has_aabb:
		return AABB(Vector3.ZERO, Vector3.ONE)
	return AABB(min_v, max_v - min_v)

func _obtener_meshes(node: Node) -> Array:
	var result := []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_obtener_meshes(child))
	return result

func _aabb_corners(aabb: AABB) -> Array:
	var p := aabb.position
	var s := aabb.size
	return [
		p,
		p + Vector3(s.x, 0, 0),
		p + Vector3(0, s.y, 0),
		p + Vector3(0, 0, s.z),
		p + Vector3(s.x, s.y, 0),
		p + Vector3(s.x, 0, s.z),
		p + Vector3(0, s.y, s.z),
		p + s
	]

func _animar_visual(delta: float, input_dir: Vector2) -> void:
	if _visual_root == null:
		return

	# El personaje mantiene siempre la misma orientación visual.
	# Se mueve hacia adelante, atrás, izquierda o derecha sin girar la cámara ni cambiar de pose.
	_visual_time += delta
	var moving := input_dir.length() > 0.05
	var bob := sin(_visual_time * (10.0 if moving else 3.0)) * (0.025 if moving and is_on_floor() else 0.006)

	_visual_root.position.y = _base_visual_y + bob
	_visual_root.rotation = Vector3.ZERO

	if _visual_model != null:
		_visual_model.rotation_degrees = Vector3(0.0, model_yaw_degrees, 0.0)
