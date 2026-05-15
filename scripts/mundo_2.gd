extends Node3D

@export var platform_scene: PackedScene
@export var crystal_scene: PackedScene
@export var player_id: int = 1

var player_node: CharacterBody3D
var platforms_spawned: int = 0
var last_platform_z: float = 0.0
var api_config: Dictionary = {}
var _last_x: float = 0.0
var _runtime_seconds: float = 0.0
var _difficulty_stage: int = -1

func _ready() -> void:
	AudioManager.stop_menu_music()
	randomize()
	GameState.cambiar_estado(GameState.Estado.CARGANDO_API)

	player_node = $player
	$player.player_id = player_id

	if $HUD.has_method("configurar_jugador"):
		$HUD.configurar_jugador(player_id)
	else:
		$HUD.player_id = player_id

	if $HUD.has_method("mostrar_carga"):
		$HUD.mostrar_carga("Consultando API...")

	api_config = await ApiManager.obtener_config_partida(Global.es_multijugador, player_id)
	_runtime_seconds = 0.0
	_aplicar_dificultad_por_tiempo(true)

	if $HUD.has_method("set_api_config"):
		$HUD.set_api_config(api_config)
	if $HUD.has_method("ocultar_carga"):
		$HUD.ocultar_carga()

	for i in range(10):
		spawn_platform()

	GameState.cambiar_estado(GameState.Estado.JUGANDO)

func _process(delta: float) -> void:
	if get_tree().paused:
		return

	_runtime_seconds += delta
	_aplicar_dificultad_por_tiempo(false)

	if player_node.global_position.z - 35.0 < last_platform_z:
		spawn_platform()

func _aplicar_dificultad_por_tiempo(force_update: bool) -> void:
	var new_stage: int = 0
	if _runtime_seconds >= 75.0:
		new_stage = 3
	elif _runtime_seconds >= 50.0:
		new_stage = 2
	elif _runtime_seconds >= 25.0:
		new_stage = 1

	if not force_update and new_stage == _difficulty_stage:
		return

	_difficulty_stage = new_stage

	match _difficulty_stage:
		0:
			_set_config_dificultad("normal", 4.1, 5.4, 2.35, 0.58, 1.00, 2.4, 1.00)
		1:
			_set_config_dificultad("media", 4.4, 5.8, 2.75, 0.50, 1.15, 2.8, 1.15)
		2:
			_set_config_dificultad("alta", 4.8, 6.2, 3.15, 0.42, 1.32, 3.1, 1.30)
		_:
			_set_config_dificultad("extrema", 5.0, 6.5, 3.45, 0.34, 1.50, 3.4, 1.45)

	Global.api_dificultad = str(api_config.get("dificultad", "normal"))
	Global.score_multiplier = float(api_config.get("score_multiplier", 1.0))

	if has_node("HUD") and $HUD.has_method("set_api_config"):
		$HUD.set_api_config(api_config)

func _set_config_dificultad(nombre: String, distancia_min: float, distancia_max: float, lateral_max: float, crystal_chance: float, speed_mult: float, move_distance: float, score_mult: float) -> void:
	api_config["dificultad"] = nombre
	api_config["distancia_min"] = distancia_min
	api_config["distancia_max"] = distancia_max
	api_config["lateral_max"] = lateral_max
	api_config["crystal_chance"] = crystal_chance
	api_config["platform_speed_multiplier"] = speed_mult
	api_config["platform_move_distance"] = move_distance
	api_config["score_multiplier"] = 1.0 if Global.es_multijugador else score_mult
	api_config["fuente"] = str(api_config.get("fuente", "API externa")) + " + dificultad por tiempo"

func spawn_platform() -> void:
	var new_platform = platform_scene.instantiate()

	var dificultad_bonus: float = min(float(platforms_spawned) * 0.010, 0.8)
	var distancia_min: float = float(api_config.get("distancia_min", 4.1)) + dificultad_bonus * 0.25
	var distancia_max: float = float(api_config.get("distancia_max", 5.5)) + dificultad_bonus * 0.40
	var lateral_max: float = float(api_config.get("lateral_max", 2.4)) + dificultad_bonus * 0.35

	var distancia_z: float = randf_range(distancia_min, distancia_max)
	var random_x: float = clamp(_last_x + randf_range(-1.9, 1.9), -lateral_max, lateral_max)

	if platforms_spawned == 0:
		new_platform.position = Vector3(0, 0, 0)
		new_platform.type = 0
	else:
		last_platform_z -= distancia_z
		new_platform.position = Vector3(random_x, 0, last_platform_z)

	if new_platform.has_method("configure_from_api"):
		new_platform.configure_from_api(api_config, platforms_spawned)

	add_child(new_platform)
	_last_x = new_platform.position.x

	if platforms_spawned > 0 and randf() < float(api_config.get("crystal_chance", 0.55)):
		spawn_crystal(new_platform)

	platforms_spawned += 1

func spawn_crystal(platform_node: Node3D) -> void:
	var new_crystal = crystal_scene.instantiate()
	platform_node.add_child(new_crystal)
	new_crystal.position = Vector3(0, 1.45, 0)

func _on_player_perder_vida() -> void:
	$HUD.restarVidas()

func _on_hud_pausar() -> void:
	process_mode = PROCESS_MODE_DISABLED
