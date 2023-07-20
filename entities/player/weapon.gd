extends Node3D

@onready var impact_scene = preload("res://entities/player/weapon_impact.tscn")

@onready var ray : RayCast3D = $RayCast3D

# firing variables
var firing : bool = false		# is this weapon firing? used for burst
var fire_speed : float = 0.1	# time between shots; "rounds per minute"
var fire_delay: float = 1	# time before you can pull the trigger again; ignored for automatic weapons
var fire_timer : float = 0	# firing timer
var fire_cooldown : float = 0	# firing delay timer

# reload variables
var reloading : bool = false	# is this weapon reloading?
var reload_full : bool = false	# does this weapon always load all ammo? if false, does "progressive" reload
var reload_num : int = 1	# number of shots attempted to load per reload, if reload_full is false
var reload_speed : float = 0.1	# how fast in seconds does this weapon reload (TODO: make this animation-driven)
var reload_timer : float = 0	# reload timer

# ammo variables
var ammo : int = 5		# current ammo
var ammo_max : int = 15	# mag capacity
var ammo_reload : int = 0	# amount of ammo to reload
var reserve : int = 23	# current reserves
var reserve_max : int = 60	# reserve capacity; if -1, infinite ammo

# number of shots fired before firing cooldown happens (each trigger pull)
# 0 or lower for automatic, 1 for semi, 2+ for burst
var shots : int = 3
var shots_left : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# fire a single bullet
func _fire():
	reloading = false
	if fire_timer > 0 or ammo <= 0:
		return
	if ray.is_colliding():
		var col : Object = ray.get_collider()
		var col_point = ray.get_collision_point()
		var impact = impact_scene.instantiate()
		
		# impact impulse
		if col.is_class("RigidBody3D"):
			col.apply_impulse(col.global_position, col_point)
			
		# impact effect
		get_tree().root.add_child(impact)
		impact.position = col_point
	
	fire_timer = fire_speed
	ammo -= 1
	shots_left -= 1

# reload
func _reload():
	if reloading == false or firing == true:
		return
	firing = false
	
	# can't reload weapons that can't hold reserves
	if reserve_max == 0:
		return
	# infinite reload weapons get to skip all the bean counter shit
	elif reserve_max < 0:
		ammo = ammo_max
		ammo_reload = 0
	# bean counter shit
	elif reserve_max > 0:
		if reload_full:
			ammo += ammo_reload
			reserve -= ammo_reload
			ammo_reload = 0
			reloading = false
		elif not reload_full:
			var to_reload = min(ammo_reload, reload_num)
			ammo += to_reload
			reserve -= to_reload
			ammo_reload -= to_reload
			if ammo_reload <= 0:
				reloading = false
	reload_timer = 0
	

# starts the reload. does conditional checks
func _start_reload():
	if reserve_max > 0 and reserve > 0:
		var missing = ammo_max - ammo
		ammo_reload = min(reserve, missing)
		reloading = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# timers
	fire_timer = max(0, fire_timer - delta)
	if not firing:
		fire_cooldown = max(0, fire_cooldown - delta)
	
	# reloading takes time, and can be interrupted
	if Input.is_action_just_pressed("reload"):
		_start_reload()
	if reloading:
		reload_timer += delta
		if reload_timer >= reload_speed:
			_reload()
	
	# automatic fire
	if Input.is_action_pressed("fire"):
		if ammo <= 0:
			_start_reload()
		elif shots == 0:
			_fire()
	# semi-auto and burst fire
	if Input.is_action_just_pressed(("fire")):
		if ammo <= 0:
			_start_reload()
		elif shots > 0 and fire_cooldown <= 0:
			firing = true
			shots_left = min(ammo, shots)
			fire_cooldown = fire_delay
	
	# if the weapon is in the firing state, keep it firing
	if firing:
		if shots_left <= 0:
			firing = false
		elif fire_timer <= 0 and shots_left > 0:
			_fire()
			
