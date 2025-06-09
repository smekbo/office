extends Node3D
class_name Room

@onready var spawners : Array = get_spawners()

## Gets all the spawners attached to this room
func get_spawners():
	var _spawners = get_children()
	var to_return = []
	for spawner in _spawners:
		if spawner is Spawner:
			to_return.append(spawner)
	print(str(to_return))
	return to_return

## Spawns an encounter in this room
## Currently only spawns one entity per spawner
## Todo: Multiple entities per spawner?
func spawn_encounter(encounter : Encounter):
	var _spawner_num = spawners.size()
	var enemies = encounter.enemies
	var i : int = 0
	for spawner : Spawner in spawners:
		if not enemies.is_empty() && i <= enemies.size() - 1:
			spawner.spawn(enemies[i])
			i += 1
