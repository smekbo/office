class_name WeaponImpact
extends Node3D

@export var FLASH : CompressedTexture2D
@export var DUST : CompressedTexture2D 
@export var SPARKS : bool
@onready var DECAL : Node3D = $bullet_hole

#@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var dust : Node3D = $Dust
@onready var sparks : Node3D = $Spark
@onready var flash : Node3D = $Flash

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	#dust.texture = DUST
	
func start(impact_location : Vector3, spark_direction : Vector3 = Vector3(0,0,1)):
	#if SPARKS:
	#	var new_sparks = sparks.duplicate()
	#	new_sparks.global_position = impact_location
	#	new_sparks.set_reflect_direction(reflect_direction)
	#	new_sparks.emitting = true
	
	global_position = impact_location
	show()
	animator.play("emit")
	sparks.process_material.direction = spark_direction
	dust.process_material.direction = spark_direction
