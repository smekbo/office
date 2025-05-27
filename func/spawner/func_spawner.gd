extends Node3D
class_name Spawner

func spawn(to_spawn: PackedScene):
	var spawned : Node3D = to_spawn.instantiate() 
	owner.add_child.call_deferred(spawned)
	spawned.set_global_position.call_deferred(global_position)
