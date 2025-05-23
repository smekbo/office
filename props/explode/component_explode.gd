extends Area3D
class_name Explodable

@export_category("Damage")
## The damage this explosion does
@export var damage : int = 10
## How much penetration the damage has
@export var penetration : float = 0
## Does the damage ignore all resistances?
@export var ignore : bool = false

## Explodes. Checks for all objects in volume, which ones can be damaged, and damages them
## Todo: Add explosion VFX calls
func explode():
	var _bodies = self.get_overlapping_bodies()
	var _parent = self.get_parent_node_3d()
	print(str(_bodies))
	for item in _bodies:
		var _health : HealthComponent = item.get("health")
		if _health != null && item != _parent:
			item.health.injure(damage, self.get_parent_node_3d(), penetration, ignore)
