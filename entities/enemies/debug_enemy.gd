extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@export var target : CharacterBody3D
@export var move_speed = 1.0

func _physics_process(delta):
	if target:
		nav_agent.target_position = target.global_transform.origin
	
	var loc = global_transform.origin
	var loc_next = nav_agent.get_next_path_position()
	var velocity_next = (loc_next - loc).normalized() * move_speed
	
	nav_agent.velocity = velocity_next
	
	look_at(loc_next)
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, 0.25)
	velocity.y = -9.8
	move_and_slide()
