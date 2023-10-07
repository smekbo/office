extends CharacterBody3D

@export var health : Resource

@onready var camera : Node3D = $cam_pivot
@onready var kick_raycast : RayCast3D = $cam_pivot/Camera3D/kick_raycast
@onready var legs : Node3D = $Hmercenary
@onready var legs_animation : AnimationTree = $Hmercenary/AnimationTree
@onready var weapon = $cam_pivot/Camera3D/weapon
@onready var ui_animation : AnimationPlayer = $Control/AnimationPlayer
var smooth_animation_input : Vector2 

var mouse_delta : Vector2 = Vector2()
var lookangle_min : float = -90.0
var lookangle_max : float = 90.0
var look_sensitivity : float = 10.0

var slomoing : bool = false
var slomo : float = 10.0
@export var slomo_max : float = 10.0
@export var kick_strength : float = 5.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _init():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative

func _ready():
	health._ready()
	$Control/Health.set_text(str("health ", snapped(health.health, 1), " armor ", snapped(health.armor, 1)))
	health.connect("injured", _on_health_injured)
	health.connect("healed", _on_health_healed)
	health.connect("died", _on_health_died)

func _process(delta):
	
	# autostops when out
	if slomo <= 0:
		slomoing = false
		Engine.time_scale = 1
	
	# sets engine timescale
	if Input.is_action_just_pressed("slomo"):
		if slomoing == false:
			if slomo > 2:
				Engine.time_scale = 0.2
				slomoing = true
		else:
			Engine.time_scale = 1
			slomoing = false
	
	# slomo resource bar; goes up/down depending on use, 
	if slomoing == true:
		slomo = max(slomo - (delta * (1 / Engine.time_scale)), 0)
	elif slomoing == false:
		slomo = min(slomo + delta, slomo_max)
		
	$Control/Slomo.set_text(str("slomo ", snapped(slomo, .01), "s ", "ts ", Engine.time_scale, " ", slomoing))
	$Control/Reload.set_text(str("reloading ", weapon.reloading, " ", snapped(weapon.reload_timer, .01), "s"))
	$Control/Ammo.set_text(str("ammo ", weapon.ammo, " / ", weapon.ammo_max, " reserve ", weapon.reserve, " / ", weapon.reserve_max))
	$Control/Ammo2.set_text(str("progressive ", not weapon.reload_num >= weapon.ammo_max, " missing ", weapon.ammo_reload))
	$Control/Refire.set_text(str("refire ", snapped(weapon.fire_timer, .01), " cooldown ", snapped(weapon.fire_cooldown, .01)))
	$Control/Spread.set_text(str("spread ", snapped(weapon.spread, .01)))
	$Control/Health.set_text(str("health ", snapped(health.health, 1), " armor ", snapped(health.armor, 1)))
	$Control/DebugNormals.set_text(str("direction ", weapon.dir_normal, " collision ", weapon.col_normal))
	
	$Control/crosshair/u_cross.position = Vector2(2, -2-(weapon.spread*2))
	$Control/crosshair/d_cross.position = Vector2(2, 2+(weapon.spread*2))
	$Control/crosshair/l_cross.position = Vector2(-2-(weapon.spread*2), 2)
	$Control/crosshair/r_cross.position = Vector2(2+(weapon.spread*2), 2)

func _physics_process(delta):
	velocity.x = 0
	velocity.z = 0

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var forward = global_transform.basis.z
	var right = camera.global_transform.basis.x
	
	var relativeDir = (forward * input_dir.y + right * input_dir.x)

	# set the velocity
	velocity.x = relativeDir.x * SPEED
	velocity.z = relativeDir.z * SPEED

	# apply gravity
	velocity.y -= gravity * delta

	# move the player
	move_and_slide()

	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("heal"):
		health.heal(5)
		
	if Input.is_action_just_pressed("injure"):
		health.injure(10, 0, false)
	
	if mouse_delta:
		process_camera(delta)
	
	if Input.is_action_just_pressed("kick"):
		# kick function is triggered by animation
		legs_animation["parameters/OneShot/request"] = 1
	
	# Legs animation and easing	
	smooth_animation_input.x = move_toward(smooth_animation_input.x, input_dir.x, delta*2)
	smooth_animation_input.y = move_toward(smooth_animation_input.y, input_dir.y, delta*2)
	legs_animation["parameters/BlendSpace2D/blend_position"] = smooth_animation_input

#demonstrating

func kick():
	var obj = kick_raycast.get_collider()
	if obj:
		var col_point = kick_raycast.get_collision_point()
		var hit_dir = col_point - kick_raycast.global_position
		var impulse_dir = (hit_dir * Vector3(1,0,1)).normalized()
		
		# impact impulse
		if obj.is_class("RigidBody3D"):
			obj.apply_impulse(impulse_dir * kick_strength)

func process_camera(delta):
	camera.rotation_degrees.x -= mouse_delta.y * look_sensitivity * delta

	# Should clamp this value, but this code isn't working right ATM
	#camera.rotation_degrees.x = clamp(rotation_degrees.x, lookangle_min, lookangle_max)

	# rotate the player along their y-axis
	rotation_degrees.y -= mouse_delta.x * look_sensitivity * delta
	
	
	mouse_delta = Vector2()

func _on_health_injured(amount, source):
	ui_animation.stop()
	ui_animation.play("hurt_screen")

func _on_health_healed(amount, source):
	pass

func _on_health_died(killer):
	pass
