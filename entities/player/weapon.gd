extends Node3D
class_name Weapon

## Class / scene for all player weapons.

@onready var ray : RayCast3D = $RayCast3D
@onready var animation : AnimationPlayer = $"viewmodel-pistol/AnimationPlayer"
@onready var sound_col : Area3D = $SoundRadius
@export var default_impact : PackedScene

# Variables related to damage.
@export_group("Damage")
## Base weapon damage.
@export var damage : int = 10
## Damage penetration, expressed as a percentage ([code]penetration / 100[/code]).
@export var penetration : int = 3
## How much impulse force is applied on hit to objects.
@export var force : float = 2.5

## Variables related to firing.
@export_group("Firing")
## Is this weapon firing? Used in burst-fire weapons.
var firing : bool = false
## Time in seconds between shots. 
## To get RPM, use the following formula: [cose](1 / fire_speed) * 60[/code].
@export var fire_speed : float = 0.1
## Time before you can pull the trigger again; ignored for automatic weapons.
@export var fire_delay: float = 1
## Firing timer.
var fire_timer : float = 0
## Fire delay timer.
var fire_cooldown : float = 0
## Number of shots fired before firing cooldown happens (each trigger pull).
## 0 or lower for automatic, 1 for semi, 2+ for burst.
@export var shots : int = 3
## Number of shots left in the current burst.
var shots_left : int = 0

## Variables related to spread.
@export_group("Spread")
## Current spread.
var spread : float = 0
## Minimum spread value (0 or greater).
@export var spread_min : float = 0
## Maximum spread value (0 or greater).
@export var spread_max : float = 3
## How much the spread increases per shot.
@export var spread_inc : float = 0.1
## How much the spread decreases each second; "resting" time.
@export var spread_dec : float = 0.05
## The spread scalar; "accuracy".
@export var spread_scalar : float = 1

## Variables related to ammo
@export_group("Ammo")
## Current ammo.
@export var ammo : int = 5
## Magazine capacity.
@export var ammo_max : int = 15
## Current reserves.
@export var reserve : int = 23
## Reserve capacity; if -1, infinite ammo.
@export var reserve_max : int = 60
## Amount of ammo left to reload; used in progressive reloads.
var ammo_reload : int = 0

## Variables related to reloading
@export_group("Reloading")
## Number of shots attempted to load per reload. If less than [param ammo_max], will perform "progressive" reloads (like a tube-fed shotgun).
@export var reload_num : int = 1
## How fast in seconds does this weapon reload (TODO: make this animation-driven)
@export var reload_speed : float = 0.1
## Reload timer.
var reload_timer : float = 0
## Is this weapon reloading?
var reloading : bool = false

var col_normal : Vector3
var dir_normal : Vector3

signal made_sound(location: Vector3)

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("idle_pose")
	pass

# fire a single bullet
func fire():
	reloading = false
	if fire_timer > 0 or ammo <= 0:
		return
	ray.target_position = Vector3(randf_range(-spread, spread), randf_range(-spread, spread), 100)
	if ray.is_colliding():
		var col : Node = ray.get_collider()
		var col_point : Vector3 = ray.get_collision_point()
		col_normal = ray.get_collision_normal()
		var dir : Vector3 = col_point - ray.global_position
		dir_normal = dir.normalized()
		var dir_reflect : Vector3 = dir_normal.reflect(col_normal)
		var impact : WeaponImpact = col.get_node_or_null("weapon_impact")
		
		# impact impulse
		if col.is_class("RigidBody3D"):
			col.apply_impulse(dir_normal * force)
		
		var h_comp = col.get("health")
		
		# health damage
		if h_comp != null: 
			if h_comp.alive == false: 
				ray.add_exception(col)
			else: h_comp.injure(damage, penetration)
		
		# impact effect
		if not col.is_class("CharacterBody3D"):
			if impact:
				impact.start(col, col_point, col_normal)
			else:
				var new_impact = default_impact.instantiate()
				get_tree().get_root().add_child(new_impact)
				new_impact.global_position = col_point
				new_impact.start(col, col_point, col_normal)
	
	animation.stop()
	animation.play("fire_2")
	fire_timer = fire_speed
	ammo -= 1
	shots_left -= 1
	spread = min(spread_max, spread + spread_inc)
	sound_col.emit_signal("sound_made", sound_col.global_transform.origin)

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
		animation.play("reload_2")
		reload_speed = animation.current_animation_length
		
		

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
			
func _physics_process(delta):
	sound_col.visible = false
