extends Node3D

@export var platform_scene: PackedScene
@export var crystal_scene: PackedScene
@export var player_id: int = 1

const GameplayBackgroundTexture: Texture2D = preload("res://assets/ui/gameplay_background.png")

var player_node: CharacterBody3D
var platforms_spawned: int = 0
var last_platform_z: float = 0.0
var api_config: Dictionary = {}
var _last_x: float = 0.0
var _runtime_seconds: float = 0.0
var _difficulty_stage: int = -1
var _active_platforms: Array[Node3D] = []
var _ambiente_preparado: bool = false

func _ready() -> void:
	AudioManager.stop_menu_music()
	AudioManager.play_wind_ambience()
	randomize()
	GameState.cambiar_estado(GameState.Estado.CARGANDO_API)
	player_node = $player
	_preparar_ambiente_gameplay()
	$player.player_id = player_id
	if $HUD.has_method("configurar_jugador"):
		$HUD.configurar_jugador(player_id)
	else:
		$HUD.player_id = player_id
	if $HUD.has_method("mostrar_carga"):
		$HUD.mostrar_carga("Consultando API externa...")

	api_config = await ApiManager.obtener_config_partida(Global.es_multijugador, player_id)
	_mostrar_estado_api()
	_runtime_seconds = 0.0
	_aplicar_dificultad_por_tiempo(true)
	if $HUD.has_method("set_api_config"):
		$HUD.set_api_config(api_config)
	if $HUD.has_method("ocultar_carga"):
		$HUD.ocultar_carga()

	for i in range(12):
		spawn_platform()
	GameState.cambiar_estado(GameState.Estado.JUGANDO)

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	_runtime_seconds += delta
	_aplicar_dificultad_por_tiempo(false)
	if player_node.global_position.z - 40.0 < last_platform_z:
		spawn_platform()
	_limpiar_plataformas_antiguas()

func _mostrar_estado_api() -> void:
	var fuente = str(api_config.get("fuente", "respaldo local"))
	if fuente.to_lower().contains("respaldo"):
		Global.api_mensaje_actual = "No se pudo conectar con la API, usando configuración local."
	else:
		Global.api_mensaje_actual = "API conectada: dificultad ajustada con datos externos."
	if has_node("HUD") and $HUD.has_method("mostrar_mensaje"):
		$HUD.mostrar_mensaje(Global.api_mensaje_actual)

func _aplicar_dificultad_por_tiempo(force_update: bool) -> void:
	var base_stage = Global._dificultad_nivel(Global.dificultad_elegida)
	var extra_stage = int(_runtime_seconds / 38.0)
	var new_stage: int = mini(3, base_stage + extra_stage)
	if not force_update and new_stage == _difficulty_stage:
		return
	_difficulty_stage = new_stage
	var names = ["facil", "normal", "dificil", "extremo"]
	var nombre: String = names[_difficulty_stage]
	var profile = Global.get_difficulty_profile(nombre)
	for key in profile.keys():
		api_config[key] = profile[key]
	api_config["fuente"] = str(api_config.get("fuente", "API externa")) + " + dificultad seleccionada/progresiva"
	Global.api_dificultad = nombre
	Global.score_multiplier = float(api_config.get("score_multiplier", 1.0))
	if Global.es_multijugador:
		Global.score_multiplier = 1.0
		api_config["score_multiplier"] = 1.0
	if has_node("HUD") and $HUD.has_method("set_api_config"):
		$HUD.set_api_config(api_config)
	if not force_update and has_node("HUD") and $HUD.has_method("mostrar_mensaje"):
		$HUD.mostrar_mensaje("¡La dificultad subió a %s!" % nombre.capitalize())

