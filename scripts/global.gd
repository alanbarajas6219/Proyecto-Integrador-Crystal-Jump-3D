extends Node

var nombreJ1: String = ""
var scoreJ1: int = 0
var tiempoJ1: int = 0
var jugador1_id: int = 0

var nombreJ2: String = ""
var scoreJ2: int = 0
var tiempoJ2: int = 0
var jugador2_id: int = 0

var j1_vivo: bool = true
var j2_vivo: bool = true
var es_multijugador: bool = false
var api_dificultad: String = "normal"
var score_multiplier: float = 1.0

var music_volume: float = 0.70
var sfx_volume: float = 0.85
var calidad_visual: String = "media"
var api_base_url: String = "https://jsonplaceholder.typicode.com"

var retomar_sesion: bool = false
var sesion_cargada: Dictionary = {}

var db = null
const DB_PATH := "user://basededatos.db"
const JSON_PATH := "user://game_data.json"

var _use_web_fallback: bool = false
var _sqlite_ok: bool = false
var _store: Dictionary = {}

func _ready() -> void:
	_use_web_fallback = OS.has_feature("web")
	_store = _default_store()
	_cargar_json_store()
	_asegurar_store()
	_inicializar_sqlite()
	crear_tablas()
	cargar_configuracion()
	j1_vivo = true
	j2_vivo = true

func _default_store() -> Dictionary:
	return {
		"players": [],
		"matches": [],
		"history": [],
		"session": {"activa": 0},
		"config": {
			"music_volume": 0.70,
			"sfx_volume": 0.85,
			"calidad_visual": "media",
			"api_base_url": "https://jsonplaceholder.typicode.com",
			"fecha_actualizacion": ""
		},
		"next_ids": {"player": 1, "match": 1, "history": 1}
	}

func _asegurar_store() -> void:
	var defaults := _default_store()
	for key in defaults.keys():
		if not _store.has(key):
			_store[key] = defaults[key]
	if not (_store.get("players", []) is Array):
		_store["players"] = []
	if not (_store.get("matches", []) is Array):
		_store["matches"] = []
	if not (_store.get("history", []) is Array):
		_store["history"] = []
	if not (_store.get("session", {}) is Dictionary):
		_store["session"] = {"activa": 0}
	if not (_store.get("config", {}) is Dictionary):
		_store["config"] = defaults["config"]
	if not (_store.get("next_ids", {}) is Dictionary):
		_store["next_ids"] = defaults["next_ids"]

func _cargar_json_store() -> void:
	if not FileAccess.file_exists(JSON_PATH):
		return
	var file := FileAccess.open(JSON_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_store = parsed

func _guardar_json_store() -> void:
	_asegurar_store()
	var file := FileAccess.open(JSON_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_store, "	"))
	file.close()
	_sync_sqlite_desde_store()

func _inicializar_sqlite() -> void:
	_sqlite_ok = false
	if _use_web_fallback:
		print("Web detectado: se usará persistencia JSON compatible con navegador.")
		return

	# SQLite queda como complemento en escritorio. No se referencia SQLite.new()
	# directamente para evitar error de parser si el plugin todavía no cargó la clase.
	if not ClassDB.class_exists("SQLite"):
		print("Godot-SQLite no está disponible todavía. Se usará persistencia JSON local.")
		return

	db = ClassDB.instantiate("SQLite")
	if db == null:
		print("No se pudo instanciar SQLite. Se usará persistencia JSON local.")
		return

	db.set("path", DB_PATH)
	_sqlite_ok = bool(db.call("open_db"))
	if not _sqlite_ok:
		print("No se pudo abrir SQLite. Se usará persistencia JSON local.")

