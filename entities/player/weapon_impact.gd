class_name WeaponImpact
extends Node3D

@export var SPRITE : CompressedTexture2D 
@export var SPARKS : bool
@export var DECAL : Decal

#@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var dust : Node3D = $Sprite3D
@onready var sparks : Node3D = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	dust.texture = SPRITE
	
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
