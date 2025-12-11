extends StaticBody3D

@export var health : ComponentHealth
@export var explosion : Explodable
@export_custom(PROPERTY_HINT_NONE, "suffix:hp") var healing : int = 5

func _ready():
	health.died.connect(_on_health_died)
	
func _on_health_died(_killer):
	explosion.explode()

func _on_component_usable_attempted(user: Variant, usable: Variant) -> void:
	var _health : ComponentHealth = user.get("health")
	if _health.health >= _health.health_max or _health == null or not health.alive: 
		usable.fail(user)
	else: usable.use(user)

func _on_component_usable_used(user: Variant, _usable: Variant) -> void:
	var _health : ComponentHealth = user.get("health")
	_health.heal(healing, self)
