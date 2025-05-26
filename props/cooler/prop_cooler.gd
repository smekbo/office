extends StaticBody3D

@export var health : ComponentHealth
@export var explosion : Explodable
@export_custom(PROPERTY_HINT_NONE, "suffix:hp") var healing : int = 5

func _ready():
	health._ready()
	health.died.connect(_on_health_died)
	
func _on_health_died(_killer):
	explosion.explode()

func _on_component_usable_used(user: Variant) -> void:
	var _health : ComponentHealth = user.get("health")
	if _health != null && health.alive:
		_health.heal(healing, self)
