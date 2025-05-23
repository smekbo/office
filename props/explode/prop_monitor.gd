extends RigidBody3D

@export var health : HealthComponent
@export var explosion : Explodable

func _ready():
	health._ready()
	health.died.connect(_on_health_died)
	
func _on_health_died(_killer):
	explosion.explode()
