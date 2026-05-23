# Crystal Jump Challenge 3D

## Introducción

**Crystal Jump Challenge 3D** es un videojuego de plataformas en 3D desarrollado en Godot Engine 4.6.2 como proyecto integrador final. El juego se basa en una experiencia de salto, precisión y avance progresivo, donde el jugador debe desplazarse entre plataformas flotantes, recolectar cristales y evitar caer al vacío para conservar sus vidas.

El objetivo principal es conseguir la mayor puntuación posible avanzando entre plataformas, recolectando cristales y sobreviviendo el mayor tiempo posible. El juego cuenta con modo individual y modo para dos jugadores, permitiendo una experiencia tanto de reto personal como de competencia local.

## Información del proyecto

| Elemento | Información |
|---|---|
| Nombre del proyecto | Crystal Jump Challenge 3D |
| Motor de desarrollo | Godot Engine |
| Versión utilizada | Godot 4.6.2 |
| Plataforma principal | Web |
| Publicación | itch.io |
| Categoría | Plataformas en 3D |
| Tipo de entrega | Proyecto integrador final |
| Año | 2026 |

## Desarrollado por

- Alan Ernesto Barajas Estrada
- Juan Gerardo Vazquez Rodriguez
- Omar Fernando Lopez Maravilla

Proyecto desarrollado para la clase de Programación 3D como entrega final del profesor Dr. Jose Luis David Bonilla Carranza.

---

# Descripción general del juego

## Sistema de juego

El jugador debe avanzar saltando entre plataformas flotantes, recolectar diferentes tipos de cristales y evitar caer al vacío. Cada plataforma alcanzada suma puntos, mientras que cada cristal recolectado otorga una puntuación adicional dependiendo de su tipo.

El juego está diseñado para que el jugador mantenga movimiento constante, mientras la dificultad aumenta conforme avanza la partida. Además, permanecer demasiado tiempo sobre una plataforma puede provocar que esta desaparezca, obligando al jugador a calcular sus saltos, reaccionar rápidamente y continuar avanzando.

## Objetivo del juego

El objetivo principal es avanzar la mayor cantidad de plataformas posible, recolectar cristales y acumular puntos antes de perder todas las vidas.

En el modo individual, el jugador registra su nickname y busca obtener la mejor puntuación para aparecer en el ranking global local. En el modo de dos jugadores, ambos participantes compiten de forma local para obtener el mayor puntaje.

---

# Características principales

- Juego de plataformas en 3D.
- Modo individual con registro de nickname.
- Modo local para dos jugadores.
- Selección de dificultad.
- Sistema de vidas.
- Sistema de puntuación.
- Cristales coleccionables con diferentes valores.
- Power-up temporal de doble salto.
- Plataformas móviles.
- Plataformas que desaparecen después de cierto tiempo.
- Señales visuales para plataformas peligrosas.
- Dificultad progresiva durante la partida.
- Menú principal con identidad visual de cristales y templos flotantes.
- Pantalla de carga inicial.
- Menú de pausa.
- Pantalla de configuración.
- Remapeo de controles.
- Ranking global local.
- Historial individual por jugador.
- Persistencia local de datos.
- Integración con API externa.
- Sonido ambiental de viento durante la partida.
- Música en menús.
- HUD visual con iconos.
- Landmarks visuales dentro del recorrido.
- Meta visual cada 50 plataformas.
- Exportación Web compatible con itch.io.

---

# Modos de juego

## Modo individual

En el modo individual, el jugador ingresa su nickname y juega con el objetivo de obtener la mayor puntuación posible. Al finalizar la partida, el resultado se guarda en el ranking global local junto con la siguiente información:

- Nickname del jugador.
- Puntaje obtenido.
- Tiempo de partida.
- Cristales recolectados.
- Plataformas recorridas.
- Dificultad alcanzada.
- Modo de juego.
- Fecha de la partida.

## Modo 2 jugadores

En el modo para dos jugadores, ambos participantes eligen sus nicknames y compiten de forma local usando controles diferentes. Cada jugador debe avanzar entre plataformas, recolectar cristales y evitar caer al vacío.

Al finalizar la partida, el juego compara los resultados y determina al ganador. El jugador ganador puede registrarse en el ranking global local junto con sus estadísticas de partida.

---

# Controles

El juego cuenta con controles predeterminados para ambos modos de juego. También incluye una opción de remapeo de controles dentro del menú de configuración, permitiendo que el jugador asigne las teclas de mayor comodidad. La tecla **ESC** permanece bloqueada porque se utiliza exclusivamente para abrir el menú de pausa.

## Modo individual

| Acción | Tecla |
|---|---|
| Avanzar | W |
| Retroceder | S |
| Moverse a la izquierda | A |
| Moverse a la derecha | D |
| Saltar | Espacio |
| Abrir menú de pausa | ESC |

## Modo 2 jugadores

### Jugador 1

| Acción | Tecla |
|---|---|
| Avanzar | W |
| Retroceder | S |
| Moverse a la izquierda | A |
| Moverse a la derecha | D |
| Saltar | Espacio |

