class_name WeaponImpact
extends Node3D

@export var FLASH : PackedScene
@export var DUST : PackedScene
@export var SPARKS : bool
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
	# apply hit decal
	if DECAL:
		var new_decal : Decal = DECAL.instantiate()
		var decal_normal : Vector3 = Vector3.DOWN + normal
		object.add_child(new_decal)
		new_decal.global_position = location
		new_decal.global_rotation = decal_normal
