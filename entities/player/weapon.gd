extends Node3D

@onready var impact_scene = preload("res://entities/player/weapon_impact.tscn")

@onready var ray : RayCast3D = $RayCast3D

# damage variables
@export var damage : int = 10		# base damage
@export var damage_pen : int = 3	# how much the damage penetrates armor
@export var force : float = 2.5		# how much impulse force is applied on hit

# firing variables
var firing : bool = false		# is this weapon firing? used for burst
@export var fire_speed : float = 0.1	# time between shots; "rounds per minute"
@export var fire_delay: float = 1	# time before you can pull the trigger again; ignored for automatic weapons
var fire_timer : float = 0	# firing timer
var fire_cooldown : float = 0	# firing delay timer

# spread variables
var spread : float = 0		# our current spread
@export var spread_min : float = 0	# minimum spread value
@export var spread_max : float = 3	# maximum spread value
@export var spread_inc : float = 0.1	# how much the spread increases per shot
@export var spread_dec : float = 0.05	# how much the spread decreases to minimum each second
@export var spread_scalar : float = 1	# the spread scalar; "accuracy"

# reload variables
var reloading : bool = false	# is this weapon reloading?
@export var reload_num : int = 1	# number of shots attempted to load per reload. if less than mag size, will do "progressive" reloads
@export var reload_speed : float = 0.1	# how fast in seconds does this weapon reload (TODO: make this animation-driven)
var reload_timer : float = 0	# reload timer

# ammo variables
@export var ammo : int = 5		# current ammo
@export var ammo_max : int = 15	# mag capacity
var ammo_reload : int = 0	# amount of ammo to reload
@export var reserve : int = 23	# current reserves
@export var reserve_max : int = 60	# reserve capacity; if -1, infinite ammo

# number of shots fired before firing cooldown happens (each trigger pull)
# 0 or lower for automatic, 1 for semi, 2+ for burst
@export var shots : int = 3
var shots_left : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# fire a single bullet
func fire():
	reloading = false
	if fire_timer > 0 or ammo <= 0:
		return
	ray.target_position = Vector3(randf_range(-spread, spread), randf_range(-spread, spread), 100)
	if ray.is_colliding():
		var col : Object = ray.get_collider()
		var col_point = ray.get_collision_point()
		var impact = impact_scene.instantiate()
		
		# impact impulse
		if col.is_class("RigidBody3D"):
			col.apply_impulse((col_point - ray.global_position) * force)
		
		var h_comp = col.get_node("HealthComponent")
		if h_comp: h_comp.injure(damage, damage_pen)
		
		# impact effect
		get_tree().root.add_child(impact)
		impact.position = col_point
	
	fire_timer = fire_speed
	ammo -= 1
	shots_left -= 1
	spread = min(spread_max, spread + spread_inc)

# reload
func _reload():
	if reloading == false or firing == true:
		return
	firing = false
	
	# can't reload weapons that can't hold reserves
	if reserve_max == 0:
		return
	# mag vs progressive reload
	if reload_num >= ammo_max:
		ammo += ammo_reload
		if reserve_max > 0: reserve -= ammo_reload
		ammo_reload = 0
		reloading = false
	else:
		var to_reload = min(ammo_reload, reload_num)
		ammo += to_reload
		if reserve_max > 0: reserve -= to_reload
		ammo_reload -= to_reload
		if ammo_reload <= 0:
			reloading = false	
	reload_timer = 0
	

# starts the reload. does conditional checks
func start_reload():
	if reserve_max == 0:
		return
	if reserve_max <= 0 or (reserve_max > 0 and reserve > 0):
		var missing = ammo_max - ammo
		ammo_reload = min(reserve, missing)
		reloading = true
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# timers
	fire_timer = max(0, fire_timer - delta)
	if not firing:
		fire_cooldown = max(0, fire_cooldown - delta)
		spread = max(0, spread - (spread_dec * delta))
	
	# reloading takes time, and can be interrupted
	if Input.is_action_just_pressed("reload"):
		start_reload()
	if reloading:
		reload_timer += delta
		if reload_timer >= reload_speed:
			_reload()
	
	# automatic fire
	if Input.is_action_pressed("fire"):
		if ammo <= 0:
			start_reload()
		elif shots == 0:
			fire()
	# semi-auto and burst fire
	if Input.is_action_just_pressed(("fire")):
		if ammo <= 0:
			start_reload()
		elif shots > 0 and fire_cooldown <= 0:
			shots_left = min(ammo, shots)
			fire_cooldown = fire_delay
			firing = true
	
	# if the weapon is in the firing state, keep it firing
	if firing:
		if shots_left <= 0:
			firing = false
		elif fire_timer <= 0 and shots_left > 0:
			fire()
			
