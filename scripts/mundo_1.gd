extends Node3D

# Arrastraremos la escena de la plataforma aquí en el Inspector
@export var platform_scene: PackedScene
@export var crystal_scene: PackedScene
var player_node: CharacterBody3D

var platforms_spawned = 0
var platform_spacing_z = 5.0 # Distancia hacia adelante (-Z)
var last_platform_z = 0.0

func _ready():
	player_node = $player
	# Generar las primeras 10 plataformas
	for i in range(10):
		spawn_platform()

func _process(_delta):
	# Si el jugador avanza y se acerca a la última plataforma generada, creamos más
	# (En Godot, hacia "enfrente" es el eje Z negativo)
	if player_node.global_position.z - 30.0 < last_platform_z:
		spawn_platform()

func spawn_platform():
	var new_platform = platform_scene.instantiate()
	
	# 1. Distancia aleatoria pero alcanzable (entre 3.0 y 5.5 unidades)
	var distancia_z = randf_range(3.0, 5.5) 
	var random_x = randf_range(-2.0, 2.0)
	
	if platforms_spawned == 0:
		new_platform.position = Vector3(0, 0, 0)
		new_platform.type = 0 
	else:
		last_platform_z -= distancia_z
		new_platform.position = Vector3(random_x, 0, last_platform_z)
	
	add_child(new_platform)
	
	if platforms_spawned > 0 and randf() < 0.4:
		spawn_crystal(new_platform)
		
	platforms_spawned += 1
	
	if platforms_spawned > 0 and randf() < 0.4:
		spawn_crystal(new_platform)
	
	platforms_spawned += 1
	
func spawn_crystal(platform_node):
	var new_crystal = crystal_scene.instantiate()
	platform_node.add_child(new_crystal)
	
	# 2. Cristales más altos: Cambiamos la Y de 1.0 a 1.8
	new_crystal.position = Vector3(0, 1.8, 0)


func _on_player_perder_vida() -> void:
	$HUD.restarVidas()
