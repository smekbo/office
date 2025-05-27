## The singleton director which governs wave count, room respawning, and the like.
## Rooms should be single-deep child nodes of the director, to ensure that they can be found and iterated on properly

extends Node3D
class_name Director

var wave : int = 1
var score : int = 0
@onready var rooms : Array = get_rooms()

@export_category("Encounters")
@export var easy_encounters : Array[Encounter]
@export var medium_encounters : Array
@export var hard_encounters : Array
@export var impossible_encounters : Array

func _ready() -> void:
	for room : Room in rooms:
		room.spawn_encounter(easy_encounters[0])

## Gets all rooms attached to this director.
func get_rooms() -> Array:
	var _rooms = get_children()
	var to_return = []
	for room in _rooms:
		if room is Room:
			to_return.append(room)
	return to_return
