extends Node

enum Estado {
	MENU,
	CONFIGURACION,
	REGISTRO,
	CARGANDO_API,
	JUGANDO,
	PAUSA,
	GAME_OVER,
	RANKING,
	HISTORIAL
}

var estado_actual: Estado = Estado.MENU

func cambiar_estado(nuevo_estado: Estado) -> void:
	estado_actual = nuevo_estado

func puede_jugar() -> bool:
	return estado_actual == Estado.JUGANDO

func puede_pausar() -> bool:
	return estado_actual == Estado.JUGANDO

func esta_en_menu() -> bool:
	return estado_actual == Estado.MENU
