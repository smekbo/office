extends Node

var health = 100
@export var health_max = 100
@export var armor = 5
var alive = true

# function that begins the process of taking damage
func injure(damage, penetration = 0, ignore = false):
	# calculate damage
	var damage_taken = damage
	if not ignore: damage_taken -= (armor - penetration)
	
	# apply damage
	health = max(0, health - damage_taken)
	if health <= 0: die()

func heal(healing):
	# heal!
	health = min(health_max, health + healing)

# you fuckin DIE
func die():
	alive = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass