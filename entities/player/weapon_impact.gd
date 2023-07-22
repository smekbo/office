class_name WeaponImpact
extends Node3D

@export var DUST_TEXTURE : CompressedTexture2D 
@export var SPARKS : bool
@export var DECAL : Decal

#@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var dust : Node3D = $dust
@onready var sparks : Node3D = $sparks

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	dust.set_texture(DUST_TEXTURE)
	
func start(impact_location : Vector3, reflect_direction : Vector3):
	#if SPARKS:
	#	var new_sparks = sparks.duplicate()
	#	new_sparks.global_position = impact_location
	#	new_sparks.set_reflect_direction(reflect_direction)
	#	new_sparks.emitting = true
	
	var new_dust_sprite : Node3D = dust.duplicate()
	get_tree().root.add_child(new_dust_sprite)
	new_dust_sprite.global_position = impact_location
	new_dust_sprite.show()
	new_dust_sprite.emit()