func _to_int(value: Variant, default_value: int = 0) -> int:
	if value == null:
		return default_value
	match typeof(value):
		TYPE_INT:
			return value
		TYPE_FLOAT:
			return int(round(value))
		TYPE_STRING:
			var txt := str(value).strip_edges()
			if txt == "":
				return default_value
			if txt.is_valid_int():
				return txt.to_int()
			if txt.is_valid_float():
				return int(round(txt.to_float()))
			return default_value
		TYPE_BOOL:
			return 1 if bool(value) else 0
		_:
			return default_value

func _to_float(value: Variant, default_value: float = 0.0) -> float:
	if value == null:
		return default_value
	match typeof(value):
		TYPE_FLOAT:
			return value
		TYPE_INT:
			return float(value)
		TYPE_STRING:
			var txt := str(value).strip_edges()
			if txt == "":
				return default_value
			if txt.is_valid_float():
				return txt.to_float()
			return default_value
		_:
			return default_value

func crear_tablas() -> void:
	if not _sqlite_ok:
		return
	db.call("query", """
		CREATE TABLE IF NOT EXISTS jugadores (
			id INTEGER PRIMARY KEY,
			nombre TEXT UNIQUE NOT NULL,
			fecha_creacion TEXT NOT NULL,
			partidas_jugadas INTEGER DEFAULT 0,
			mejor_score INTEGER DEFAULT 0
		);
	""")
	db.call("query", """
		CREATE TABLE IF NOT EXISTS partidas (
			id INTEGER PRIMARY KEY,
			modo TEXT,
			fecha_inicio TEXT,
			fecha_fin TEXT,
			jugador1_id INTEGER,
			jugador2_id INTEGER,
			ganador_id INTEGER,
			score_j1 INTEGER,
			score_j2 INTEGER,
			tiempo_j1 INTEGER,
			tiempo_j2 INTEGER,
			dificultad TEXT,
			enviado_api INTEGER DEFAULT 0
		);
	""")
	db.call("query", """
		CREATE TABLE IF NOT EXISTS historial (
			id INTEGER PRIMARY KEY,
			partida_id INTEGER,
			jugador_id INTEGER,
			nombre TEXT,
			score INTEGER,
			tiempo INTEGER,
			dificultad TEXT,
			modo TEXT,
			resultado TEXT,
			fecha TEXT
		);
	""")
	db.call("query", """
		CREATE TABLE IF NOT EXISTS sesion_guardada (
			id INTEGER PRIMARY KEY,
			activa INTEGER,
			modo TEXT,
			fecha_guardado TEXT,
			nombre_j1 TEXT,
			nombre_j2 TEXT,
			jugador1_id INTEGER,
			jugador2_id INTEGER,
			score_j1 INTEGER,
			score_j2 INTEGER,
			tiempo_j1 INTEGER,
			tiempo_j2 INTEGER,
			vidas_j1 INTEGER,
			vidas_j2 INTEGER,
			plataformas_j1 INTEGER,
			plataformas_j2 INTEGER,
			dificultad TEXT
		);
	""")
	db.call("query", """
		CREATE TABLE IF NOT EXISTS configuracion (
			id INTEGER PRIMARY KEY,
			music_volume REAL,
			sfx_volume REAL,
			calidad_visual TEXT,
			api_base_url TEXT,
			fecha_actualizacion TEXT
		);
	""")

func _sync_sqlite_desde_store() -> void:
	if not _sqlite_ok:
		return
	for table in ["jugadores", "partidas", "historial", "sesion_guardada", "configuracion"]:
		db.call("query", "DELETE FROM %s;" % table)
	for p in _store.get("players", []):
		db.call("insert_row", "jugadores", Dictionary(p))
	for m in _store.get("matches", []):
		db.call("insert_row", "partidas", Dictionary(m))
	for h in _store.get("history", []):
		db.call("insert_row", "historial", Dictionary(h))
	var session: Dictionary = Dictionary(_store.get("session", {"activa": 0}))
	if not session.is_empty():
		if not session.has("id"):
			session["id"] = 1
		db.call("insert_row", "sesion_guardada", session)
	var cfg: Dictionary = Dictionary(_store.get("config", {}))
	if not cfg.is_empty():
		cfg["id"] = 1
		db.call("insert_row", "configuracion", cfg)

