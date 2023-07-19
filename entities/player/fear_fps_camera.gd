extends CharacterBody3D

@onready var camera : Node3D = $cam_pivot

@onready var gun_animation : AnimationTree = $cam_pivot/gangstarig/AnimationTree

@onready var kick_raycast : RayCast3D = $cam_pivot/kick_raycast
@onready var legs : Node3D = $Hmercenary
@onready var legs_animation : AnimationTree = $Hmercenary/AnimationTree
@onready var weapon = $cam_pivot/weapon
var smooth_animation_input : Vector2 

var mouseDelta : Vector2 = Vector2()
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 10.0

var slomoActive : bool = false
var slomo : float = 10.0
var slomoMax : float = 10.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative

func _process(delta):
	
	# autostops when out
	if slomo <= 0:
		slomoActive = false
		Engine.time_scale = 1
	
	# sets engine timescale
	if Input.is_action_just_pressed("slomo"):
		if slomoActive == false:
			if slomo > 2:
				Engine.time_scale = 0.2
				slomoActive = true
		else:
			Engine.time_scale = 1
			slomoActive = false
	
	# slomo resource bar; goes up/down depending on use, 
	if slomoActive == true:
		slomo = max(slomo - (delta * (1 / Engine.time_scale)), 0)
	elif slomoActive == false:
		slomo = min(slomo + delta, slomoMax)
		
	$Control/Slomo.set_text(str("slomo ", snapped(slomo, .01), "s ", "ts ", Engine.time_scale, " ", slomoActive))
	$Control/Reload.set_text(str("reloading ", weapon.reloading, " ", snapped(weapon.reload_timer, .01), "s"))
	$Control/Ammo.set_text(str("ammo ", weapon.ammo, " / ", weapon.ammo_max, " reserve ", weapon.reserve, " / ", weapon.reserve_max))
	$Control/Ammo2.set_text(str("progressive ", not weapon.reload_full, " missing ", weapon.ammo_reload))
	$Control/Refire.set_text(str("refire ", snapped(weapon.fire_timer, .01), " cooldown ", snapped(weapon.fire_cooldown, .01)))

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
	
	if mouseDelta:
		process_camera(delta)
		
	if Input.is_action_pressed("fire"):
		gun_animation["parameters/Blend2/blend_amount"] = 1
	else :
		gun_animation["parameters/Blend2/blend_amount"] = 0
	
	if Input.is_action_just_pressed("kick"):
		legs_animation["parameters/OneShot/request"] = 1
		var obj = kick_raycast.get_collider()
		if obj:
			obj._flip()

	
	# Legs animation and easing	
	smooth_animation_input.x = move_toward(smooth_animation_input.x, input_dir.x, delta*2)
	smooth_animation_input.y = move_toward(smooth_animation_input.y, input_dir.y, delta*2)
	legs_animation["parameters/BlendSpace2D/blend_position"] = smooth_animation_input
		
#	if Input.is_action_just_pressed("use"):
#		var col = use_ray.get_collision_point()
#		print(col)
#		var obj = use_ray.get_collider()
#		if obj:
#			obj._flip()
#			obj._kick(col)
#		use.emit()


func process_camera(delta):
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta

	# Should clamp this value, but this code isn't working right ATM
	#camera.rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)

	# rotate the player along their y-axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	
	
	mouseDelta = Vector2()
