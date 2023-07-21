extends CharacterBody3D

signal use

@onready var camera = $Camera3D
@onready var use_ray :RayCast3D = $Camera3D/RayCast3D

# physics
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	velocity.x = 0
	velocity.z = 0

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var forward = camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

	var relativeDir = (forward * input_dir.y + right * input_dir.x)

	# set the velocity
	velocity.x = relativeDir.x * moveSpeed
	velocity.z = relativeDir.z * moveSpeed

	# apply gravity
	velocity.y -= gravity * delta

	# move the player
	move_and_slide()

	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jumpForce
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_just_pressed("use"):
		var col = use_ray.get_collision_point()
		print(col)
		var obj = use_ray.get_collider()
		if obj:
			obj._flip()
			obj._kick(col)
		use.emit()
