extends Node3D

## The health component for this enemy. Governs health, armor, injury, and healing.
@export var health : Resource

func _ready():
	health._ready()
	health.connect("injured", _on_health_injured)
	health.connect("healed", _on_health_healed)

func _on_health_injured(_amount, _source):
	print("Dummy health damage: " + str(_amount))

func _on_health_healed(_amount, _source):
	pass
