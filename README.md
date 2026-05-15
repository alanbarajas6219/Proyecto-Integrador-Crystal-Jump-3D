# Crystal Jump Challenge 3D

## Descripción general

Crystal Jump Challenge 3D es un videojuego de plataformas en 3D desarrollado en Godot Engine como proyecto integrador final.
El juego consiste en avanzar entre plataformas flotantes, recolectar cristales, evitar caer al vacío y conseguir la mayor puntuación posible.
El proyecto fue diseñado para ejecutarse en navegador Web y publicarse en itch.io.
Además, integra mecánicas de juego, sistema de puntuación, ranking, historial individual, persistencia local, conexión con API externa, menú de pausa y modo para dos jugadores.

## Información del proyecto

- **Nombre del proyecto:** Crystal Jump Challenge 3D
- **Motor de desarrollo:** Godot Engine
- **Versión utilizada:** Godot 4.6.2
- **Plataforma principal:** Web
- **Publicación:** itch.io
- **Categoría seleccionada:** Plataformas en 3D
- **Tipo de entrega:** Proyecto integrador final

## Objetivo del juego

El objetivo principal del juego es avanzar la mayor distancia posible entre plataformas flotantes, recolectar cristales y acumular puntos antes de perder todas las vidas.
En el modo individual, el jugador registra su nickname y busca obtener la mayor puntuación posible para aparecer en el ranking.
En el modo de dos jugadores, ambos participantes compiten localmente para obtener el mejor puntaje.

## Características principales

- Juego de plataformas en 3D.
- Modo individual con registro de nickname.
- Modo local para dos jugadores.
- Sistema de vidas.
- Sistema de puntuación.
- Cristales coleccionables.
- Plataformas móviles.
- Plataformas que desaparecen después de cierto tiempo.
- Dificultad dinámica durante la partida.
- Menú principal.
- Menú de pausa.
- Pantalla de configuración.
- Ranking de mejores puntuaciones.
- Historial individual por jugador.
- Persistencia local de datos.
- Integración con API externa.
- Exportación Web compatible con itch.io.

## Modos de juego
Modo individual
En este modo, el jugador ingresa su nickname y juega con el objetivo de obtener la mayor puntuación posible.
Al finalizar la partida, el resultado se guarda en el ranking junto con el tiempo de partida, dificultad y modo de juego.

Modo 2 jugadores
En este modo, dos jugadores compiten de manera local utilizando controles diferentes. Cada jugador debe avanzar entre plataformas, recolectar cristales y evitar caer.
Al finalizar, el juego compara los puntajes y determina al ganador.

## Controles

Modo individual
| Acción | Tecla |
--------------------------------
| Avanzar | W |
| Retroceder | S |
| Moverse a la izquierda | A |
| Moverse a la derecha | D |
| Saltar | Espacio |
| Pausa | ESC |

Modo 2 jugadores

Jugador 1

| Acción | Tecla |
--------------------------------
| Avanzar | W |
| Retroceder | S |
| Moverse a la izquierda | A |
| Moverse a la derecha | D |
| Saltar | Espacio |

Jugador 2

| Acción | Tecla |
-----------------------------------------------
| Avanzar | Flecha arriba |
| Retroceder | Flecha abajo |
| Moverse a la izquierda | Flecha izquierda |
| Moverse a la derecha | Flecha derecha |
| Saltar | Enter |

Controles generales

| Acción | Tecla |
--------------------------------
| Abrir menú de pausa | ESC |

## Sistema de puntuación

El sistema de puntuación se basa en el avance del jugador y la recolección de cristales.

- Cada plataforma alcanzada suma puntos.
- Cada cristal recolectado otorga puntos adicionales.
- La dificultad puede aumentar durante la partida.
- El puntaje final se registra al terminar la partida.

## Persistencia de datos

El proyecto implementa persistencia local para guardar información relacionada con:

- Ranking de mejores puntuaciones.
- Historial individual por jugador.
- Configuración de audio.
- Datos de partida.

Durante el desarrollo se contempló compatibilidad con SQLite.
Para asegurar el funcionamiento en la versión Web publicada en itch.io, se implementó un sistema de guardado local compatible con navegador mediante `user://game_data.json`.
Esto permite que los datos se conserven localmente en el navegador del usuario mientras no se borren los datos del sitio o la caché.

## Integración con API externa

El juego integra una API externa utilizada para modificar parámetros relacionados con la dificultad y configuración de la partida.
En caso de que la conexión con la API falle, el juego utiliza valores locales de respaldo para mantener la experiencia funcional.

## Estructura del proyecto

El repositorio está organizado de la siguiente manera:

```
Crystal-Jump-Challenge-3D/
│
├── project.godot
├── README.md
├── .gitignore
├── export_presets.cfg
├── icon.svg
│
├── assets/
│   ├── audio/
│   ├── characters/
│   ├── models/
│   └── ui/
│
├── scenes/
│   ├── menu_principal.tscn
│   ├── ingresar_nombre.tscn
│   ├── ingresar_nombre_multi.tscn
│   ├── mundo_2.tscn
│   ├── pantalla_dividida.tscn
│   ├── player.tscn
│   ├── plataform.tscn
│   ├── cristal.tscn
│   ├── puntajes.tscn
│   ├── historial_jugador.tscn
│   ├── configuracion.tscn
│   └── fin_partida.tscn
│
└── scripts/
	├── global.gd
	├── api_manager.gd
	├── audio_manager.gd
	├── game_state.gd
	├── menu_principal.gd
	├── ingresar_nombre.gd
	├── ingresar_nombre_multi.gd
	├── mundo_2.gd
	├── pantalla_dividida.gd
	├── player.gd
	├── plataform.gd
	├── cristal.gd
	├── puntajes.gd
	├── historial_jugador.gd
	├── configuracion.gd
	├── fin_partida.gd
	└── ui_templo.gd
