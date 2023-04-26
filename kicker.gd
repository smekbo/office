extends Area3D

@onready var sides = $sides

var STRENGTH := 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _kick(collision : Vector3):
	var nearest = sides.get_children()[0]
	var shortest_dist = collision.distance_to(sides.get_children()[0].global_position)
	for side in sides.get_children():
		var dist = collision.distance_to(side.global_position)
		if dist < shortest_dist:
			nearest = side 
	
	owner.apply_impulse(nearest.global_transform.basis.z * STRENGTH, Vector3(0,1,0))		

func _flip():
	pass