func _next_id(key: String) -> int:
	var ids: Dictionary = Dictionary(_store.get("next_ids", {}))
	var next_value: int = _to_int(ids.get(key, 1), 1)
	ids[key] = next_value + 1
	_store["next_ids"] = ids
	return next_value

func _players() -> Array:
	return _store.get("players", [])

func _history() -> Array:
	return _store.get("history", [])

func _matches() -> Array:
	return _store.get("matches", [])

func _find_player_index_by_name(nombre: String) -> int:
	var players: Array = _players()
	for i in range(players.size()):
		var p: Dictionary = Dictionary(players[i])
		if str(p.get("nombre", "")) == nombre:
			return i
	return -1

func setNombre(nombre_: String, nombre2: String) -> void:
	nombreJ1 = nombre_.strip_edges()
	nombreJ2 = nombre2.strip_edges()
	jugador1_id = get_or_create_player(nombreJ1)
	if nombreJ2 != "":
		jugador2_id = get_or_create_player(nombreJ2)
	else:
		jugador2_id = 0

func setScoreTiempo(score_: int, tiempo_: int, score2: int, tiempo2: int) -> void:
	scoreJ1 = score_
	tiempoJ1 = tiempo_
	scoreJ2 = score2
	tiempoJ2 = tiempo2

func get_or_create_player(nombre: String) -> int:
	var clean_name := nombre.strip_edges()
	if clean_name == "":
		clean_name = "Jugador"
	var players: Array = _players()
	var idx := _find_player_index_by_name(clean_name)
	if idx >= 0:
		return _to_int(Dictionary(players[idx]).get("id", 0))

	var nuevo := {
		"id": _next_id("player"),
		"nombre": clean_name,
		"fecha_creacion": Time.get_datetime_string_from_system(),
		"partidas_jugadas": 0,
		"mejor_score": 0
	}
	players.append(nuevo)
	_store["players"] = players
	_guardar_json_store()
	return int(nuevo["id"])

func guardar_fila_sql(nombre: String, puntos: int, tiempo: int, modo: String = "individual", resultado: String = "finalizado", partida_id: int = 0) -> void:
	var jugador_id: int = get_or_create_player(nombre)
	var history: Array = _history()
	history.append({
		"id": _next_id("history"),
		"partida_id": partida_id,
		"jugador_id": jugador_id,
		"nombre": nombre,
		"score": puntos,
		"tiempo": tiempo,
		"dificultad": api_dificultad,
		"modo": modo,
		"resultado": resultado,
		"fecha": Time.get_datetime_string_from_system()
	})
	_store["history"] = history

	var players: Array = _players()
	var idx := _find_player_index_by_name(nombre)
	if idx >= 0:
		var player: Dictionary = Dictionary(players[idx])
		player["partidas_jugadas"] = _to_int(player.get("partidas_jugadas", 0)) + 1
		player["mejor_score"] = maxi(_to_int(player.get("mejor_score", 0)), puntos)
		players[idx] = player
		_store["players"] = players

	_guardar_json_store()

