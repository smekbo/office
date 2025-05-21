extends Node

signal heard(location: Vector3)
signal saw(player: Object)

@onready var hearing_area = $Hearing
@onready var vision_area = $Vision
@onready var vision_ray = $Vision/VisionRay

@export var vision_scale = 1
@export var hearing_scale = 1

func _ready():
	pass
	
func heard_sound(location: Vector3):
	# i heard something!
	emit_signal("heard", location)

func _on_hearing_area_entered(area):
	# connect sound to hearing when entering area
	area.connect("sound_made", heard_sound)

func _on_hearing_area_exited(area):
	# disconnect sound from hearing when exiting area
	area.disconnect("sound_made", heard_sound)

func _physics_process(_delta):
	# does all the vision processing
	# start with overlapping bodies (anything in layer 1)
	var overlapping = vision_area.get_overlapping_bodies()
	if overlapping:
		# player will always be the only entry in overlapping (for now...)
		var player = overlapping[0]
		# raycast to player position to see if they are visible
		vision_ray.target_position = vision_ray.to_local(player.global_transform.origin)
		var collided : Object = vision_ray.get_collider()
		if collided:
			var is_player = collided.get_collision_layer_value(2)
			# if the raycast hits the player, send the "saw something" signal
			if is_player:
				emit_signal("saw", collided)