### Jugador 2

| Acción | Tecla |
|---|---|
| Avanzar | Flecha arriba |
| Retroceder | Flecha abajo |
| Moverse a la izquierda | Flecha izquierda |
| Moverse a la derecha | Flecha derecha |
| Saltar | Enter |

## Control general

| Acción | Tecla |
|---|---|
| Abrir menú de pausa | ESC |

---

# Dificultad del juego

El juego cuenta con cuatro niveles principales de dificultad:

- **Fácil:** incluye ayuda visual de salto para que el jugador pueda acostumbrarse a la mecánica del juego.
- **Normal:** experiencia base del juego sin asistencia visual.
- **Difícil:** aumenta la exigencia de las plataformas y la precisión requerida.
- **Extremo:** representa el mayor nivel de reto, con mayor dificultad de avance y reacción.

La dificultad también puede aumentar durante la partida conforme el jugador avanza, generando una experiencia progresiva.

---

# HUD en partida

El HUD muestra información importante mediante texto e iconos visuales:

- Puntaje.
- Tiempo de partida.
- Vidas restantes.
- Dificultad actual.
- Plataformas recorridas.
- Cristales recolectados.
- Contador del power-up de doble salto cuando está activo.

Para mejorar la claridad visual, se integraron iconos de cristal, reloj y corazones. Las vidas se muestran con corazones llenos y vacíos para representar el estado actual del jugador.

---

# Sistema de puntuación y poderes

El sistema de puntuación se basa en el avance del jugador y la recolección de cristales.

| Elemento | Recompensa |
|---|---|
| Plataforma alcanzada | +2 puntos |
| Meta cada 50 plataformas | +15 puntos adicionales |
| Cristal verde | +4 puntos |
| Cristal morado | +8 puntos |
| Cristal rojo | Power-up de doble salto por 15 segundos |

Cada 50 plataformas recorridas aparece una meta visual, funcionando como punto de referencia dentro del avance del jugador.

---

# Mecánicas de plataformas

El juego incluye diferentes comportamientos de plataformas:

- Plataformas normales.
- Plataformas móviles.
- Plataformas que desaparecen.
- Plataformas con señales visuales de advertencia.
- Bifurcaciones y variaciones de ruta.
- Tramos tipo pasillo para variar el ritmo del recorrido.

Si el jugador permanece demasiado tiempo sobre una plataforma, esta cambia de color para indicar peligro y posteriormente desaparece. Esto evita que el jugador se quede inmóvil y mantiene la partida en constante movimiento.

---

# Mejoras de control

Para hacer que el movimiento se sienta más justo y fluido, se implementaron dos técnicas comunes en videojuegos de plataformas:

## Coyote time

Permite que el jugador pueda saltar durante una pequeña fracción de segundo después de abandonar una plataforma. Esto reduce la frustración cuando el jugador presiona salto apenas después de salir del borde.

## Buffer de salto

Permite que el salto se ejecute si el jugador presiona la tecla poco antes de tocar una plataforma. Esto hace que el control se sienta más responsivo.

---

# Pantallas del juego

## Pantalla de carga

El juego cuenta con una pantalla de carga inicial antes de acceder al menú principal. Esta pantalla mejora la presentación del proyecto en su versión Web.

## Menú principal

El menú principal incluye una identidad visual basada en cristales, templos flotantes y una atmósfera de fantasía. Desde este menú se puede acceder a:

- Jugar.
- Ranking global local.
- Historial individual.
- Configuración.
- Créditos.

## Menú de pausa

Durante la partida, al presionar **ESC**, se abre el menú de pausa. Este menú permite:

- Continuar la partida.
- Reiniciar partida.
- Ver controles.
- Volver al menú principal con doble confirmación.
- Salir del juego en la versión Web.

## Pantalla de fin de partida

Al finalizar la partida, el juego muestra estadísticas como:

- Puntaje final.
- Tiempo total.
- Cristales recolectados.
- Plataformas superadas.
- Caídas.
- Vidas restantes.
- Dificultad alcanzada.

También ofrece opciones para revancha rápida, cambiar dificultad, ver ranking o volver al menú principal.

---

# Ranking global local

El ranking global local muestra las mejores partidas guardadas en el navegador. La tabla incluye:

- Jugador.
- Puntaje.
- Tiempo.
- Cristales recolectados.
- Plataformas recorridas.
- Dificultad.
- Modo de juego.
- Fecha.

---

# Historial individual

En el historial individual, cada jugador puede buscar su nickname para consultar:

- Número de partidas jugadas.
- Mejor puntuación.
- Últimas partidas registradas.
- Fecha de partida.
- Modo de juego.
- Puntaje.
- Tiempo.
- Cristales recolectados.
- Plataformas recorridas.

---

# Persistencia de datos

El proyecto implementa persistencia local para guardar información del jugador, historial, ranking y configuración.

Durante el desarrollo se contempló compatibilidad con SQLite. Sin embargo, para asegurar el funcionamiento en la versión Web publicada en itch.io, se implementó un sistema de guardado local compatible con navegador mediante:

```text
user://game_data.json
