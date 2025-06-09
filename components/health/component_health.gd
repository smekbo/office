## Adds "health" to this object, allowing it to be damaged. 
## Should always be assigned to the "health" property on the object; see player object for an example.

extends Resource
class_name ComponentHealth

## This object has died. Passes the [param killer].
signal died(killer)
## This object was injured. Passes the [param amount] of damage and its [param source].
signal injured(amount, crit, source)
## This object was healed. Passes the [param amount] of healing and its [param source].
signal healed(amount, source)
## This object was armored. Passes the [param amount] of armoring and its [param source].
signal armored(amount, source)

## Current health. This is reduced when you take damage, and is modified by your resistance value.
var health = 0
## Maximum health.
@export var health_max = 100

## Current armor. This is reduced when you take damage, according to the amount of damage you resisted.
var armor = 0
## Maximum armor.
@export var armor_max = 20
## Armor resistance, expressed as a percentage ([code]resistance / 100[/code])
@export var resistance = 50
## Does this character [b]always resist[/b] attacks? Ignores armor values when calculating resistance.
@export var super_armor = false

## Is this character invulnerable (ignores all damage)?
@export var invulnerable = false
## Is this character unkillable (does not die)?
@export var killable = true

## If you shoot the weak spot, what is the damage multiplier?
@export var crit_mult : float = 2.0

## Is this character alive?
var alive = true

func _ready():
	health = health_max
	armor = armor_max
	if not is_local_to_scene(): push_warning("Health component for " + str(resource_path) + " is not set to loca-to-scene! All stats are shared between all objects with this component!")

## Injures the character this [ComponentHealth] is attached to. 
## Takes [param damage] for initial damage, [param source] for damage source, [param penetration] for amount of resist ignored, and [param ignore] to fully ignore all resistance.
## Emits [param injured] signal, and [param died] signal if damage was lethal.
func injure(damage:int, crit = false, penetration:int = 0, ignore:bool = false, source = null) -> int:
	var taken = 0
	if not invulnerable: # if you're invuln, you don't take damage!
		taken = damage
		if crit: taken *= crit_mult
		var resist_percent = max(0 , min(1, (float(resistance - penetration)) / 100))
		var resisted = taken * resist_percent
		
		if not ignore and resisted > 0: # armor calculation and adjustment
			if not super_armor: resisted = min(1, armor / resisted) * resisted
			taken -= resisted
		if taken > 0: # apply damage and armor loss
			taken = roundi(taken)
			health = max(0, health - taken)
			if not super_armor: armor = max(0, armor - resisted)
			injured.emit(taken, crit, source)
		
	# megamind meme no health???
	if killable and health <= 0:
		die(source)
	
	return taken

## Heals the character this [ComponentHealth] is attached to. 
## Takes [param amount] for healing, and [param source] for healing source.
## Emits [param healed] signal.
func heal(amount:int, source = null):
	health = min(health_max, health + amount)
	healed.emit(amount, source)

## Armors the character this [ComponentHealth] is attached to. 
## Takes [param amount] for armoring amount, and [param source] for armoring source.
## Emits [param armored] signal.
func armoring(amount:int, source = null):
	armor = min(armor_max, armor + amount)
	armored.emit(amount, source)

## Kills this character. Flips the [param alive] bool to false.
## Takes [param killer] for the object that made the final blow.
## Emits [param died] signal.
func die(killer):
	alive = false
	died.emit(killer)
