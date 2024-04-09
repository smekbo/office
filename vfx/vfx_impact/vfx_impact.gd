class_name WeaponImpact
extends Node3D

@export var sparking : bool
@export var spark_chance : float = 1.0
@export var dusting : bool
@export var dust : Resource
@export var dust_chance : float = 1.0
@export var decal : PackedScene

@export_group("Spark Overrides")
@export var spark_override : Mesh
@export var spark_process_override : ParticleProcessMaterial
@export var spark_lifetime : float
@export var spark_amount : int
@export var spark_explosiveness : float

#@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var animator : AnimationPlayer = $AnimationPlayer
@onready var dust_node : Node3D = $Dust
@onready var sparks : GPUParticles3D = $Spark

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	if spark_override: sparks.draw_pass_1 = spark_override
	if spark_process_override: sparks.process_material = spark_process_override
	if spark_lifetime: sparks.lifetime = spark_lifetime
	if spark_explosiveness: sparks.explosiveness = spark_explosiveness
	if spark_amount: sparks.amount = spark_amount
	
func start(object : PhysicsBody3D, location : Vector3, normal : Vector3 = Vector3(0,0,1)):
	# set impact position to location and start impact scene
	global_position = location
	show()
	animator.play("emit")
	
	#set spark and dust particle directions to the collision normal
	sparks.process_material.direction = normal
	dust_node.process_material.direction = normal
	
	# randomize if dust/sparks are visible
	var spark_roll = randf()
	if sparking and spark_chance >= spark_roll: 
		sparks.visible = false
	var dust_roll = randf()
	if dusting and dust_chance >= dust_roll: 
		dust_node.visible = false
	
	# apply hit decal
	if decal:
		# instance decal and set up other variables
		var new_decal : Decal = decal.instantiate()
		var decal_normal : Vector3 = Vector3.DOWN + normal
		var random_rot : int = randi_range(-180, 180)
		
		# parent, place, and properly rotate decal
		object.add_child(new_decal)
		new_decal.global_position = location
		new_decal.global_rotation = decal_normal
		
		# add a little random rotation to spice it up
		new_decal.global_transform.basis = new_decal.global_transform.basis.rotated(normal, deg_to_rad(random_rot))
