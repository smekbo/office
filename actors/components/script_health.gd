extends Resource
class_name HealthComponent

## This object has died. Passes the [param killer].
signal died(killer)
## This object was injured. Passes the [param amount] of damage and its [param source].
signal injured(amount, source)
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
@export var killable = false

## Is this character alive?
var alive = true

func _ready():
	health = health_max
	armor = armor_max

## Injures the character this [HealthComponent] is attached to. 
## Takes [param damage] for initial damage, [param source] for damage source, [param penetration] for amount of resist ignored, and [param ignore] to fully ignore all resistance.
## Emits [param injured] signal, and [param died] signal if damage was lethal.
func injure(damage:int, source = null, penetration:int = 0, ignore:bool = false):
	if not invulnerable: # if you're invuln, you don't take damage!
		var taken = damage
		var resist_percent = max(0 , min(1, (float(resistance - penetration)) / 100))
		var resisted = taken * resist_percent
		
		if not ignore and resisted > 0: # armor calculation and adjustment
			if not super_armor: resisted = min(1, armor / resisted) * resisted
			taken -= resisted
		if taken > 0: # apply damage and armor loss
			health = max(0, health - taken)
			if not super_armor: armor = max(0, armor - resisted)
			injured.emit(taken, source)
		
	# megamind meme no health???
	if killable and health <= 0: die(source)

## Heals the character this [HealthComponent] is attached to. 
## Takes [param amount] for healing, and [param source] for healing source.
## Emits [param healed] signal.
func heal(amount:int, source = null):
	health = min(health_max, health + amount)
	healed.emit(amount, source)

## Armors the character this [HealthComponent] is attached to. 
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
