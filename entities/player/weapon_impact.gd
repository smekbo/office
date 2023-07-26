class_name WeaponImpact
extends Node3D

@export var SPARKS : bool
@export var DUST : Resource
@export var DECAL : PackedScene

#@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var dust : Node3D = $Dust
@onready var sparks : Node3D = $Spark

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	#dust.texture = DUST
	
func start(object : PhysicsBody3D, location : Vector3, normal : Vector3 = Vector3(0,0,1)):
	# set impact position to location and start impact scene
	global_position = location
	show()
	animator.play("emit")
	
	#set spark and dust practicle directions to the collision normal
	sparks.process_material.direction = normal
	dust.process_material.direction = normal
	
	# randomize if dust/sparks are visible
	if randf() > 0.5: 
		sparks.visible = false
	if randf() > 0.5: 
		dust.visible = false
	
	# apply hit decal
	if DECAL:
		# instance decal and set up other variables
		var new_decal : Decal = DECAL.instantiate()
		var decal_normal : Vector3 = Vector3.DOWN + normal
		var random_rot : int = randi_range(-180, 180)
		
		# parent, place, and properly rotate decal
		object.add_child(new_decal)
		new_decal.global_position = location
		new_decal.global_rotation = decal_normal
		
		# add a little random rotation to spice it up
		new_decal.global_transform.basis = new_decal.global_transform.basis.rotated(normal, deg_to_rad(random_rot))
