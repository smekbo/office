## Component which allows objects to "use" something.
## Basically just a raycast that looks for a "usable" collision volume.

extends RayCast3D
class_name ComponentUser

func use():
	if is_colliding():
		var _usable : ComponentUsable = get_collider()
		_usable.attempt(self.get_owner())
