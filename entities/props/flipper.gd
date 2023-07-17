extends Area3D

@export var STRENGTH := 2
@onready var flip_detector : RayCast3D = $flip_detector

#func _physics_process(delta):
#	if flip_detector.is_colliding():
#		flip_detector.enabled = false
#		owner.sleeping = true
#		$CPUParticles3D.emitting = false

func _flip():
	$CPUParticles3D.emitting = true
	owner.sleeping = false
	flip_detector.enabled = true
	print(global_transform.basis.z)
	owner.apply_impulse(-global_transform.basis.z * STRENGTH,Vector3(0,1,0))	

func _kick(collision : Vector3):
	pass