func spawn_platform() -> void:
	var dificultad_bonus: float = min(float(platforms_spawned) * 0.010, 0.8)
	var distancia_min: float = float(api_config.get("distancia_min", 4.1)) + dificultad_bonus * 0.25
	var distancia_max: float = float(api_config.get("distancia_max", 5.5)) + dificultad_bonus * 0.40
	var lateral_max: float = float(api_config.get("lateral_max", 2.4)) + dificultad_bonus * 0.35
	var distancia_z: float = randf_range(distancia_min, distancia_max)
	var random_x: float = clamp(_last_x + randf_range(-1.9, 1.9), -lateral_max, lateral_max)

	# Tramos tipo pasillo: varias plataformas más juntas para variar la lectura del mapa.
	var tramo = platforms_spawned % 22
	if tramo >= 6 and tramo <= 10:
		distancia_z = randf_range(2.55, 3.05)
		random_x = clamp(_last_x + randf_range(-0.35, 0.35), -lateral_max, lateral_max)

	var pos = Vector3.ZERO
	if platforms_spawned == 0:
		pos = Vector3(0, 0, 0)
	else:
		last_platform_z -= distancia_z
		pos = Vector3(random_x, 0, last_platform_z)

	var platform = _crear_plataforma(pos, platforms_spawned, false)
	_last_x = platform.position.x

	if platforms_spawned > 0 and randf() < float(api_config.get("crystal_chance", 0.55)):
		spawn_crystal(platform)

	# Bifurcaciones de riesgo/recompensa: una plataforma alterna con cristal raro.
	if platforms_spawned > 10 and platforms_spawned % 24 == 0:
		var branch_x = clamp(-random_x + randf_range(-0.8, 0.8), -lateral_max, lateral_max)
		var branch = _crear_plataforma(Vector3(branch_x, 0, last_platform_z - 0.15), platforms_spawned, true)
		spawn_crystal(branch, "morado")

	platforms_spawned += 1

func _crear_plataforma(pos: Vector3, index: int, branch: bool) -> Node3D:
	var new_platform = platform_scene.instantiate()
	new_platform.position = pos
	if index == 0:
		new_platform.type = 0
	if new_platform.has_method("configure_from_api"):
		new_platform.configure_from_api(api_config, index)
	if branch:
		new_platform.scale = Vector3(0.82, 1.0, 0.82)
	add_child(new_platform)
	_active_platforms.append(new_platform)
	_decorar_plataforma(new_platform, index, branch)
	return new_platform


func _preparar_ambiente_gameplay() -> void:
	if _ambiente_preparado:
		return
	_ambiente_preparado = true
	_crear_fondo_en_camara()
	_crear_particulas_viento()
	_reforzar_ambiente_y_niebla()

func _crear_fondo_en_camara() -> void:
	if player_node == null:
		return
	var cam = player_node.get_node_or_null("Camera3D") as Camera3D
	if cam == null or cam.has_node("FondoGameplayCinematico"):
		return
	var bg = Sprite3D.new()
	bg.name = "FondoGameplayCinematico"
	bg.texture = GameplayBackgroundTexture
	bg.centered = true
	bg.pixel_size = 0.070
	bg.position = Vector3(0.0, 0.2, -42.0)
	bg.modulate = Color(0.82, 0.95, 1.0, 0.96)
	bg.no_depth_test = false
	bg.render_priority = -20
	cam.add_child(bg)

func _crear_particulas_viento() -> void:
	if player_node == null:
		return
	var cam = player_node.get_node_or_null("Camera3D") as Camera3D
	if cam == null or cam.has_node("ParticulasViento"):
		return
	var particles = GPUParticles3D.new()
	particles.name = "ParticulasViento"
	particles.amount = 90
	particles.lifetime = 4.6
	particles.visibility_aabb = AABB(Vector3(-22, -12, -48), Vector3(44, 24, 55))
	particles.position = Vector3(0.0, 0.0, -14.0)
	particles.emitting = true
	var process = ParticleProcessMaterial.new()
	process.direction = Vector3(-0.65, 0.10, -0.25)
	process.spread = 38.0
	process.initial_velocity_min = 1.0
	process.initial_velocity_max = 3.0
	process.gravity = Vector3(0.0, 0.10, 0.0)
	process.scale_min = 0.025
	process.scale_max = 0.075
	process.color = Color(0.55, 0.86, 1.0, 0.32)
	particles.process_material = process
	var mesh = QuadMesh.new()
	mesh.size = Vector2(0.12, 0.025)
	particles.draw_pass_1 = mesh
	cam.add_child(particles)

