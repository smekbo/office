extends RigidBody3D

## Healing per use.
@export_custom(PROPERTY_HINT_NONE, "suffix:hp") var healing : int = 5

func _on_component_usable_used(user: Variant) -> void:
	var _health : ComponentHealth = user.get("health")
	if _health != null:
		_health.heal(healing, self)
