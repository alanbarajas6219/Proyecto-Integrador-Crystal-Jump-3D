extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	rotate_y(delta * 2.8)

func _on_body_entered(body: Node) -> void:
	if body.name == "player":
		_sumar_cristal_al_hud(body)
		queue_free()

func _sumar_cristal_al_hud(body: Node) -> void:
	var mundo := body.get_parent()
	if mundo != null and mundo.has_node("HUD"):
		var hud := mundo.get_node("HUD")
		if hud != null and hud.has_method("cristalTomado"):
			hud.cristalTomado()
