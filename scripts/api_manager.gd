extends Node

signal config_recibida(config: Dictionary)
signal config_fallback()
signal api_mensaje(texto: String)

const MAX_REINTENTOS = 3

var ultima_config: Dictionary = {
	"dificultad": "normal",
	"fuente": "respaldo local",
	"distancia_min": 4.1,
	"distancia_max": 5.5,
	"lateral_max": 2.4,
	"crystal_chance": 0.55,
	"platform_speed_multiplier": 1.0,
	"platform_move_distance": 2.4,
	"score_multiplier": 1.0
}

func _base_url() -> String:
	var url: String = Global.api_base_url.strip_edges()
	if url == "":
		url = "https://jsonplaceholder.typicode.com"
	return url.trim_suffix("/")

func obtener_config_partida(es_multijugador: bool, player_id: int) -> Dictionary:
	for intento in range(1, MAX_REINTENTOS + 1):
		api_mensaje.emit("Consultando API... intento %d/%d" % [intento, MAX_REINTENTOS])
		var url = "%s/todos/%d" % [_base_url(), randi_range(1, 20)]
		var respuesta: Dictionary = await _get_json(url)

		if bool(respuesta.get("ok", false)):
			var datos: Dictionary = Dictionary(respuesta.get("data", {}))
			ultima_config = _generar_config_desde_api(datos, es_multijugador, player_id)
			config_recibida.emit(ultima_config)
			api_mensaje.emit("API conectada. Dificultad: %s" % str(ultima_config.get("dificultad", "normal")))
			return ultima_config

		await get_tree().create_timer(0.35).timeout

	ultima_config = _config_respaldo()
	config_fallback.emit()
	api_mensaje.emit("API no disponible. Usando respaldo local.")
	return ultima_config

func enviar_resultado_remoto(payload: Dictionary) -> void:
	_enviar_resultado_interno(payload)

func _enviar_resultado_interno(payload: Dictionary) -> void:
	api_mensaje.emit("Sincronizando resultado...")
	var request = HTTPRequest.new()
	add_child(request)

	var headers = ["Content-Type: application/json", "Accept: application/json"]
	var body = JSON.stringify(payload)
	var err = request.request("%s/posts" % _base_url(), headers, HTTPClient.METHOD_POST, body)

	if err != OK:
		request.queue_free()
		api_mensaje.emit("No se pudo iniciar el POST remoto.")
		return

	var result: Array = await request.request_completed
	request.queue_free()

	var http_code: int = int(result[1])
	if http_code >= 200 and http_code < 300:
		api_mensaje.emit("Resultado sincronizado correctamente.")
	else:
		api_mensaje.emit("Error al sincronizar resultado. Se conserva localmente.")

func _get_json(url: String) -> Dictionary:
	var request = HTTPRequest.new()
	request.timeout = 7.0
	add_child(request)

	var err = request.request(url, ["Accept: application/json"], HTTPClient.METHOD_GET)
	if err != OK:
		request.queue_free()
		return {"ok": false}

	var result: Array = await request.request_completed
	request.queue_free()

	var response_code: int = int(result[1])
	var body: PackedByteArray = result[3]

	if response_code < 200 or response_code >= 300:
		return {"ok": false}

	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false}

	return {"ok": true, "data": parsed}

func _generar_config_desde_api(datos: Dictionary, es_multijugador: bool, player_id: int) -> Dictionary:
	var external_id: int = int(datos.get("id", randi_range(1, 20)))
	var user_id: int = int(datos.get("userId", 1))
	var completed: bool = bool(datos.get("completed", false))

	var selector: int = (external_id + user_id + player_id) % 3
	var dificultad = "normal"
	var distancia_min = 4.1
	var distancia_max = 5.5
	var lateral_max = 2.4
	var crystal_chance = 0.55
	var speed_mult = 1.0
	var move_distance = 2.4
	var score_mult = 1.0

	if selector == 1:
		dificultad = "media"
		distancia_min = 4.5
		distancia_max = 5.9
		lateral_max = 2.8
		crystal_chance = 0.48
		speed_mult = 1.15
		move_distance = 2.8
		score_mult = 1.15
	elif selector == 2:
		dificultad = "alta"
		distancia_min = 4.8
		distancia_max = 6.2
		lateral_max = 3.2
		crystal_chance = 0.42
		speed_mult = 1.32
		move_distance = 3.1
		score_mult = 1.30

	if completed:
		crystal_chance += 0.08

	if es_multijugador:
		score_mult = 1.0

	return {
		"dificultad": dificultad,
		"fuente": "API externa",
		"distancia_min": distancia_min,
		"distancia_max": distancia_max,
		"lateral_max": lateral_max,
		"crystal_chance": crystal_chance,
		"platform_speed_multiplier": speed_mult,
		"platform_move_distance": move_distance,
		"score_multiplier": score_mult,
		"api_id": external_id
	}

func _config_respaldo() -> Dictionary:
	return {
		"dificultad": "normal",
		"fuente": "respaldo local",
		"distancia_min": 4.1,
		"distancia_max": 5.5,
		"lateral_max": 2.4,
		"crystal_chance": 0.55,
		"platform_speed_multiplier": 1.0,
		"platform_move_distance": 2.4,
		"score_multiplier": 1.0,
		"api_id": -1
	}