func _reforzar_ambiente_y_niebla() -> void:
	var world_env = get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env == null or world_env.environment == null:
		return
	world_env.environment.fog_enabled = true
	world_env.environment.fog_density = 0.018
	world_env.environment.fog_light_color = Color(0.30, 0.40, 0.55, 1.0)
	world_env.environment.fog_sky_affect = 0.92
	world_env.environment.glow_enabled = true

func _decorar_plataforma(platform_node: Node3D, index: int, branch: bool) -> void:
	if index <= 0:
		return
	if index % 50 == 0:
		_crear_meta_visual(platform_node, index)
	elif index % 25 == 0:
		_crear_landmark_lateral(platform_node, index)
	elif index % 8 == 0 and not branch:
		_crear_cristales_decorativos(platform_node, index)

func _crear_meta_visual(platform_node: Node3D, index: int) -> void:
	# Meta visual cada 50 plataformas: pilar procedural + aro de cristal + luz.
	# Se genera por código para mantener bajo el peso del export Web/itch.io.
	var pillar = _crear_pilar_procedural("MetaPilar_%d" % index, true)
	platform_node.add_child(pillar)
	pillar.position = Vector3(2.6, 0.15, -0.15)
	pillar.rotation_degrees = Vector3(0.0, float(int(index / 50) % 4) * 90.0, 0.0)

	var ring = MeshInstance3D.new()
	ring.name = "PortalMeta_%d" % index
	var torus = TorusMesh.new()
	torus.inner_radius = 0.58
	torus.outer_radius = 0.72
	torus.rings = 28
	torus.ring_segments = 8
	ring.mesh = torus
	ring.position = Vector3(0.0, 1.45, -0.05)
	ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	ring.material_override = _crear_material_emision(Color(0.20, 0.90, 1.0), 1.8)
	platform_node.add_child(ring)

	var light = OmniLight3D.new()
	light.name = "LuzMeta_%d" % index
	light.light_color = Color(0.25, 0.90, 1.0)
	light.light_energy = 1.2
	light.omni_range = 5.0
	light.position = Vector3(0.0, 1.35, 0.0)
	platform_node.add_child(light)
	_crear_cristales_decorativos(platform_node, index, true)

func _crear_landmark_lateral(platform_node: Node3D, index: int) -> void:
	var side = -1.0 if index % 2 == 0 else 1.0
	var pillar = _crear_pilar_procedural("LandmarkPilar_%d" % index, false)
	platform_node.add_child(pillar)
	pillar.position = Vector3(side * 5.8, 0.0, 0.0)
	pillar.rotation_degrees = Vector3(0.0, randf_range(0.0, 360.0), 0.0)
	_crear_cristal_decorativo(platform_node, Vector3(side * 3.8, 0.30, 0.95), Color(0.45, 0.20, 1.0), 0.95)
	_crear_cristal_decorativo(platform_node, Vector3(side * 4.6, 0.25, -0.70), Color(0.05, 0.80, 1.0), 0.75)

