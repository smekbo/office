extends Pickup

@export_custom(PROPERTY_HINT_NONE, "suffix:hp") var healing_amount : int = 25
@export_custom(PROPERTY_HINT_NONE, "suffix:armor") var armoring_amount : int = 25

func _on_body_entered(body: Node3D) -> void:
	var _health : HealthComponent = body.get("health")
	var _used : bool = false
	
	if _health:
		if _health.health < _health.health_max:
			_health.heal(healing_amount)
			_used = true
		if _health.armor < _health.armor_max:
			_health.armoring(armoring_amount)
			_used = true
	
	if _used: self.queue_free()