func finalizar_partida() -> void:
	var modo: String = "multijugador" if es_multijugador else "individual"
	var ganador_id: int = 0
	var resultado_j1: String = "finalizado"
	var resultado_j2: String = "finalizado"

	if es_multijugador:
		if scoreJ1 > scoreJ2:
			ganador_id = jugador1_id
			resultado_j1 = "ganador"
			resultado_j2 = "derrota"
		elif scoreJ2 > scoreJ1:
			ganador_id = jugador2_id
			resultado_j1 = "derrota"
			resultado_j2 = "ganador"
		else:
			resultado_j1 = "empate"
			resultado_j2 = "empate"

	var partida_id := _next_id("match")
	var partida := {
		"id": partida_id,
		"modo": modo,
		"fecha_inicio": Time.get_datetime_string_from_system(),
		"fecha_fin": Time.get_datetime_string_from_system(),
		"jugador1_id": jugador1_id,
		"jugador2_id": jugador2_id,
		"ganador_id": ganador_id,
		"score_j1": scoreJ1,
		"score_j2": scoreJ2,
		"tiempo_j1": tiempoJ1,
		"tiempo_j2": tiempoJ2,
		"dificultad": api_dificultad,
		"enviado_api": 0
	}
	var matches: Array = _matches()
	matches.append(partida)
	_store["matches"] = matches

	if es_multijugador:
		guardar_fila_sql(nombreJ1, scoreJ1, tiempoJ1, modo, resultado_j1, partida_id)
		guardar_fila_sql(nombreJ2, scoreJ2, tiempoJ2, modo, resultado_j2, partida_id)
	else:
		guardar_fila_sql(nombreJ1, scoreJ1, tiempoJ1, modo, "finalizado", partida_id)

	var payload := {
		"modo": modo,
		"jugador_1": nombreJ1,
		"jugador_2": nombreJ2,
		"score_j1": scoreJ1,
		"score_j2": scoreJ2,
		"tiempo_j1": tiempoJ1,
		"tiempo_j2": tiempoJ2,
		"ganador_id": ganador_id,
		"dificultad": api_dificultad,
		"fecha": Time.get_datetime_string_from_system()
	}
	if has_node("/root/ApiManager"):
		ApiManager.enviar_resultado_remoto(payload)

	borrar_sesion_guardada()
	_guardar_json_store()
	print("Partida guardada en persistencia híbrida (JSON + SQLite si está disponible).")

func _sort_score_desc(a: Dictionary, b: Dictionary) -> bool:
	return _to_int(a.get("score", 0)) > _to_int(b.get("score", 0))

func _sort_id_desc(a: Dictionary, b: Dictionary) -> bool:
	return _to_int(a.get("id", 0)) > _to_int(b.get("id", 0))

func obtener_mejores_puntajes() -> Array:
	var arr: Array = []
	for h in _history():
		arr.append(Dictionary(h))
	arr.sort_custom(_sort_score_desc)
	if arr.size() > 10:
		arr.resize(10)
	return arr

func obtener_historial_jugador(nombre: String) -> Dictionary:
	var clean_name := nombre.strip_edges()
	if clean_name == "":
		return {"found": false, "message": "Debes escribir un nombre."}

	var idx := _find_player_index_by_name(clean_name)
	if idx < 0:
		return {"found": false, "message": "No existe historial para ese jugador."}

	var jugador: Dictionary = Dictionary(_players()[idx])
	var partidas: Array = []
	var mejor: int = 0
	var total: int = 0
	for h in _history():
		var row: Dictionary = Dictionary(h)
		if str(row.get("nombre", "")) == clean_name:
			partidas.append(row)
			total += 1
			mejor = maxi(mejor, _to_int(row.get("score", 0)))
	partidas.sort_custom(_sort_id_desc)
	if partidas.size() > 8:
		partidas.resize(8)

	return {
		"found": true,
		"jugador": jugador,
		"partidas": partidas,
		"mejor": mejor,
		"total": total
	}

