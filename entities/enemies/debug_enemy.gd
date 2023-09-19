extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var animator : AnimationPlayer = $workrobot/AnimationPlayer
@onready var animation_tree : AnimationTree = $workrobot/AnimationTree
@onready var skeleton : Skeleton3D = $workrobot/metarig/Skeleton3D
@onready var health = $HealthComponent
@onready var health_bar : Label = $Control/Health
@onready var ray : RayCast3D = $RayCast3D

@export var target : CharacterBody3D
@export var move_speed = 1.0
@export var turn_speed = 0.1
var swipe_timer : float = 1.0

func _physics_process(delta):
	swipe_timer = max(swipe_timer - delta, 0)
	
	var velocity_next = Vector3.ZERO
	var loc = global_transform.origin
	
	if target:
		nav_agent.target_position = target.global_transform.origin
		if nav_agent.distance_to_target() < 2 and swipe_timer <= 0:
			animation_tree.set("parameters/swipe/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			if ray.is_colliding():
				var player = ray.get_collider()
				player.health.injure(10)
			swipe_timer = animator.get_animation("attack-r-hand-chop").length
	#else:
	#	nav_agent.target_position = loc
	var loc_next = nav_agent.get_next_path_position()
	velocity_next = (loc_next - loc).normalized() * move_speed
	
	if global_transform.origin != loc_next: look_at(Vector3(loc_next.x, position.y, loc_next.z))
	nav_agent.velocity = velocity_next
	move_and_slide()
	
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if health.alive:
		velocity = velocity.move_toward(safe_velocity, 0.25)
	else:
		velocity = Vector3.ZERO
	velocity.y = -9.8
	
	# animation
	animation_tree["parameters/BlendSpace1D/blend_position"] = velocity.y + velocity.x
	
	move_and_slide()

func _on_health_component_died():
	print("Robot died")
	collision_layer = 32
	target = null
	nav_agent.velocity = Vector3.ZERO
	animator.stop()
	skeleton.physical_bones_start_simulation()

func _on_health_component_took_damage():
	health_bar.set_text(str("Enemy Health: ", health.health))

func _on_senses_heard(location):
	nav_agent.target_position = location

func _on_senses_saw(player):
	if target != player: target = player
	nav_agent.target_position = player.global_transform.origin