func _crear_pilar_procedural(nombre: String, es_meta: bool) -> Node3D:
	var root = Node3D.new()
	root.name = nombre
	var mat_piedra = _crear_material_piedra()
	var mat_luz = _crear_material_emision(Color(0.16, 0.86, 1.0), 1.35)

	var base = _crear_bloque(Vector3(1.15, 0.22, 1.15), mat_piedra)
	base.position = Vector3(0.0, 0.11, 0.0)
	root.add_child(base)

	var cuerpo = MeshInstance3D.new()
	var cilindro = CylinderMesh.new()
	cilindro.top_radius = 0.34 if es_meta else 0.28
	cilindro.bottom_radius = 0.42 if es_meta else 0.34
	cilindro.height = 1.65 if es_meta else 1.25
	cilindro.radial_segments = 10
	cuerpo.mesh = cilindro
	cuerpo.material_override = mat_piedra
	cuerpo.position = Vector3(0.0, (1.65 if es_meta else 1.25) * 0.5 + 0.22, 0.0)
	root.add_child(cuerpo)

	var tapa = _crear_bloque(Vector3(0.95, 0.18, 0.95), mat_piedra)
	tapa.position = Vector3(0.0, 1.98 if es_meta else 1.58, 0.0)
	root.add_child(tapa)

	var cristal = MeshInstance3D.new()
	var cmesh = CylinderMesh.new()
	cmesh.top_radius = 0.0
	cmesh.bottom_radius = 0.22 if es_meta else 0.17
	cmesh.height = 0.62 if es_meta else 0.45
	cmesh.radial_segments = 6
	cristal.mesh = cmesh
	cristal.material_override = mat_luz
	cristal.position = Vector3(0.0, 2.36 if es_meta else 1.88, 0.0)
	root.add_child(cristal)

	var luz = OmniLight3D.new()
	luz.light_color = Color(0.16, 0.86, 1.0)
	luz.light_energy = 0.55 if es_meta else 0.35
	luz.omni_range = 3.0
	luz.position = cristal.position
	root.add_child(luz)
	return root

func _crear_bloque(size: Vector3, mat: Material) -> MeshInstance3D:
	var node = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = mat
	return node

func _crear_material_piedra() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.36, 0.34, 0.30, 1.0)
	mat.roughness = 0.82
	return mat

func _crear_cristales_decorativos(platform_node: Node3D, index: int, extra: bool = false) -> void:
	var s = -1.0 if index % 2 == 0 else 1.0
	_crear_cristal_decorativo(platform_node, Vector3(s * 1.35, 0.30, 1.35), Color(0.50, 0.18, 1.0), 0.52)
	if extra:
		_crear_cristal_decorativo(platform_node, Vector3(-s * 1.15, 0.26, -1.25), Color(0.05, 0.88, 1.0), 0.50)

func _crear_cristal_decorativo(parent: Node3D, local_pos: Vector3, color: Color, escala: float) -> void:
	var crystal = MeshInstance3D.new()
	crystal.name = "CristalDecorativo"
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = 0.26
	mesh.height = 1.05
	mesh.radial_segments = 6
	crystal.mesh = mesh
	crystal.position = local_pos
	crystal.rotation_degrees = Vector3(0.0, randf_range(0.0, 360.0), 0.0)
	crystal.scale = Vector3.ONE * escala
	crystal.material_override = _crear_material_emision(color, 1.15)
	parent.add_child(crystal)

func _crear_material_emision(color: Color, energy: float) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = energy
	mat.roughness = 0.35
	return mat

func spawn_crystal(platform_node: Node3D, forced_type: String = "") -> void:
	var new_crystal = crystal_scene.instantiate()
	var tipo = forced_type
	if tipo == "":
		var r = randf()
		if r < 0.40:
			tipo = "verde"
		elif r < 0.70:
			tipo = "morado"
		else:
			tipo = "rojo"
	platform_node.add_child(new_crystal)
	new_crystal.position = Vector3(0, 1.45, 0)
	if new_crystal.has_method("configurar_tipo"):
		new_crystal.configurar_tipo(tipo)

func _limpiar_plataformas_antiguas() -> void:
	for i in range(_active_platforms.size() - 1, -1, -1):
		var p = _active_platforms[i]
		if not is_instance_valid(p):
			_active_platforms.remove_at(i)
		elif player_node != null and p.global_position.z > player_node.global_position.z + 24.0 and p.global_position.z < -0.5:
			p.queue_free()
			_active_platforms.remove_at(i)

func _on_player_perder_vida() -> void:
	$HUD.restarVidas()

func _on_hud_pausar() -> void:
	process_mode = PROCESS_MODE_DISABLED
