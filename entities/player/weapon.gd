extends Node3D

@onready var impact_scene = preload("res://entities/player/weapon_impact.tscn")

@onready var ray : RayCast3D = $RayCast3D

var firing_speed : float = 0.05
var firing_timer : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("fire"):
		if firing_timer >= firing_speed:
			firing_timer = 0
			if ray.is_colliding():
				var col = ray.get_collision_point()
				var impact = impact_scene.instantiate()
				
				get_tree().root.add_child(impact)
				impact.position = col
		firing_timer += delta
