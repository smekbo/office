extends Area3D
class_name Explodable

@export_category("Timing")
## How long before the explosion happens
@export_custom(PROPERTY_HINT_NONE, "suffix:s") var fuse : float = 0
var fuse_timer : float = 0
var fuse_lit : bool = false
var exploded : bool = false
## How long the explosion "lingers", still able to damage entities
@export_custom(PROPERTY_HINT_NONE, "suffice:s") var linger : float = 0
var lingering : bool = false
var linger_timer : float = 0
## How often the explosion ticks damage. Only used when the explosion is set to linger.
@export_custom(PROPERTY_HINT_NONE, "suffice:s") var tickrate : float = 1
var tick_timer : float = 0

@export_category("Damage")
## The damage this explosion does
@export var damage : int = 10
## How much penetration the damage has
@export var penetration : float = 0
## Does the damage ignore all resistances?
@export var ignore : bool = false

@export var vfx : WeaponImpact

func _physics_process(delta: float) -> void:
	if fuse_lit:
		fuse_timer -= delta
		if fuse_timer <= 0:
			explode()
	if lingering:
		linger_timer -= delta
		if linger_timer <= 0:
			lingering = false
			return
		tick_timer -= delta
		if tick_timer <= 0:
			damage_area()
			tick_timer = tickrate

## Explodes. Checks for all objects in volume, which ones can be damaged, and damages them
## Todo: Add explosion VFX calls
func explode():
	if fuse > 0 && not fuse_lit:
		fuse_timer = fuse
		fuse_lit = true
		return
	elif not exploded:
		damage_area()
		exploded = true
		if linger > 0:
			linger_timer = linger
			tick_timer = tickrate
			lingering = true

## Damages all objects in the area. Objects must have a HealthComponent attached to "health" property to be damaged.
func damage_area():
	var _bodies = self.get_overlapping_bodies()
	var _parent = self.get_parent_node_3d()
	for item in _bodies:
		var _health : HealthComponent = item.get("health")
		if _health != null && item != _parent:
			item.health.injure(damage, self.get_parent_node_3d(), penetration, ignore)
