extends CharacterBody3D

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var animator : AnimationPlayer = $"workrobot-model/AnimationPlayer"
@onready var animation_tree : AnimationTree = $"workrobot-model/AnimationTree"
@onready var skeleton : Skeleton3D = $"workrobot-model"/metarig/Skeleton3D
@onready var health_bar : Label = $Control/Health
@onready var ray : RayCast3D = $RayCast3D

## The health component for this enemy. Governs health, armor, injury, and healing.
@export var health : Resource
## The amount of time (in [param seconds]) that this NPC will continue tracking a target it can't see.
@export var intuition : float = 3.0
var intuition_timer : float = 0.0
var target : CharacterBody3D
## NPC's move speed in units/s
@export var move_speed = 1.0
@export var turn_speed = 0.1
var swipe_timer : float = 1.0

func _ready():
	animator.play("idle")
	health._ready()
	health_bar.set_text(str("Enemy Health: ", health.health))
	health.connect("injured", _on_health_injured)
	health.connect("healed", _on_health_healed)
	health.connect("died", _on_health_died)

func _physics_process(delta):
	# timers
	swipe_timer = max(swipe_timer - delta, 0)
	intuition_timer = max(intuition_timer - delta, 0)
	
	var velocity_next = Vector3.ZERO
	var loc = global_transform.origin
	var loc_next = nav_agent.get_next_path_position()
	velocity_next = (loc_next - loc).normalized() * move_speed
	
	if target:
		var distance = (target.global_transform.origin - global_transform.origin).length()
		nav_agent.target_position = target.global_transform.origin
		if distance < 1.5:
			velocity_next = Vector3.ZERO
			if swipe_timer <= 0:
				animation_tree.set("parameters/swipe/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				if ray.is_colliding():
					var _player = ray.get_collider()
				swipe_timer = animator.get_animation("attack-r-hand-chop").length
	
	if global_transform.origin != loc_next: 
		look_at(Vector3(loc_next.x, position.y, loc_next.z))
	nav_agent.velocity = velocity_next
	move_and_slide()
	
	# conditionals to alter NPC behavior
	if intuition_timer <= 0: target = null

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if health.alive:
		velocity = velocity.move_toward(safe_velocity, 0.25)
	else:
		velocity = Vector3.ZERO
		
	# walk blend
	var _blendval = max(min(1, abs(velocity.x) + abs(velocity.z)), 0)
	animation_tree["parameters/BlendSpace1D/blend_position"] = velocity.x + velocity.z
	
	move_and_slide()

func _on_health_injured(_amount, _source):
	health_bar.set_text(str("Enemy Health: ", health.health))

func _on_health_healed(_amount, _source):
	pass

func _on_health_died(_killer):
	print("Robot died")
	collision_layer = 32
	target = null
	nav_agent.velocity = Vector3.ZERO
	animation_tree.set("parameters/die/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _on_senses_heard(location):
	nav_agent.target_position = location

func _on_senses_saw(player):
	if target != player: target = player
	nav_agent.target_position = player.global_transform.origin
	intuition_timer = intuition

func _ragdoll():
	skeleton.physical_bones_start_simulation()

func attack():
	if ray.is_colliding():
		var player = ray.get_collider()
		player.health.injure(10, self)
