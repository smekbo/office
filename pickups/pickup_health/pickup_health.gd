extends Pickup

@export_custom(PROPERTY_HINT_NONE, "suffix:hp") var healing : int = 25

func _on_body_entered(body: Node3D) -> void:
	var _health : HealthComponent = body.get("health")
	if _health && _health.health < _health.health_max:
		_health.heal(healing)
		self.queue_free()