func guardar_estado_sesion(player_id: int, score: int, tiempo: int, vidas: int, plataformas: int) -> void:
	var modo: String = "multijugador" if es_multijugador else "individual"
	var s: Dictionary = Dictionary(_store.get("session", {}))
	if s.is_empty() or _to_int(s.get("activa", 0)) == 0:
		s = {
			"id": 1,
			"score_j1": 0, "score_j2": 0,
			"tiempo_j1": 0, "tiempo_j2": 0,
			"vidas_j1": 3, "vidas_j2": 3,
			"plataformas_j1": 0, "plataformas_j2": 0
		}

	if player_id == 1:
		s["score_j1"] = score
		s["tiempo_j1"] = tiempo
		s["vidas_j1"] = vidas
		s["plataformas_j1"] = plataformas
	else:
		s["score_j2"] = score
		s["tiempo_j2"] = tiempo
		s["vidas_j2"] = vidas
		s["plataformas_j2"] = plataformas

	s["id"] = 1
	s["activa"] = 1
	s["modo"] = modo
	s["fecha_guardado"] = Time.get_datetime_string_from_system()
	s["nombre_j1"] = nombreJ1
	s["nombre_j2"] = nombreJ2
	s["jugador1_id"] = jugador1_id
	s["jugador2_id"] = jugador2_id
	s["dificultad"] = api_dificultad
	_store["session"] = s
	_guardar_json_store()

func existe_sesion_guardada() -> bool:
	var s: Dictionary = Dictionary(_store.get("session", {}))
	return _to_int(s.get("activa", 0)) == 1

func obtener_sesion_guardada() -> Dictionary:
	var s: Dictionary = Dictionary(_store.get("session", {}))
	if _to_int(s.get("activa", 0)) == 1:
		return s
	return {}

func cargar_sesion_en_memoria() -> bool:
	var s := obtener_sesion_guardada()
	if s.is_empty():
		return false
	sesion_cargada = s
	retomar_sesion = true
	es_multijugador = str(s.get("modo", "individual")) == "multijugador"
	nombreJ1 = str(s.get("nombre_j1", "Jugador 1"))
	nombreJ2 = str(s.get("nombre_j2", ""))
	jugador1_id = _to_int(s.get("jugador1_id", 0))
	jugador2_id = _to_int(s.get("jugador2_id", 0))
	scoreJ1 = _to_int(s.get("score_j1", 0))
	scoreJ2 = _to_int(s.get("score_j2", 0))
	tiempoJ1 = _to_int(s.get("tiempo_j1", 0))
	tiempoJ2 = _to_int(s.get("tiempo_j2", 0))
	api_dificultad = str(s.get("dificultad", "normal"))
	j1_vivo = _to_int(s.get("vidas_j1", 3)) > 0
	j2_vivo = _to_int(s.get("vidas_j2", 3)) > 0
	return true

func borrar_sesion_guardada() -> void:
	_store["session"] = {"id": 1, "activa": 0}
	retomar_sesion = false
	sesion_cargada = {}
	_guardar_json_store()

func cargar_configuracion() -> void:
	var c: Dictionary = Dictionary(_store.get("config", {}))
	music_volume = _to_float(c.get("music_volume", music_volume), music_volume)
	sfx_volume = _to_float(c.get("sfx_volume", sfx_volume), sfx_volume)
	calidad_visual = str(c.get("calidad_visual", calidad_visual))
	api_base_url = str(c.get("api_base_url", api_base_url))

func guardar_configuracion(music: float, sfx: float, calidad: String, api_url: String) -> void:
	music_volume = clampf(music, 0.0, 1.0)
	sfx_volume = clampf(sfx, 0.0, 1.0)
	calidad_visual = calidad
	api_base_url = api_url.strip_edges()
	if api_base_url == "":
		api_base_url = "https://jsonplaceholder.typicode.com"
	_store["config"] = {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"calidad_visual": calidad_visual,
		"api_base_url": api_base_url,
		"fecha_actualizacion": Time.get_datetime_string_from_system()
	}
	_guardar_json_store()
	if has_node("/root/AudioManager"):
		AudioManager.apply_volumes()

func diagnostico_db() -> void:
	print("Persistencia principal JSON: ", JSON_PATH)
	print("Modo web fallback: ", _use_web_fallback)
	print("SQLite activo: ", _sqlite_ok)
	print("Jugadores: ", _players().size())
	print("Partidas: ", _matches().size())
	print("Historial: ", _history().size())
